---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

**Goal**: Comprehensive implementation plan assuming zero context.
**Path**: `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Structure
1. **Analyze & Create (AUTO-START)**:
   - Read the design document.
   - **IMMEDIATELY** generate the plan file `docs/plans/YYYY-MM-DD-<feature-name>.md`.
   - **Do NOT wait** or ask for confirmation to write the plan (loading this skill IS confirmation).
   - Only use `AskUserQuestion` if the design is critically missing or unintelligible.
2. **Header**: Goal, Architecture, Tech Stack.
3. **Tasks**: Bite-sized (2-5 mins).
   - Files (Create/Modify/Test)
   - Step 1: Write failing test
   - Step 2: Verify failure
   - Step 3: Minimal implementation
   - Step 4: Verify pass
   - Step 5: Commit

## Transition (MANDATORY TUI)
**STOP**: Do NOT auto-execute the plan.
Use `AskUserQuestion` to ask "What's next?":
1. **Execute Plan**: "Proceed to execution (Invoke executing-plans)"
2. **Review Plan**: "I want to review/annotate the plan file"
3. **Refine Plan**: "Let's discuss changes"

## Rules
- **TUI First**: NEVER start execution without explicit user approval via `AskUserQuestion`.

> For detailed template and examples, see `.claude/docs/references/skills/writing_plans_full.md`
