# Task1 Session Token Observer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 `session-eval.sh` 的导出结果新增一个可测试的 Python CLI，输出场景台账、按 `input_tokens`/`output_tokens`/`调用频次` 的三维排序，以及每个维度的 Top3。

**Architecture:** 新 CLI 读取 `api_requests.jsonl` 作为唯一必需输入，并把每条 assistant usage 记录视为一个“调用场景”。内部拆成“读取与校验”“场景聚合”“排行与 Top3”“终端渲染”四个小单元，保持脚本可直接运行，同时把核心逻辑暴露为纯函数以便 `unittest` 覆盖。

**Tech Stack:** Python 3.10+, `argparse`, `json`, `pathlib`, `unittest`, `tempfile`

---

### Task 1: 建测试骨架并锁定 CLI 行为

**Files:**
- Create: `tests/test_session_token_observer.py`
- Create: `scripts/session_token_observer.py`

- [ ] **Step 1: 写失败测试**

```python
import json
import tempfile
import unittest
from pathlib import Path

from scripts.session_token_observer import build_report


class SessionTokenObserverTests(unittest.TestCase):
    def test_build_report_groups_rows_and_sorts_dimensions(self):
        with tempfile.TemporaryDirectory() as tmp:
            out_dir = Path(tmp)
            rows = [
                {"session_id": "s1", "message_id": "m1", "input_tokens": 120, "output_tokens": 30},
                {"session_id": "s1", "message_id": "m2", "input_tokens": 30, "output_tokens": 80},
                {"session_id": "s2", "message_id": "m3", "input_tokens": 90, "output_tokens": 20},
                {"session_id": "s2", "message_id": "m4", "input_tokens": 10, "output_tokens": 10},
                {"session_id": "s2", "message_id": "m5", "input_tokens": 5, "output_tokens": 5},
            ]
            path = out_dir / "api_requests.jsonl"
            path.write_text("".join(json.dumps(row) + "\n" for row in rows), encoding="utf-8")

            report = build_report(out_dir)

            self.assertEqual(2, len(report["ledger"]))
            self.assertEqual("s2", report["rankings"]["by_frequency"][0]["scenario"])
            self.assertEqual("s1", report["rankings"]["by_input_tokens"][0]["scenario"])
            self.assertEqual("s1", report["rankings"]["by_output_tokens"][0]["scenario"])
```

- [ ] **Step 2: 跑单测确认失败**

Run: `python3 -m unittest tests.test_session_token_observer -v`
Expected: FAIL with `ModuleNotFoundError` or missing `build_report`

- [ ] **Step 3: 写最小实现让测试转绿**

```python
def build_report(eval_dir):
    ...
```

- [ ] **Step 4: 跑单测确认通过**

Run: `python3 -m unittest tests.test_session_token_observer -v`
Expected: PASS

- [ ] **Step 5: 提交本任务**

```bash
git add scripts/session_token_observer.py tests/test_session_token_observer.py
git commit -m "feat: add session token observer cli"
```

### Task 2: 补 CLI 文本输出与 Top3 回归测试

**Files:**
- Modify: `scripts/session_token_observer.py`
- Modify: `tests/test_session_token_observer.py`

- [ ] **Step 1: 写失败测试覆盖 CLI 输出**

```python
from contextlib import redirect_stdout
from io import StringIO

from scripts.session_token_observer import main


    def test_cli_prints_ledger_rankings_and_top3(self):
        buffer = StringIO()
        with redirect_stdout(buffer):
            exit_code = main([str(out_dir)])
        output = buffer.getvalue()
        self.assertEqual(0, exit_code)
        self.assertIn("场景台账", output)
        self.assertIn("按 input_tokens 排序", output)
        self.assertIn("Top3", output)
```

- [ ] **Step 2: 跑单测确认失败**

Run: `python3 -m unittest tests.test_session_token_observer -v`
Expected: FAIL because `main()` output format is incomplete

- [ ] **Step 3: 实现 CLI 参数解析和文本渲染**

```python
def main(argv=None):
    parser = argparse.ArgumentParser(...)
    parser.add_argument("eval_dir")
    ...
```

- [ ] **Step 4: 跑单测确认通过**

Run: `python3 -m unittest tests.test_session_token_observer -v`
Expected: PASS

- [ ] **Step 5: 提交本任务**

```bash
git add scripts/session_token_observer.py tests/test_session_token_observer.py
git commit -m "test: cover session token observer cli output"
```

### Task 3: 做全量验证并补手册

**Files:**
- Modify: `docs/setup/skill-telemetry-setup.md`
- Verify: `Makefile`

- [ ] **Step 1: 补充使用说明**

```md
python3 scripts/session_token_observer.py /tmp/eval/20260319
```

- [ ] **Step 2: 跑项目验证命令**

Run: `make test`
Expected: PASS with discovered tests

Run: `make lint-skills`
Expected: PASS

Run: `make check`
Expected: PASS

- [ ] **Step 3: 检查改动与交付信息**

Run: `git diff -- scripts/session_token_observer.py tests/test_session_token_observer.py docs/setup/skill-telemetry-setup.md`
Expected: only Task1 related changes

- [ ] **Step 4: 提交本任务**

```bash
git add docs/setup/skill-telemetry-setup.md
git commit -m "docs: add session token observer usage"
```
