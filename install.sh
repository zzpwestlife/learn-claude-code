#!/bin/bash
set -e

# Configuration
PLUGIN_NAME="smart-guided-workflow"
CLAUDE_ROOT="${CLAUDE_ROOT:-$HOME/.claude}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Installing $PLUGIN_NAME plugin...${NC}"
echo "Target directory: $CLAUDE_ROOT"

# Ensure directories exist
mkdir -p "$CLAUDE_ROOT/commands"
mkdir -p "$CLAUDE_ROOT/skills"
mkdir -p "$CLAUDE_ROOT/agents"

# Copy files
echo -e "-> Installing commands..."
if [ -d ".claude/commands" ]; then
    cp -R .claude/commands/* "$CLAUDE_ROOT/commands/"
fi

echo -e "-> Installing skills..."
if [ -d ".claude/skills" ]; then
    cp -R .claude/skills/* "$CLAUDE_ROOT/skills/"
fi

echo -e "-> Installing agents..."
if [ -d ".claude/agents" ]; then
    cp -R .claude/agents/* "$CLAUDE_ROOT/agents/"
fi

# Optional: Copy settings if user wants (usually not overwritten)
# echo "-> Checking settings..."

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "   Try running '${BLUE}/optimize-prompt${NC}' to start your workflow."
