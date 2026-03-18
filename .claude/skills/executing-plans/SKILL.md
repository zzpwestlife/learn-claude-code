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

**Core Principle**: Batch execution -> Checkpoints -> Review.

## Process
1. **Load Plan**: Read file. Review critically.
2. **Execute Batch**:
   - Default: 3 tasks.
   - Follow steps exactly.
   - Verify each task.
3. **Report (MANDATORY TUI)**:
   - After each batch (3 tasks) or when blocked.
   - Use `AskUserQuestion` to ask:
     - **Continue**: Execute next batch.
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
