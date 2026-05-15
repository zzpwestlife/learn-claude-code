"""Benchmark prompt/token reductions for Task2-Task5 changes."""

from __future__ import annotations

import math
import subprocess
from pathlib import Path


TARGETS = (
    {
        "name": "claudeception-activator",
        "path": ".claude/scripts/claudeception-activator.sh",
        "extractor": "activator",
    },
    {
        "name": "changelog-generator",
        "path": ".claude/commands/changelog-generator.md",
        "extractor": "markdown",
    },
    {
        "name": "audit-skills",
        "path": ".claude/commands/audit-skills.md",
        "extractor": "markdown",
    },
    {
        "name": "commit-message-generator",
        "path": ".claude/commands/commit-message-generator.md",
        "extractor": "markdown",
    },
)


def estimate_tokens(text: str) -> int:
    """Estimate tokens with a simple 4-char heuristic."""
    if not text:
        return 0
    return math.ceil(len(text) / 4)


def extract_markdown_prompt(text: str) -> str:
    """Keep prompt-bearing markdown and drop frontmatter/shell prelude."""
    body = text
    if text.startswith("---\n"):
        _, _, remainder = text.partition("---\n")
        _, _, body = remainder.partition("\n---\n")
    lines = []
    for line in body.splitlines():
        stripped = line.strip()
        if stripped.startswith("!"):
            continue
        if not stripped and (not lines or not lines[-1]):
            continue
        lines.append(line.rstrip())
    return "\n".join(lines).strip()


def extract_activator_prompt(text: str) -> str:
    """Extract the first heredoc body from the activator script."""
    marker = "cat <<"
    start = text.find(marker)
    if start == -1:
        return ""
    header_end = text.find("\n", start)
    if header_end == -1:
        return ""
    eof_start = text.find("\nEOF", header_end)
    if eof_start == -1:
        return ""
    return text[header_end + 1 : eof_start].strip()


def extract_text(text: str, extractor: str) -> str:
    """Dispatch extractor by target type."""
    if extractor == "activator":
        return extract_activator_prompt(text)
    return extract_markdown_prompt(text)


def compare_text(before: str, after: str, name: str) -> dict:
    """Compare before/after token counts for one scenario."""
    before_tokens = estimate_tokens(before)
    after_tokens = estimate_tokens(after)
    reduction_pct = 0.0
    if before_tokens:
        reduction_pct = round((before_tokens - after_tokens) * 100 / before_tokens, 1)
    return {
        "name": name,
        "before_tokens": before_tokens,
        "after_tokens": after_tokens,
        "reduction_pct": reduction_pct,
    }


def build_report_from_snapshots(snapshots: list[dict]) -> dict:
    """Build aggregate report from extracted prompt snapshots."""
    scenarios = [compare_text(item["before"], item["after"], item["name"]) for item in snapshots]
    before_total = sum(item["before_tokens"] for item in scenarios)
    after_total = sum(item["after_tokens"] for item in scenarios)
    overall = compare_text("x" * (before_total * 4), "x" * (after_total * 4), "overall")
    overall["before_tokens"] = before_total
    overall["after_tokens"] = after_total
    return {"scenarios": scenarios, "overall": overall}


def load_head_text(repo_root: Path, relative_path: str) -> str:
    """Load baseline text from HEAD for a tracked file."""
    result = subprocess.run(
        ["git", "show", f"HEAD:{relative_path}"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise FileNotFoundError(relative_path)
    return result.stdout


def build_report(repo_root: Path) -> dict:
    """Load HEAD/current snapshots and compute the benchmark report."""
    snapshots = []
    for target in TARGETS:
        relative_path = target["path"]
        current_text = (repo_root / relative_path).read_text(encoding="utf-8")
        before_text = load_head_text(repo_root, relative_path)
        snapshots.append(
            {
                "name": target["name"],
                "before": extract_text(before_text, target["extractor"]),
                "after": extract_text(current_text, target["extractor"]),
            }
        )
    return build_report_from_snapshots(snapshots)


def render_report(report: dict) -> str:
    """Render a compact markdown table plus overall summary."""
    lines = [
        "| 场景 | Before Tokens | After Tokens | 降幅 |",
        "| --- | ---: | ---: | ---: |",
    ]
    for scenario in report["scenarios"]:
        lines.append(
            f"| {scenario['name']} | {scenario['before_tokens']} | {scenario['after_tokens']} | {scenario['reduction_pct']}% |"
        )
    overall = report["overall"]
    lines.extend(
        [
            "",
            f"整体：{overall['before_tokens']} -> {overall['after_tokens']} tokens，降幅 {overall['reduction_pct']}%",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    """Run benchmark in the current repository."""
    repo_root = Path(__file__).resolve().parent.parent
    print(render_report(build_report(repo_root)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
