---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
hooks:
  PostToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: |
            SCRIPT_DIR=".claude/scripts"
            OUTPUT=$(sh "$SCRIPT_DIR/check-complete.sh" 2>/dev/null)
            if echo "$OUTPUT" | grep -q "ALL TASKS COMPLETE"; then
              echo "<system-reminder>✅ ALL TASKS COMPLETE. Use 'AskUserQuestion' to ask: 'Review Code?' (Yes/No). If Yes -> /review-code.</system-reminder>"
            elif [ -n "$OUTPUT" ]; then
               mkdir -p .claude/tmp
               echo "Status Updated: [View Status]($CLAUDE_PROJECT_DIR/.claude/tmp/planning_status.md)"
            fi
---

# Executing Plans

**Core Principle**: State-Driven Execution -> Red-Green Loop -> Review.

## Process
1. **Load Plan & State**: 
   - Read the main `docs/plans/*.md` file.
   - **CRITICAL**: Locate and read the corresponding `docs/plans/*-state.local.md` tracking file.
2. **Execute via Red-Green Loop**:
   - Find the first uncompleted, unblocked task in the `.local.md` state file.
   - If it's a **[Red]** task: Write the failing test FIRST. Run it. Verify it FAILS. Update state to `[x]`.
   - If it's a **[Green]** task: Implement the minimal code to pass the test. Run it. Verify it PASSES. Update state to `[x]`.
3. **Report (MANDATORY TUI)**:
   - After each logical chunk or when blocked.
   - Use `AskUserQuestion` to ask:
     - **Continue**: Execute next task in `.local.md`.
     - **Review Code**: Pause for manual review.
     - **Pause**: Stop execution.
4. **Complete**:
   - If ALL tasks done: Ask user to invoke `finishing-a-development-branch`.

## Rules
- **Stop on Blocker**: Don't guess. Ask.
- **Strict Adherence**: Follow plan steps exactly.
- **Verification**: Never skip verification steps.
- **TUI Handoff**: Always return control to user after a batch.

> For detailed workflow diagrams, see `.claude/docs/references/skills/executing_plans_full.md`
