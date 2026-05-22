# Distribution Contract

The distributed zip should unpack to one top-level directory named `skill-evolver/`.

## Required bundle contents

### Core（必须包含）

- `SKILL.md`
- `references/artifacts.md`
- `references/dataset-format.md`
- `references/distribution.md`
- `references/runbook.md`
- `scripts/check_skill_package.py`
- `scripts/setup_workspace.py`
- `scripts/validate_dataset.py`
- `assets/example/target_skill/SKILL.md`
- `assets/example/dataset/gt.jsonl`
- `assets/example/dataset/dev.jsonl`
- `assets/example/dataset/holdout.jsonl`
- `assets/example/dataset/regression.jsonl`

### Trace Recorder（随 bundle 一起分发）

- `scripts/trace-recorder.js`
- `scripts/trace-review.js`
- `references/trace-recorder.md`

这两个脚本属于 bundle 的可选但推荐组件。分发时应一并包含，接收方可按 `references/trace-recorder.md` 决定是否启用。

## Must not include

- `.DS_Store`
- `.git/`
- `__pycache__/`
- `.pytest_cache/`
- repo-level tests, PDFs, build artifacts, or temporary smoke outputs
- `~/.claude/skill-traces/`（接收方的本地录制数据，不属于 bundle）

## Dependency contract

**Python scripts**（`scripts/*.py`）：仅依赖 Python 标准库，无需额外安装。接收方应能在不安装任何额外依赖的前提下运行：
```bash
python3 scripts/check_skill_package.py . --json
```

**Node.js scripts**（`scripts/trace-recorder.js`、`scripts/trace-review.js`）：需要 Node.js ≥ 16。这是可选功能的额外依赖，不影响 Core 功能的可用性。分发说明中应明确注明。

## Recipient setup for trace recorder

接收方启用自动录制需在 `~/.claude/settings.json` 中添加：

```json
"PostToolUse": [{
  "matcher": "Skill",
  "hooks": [{ "command": "node <path>/scripts/trace-recorder.js post-tool", "type": "command" }]
}]
```

以及在 `Stop` 数组中追加：

```json
{ "hooks": [{ "command": "node <path>/scripts/trace-recorder.js stop", "type": "command" }] }
```

`<path>` 替换为 bundle 实际安装路径（如 `~/.claude/skills/skill-evolver`）。详见 `references/trace-recorder.md`。

## Pending traces location

自动录制的候选 trace 写入接收方本地的 `~/.claude/skill-traces/pending.jsonl`，与 bundle 目录完全隔离，打包分发时不应包含此文件。
