# Claude Code 炫酷状态行配置指南

本文档提供了一份完整的指南，帮助您为 Claude Code 配置一个功能丰富、美观的全局状态行。

## 1. 效果预览

配置完成后，您的 Claude Code 底部将显示如下信息：

```text
🤖 Claude 3.5 Sonnet | 📁 my-project  main | 📊 15% (30.0k) | 💰 $0.0123
```

**包含特性：**
- **模型显示**：带有 🤖 图标和高亮颜色。
- **项目上下文**：显示当前目录名。
- **Git 集成**：显示当前分支（带  图标）。
- **Token 监控**：实时显示上下文使用率和具体消耗量（如 `15% (30.0k)`），并根据用量变色（<50% 绿, >50% 黄, >80% 红）。
- **成本估算**：显示当前会话预估成本（即使为 0 也会显示）。

## 2. 一键安装（推荐）

复制以下代码块，在您的终端中粘贴并运行即可完成配置。该脚本会自动处理配置文件路径和权限。

```bash
# 创建脚本目录
mkdir -p ~/.claude/scripts

# 写入状态行脚本
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

# 赋予执行权限
chmod +x ~/.claude/scripts/statusline.sh

# 配置全局设置 (自动检测 config.json 或 ft-settings.json)
SETTINGS_FILE=~/.claude/config.json
if [ -f ~/.claude/ft-settings.json ]; then
    SETTINGS_FILE=~/.claude/ft-settings.json
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

SCRIPT_PATH="${HOME}/.claude/scripts/statusline.sh"

if command -v jq &> /dev/null; then
    tmp=$(mktemp)
    jq --arg script_path "$SCRIPT_PATH" '. + {"statusLine": {
        "type": "command",
        "command": $script_path,
        "padding": 0
    }}' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
    echo "✅ Global configuration updated in $SETTINGS_FILE"
else
    echo "⚠️  jq not found. Please manually edit $SETTINGS_FILE to add statusLine configuration."
fi

echo "Please restart Claude Code to apply changes."
```

## 3. 依赖说明

- **jq**：脚本严重依赖 `jq` 来解析 JSON 数据。请确保系统中已安装：
  ```bash
  brew install jq
  ```
- **Nerd Fonts**（可选）：为了正确显示图标（ 等），建议使用支持 Nerd Fonts 的终端字体。

## 4. 故障排除

- **状态栏不显示**：
  - 检查配置文件路径是否正确（必须是绝对路径）。
  - 检查脚本是否有执行权限 (`chmod +x`).
  - 重启 Claude Code (`/exit` 然后重新进入)。
- **JSON 解析错误**：
  - 确保安装了 `jq`。
  - 尝试手动运行脚本测试：
    ```bash
    echo '{}' | ~/.claude/scripts/statusline.sh
    ```
