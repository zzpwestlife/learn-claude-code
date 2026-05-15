"""Regression tests for session token observer CLI."""

import json
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

from scripts.session_token_observer import build_report, main


def write_jsonl(path: Path, rows: list[dict]) -> None:
    """Write a small jsonl fixture file for tests."""
    path.write_text("".join(json.dumps(row) + "\n" for row in rows), encoding="utf-8")


class SessionTokenObserverTests(unittest.TestCase):
    def test_build_report_groups_prompt_scenarios_and_sorts_dimensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            eval_dir = Path(tmp)
            write_jsonl(
                eval_dir / "user_prompts.jsonl",
                [
                    {"timestamp": "2026-05-14T10:00:00Z", "session_id": "session-1", "prompt": "Task A auth bug triage"},
                    {"timestamp": "2026-05-14T10:05:00Z", "session_id": "session-1", "prompt": "Task B refactor hooks"},
                    {"timestamp": "2026-05-14T10:10:00Z", "session_id": "session-1", "prompt": "Task C write docs"},
                    {"timestamp": "2026-05-14T10:15:00Z", "session_id": "session-1", "prompt": "Task D fix lint"},
                ],
            )
            write_jsonl(
                eval_dir / "api_requests.jsonl",
                [
                    {"timestamp": "2026-05-14T10:00:10Z", "session_id": "session-1", "message_id": "m1", "model": "sonnet", "input_tokens": 120, "output_tokens": 30, "cache_read_input_tokens": 10, "cache_creation_input_tokens": 2},
                    {"timestamp": "2026-05-14T10:00:20Z", "session_id": "session-1", "message_id": "m2", "model": "sonnet", "input_tokens": 30, "output_tokens": 80, "cache_read_input_tokens": 5, "cache_creation_input_tokens": 1},
                    {"timestamp": "2026-05-14T10:05:05Z", "session_id": "session-1", "message_id": "m3", "model": "haiku", "input_tokens": 90, "output_tokens": 20, "cache_read_input_tokens": 4, "cache_creation_input_tokens": 0},
                    {"timestamp": "2026-05-14T10:05:10Z", "session_id": "session-1", "message_id": "m4", "model": "haiku", "input_tokens": 10, "output_tokens": 10, "cache_read_input_tokens": 1, "cache_creation_input_tokens": 0},
                    {"timestamp": "2026-05-14T10:05:20Z", "session_id": "session-1", "message_id": "m5", "model": "haiku", "input_tokens": 5, "output_tokens": 5, "cache_read_input_tokens": 0, "cache_creation_input_tokens": 0},
                    {"timestamp": "2026-05-14T10:10:10Z", "session_id": "session-1", "message_id": "m6", "model": "opus", "input_tokens": 40, "output_tokens": 15, "cache_read_input_tokens": 0, "cache_creation_input_tokens": 3},
                    {"timestamp": "2026-05-14T10:15:10Z", "session_id": "session-1", "message_id": "m7", "model": "sonnet", "input_tokens": 20, "output_tokens": 10, "cache_read_input_tokens": 2, "cache_creation_input_tokens": 0},
                ],
            )

            report = build_report(eval_dir)

        self.assertEqual(4, len(report["ledger"]))
        self.assertTrue(report["rankings"]["by_input_tokens"][0]["scenario"].endswith("Task A auth bug triage"))
        self.assertTrue(report["rankings"]["by_output_tokens"][0]["scenario"].endswith("Task A auth bug triage"))
        self.assertTrue(report["rankings"]["by_frequency"][0]["scenario"].endswith("Task B refactor hooks"))
        self.assertEqual("sonnet", report["rankings"]["by_input_tokens"][0]["models"])
        self.assertEqual(15, report["rankings"]["by_input_tokens"][0]["cache_read_input_tokens"])
        self.assertEqual(3, len(report["top3"]["by_input_tokens"]))
        self.assertEqual(3, len(report["top3"]["by_output_tokens"]))
        self.assertEqual(3, len(report["top3"]["by_frequency"]))

    def test_cli_prints_ledger_rankings_and_top3(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            eval_dir = Path(tmp)
            write_jsonl(
                eval_dir / "user_prompts.jsonl",
                [
                    {"timestamp": "2026-05-14T11:00:00Z", "session_id": "session-2", "prompt": "Task A fix parser"},
                    {"timestamp": "2026-05-14T11:05:00Z", "session_id": "session-2", "prompt": "Task B update docs"},
                    {"timestamp": "2026-05-14T11:10:00Z", "session_id": "session-2", "prompt": "Task C cleanup"},
                ],
            )
            write_jsonl(
                eval_dir / "api_requests.jsonl",
                [
                    {"timestamp": "2026-05-14T11:00:10Z", "session_id": "session-2", "message_id": "m1", "model": "haiku", "input_tokens": 10, "output_tokens": 20, "cache_read_input_tokens": 1, "cache_creation_input_tokens": 0},
                    {"timestamp": "2026-05-14T11:05:10Z", "session_id": "session-2", "message_id": "m2", "model": "haiku", "input_tokens": 30, "output_tokens": 5, "cache_read_input_tokens": 2, "cache_creation_input_tokens": 1},
                    {"timestamp": "2026-05-14T11:05:20Z", "session_id": "session-2", "message_id": "m3", "model": "haiku", "input_tokens": 25, "output_tokens": 15, "cache_read_input_tokens": 0, "cache_creation_input_tokens": 0},
                    {"timestamp": "2026-05-14T11:10:10Z", "session_id": "session-2", "message_id": "m4", "model": "sonnet", "input_tokens": 5, "output_tokens": 50, "cache_read_input_tokens": 0, "cache_creation_input_tokens": 2},
                ],
            )

            buffer = StringIO()
            with redirect_stdout(buffer):
                exit_code = main([str(eval_dir)])

        output = buffer.getvalue()
        self.assertEqual(0, exit_code)
        self.assertIn("场景台账", output)
        self.assertIn("按 input_tokens 排序", output)
        self.assertIn("按 output_tokens 排序", output)
        self.assertIn("按调用频次排序", output)
        self.assertIn("Top3", output)
        self.assertIn("cache_read=", output)
        self.assertIn("model=", output)
        self.assertIn("Task B update docs", output)


if __name__ == "__main__":
    unittest.main()
