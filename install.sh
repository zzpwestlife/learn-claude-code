#!/bin/bash
set -e

# ==========================================
# FlowState (Go Edition) Installer
# ==========================================

PLUGIN_NAME="FlowState (Go)"
DEFAULT_PROFILE="go"

# Colors
if command -v tput >/dev/null 2>&1; then
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    NC=$(tput sgr0)
else
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
fi

cecho() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# --- Arguments Parsing ---
DEV_MODE=false
TARGET_DIR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dev) DEV_MODE=true ;;
        -*) echo "Unknown parameter passed: $1"; exit 1 ;;
        *) TARGET_DIR="$1" ;;
    esac
    shift
done

# --- Target Selection ---
if [ -z "$TARGET_DIR" ]; then
    cecho "$BLUE" "Where would you like to install FlowState (Go Edition)?"
    echo "  1) Current Directory ($(pwd))"
    echo "  2) Specify a different project path"
    echo ""
    read -p "Your choice [1/2]: " choice
    
    case "$choice" in
        2)
            read -e -p "Enter project path: " user_path
            # Resolve absolute path
            if [[ "$user_path" != /* ]]; then
                TARGET_DIR="$(pwd)/$user_path"
            else
                TARGET_DIR="$user_path"
            fi
            ;;
        *)
            TARGET_DIR="$(pwd)"
            ;;
    esac
fi

if [ ! -d "$TARGET_DIR" ]; then
    cecho "$RED" "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

CLAUDE_ROOT="$TARGET_DIR/.claude"
cecho "$GREEN" "Target set to: $TARGET_DIR"
if [ "$DEV_MODE" = true ]; then
    cecho "$YELLOW" "Running in DEV MODE (Symlinks enabled)"
fi

# --- Helper Functions ---

ensure_dir() {
    mkdir -p "$1"
}

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        cecho "$YELLOW" "  ⚠️  Backed up: $(basename "$file")"
    fi
}

safe_install() {
    local src="$1"
    local dest="$2"
    local is_dir=false
    
    if [ -d "$src" ]; then is_dir=true; fi

    # Create parent dir
    mkdir -p "$(dirname "$dest")"

    if [ "$DEV_MODE" = true ]; then
        # Symlink logic
        if [ -L "$dest" ]; then
            rm "$dest"
        elif [ -e "$dest" ]; then
             backup_file "$dest"
             rm -rf "$dest"
        fi
        ln -s "$(realpath "$src")" "$dest"
        cecho "$GREEN" "  🔗 Symlinked $(basename "$src")"
    else
        # Copy logic
        if [ -L "$dest" ]; then
            rm "$dest" # Replace symlink with real file
        fi
        
        if [ -e "$dest" ]; then
            # If directory, merge (recursive copy)
            # If file, backup and replace
            if [ "$is_dir" = true ]; then
                cp -R "$src/"* "$dest/"
                cecho "$GREEN" "  ✅ Merged directory $(basename "$src")"
            else
                if cmp -s "$src" "$dest"; then
                    cecho "$YELLOW" "  ⏭️  Skipping identical: $(basename "$dest")"
                else
                    backup_file "$dest"
                    cp "$src" "$dest"
                    cecho "$GREEN" "  ✅ Installed $(basename "$src")"
                fi
            fi
        else
            cp -R "$src" "$dest"
            cecho "$GREEN" "  ✅ Installed $(basename "$src")"
        fi
    fi
}

# --- Installation Steps ---

cecho "$BLUE" "🚀 Installing Core Components..."

# 1. Install .claude/ contents
ensure_dir "$CLAUDE_ROOT"
ensure_dir "$CLAUDE_ROOT/agents"
ensure_dir "$CLAUDE_ROOT/commands"
ensure_dir "$CLAUDE_ROOT/hooks"
ensure_dir "$CLAUDE_ROOT/skills"
ensure_dir "$CLAUDE_ROOT/constitution"

# Core Constitution
safe_install ".claude/constitution.md" "$CLAUDE_ROOT/constitution.md"

# Agents, Commands, Hooks, Skills (Core)
for dir in agents commands hooks skills constitution; do
    if [ -d ".claude/$dir" ]; then
        for item in ".claude/$dir"/*; do
            safe_install "$item" "$CLAUDE_ROOT/$dir/$(basename "$item")"
        done
    fi
done

# 2. Install Go Profile
echo ""
cecho "$BLUE" "📦 Installing Go Development Profile..."
# Default to Yes for this specialized installer
# But let's prompt just in case, or check for go.mod?
# Assuming user wants it since they are using this repo.

PROFILE_DIR="profiles/go"

# Install .claude overlay from profile
if [ -d "$PROFILE_DIR/.claude" ]; then
    for dir in "$PROFILE_DIR/.claude"/*; do
        dirname=$(basename "$dir")
        # Handle files at .claude root (like AGENTS.md)
        if [ -f "$dir" ]; then
             safe_install "$dir" "$CLAUDE_ROOT/$dirname"
        elif [ -d "$dir" ]; then
             ensure_dir "$CLAUDE_ROOT/$dirname"
             for item in "$dir"/*; do
                 safe_install "$item" "$CLAUDE_ROOT/$dirname/$(basename "$item")"
             done
        fi
    done
fi

# Install Root Files from Profile (CLAUDE.md, Makefile)
safe_install "$PROFILE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
safe_install "$PROFILE_DIR/Makefile" "$TARGET_DIR/Makefile"

# 3. Permissions
cecho "$BLUE" "🔒 Setting permissions..."
find "$CLAUDE_ROOT/hooks" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$CLAUDE_ROOT/skills" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
find "$CLAUDE_ROOT/skills" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo ""
cecho "$GREEN" "✅ Installation Complete!"
echo "----------------------------------------"
echo "Project: $TARGET_DIR"
echo "Mode:    $( [ "$DEV_MODE" = true ] && echo "Development (Symlinks)" || echo "Production (Copies)" )"
echo "Profile: Go"
echo "----------------------------------------"
echo "To get started:"
echo "1. cd $TARGET_DIR"
echo "2. Run: /optimize-prompt (to test the workflow)"
