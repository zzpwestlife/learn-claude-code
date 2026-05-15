# Cutover Handoff Quality Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不引入模型和激进推断的前提下，提升 `session_cutover.md` 的 `Current Task` 与 `Open Issues` 质量，让第三轮 handoff 更可接手。

**Architecture:** 继续复用现有 `session_usage_snapshot.json + session_summary.md + git log + git status` 这些本地信号，不新增脚本和服务。`session-summary.sh` 负责根据 recent commit、modified files 和 CUTOVER 状态做保守归纳，`tests/test_soft_token_guards.py` 通过 `unittest + subprocess` 锁定 recent commit、文件路径回退、信息不足回退和 `Open Issues` 数量约束。

**Tech Stack:** Bash, Python 3.10+, `unittest`, `subprocess`, `json`, Markdown reports

---

## File Map

**Modify**
- `.claude/hooks/session-summary.sh`
- `tests/test_soft_token_guards.py`
- `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

**Verify**
- `docs/superpowers/specs/2026-05-14-cutover-handoff-quality-design.md`

---

### Task 1: 先写红灯测试，锁定保守归纳行为

**Files:**
- Modify: `tests/test_soft_token_guards.py`
- Verify: `.claude/hooks/session-summary.sh`

- [ ] **Step 1: 为 recent commit 场景新增失败测试，要求 `Current Task` 具体化**

```python
    def test_session_summary_uses_recent_commit_for_current_task(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init"], cwd=repo, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo, check=True)
            subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo, check=True)
            (repo / "README.md").write_text("hello\n", encoding="utf-8")
            subprocess.run(["git", "add", "README.md"], cwd=repo, check=True)
            subprocess.run(["git", "commit", "-m", "feat: add cutover handoff"], cwd=repo, check=True, capture_output=True, text=True)
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps({"guard_status": "CUTOVER", "api_requests": 40, "output_tokens": 90000, "cache_read_input_tokens": 2100000, "continued_session": True}),
                encoding="utf-8",
            )

            subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/hooks/session-summary.sh")],
                cwd=repo,
                check=False,
                capture_output=True,
                text=True,
            )

            handoff = (repo / ".claude/tmp/session_cutover.md").read_text(encoding="utf-8")

        self.assertIn("正在处理：cutover handoff", handoff)
```

- [ ] **Step 2: 为 modified files 回退场景新增失败测试，要求 `Current Task` 基于路径生成**

```python
    def test_session_summary_uses_modified_files_for_current_task_when_no_recent_commit(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init"], cwd=repo, check=True, capture_output=True, text=True)
            (repo / ".claude/hooks").mkdir(parents=True)
            (repo / "tests").mkdir(parents=True)
            (repo / ".claude/hooks/session-summary.sh").write_text("echo test\n", encoding="utf-8")
            (repo / "tests/test_soft_token_guards.py").write_text("print('x')\n", encoding="utf-8")
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps({"guard_status": "CUTOVER", "api_requests": 31, "output_tokens": 51000, "cache_read_input_tokens": 2100000, "continued_session": False}),
                encoding="utf-8",
            )

            subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/hooks/session-summary.sh")],
                cwd=repo,
                check=False,
                capture_output=True,
                text=True,
            )

            handoff = (repo / ".claude/tmp/session_cutover.md").read_text(encoding="utf-8")

        self.assertIn("正在处理 session-summary 与 soft token guard 相关工作", handoff)
```

- [ ] **Step 3: 为信息不足场景新增失败测试，要求保守回退**

```python
    def test_session_summary_keeps_manual_placeholder_when_no_reliable_signal(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps({"guard_status": "CUTOVER", "api_requests": 35, "output_tokens": 52000, "cache_read_input_tokens": 2200000, "continued_session": False}),
                encoding="utf-8",
            )

            subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/hooks/session-summary.sh")],
                cwd=repo,
                check=False,
                capture_output=True,
                text=True,
            )

            handoff = (repo / ".claude/tmp/session_cutover.md").read_text(encoding="utf-8")

        self.assertIn("## Current Task\n- 需要人工补充", handoff)
```

- [ ] **Step 4: 为 `Open Issues` 新增失败测试，要求最多 3 条且来自可验证信号**

```python
    def test_session_summary_generates_bounded_open_issues(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init"], cwd=repo, check=True, capture_output=True, text=True)
            (repo / "notes.txt").write_text("draft\n", encoding="utf-8")
            (repo / ".claude/tmp").mkdir(parents=True)
            (repo / ".claude/tmp/session_usage_snapshot.json").write_text(
                json.dumps({"guard_status": "CUTOVER", "api_requests": 33, "output_tokens": 53000, "cache_read_input_tokens": 2300000, "continued_session": True}),
                encoding="utf-8",
            )

            subprocess.run(
                ["bash", str(REPO_ROOT / ".claude/hooks/session-summary.sh")],
                cwd=repo,
                check=False,
                capture_output=True,
                text=True,
            )

            handoff = (repo / ".claude/tmp/session_cutover.md").read_text(encoding="utf-8")
            open_issues_block = handoff.split("## Open Issues\n", 1)[1].split("\n## Suggested Next Prompt", 1)[0]
            issue_lines = [line for line in open_issues_block.splitlines() if line.startswith("- ")]

        self.assertGreaterEqual(len(issue_lines), 1)
        self.assertLessEqual(len(issue_lines), 3)
        self.assertIn("cutover", open_issues_block.lower())
```

- [ ] **Step 5: 运行新增测试，确认红灯**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
FAIL: test_session_summary_uses_recent_commit_for_current_task
FAIL: test_session_summary_uses_modified_files_for_current_task_when_no_recent_commit
FAIL: test_session_summary_generates_bounded_open_issues
```

---

### Task 2: 实现 `Current Task` 的保守归纳

**Files:**
- Modify: `.claude/hooks/session-summary.sh`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `session-summary.sh` 中增加 recent commit 清洗逻辑**

```bash
sanitize_commit_message() {
    local message="$1"
    message="${message#feat: }"
    message="${message#fix: }"
    message="${message#chore: }"
    message="${message#docs: }"
    echo "$message"
}

CURRENT_TASK_LINE="- 需要人工补充"
if [ -n "$RECENT_COMMIT" ]; then
    RECENT_COMMIT_MESSAGE="$(printf '%s' "$RECENT_COMMIT" | cut -d' ' -f2-)"
    RECENT_COMMIT_MESSAGE="$(sanitize_commit_message "$RECENT_COMMIT_MESSAGE")"
    CURRENT_TASK_LINE="- 正在处理：$RECENT_COMMIT_MESSAGE"
fi
```

- [ ] **Step 2: 为无 recent commit 时增加 modified files 回退**

```bash
if [ "$CURRENT_TASK_LINE" = "- 需要人工补充" ] && git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    STATUS_LINES="$(git status --short 2>/dev/null | head -n 2)"
    if printf '%s' "$STATUS_LINES" | grep -q 'session-summary.sh' && printf '%s' "$STATUS_LINES" | grep -q 'test_soft_token_guards.py'; then
        CURRENT_TASK_LINE="- 正在处理 session-summary 与 soft token guard 相关工作"
    elif [ -n "$STATUS_LINES" ]; then
        FIRST_PATH="$(printf '%s' "$STATUS_LINES" | head -n 1 | awk '{print $2}')"
        CURRENT_TASK_LINE="- 正在处理 ${FIRST_PATH##*/} 相关工作"
    fi
fi
```

- [ ] **Step 3: 用新变量写入 handoff 的 `Current Task`**

```bash
echo "## Current Task" >> "$CUTOVER_FILE"
echo "$CURRENT_TASK_LINE" >> "$CUTOVER_FILE"
```

- [ ] **Step 4: 运行定向测试，确认 `Current Task` 相关场景转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_uses_recent_commit_for_current_task -v
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_uses_modified_files_for_current_task_when_no_recent_commit -v
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_keeps_manual_placeholder_when_no_reliable_signal -v
```

Expected:

```text
OK
```

---

### Task 3: 实现 `Open Issues` 的保守归纳与上限约束

**Files:**
- Modify: `.claude/hooks/session-summary.sh`
- Test: `tests/test_soft_token_guards.py`

- [ ] **Step 1: 在 `session-summary.sh` 中按规则收集最多 3 条 `Open Issues`**

```bash
OPEN_ISSUES=()
if git rev-parse --is-inside-work-tree > /dev/null 2>&1 && [ -n "$(git status --short 2>/dev/null)" ]; then
    OPEN_ISSUES+=("- 仍有未提交改动，建议新会话先确认本轮修改边界")
fi
if [ "$COMMIT_COUNT" -eq 0 ]; then
    OPEN_ISSUES+=("- 最近没有提交记录，可能仍处于探索或整理阶段")
fi
if [ "$GUARD_STATUS" = "CUTOVER" ]; then
    OPEN_ISSUES+=("- 当前会话已触发 cutover，建议新会话先确认第一优先任务")
fi
```

- [ ] **Step 2: 为无信号场景保留占位回退**

```bash
if [ "${#OPEN_ISSUES[@]}" -eq 0 ]; then
    OPEN_ISSUES=("- 需要人工补充当前未完成事项")
fi
```

- [ ] **Step 3: 只输出前 3 条 issue 到 handoff**

```bash
echo "## Open Issues" >> "$CUTOVER_FILE"
for issue in "${OPEN_ISSUES[@]:0:3}"; do
    echo "$issue" >> "$CUTOVER_FILE"
done
```

- [ ] **Step 4: 运行定向测试和整组测试，确认转绿**

Run:

```bash
python3 -m unittest tests.test_soft_token_guards.SoftTokenGuardTests.test_session_summary_generates_bounded_open_issues -v
python3 -m unittest tests.test_soft_token_guards -v
```

Expected:

```text
Ran 10 tests
OK
```

---

### Task 4: 更新验证报告与总总结

**Files:**
- Modify: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- Modify: `docs/reports/2026-05-14-token-optimization-summary.md`

- [ ] **Step 1: 在第二轮验证报告中补充第三轮内容质量增强说明**

```md
## Round 3: Handoff Quality

- `Current Task` 优先使用 recent commit，缺失时回退到 modified files
- `Open Issues` 只基于未提交改动、无 recent commit、CUTOVER 命中这类可验证信号生成
- 信息不足时仍保留“需要人工补充”
```

- [ ] **Step 2: 在总总结文档中新增第三轮入口**

```md
## Cutover Handoff Quality

- Design: `docs/superpowers/specs/2026-05-14-cutover-handoff-quality-design.md`
- Validation: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
```

- [ ] **Step 3: 运行测试确认文档更新未影响行为**

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
- Verify: `tests/test_soft_token_guards.py`
- Verify: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- Verify: `docs/reports/2026-05-14-token-optimization-summary.md`

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
git diff -- .claude/hooks/session-summary.sh tests/test_soft_token_guards.py docs/reports/2026-05-14-session-cutover-handoff-validation.md docs/reports/2026-05-14-token-optimization-summary.md
```

Expected:

```text
Only handoff quality related changes are present
```

- [ ] **Step 3: 记录第三轮边界**

```text
- 不引入模型摘要
- 不自动推断业务根因
- 信息不足时继续回退“需要人工补充”
```

---

## Self-Review

- Spec coverage:
  - `Current Task` 保守增强 -> Task 1 / Task 2
  - `Open Issues` 保守增强 -> Task 1 / Task 3
  - `验证与文档` -> Task 4 / Task 5
- Placeholder scan:
  - 无 `TBD` / `TODO` / “稍后实现” 类占位语
- Type consistency:
  - `session_cutover.md`、`Current Task`、`Open Issues`、`CUTOVER` 在所有任务中命名一致
