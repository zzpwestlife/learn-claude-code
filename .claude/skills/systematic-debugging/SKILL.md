---
name: systematic-debugging
description: |
  Invoke when a bug, test failure, or unexpected behavior must be root-caused before any fix.
  First step: diagnostic questions (reverse prompting); then reproduce, hypothesize, verify.
version: "1.0.0"
---

# Systematic Debugging

## Iron rule

**No fix before root cause is evidenced.** Do not guess-and-patch.

## Phase 0 · Diagnostic questions (reverse prompting)

When the user reports a bug with insufficient context, **STOP** and ask — do not analyze or edit code yet.

Use this prompt shape internally:

> 我需要这些信息才能定位：[按重要性排序的问题清单]。请逐条回答。不要假设答案后直接改代码。

**Typical question dimensions** (pick only what applies; ≤5 questions):

| Priority | Ask about |
|----------|-----------|
| 1 | Always or intermittent? Steps to reproduce? |
| 2 | Frontend vs backend? Console / server logs / trace id? |
| 3 | Recent changes to related code or config? |
| 4 | Data state (DB row, cache, feature flag)? |
| 5 | Environment (prod/staging/local, version, region)? |

**STOP rule**: List questions → wait for answers. Do not self-answer and proceed.

User guide: `docs/guides/reverse-prompting.md` (Bug 诊断版).

## Phase 1 · Reproduce

- Minimal repro steps or failing test command
- Capture exact error message and exit code

## Phase 2 · Hypothesize

- One primary hypothesis; at most two alternates
- Tie each to observable evidence

## Phase 3 · Verify

- Run targeted checks (grep, log slice, single test)
- Record evidence block: command + exit code + relevant output snippet

## Phase 4 · Fix and regression

- Smallest change that addresses root cause
- Add or run regression test when behavior is non-trivial
- Invoke `verification-before-completion` before claiming done

## Deliverable (R)

Write a short debug note when closing:

- Path: `.claude/tmp/debug-YYYY-MM-DD-<slug>.md` or append to task handoff
- Sections: symptom · repro · root cause · fix · verification command

## Routing

| Situation | Action |
|-----------|--------|
| No repro possible | STOP; list what user must provide |
| Fix requested before Phase 0–1 done | Refuse; complete diagnostic questions first |
| Needs design change | Route `design-first` after root cause is known |
