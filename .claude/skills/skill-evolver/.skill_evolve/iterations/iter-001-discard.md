# Iteration 1 — DISCARD

**Date:** 2026-05-21T15:00
**Layer:** Layer 2
**Target case:** extracted-20260521-002 (A6/A7 R3 aggregation)
**Status:** DISCARD

## Mutation Proposed

Add explicit aggregation rule to Degraded Mode L1 Static Check:
> "When multiple absolute paths trigger R3, each distinct path counts as one warning entry (not de-duplicated)."

**Counterfactual:** Case 002 A6/A7 failed because SKILL.md safety scan output format does not specify how to count multiple R3 occurrences; if we add an explicit aggregation rule, we expect A6 `contains: 2 warnings` and A7 llm_judge to PASS.

## L1 Result: FAIL ★

**R2★ false positive:** regex `(api[_-]?key|secret|token|BEGIN .* PRIVATE KEY)` matched substring `token` inside text `total token cost` in the Gate section of SKILL.md.

This is NOT a credential. This is LLM usage terminology. The failure is **pre-existing** in `references/safety-rules.md` R2 pattern — not introduced by Mutation 1.

## Gate Result

- structure_and_safety: **FAIL** (L1 R2★)
- dev_quality: NOT_RUN
- strict_quality: NOT_RUN
- cost_budget: NOT_RUN
- atomic_auditability: NOT_RUN

**Decision: DISCARD — all gates must pass (AND gate)**

## Rollback

Restored SKILL.md from: `.skill_evolve/workspace/SKILL.md.snap-20260521T144955`

## Root Cause

`references/safety-rules.md` R2 pattern uses bare `token` which is too broad. Every SKILL.md discussing token budgets, token costs, or token counts will false-positive on R2. This blocks all future iterations until the R2 regex is narrowed.

## Next Action

Layer 3 mutation required: narrow R2 regex in `references/safety-rules.md` from bare `token` to explicit forms: `access_token|api_token|auth_token|Bearer\s`.

Trace evidence proves failure lives in `references/safety-rules.md` → Layer 3 eligible without exhausting lower layers first (per loop rule: "skip directly to Layer 3 when trace evidence already proves the failure lives in helper material").
