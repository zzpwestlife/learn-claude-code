---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

## The Iron Law
**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**
If you wrote code before the test, delete it and start over.

## Process: Red-Green-Refactor

### 1. RED - Write Failing Test
- **Action**: Write one minimal test for the missing feature/bug.
- **Rules**:
  - One behavior per test.
  - Real code (avoid mocks unless unavoidable).
  - Clear test name.
- **Verify**: Run test. Must fail (not error).
  - `npm test path/to/test` (or equivalent)

### 2. GREEN - Minimal Code
- **Action**: Write simplest code to pass the test.
- **Rules**:
  - Do NOT add unrequested features (YAGNI).
  - Do NOT refactor yet.
- **Verify**: Run test. Must pass.
  - All other tests must also pass.

### 3. REFACTOR - Clean Up
- **Action**: Clean up code while keeping tests green.
- **Rules**:
  - Remove duplication.
  - Improve naming.
  - Extract helpers.
- **Verify**: Run all tests.

## Environment Constraints
If local environment lacks test runner:
1. **Red**: Verify missing module via interpreter (e.g., `python -c "import mod"`).
2. **Test File**: Write standard test file (for CI).
3. **Green**: Use one-liner script to verify logic.
4. **Refactor**: Clean up.

## Verification Checklist
- [ ] Watched test fail before implementing?
- [ ] Failed for the right reason (feature missing)?
- [ ] Wrote minimal code to pass?
- [ ] All tests pass now?
- [ ] No errors/warnings?

> For detailed tutorial and anti-patterns, see `.claude/docs/references/skills/tdd_full.md`
