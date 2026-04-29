# INPUT: Git 跟踪的 .claude/skills/*/SKILL.md 文件
# OUTPUT: 退出码 0/1；失败时输出缺失项列表（成功时静默）
# POS: 校验 skill 的 frontmatter + R 合同 + 反锚定

from __future__ import annotations

import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.S)
NAME_RE = re.compile(r"(?m)^\s*name:\s*\S+")
DESCRIPTION_RE = re.compile(r"(?m)^\s*description:\s*(\||.+)$")
VERSION_RE = re.compile(r"(?m)^\s*version:\s*['\"]?\d+(\.\d+){0,2}['\"]?\s*$")

R_CONTRACT_RE = re.compile(r"Reusable Interface\s*\(R\)", re.I)
ANTI_ANCHOR_RE = re.compile(r"Anti-?Anchoring|反锚定", re.I)


@dataclass(frozen=True)
class SkillLintFailure:
    path: str
    missing: tuple[str, ...]


def _git_ls_files(pattern: str) -> list[str]:
    try:
        out = subprocess.check_output(
            ["git", "ls-files", pattern],
            stderr=subprocess.STDOUT,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"git ls-files failed: {e.output.strip()}") from e
    return [line.strip() for line in out.splitlines() if line.strip()]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _extract_frontmatter(text: str) -> str | None:
    m = FRONTMATTER_RE.search(text)
    return None if not m else m.group(1)


def lint_skill_file(path: Path) -> SkillLintFailure | None:
    text = _read_text(path)
    missing: list[str] = []

    frontmatter = _extract_frontmatter(text)
    if not frontmatter:
        missing.append("frontmatter(--- ... ---)")
    else:
        if not NAME_RE.search(frontmatter):
            missing.append("frontmatter.name")
        if not DESCRIPTION_RE.search(frontmatter):
            missing.append("frontmatter.description")
        if not VERSION_RE.search(frontmatter):
            missing.append("frontmatter.version")

    if not R_CONTRACT_RE.search(text):
        missing.append("Reusable Interface (R)")
    if not ANTI_ANCHOR_RE.search(text):
        missing.append("Anti-Anchoring/反锚定")

    if not missing:
        return None
    return SkillLintFailure(str(path), tuple(missing))


def lint_repo() -> list[SkillLintFailure]:
    paths = _git_ls_files(".claude/skills/*/SKILL.md")
    failures: list[SkillLintFailure] = []
    for p in paths:
        failure = lint_skill_file(Path(p))
        if failure:
            failures.append(failure)
    return failures


def _print_failures(failures: Iterable[SkillLintFailure]) -> None:
    for f in failures:
        missing = ", ".join(f.missing)
        print(f"[lint-skills] {f.path}: missing {missing}")


def main() -> int:
    failures = lint_repo()
    if not failures:
        return 0
    _print_failures(failures)
    return 1


if __name__ == "__main__":
    sys.exit(main())

