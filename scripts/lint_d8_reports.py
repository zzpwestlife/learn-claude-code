"""Lint adopted D8 report files for required template markers."""

from __future__ import annotations

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


@dataclass(frozen=True)
class D8ReportLintFailure:
    path: Path
    missing: tuple[str, ...]


def lint_report_file(path: Path) -> D8ReportLintFailure | None:
    text = path.read_text(encoding="utf-8")
    missing = tuple(marker for marker in REQUIRED_MARKERS if marker not in text)
    if not missing:
        return None
    return D8ReportLintFailure(path, missing)


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
