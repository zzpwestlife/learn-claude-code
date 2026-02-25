#!/bin/bash

# Learn Claude Code Installation Script (Cross-Platform Enhanced)
# Usage: ./install.sh [Target Project Path]

set -e

# ==========================================
# 0. Global Configuration & Logging
# ==========================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

LOG_FILE="install_claude_code.log"
touch "$LOG_FILE"

log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    # Strip color codes for log file
    local clean_msg=$(echo -e "$msg" | sed 's/\x1b\[[0-9;]*m//g')
    echo "[$timestamp] [$level] $clean_msg" >> "$LOG_FILE"
    
    # Print to console with color
    case "$level" in
        "INFO") echo -e "${BLUE}[INFO]${NC} $msg" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $msg" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $msg" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $msg" ;;
        *) echo -e "$msg" ;;
    esac
}

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR=""
BACKUP_DIR=""
OS_TYPE=""
NEW_IGNORE_ENTRIES=()
IGNORE_CLAUDE_DIR="false"
IGNORE_SPECS_DIR="false"

# ==========================================
# 1. OS Detection & Tool Abstraction
# ==========================================

detect_os() {
    log "INFO" "Detecting Operating System..."
    local uname_out="$(uname -s)"
    case "${uname_out}" in
        Linux*)     OS_TYPE="Linux";;
        Darwin*)    OS_TYPE="macOS";;
        CYGWIN*)    OS_TYPE="Windows";;
        MINGW*)     OS_TYPE="Windows";;
        MSYS*)      OS_TYPE="Windows";;
        *)          OS_TYPE="Unknown";;
    esac
    log "INFO" "Detected OS: $OS_TYPE"
}

check_tools() {
    log "INFO" "Checking required tools..."
    
    # Check for basic tools
    for tool in git curl; do
        if ! command -v "$tool" &> /dev/null; then
            log "ERROR" "Required tool '$tool' not found. Please install it first."
            exit 1
        fi
    done

    # Configure sed based on OS
    if [[ "$OS_TYPE" == "macOS" ]]; then
        # macOS sed requires empty string for inplace backup
        run_sed_i() { sed -i '' "$@"; }
    else
        # GNU sed (Linux) - assumes standard GNU sed behavior
        run_sed_i() { sed -i "$@"; }
    fi
    
    # Verify sed works
    local test_file=$(mktemp)
    echo "foo" > "$test_file"
    if run_sed_i 's/foo/bar/' "$test_file" 2>/dev/null && grep -q "bar" "$test_file"; then
        log "INFO" "sed configured successfully."
    else
        log "ERROR" "sed configuration failed. Please check your sed version."
        rm "$test_file"
        exit 1
    fi
    rm "$test_file"
}

# ==========================================
# 2. Backup & Rollback
# ==========================================

init_backup() {
    if [ -z "$TARGET_DIR" ]; then return; fi
    ensure_dir "$TARGET_DIR/.claude"
    BACKUP_DIR="$TARGET_DIR/.claude/.install_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    log "INFO" "Backup directory initialized at: $BACKUP_DIR"
}

backup_file() {
    local dest_file="$1"
    if [ -f "$dest_file" ]; then
        # Create relative path structure in backup dir
        local rel_path="${dest_file#$TARGET_DIR/}"
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        cp "$dest_file" "$backup_path"
        # log "INFO" "Backed up: $rel_path"
    fi
}

rollback() {
    # Only rollback if we have a backup dir and it's not empty
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log "WARN" "Installation failed or interrupted. Initiating rollback..."
        
        # Check if there are files to restore
        if [ "$(ls -A "$BACKUP_DIR")" ]; then
            cp -R "$BACKUP_DIR/"* "$TARGET_DIR/" 2>/dev/null || true
            log "INFO" "Rollback completed. Restored files from backup."
        else
            log "INFO" "No files modified, skipping rollback."
        fi
    fi
}

# Setup error trap for rollback
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Script exited with error code $exit_code"
        rollback
    fi
    # Optional: cleanup backup dir on success? Maybe keep it for manual inspection.
    if [ $exit_code -eq 0 ]; then
        log "INFO" "Installation successful."
    fi
}
trap cleanup EXIT

# ==========================================
# 3. Helper Functions
# ==========================================

add_ignore_entry() {
    local entry="$1"
    if [ -n "$entry" ]; then
        NEW_IGNORE_ENTRIES+=("$entry")
    fi
}

ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        local rel_path="${dir#$TARGET_DIR/}"
        if [ "$rel_path" != "$dir" ]; then
            if [ "${rel_path: -1}" != "/" ]; then
                rel_path="$rel_path/"
            fi
            add_ignore_entry "$rel_path"
            if [ "$rel_path" == ".claude/" ]; then IGNORE_CLAUDE_DIR="true"; fi
            if [ "$rel_path" == "specs/" ]; then IGNORE_SPECS_DIR="true"; fi
        fi
    fi
}

ensure_gitignore() {
    local gitignore="$TARGET_DIR/.gitignore"
    if [ ! -f "$gitignore" ]; then
        touch "$gitignore"
    fi

    for entry in "${NEW_IGNORE_ENTRIES[@]}"; do
        if [ -n "$entry" ] && ! grep -Fqx "$entry" "$gitignore"; then
            printf "\n%s\n" "$entry" >> "$gitignore"
        fi
    done
}

# Safe Copy with Backup and Merge logic
safe_copy() {
    local src="$1"
    local dest="$2"
    local dest_file
    
    if [ ! -e "$src" ]; then
        log "WARN" "Source file not found: $src"
        return
    fi
    
    # Calculate destination file path
    if [ -d "$dest" ]; then
        dest_file="$dest/$(basename "$src")"
    else
        dest_file="$dest"
    fi
    
    mkdir -p "$(dirname "$dest_file")"
    
    if [ -f "$dest_file" ]; then
        # Check if identical
        if cmp -s "$src" "$dest_file"; then
            log "INFO" "Skipped (Identical): $(basename "$dest_file")"
            return
        fi

        # Backup existing file before any modification
        backup_file "$dest_file"

        log "WARN" "Target file exists: $(basename "$dest_file")"
        
        # Special handling for Makefile
        if [[ "$(basename "$dest_file")" == "Makefile" ]]; then
            handle_makefile_conflict "$src" "$dest_file"
            return
        fi

        # General file conflict
        local should_overwrite="false"
        
        # Interactive prompt (GUI or CLI)
        if [[ "$OS_TYPE" == "macOS" ]] && command -v osascript >/dev/null 2>&1; then
            BTN_CLICKED=$(osascript -e 'try
                display dialog "文件已存在: '"$(basename "$dest_file")"'\n\n是否覆盖？" buttons {"跳过", "覆盖"} default button "跳过" with icon caution
                return button returned of result
            on error
                return "跳过"
            end try' 2>/dev/null)
            
            if [ "$BTN_CLICKED" == "覆盖" ]; then should_overwrite="true"; fi
        else
            echo -e "${YELLOW}File $(basename "$dest_file") exists. Overwrite? (y/N)${NC}"
            read -r USER_RESP
            if [[ "$USER_RESP" =~ ^[Yy]$ ]]; then should_overwrite="true"; fi
        fi
        
        if [ "$should_overwrite" == "true" ]; then
            cp -v "$src" "$dest_file"
            log "INFO" "Overwritten: $(basename "$dest_file")"
        else
            log "INFO" "Skipped: $(basename "$dest_file")"
        fi
    else
        # File doesn't exist, just copy
        cp -v "$src" "$dest_file"
        local rel_path="${dest_file#$TARGET_DIR/}"
        if [ "$rel_path" != "$dest_file" ]; then
            if [[ "$IGNORE_CLAUDE_DIR" == "true" && "$dest_file" == "$TARGET_DIR/.claude/"* ]]; then
                :
            elif [[ "$IGNORE_SPECS_DIR" == "true" && "$dest_file" == "$TARGET_DIR/specs/"* ]]; then
                :
            else
                add_ignore_entry "$rel_path"
            fi
        fi
    fi
}

handle_makefile_conflict() {
    local src="$1"
    local dest_file="$2"
    local action="skip"
    
    # Prompt logic
    if [[ "$OS_TYPE" == "macOS" ]] && command -v osascript >/dev/null 2>&1; then
        BTN_CLICKED=$(osascript -e 'try
            display dialog "Makefile 已存在: '"$(basename "$dest_file")"'\n\n请选择操作：" buttons {"跳过", "覆盖", "智能合并"} default button "智能合并" with icon caution
            return button returned of result
        on error
            return "跳过"
        end try' 2>/dev/null)
        
        if [ "$BTN_CLICKED" == "覆盖" ]; then action="overwrite";
        elif [ "$BTN_CLICKED" == "智能合并" ]; then action="merge"; fi
    else
        echo -e "${YELLOW}Makefile exists. Choose: [s]Skip / [o]Overwrite / [m]Merge (Default: m)${NC}"
        read -r USER_RESP
        if [[ "$USER_RESP" =~ ^[Oo]$ ]]; then action="overwrite";
        elif [[ "$USER_RESP" =~ ^[Ss]$ ]]; then action="skip";
        else action="merge"; fi
    fi
    
    if [ "$action" == "overwrite" ]; then
        cp -v "$src" "$dest_file"
        log "INFO" "Makefile overwritten."
    elif [ "$action" == "merge" ]; then
        log "INFO" "Attempting smart merge for Makefile..."
        if command -v python3 >/dev/null 2>&1; then
            python3 "$SOURCE_DIR/scripts/merge_makefile.py" "$src" "$dest_file"
            log "SUCCESS" "Makefile merged."
        else
            log "ERROR" "python3 not found, cannot merge. Skipping."
        fi
    else
        log "INFO" "Makefile skipped."
    fi
}

# ==========================================
# 4. Main Execution
# ==========================================

log "INFO" "🚀 Learn Claude Code Integration Wizard"

detect_os
check_tools

# --- Target Directory Selection ---
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    if [[ "$OS_TYPE" == "macOS" ]] && command -v osascript >/dev/null 2>&1; then
        echo "Launching folder selection dialog..."
        TARGET_DIR=$(osascript -e 'try
            POSIX path of (choose folder with prompt "🚀 Learn Claude Code Setup\n\nSelect target project root:")
        on error
            return ""
        end try' 2>/dev/null)
    fi
    
    if [ -z "$TARGET_DIR" ]; then
        echo -e "${YELLOW}Please enter target project absolute path:${NC}"
        read -r TARGET_DIR
    fi
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    log "ERROR" "Directory '$TARGET_DIR' does not exist or invalid."
    exit 1
fi

TARGET_DIR="${TARGET_DIR%/}"
log "SUCCESS" "Target Project: $TARGET_DIR"

# Initialize Backup after Target is known
init_backup

# --- Language Selection ---
LANG_CHOICE=""
DETECTED_LANG=""

if [ -f "$TARGET_DIR/go.mod" ]; then DETECTED_LANG="Go";
elif [ -f "$TARGET_DIR/composer.json" ]; then DETECTED_LANG="PHP";
elif [ -f "$TARGET_DIR/requirements.txt" ] || [ -f "$TARGET_DIR/pyproject.toml" ]; then DETECTED_LANG="Python";
fi

if [ -n "$DETECTED_LANG" ]; then
    log "INFO" "Detected language: $DETECTED_LANG"
fi

if [[ "$OS_TYPE" == "macOS" ]] && command -v osascript >/dev/null 2>&1; then
    LANG_CHOICE=$(osascript -e 'try
        choose from list {"Go", "PHP", "Python"} with prompt "Select Project Language:" default items {"'"${DETECTED_LANG:-Go}"'"} OK button name "OK" cancel button name "Cancel"
    on error
        return "Cancel"
    end try' 2>/dev/null)
    
    if [ "$LANG_CHOICE" == "false" ] || [ "$LANG_CHOICE" == "Cancel" ]; then
        log "WARN" "Operation cancelled by user."
        exit 0
    fi
else
    echo -e "Select Language (Go/PHP/Python) [Default: ${DETECTED_LANG:-Go}]:"
    read -r USER_INPUT
    LANG_CHOICE="${USER_INPUT:-${DETECTED_LANG:-Go}}"
fi

# Normalize Language
if [[ "$LANG_CHOICE" =~ ^[Gg][Oo]$ ]]; then PROFILE="go"; LANG_NAME="Go";
elif [[ "$LANG_CHOICE" =~ ^[Pp][Hh][Pp]$ ]]; then PROFILE="php"; LANG_NAME="PHP";
elif [[ "$LANG_CHOICE" =~ ^[Pp][Yy][Tt][Hh][Oo][Nn]$ ]]; then PROFILE="python"; LANG_NAME="Python";
else
    log "ERROR" "Unsupported language: $LANG_CHOICE"
    exit 1
fi

log "INFO" "Selected Profile: $LANG_NAME"

# ==========================================
# 5. Installation Steps
# ==========================================

log "INFO" "Installing core files..."

# 0. Ensure base dir
ensure_dir "$TARGET_DIR/.claude"

# 1. Copy Constitution
safe_copy "$SOURCE_DIR/.claude/constitution.md" "$TARGET_DIR/.claude/"

# 1.1 Specs dir
if [ ! -d "$TARGET_DIR/specs" ]; then
    ensure_dir "$TARGET_DIR/specs"
    log "INFO" "Created specs/ directory"
fi

# 1.2 Settings
if [ -f "$SOURCE_DIR/.claude/settings.json" ]; then
    safe_copy "$SOURCE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"
fi

# 2. Copy Language Configs
log "INFO" "Installing $LANG_NAME configurations..."
safe_copy "$SOURCE_DIR/profiles/$PROFILE/CLAUDE.md" "$TARGET_DIR/"
safe_copy "$SOURCE_DIR/profiles/$PROFILE/AGENTS.md" "$TARGET_DIR/"

# 3. Copy Agents
log "INFO" "Copying Agents..."
ensure_dir "$TARGET_DIR/.claude/agents"
for file in "$SOURCE_DIR/.claude/agents/"*; do
    if [ -f "$file" ]; then safe_copy "$file" "$TARGET_DIR/.claude/agents/"; fi
done

if [ -f "$SOURCE_DIR/.claude/settings.local.json" ]; then
    safe_copy "$SOURCE_DIR/.claude/settings.local.json" "$TARGET_DIR/.claude/"
fi

# 4. Copy Annex
log "INFO" "Copying $LANG_NAME Annex..."
ensure_dir "$TARGET_DIR/.claude/constitution"
case "$LANG_NAME" in
    "Go")
        safe_copy "$SOURCE_DIR/.claude/constitution/go_annex.md" "$TARGET_DIR/.claude/constitution/"
        safe_copy "$SOURCE_DIR/profiles/go/Makefile" "$TARGET_DIR/"
        ;;
    "PHP")
        safe_copy "$SOURCE_DIR/.claude/constitution/php_annex.md" "$TARGET_DIR/.claude/constitution/"
        ;;
    "Python")
        safe_copy "$SOURCE_DIR/.claude/constitution/python_annex.md" "$TARGET_DIR/.claude/constitution/"
        ;;
esac

# 5. Copy Commands
log "INFO" "Copying Commands..."
ensure_dir "$TARGET_DIR/.claude/commands"
if ls "$SOURCE_DIR/.claude/commands/"*.md 1> /dev/null 2>&1; then
    for file in "$SOURCE_DIR/.claude/commands/"*.md; do
        safe_copy "$file" "$TARGET_DIR/.claude/commands/"
    done
fi



# 6. Copy Hooks
log "INFO" "Copying Hooks..."
ensure_dir "$TARGET_DIR/.claude/hooks"
for file in "$SOURCE_DIR/.claude/hooks/"*; do
    if [ -f "$file" ] && [[ "$(basename "$file")" != .* ]]; then
        safe_copy "$file" "$TARGET_DIR/.claude/hooks/"
    fi
done

if [ -d "$SOURCE_DIR/.claude/hooks/$PROFILE" ]; then
    if ls "$SOURCE_DIR/.claude/hooks/$PROFILE/"* 1> /dev/null 2>&1; then
        for file in "$SOURCE_DIR/.claude/hooks/$PROFILE/"*; do
            if [ -f "$file" ]; then safe_copy "$file" "$TARGET_DIR/.claude/hooks/"; fi
        done
    fi
fi

# 7. Copy Skills
log "INFO" "Copying Skills..."
ensure_dir "$TARGET_DIR/.claude/skills"
if [ -d "$SOURCE_DIR/.claude/skills" ]; then
    if [ -d "$TARGET_DIR/.claude/skills" ] && [ "$(ls -A "$TARGET_DIR/.claude/skills")" ]; then
        # Skills dir exists and not empty
        SKILLS_ACTION="skip"
        if [[ "$OS_TYPE" == "macOS" ]] && command -v osascript >/dev/null 2>&1; then
            BTN_CLICKED=$(osascript -e 'try
                display dialog "目标 .claude/skills 目录已存在。\n\n是否覆盖/合并更新？" buttons {"跳过", "合并更新"} default button "跳过" with icon caution
                return button returned of result
            on error
                return "跳过"
            end try' 2>/dev/null)
            if [ "$BTN_CLICKED" == "合并更新" ]; then SKILLS_ACTION="merge"; fi
        else
            echo -e "${YELLOW}Skills directory exists. Merge/Update? (y/N)${NC}"
            read -r USER_RESP
            if [[ "$USER_RESP" =~ ^[Yy]$ ]]; then SKILLS_ACTION="merge"; fi
        fi
        
        if [ "$SKILLS_ACTION" == "merge" ]; then
            cp -r "$SOURCE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
            log "SUCCESS" "Skills updated."
        else
            log "INFO" "Skills update skipped."
        fi
    else
        cp -r "$SOURCE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
        log "SUCCESS" "Skills installed."
    fi
fi

# 8. Misc configs
if [ -f "$SOURCE_DIR/.claude/changelog_config.json" ]; then
    safe_copy "$SOURCE_DIR/.claude/changelog_config.json" "$TARGET_DIR/.claude/"
fi

log "INFO" "Checking .env configuration..."
if [ ! -f "$TARGET_DIR/.env" ] && [ -f "$SOURCE_DIR/.env.example" ]; then
    safe_copy "$SOURCE_DIR/.env.example" "$TARGET_DIR/.env"
fi

ensure_gitignore

# ==========================================
# 6. Post-Install Adjustments
# ==========================================
log "INFO" "Adjusting configuration paths..."

# Use run_sed_i wrapper for cross-platform compatibility
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    run_sed_i 's/@AGENTS.md/@AGENTS.md/g' "$TARGET_DIR/CLAUDE.md"
fi

if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    run_sed_i 's/(\.\.\/\.\.\/constitution.md)/(.claude\/constitution.md)/g' "$TARGET_DIR/AGENTS.md"
    run_sed_i 's/(\.\.\/\.\.\/docs\/constitution\//(.claude\/constitution\//g' "$TARGET_DIR/AGENTS.md"
    run_sed_i 's/@\.\/constitution.md/@.claude\/constitution.md/g' "$TARGET_DIR/AGENTS.md"
fi

if [ -f "$TARGET_DIR/.claude/agents/code-reviewer.md" ]; then
    run_sed_i 's/docs\/constitution\//.claude\/constitution\//g' "$TARGET_DIR/.claude/agents/code-reviewer.md"
fi

if [ -d "$TARGET_DIR/.claude/commands" ]; then
    find "$TARGET_DIR/.claude/commands" -name "review-code.md" -print0 | while IFS= read -r -d '' file; do
        run_sed_i 's/docs\/constitution\//.claude\/constitution\//g' "$file"
    done
fi

# Permissions
log "INFO" "Setting permissions..."
chmod +x "$TARGET_DIR/.claude/hooks/"* 2>/dev/null || true
if [ -d "$TARGET_DIR/.claude/skills" ]; then
    find "$TARGET_DIR/.claude/skills" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;
fi

# ==========================================
# 7. Final Verification
# ==========================================
log "INFO" "Verifying installation..."
ERRORS=0

if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    log "WARN" "CLAUDE.md missing! (Skipped)"
fi

if [ ! -d "$TARGET_DIR/.claude/agents" ]; then
    log "ERROR" "Agents directory missing!"
    ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
    log "SUCCESS" "Installation verified successfully!"
    echo -e "\n${GREEN}🎉 Learn Claude Code Integration Complete!${NC}"
    echo -e "Check ${BLUE}$TARGET_DIR/CLAUDE.md${NC} to get started."
    echo -e "Installation log saved to: ${BLUE}$LOG_FILE${NC}"
else
    log "ERROR" "Installation finished with $ERRORS errors. Please check logs."
    exit 1
fi
