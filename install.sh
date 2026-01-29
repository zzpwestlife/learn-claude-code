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
# 辅助函数: 安全复制 (Safe Copy)
# ==========================================
# 参数: $1=源文件, $2=目标路径(文件或目录)
safe_copy() {
    local src="$1"
    local dest="$2"
    local dest_file
    
    # 检查源文件是否存在
    if [ ! -e "$src" ]; then
        return
    fi
    
    # 计算目标文件完整路径
    if [ -d "$dest" ]; then
        dest_file="$dest/$(basename "$src")"
    else
        dest_file="$dest"
    fi
    
    # 确保目标目录存在
    mkdir -p "$(dirname "$dest_file")"
    
    if [ -f "$dest_file" ]; then
        # 优先检查内容是否一致，如果一致则直接跳过
        if cmp -s "$src" "$dest_file"; then
            echo -e "${GREEN}✅ 已跳过 (内容一致): $(basename "$dest_file")${NC}"
            return
        fi

        echo -e "${YELLOW}⚠️  目标文件已存在: $(basename "$dest_file")${NC}"
        
        # 特殊处理 Makefile 的合并逻辑
        if [[ "$(basename "$dest_file")" == "Makefile" ]]; then
            local action="skip"
            
            if command -v osascript >/dev/null 2>&1; then
                # GUI 弹窗
                BTN_CLICKED=$(osascript -e 'try
                    display dialog "Makefile 已存在: '"$(basename "$dest_file")"'\n\n请选择操作：" buttons {"跳过", "覆盖", "智能合并"} default button "智能合并" with icon caution
                    return button returned of result
                on error
                    return "跳过"
                end try' 2>/dev/null)
                
                if [ "$BTN_CLICKED" == "覆盖" ]; then
                    action="overwrite"
                elif [ "$BTN_CLICKED" == "智能合并" ]; then
                    action="merge"
                fi
            else
                # 命令行交互
                echo -e "${YELLOW}Makefile 已存在，请选择操作: [s]跳过 / [o]覆盖 / [m]智能合并 (默认: m)${NC}"
                read -r USER_RESP
                if [[ "$USER_RESP" =~ ^[Oo]$ ]]; then
                    action="overwrite"
                elif [[ "$USER_RESP" =~ ^[Ss]$ ]]; then
                    action="skip"
                else
                    action="merge"
                fi
            fi
            
            if [ "$action" == "overwrite" ]; then
                cp -v "$src" "$dest_file"
            elif [ "$action" == "merge" ]; then
                echo "🔄 正在尝试智能合并 Makefile..."
                # 检查 python3 是否存在
                if command -v python3 >/dev/null 2>&1; then
                    python3 "$SOURCE_DIR/scripts/merge_makefile.py" "$src" "$dest_file"
                else
                    echo -e "${RED}错误: 未找到 python3，无法执行智能合并。回退到跳过操作。${NC}"
                fi
            else
                echo -e "${YELLOW}🚫 已跳过: $(basename "$dest_file")${NC}"
            fi
            return
        fi

        local should_overwrite="false"
        
        if command -v osascript >/dev/null 2>&1; then
            # GUI 弹窗
            BTN_CLICKED=$(osascript -e 'try
                display dialog "文件已存在: '"$(basename "$dest_file")"'\n\n是否覆盖？" buttons {"跳过", "覆盖"} default button "跳过" with icon caution
                return button returned of result
            on error
                return "跳过"
            end try' 2>/dev/null)
            
            if [ "$BTN_CLICKED" == "覆盖" ]; then
                should_overwrite="true"
            fi
        else
            # 命令行交互
            echo -e "${YELLOW}是否覆盖? (y/N)${NC}"
            read -r USER_RESP
            if [[ "$USER_RESP" =~ ^[Yy]$ ]]; then
                should_overwrite="true"
            fi
        fi
        
        if [ "$should_overwrite" == "true" ]; then
            cp -v "$src" "$dest_file"
        else
            echo -e "${YELLOW}🚫 已跳过: $(basename "$dest_file")${NC}"
        fi
    else
        # 文件不存在，直接复制
        cp -v "$src" "$dest_file"
    fi
}

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
safe_copy "$SOURCE_DIR/constitution.md" "$TARGET_DIR/.claude/"

# 1.1 创建 SDD 规范目录 (specs)
echo "📂 创建 specs 目录..."
if [ ! -d "$TARGET_DIR/specs" ]; then
    mkdir -p "$TARGET_DIR/specs"
    echo "  -> 已创建 specs/ (用于存放 spec.md, plan.md 等)"
else
    echo "  -> specs/ 已存在"
fi

# 1.2 复制团队安全配置 (settings.json)
if [ -f "$SOURCE_DIR/.claude/settings.json" ]; then
    echo "🛡️ 安装团队安全配置 (settings.json)..."
    mkdir -p "$TARGET_DIR/.claude"
    safe_copy "$SOURCE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"
fi

# 2. 复制语言特定的 CLAUDE.md 和 AGENTS.md
echo "📝 安装 $LANG_NAME 专属配置..."
safe_copy "$SOURCE_DIR/profiles/$PROFILE/CLAUDE.md" "$TARGET_DIR/"
safe_copy "$SOURCE_DIR/profiles/$PROFILE/AGENTS.md" "$TARGET_DIR/.claude/"

# 3. 复制 Agent 配置 (合并模式)
echo "🧠 复制 Agent 配置..."
mkdir -p "$TARGET_DIR/.claude/agents"
# 逐个文件复制以支持覆盖检查
for file in "$SOURCE_DIR/.claude/agents/"*; do
    if [ -f "$file" ]; then
        safe_copy "$file" "$TARGET_DIR/.claude/agents/"
    fi
done

# 复制 settings.local.json
if [ -f "$SOURCE_DIR/.claude/settings.local.json" ]; then
    safe_copy "$SOURCE_DIR/.claude/settings.local.json" "$TARGET_DIR/.claude/"
fi

# 4. 复制语言附录
echo "📚 复制 $LANG_NAME 语言附录..."
mkdir -p "$TARGET_DIR/.claude/constitution"

case "$LANG_NAME" in
    "Go")
        safe_copy "$SOURCE_DIR/docs/constitution/go_annex.md" "$TARGET_DIR/.claude/constitution/"
        safe_copy "$SOURCE_DIR/profiles/go/Makefile" "$TARGET_DIR/"
        ;;
    "PHP")
        safe_copy "$SOURCE_DIR/docs/constitution/php_annex.md" "$TARGET_DIR/.claude/constitution/"
        ;;
    "Python")
        safe_copy "$SOURCE_DIR/docs/constitution/python_annex.md" "$TARGET_DIR/.claude/constitution/"
        ;;
esac

# 5. 复制 Slash Commands
echo "⚡️ 复制 $LANG_NAME Slash Commands..."
mkdir -p "$TARGET_DIR/.claude/commands"

# 5.1 复制通用命令 (Common Commands)
if ls "$SOURCE_DIR/.claude/commands/"*.md 1> /dev/null 2>&1; then
    echo "  -> 复制通用命令..."
    for file in "$SOURCE_DIR/.claude/commands/"*.md; do
        safe_copy "$file" "$TARGET_DIR/.claude/commands/"
    done
fi

# 5.2 复制语言特定命令 (Language Specific Commands)
if [ -d "$SOURCE_DIR/.claude/commands/$PROFILE" ]; then
    echo "  -> 复制 $LANG_NAME 专属命令..."
    for file in "$SOURCE_DIR/.claude/commands/$PROFILE/"*; do
        if [ -f "$file" ]; then
             safe_copy "$file" "$TARGET_DIR/.claude/commands/"
        fi
    done
fi

# 6. 复制 Hooks
echo "🪝 复制 Hooks..."
mkdir -p "$TARGET_DIR/.claude/hooks"

# 6.1 复制通用 Hooks
# 查找文件并逐个复制
for file in "$SOURCE_DIR/.claude/hooks/"*; do
    if [ -f "$file" ] && [[ "$(basename "$file")" != .* ]]; then
        safe_copy "$file" "$TARGET_DIR/.claude/hooks/"
    fi
done

# 6.2 复制语言特定 Hooks
if [ -d "$SOURCE_DIR/.claude/hooks/$PROFILE" ]; then
    if ls "$SOURCE_DIR/.claude/hooks/$PROFILE/"* 1> /dev/null 2>&1; then
        echo "  -> 复制 $LANG_NAME 专属 Hooks..."
        for file in "$SOURCE_DIR/.claude/hooks/$PROFILE/"*; do
            if [ -f "$file" ]; then
                safe_copy "$file" "$TARGET_DIR/.claude/hooks/"
            fi
        done
    else
        echo "  -> (无 $LANG_NAME 专属 Hooks，跳过)"
    fi
fi

# 7. 复制 Skills
echo "🛠️ 复制 Skills..."
mkdir -p "$TARGET_DIR/.claude/skills"
if [ -d "$SOURCE_DIR/.claude/skills" ]; then
    # Skills 是目录结构，简化处理：询问是否更新 Skills 目录
    # 如果目标目录存在，先询问一次
    if [ -d "$TARGET_DIR/.claude/skills" ]; then
        echo -e "${YELLOW}⚠️  目标 .claude/skills 目录已存在${NC}"
        SKILLS_ACTION="skip"
        
        if command -v osascript >/dev/null 2>&1; then
            BTN_CLICKED=$(osascript -e 'try
                display dialog "目标 .claude/skills 目录已存在。\n\n是否覆盖/合并更新？" buttons {"跳过", "合并更新"} default button "跳过" with icon caution
                return button returned of result
            on error
                return "跳过"
            end try' 2>/dev/null)
             if [ "$BTN_CLICKED" == "合并更新" ]; then
                SKILLS_ACTION="merge"
            fi
        else
            echo -e "${YELLOW}是否合并更新 Skills? (y/N)${NC}"
            read -r USER_RESP
            if [[ "$USER_RESP" =~ ^[Yy]$ ]]; then
                SKILLS_ACTION="merge"
            fi
        fi
        
        if [ "$SKILLS_ACTION" == "merge" ]; then
            cp -r "$SOURCE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
            echo "  -> Skills 已合并更新"
        else
            echo "  -> 已跳过 Skills 更新"
        fi
    else
        # 不存在则直接复制
        cp -r "$SOURCE_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
        echo "  -> Skills 复制完成"
    fi
else
    echo "  -> (无 Skills 目录，跳过)"
fi

# 8. 复制其他配置文件
if [ -f "$SOURCE_DIR/.claude/changelog_config.json" ]; then
    echo "⚙️ 复制 changelog_config.json..."
    safe_copy "$SOURCE_DIR/.claude/changelog_config.json" "$TARGET_DIR/.claude/"
fi

# ==========================================
# 9. Post-Installation Path Adjustments
# ==========================================
echo "🔧 调整配置文件路径引用..."

# Update CLAUDE.md in target to point to .claude/AGENTS.md
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    sed -i '' 's/@AGENTS.md/@.claude\/AGENTS.md/g' "$TARGET_DIR/CLAUDE.md"
fi

# Update AGENTS.md in target (.claude/AGENTS.md)
if [ -f "$TARGET_DIR/.claude/AGENTS.md" ]; then
    # Replace ../../constitution.md with constitution.md (sibling)
    sed -i '' 's/(\.\.\/\.\.\/constitution.md)/(constitution.md)/g' "$TARGET_DIR/.claude/AGENTS.md"
    
    # Replace ../../docs/constitution/ with constitution/ (child folder)
    sed -i '' 's/(\.\.\/\.\.\/docs\/constitution\//(constitution\//g' "$TARGET_DIR/.claude/AGENTS.md"
fi

# Update code-reviewer agent
if [ -f "$TARGET_DIR/.claude/agents/code-reviewer.md" ]; then
    sed -i '' 's/docs\/constitution\//.claude\/constitution\//g' "$TARGET_DIR/.claude/agents/code-reviewer.md"
fi

# Update review-code commands
if [ -d "$TARGET_DIR/.claude/commands" ]; then
    find "$TARGET_DIR/.claude/commands" -name "review-code.md" -exec sed -i '' 's/docs\/constitution\//.claude\/constitution\//g' {} \;
fi

# 确保所有脚本具有执行权限
chmod +x "$TARGET_DIR/.claude/hooks/"* 2>/dev/null || true
# 递归赋予 skills 目录下脚本执行权限
if [ -d "$TARGET_DIR/.claude/skills" ]; then
    find "$TARGET_DIR/.claude/skills" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;
fi

echo -e "\n${GREEN}🎉 安装完成!${NC}"
echo -e "请检查 $TARGET_DIR/CLAUDE.md 并根据项目实际情况微调命令。"
