#!/bin/bash
# Check if all phases in task_plan.md are complete
# Always exits 0 — uses stdout for status reporting
# Used by PostToolUse hook to report task completion status

PLAN_FILE="${1:-task_plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[planning-with-files] No task_plan.md found — no active planning session."
    exit 0
fi

# 1. Check Global Status first (Absolute Priority)
# Matches "**Status:** complete", "**Status:** ✅ COMPLETED", "**Status:** [x] Complete", etc.
if grep -iE "\*\*Status:\*\*.*complete" "$PLAN_FILE" >/dev/null; then
    echo "[planning-with-files] ALL PHASES COMPLETE (Global Status)"
    exit 0
fi

# 2. Count total phases dynamically
TOTAL=$(grep -c "### Phase" "$PLAN_FILE" || true)

# If no phases defined and no global status, assume nothing to do
if [ "$TOTAL" -eq 0 ]; then
     echo "[planning-with-files] No phases defined."
     exit 0
fi

# 3. Count completed phases (looking for [complete] or [x])
# Adjust regex to match standard task_plan.md formats
COMPLETE_TAG=$(grep -ic "\[complete\]" "$PLAN_FILE" || true)
COMPLETE_CHECKBOX=$(grep -ic "\[x\]" "$PLAN_FILE" || true)

# Note: We do NOT sum Status here because it's handled in step 1.
# We sum tags and checkboxes, assuming they are used to mark phases.
# Be careful not to double count if someone uses both on the same line (unlikely).
COMPLETE=$((COMPLETE_TAG + COMPLETE_CHECKBOX))

# Report status
if [ "$COMPLETE" -ge "$TOTAL" ]; then
    echo "[planning-with-files] ALL PHASES COMPLETE ($COMPLETE/$TOTAL)"
else
    echo "[planning-with-files] Task in progress ($COMPLETE/$TOTAL phases complete)"
    IN_PROGRESS=$(grep -ic "\[in_progress\]" "$PLAN_FILE" || true)
    
    if [ "$IN_PROGRESS" -gt 0 ]; then
        echo "[planning-with-files] $IN_PROGRESS phase(s) still in progress."
    fi
fi
exit 0
