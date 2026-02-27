---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

**Principle**: Fresh subagent per task + Two-stage review (Spec -> Quality).

## Workflow (Per Task)

1. **Dispatch Implementation**:
   - Use `assets/prompts/implementer-prompt.md`.
   - Provide full task text + context.
   - Wait for implementation, tests, and commit.

2. **Stage 1: Spec Review**:
   - Dispatch `assets/prompts/spec-reviewer-prompt.md`.
   - Check: Does code match spec? No extra features?
   - If issues: Same implementer fixes -> Re-review.

3. **Stage 2: Quality Review**:
   - Dispatch `assets/prompts/code-quality-reviewer-prompt.md`.
   - Check: Code quality, patterns, hygiene.
   - If issues: Same implementer fixes -> Re-review.

4. **Mark Complete**: Update `TodoWrite`.

## Final Steps
- Dispatch Final Reviewer for entire implementation.
- Use `superpowers:finishing-a-development-branch`.

## Rules
- **Fresh Subagent**: Always use a new subagent for each task (prevents context pollution).
- **No Skipping**: Spec Review AND Quality Review are mandatory.
- **Fix Loop**: Reviewer finds issue -> Implementer fixes -> Reviewer checks again.
- **Questions**: If subagent asks, answer clearly before they proceed.

> For detailed workflow diagrams and examples, see `.claude/docs/references/skills/subagent_full.md`
