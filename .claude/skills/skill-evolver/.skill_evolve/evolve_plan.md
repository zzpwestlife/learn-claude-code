# skill-evolver Evolution Plan
Generated: 2026-05-21

## Target
- Skill: skill-evolver
- Dataset: dataset/ (1 GT, 3 dev, 1 holdout, 1 regression)
- Output: .skill_evolve/

## Evaluation Strategy
- eval_mode: dry_run (skill-creator unavailable)
- eval.repeat_n: 2 (noise mitigation; lower than default 3 due to dry_run determinism)
- L1: manual (skip quick_validate step)
- L2: dry_run assertions on dev split
- L3: triggered when dev_pass_rate >= 0.90 OR every 3 iterations; holdout + regression

## Baseline
- L1: PASS (0 critical, 0 warnings)
- L2 dev pass rate: 0.875 (21/24 assertions)
- Persistent failure: trace-002 A6/A7 (R3 multi-occurrence reporting format)
- Regression trace-006: STALE — needs update before L3 regression can run

## Gate Thresholds
- structure_and_safety: L1 PASS + 0 critical
- dev_quality: L2 pass rate >= baseline (0.875) + 0 new regressions
- strict_quality: L3 holdout pass rate >= baseline; regression failures = 0
- cost_budget: dry_run cost tracking N/A
- atomic_auditability: 1 layer, 1 file per iteration (default)

## Starting Layer
- Layer 2 (first mutation targets SKILL.md body — safety scan output spec)

## Stop Conditions
1. dev_pass_rate == 1.0 AND L3 passes
2. All layers exhausted (3 failed attempts per layer)
3. Operator exits

## Mutation Candidates (priority order)
1. [Layer 2] Add explicit aggregation rule for multiple R3 occurrences in safety scan output
   → Targets trace-002 A6/A7 failure
2. [Layer 1] Tighten trigger description to distinguish from darwin-skill
   → Improves D1 for edge cases where "评测 skill" could route to either
3. [Dataset] Update regression trace-006 to reflect post-fix expected_output
   → Required before L3 regression can run cleanly

## Artifact Paths
- results.tsv: .skill_evolve/results.tsv
- experiments.jsonl: .skill_evolve/experiments.jsonl
- traces: .skill_evolve/traces/
- iterations: .skill_evolve/iterations/
- checkpoints: .skill_evolve/workspace/ (file snapshots, no git)
