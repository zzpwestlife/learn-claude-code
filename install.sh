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

# 去除末尾的斜杠，避免路径中出现 //
TARGET_DIR="${TARGET_DIR%/}"

echo -e "✅ 目标项目: ${BLUE}$TARGET_DIR${NC}"

# ==========================================
# 2. 语言类型选择 (Language Selection)
# ==========================================

LANG_CHOICE=""

# 尝试通过文件探测语言
if [ -f "$TARGET_DIR/go.mod" ]; then
    DETECTED_LANG="Go"
elif [ -f "$TARGET_DIR/composer.json" ]; then
    DETECTED_LANG="PHP"
elif [ -f "$TARGET_DIR/requirements.txt" ] || [ -f "$TARGET_DIR/pyproject.toml" ]; then
    DETECTED_LANG="Python"
fi

if [ -n "$DETECTED_LANG" ]; then
    echo -e "🔍 检测到项目语言可能为: ${GREEN}$DETECTED_LANG${NC}"
fi

# 如果是交互模式（无命令行参数），询问语言
if command -v osascript >/dev/null 2>&1; then
    LANG_CHOICE=$(osascript -e 'try
        choose from list {"Go", "PHP", "Python"} with prompt "请选择项目主要语言\n(将安装对应的配置文件和规则):" default items {"'"${DETECTED_LANG:-Go}"'"} OK button name "确定" cancel button name "取消"
    on error
        return "Cancel"
    end try' 2>/dev/null)
    
    if [ "$LANG_CHOICE" == "false" ] || [ "$LANG_CHOICE" == "Cancel" ]; then
        echo -e "${YELLOW}用户取消了操作。${NC}"
        exit 0
    fi
else
    # 命令行交互
    echo -e "请选择项目语言 (Go/PHP/Python) [默认: ${DETECTED_LANG:-Go}]:"
    read -r USER_INPUT
    LANG_CHOICE="${USER_INPUT:-${DETECTED_LANG:-Go}}"
fi

# 规范化输入
if [[ "$LANG_CHOICE" =~ ^[Gg][Oo]$ ]]; then
    PROFILE="go"
    LANG_NAME="Go"
elif [[ "$LANG_CHOICE" =~ ^[Pp][Hh][Pp]$ ]]; then
    PROFILE="php"
    LANG_NAME="PHP"
elif [[ "$LANG_CHOICE" =~ ^[Pp][Yy][Tt][Hh][Oo][Nn]$ ]]; then
    PROFILE="python"
    LANG_NAME="Python"
else
    echo -e "${RED}错误: 不支持的语言 '$LANG_CHOICE'${NC}"
    exit 1
fi

echo -e "✅ 选择语言配置: ${BLUE}$LANG_NAME${NC}"

# ==========================================
# 3. 执行安装 (Installation)
# ==========================================

echo -e "\n📦 正在安装核心文件..."

# 1. 复制通用宪法
cp -v "$SOURCE_DIR/constitution.md" "$TARGET_DIR/"

# 2. 复制语言特定的 CLAUDE.md 和 AGENTS.md
echo "📝 安装 $LANG_NAME 专属配置..."
cp -v "$SOURCE_DIR/profiles/$PROFILE/CLAUDE.md" "$TARGET_DIR/"
cp -v "$SOURCE_DIR/profiles/$PROFILE/AGENTS.md" "$TARGET_DIR/"

# 3. 复制 Agent 配置 (合并模式)
echo "🧠 复制 Agent 配置..."
mkdir -p "$TARGET_DIR/.claude/agents"
# 复制 agents 下的所有文件
cp -v "$SOURCE_DIR/.claude/agents/"* "$TARGET_DIR/.claude/agents/"
# 复制 settings.local.json (如果不存在则复制，如果存在则不覆盖? 或者总是覆盖? 模板通常不覆盖本地设置，但这是初始化脚本)
# 这里假设用户想要从模板更新，所以我们复制，但给个提示
if [ -f "$SOURCE_DIR/.claude/settings.local.json" ]; then
    cp -v "$SOURCE_DIR/.claude/settings.local.json" "$TARGET_DIR/.claude/"
fi

# 4. 复制语言附录
echo "📚 复制 $LANG_NAME 语言附录..."
mkdir -p "$TARGET_DIR/docs/constitution"

case "$LANG_NAME" in
    "Go")
        cp -v "$SOURCE_DIR/docs/constitution/go_annex.md" "$TARGET_DIR/docs/constitution/"
        ;;
    "PHP")
        cp -v "$SOURCE_DIR/docs/constitution/php_annex.md" "$TARGET_DIR/docs/constitution/"
        ;;
    "Python")
        cp -v "$SOURCE_DIR/docs/constitution/python_annex.md" "$TARGET_DIR/docs/constitution/"
        ;;
esac

# 5. 复制 Slash Commands
echo "⚡️ 复制 $LANG_NAME Slash Commands..."
mkdir -p "$TARGET_DIR/.claude/commands"

# 5.1 复制通用命令 (Common Commands)
if ls "$SOURCE_DIR/.claude/commands/"*.md 1> /dev/null 2>&1; then
    echo "  -> 复制通用命令..."
    cp -v "$SOURCE_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"
fi

# 5.2 复制语言特定命令 (Language Specific Commands)
if [ -d "$SOURCE_DIR/.claude/commands/$PROFILE" ]; then
    echo "  -> 复制 $LANG_NAME 专属命令..."
    cp -v "$SOURCE_DIR/.claude/commands/$PROFILE/"* "$TARGET_DIR/.claude/commands/"
fi

# 6. 复制 Hooks
echo "🪝 复制 Hooks..."
mkdir -p "$TARGET_DIR/.claude/hooks"

# 6.1 复制通用 Hooks
# 使用 find 只复制文件，不复制子目录
find "$SOURCE_DIR/.claude/hooks" -maxdepth 1 -type f -not -name ".*" -exec cp -v {} "$TARGET_DIR/.claude/hooks/" \; 2>/dev/null || true

# 6.2 复制语言特定 Hooks
if [ -d "$SOURCE_DIR/.claude/hooks/$PROFILE" ]; then
    # 检查目录下是否有文件
    if ls "$SOURCE_DIR/.claude/hooks/$PROFILE/"* 1> /dev/null 2>&1; then
        echo "  -> 复制 $LANG_NAME 专属 Hooks..."
        cp -v "$SOURCE_DIR/.claude/hooks/$PROFILE/"* "$TARGET_DIR/.claude/hooks/"
    else
        echo "  -> (无 $LANG_NAME 专属 Hooks，跳过)"
    fi
fi

# 7. 复制 Skills
echo "🛠️ 复制 Skills..."
mkdir -p "$TARGET_DIR/.claude/skills"
if [ -d "$SOURCE_DIR/.claude/skills" ]; then
    cp -r "$SOURCE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/" 2>/dev/null || true
    echo "  -> Skills 复制完成"
else
    echo "  -> (无 Skills 目录，跳过)"
fi

# 8. 复制其他配置文件
if [ -f "$SOURCE_DIR/.claude/changelog_config.json" ]; then
    echo "⚙️ 复制 changelog_config.json..."
    cp -v "$SOURCE_DIR/.claude/changelog_config.json" "$TARGET_DIR/.claude/"
fi

# 确保所有脚本具有执行权限
chmod +x "$TARGET_DIR/.claude/hooks/"* 2>/dev/null || true
# 递归赋予 skills 目录下脚本执行权限
if [ -d "$TARGET_DIR/.claude/skills" ]; then
    find "$TARGET_DIR/.claude/skills" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;
fi

echo -e "\n${GREEN}🎉 安装完成!${NC}"
echo -e "请检查 $TARGET_DIR/CLAUDE.md 并根据项目实际情况微调命令。"
