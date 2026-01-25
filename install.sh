#!/bin/bash

# Learn Claude Code 安装脚本 (Interactive Enhanced)
# 用法: ./install.sh [目标项目路径]

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Learn Claude Code 集成向导${NC}"

# ==========================================
# 1. 目标目录选择 (Target Directory Selection)
# ==========================================

TARGET_DIR="$1"

# 如果未提供参数，尝试使用 macOS GUI 弹窗选择
if [ -z "$TARGET_DIR" ]; then
    if command -v osascript >/dev/null 2>&1; then
        echo "正在唤起文件夹选择窗口..."
        TARGET_DIR=$(osascript -e 'try
            POSIX path of (choose folder with prompt "🚀 Learn Claude Code 安装向导\n\n请选择您要集成的目标项目根目录:")
        on error
            return ""
        end try' 2>/dev/null)
        
        if [ -z "$TARGET_DIR" ]; then
            echo -e "${YELLOW}用户取消了操作。${NC}"
            exit 0
        fi
    else
        # 降级到命令行交互
        echo -e "${YELLOW}请输入目标项目绝对路径:${NC}"
        read -r TARGET_DIR
    fi
fi

# 再次检查目录有效性
if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误: 目录 '$TARGET_DIR' 不存在或无效${NC}"
    exit 1
fi

echo -e "✅ 目标项目: ${BLUE}$TARGET_DIR${NC}"

# ==========================================
# 2. 语言类型选择 (Language Selection)
# ==========================================

LANG_CHOICE="All"

# 如果是交互模式（无命令行参数），询问语言
if [ -z "$1" ] && command -v osascript >/dev/null 2>&1; then
    LANG_CHOICE=$(osascript -e 'try
        choose from list {"Go", "PHP", "All"} with prompt "请选择项目主要语言\n(将安装对应的宪法附录规则):" default items {"All"} OK button name "确定" cancel button name "跳过"
    on error
        return "Skip"
    end try' 2>/dev/null)
    
    if [ "$LANG_CHOICE" == "false" ] || [ "$LANG_CHOICE" == "Skip" ]; then
        LANG_CHOICE="None"
    fi
fi

echo -e "✅ 选择语言配置: ${BLUE}$LANG_CHOICE${NC}"

# ==========================================
# 3. 执行安装 (Installation)
# ==========================================

echo -e "\n📦 正在复制核心文件..."
cp -v "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/"
cp -v "$SOURCE_DIR/constitution.md" "$TARGET_DIR/"

echo "🧠 复制 Agent 配置..."
if [ -d "$TARGET_DIR/.claude" ]; then
    echo "  注意: 目标目录已包含 .claude，正在合并..."
fi
cp -rv "$SOURCE_DIR/.claude" "$TARGET_DIR/"

echo "📚 复制语言附录..."
mkdir -p "$TARGET_DIR/docs/constitution"

case "$LANG_CHOICE" in
    "Go")
        cp -v "$SOURCE_DIR/docs/constitution/go_annex.md" "$TARGET_DIR/docs/constitution/"
        ;;
    "PHP")
        cp -v "$SOURCE_DIR/docs/constitution/php_annex.md" "$TARGET_DIR/docs/constitution/"
        ;;
    "All")
        cp -v "$SOURCE_DIR/docs/constitution/"*.md "$TARGET_DIR/docs/constitution/"
        ;;
    *)
        echo "  跳过语言附录复制 (选择: $LANG_CHOICE)"
        ;;
esac

# ==========================================
# 4. 完成与引导 (Completion & Onboarding)
# ==========================================

echo -e "\n${GREEN}🎉 集成成功!${NC}"

# 询问是否打开目标目录
OPEN_ACTION="No"
if [ -z "$1" ] && command -v osascript >/dev/null 2>&1; then
    BUTTON_CLICKED=$(osascript -e 'display dialog "集成已完成！\n\n您希望现在打开目标项目文件夹吗？" buttons {"不了", "打开目录"} default button "打开目录" with icon note' 2>/dev/null)
    if [[ "$BUTTON_CLICKED" == *"button returned:打开目录"* ]]; then
        OPEN_ACTION="Yes"
    fi
fi

if [ "$OPEN_ACTION" == "Yes" ]; then
    open "$TARGET_DIR"
fi

echo -e "\n🚀 下一步建议:"
echo -e "1. ${BLUE}cd $TARGET_DIR${NC}"
echo -e "2. 编辑 CLAUDE.md，配置 Build/Test 命令"
echo -e "3. 试着问 Claude: '此项目的宪法原则是什么?'"
