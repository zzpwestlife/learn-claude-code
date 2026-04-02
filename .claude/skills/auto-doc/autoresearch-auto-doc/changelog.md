## Experiment 0 — baseline

**Score:** 20/25 (80.0%)
**Change:** No change — original skill measured as-is
**Reasoning:** Baseline measurement
**Result:** Identified two failure patterns:
  1. E1 failure on S4 (delete scenario): "Add/Del" combined row in trigger table is ambiguous — doesn't clarify that header is N/A for deletes
  2. E5 failures on S2–S5: Skill does not enforce Level 1/2/3 terminology in outputs — agents skip structural references and just say "update CLAUDE.md" without the level label
**Failing outputs:** Add/Del row ambiguity (delete case), no structural level terminology enforcement

## Experiment 1 — keep

**Score:** 23/25 (92.0%) — +3 points from baseline
**Change:** Added "Output format" instruction after trigger table: always name the level explicitly using "Level X (name)" format
**Reasoning:** E5 was failing 4/5 scenarios because agents apply the trigger table correctly but drop the level terminology. Making the output format explicit forces consistent labeling.
**Result:** E5 went from 1/5 to 5/5 (+4). E1 unchanged at 4/5 (Add/Del delete ambiguity remains).
**Failing outputs:** S4 (delete scenario) — Add/Del row still ambiguous, unclear that header is N/A for deletes

## Experiment 2 — keep

**Score:** 25/25 (100.0%) — +2 points from Exp 1
**Change:** Split combined "Add/Del" row in trigger table into separate "Add File" (Header ✅, CLAUDE.md ✅, ARCH ❌) and "Remove File" (Header N/A, CLAUDE.md ✅, ARCH ❌) rows
**Reasoning:** The delete scenario (S4) was failing E1 because the combined row implied the header should be updated even for deletes. Splitting matches the full reference doc and eliminates ambiguity.
**Result:** E1 went from 4/5 to 5/5 across all experiments. Perfect score 25/25.
**Failing outputs:** None — all 5 scenarios pass all 5 evals.

## Experiment 3 — discard

**Score:** 25/25 (100.0%) — same as Exp 2
**Change:** Added "Create if none exists in the directory" to Level 2 description
**Reasoning:** Expected to clarify Add File and New Module scenarios by explicitly noting CLAUDE.md may need to be created, not just updated
**Result:** Score unchanged — agents already understand create-vs-update from context. Change added words without improving pass rate.
**Failing outputs:** None — but per protocol, same score = discard to keep skill minimal.
**Decision:** REVERTED.

