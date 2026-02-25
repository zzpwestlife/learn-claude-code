#!/bin/bash
set -e

# Migration Script: ai-workflow -> Project Root
# Goal: Migrate missing components, ensure structure alignment, preserve Go focus.

SOURCE_DIR="ai-workflow"
TARGET_DIR="."

echo "🚀 Starting Migration from $SOURCE_DIR to $TARGET_DIR"

# Helper to copy if missing or different
migrate_file() {
    local src="$1"
    local dest="$2"
    
    if [ ! -f "$src" ]; then
        echo "⚠️ Source file missing: $src"
        return
    fi
    
    mkdir -p "$(dirname "$dest")"
    
    if [ ! -f "$dest" ]; then
        echo "✅ Copying (New): $dest"
        cp "$src" "$dest"
    elif ! cmp -s "$src" "$dest"; then
        echo "🔄 Updating (Diff): $dest"
        cp "$src" "$dest"
    else
        echo "⏭️  Skipping (Identical): $dest"
    fi
}

# 1. Migrate Rules (.claude/rules)
# These are critical for the workflow protocol and coding standards
echo "📦 Migrating Rules..."
mkdir -p .claude/rules
for file in "$SOURCE_DIR/.claude/rules/"*.md; do
    migrate_file "$file" ".claude/rules/$(basename "$file")"
done

# 2. Migrate Hooks
echo "📦 Migrating Hooks..."
migrate_file "$SOURCE_DIR/.claude/hooks/claudeception-activator.sh" ".claude/hooks/claudeception-activator.sh"
chmod +x .claude/hooks/claudeception-activator.sh

# 3. Migrate Planning Templates
echo "📦 Migrating Planning Templates..."
TEMPLATE_DIR=".claude/skills/planning-with-files/templates"
mkdir -p "$TEMPLATE_DIR"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/templates/task_plan.md" "$TEMPLATE_DIR/task_plan.md"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/templates/findings.md" "$TEMPLATE_DIR/findings.md"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/templates/progress.md" "$TEMPLATE_DIR/progress.md"

# 4. Migrate Planning Scripts
echo "📦 Migrating Planning Scripts..."
SCRIPT_DIR=".claude/skills/planning-with-files/scripts"
mkdir -p "$SCRIPT_DIR"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/scripts/check-complete.sh" "$SCRIPT_DIR/check-complete.sh"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/scripts/check-complete.ps1" "$SCRIPT_DIR/check-complete.ps1"
migrate_file "$SOURCE_DIR/.claude/skills/planning-with-files/scripts/session-catchup.py" "$SCRIPT_DIR/session-catchup.py"
chmod +x "$SCRIPT_DIR"/*.sh
chmod +x "$SCRIPT_DIR"/*.py

# 5. Migrate Changelog Agent
echo "📦 Migrating Changelog Agent..."
CL_DIR=".claude/skills/changelog-generator/scripts"
mkdir -p "$CL_DIR"
migrate_file "$SOURCE_DIR/.claude/skills/changelog-generator/scripts/changelog_agent.py" "$CL_DIR/changelog_agent.py"
chmod +x "$CL_DIR/changelog_agent.py"

# 6. Migrate Command Definitions
echo "📦 Migrating Commands..."
CMD_DIR=".claude/commands"
mkdir -p "$CMD_DIR"
for file in "$SOURCE_DIR/.claude/commands/"*.md; do
    migrate_file "$file" "$CMD_DIR/$(basename "$file")"
done

# 7. Migrate Settings
echo "📦 Migrating Settings..."
# Merge logic would be better, but for now we check if key settings are missing
# Just copy changelog_config.json
migrate_file "$SOURCE_DIR/.claude/changelog_config.json" ".claude/changelog_config.json"

# 8. Migrate Tests
echo "📦 Migrating Tests..."
# We already have test_session_catchup.py, but let's sync any others
if [ -d "$SOURCE_DIR/tests" ]; then
    for file in "$SOURCE_DIR/tests/"test_*.py; do
         migrate_file "$file" "tests/$(basename "$file")"
    done
fi

# 9. Verify Agent Definitions
echo "📦 Migrating Agents..."
# Specifically Code Reviewer
migrate_file "$SOURCE_DIR/.claude/agents/code-reviewer.md" ".claude/agents/code-reviewer.md"

echo "🎉 Migration Script Completed."
echo "Please run verification tests."
