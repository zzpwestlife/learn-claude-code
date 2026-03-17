# Claude Code + Chrome Remote Debugging 配置指南

本文档记录了如何配置 Claude Code 以便“丝滑接管”当前已登录的 Chrome 浏览器（保留 Cookie、Session 和后台权限），而不是启动一个新的无头浏览器。

## 核心原理
利用 Chrome 146+ 版本引入的 `chrome://inspect/#remote-debugging` 远程调试开关，配合 MCP 的 `autoConnect` 模式，实现无缝连接。

## 前置条件
1.  **Google Chrome**: 版本需 >= 146。
2.  **Claude Code**: 已安装并登录。

---

## 🚀 快速配置步骤

### 第一步：Chrome 设置（一次性）
1.  正常启动 Chrome（点击图标即可，无需命令行）。
2.  在地址栏输入并回车：
    ```text
    chrome://inspect/#remote-debugging
    ```
3.  **勾选** `Allow remote debugging` 选项。
    > 建议保持此页面开启，确保调试服务处于监听状态。

### 第二步：Claude MCP 配置
在终端运行以下命令，添加支持自动连接的 MCP 服务：

```bash
# 如果之前配置过，先移除旧的（可选）
claude mcp remove chrome-devtools

# 添加新配置
claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest --autoConnect
```

### 第三步：首次连接授权
1.  在 Claude Code 中下达任意浏览器指令，例如：
    > "截取当前 Chrome 标签页的屏幕截图"
2.  **关键动作**：Chrome 浏览器会立即弹出一个提示框（"Allow remote debugging?"）。
3.  点击 **【Allow】**。

---

## 🛠 常见问题排查

### 现象 1：Claude 打开了一个新的“无痕/空白”浏览器窗口
*   **原因**：自动连接失败，MCP 回退到了启动新实例的默认行为。
*   **检查点**：
    1.  确认 Chrome 版本是否 >= 146。
    2.  确认 `chrome://inspect/#remote-debugging` 中的开关已勾选。
    3.  **重启 Chrome**：使用 `Cmd+Q` 彻底退出 Chrome 后再重新打开。

### 现象 2：一直提示 "Could not connect to Chrome"
*   **解决方法**：
    1.  确保 Chrome 是运行状态。
    2.  尝试在 Claude 中输入 `/restart` 重启 MCP 服务。
    3.  如果仍然不行，使用**备用方案（强制端口模式）**。

---

## 🚑 备用方案：强制端口模式（100% 可行）
如果上述自动连接始终不稳定，可以使用传统的“指定端口”方式。

**1. 启动 Chrome（需使用命令行）**
必须先关闭所有 Chrome 窗口（Cmd+Q），然后运行：
```zsh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222
```

**2. 配置 Claude**
```bash
claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest --browserUrl http://127.0.0.1:9222
```

**3. 简化启动（可选）**
在 `~/.zshrc` 中添加别名，方便日后启动：
```bash
alias debug-chrome='"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222'
```
