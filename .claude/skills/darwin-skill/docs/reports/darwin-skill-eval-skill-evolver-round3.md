# Darwin Skill Eval Report — skill-evolver
**Date:** 2026-05-21  
**Rounds:** 3 / 3 KEEP  
**eval_mode:** dry_run

## Score Summary

| Metric | Value |
|---|---|
| Baseline | 79.2 |
| Final | 84.55 |
| Δ | **+5.35** |
| Reverts | 0 |

## Dimension Detail

| # | Dimension | Weight | Before | After | Δ pts |
|---|---|---|---|---|---|
| D1 | Frontmatter质量 | 8 | 7/10 | 9/10 | +1.6 |
| D2 | 工作流清晰度 | 15 | 8/10 | 8/10 | — |
| D3 | 边界条件覆盖 | 10 | 8/10 | 8/10 | — |
| D4 | 检查点设计 | 7 | 9/10 | 9/10 | — |
| D5 | 指令具体性 | 15 | 8/10 | 9/10 | +1.5 |
| D6 | 资源整合度 | 5 | 8/10 | 8/10 | — |
| D7 | 整体架构 | 15 | 7/10 | 8.5/10 | +2.25 |
| D8 | 实测表现 | 25 | 8.3/10 | 8.3/10 | — |

## Changes Made

### Round 1 — D7 整体架构 (+2.25pt)
**File:** `SKILL.md`  
**Change:** Added `## Mode Dispatch` table between SKIP examples and `## Inputs`.  
Maps 6 scenarios (full mode / degraded mode / trace extraction / 3× skip) to their entry points and modes in a single lookup table. Replaced scattered `If user only wants X…` inline triage.

### Round 2 — D1 Frontmatter质量 (+1.6pt)
**File:** `SKILL.md`  
**Change:** Restructured frontmatter `description` from single-line string to multi-line YAML with four explicit lines:
- `Invoke when:` — 3 trigger modes
- `Do not use when:` — 3 exclusion cases
- `Example (invoke):` — 1 positive example
- `Example (skip):` — 1 negative example

### Round 3 — D5 指令具体性 (+1.5pt)
**File:** `SKILL.md`  
**Change:** skill-creator dependency instruction changed from:
> "If skill-creator is unavailable, stop and surface the gap"

To explicit `dry_run mode` fallback:
> Enter **dry_run mode**: surface gap in `baseline.json`, skip `quick_validate`, simulate L2/L3 via agent reasoning, mark `eval_mode: dry_run`, always report simulated vs. skipped.

## Remaining Gaps (next session targets)

| Dimension | Issue | Potential Δ |
|---|---|---|
| D7 | Full Mode lacks Phase 1/2/3 labels; only Phase 0 is labeled | +1.5pt |
| D3 | No explicit stop condition when dataset exists but GT data is missing | +0.5pt |
| D8 | dry_run only; live skill-creator run would add confidence | TBD |

## Artifacts

- Results: `.claude/skills/darwin-skill/results.tsv`
- Report: `docs/reports/darwin-skill-eval-skill-evolver-round3.md`
- Card HTML: `templates/result-card-skill-evolver-20260521.html`
- Snapshots: `.skill_evolve/workspace/SKILL.md.darwin-bak-*`

---

## Continued: Rounds 4–5 (user requested)

| Round | Dimension | Change | Δ pts | New total |
|---|---|---|---|---|
| R4 | D7 整体架构 | `## Iteration Loop` → `## Phase 1: Iteration Loop` + bridge sentence | +0.75 | 85.3 |
| R5 | D3 边界条件 | Phase 0 Step 2: add explicit stop when GT data absent | +0.5 | **85.8** |

**Final score: 85.8** (started: 79.2, total Δ: +6.6pt, 5/5 KEEP, 0 revert)
