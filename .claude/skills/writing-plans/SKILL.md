---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

**Goal**: Comprehensive implementation plan assuming zero context.
**Path**: `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Structure
1. **Header**: Goal, Architecture, Tech Stack.
2. **Tasks**: Bite-sized (2-5 mins).
   - Files (Create/Modify/Test)
   - Step 1: Write failing test
   - Step 2: Verify failure
   - Step 3: Minimal implementation
   - Step 4: Verify pass
   - Step 5: Commit

## Handoff (MANDATORY TUI)
Use `AskUserQuestion` to offer:
1. **Execute Plan** (`/execute-plan`)
2. **Review Plan**
3. **Refine Plan**

> For detailed template and examples, see `.claude/docs/references/skills/writing_plans_full.md`
