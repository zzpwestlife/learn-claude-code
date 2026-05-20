"""Lint adopted D8 report files for required template markers."""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[1]
REPORT_PATHS = (
    REPO_ROOT / "docs/reports/2026-05-19-skill-ab-eval-execution-chain.md",
    REPO_ROOT / "docs/reports/2026-05-19-darwin-skill-self-host-round1.md",
)
REQUIRED_MARKERS = (
    "## Header",
    "## Scope",
    "## Method",
    "## Environment Limitation",
    "## Results",
    "## D8 Decision",
    "## Takeaways",
    "- confidence:",
    "- can_feed_results_tsv:",
)
HEADER_EVAL_MODE_RE = re.compile(r"## Header\b[\s\S]*?^\s*-\s*eval_mode:\s*`?(dry_run|full_test)`?", re.M)
DECISION_EVAL_MODE_RE = re.compile(
    r"## D8 Decision\b[\s\S]*?^\s*-\s*eval_mode:\s*`?(dry_run|full_test)`?", re.M
)
ENVIRONMENT_SECTION_RE = re.compile(
    r"## Environment Limitation\b(?P<body>[\s\S]*?)(?:^##\s|\Z)",
    re.M,
)
PLACEHOLDER_LIMITATIONS = {"none", "n/a", "na"}


@dataclass(frozen=True)
class D8ReportLintFailure:
    path: Path
    missing: tuple[str, ...]


def lint_report_file(path: Path) -> D8ReportLintFailure | None:
    text = path.read_text(encoding="utf-8")
    missing = list(marker for marker in REQUIRED_MARKERS if marker not in text)
    missing.extend(_semantic_failures(text))
    if not missing:
        return None
    return D8ReportLintFailure(path, tuple(missing))


def _semantic_failures(text: str) -> list[str]:
    failures: list[str] = []
    header_eval_mode = _extract_eval_mode(text, HEADER_EVAL_MODE_RE)
    decision_eval_mode = _extract_eval_mode(text, DECISION_EVAL_MODE_RE)

    if header_eval_mode and decision_eval_mode and header_eval_mode != decision_eval_mode:
        failures.append("eval_mode.match")

    if header_eval_mode == "dry_run" and _environment_limitation_is_empty(text):
        failures.append("dry_run.environment_limitation")

    return failures


def _extract_eval_mode(text: str, pattern: re.Pattern[str]) -> str | None:
    match = pattern.search(text)
    if not match:
        return None
    return match.group(1)


def _environment_limitation_is_empty(text: str) -> bool:
    match = ENVIRONMENT_SECTION_RE.search(text)
    if not match:
        return True

    body = match.group("body")
    content_lines = [
        line.strip(" -`")
        for line in body.splitlines()
        if line.strip() and not line.lstrip().startswith("## ")
    ]
    if not content_lines:
        return True

    normalized = " ".join(content_lines).strip().lower()
    return normalized in PLACEHOLDER_LIMITATIONS


def lint_repo() -> list[D8ReportLintFailure]:
    failures: list[D8ReportLintFailure] = []
    for path in REPORT_PATHS:
        failure = lint_report_file(path)
        if failure:
            failures.append(failure)
    return failures


def _print_failures(failures: Iterable[D8ReportLintFailure]) -> None:
    for failure in failures:
        markers = ", ".join(failure.missing)
        print(f"[lint-d8-reports] {failure.path}: missing {markers}")


def main() -> int:
    failures = lint_repo()
    if not failures:
        return 0
    _print_failures(failures)
    return 1


if __name__ == "__main__":
    sys.exit(main())
