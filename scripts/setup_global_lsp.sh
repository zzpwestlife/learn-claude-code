#!/bin/bash

# 设置目标目录
TARGET_DIR="$HOME/.claude/claude_plugins"
SOURCE_DIR="./claude_plugins"

echo "正在准备全局 Claude 插件目录..."

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误：当前目录下未找到 claude_plugins 文件夹。"
    echo "请确保您在 learn-claude-code 项目根目录下运行此脚本。"
    exit 1
fi

# 创建目标目录
echo "创建目录: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# 复制插件文件
echo "复制插件文件到全局目录..."
# 使用 . 确保复制隐藏文件 (macOS/Linux 兼容)
cp -R "$SOURCE_DIR/." "$TARGET_DIR/"

echo "正在从全局目录同步插件到当前项目..."
mkdir -p ./claude_plugins
# 使用 cp -L 复制软链接指向的实际文件，或者直接复制目录
# 这里我们直接从源头复制，确保是实体文件
cp -R "$TARGET_DIR/"* ./claude_plugins/

if [ $? -eq 0 ]; then
    echo "✅ 成功！插件配置已准备就绪。"
    echo ""
    echo "由于直接路径安装可能遇到兼容性问题，推荐使用【本地市场】模式："
    echo ""
    echo "1. 首先添加本地插件市场（仅需执行一次）："
    echo "   /plugin marketplace add local_lsp $PROJECT_ROOT/claude_plugins"
    echo ""
    echo "2. 然后从本地市场安装插件："
    echo "   /plugin install gopls@local_lsp"
    echo "   /plugin install intelephense@local_lsp"
    echo ""
    echo "3. 验证安装："
    echo "   /plugin list"
    echo ""
else
    echo "❌ 复制失败，请检查权限。"
    exit 1
fi
