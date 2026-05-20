"""Session token observer CLI."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


SECTION_ORDER = ("by_input_tokens", "by_output_tokens", "by_frequency")


def load_jsonl(path: Path) -> list[dict]:
    """Load a jsonl file and ignore empty lines."""
    if not path.exists():
        return []
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def scenario_label(index: int, prompt: str) -> str:
    """Build a stable human-readable scenario label."""
    preview = " ".join(prompt.split())[:60] if prompt else "未命名场景"
    return f"S{index:02d} {preview}"


def assign_scenario(api_row: dict, prompts_by_session: dict[str, list[dict]]) -> tuple[str, str]:
    """Map an API request row to the latest prompt in the same session."""
    prompts = prompts_by_session.get(api_row.get("session_id", ""), [])
    chosen = None
    for prompt in prompts:
        if prompt["timestamp"] <= api_row.get("timestamp", ""):
            chosen = prompt
        else:
            break
    if chosen is None:
        message_id = api_row.get("message_id", "unknown")
        return f"fallback:{message_id}", f"未匹配提示词 {message_id}"
    return chosen["scenario_key"], chosen["scenario"]


def build_report(eval_dir: str | Path) -> dict:
    """Build ledger, rankings, and Top3 from session-eval exports."""
    eval_path = Path(eval_dir)
    api_rows = sorted(load_jsonl(eval_path / "api_requests.jsonl"), key=lambda row: row.get("timestamp", ""))
    if not api_rows:
        raise FileNotFoundError(f"missing data: {eval_path / 'api_requests.jsonl'}")

    prompts_by_session: dict[str, list[dict]] = {}
    for prompt_index, prompt_row in enumerate(
        sorted(load_jsonl(eval_path / "user_prompts.jsonl"), key=lambda row: row.get("timestamp", "")),
        start=1,
    ):
        session_id = prompt_row.get("session_id", "")
        prompt_rows = prompts_by_session.setdefault(session_id, [])
        prompt_rows.append(
            {
                "timestamp": prompt_row.get("timestamp", ""),
                "scenario_key": f"{session_id}:{prompt_index}",
                "scenario": scenario_label(prompt_index, prompt_row.get("prompt", "")),
            }
        )

    ledger_map: dict[str, dict] = {}
    for row in api_rows:
        scenario_key, scenario = assign_scenario(row, prompts_by_session)
        entry = ledger_map.setdefault(
            scenario_key,
            {
                "scenario": scenario,
                "input_tokens": 0,
                "output_tokens": 0,
                "cache_read_input_tokens": 0,
                "cache_creation_input_tokens": 0,
                "frequency": 0,
                "models": set(),
            },
        )
        entry["input_tokens"] += int(row.get("input_tokens", 0) or 0)
        entry["output_tokens"] += int(row.get("output_tokens", 0) or 0)
        entry["cache_read_input_tokens"] += int(row.get("cache_read_input_tokens", 0) or 0)
        entry["cache_creation_input_tokens"] += int(row.get("cache_creation_input_tokens", 0) or 0)
        entry["frequency"] += 1
        if row.get("model"):
            entry["models"].add(str(row["model"]))

    ledger = []
    for entry in ledger_map.values():
        entry["models"] = ", ".join(sorted(entry["models"])) if entry["models"] else "-"
        ledger.append(entry)
    rankings = {
        "by_input_tokens": sorted(ledger, key=lambda row: (-row["input_tokens"], row["scenario"])),
        "by_output_tokens": sorted(ledger, key=lambda row: (-row["output_tokens"], row["scenario"])),
        "by_frequency": sorted(ledger, key=lambda row: (-row["frequency"], row["scenario"])),
    }
    return {"ledger": ledger, "rankings": rankings, "top3": {name: rows[:3] for name, rows in rankings.items()}}


def render_rows(rows: list[dict], metric: str) -> list[str]:
    """Render a compact fixed-width table body."""
    lines = []
    for index, row in enumerate(rows, start=1):
        lines.append(
            f"{index:>2}. {row['scenario']:<40} model={row['models']:<18} "
            f"input={row['input_tokens']:<4} output={row['output_tokens']:<4} "
            f"cache_read={row['cache_read_input_tokens']:<4} "
            f"cache_write={row['cache_creation_input_tokens']:<4} "
            f"调用频次={row['frequency']:<3} {metric}={row[metric]}"
        )
    return lines


def render_report(report: dict) -> str:
    """Render the final terminal report."""
    parts = ["场景台账", *render_rows(report["ledger"], "frequency")]
    labels = {
        "by_input_tokens": ("按 input_tokens 排序", "input_tokens"),
        "by_output_tokens": ("按 output_tokens 排序", "output_tokens"),
        "by_frequency": ("按调用频次排序", "frequency"),
    }
    for section_name in SECTION_ORDER:
        title, metric = labels[section_name]
        parts.extend(["", title, *render_rows(report["rankings"][section_name], metric), "", f"Top3 {title}"])
        parts.extend(render_rows(report["top3"][section_name], metric))
    return "\n".join(parts)


def main(argv: list[str] | None = None) -> int:
    """Run the CLI and print the text report."""
    parser = argparse.ArgumentParser(description="Observe token usage from session-eval exports.")
    parser.add_argument("eval_dir", help="Directory containing api_requests.jsonl and user_prompts.jsonl")
    args = parser.parse_args(argv)
    try:
        print(render_report(build_report(args.eval_dir)))
        return 0
    except FileNotFoundError as error:
        print(str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
