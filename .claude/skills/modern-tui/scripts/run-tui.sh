#!/bin/bash
# Wrapper to run the modern TUI python script with the correct environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
TUI_SCRIPT="$SCRIPT_DIR/tui.py"

# Try to find python with rich/questionary installed
PYTHON_CMD="python3"

# Check for local venv in project root
if [ -d "$PROJECT_ROOT/venv" ]; then
    source "$PROJECT_ROOT/venv/bin/activate"
    PYTHON_CMD="python"
elif [ -d "$PROJECT_ROOT/.venv" ]; then
    source "$PROJECT_ROOT/.venv/bin/activate"
    PYTHON_CMD="python"
fi

# Run the TUI script
"$PYTHON_CMD" "$TUI_SCRIPT" "$@"
