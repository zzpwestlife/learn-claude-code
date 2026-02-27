---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

**Core Principle**: Review early, review often.

## When to Request
1. **Mandatory**:
   - After each task in Subagent-Driven Development.
   - After completing major feature.
   - Before merge to main.
2. **Optional**: When stuck or before refactoring.

## How to Request
1. **Get SHAs**:
   ```bash
   BASE_SHA=$(git rev-parse HEAD~1)
   HEAD_SHA=$(git rev-parse HEAD)
   ```
2. **Dispatch Agent**:
   - Use `code-reviewer` agent.
   - Fill template: `{WHAT}`, `{PLAN}`, `{BASE_SHA}`, `{HEAD_SHA}`.
3. **Act**:
   - **Critical**: Fix immediately.
   - **Important**: Fix before proceeding.
   - **Minor**: Note for later.

> For detailed examples and red flags, see `.claude/docs/references/skills/requesting_code_review_full.md`
