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

## The Process

### Step 1: Load Plan & State
1. Read the main `docs/plans/*.md` file.
2. **CRITICAL**: Locate and read the corresponding `docs/plans/*-state.local.md` tracking file.
3. Review critically - identify any questions or concerns about the plan.
4. If concerns: Raise them with your human partner before starting.
5. If no concerns: Create TodoWrite and proceed.

### Step 2: Execute via Red-Green Loop
Find the first uncompleted, unblocked task in the `.local.md` state file.
- If it's a **[Red]** task: Write the failing test FIRST. Run it. Verify it FAILS. Update state to `[x]`.
- If it's a **[Green]** task: Implement the minimal code to pass the test. Run it. Verify it PASSES. Update state to `[x]`.
- Follow each step exactly (plan has bite-sized steps).
- Run verifications as specified.

### Step 3: Report (MANDATORY TUI)
After each logical chunk or when blocked.
Use `AskUserQuestion` to ask:
- **Continue**: Execute next task in `.local.md`.
- **Review Code**: Pause for manual review.
- **Pause**: Stop execution.

### Step 4: Complete Development
After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch

## When to Stop and Ask for Help
**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## Rules
- **Stop on Blocker**: Don't guess. Ask.
- **Strict Adherence**: Follow plan steps exactly.
- **Verification**: Never skip verification steps.
- **TUI Handoff**: Always return control to user after a batch.
- **Never start implementation on main/master branch** without explicit user consent.

## Integration
**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
