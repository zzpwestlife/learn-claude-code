---
name: engineering-standards
description: Apply before any feature, bug fix, or code review task.
version: "1.0.0"
---

# Engineering Standards

This document outlines the mandatory engineering standards for all development work. It combines three critical disciplines:
1. **Test-Driven Development (TDD)**: Ensuring correctness from the start.
2. **Systematic Debugging**: Solving problems at their root cause.
3. **Verification Before Completion**: Proving success with evidence.

---

## 1. Test-Driven Development (TDD)

Use when implementing any feature or bugfix, before writing implementation code.

### The Iron Law
**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**
If you wrote code before the test, delete it and start over.

### Process: Red-Green-Refactor

#### 1. RED - Write Failing Test
- **Action**: Write one minimal test for the missing feature/bug.
- **Rules**:
  - One behavior per test.
  - Real code (avoid mocks unless unavoidable).
  - Clear test name.
- **Verify**: Run test. Must fail (not error).
  - `npm test path/to/test` (or equivalent)

#### 2. GREEN - Minimal Code
- **Action**: Write simplest code to pass the test.
- **Rules**:
  - Do NOT add unrequested features (YAGNI).
  - Do NOT refactor yet.
- **Verify**: Run test. Must pass.
  - All other tests must also pass.

#### 3. REFACTOR - Clean Up
- **Action**: Clean up code while keeping tests green.
- **Rules**:
  - Remove duplication.
  - Improve naming.
  - Extract helpers.
- **Verify**: Run all tests.

### Environment Constraints
If local environment lacks test runner:
1. **Red**: Verify missing module via interpreter (e.g., `python -c "import mod"`).
2. **Test File**: Write standard test file (for CI).
3. **Green**: Use one-liner script to verify logic.
4. **Refactor**: Clean up.

### Verification Checklist
- [ ] Watched test fail before implementing?
- [ ] Failed for the right reason (feature missing)?
- [ ] Wrote minimal code to pass?
- [ ] All tests pass now?
- [ ] No errors/warnings?

> For detailed tutorial and anti-patterns, see `.claude/docs/references/skills/tdd_full.md`

---

## 2. Systematic Debugging

Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes.

### Overview
Random fixes waste time and create new bugs. Quick patches mask underlying issues.
**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

### The Iron Law
```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```
If you haven't completed Phase 1, you cannot propose fixes.

### The Four Phases
You MUST complete each phase before proceeding to the next.

#### Phase 1: Root Cause Investigation
**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings.
   - Read stack traces completely.

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?

3. **Check Recent Changes**
   - Git diff, recent commits.
   - Environmental differences.

4. **Gather Evidence in Multi-Component Systems**
   - Add diagnostic instrumentation at component boundaries.
   - Log what data enters/exits each component.
   - Run once to gather evidence showing WHERE it breaks.

5. **Trace Data Flow**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source.
   - See `.claude/docs/references/skills/root-cause-tracing.md` for complete technique.

#### Phase 2: Pattern Analysis
**Find the pattern before fixing:**

1. **Find Working Examples**: Locate similar working code in same codebase.
2. **Compare Against References**: Read reference implementation COMPLETELY.
3. **Identify Differences**: List every difference between working and broken.
4. **Understand Dependencies**: What other components/config does this need?

#### Phase 3: Hypothesis and Testing
**Scientific method:**

1. **Form Single Hypothesis**: "I think X is the root cause because Y".
2. **Test Minimally**: Make the SMALLEST possible change to test hypothesis.
3. **Verify Before Continuing**: Did it work? If not, form NEW hypothesis.
4. **When You Don't Know**: Say "I don't understand X". Research more.

#### Phase 4: Implementation
**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**: Simplest possible reproduction (automated if possible).
2. **Implement Single Fix**: Address root cause. ONE change at a time.
3. **Verify Fix**: Test passes now? No other tests broken?
4. **If Fix Doesn't Work**: STOP.
   - If < 3 tries: Return to Phase 1.
   - If ≥ 3 tries: STOP and question architecture.

### Red Flags - STOP and Follow Process
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Skip the test, I'll manually verify"
- "One more fix attempt" (when already tried 2+)

### Supporting Techniques
- **Root Cause Tracing**: `.claude/docs/references/skills/root-cause-tracing.md`
- **Defense in Depth**: `.claude/docs/references/skills/defense-in-depth.md`
- **Condition Based Waiting**: `.claude/docs/references/skills/condition-based-waiting.md`
  - See `condition-based-waiting-example.ts` in this directory for implementation example.
- **Find Polluter**: See `find-polluter.sh` in this directory for finding tests that leak state.

---

## 3. Verification Before Completion

Use when about to claim work is complete, fixed, or passing, before committing or creating PRs.

### Overview
Claiming work is complete without verification is dishonesty, not efficiency.
**Core principle:** Evidence before claims, always.

### The Iron Law
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```
If you haven't run the verification command in this message, you cannot claim it passes.

### The Gate Function
```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim
```

### Common Failures
| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |

### Red Flags - STOP
- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports without independent verification

### The Bottom Line
**No shortcuts for verification.**
Run the command. Read the output. THEN claim the result.
