#!/bin/bash

# ==============================================================================
# Script: clean_user_config.sh (Now acts as: UNINSTALL CLAUDE CODE)
# Purpose: COMPLETELY uninstall Claude Code (Official & Unofficial) and all configurations.
# Usage: ./clean_user_config.sh
# ==============================================================================

set -e

# Configuration
USER_CONFIG_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude_backup_full_$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}======================================================================${NC}"
echo -e "${RED}DANGER: This script will COMPLETELY UNINSTALL Claude Code and remove ALL data.${NC}"
echo -e "${RED}======================================================================${NC}"
echo -e "${YELLOW}Targeting for removal:${NC}"
echo -e "  1. [NPM] @anthropic-ai/claude-code (Official Package)"
echo -e "  2. [NPM] @futupb/ft-claude-code (Unofficial/Fork Package)"
echo -e "  3. [BREW] claude-code-tool-manager (Tool Manager)"
echo -e "  4. [CONFIG] $USER_CONFIG_DIR (All chats, settings, keys, history)"
echo ""

# Interactive Confirmation
read -p "Are you sure you want to completely uninstall EVERYTHING? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# ==============================================================================
# 1. Uninstall NPM Packages
# ==============================================================================
echo -e "\n${GREEN}[1/4] Uninstalling NPM packages...${NC}"

if command -v npm >/dev/null 2>&1; then
    # Try removing official package
    echo "Attempting to remove @anthropic-ai/claude-code..."
    if npm list -g @anthropic-ai/claude-code >/dev/null 2>&1; then
        npm uninstall -g @anthropic-ai/claude-code || echo -e "${YELLOW}Warning: Failed to uninstall @anthropic-ai/claude-code (check permissions?)${NC}"
    else
        echo "Package @anthropic-ai/claude-code not found."
    fi
    
    # Try removing unofficial package
    echo "Attempting to remove @futupb/ft-claude-code..."
    if npm list -g @futupb/ft-claude-code >/dev/null 2>&1; then
        npm uninstall -g @futupb/ft-claude-code || echo -e "${YELLOW}Warning: Failed to uninstall @futupb/ft-claude-code (check permissions?)${NC}"
    else
        echo "Package @futupb/ft-claude-code not found."
    fi
else
    echo -e "${YELLOW}npm not found. Skipping npm uninstall.${NC}"
fi

# ==============================================================================
# 2. Uninstall Homebrew Packages
# ==============================================================================
echo -e "\n${GREEN}[2/4] Uninstalling Homebrew packages...${NC}"

if command -v brew >/dev/null 2>&1; then
    if brew list --cask | grep -q "claude-code-tool-manager"; then
        echo "Removing claude-code-tool-manager..."
        brew uninstall --cask claude-code-tool-manager || echo -e "${YELLOW}Warning: Failed to remove claude-code-tool-manager${NC}"
    else
        echo "claude-code-tool-manager not found in brew."
    fi

    # Check for 'claude-code' cask (The main CLI installed via brew)
    if brew list --cask | grep -q "^claude-code$"; then
        echo "Removing claude-code cask..."
        brew uninstall --cask claude-code || echo -e "${YELLOW}Warning: Failed to remove claude-code cask${NC}"
    else
        echo "claude-code cask not found in brew."
    fi

    # Check for 'claude' formula (rare but possible)
    if brew list --formula | grep -q "^claude$"; then
        echo "Removing claude formula..."
        brew uninstall claude || echo -e "${YELLOW}Warning: Failed to remove claude formula${NC}"
    fi
else
    echo -e "${YELLOW}brew not found. Skipping brew uninstall.${NC}"
fi

# ==============================================================================
# 3. Backup Configuration (Safety First)
# ==============================================================================
if [ -d "$USER_CONFIG_DIR" ]; then
    echo -e "\n${GREEN}[3/4] Backing up configuration (just in case)...${NC}"
    echo "Backup location: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -R "$USER_CONFIG_DIR/"* "$BACKUP_DIR/" 2>/dev/null || echo "Backup warning: some files might be skipped."
else
    echo -e "\n${GREEN}[3/4] No configuration directory found to backup.${NC}"
fi

# ==============================================================================
# 4. Remove Configuration Directory
# ==============================================================================
echo -e "\n${GREEN}[4/4] Removing configuration directory...${NC}"

if [ -d "$USER_CONFIG_DIR" ]; then
    rm -rf "$USER_CONFIG_DIR"
    echo "Removed $USER_CONFIG_DIR"
else
    echo "$USER_CONFIG_DIR already gone."
fi

# ==============================================================================
# 5. Final Verification
# ==============================================================================
echo -e "\n${GREEN}=== Uninstallation Complete ===${NC}"
echo "Checking for leftovers..."

REMAINING_ISSUES=0

if command -v claude >/dev/null 2>&1; then
    CLA_PATH=$(which claude)
    echo -e "${RED}WARNING: 'claude' command still exists at: $CLA_PATH${NC}"
    
    # Aggressive Cleanup: Try to remove the binary/symlink manually
    read -p "Do you want to FORCE DELETE $CLA_PATH? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Force deleting $CLA_PATH..."
        rm -f "$CLA_PATH" || sudo rm -f "$CLA_PATH"
        
        # Verify again
        if command -v claude >/dev/null 2>&1; then
             echo -e "${RED}Failed to delete. Please remove manually.${NC}"
             REMAINING_ISSUES=1
        else
             echo -e "${GREEN}Successfully force deleted 'claude'.${NC}"
             REMAINING_ISSUES=0
        fi
    else
        echo -e "You chose not to delete it. Please remove it manually."
        REMAINING_ISSUES=1
    fi
else
    echo -e "${GREEN}SUCCESS: 'claude' command is gone.${NC}"
fi

if [ -d "$USER_CONFIG_DIR" ]; then
    echo -e "${RED}WARNING: $USER_CONFIG_DIR still exists.${NC}"
    REMAINING_ISSUES=1
else
    echo -e "${GREEN}SUCCESS: Config directory is gone.${NC}"
fi

echo ""
if [ $REMAINING_ISSUES -eq 0 ]; then
    echo -e "${GREEN}All checks passed. Claude Code has been completely uninstalled.${NC}"
else
    echo -e "${YELLOW}Some components may still remain. Please check the warnings above.${NC}"
fi

echo -e "\nNote: If you have added any alias/export lines to your .zshrc or .bashrc, please remove them manually."
