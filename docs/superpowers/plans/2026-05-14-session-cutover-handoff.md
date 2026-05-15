# Session Cutover Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `CUTOVER` 状态增加可直接承接的新会话 handoff 文档，降低长会话切换成本，同时保持软治理边界。

**Architecture:** 继续复用现有 `statusline.sh -> session_usage_snapshot.json -> session-summary.sh` 链路，不新增后台服务或独立摘要器。`statusline.sh` 继续负责阈值判断与 snapshot 输出，`session-summary.sh` 在命中 `CUTOVER` 时生成 `.claude/tmp/session_cutover.md`，测试用 `unittest + subprocess` 锁定触发条件、文档结构和非 Git 目录回退行为。

**Tech Stack:** Bash, Python 3.10+, `unittest`, `json`, `subprocess`, Markdown reports

---

## File Map

**Modify**
- `.claude/hooks/session-summary.sh`
- `.claude/scripts/statusline.sh`
- `tests/test_soft_token_guards.py`
- `docs/reports/2026-05-14-soft-token-guards-validation.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

**Create**
- `docs/reports/2026-05-14-session-cutover-handoff-validation.md`

**Verify**
- `docs/superpowers/specs/2026-05-14-session-cutover-handoff-design.md`

---

### Task 1: 先写红灯测试，锁定 cutover handoff 行为

**Files:**
- Modify: `tests/test_soft_token_guards.py`
- Verify: `.claude/hooks/session-summary.sh`
- Verify: `.claude/scripts/statusline.sh`

- [ ] **Step 1: 为 `CUTOVER` 场景新增失败测试，要求生成 `session_cutover.md`**

```python
    def test_session_summary_writes_cutover_handoff_when_guard_status_is_cutover(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps(
                    {
                        "api_requests": 42,
                        "output_tokens": 88000,
                        "cache_read_input_tokens": 3100000,
                        "continued_session": True,
                        "guard_status": "CUTOVER",
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

            handoff = (repo / ".claude/tmp/session_cutover.md").read_text(encoding="utf-8")

        self.assertEqual(0, result.returncode)
        self.assertIn("Current Task", handoff)
        self.assertIn("What Changed", handoff)
        self.assertIn("Open Issues", handoff)
        self.assertIn("Suggested Next Prompt", handoff)
        self.assertIn("Why Cutover", handoff)
```

- [ ] **Step 2: 为 `WATCH` 场景新增失败测试，要求不生成 handoff**

```python
    def test_session_summary_does_not_write_cutover_handoff_for_watch_status(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps(
                    {
                        "api_requests": 12,
                        "output_tokens": 1000,
                        "cache_read_input_tokens": 90000,
                        "continued_session": False,
                        "guard_status": "WATCH",
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

        self.assertEqual(0, result.returncode)
        self.assertFalse((repo / ".claude/tmp/session_cutover.md").exists())
```

- [ ] **Step 3: 为 `statusline.sh` snapshot 新增失败测试，确保继续输出 cutover 所需字段**

```python
    def test_statusline_snapshot_keeps_cutover_fields_for_handoff(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            (repo / ".claude/tmp").mkdir(parents=True)
            payload = {
                "model": {"display_name": "Claude"},
                "workspace": {"current_dir": str(repo)},
                "session": {"api_requests": 31},
                "context_window": {
                    "context_window_size": 200000,
                    "current_usage": {
                        "input_tokens": 25000,
                        "cache_creation_input_tokens": 10000,
                        "cache_read_input_tokens": 2100000,
                        "output_tokens": 51000,
                    },
                },
            }
            result = subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/scripts/statusline.sh")],
                cwd=repo,
                input=json.dumps(payload),
                text=True,
                capture_output=True,
                check=False,
            )
            snapshot = json.loads(
                (repo / ".claude/tmp/session_usage_snapshot.json").read_text(encoding="utf-8")
            )

        self.assertEqual(0, result.returncode)
        self.assertEqual("CUTOVER", snapshot["guard_status"])
        self.assertEqual(31, snapshot["api_requests"])
        self.assertEqual(51000, snapshot["output_tokens"])
        self.assertEqual(2100000, snapshot["cache_read_input_tokens"])
```

- [ ] **Step 4: 运行新增测试，确认红灯**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
FAIL: test_session_summary_writes_cutover_handoff_when_guard_status_is_cutover
FAIL: test_session_summary_does_not_write_cutover_handoff_for_watch_status
```

---

### Task 2: 实现 cutover handoff 的最小生成逻辑

**Files:**
- Modify: `.claude/hooks/session-summary.sh`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `session-summary.sh` 中增加 cutover handoff 输出路径与清理逻辑**

```bash
CUTOVER_FILE=".claude/tmp/session_cutover.md"
rm -f "$CUTOVER_FILE"
```

- [ ] **Step 2: 在 `CUTOVER` 分支中生成固定结构的 handoff 文档**

```bash
cat > "$CUTOVER_FILE" <<EOF
# Session Cutover Handoff

## Current Task
- 需要人工补充

## What Changed
- See session_summary.md for recent git activity and modified files.

## Open Issues
- 需要人工补充当前未完成事项

## Suggested Next Prompt
继续处理当前任务。先阅读 session_cutover.md，然后：
1. 确认 Current Task 是否准确
2. 优先处理 Open Issues 的第一项
3. 保持修改范围最小，完成后运行对应验证

## Why Cutover
- API requests: $API_REQUESTS
- Output tokens: $OUTPUT_TOKENS
- Cache read tokens: $CACHE_READ_TOKENS
- Continued session: $CONTINUED_SESSION
EOF
```

- [ ] **Step 3: 为非 `CUTOVER` 状态保留“不生成 handoff”行为**

```bash
if [ "$GUARD_STATUS" = "CUTOVER" ]; then
    # write cutover file
else
    rm -f "$CUTOVER_FILE"
fi
```

- [ ] **Step 4: 运行定向测试，确认 cutover / watch 两个场景转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_writes_cutover_handoff_when_guard_status_is_cutover -v
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_does_not_write_cutover_handoff_for_watch_status -v
```

Expected:

```text
OK
```

---

### Task 3: 收紧 snapshot 与 summary 内容，避免 handoff 失真

**Files:**
- Modify: `.claude/scripts/statusline.sh`
- Modify: `.claude/hooks/session-summary.sh`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `statusline.sh` 中补全 snapshot 字段与工作目录隔离**

```bash
SNAPSHOT_DIR=".claude/tmp"
mkdir -p "$SNAPSHOT_DIR"
cat > "$SNAPSHOT_DIR/session_usage_snapshot.json" <<EOF
{"api_requests": $API_REQUESTS, "output_tokens": $OUTPUT_TOKENS, "cache_read_input_tokens": $CACHE_READ_TOKENS, "continued_session": false, "guard_status": "$GUARD_STATUS"}
EOF
```

- [ ] **Step 2: 在 `session-summary.sh` 中把 handoff 的 `What Changed` 做成短块**

```bash
RECENT_COMMIT=$(git log --since="1 hour ago" --oneline --no-merges 2>/dev/null | head -n 1)
if [ -n "$RECENT_COMMIT" ]; then
    WHAT_CHANGED_LINE="- Recent commit: $RECENT_COMMIT"
else
    WHAT_CHANGED_LINE="- No recent commit detected."
fi
```

- [ ] **Step 3: 在 handoff 中保留保守文案，避免虚构任务结论**

```bash
echo "## Current Task" >> "$CUTOVER_FILE"
echo "- 需要人工补充" >> "$CUTOVER_FILE"
echo "" >> "$CUTOVER_FILE"
echo "## Open Issues" >> "$CUTOVER_FILE"
echo "- 需要人工补充当前未完成事项" >> "$CUTOVER_FILE"
```

- [ ] **Step 4: 运行 snapshot 定向测试和整组测试，确认转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_statusline_snapshot_keeps_cutover_fields_for_handoff -v
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
Ran 6 tests
OK
```

---

### Task 4: 补验证报告并更新总总结入口

**Files:**
- Create: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- Modify: `docs/reports/2026-05-14-soft-token-guards-validation.md`
- Modify: `docs/reports/2026-05-14-token-optimization-summary.md`

- [ ] **Step 1: 写第二轮验证报告，记录 trigger、handoff 结构与手工验证**

```md
# Session Cutover Handoff Validation

## Trigger
- guard_status = CUTOVER

## Generated Files
- `.claude/tmp/session_summary.md`
- `.claude/tmp/session_cutover.md`

## Handoff Structure
- Current Task
- What Changed
- Open Issues
- Suggested Next Prompt
- Why Cutover
```

- [ ] **Step 2: 在第一轮验证报告中追加第二轮说明**

```md
## Round 2: Session Cutover Handoff

- `CUTOVER` 命中后新增 `session_cutover.md`
- 该文档只做短承接，不做自动切换
```

- [ ] **Step 3: 在总总结文档中补第二轮链接**

```md
## Session Cutover Handoff

- Design: `docs/superpowers/specs/2026-05-14-session-cutover-handoff-design.md`
- Validation: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
```

- [ ] **Step 4: 运行文档相关检查**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
OK
```

---

### Task 5: 跑全量校验并收尾

**Files:**
- Verify: `.claude/hooks/session-summary.sh`
- Verify: `.claude/scripts/statusline.sh`
- Verify: `tests/test_soft_token_guards.py`
- Verify: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`

- [ ] **Step 1: 跑全量验证**

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

- [ ] **Step 2: 审核目标 diff**

Run:

```bash
git diff -- .claude/hooks/session-summary.sh .claude/scripts/statusline.sh tests/test_soft_token_guards.py docs/reports/2026-05-14-session-cutover-handoff-validation.md docs/reports/2026-05-14-soft-token-guards-validation.md docs/reports/2026-05-14-token-optimization-summary.md
```

Expected:

```text
Only session cutover handoff related changes are present
```

- [ ] **Step 3: 记录 handoff 的已知限制**

```text
- Current Task 和 Open Issues 第一版可能退化为“需要人工补充”
- 第二轮不自动创建新 session，也不自动注入下一会话 prompt
- handoff 只保留最近一次 CUTOVER 输出
```

---

## Self-Review

- Spec coverage:
  - `CUTOVER 触发 handoff` -> Task 1 / Task 2
  - `保守模板与不虚构` -> Task 3
  - `验证与文档` -> Task 4 / Task 5
- Placeholder scan:
  - 无 `TBD` / `TODO` / “后续再补” 类占位语
- Type consistency:
  - `session_cutover.md`、`CUTOVER`、`WATCH`、`session_usage_snapshot.json` 在所有任务中名称一致
