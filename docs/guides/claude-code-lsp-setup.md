# Claude Code (CLI) Golang LSP 配置指南

本文档旨在指导 macOS 用户如何在 Claude Code 命令行工具中开启并配置 Golang 语言服务器 (LSP)，以实现代码跳转、精准搜索和实时错误检查，从而获得 IDE 级的开发体验。

## 为什么需要开启 LSP？

默认情况下，Claude Code 使用 `grep` 进行文本搜索，这在大型项目中可能导致：
- **速度慢**：搜索结果包含大量无关信息，处理耗时 30-60 秒。
- **不准确**：无法区分代码定义、注释或字符串。
- **Token 消耗大**：大量无关上下文被发送给模型。

开启 LSP (Language Server Protocol) 后，Claude Code 可以直接与 Go 语言服务器通信，实现：
- **毫秒级响应**：定位定义仅需 ~50ms。
- **100% 准确**：基于语义的代码理解，而非文本匹配。
- **智能功能**：支持跳转定义 (Go to Definition)、查找引用 (Find References) 等。

---

## 前置条件

- **操作系统**: macOS
- **Shell**: zsh (macOS 默认) 或 bash
- **工具**: 
  - [Go](https://go.dev/dl/) (建议 1.18+)
  - Claude Code CLI

## 配置步骤

### 第一步：安装 Go 语言服务器 (gopls)

`gopls` (Go Language Server) 是 Google 官方提供的 Go 语言 LSP 实现。

在终端中执行以下命令安装：

```bash
go install golang.org/x/tools/gopls@latest
```

**验证安装**：
确保 `gopls` 在你的 PATH 中：

```bash
gopls version
```
*如果提示找不到命令，请确保 `$GOPATH/bin` 或 `$HOME/go/bin` 已添加到你的 PATH 环境变量中。*

### 第二步：配置环境变量

你需要设置 `ENABLE_LSP_TOOL=1` 来告诉 Claude Code 启用 LSP 功能。

**推荐方式：修改 Claude 配置文件** (持久生效)

编辑或创建 `~/.claude/settings.json` 文件：

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  }
}
```

**备选方式：Shell 环境变量**

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
export ENABLE_LSP_TOOL=1
```
然后执行 `source ~/.zshrc` 生效。

### 第三步：在 Claude Code 中安装插件

1. 启动 Claude Code：
   ```bash
   claude
   ```

2. 在 Claude Code 交互界面中，输入 `/plugin` 命令进入插件管理。

3. 搜索并安装 Go 语言插件。通常可以通过以下对话完成：
   > "Please install the official gopls-lsp plugin."
   
   或者直接让 Claude 帮你查找：
   > "Search for a plugin for Golang LSP."

   *注：官方插件通常命名为 `gopls-lsp` 或类似名称，安装后 Claude 会自动检测系统中的 `gopls` 二进制文件。*

### 第四步：验证配置

重启 Claude Code，然后输入以下 Prompt 进行验证：

> "Check if the LSP tool is active and what capabilities it has."

或者尝试一个具体的代码查询：

> "Where is the `main` function defined? Use LSP."

如果配置成功，Claude 会直接给出文件路径和行号，而不会显示 "Running grep..."。

---

## 进阶配置：优化项目提示词 (CLAUDE.md)

为了确保 Claude 优先使用 LSP 而非 grep，建议在项目根目录的 `CLAUDE.md` 文件中添加以下指令：

```markdown
## Tool Usage Guidelines
- **Code Navigation**: For finding definitions, ALWAYS use `goToDefinition` or `workspaceSymbol` via LSP first.
- **References**: Use `findReferences` for tracking usage.
- **Fallback**: Only use `grep` or text search for comments, strings, or when LSP returns no results.
- **Type Checking**: Regularly check for diagnostics after significant edits using LSP.
```

## 常见问题

**Q: 遇到 `Extra inputs are not permitted` 报错怎么办？**
A: 这通常是由于启用了过多的 MCP 工具导致 Claude 的上下文窗口（Context Window）被占满。
   *   **原因**：每个启用的 MCP 工具都会占用一定的 token。当启用的 MCP 工具过多时，可能会超出上下文限制，导致此报错。
   *   **验证方法**：使用 `/context` 命令查看当前的 Context Usage。如果 `MCP tools` 的占用比例过高，或者总 Token 数接近上限，即确认是此问题。
   *   **解决方法**：
       1.  **禁用不必要的 MCP**：使用 `/mcp` 管理工具，禁用当前会话不需要的 MCP 服务器。
       2.  **重启会话**：尝试使用 `/compact` 或重启 Claude Code 会话来清理上下文。
       3.  **检查 defer_loading（次要原因）**：在极少数情况下，也可能是 Claude Code v2.1.69+ 引入新特性 `defer_loading` (延迟加载) 时的兼容性问题，导致旧版插件不支持。此时可尝试升级插件。

**Q: 开启 LSP 后 Claude 反应变慢？**
A: 初始化 LSP 可能需要几秒钟（特别是大项目索引时），但之后的查询应该是毫秒级的。

**Q: `gopls` 报错或无法连接？**
A: 确保你在项目根目录下运行 `claude`，且该目录包含有效的 `go.mod` 文件。LSP 依赖项目上下文。

**Q: 支持其他语言吗？**
A: 支持。Python (pyright), TypeScript (typescript-language-server), Rust (rust-analyzer) 等均支持，配置流程类似。
