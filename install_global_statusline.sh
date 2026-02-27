#!/bin/bash

# 确保全局目录存在
mkdir -p ~/.claude/scripts

# 写入新的脚本内容
cat > ~/.claude/scripts/statusline.sh << 'EOF'
#!/bin/bash

# 读取 stdin 输入
input=$(cat)

# 定义颜色
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'

# 1. 模型信息
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
MODEL_DISPLAY="${BOLD}${MAGENTA}🤖 ${MODEL}${RESET}"

# 2. 目录信息
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
DIR_NAME="${DIR##*/}"
DIR_DISPLAY="📁 ${DIR_NAME}"

# 3. Git 分支
GIT_DISPLAY=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_DISPLAY=" ${CYAN} ${BRANCH}${RESET}"
    fi
fi

# 4. Token 使用率 (显示百分比和具体数值)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage')
PERCENT_USED=0
TOKEN_DISPLAY=""

if [ "$USAGE" != "null" ] && [ "$USAGE" != "" ]; then
    # 计算总 Token
    CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
    
    # 计算百分比
    if [ "$CONTEXT_SIZE" -gt 0 ]; then
        PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
        if [ "$PERCENT_USED" -eq 0 ] && [ "$CURRENT_TOKENS" -gt 0 ]; then
            PERCENT_USED=1
        fi
    fi
    
    # 格式化 Token 数 (例如 22.5k)
    if [ "$CURRENT_TOKENS" -gt 1000 ]; then
        if command -v awk &> /dev/null; then
            TOKENS_FMT=$(echo "$CURRENT_TOKENS" | awk '{printf "%.1fk", $1/1000}')
        else
            TOKENS_FMT="$((CURRENT_TOKENS / 1000))k"
        fi
    else
        TOKENS_FMT="$CURRENT_TOKENS"
    fi
    
    # 颜色逻辑
    TOKEN_COLOR=$GREEN
    if [ "$PERCENT_USED" -ge 80 ]; then
        TOKEN_COLOR=$RED
    elif [ "$PERCENT_USED" -ge 50 ]; then
        TOKEN_COLOR=$YELLOW
    fi
    
    # 显示格式: 📊 11% (22.1k)
    TOKEN_DISPLAY="${TOKEN_COLOR}📊 ${PERCENT_USED}% (${TOKENS_FMT})${RESET}"
else
    TOKEN_DISPLAY="${GRAY}📊 0%${RESET}"
fi

# 5. 成本估算
COST_VAL=$(echo "$input" | jq -r '.cost.total_cost // 0')
COST_DISPLAY=""
if [ "$COST_VAL" != "null" ]; then
    if command -v awk &> /dev/null; then
        COST_FMT=$(echo "$COST_VAL" | awk '{printf "%.4f", $1}')
        COST_DISPLAY=" ${GRAY}|${RESET} 💰 \$${COST_FMT}"
    else
        COST_DISPLAY=" ${GRAY}|${RESET} 💰 \$${COST_VAL}"
    fi
fi

# 分隔符
SEP="${GRAY}|${RESET}"

# 组合输出
echo -e "${MODEL_DISPLAY} ${SEP} ${DIR_DISPLAY}${GIT_DISPLAY} ${SEP} ${TOKEN_DISPLAY}${COST_DISPLAY}"
EOF

chmod +x ~/.claude/scripts/statusline.sh

echo "✅ Updated statusline script installed to ~/.claude/scripts/statusline.sh"

# 检查配置文件，优先使用 ft-settings.json (如果存在)
SETTINGS_FILE=~/.claude/config.json
if [ -f ~/.claude/ft-settings.json ]; then
    SETTINGS_FILE=~/.claude/ft-settings.json
    echo "ℹ️  Found ft-settings.json, updating that instead of config.json"
fi

# 如果都不存在，则创建 config.json
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

SCRIPT_PATH="${HOME}/.claude/scripts/statusline.sh"

# 使用 jq 添加配置 (如果 jq 存在)
if command -v jq &> /dev/null; then
    tmp=$(mktemp)
    # 使用 --arg 传递变量，避免 shell 注入风险
    # 注意：这里会覆盖现有的 statusLine 配置
    jq --arg script_path "$SCRIPT_PATH" '. + {"statusLine": {
        "type": "command",
        "command": $script_path,
        "padding": 0
    }}' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
    echo "✅ Global configuration updated in $SETTINGS_FILE with absolute path: $SCRIPT_PATH"
else
    echo "⚠️  jq not found. Please manually add the following to $SETTINGS_FILE:"
    echo '  "statusLine": {'
    echo '    "type": "command",'
    echo '    "command": "~/.claude/scripts/statusline.sh",'
    echo '    "padding": 0'
    echo '  }'
fi

echo "Please restart Claude Code to apply changes."
