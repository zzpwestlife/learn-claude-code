---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

**Goal**: Comprehensive implementation plan assuming zero context.
**Path**: `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Structure
1. **Pre-flight Check**:
   - Confirm understanding of the Design.
   - If ambiguous, use `AskUserQuestion` to clarify BEFORE planning.
2. **Header**: Goal, Architecture, Tech Stack.
3. **Tasks**: Bite-sized (2-5 mins).
   - Files (Create/Modify/Test)
   - Step 1: Write failing test
   - Step 2: Verify failure
   - Step 3: Minimal implementation
   - Step 4: Verify pass
   - Step 5: Commit

## Handoff (MANDATORY TUI)
Point the user to the generated plan file (`docs/plans/...`) and ask them to **Annotate** it directly.

Use `AskUserQuestion` to offer:
1. **Execute Plan** (Only if annotated/approved)
2. **Review Plan** (I will read your annotations)
3. **Refine Plan** (Interactive mode)

> For detailed template and examples, see `.claude/docs/references/skills/writing_plans_full.md`
