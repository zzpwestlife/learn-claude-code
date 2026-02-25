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

# --- Helper Functions for GUI ---

# Usage: gui_choose "Prompt" "Option1" "Option2" ...
# Returns selected option in $SELECTED_OPTION
gui_choose() {
    local prompt="$1"
    shift
    local options=("$@")
    
    # Construct AppleScript list
    local list_str="{"
    for i in "${!options[@]}"; do
        list_str+="\"${options[$i]}\""
        if [ $i -lt $((${#options[@]} - 1)) ]; then
            list_str+=", "
        fi
    done
    list_str+="}"
    
    # Call osascript
    SELECTED_OPTION=$(osascript -e 'try
        tell application "System Events"
            activate
            set result to choose from list '"$list_str"' with prompt "'"$prompt"'" default items {"'"${options[0]}"'"}
            if result is false then
                return ""
            else
                return item 1 of result
            end if
        end tell
    on error
        return ""
    end try' 2>/dev/null)
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
    
    # GUI Mode for macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        cecho "$BLUE" "Where would you like to install FlowState (Go Edition)?"
        gui_choose "Where would you like to install FlowState?" \
            "1) Current Directory ($(pwd))" \
            "2) Specify a different project path"
        
        choice=""
        # Need to escape the parenthesis for regex matching if it's special, but here it's just string matching
        if [[ "$SELECTED_OPTION" == 1\)* ]]; then
            choice="1"
        elif [[ "$SELECTED_OPTION" == 2\)* ]]; then
            choice="2"
        fi
    else
        # CLI Fallback
        echo "  1) Current Directory ($(pwd))"
        echo "  2) Specify a different project path"
        echo ""
        read -p "Your choice [1/2]: " choice
    fi
    
    case "$choice" in
        2)
            user_path=""
            
            # Try macOS native folder selection dialog first
            if [[ "$(uname)" == "Darwin" ]]; then
                cecho "$BLUE" "Opening Finder to select project directory..."
                # Use osascript to show folder selection dialog
                # Redirect stderr to /dev/null to suppress error if user cancels
                selected_path=$(osascript -e 'try
                    tell application "System Events"
                        activate
                        set folderPath to choose folder with prompt "Select Project Directory for FlowState Installation"
                        POSIX path of folderPath
                    end tell
                on error
                    return ""
                end try' 2>/dev/null)
                
                if [ -n "$selected_path" ]; then
                    # Remove trailing slash if present (osascript returns path with trailing slash)
                    user_path=${selected_path%/}
                    cecho "$GREEN" "Selected: $user_path"
                else
                    cecho "$YELLOW" "Selection cancelled or failed. Falling back to manual input."
                fi
            fi

            # Fallback to manual input if no path selected (or not on macOS)
            if [ -z "$user_path" ]; then
                read -e -p "Enter project path: " user_path
            fi
            
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

# --- Helper Functions for GUI ---

# Usage: gui_choose "Prompt" "Option1" "Option2" ...
# Returns selected option in $SELECTED_OPTION
gui_choose() {
    local prompt="$1"
    shift
    local options=("$@")
    
    # Construct AppleScript list
    local list_str="{"
    for i in "${!options[@]}"; do
        list_str+="\"${options[$i]}\""
        if [ $i -lt $((${#options[@]} - 1)) ]; then
            list_str+=", "
        fi
    done
    list_str+="}"
    
    # Call osascript
    SELECTED_OPTION=$(osascript -e 'try
        tell application "System Events"
            activate
            set result to choose from list '"$list_str"' with prompt "'"$prompt"'" default items {"'"${options[0]}"'"}
            if result is false then
                return ""
            else
                return item 1 of result
            end if
        end tell
    on error
        return ""
    end try' 2>/dev/null)
}

# Usage: smart_merge_json src dest
smart_merge_json() {
    local src="$1"
    local dest="$2"
    
    python3 -c "
import sys, json, os

src_path = '$src'
dest_path = '$dest'

try:
    with open(src_path, 'r') as f:
        src_data = json.load(f)
    
    if os.path.exists(dest_path):
        with open(dest_path, 'r') as f:
            dest_data = json.load(f)
    else:
        dest_data = {}

    def deep_update(d, u):
        for k, v in u.items():
            if isinstance(v, dict):
                d[k] = deep_update(d.get(k, {}), v)
            else:
                d[k] = v
        return d
    
    # We want dest to override src
    merged = src_data.copy()
    deep_update(merged, dest_data)
    
    # Write back
    with open(dest_path, 'w') as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)
        
    print('Merged successfully')
except Exception as e:
    print(f'Merge failed: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Usage: smart_merge_text src dest
# Appends lines from src that are NOT present in dest
smart_merge_text() {
    local src="$1"
    local dest="$2"
    
    # Ensure dest exists
    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
        return
    fi
    
    # Append missing lines
    # We use python for safer line handling than pure bash/grep
    python3 -c "
import sys

src_path = '$src'
dest_path = '$dest'

try:
    with open(dest_path, 'r') as f:
        dest_lines = set(line.strip() for line in f)
        
    new_lines = []
    with open(src_path, 'r') as f:
        for line in f:
            if line.strip() and line.strip() not in dest_lines:
                new_lines.append(line)
    
    if new_lines:
        with open(dest_path, 'a') as f:
            f.write('\n# --- FlowState Merged Content ---\n')
            for line in new_lines:
                f.write(line)
        print(f'Appended {len(new_lines)} new lines')
    else:
        print('No new lines to merge')

except Exception as e:
    print(f'Text merge failed: {e}', file=sys.stderr)
    sys.exit(1)
"
}


# Global conflict resolution strategy
# possible values: ask (default), overwrite_all, skip_all, backup_all, merge_all
CONFLICT_STRATEGY="ask"

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
            if [ "$is_dir" = true ]; then
                # For directories, we just copy contents recursively
                # This might need refinement if we want to prompt for every conflicting file inside
                # But typically merging folders is safe-ish.
                # Let's keep simple recursive copy for folders for now, or iterate?
                # Iterating is safer but slower. Let's rely on cp -R for now, or just warn.
                # Actually, safe_install calls itself recursively in the main loop for top-level dirs.
                # If we are here, it means we are copying a directory that was passed directly to safe_install.
                cp -R "$src/"* "$dest/"
                cecho "$GREEN" "  ✅ Merged directory $(basename "$src")"
            else
                # File conflict detection
                if cmp -s "$src" "$dest"; then
                    cecho "$YELLOW" "  ⏭️  Skipping identical: $(basename "$dest")"
                else
                    # CONFLICT DETECTED
                    local action=""
                    
                    if [ "$CONFLICT_STRATEGY" == "overwrite_all" ]; then
                        action="overwrite"
                    elif [ "$CONFLICT_STRATEGY" == "skip_all" ]; then
                        action="skip"
                    elif [ "$CONFLICT_STRATEGY" == "backup_all" ]; then
                        action="backup"
                    elif [ "$CONFLICT_STRATEGY" == "merge_all" ]; then
                        action="merge"
                    else
                        # Interactive Prompt
                        local filename=$(basename "$dest")
                        
                        if [[ "$(uname)" == "Darwin" ]]; then
                            # macOS GUI Prompt
                            gui_choose "Conflict: $filename exists. Choose action:" \
                                "Overwrite" \
                                "Skip" \
                                "Backup & Overwrite" \
                                "Smart Merge (JSON/Text)" \
                                "Diff" \
                                "Overwrite All" \
                                "Skip All" \
                                "Backup All" \
                                "Merge All (JSON/Text)"
                            
                            case "$SELECTED_OPTION" in
                                "Overwrite") action="overwrite" ;;
                                "Skip") action="skip" ;;
                                "Backup & Overwrite") action="backup" ;;
                                "Smart Merge (JSON/Text)") action="merge" ;;
                                "Diff") action="diff" ;;
                                "Overwrite All") CONFLICT_STRATEGY="overwrite_all"; action="overwrite" ;;
                                "Skip All") CONFLICT_STRATEGY="skip_all"; action="skip" ;;
                                "Backup All") CONFLICT_STRATEGY="backup_all"; action="backup" ;;
                                "Merge All (JSON/Text)") CONFLICT_STRATEGY="merge_all"; action="merge" ;;
                                *) action="skip" ;; # Cancel/Empty -> Skip
                            esac
                        else
                            # CLI Prompt (Fallback)
                            echo ""
                            cecho "$RED" "⚠️  Conflict: $filename already exists and differs."
                            echo "  Src: $src"
                            echo "  Dst: $dest"
                            echo "  [o]verwrite, [s]kip, [b]ackup, [m]erge, [d]iff, [A]ll overwrite, [S]kip all, [B]ackup all, [M]erge all"
                            read -p "  Action? [o/s/b/m/d/A/S/B/M]: " choice < /dev/tty
                            
                            case "$choice" in
                                o) action="overwrite" ;;
                                s) action="skip" ;;
                                b) action="backup" ;;
                                m) action="merge" ;;
                                d) action="diff" ;;
                                A) CONFLICT_STRATEGY="overwrite_all"; action="overwrite" ;;
                                S) CONFLICT_STRATEGY="skip_all"; action="skip" ;;
                                B) CONFLICT_STRATEGY="backup_all"; action="backup" ;;
                                M) CONFLICT_STRATEGY="merge_all"; action="merge" ;;
                                *) action="skip" ;; # Default safe
                            esac
                        fi
                        
                        if [ "$action" == "diff" ]; then
                             diff "$dest" "$src" || true
                             echo ""
                             # Recursive call to ask again after diff
                             safe_install "$src" "$dest"
                             return
                        fi
                    fi
                    
                    case "$action" in
                        overwrite)
                            cp "$src" "$dest"
                            cecho "$GREEN" "  ✅ Overwritten: $(basename "$dest")"
                            ;;
                        skip)
                            cecho "$YELLOW" "  ⏭️  Skipped: $(basename "$dest")"
                            ;;
                        backup)
                            backup_file "$dest"
                            cp "$src" "$dest"
                            cecho "$GREEN" "  ✅ Updated (with backup): $(basename "$dest")"
                            ;;
                        merge)
                            if [[ "$dest" == *.json ]]; then
                                cecho "$BLUE" "  🔄 Smart Merging JSON..."
                                smart_merge_json "$src" "$dest"
                                cecho "$GREEN" "  ✅ Merged (JSON): $(basename "$dest")"
                            else
                                # Text Merge Fallback
                                cecho "$BLUE" "  🔄 Smart Merging Text (Appending new lines)..."
                                smart_merge_text "$src" "$dest"
                                cecho "$GREEN" "  ✅ Merged (Text): $(basename "$dest")"
                            fi
                            ;;
                    esac
                fi
            fi
        else
            if [ "$is_dir" = true ]; then
                 cp -R "$src" "$dest"
            else
                 cp "$src" "$dest"
            fi
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
# Explicitly handled to ensure correct placement, though the loop would catch it too.
safe_install ".claude/constitution/constitution.md" "$CLAUDE_ROOT/constitution/constitution.md"

# Agents, Commands, Hooks, Skills (Core)
for dir in agents commands hooks skills constitution; do
    if [ -d ".claude/$dir" ]; then
        for item in ".claude/$dir"/*; do
            [ -e "$item" ] || continue
            # constitution.md is already handled explicitly, skip it to avoid double copy or error
            if [[ "$dir" == "constitution" && "$(basename "$item")" == "constitution.md" ]]; then
                continue
            fi
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
