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
   - **IMMEDIATELY** generate the BDD plan file `docs/plans/YYYY-MM-DD-<feature-name>.md`.
   - **AND** generate the State Tracking File `docs/plans/YYYY-MM-DD-<feature-name>-state.local.md` (Refer to `.claude/docs/guides/agent_bdd_loop.md` for format).
   - **Do NOT wait** or ask for confirmation to write the plan (loading this skill IS confirmation).
   - Only use `AskUserQuestion` if the design is critically missing or unintelligible.
2. **Header**: Goal, Architecture, Tech Stack, BDD Scenarios.
3. **Tasks (Red-Green Loop)**: Bite-sized (2-5 mins) tracked in the `.local.md` file.
   - Files (Create/Modify/Test)
   - Step 1: [Red] Write failing BDD test
   - Step 2: Verify failure
   - Step 3: [Green] Minimal implementation
   - Step 4: Verify pass
   - Step 5: Commit

## Transition (CRITICAL TOOL CALL REQUIRED)
**STOP**: Do NOT auto-execute the plan. Do NOT just print "Plan created".
You **MUST ACTUALLY EXECUTE** the `AskUserQuestion` tool before ending your turn.
- Set `question`: "Implementation plan and BDD State file created. What's next?"
- Set `options`:
  1. `label`: "Execute Plan", `description`: "Proceed to execution (Invoke executing-plans)"
  2. `label`: "Review Plan", `description`: "I want to review/annotate the plan file"
  3. `label`: "Refine Plan", `description`: "Let's discuss changes"

## Rules
- **TUI First**: NEVER start execution without explicit user approval via `AskUserQuestion`.

> For detailed template and examples, see `.claude/docs/references/skills/writing_plans_full.md`
