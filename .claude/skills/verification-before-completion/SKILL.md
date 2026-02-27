---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs
---

# Verification Before Completion

**The Iron Law**: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

## The Gate Function
1. **Identify**: What command proves this claim?
2. **Run**: Execute full command (fresh).
3. **Read**: Check output, exit code, failure count.
4. **Verify**: Does output confirm claim?
5. **Claim**: Only then state success with evidence.

## Common Failures
- ❌ "Should pass" (Guessing)
- ❌ "Linter clean" (Not a compiler/test check)
- ❌ "Agent says success" (Trusting without verifying)
- ✅ Run test -> See 0 failures -> "Tests pass"

## When to Apply
- Before saying "Done", "Fixed", "Complete".
- Before committing or creating PR.
- Before moving to next task.

> For detailed examples and red flags, see `.claude/docs/references/skills/verification_full.md`
