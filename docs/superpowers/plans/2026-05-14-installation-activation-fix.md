# Installation Activation Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复安装到其他项目后 `statusline -> snapshot -> session-summary -> session_cutover` 默认不生效的问题, 让目标项目在安装完成后自动接通必需运行时入口。

**Architecture:** 保留现有 `install.sh` 的目录复制主流程, 但把 `.claude/settings.json` 从通用冲突合并路径中剥离。新增一个专用 Python 补丁脚本: 目标项目无 settings 时以仓库模板为基底落盘, 有 settings 时只对 `statusLine`、`hooks.SessionEnd`、`hooks.PreToolUse matcher=Bash` 做最小结构化补丁, 并通过 `stderr` 输出冲突提示而不是覆盖用户自定义配置。验证分成两层: 先用 `unittest` 锁定补丁脚本的结构化合并行为, 再用临时目标目录跑 installer 集成测试确认真实安装链路生效。

**Tech Stack:** Bash, Python 3.10+, `json`, `pathlib`, `tempfile`, `subprocess`, `unittest`, Markdown reports

---

## File Map

**Create**
- `scripts/installers/patch_claude_settings.py`
- `tests/test_installation_activation.py`
- `docs/reports/2026-05-14-installation-activation-fix-validation.md`

**Modify**
- `scripts/installers/install.sh`
- `docs/reports/2026-05-14-token-optimization-summary.md`

**Reference**
- `docs/superpowers/specs/2026-05-14-installation-activation-fix-design.md`
- `.claude/settings.json`

---

### Task 1: 先写红灯测试, 锁定 settings 结构化补丁边界

**Files:**
- Create: `tests/test_installation_activation.py`
- Verify: `.claude/settings.json`
- Verify: `scripts/installers/install.sh`

- [ ] **Step 1: 建立 BDD 状态文件, 明确依赖顺序**

```md
# INPUT: installation activation fix approved design
# OUTPUT: task state for red-green execution
# POS: .local.md

## Current Goal
- Make installer auto-enable statusline, SessionEnd summary hook, and PreToolUse Bash RTK hook.

## Dependencies
- Task 1 red tests before helper implementation
- Task 2 helper implementation before installer wiring
- Task 3 installer wiring before integration tests

## Verification Targets
- python3 -m unittest tests.test_installation_activation -v
- make test
- make lint-skills
- make check
```

- [ ] **Step 2: 为缺失目标 settings 的场景新增失败测试, 要求从源模板初始化并补齐必需入口**

```python
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
PATCH_SCRIPT = REPO_ROOT / "scripts/installers/patch_claude_settings.py"
SOURCE_SETTINGS = REPO_ROOT / ".claude/settings.json"

class InstallationActivationTests(unittest.TestCase):
    def test_patch_script_seeds_missing_target_settings_from_source_template(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / ".claude/settings.json"
            result = subprocess.run(
                ["python3", str(PATCH_SCRIPT), str(SOURCE_SETTINGS), str(target)],
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads(target.read_text(encoding="utf-8"))

        self.assertEqual(0, result.returncode)
        self.assertEqual(".claude/scripts/statusline.sh", settings["statusLine"]["command"])
        self.assertEqual("plan", settings["permissions"]["defaultMode"])
        session_end = settings["hooks"]["SessionEnd"][0]["hooks"]
        self.assertIn(
            {"type": "command", "command": ".claude/hooks/session-summary.sh"},
            session_end,
        )
```

- [ ] **Step 3: 为已有 `matcher=Bash` 的场景新增失败测试, 要求只追加 RTK hook 而不覆盖已有 hooks**

```python
    def test_patch_script_appends_rtk_hook_to_existing_bash_matcher(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / ".claude/settings.json"
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(
                json.dumps(
                    {
                        "hooks": {
                            "PreToolUse": [
                                {
                                    "matcher": "Bash",
                                    "hooks": [
                                        {"type": "command", "command": ".claude/hooks/custom-pretool.sh"}
                                    ],
                                }
                            ]
                        }
                    }
                ),
                encoding="utf-8",
            )

            result = subprocess.run(
                ["python3", str(PATCH_SCRIPT), str(SOURCE_SETTINGS), str(target)],
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads(target.read_text(encoding="utf-8"))
            bash_entry = settings["hooks"]["PreToolUse"][0]["hooks"]

        self.assertEqual(0, result.returncode)
        self.assertIn({"type": "command", "command": ".claude/hooks/custom-pretool.sh"}, bash_entry)
        self.assertIn({"type": "command", "command": ".claude/hooks/rtk-rewrite.sh"}, bash_entry)
        self.assertEqual(2, len(bash_entry))
```

- [ ] **Step 4: 为已有 `statusLine` 的场景新增失败测试, 要求保留原值并输出冲突提示**

```python
    def test_patch_script_preserves_existing_statusline_and_reports_conflict(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / ".claude/settings.json"
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(
                json.dumps({"statusLine": {"command": ".claude/scripts/custom-statusline.sh"}}),
                encoding="utf-8",
            )

            result = subprocess.run(
                ["python3", str(PATCH_SCRIPT), str(SOURCE_SETTINGS), str(target)],
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads(target.read_text(encoding="utf-8"))

        self.assertEqual(0, result.returncode)
        self.assertEqual(".claude/scripts/custom-statusline.sh", settings["statusLine"]["command"])
        self.assertIn("statusLine already exists", result.stderr)
```

- [ ] **Step 5: 为重复 hook 场景新增失败测试, 要求补丁脚本幂等**

```python
    def test_patch_script_does_not_duplicate_existing_required_hooks(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / ".claude/settings.json"
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(
                SOURCE_SETTINGS.read_text(encoding="utf-8"),
                encoding="utf-8",
            )

            first = subprocess.run(
                ["python3", str(PATCH_SCRIPT), str(SOURCE_SETTINGS), str(target)],
                text=True,
                capture_output=True,
                check=False,
            )
            second = subprocess.run(
                ["python3", str(PATCH_SCRIPT), str(SOURCE_SETTINGS), str(target)],
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads(target.read_text(encoding="utf-8"))
            bash_hooks = settings["hooks"]["PreToolUse"][0]["hooks"]
            session_end_hooks = settings["hooks"]["SessionEnd"][0]["hooks"]

        self.assertEqual(0, first.returncode)
        self.assertEqual(0, second.returncode)
        self.assertEqual(1, bash_hooks.count({"type": "command", "command": ".claude/hooks/rtk-rewrite.sh"}))
        self.assertEqual(1, session_end_hooks.count({"type": "command", "command": ".claude/hooks/session-summary.sh"}))
```

- [ ] **Step 6: 运行定向测试, 确认红灯**

Run:

```bash
python3 -m unittest tests.test_installation_activation -v
```

Expected:

```text
ERROR: tests.test_installation_activation
```

---

### Task 2: 实现 Claude settings 专用补丁脚本

**Files:**
- Create: `scripts/installers/patch_claude_settings.py`
- Test: `tests/test_installation_activation.py`

- [ ] **Step 1: 创建补丁脚本骨架, 保持单文件小而专注**

```python
# INPUT: source settings path, target settings path
# OUTPUT: patched target settings file and concise diagnostics
# POS: scripts/installers/patch_claude_settings.py

from __future__ import annotations

import json
import sys
from pathlib import Path

STATUSLINE_COMMAND = ".claude/scripts/statusline.sh"
SESSION_SUMMARY_COMMAND = ".claude/hooks/session-summary.sh"
RTK_REWRITE_COMMAND = ".claude/hooks/rtk-rewrite.sh"
```

- [ ] **Step 2: 实现基础加载和写回逻辑, 让“目标缺失时以源模板为基底”成为默认行为**

```python
def load_settings(source_path: Path, target_path: Path) -> dict:
    if target_path.exists():
        return json.loads(target_path.read_text(encoding="utf-8"))
    return json.loads(source_path.read_text(encoding="utf-8"))


def write_settings(target_path: Path, data: dict) -> None:
    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
```

- [ ] **Step 3: 实现三段结构化补丁函数, 分别处理 `statusLine`、`SessionEnd` 和 `PreToolUse:Bash`**

```python
def ensure_statusline(settings: dict, warnings: list[str]) -> None:
    statusline = settings.get("statusLine")
    if statusline is None:
        settings["statusLine"] = {"command": STATUSLINE_COMMAND}
        return
    if statusline.get("command") != STATUSLINE_COMMAND:
        warnings.append(f"statusLine already exists: {statusline.get('command')}")


def ensure_command_hook(entries: list[dict], command: str) -> None:
    if not entries:
        entries.append({"hooks": [{"type": "command", "command": command}]})
        return
    hooks = entries[0].setdefault("hooks", [])
    if {"type": "command", "command": command} not in hooks:
        hooks.append({"type": "command", "command": command})


def ensure_bash_pretool(settings: dict) -> None:
    hooks = settings.setdefault("hooks", {})
    entries = hooks.setdefault("PreToolUse", [])
    for entry in entries:
        if entry.get("matcher") == "Bash":
            bash_hooks = entry.setdefault("hooks", [])
            target = {"type": "command", "command": RTK_REWRITE_COMMAND}
            if target not in bash_hooks:
                bash_hooks.append(target)
            return
    entries.append({"matcher": "Bash", "hooks": [{"type": "command", "command": RTK_REWRITE_COMMAND}]})
```

- [ ] **Step 4: 实现 `main()` 和简洁输出, 让 installer 能直接调用**

```python
def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("usage: patch_claude_settings.py <source_settings> <target_settings>", file=sys.stderr)
        return 1

    source_path = Path(argv[1])
    target_path = Path(argv[2])
    warnings: list[str] = []
    settings = load_settings(source_path, target_path)
    settings.setdefault("hooks", {})
    ensure_statusline(settings, warnings)
    ensure_command_hook(settings["hooks"].setdefault("SessionEnd", []), SESSION_SUMMARY_COMMAND)
    ensure_bash_pretool(settings)
    write_settings(target_path, settings)

    for warning in warnings:
        print(warning, file=sys.stderr)
    print("patched settings")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
```

- [ ] **Step 5: 运行定向测试, 确认四个结构化补丁场景转绿**

Run:

```bash
python3 -m unittest tests.test_installation_activation.InstallationActivationTests.test_patch_script_seeds_missing_target_settings_from_source_template -v
python3 -m unittest tests.test_installation_activation.InstallationActivationTests.test_patch_script_appends_rtk_hook_to_existing_bash_matcher -v
python3 -m unittest tests.test_installation_activation.InstallationActivationTests.test_patch_script_preserves_existing_statusline_and_reports_conflict -v
python3 -m unittest tests.test_installation_activation.InstallationActivationTests.test_patch_script_does_not_duplicate_existing_required_hooks -v
```

Expected:

```text
OK
```

---

### Task 3: 把补丁脚本接入 installer 主链路

**Files:**
- Modify: `scripts/installers/install.sh`
- Test: `tests/test_installation_activation.py`
- Verify: `.claude/settings.json`

- [ ] **Step 1: 在 `.claude` 基础复制循环中跳过 `settings.json`, 避免再走通用 JSON merge**

```bash
for item in ".claude"/*; do
    basename=$(basename "$item")
    if [ "$basename" == "profiles" ] || [ "$basename" == "tmp" ] || [ "$basename" == "settings.json" ]; then
        continue
    fi

    safe_install "$item" "$CLAUDE_ROOT/$basename"
done
```

- [ ] **Step 2: 在基础复制和 profile 覆盖完成后, 专门调用补丁脚本生成或修补目标 settings**

```bash
SOURCE_SETTINGS="$(pwd)/.claude/settings.json"
TARGET_SETTINGS="$CLAUDE_ROOT/settings.json"

cecho "$BLUE" "🧩 Patching Claude settings..."
"$PYTHON_CMD" "$(pwd)/scripts/installers/patch_claude_settings.py" \
    "$SOURCE_SETTINGS" \
    "$TARGET_SETTINGS"
```

- [ ] **Step 3: 为 fresh target 新增 installer 集成测试, 确认运行后链路文件和配置同时到位**

```python
    def test_install_script_bootstraps_required_runtime_entries_for_fresh_target(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "target"
            target.mkdir()
            result = subprocess.run(
                ["bash", str(REPO_ROOT / "scripts/installers/install.sh"), str(target)],
                cwd=REPO_ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads((target / ".claude/settings.json").read_text(encoding="utf-8"))

        self.assertEqual(0, result.returncode)
        self.assertTrue((target / ".claude/scripts/statusline.sh").exists())
        self.assertTrue((target / ".claude/hooks/session-summary.sh").exists())
        self.assertEqual(".claude/scripts/statusline.sh", settings["statusLine"]["command"])
```

- [ ] **Step 4: 为已有目标 settings 的场景新增 installer 集成测试, 确认保留现有 `statusLine` 并补齐缺失 hooks**

```python
    def test_install_script_preserves_existing_target_statusline_while_backfilling_hooks(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "target"
            (target / ".claude").mkdir(parents=True)
            (target / ".claude/settings.json").write_text(
                json.dumps(
                    {
                        "statusLine": {"command": ".claude/scripts/custom-statusline.sh"},
                        "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": []}]},
                    }
                ),
                encoding="utf-8",
            )
            result = subprocess.run(
                ["bash", str(REPO_ROOT / "scripts/installers/install.sh"), str(target)],
                cwd=REPO_ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            settings = json.loads((target / ".claude/settings.json").read_text(encoding="utf-8"))
            bash_hooks = settings["hooks"]["PreToolUse"][0]["hooks"]

        self.assertEqual(0, result.returncode)
        self.assertEqual(".claude/scripts/custom-statusline.sh", settings["statusLine"]["command"])
        self.assertIn({"type": "command", "command": ".claude/hooks/rtk-rewrite.sh"}, bash_hooks)
        self.assertIn("statusLine already exists", result.stderr)
```

- [ ] **Step 5: 运行整组安装测试, 确认 helper + installer 接线转绿**

Run:

```bash
python3 -m unittest tests.test_installation_activation -v
```

Expected:

```text
Ran 6 tests
OK
```

---

### Task 4: 增加最小运行时验证和交付文档

**Files:**
- Modify: `tests/test_installation_activation.py`
- Create: `docs/reports/2026-05-14-installation-activation-fix-validation.md`
- Modify: `docs/reports/2026-05-14-token-optimization-summary.md`

- [ ] **Step 1: 为安装后脚本链路新增最小运行时测试, 确认 `statusline.sh` 能写 snapshot**

```python
    def test_installed_statusline_writes_snapshot_in_target_project(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "target"
            target.mkdir()
            subprocess.run(
                ["bash", str(REPO_ROOT / "scripts/installers/install.sh"), str(target)],
                cwd=REPO_ROOT,
                text=True,
                capture_output=True,
                check=True,
            )
            payload = json.dumps(
                {
                    "model": {"display_name": "Claude"},
                    "workspace": {"current_dir": str(target)},
                    "session": {"api_requests": 31, "continued_session": True},
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
            )

            result = subprocess.run(
                ["bash", str(target / ".claude/scripts/statusline.sh")],
                cwd=target,
                input=payload,
                text=True,
                capture_output=True,
                check=False,
            )

        self.assertEqual(0, result.returncode)
        self.assertTrue((target / ".claude/tmp/session_usage_snapshot.json").exists())
```

- [ ] **Step 2: 在验证报告中记录安装前问题、补丁策略、测试证据和已知限制**

```md
# Installation Activation Fix Validation

## Verification Scope
- installer writes required runtime files
- target `.claude/settings.json` contains required runtime entries
- installed `statusline.sh` can generate `session_usage_snapshot.json`

## Command Evidence
- `python3 -m unittest tests.test_installation_activation -v`
- `make test`
- `make lint-skills`
- `make check`

## Known Limits
- existing custom `statusLine` is preserved, not replaced
- this round only patches `statusLine`, `SessionEnd`, and `PreToolUse:Bash`
```

- [ ] **Step 3: 在总总结文档中追加安装链路修复入口**

```md
## Installation Activation Fix

- Design: `docs/superpowers/specs/2026-05-14-installation-activation-fix-design.md`
- Plan: `docs/superpowers/plans/2026-05-14-installation-activation-fix.md`
- Validation: `docs/reports/2026-05-14-installation-activation-fix-validation.md`
```

- [ ] **Step 4: 运行安装测试与全量测试, 确认文档前的证据完整**

Run:

```bash
python3 -m unittest tests.test_installation_activation -v
make test
```

Expected:

```text
All tests exit 0
```

---

### Task 5: 跑仓库级校验并审核 diff

**Files:**
- Verify: `scripts/installers/install.sh`
- Verify: `scripts/installers/patch_claude_settings.py`
- Verify: `tests/test_installation_activation.py`
- Verify: `docs/reports/2026-05-14-installation-activation-fix-validation.md`
- Verify: `docs/reports/2026-05-14-token-optimization-summary.md`

- [ ] **Step 1: 跑仓库要求的完整校验**

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

- [ ] **Step 2: 审核目标 diff, 确认只包含安装链路修复相关改动**

Run:

```bash
git diff -- scripts/installers/install.sh scripts/installers/patch_claude_settings.py tests/test_installation_activation.py docs/reports/2026-05-14-installation-activation-fix-validation.md docs/reports/2026-05-14-token-optimization-summary.md
```

Expected:

```text
Only installation activation fix changes are present
```

- [ ] **Step 3: 记录交付后的行为边界, 作为 handoff 内容**

```text
- installer now patches required Claude runtime entries after file copy
- existing custom statusLine is preserved and reported, not overwritten
- hook patching is idempotent for SessionEnd and PreToolUse:Bash
- broader manifest-driven installer refactor stays out of scope
```

---

## Self-Review

- Spec coverage:
  - 自动接通 `statusLine` / `SessionEnd` / `PreToolUse:Bash` -> Task 1, Task 2, Task 3
  - 不覆盖已有 `statusLine` -> Task 1, Task 2, Task 3
  - installer 级验证和运行时验证 -> Task 3, Task 4
  - 仓库级校验与交付证据 -> Task 4, Task 5
- Placeholder scan:
  - 无 `TODO`、`TBD`、"后续再补" 等占位语
- Type consistency:
  - `patch_claude_settings.py`、`statusLine`、`SessionEnd`、`PreToolUse`、`matcher=Bash`、`session_usage_snapshot.json` 在所有任务中名称一致
