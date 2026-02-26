#!/bin/bash

# Archive Task Script
# Moves current planning files to archive directory to clean up workspace.

# 1. Define Archive Directory
ARCHIVE_ROOT=".claude/archive/plans"
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")

# 2. Check if files exist
if [ ! -f "task_plan.md" ]; then
    echo "❌ No task_plan.md found in current directory."
    exit 1
fi

# 3. Extract Task Name (optional, from first line of task_plan.md)
# Assuming format "# Task: My Task Name" or similar
TASK_NAME=$(head -n 1 task_plan.md | sed 's/[# ]//g' | cut -c 1-20)
if [ -z "$TASK_NAME" ]; then
    TASK_NAME="Untitled"
fi

# 4. Create Archive Path
ARCHIVE_DIR="$ARCHIVE_ROOT/$TIMESTAMP-$TASK_NAME"
mkdir -p "$ARCHIVE_DIR"

# 5. Move Files
echo "📦 Archiving task to: $ARCHIVE_DIR"

if [ -f "task_plan.md" ]; then
    mv "task_plan.md" "$ARCHIVE_DIR/"
    echo "  - Moved task_plan.md"
fi

if [ -f "findings.md" ]; then
    mv "findings.md" "$ARCHIVE_DIR/"
    echo "  - Moved findings.md"
fi

if [ -f "progress.md" ]; then
    mv "progress.md" "$ARCHIVE_DIR/"
    echo "  - Moved progress.md"
fi

# 6. Success Message
echo "✅ Task archived successfully!"
echo "Workspace is clean. You can now start a new task."
