#!/bin/bash

# setup_claude_env.sh
# One-click setup script for Claude Code environment
# Usage: ./setup_claude_env.sh

set -e # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[SETUP] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# --- 0. Load Configuration ---
log "Loading configuration..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

# --- 0.1 Prerequisites Check ---
log "Checking prerequisites..."

# Check OS (Mac only support as requested)
if [[ "$OSTYPE" != "darwin"* ]]; then
    warn "This script is optimized for macOS. Linux/Windows may encounter issues."
fi

# Check Node.js and NPM
if ! command -v npm &> /dev/null; then
    error "Node.js/npm is not installed. Please install Node.js (v18+) first."
fi

# Check Intranet Registry Connectivity
log "Checking connection to npm registry..."
if ! curl -s --head --request GET "http://registry.npm.oa.com/" --max-time 3 > /dev/null; then
    warn "Cannot connect to internal registry (http://registry.npm.oa.com/)."
    warn "Please ensure you are connected to the VPN/Intranet."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Aborted by user."
    fi
fi

if [ -f "$ENV_FILE" ]; then
    log "Loading configuration from .env..."
    # Source the file to load variables
    # set -a automatically exports variables
    set -a
    source "$ENV_FILE"
    set +a
elif [ -f "$ENV_EXAMPLE" ]; then
    warn ".env file not found. Creating from .env.example..."
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    warn "Created .env. Please edit it to add your API keys: Z_AI_API_KEY, BIGMODEL_API_KEY, GITHUB_TOKEN, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_AUTH_USER_EMAIL, TAVILY_API_KEY"
    warn "Continuing with empty keys..."
else
    warn "No .env or .env.example found. MCP servers requiring keys might fail."
fi

# Map .env variables to local variables used in this script
Z_AI_KEY="${Z_AI_API_KEY:-}"
BIGMODEL_KEY="${BIGMODEL_API_KEY:-}"
GH_TOKEN="${GITHUB_TOKEN:-}"
TAVILY_KEY="${TAVILY_API_KEY:-}"

# Check for Custom CLI Auth Token
if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
    log "Found ANTHROPIC_AUTH_TOKEN in environment."
    export ANTHROPIC_AUTH_TOKEN
else
    warn "ANTHROPIC_AUTH_TOKEN is not set in .env."
    warn "You may be prompted to enter your FUTU AI USER API key interactively during initialization."
fi

# Check for Custom CLI Email
if [ -n "$ANTHROPIC_AUTH_USER_EMAIL" ]; then
    log "Found ANTHROPIC_AUTH_USER_EMAIL in environment: $ANTHROPIC_AUTH_USER_EMAIL"
    export ANTHROPIC_AUTH_USER_EMAIL
else
    warn "ANTHROPIC_AUTH_USER_EMAIL is not set in .env."
    warn "This will cause an interactive prompt. Attempting to extract from git config as fallback..."
    GIT_EMAIL=$(git config --global user.email || true)
    if [[ "$GIT_EMAIL" == *"@futunn.com"* ]]; then
        log "Using git email: $GIT_EMAIL"
        export ANTHROPIC_AUTH_USER_EMAIL="$GIT_EMAIL"
    else
         warn "Git email ($GIT_EMAIL) is not a Futu email. Interactive prompt is unavoidable if not set in .env."
    fi
fi

# --- 1. Backup and Cleanup ---
log "Starting Claude Code environment reset..."

# Kill existing processes that might hold locks
log "Stopping any running Claude processes..."
pkill -f "claude" || true
pkill -f "claude-code" || true

# Remove conflicting binaries/symlinks in .local/bin
if [ -e "$HOME/.local/bin/claude" ]; then
    log "Removing conflicting binary/symlink at $HOME/.local/bin/claude..."
    rm "$HOME/.local/bin/claude"
fi

# Clean npx cache to prevent ENOTEMPTY errors
if [ -d "$HOME/.npm/_npx" ]; then
    log "Cleaning npx cache to prevent conflicts..."
    rm -rf "$HOME/.npm/_npx"
fi

if [ -d "$HOME/.claude" ]; then
    BACKUP_DIR="$HOME/.claude.bak_$(date +%s)"
    log "Backing up existing configuration to $BACKUP_DIR..."
    cp -r "$HOME/.claude" "$BACKUP_DIR"
    
    log "Removing existing .claude configuration..."
    
    # Handle macOS specific file flags (immutable)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        chflags -R nouchg "$HOME/.claude" 2>/dev/null || true
    fi

    # Try standard remove, if fail, try deleting contents specifically
    if ! rm -rf "$HOME/.claude"; then
        warn "Standard removal failed. Attempting aggressive cleanup..."
        # Delete all files first
        find "$HOME/.claude" -type f -delete 2>/dev/null || true
        # Delete all directories (depth first)
        find "$HOME/.claude" -depth -type d -exec rm -rf {} + 2>/dev/null || true
        # Try removing root again
        rm -rf "$HOME/.claude" || error "Failed to remove $HOME/.claude even after aggressive cleanup. Please check permissions or running processes."
    fi
else
    log "No existing .claude directory found. Skipping backup."
fi

# --- 2. Install Custom Claude CLI ---
log "Installing custom Claude Code CLI (@futupb/ft-claude-code)..."
# Using force and specific registry as requested
npm install -g @futupb/ft-claude-code --force --registry="http://registry.npm.oa.com/" || {
    error "Failed to install custom Claude CLI. Please check your network connection to registry.npm.oa.com."
    exit 1
}

if ! command -v claude &> /dev/null; then
    warn "Claude CLI not found in PATH immediately after install. This might be due to shell caching."
    log "Trying to proceed, but if subsequent commands fail, please restart your shell."
fi

log "Claude CLI detected: $(which claude)"

# --- Patch Custom CLI to prevent hangs ---
log "Patching custom CLI to fix network hangs..."
CLI2_PATH="$(npm root -g)/@futupb/ft-claude-code/cli2.js"
if [ -f "$CLI2_PATH" ]; then
    log "Found cli2.js at $CLI2_PATH"
    
    # 1. Fix URL typo http:/ -> http://
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|http:/futu-claudecode|http://futu-claudecode|g' "$CLI2_PATH"
    else
        sed -i 's|http:/futu-claudecode|http://futu-claudecode|g' "$CLI2_PATH"
    fi
    
    # 2. Disable blocking statsig report wait at the end by forcing the condition to false
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|if (await isFirstReported.then(result => result === false))|if (false)|g' "$CLI2_PATH"
    else
        sed -i 's|if (await isFirstReported.then(result => result === false))|if (false)|g' "$CLI2_PATH"
    fi
    
    # 3. Disable blocking statsig report start at the beginning (floating promise)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|const isFirstReported = reportStatsigId();|const isFirstReported = Promise.resolve(true);|g' "$CLI2_PATH"
    else
        sed -i 's|const isFirstReported = reportStatsigId();|const isFirstReported = Promise.resolve(true);|g' "$CLI2_PATH"
    fi
    
    # 4. Replace setInterval with setTimeout to prevent process from hanging indefinitely
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|setInterval(() => {|setTimeout(() => {|g' "$CLI2_PATH"
    else
        sed -i 's|setInterval(() => {|setTimeout(() => {|g' "$CLI2_PATH"
    fi
    
    log "Patched cli2.js successfully."
else
    warn "Could not find cli2.js to patch at $CLI2_PATH. Proceeding, but might hang..."
fi

# --- Pre-create Directories ---
log "Pre-creating necessary directories..."
mkdir -p "$HOME/.claude/statsig"
touch "$HOME/.claude/statsig/statsig.stable_id.2656274335" || true

# --- Create Configuration Files Manually ---
log "Manually creating configuration files to bypass interactive init..."

# 1. Create ft-claude-code.json (Custom Auth Config)
FT_CONFIG_PATH="$HOME/.claude/ft-claude-code.json"
if [ -n "$ANTHROPIC_AUTH_TOKEN" ] && [ -n "$ANTHROPIC_AUTH_USER_EMAIL" ]; then
    log "Writing auth config to $FT_CONFIG_PATH..."
    # Use cat to safely generate JSON without relying on python
    cat > "$FT_CONFIG_PATH" <<EOF
{
  "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_AUTH_TOKEN}",
  "ANTHROPIC_AUTH_USER_EMAIL": "${ANTHROPIC_AUTH_USER_EMAIL}"
}
EOF
    # Fix permissions and remove extended attributes (like com.apple.quarantine/provenance) that might cause EPERM
    chmod 600 "$FT_CONFIG_PATH"
    xattr -c "$FT_CONFIG_PATH" 2>/dev/null || true
else
    warn "Missing Auth Token or Email. $FT_CONFIG_PATH will not be pre-populated."
fi

# 2. Create standard config.json if missing
if [ ! -f "$HOME/.claude/config.json" ]; then
    log "Creating default config.json..."
    echo '{}' > "$HOME/.claude/config.json"
fi

# Skip problematic `claude init` which hangs
log "Skipping interactive 'claude init'. Verifying setup with 'claude --version'..."

# Also run version check as before to verify CLI is responsive.
if ! claude --version; then
    error "Claude CLI failed to run. Please check your configuration."
    exit 1
fi

# --- 3. Define Helper Functions ---

install_plugin() {
    log "Installing plugin: $1..."
    claude plugin install "$1" || warn "Failed to install $1"
}

add_mcp_std() {
    # Usage: add_mcp_std name package_name [env_vars...]
    local name=$1
    local pkg=$2
    shift 2
    local env_args=""
    for e in "$@"; do
        env_args="$env_args --env $e"
    done
    
    log "Adding MCP: $name ($pkg)..."
    # Remove if exists to ensure clean state
    claude mcp remove "$name" 2>/dev/null || true
    # Using 'claude mcp add' with npx execution
    # Force public registry for standard MCPs to avoid 404s on private registries
    # Use NPM_CONFIG_USERCONFIG=/dev/null to ignore local .npmrc (avoid expired token issues)
    NPM_CONFIG_USERCONFIG=/dev/null claude mcp add -s user "$name" $env_args -- npx -y --registry=https://registry.npmjs.org/ "$pkg" || warn "Failed to add MCP $name"
}

add_mcp_http() {
    # Usage: add_mcp_http name url header
    local name=$1
    local url=$2
    local header=$3
    
    log "Adding HTTP MCP: $name..."
    claude mcp remove "$name" 2>/dev/null || true
    claude mcp add -s user -t http "$name" "$url" --header "$header" || warn "Failed to add MCP $name"
}

# --- 4. Load & Execute Configuration ---
CONFIG_FILE="$SCRIPT_DIR/setup_config.json"

if [ -f "$CONFIG_FILE" ]; then
    log "Reading configuration from setup_config.json..."
    
    # Export variables for Python script
    export Z_AI_KEY BIGMODEL_KEY GH_TOKEN TAVILY_KEY HOME

    # Generate Python parser
    cat <<EOF > "$SCRIPT_DIR/parse_config.py"
import json
import os
import sys

def get_env(var_name):
    val = os.environ.get(var_name)
    if val == "": return None
    return val

def substitute(text):
    if not text: return ""
    return os.path.expandvars(text)

try:
    with open('setup_config.json', 'r') as f:
        config = json.load(f)
        
    # Marketplaces
    print("log 'Registering Plugin Marketplaces...'")
    for mp in config.get('marketplaces', []):
        print(f"claude plugin marketplace add {mp} || warn 'Failed to add marketplace {mp}'")
        
    # Plugins
    print("log 'Installing Plugins...'")
    for pl in config.get('plugins', []):
        print(f"install_plugin \"{pl}\"")
        
    # MCPs
    print("log 'Configuring MCP Servers...'")
    print("log 'Cleaning up deprecated/removed MCPs...'")
    print("claude mcp remove 'time' 2>/dev/null || true")
    print("claude mcp remove 'fetch' 2>/dev/null || true")

    mcps = config.get('mcps', {})
    
    # Std MCPs
    for mcp in mcps.get('std', []):
        name = mcp['name']
        pkg = mcp['package']
        condition = mcp.get('condition')
        
        if condition and not get_env(condition):
            print(f"warn 'Skipping {name} (missing {condition})'")
            continue
            
        env_args = []
        for k, v in mcp.get('env', {}).items():
            val = substitute(v)
            env_args.append(f"{k}={val}")
            
        args_str = " ".join([f"\"{e}\"" for e in env_args])
        print(f"add_mcp_std \"{name}\" \"{pkg}\" {args_str}")

    # Http MCPs
    for mcp in mcps.get('http', []):
        name = mcp['name']
        url = mcp['url']
        condition = mcp.get('condition')
        
        if condition and not get_env(condition):
            print(f"warn 'Skipping {name} (missing {condition})'")
            continue
            
        header = substitute(mcp.get('header', ''))
        print(f"add_mcp_http \"{name}\" \"{url}\" \"{header}\"")
        
except Exception as e:
    print(f"error 'Failed to parse config: {e}'")
    sys.exit(1)
EOF

    # Run Python script
    python3 "$SCRIPT_DIR/parse_config.py" > "$SCRIPT_DIR/config_commands.sh"
    
    # Check if python script succeeded
    if [ $? -eq 0 ]; then
        source "$SCRIPT_DIR/config_commands.sh"
    else
        error "Failed to generate configuration commands."
    fi
    
    # Cleanup
    rm "$SCRIPT_DIR/parse_config.py" "$SCRIPT_DIR/config_commands.sh"
    
else
    warn "setup_config.json not found. Skipping plugins/MCPs configuration."
fi

# --- 6. Install Skills ---
log "Installing Skills..."
# Skipping manual 'npx skills add' as they are often redundant or fail without proper arguments.
# Most skills are now covered by plugins or MCPs.
log "Skipping npx skills installation to avoid errors."

log "Reference Skills Repositories:"
log "- https://github.com/vercel-labs/skills"
log "- https://github.com/anthropics/skills"

# --- 7. Verification ---
echo -e "\n${GREEN}Setup Complete!${NC}"
echo "Verifying installation..."
claude plugin list
claude mcp list

echo -e "\n${GREEN}Please restart your terminal or reload your Claude Code session to ensure all changes take effect.${NC}"
