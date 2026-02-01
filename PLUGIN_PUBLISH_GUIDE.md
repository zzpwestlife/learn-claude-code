# Claude Code 插件发布与使用指南

本指南将指导您如何将 `plugin_dist` 目录下的内容发布为标准 Claude Code 插件，并在其他项目中安装使用。

---

## 方式一：基于 Git 仓库发布（推荐，最简单）

这种方式适合个人使用或团队内部共享，不需要注册 NPM 账号。

### 1. 准备仓库
您需要将 `plugin_dist` 的内容作为一个独立的 Git 仓库发布。

```bash
# 1. 创建一个新的文件夹作为仓库根目录
mkdir fin-claude-plugin
cd fin-claude-plugin

# 2. 初始化 git
git init

# 3. 将 plugin_dist 下的所有内容复制到这里
cp -R /path/to/learn-claude-code/plugin_dist/* .
# 注意：确保 .claude-plugin 文件夹也被复制（它是隐藏文件夹）

# 4. 提交代码
git add .
git commit -m "Initial release of Fin Claude Plugin"

# 5. 推送到 GitHub/GitLab (假设您已创建远程仓库)
git remote add origin https://github.com/your-username/fin-claude-plugin.git
git branch -M main
git push -u origin main
```

### 2. 在其他项目中使用

目前 Claude Code 暂不支持直接通过 `git+url` 安装插件。推荐使用 **Git Clone** 方式安装到项目的 `.claude/plugins` 目录。

在目标项目根目录下运行：

```bash
# 1. 创建插件目录
mkdir -p .claude/plugins

# 2. 克隆插件
git clone https://github.com/zzpwestlife/fin-claude-plugin.git .claude/plugins/fin-claude-plugin
```

安装完成后，Claude Code 会自动识别 `.claude/plugins` 目录下的插件。您可能需要重启 Claude Code 会话才能生效。

或者在项目的 `.claude/settings.json` 中添加（如果需要显式配置）：

```json
{
  "plugins": {
    "fin-claude-plugin": {
      "path": "./.claude/plugins/fin-claude-plugin"
    }
  }
}
```

---

## 方式二：基于 NPM 发布（标准，公开分发）

这种方式适合公开分享给所有 Claude Code 用户。

### 1. 准备 package.json
在 `plugin_dist` 目录下创建一个标准的 `package.json`：

```bash
cd plugin_dist
npm init -y
```

编辑 `package.json`，确保包含以下关键字段：

```json
{
  "name": "fin-claude-plugin",
  "version": "1.0.0",
  "description": "Enterprise-grade development framework for Claude Code",
  "main": "index.js", 
  "files": [
    ".claude-plugin",
    "agents",
    "commands",
    "hooks",
    "skills",
    "README.md"
  ],
  "keywords": ["claude-code-plugin", "workflow", "productivity"]
}
```

### 2. 发布到 NPM

```bash
# 登录 NPM (如果没有账号需先注册)
npm login

# 发布
npm publish --access public
```

### 3. 在其他项目中使用

```bash
# 安装插件
claude plugin install fin-claude-plugin
```

---

## 方式三：本地开发/调试模式

在开发过程中，您不需要每次都发布。可以直接链接本地路径。

### 1. 链接插件

```bash
# 在目标项目中运行
claude plugin install file:///Users/admin/openSource/learn-claude-code/plugin_dist
```

---

## 验证安装

安装完成后，在 Claude Code 中运行：

```bash
/help
```

您应该能在输出列表中看到来自 `fin-claude-plugin` 的命令，例如 `/fin:dev`, `/sc:design` 等。

## 常见问题

### 1. 权限提示
首次运行插件命令时，Claude Code 可能会提示请求权限（如文件读写、网络访问）。这是由 `.claude-plugin/plugin.json` 中的 `permissions` 字段定义的正常行为，批准即可。

### 2. 依赖管理
如果您的 Skills (Python 脚本) 依赖第三方库：
- **Git/本地模式**：建议在脚本中包含自动检查和安装依赖的逻辑，或者在 README 中说明需要手动 `pip install`。
- **最佳实践**：尽量使用 Python 标准库，或者将依赖打包在插件中（Vendor）。
