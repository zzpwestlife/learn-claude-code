#!/bin/bash
set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}🚀 飞书通知功能集成测试向导${NC}"
echo "========================================="

# 1. 获取目标路径
if [ -z "$1" ]; then
    read -p "请输入测试项目的路径 (例如 ../my-test-project): " TARGET_PATH
else
    TARGET_PATH="$1"
fi

# 处理相对路径
if [[ "$TARGET_PATH" != /* ]]; then
    TARGET_PATH="$(pwd)/$TARGET_PATH"
fi

echo -e "\n${BLUE}1. 正在安装 Learn Claude Code 到: $TARGET_PATH ...${NC}"
mkdir -p "$TARGET_PATH"
# 创建一个空的 go.mod 模拟 Go 项目，避免交互式询问
touch "$TARGET_PATH/go.mod"

# 运行安装脚本 (自动确认模式)
yes "Go" | "$SOURCE_DIR/install.sh" "$TARGET_PATH"

echo -e "\n${BLUE}2. 配置飞书 Webhook${NC}"
WEBHOOK_URL="$2"

if [ -z "$WEBHOOK_URL" ]; then
    echo -e "${YELLOW}请输入您的飞书 Webhook 地址 (按 Enter 跳过测试):${NC}"
    read -r WEBHOOK_URL
fi

if [ -z "$WEBHOOK_URL" ]; then
    echo -e "\n${YELLOW}已跳过 Webhook 测试。${NC}"
    echo -e "您稍后可以手动测试: \n  /Applications/ServBay/script/alias/node /Users/admin/claude-code-notification/src/index.js --type info --title 'Manual Test' --message '测试消息'"
    exit 0
fi

# 更新 .env 文件
echo -e "\n${BLUE}3. 更新环境变量...${NC}"
if [ -f "$TARGET_PATH/.env" ]; then
    # 使用 sed 替换或者追加
    if grep -q "CLAUDE_WEBHOOK_URL=" "$TARGET_PATH/.env"; then
        # 简单替换 (注意：如果 URL 包含特殊字符可能会有问题，这里做简单处理)
        # 为避免 sed 分隔符冲突，使用 python 修改
        python3 -c "
import sys
lines = open('$TARGET_PATH/.env').readlines()
with open('$TARGET_PATH/.env', 'w') as f:
    for line in lines:
        if line.strip().startswith('CLAUDE_WEBHOOK_URL='):
            f.write(f'CLAUDE_WEBHOOK_URL=$WEBHOOK_URL\n')
        else:
            f.write(line)
"
    else
        echo "CLAUDE_WEBHOOK_URL=$WEBHOOK_URL" >> "$TARGET_PATH/.env"
    fi
    echo "✅ .env 已更新"
else
    echo "❌ .env 文件未找到！"
    exit 1
fi

# 发送测试通知
echo -e "\n${BLUE}4. 发送测试通知...${NC}"
NOTIFY_CMD="/Applications/ServBay/script/alias/node /Users/admin/claude-code-notification/src/index.js"
# 显式传递 Webhook URL，确保无需依赖 python-dotenv
$NOTIFY_CMD --type info --title "Setup Test" --message "👋 你好！这是来自 Learn Claude Code 的飞书集成测试消息。"

echo -e "\n${GREEN}✨ 流程结束！${NC}"
