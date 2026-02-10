# Claude Code 环境一键配置手册

本文档提供了 `setup_claude_env.sh` 脚本的详细使用说明，帮助你在新机器（MacOS）上快速配置定制版的 Claude Code 环境。

## 1. 简介

本工具旨在自动化以下繁琐步骤：
*   清理旧的 Claude Code 配置与缓存（解决 `Directory not empty` 等问题）。
*   安装定制版 CLI (`@futupb/ft-claude-code`)。
*   配置必要的补丁（修复 Statsig 挂起、权限错误）。
*   自动安装插件 (Plugins) 和 MCP 服务器。
*   集中管理 API Key 配置。

## 2. 环境准备 (Prerequisites)

在运行脚本之前，请确保目标机器满足以下条件：

### 2.1 基础软件
*   **操作系统**: macOS (推荐 Sonoma 或更新版本)。
*   **Node.js**: 必须安装。推荐版本 `v24.4.0` 或更高。
    ```bash
    node -v
    # 如果未安装，推荐使用 nvm 安装:
    # nvm install 24
    ```
*   **网络**: 需连接内网 VPN (脚本会检查 `registry.npm.oa.com` 连接性)。

### 2.2 配置文件 (.env)
脚本依赖 `.env` 文件来获取 API Key。首次运行若不存在，脚本会从 `.env.example` 自动创建。

请编辑 `.env` 文件，填入以下关键信息：

```ini
# --- 必须配置 ---
# 定制版 CLI 认证 Key (避免交互式弹窗)
ANTHROPIC_AUTH_TOKEN="你的FUTU_AI_KEY"
ANTHROPIC_AUTH_USER_EMAIL="你的邮箱@futunn.com"

# --- MCP 依赖 (选填，不填则跳过对应 MCP 安装) ---
# GitHub MCP
GITHUB_TOKEN="ghp_xxxx"
# Tavily Search MCP
TAVILY_API_KEY="tvly-xxxx"
# Zhipu / BigModel
Z_AI_API_KEY=""
BIGMODEL_API_KEY=""
```

## 3. 定制化配置 (setup_config.json)

所有插件和 MCP 的配置已提取到 `setup_config.json` 中，无需修改 Shell 脚本即可调整。

### 3.1 配置文件结构

```json
{
  "marketplaces": [ ... ],  // 插件市场列表
  "plugins": [ ... ],       // 需安装的插件列表
  "mcps": {
    "std": [ ... ],         // 标准 MCP (stdio 模式)
    "http": [ ... ]         // HTTP MCP (sse 模式)
  }
}
```

### 3.2 常用操作

*   **添加插件**: 在 `plugins` 数组中追加插件名 (如 `"my-plugin@marketplace"`)。
*   **添加 MCP**: 在 `mcps.std` 中添加对象：
    ```json
    {
      "name": "my-tool",
      "package": "my-npm-package",
      "condition": "MY_ENV_VAR",  // 可选：只有当 .env 中存在 MY_ENV_VAR 时才安装
      "env": {
        "API_KEY": "${MY_ENV_VAR}" // 引用环境变量
      }
    }
    ```

## 4. 执行安装

1.  赋予脚本执行权限：
    ```bash
    chmod +x setup_claude_env.sh
    ```

2.  运行脚本：
    ```bash
    ./setup_claude_env.sh
    ```

### 安装过程说明
*   **清理阶段**: 脚本会自动清理 `~/.claude` 和 `~/.npm/_npx` 缓存，可能会提示 `sudo` 密码以修复权限 (请自行备份)。
*   **安装阶段**: 自动从内网源下载 CLI。
*   **配置阶段**: 解析 `setup_config.json` 并逐个安装插件和 MCP。

## 5. 验证安装

安装完成后，你可以通过以下命令验证环境：

1.  **检查版本**:
    ```bash
    claude --version
    # 应显示 @futupb/ft-claude-code 的版本
    ```

2.  **检查 MCP 状态**:
    ```bash
    claude mcp list
    # 应显示 setup_config.json 中配置且 .env 中有 Key 的所有服务
    # 例如: memory, filesystem, github (如果配置了Token) 等
    ```

3.  **检查插件状态**:
    ```bash
    claude plugin list
    ```

## 6. 常见问题排查 (Troubleshooting)

### Q1: `rm: /Users/admin/.claude: Directory not empty`
**原因**: 某个进程锁定了该目录。
**解决**: 脚本已内置 `pkill` 和 `chflags` 清理逻辑。如果仍报错，请手动重启机器或运行 `lsof +D ~/.claude` 查看占用进程。

### Q2: MCP 安装失败 (404 Not Found)
**原因**: 内网源可能没有某些开源 MCP 包。
**解决**: 脚本已强制标准 MCP 使用 `registry.npmjs.org` 公网源。确保你的网络能访问公网 npm。

### Q3: `EPERM: operation not permitted`
**原因**: macOS 扩展属性 (com.apple.quarantine) 或文件权限问题。
**解决**: 脚本会自动执行 `xattr -c` 和 `chmod` 修复。如果问题持续，请尝试 `sudo ./setup_claude_env.sh` (不推荐，可能会导致文件归属权问题)。

### Q4: 脚本卡在 `Loading configuration...`
**原因**: 网络连接 `registry.npm.oa.com` 超时。
**解决**: 检查 VPN 连接。

---
**维护**: 修改 `setup_config.json` 后，再次运行 `./setup_claude_env.sh` 即可应用最新配置。
