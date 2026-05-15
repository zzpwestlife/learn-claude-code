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


def load_settings(source_path: Path, target_path: Path) -> dict:
    if target_path.exists():
        return json.loads(target_path.read_text(encoding="utf-8"))
    return json.loads(source_path.read_text(encoding="utf-8"))


def write_settings(target_path: Path, settings: dict) -> None:
    target_path.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(settings, indent=2, ensure_ascii=False) + "\n"
    target_path.write_text(payload, encoding="utf-8")


def ensure_statusline(settings: dict, warnings: list[str]) -> None:
    statusline = settings.get("statusLine")
    if statusline is None:
        settings["statusLine"] = {"command": STATUSLINE_COMMAND}
        return
    if statusline.get("command") != STATUSLINE_COMMAND:
        warnings.append(f"statusLine already exists: {statusline.get('command')}")


def ensure_command_hook(entries: list[dict], command: str) -> None:
    target = {"type": "command", "command": command}
    if not entries:
        entries.append({"hooks": [target]})
        return

    hooks = entries[0].setdefault("hooks", [])
    if target not in hooks:
        hooks.append(target)


def ensure_bash_pretool(settings: dict) -> None:
    hooks = settings.setdefault("hooks", {})
    entries = hooks.setdefault("PreToolUse", [])
    target = {"type": "command", "command": RTK_REWRITE_COMMAND}

    for entry in entries:
        if entry.get("matcher") != "Bash":
            continue
        bash_hooks = entry.setdefault("hooks", [])
        if target not in bash_hooks:
            bash_hooks.append(target)
        return

    entries.append({"matcher": "Bash", "hooks": [target]})


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(
            "usage: patch_claude_settings.py <source_settings> <target_settings>",
            file=sys.stderr,
        )
        return 1

    source_path = Path(argv[1])
    target_path = Path(argv[2])
    warnings: list[str] = []
    settings = load_settings(source_path, target_path)
    hooks = settings.setdefault("hooks", {})

    ensure_statusline(settings, warnings)
    ensure_command_hook(hooks.setdefault("SessionEnd", []), SESSION_SUMMARY_COMMAND)
    ensure_bash_pretool(settings)
    write_settings(target_path, settings)

    for warning in warnings:
        print(warning, file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
