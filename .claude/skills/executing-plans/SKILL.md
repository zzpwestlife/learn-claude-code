---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
hooks:
  PostToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: |
            SCRIPT_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/scripts"
            # Find the latest plan file in docs/plans/
            LATEST_PLAN=$(ls -t docs/plans/*.md 2>/dev/null | head -n 1)
            
            if [ -n "$LATEST_PLAN" ]; then
              OUTPUT=$(sh "$SCRIPT_DIR/check-complete.sh" "$LATEST_PLAN" 2>/dev/null)
              
              # Concise output: only show status if changed or complete
              if echo "$OUTPUT" | grep -q "ALL PHASES COMPLETE"; then
                echo ""
                echo "<system-reminder>"
                echo "✅ SYSTEM NOTICE: All tasks in $LATEST_PLAN are complete."
                echo "👉 ACTION REQUIRED: You MUST now use 'AskUserQuestion' to prompt the user:"
                echo "  '所有计划任务已执行完成！是否进行代码审查？'"
                echo "  Options: ['Yes', 'No']"
                echo "  If Yes: Use RunCommand tool to execute '/review-code'."
                echo "</system-reminder>"
              elif [ -n "$OUTPUT" ]; then
                 # Write detailed status to a temp file to keep chat clean
                 mkdir -p .claude/tmp
                 echo "$OUTPUT" > .claude/tmp/planning_status.md
                 echo "Planning Status Updated: [View Status](file:///Users/admin/openSource/learn-claude-code/.claude/tmp/planning_status.md)"
              fi
            fi
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
