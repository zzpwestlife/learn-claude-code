# Claude Code LSP 配置指南 (Golang 篇)

本文档专注于在**新电脑或新环境**中为 Claude Code 配置 Golang 语言服务器 (gopls)。

我们推荐两种方案：
*   **方案 A (推荐)**：使用 Piebald 社区市场。配置最简单。
*   **方案 B (本地)**：手动配置本地插件。适合网络受限环境。

---

## 1. 基础环境准备

首先确保系统安装了 Go 和 gopls。

### 1.1 安装 gopls
在终端执行：
```bash
go install golang.org/x/tools/gopls@latest
```

### 1.2 验证安装
运行以下命令，确保能输出版本号：
```bash
gopls version
```
> **重要**：如果提示 "command not found"，请确保 `$GOPATH/bin` (通常是 `~/go/bin`) 已添加到系统 `PATH` 环境变量中。

---

## 方案 A：使用 Piebald 社区市场 (最简单)

如果你的网络可以访问 GitHub，这是最快的方式。

### 1. 添加市场
```text
/plugin marketplace add Piebald-AI/claude-code-lsps
```

### 2. 安装 Go 插件
```text
/plugin install gopls@Piebald-AI
```

### 3. 验证
仅仅安装插件并不意味着 LSP 已经工作。请按以下步骤确认：

1.  **检查状态**：在 Claude Code 中输入 `/plugin list`，确保 `gopls` 显示为 `✔ enabled`。
2.  **功能测试**：
    *   **重启 Claude Code** (`/exit` 后重新运行)。
    *   **打开文件**：`/read test_lsp.go`。
    *   **测试诊断**：故意写错代码（如 `fmt.PrintLine`），询问 "Is there any error?"。如果能指出 "undefined"，说明 LSP 正常工作。


---

## 方案 B：本地手动配置

如果你需要离线配置，或方案 A 不可用。

### 1. 创建配置文件
在项目根目录创建 `claude_plugins/gopls` 文件夹，并创建两个文件。

**文件 1: `claude_plugins/gopls/plugin.json`**
```json
{
  "name": "gopls",
  "version": "1.0.0",
  "description": "Go Language Server"
}
```

**文件 2: `claude_plugins/gopls/.lsp.json`**
```json
{
  "go": {
    "command": "gopls",
    "args": [],
    "transport": "stdio",
    "extensionToLanguage": {
      ".go": "go",
      ".mod": "go.mod",
      ".sum": "go.sum"
    }
  }
}
```
> **关键点**：
> 1.  `"transport": "stdio"` 必须存在。
> 2.  如果不确定 `gopls` 是否在 PATH 中，建议将 `"command": "gopls"` 改为绝对路径 (例如 `/Users/username/go/bin/gopls`)。

### 2. 注册本地市场
假设你的配置目录是 `/Users/admin/my-project/claude_plugins`：

```text
/plugin marketplace add local_lsp /Users/admin/my-project/claude_plugins
```

### 3. 安装插件
```text
/plugin install gopls@local_lsp
```

### 4. 验证
步骤同“方案 A”的验证部分：先用 `/plugin list` 检查状态，再通过故意制造语法错误来测试 LSP 诊断功能。


---

## 常见问题排查

1.  **插件一直显示 "Searching"**：
    *   检查 `.lsp.json` 中是否包含了 `"transport": "stdio"`。
    *   尝试使用 `gopls` 的绝对路径。

2.  **Marketplace not found**：
    *   确保先运行了 `/plugin marketplace add`。
    *   确保安装命令使用了正确的后缀 (例如 `@local_lsp`)。
