---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

**The Iron Law**: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.

## The Four Phases (Sequential)

### Phase 1: Root Cause Investigation
1. **Read Errors**: Don't guess. Read full stack traces.
2. **Reproduce**: Can you trigger it reliably?
3. **Evidence**:
   - Check recent changes (git diff).
   - Trace data flow (where does bad value originate?).
   - Add logging at component boundaries.

### Phase 2: Pattern Analysis
1. Find similar working code.
2. Compare differences (config, deps, logic).
3. Read reference docs completely.

### Phase 3: Hypothesis
1. Form ONE hypothesis ("I think X because Y").
2. Test it minimally (smallest change).
3. Verify. If wrong, revert and form new hypothesis.

### Phase 4: Implementation
1. **Create Failing Test** (MANDATORY).
2. Implement single fix for root cause.
3. Verify fix (test passes, no regressions).

## Rules
- **Stop at 3**: If 3 fixes fail, STOP. It's an architectural issue. Discuss with user.
- **No Shotgun Debugging**: Do not try multiple fixes at once.
- **Evidence First**: "I think" must be backed by "Log shows X".

> For detailed technique and red flags, see `.claude/docs/references/skills/debugging_full.md`
