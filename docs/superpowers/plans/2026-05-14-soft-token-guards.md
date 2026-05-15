# Soft Token Guards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 Claude Code 适配主链路落地第一轮软提醒 token guard，包括 session 切换提醒、fan-out 预算检查、任务分类路由建议与输出预算模板。

**Architecture:** 本轮只做“软治理”闭环，不引入新后台服务，也不做硬阻断。运行时部分放在 `statusline.sh` 与 `session-summary.sh`，路由与输出预算部分放在核心 skill 文本中，测试层用 `unittest` 锁定脚本输出、阈值判断与 skill 规则落点。

**Tech Stack:** Bash, Python 3.10+, `unittest`, `json`, `subprocess`, Markdown skills

---

## File Map

**Modify**
- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`
- `.claude/skills/using-superpowers/SKILL.md`
- `.claude/skills/dispatching-parallel-agents/SKILL.md`
- `.claude/skills/verification-before-completion/SKILL.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

**Create**
- `tests/test_soft_token_guards.py`
- `docs/reports/2026-05-14-soft-token-guards-validation.md`

**Verify**
- `docs/superpowers/specs/2026-05-14-soft-token-guards-design.md`
- `docs/reports/2026-05-14-claude-code-token-escape-cases.md`

---

### Task 1: 先写回归测试，锁定 guard 输出与技能规则

**Files:**
- Create: `tests/test_soft_token_guards.py`
- Verify: `.claude/scripts/statusline.sh`
- Verify: `.claude/hooks/session-summary.sh`
- Verify: `.claude/skills/using-superpowers/SKILL.md`
- Verify: `.claude/skills/dispatching-parallel-agents/SKILL.md`
- Verify: `.claude/skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: 写失败测试，覆盖 statusline guard 状态**

```python
class SoftTokenGuardTests(unittest.TestCase):
    def test_statusline_shows_cutover_warning_when_usage_crosses_threshold(self) -> None:
        payload = {
            "model": {"display_name": "Claude"},
            "workspace": {"current_dir": "/tmp/demo"},
            "context_window": {
                "context_window_size": 200000,
                "current_usage": {
                    "input_tokens": 25000,
                    "cache_creation_input_tokens": 10000,
                    "cache_read_input_tokens": 2100000,
                },
            },
            "cost": {"total_cost": 0.1234},
        }
        result = subprocess.run(
            ["bash", str(REPO_ROOT / ".claude/scripts/statusline.sh")],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(0, result.returncode)
        self.assertIn("CUTOVER", result.stdout)
```

- [ ] **Step 2: 写失败测试，覆盖 session-summary 的收口建议**

```python
    def test_session_summary_writes_guard_section_when_usage_snapshot_exists(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps(
                    {
                        "api_requests": 31,
                        "output_tokens": 51000,
                        "cache_read_input_tokens": 2500000,
                        "continued_session": True,
                    }
                ),
                encoding="utf-8",
            )
            result = subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/hooks/session-summary.sh")],
                cwd=repo,
                text=True,
                capture_output=True,
                check=False,
            )
            summary = (repo / ".claude/tmp/session_summary.md").read_text(encoding="utf-8")
        self.assertEqual(0, result.returncode)
        self.assertIn("Session Guard", summary)
        self.assertIn("建议切新 session", summary)
```

- [ ] **Step 3: 写失败测试，覆盖三份 skill 文本是否包含新 guard 规则**

```python
    def test_skill_docs_include_router_fanout_and_output_budget_rules(self) -> None:
        using = (REPO_ROOT / ".claude/skills/using-superpowers/SKILL.md").read_text(encoding="utf-8")
        dispatch = (REPO_ROOT / ".claude/skills/dispatching-parallel-agents/SKILL.md").read_text(encoding="utf-8")
        verify = (REPO_ROOT / ".claude/skills/verification-before-completion/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Task-Class Router", using)
        self.assertIn("预算检查", dispatch)
        self.assertIn("Output Budget", verify)
```

- [ ] **Step 4: 运行失败测试，确认红灯**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
FAIL: test_statusline_shows_cutover_warning_when_usage_crosses_threshold
FAIL: test_session_summary_writes_guard_section_when_usage_snapshot_exists
FAIL: test_skill_docs_include_router_fanout_and_output_budget_rules
```

---

### Task 2: 实现 Session Cutover Guard

**Files:**
- Modify: `.claude/scripts/statusline.sh`
- Modify: `.claude/hooks/session-summary.sh`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `statusline.sh` 增加 guard 阈值与状态文案**

```bash
CUTOVER_API_THRESHOLD="${CLAUDE_SOFT_GUARD_API_THRESHOLD:-30}"
CUTOVER_OUTPUT_THRESHOLD="${CLAUDE_SOFT_GUARD_OUTPUT_THRESHOLD:-50000}"
CUTOVER_CACHE_READ_THRESHOLD="${CLAUDE_SOFT_GUARD_CACHE_READ_THRESHOLD:-2000000}"

GUARD_STATUS="OK"
if [ "$CACHE_READ_TOKENS" -ge "$CUTOVER_CACHE_READ_THRESHOLD" ] || [ "$OUTPUT_TOKENS" -ge "$CUTOVER_OUTPUT_THRESHOLD" ]; then
    GUARD_STATUS="CUTOVER"
elif [ "$PERCENT_USED" -ge 50 ]; then
    GUARD_STATUS="WATCH"
fi
```

- [ ] **Step 2: 将 guard 状态写入 statusline 输出，同时落一个 usage snapshot**

```bash
SNAPSHOT_FILE=".claude/tmp/session_usage_snapshot.json"
mkdir -p "$(dirname "$SNAPSHOT_FILE")"
cat > "$SNAPSHOT_FILE" <<EOF
{"api_requests": 0, "output_tokens": $OUTPUT_TOKENS, "cache_read_input_tokens": $CACHE_READ_TOKENS, "continued_session": false, "guard_status": "$GUARD_STATUS"}
EOF

GUARD_DISPLAY="${GRAY}⚠ ${GUARD_STATUS}${RESET}"
echo -e "${MODEL_DISPLAY} ${SEP} ${DIR_DISPLAY}${GIT_DISPLAY} ${SEP} ${TOKEN_DISPLAY}${COST_DISPLAY} ${SEP} ${GUARD_DISPLAY}"
```

- [ ] **Step 3: 在 `session-summary.sh` 读取 snapshot，命中阈值时追加收口建议**

```bash
SNAPSHOT_FILE=".claude/tmp/session_usage_snapshot.json"
echo "" >> "$LOG_FILE"
echo "## Session Guard" >> "$LOG_FILE"
if [ -f "$SNAPSHOT_FILE" ]; then
    GUARD_STATUS=$(jq -r '.guard_status // "OK"' "$SNAPSHOT_FILE")
    if [ "$GUARD_STATUS" = "CUTOVER" ]; then
        echo "- 建议切新 session：当前会话已接近长上下文泥潭。" >> "$LOG_FILE"
        echo "- 原因：输出 token 或 cache read token 超过默认阈值。" >> "$LOG_FILE"
    else
        echo "- 当前无需切换 session。" >> "$LOG_FILE"
    fi
else
    echo "- 未检测到 usage snapshot，跳过 session guard 收口建议。" >> "$LOG_FILE"
fi
```

- [ ] **Step 4: 重新运行目标测试，确认转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_statusline_shows_cutover_warning_when_usage_crosses_threshold -v
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_writes_guard_section_when_usage_snapshot_exists -v
```

Expected:

```text
OK
```

---

### Task 3: 实现 Task-Class Router 与 Fan-out Budget Guard

**Files:**
- Modify: `.claude/skills/using-superpowers/SKILL.md`
- Modify: `.claude/skills/dispatching-parallel-agents/SKILL.md`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `using-superpowers` 增加任务分类与模型档位建议章节**

```md
## Task-Class Router

- 轻任务：文档润色、changelog、commit message、测试步骤整理、简单 UI 建议
- 中任务：普通 bugfix、小范围实现、单模块调试
- 重任务：架构设计、大范围重构、多源研究、长上下文续接

Routing guidance:
- 轻任务优先轻量模型或短会话
- 中任务默认中等模型
- 重任务才进入重模型主链路
```

- [ ] **Step 2: 在 `dispatching-parallel-agents` 增加 fan-out 前预算检查章节**

```md
## Budget Check Before Fan-out

- 并行前先判断任务是否真的独立，而不是默认 fan-out
- 研究/分析/高不确定性任务优先分段执行
- 子任务失败后只重试最小子段，禁止把完整背景原样重发
- 如果已经出现长会话续接或上下文膨胀，优先收口而不是继续并行
```

- [ ] **Step 3: 运行 skill 文本测试，确认转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_skill_docs_include_router_fanout_and_output_budget_rules -v
```

Expected:

```text
OK
```

---

### Task 4: 实现 Output Budget Templates

**Files:**
- Modify: `.claude/skills/verification-before-completion/SKILL.md`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `verification-before-completion` 增加 Output Budget 小节**

```md
## Output Budget

- 测试步骤：最多 8 步
- UI 建议：最多 5 条
- changelog：最多 100 字
- 调试结论固定四段：问题 / 原因 / 修复 / 验证

Do not compress:
- exit code
- failing test names
- command evidence
```

- [ ] **Step 2: 扩展测试断言，检查 Output Budget 文本落点**

```python
self.assertIn("Output Budget", verify)
self.assertIn("测试步骤：最多 8 步", verify)
self.assertIn("问题 / 原因 / 修复 / 验证", verify)
```

- [ ] **Step 3: 运行单测，确认全部 soft guard 用例转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
Ran 3 tests
OK
```

---

### Task 5: 生成验证文档并跑全量校验

**Files:**
- Create: `docs/reports/2026-05-14-soft-token-guards-validation.md`
- Modify: `docs/reports/2026-05-14-token-optimization-summary.md`
- Verify: `docs/superpowers/specs/2026-05-14-soft-token-guards-design.md`

- [ ] **Step 1: 写验证文档，记录 guard 行为、命中条件与手工验证结果**

```md
# Soft Token Guards Validation

## Session Cutover Guard
- 输入：高 cache read / 高 output token 的 statusline payload
- 结果：statusline 显示 WATCH 或 CUTOVER

## Fan-out Budget Guard
- 检查 `dispatching-parallel-agents` 新增预算检查规则

## Output Budget
- 检查 `verification-before-completion` 新增模板
```

- [ ] **Step 2: 在总总结文档补一个 “Soft Guards” 章节，链接设计文档和验证文档**

```md
## Soft Guards

- Design: `docs/superpowers/specs/2026-05-14-soft-token-guards-design.md`
- Validation: `docs/reports/2026-05-14-soft-token-guards-validation.md`
```

- [ ] **Step 3: 跑全量验证**

Run:

```bash
make test
make lint-skills
make check
```

Expected:

```text
All commands exit 0 with no new failures
```

- [ ] **Step 4: 记录最终证据块，并检查目标 diff**

Run:

```bash
git diff -- .claude/scripts/statusline.sh .claude/hooks/session-summary.sh .claude/skills/using-superpowers/SKILL.md .claude/skills/dispatching-parallel-agents/SKILL.md .claude/skills/verification-before-completion/SKILL.md tests/test_soft_token_guards.py docs/reports/2026-05-14-soft-token-guards-validation.md docs/reports/2026-05-14-token-optimization-summary.md
```

Expected:

```text
Only soft guard related changes are present
```

---

## Self-Review

- Spec coverage:
  - `Session Cutover Guard` -> Task 2
  - `Fan-out Budget Guard` -> Task 3
  - `Task-Class Router` -> Task 3
  - `Output Budget Templates` -> Task 4
  - 验收与文档 -> Task 5
- Placeholder scan:
  - 无 `TBD` / `TODO` / “适当处理” 类占位语
- Type consistency:
  - `CUTOVER` / `WATCH` / `OK` 作为 guard 状态常量在计划中保持一致
