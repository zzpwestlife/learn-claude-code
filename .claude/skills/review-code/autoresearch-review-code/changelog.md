## Experiment 0 — baseline

**Score:** 16/25 (64.0%)
**Change:** No change — original skill measured as-is
**Result:** E2 (Go-specific Patterns) = 0/5 — zero Go guidance. S3 (context) and S4 (%w) missed entirely.
**Key insight:** Generic 审查维度 catches obvious things but misses Go idiom violations.

---

## Experiment 1 — keep

**Score:** 25/25 (100.0%) — +9 points from baseline
**Change:** Added "Go 特有检查项" section with 5 checks: defer, goroutine sync, context propagation, %w error wrapping, interface size — each with explicit severity label
**Reasoning:** E2 was 0/5. One section targeting all 5 test scenarios simultaneously.
**Result:** E2: 0→5. E1: 3→5 (S3, S4 now correctly identified). E3: 3→5. Perfect score.
**Failing outputs:** None.

---

## Experiment 2 — discard

**Score:** 25/25 (100.0%) — same as Exp 1
**Change:** Tried adding `go test -race` reference to goroutine check line
**Reasoning:** Might make E2 even more actionable for data race scenario
**Result:** Score unchanged — E2 already passes with sync primitive names. Adding tooling note doesn't move any binary eval. Per protocol: same score = discard.
**Decision:** REVERTED (not applied — no-op test).

---

## Experiment 3 — discard

**Score:** 25/25 (100.0%) — same as Exp 1
**Change:** Considered removing lint-runner.py tool reference (redundant with Go checklist)
**Reasoning:** Simplification — Go checklist already covers what the script does
**Result:** Score unchanged — no eval tests for tooling references. Per protocol: same score = discard.
**Decision:** REVERTED (not applied — no-op test).
