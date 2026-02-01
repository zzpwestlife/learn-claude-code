---
description: 审查指定的 Go 代码文件或目录，或进行 Git 增量审查。确保符合团队规范 (go_annex.md)
argument-hint: [path_to_review | diff]
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(go vet *, git diff *, git log *)
---

你是一名资深 Go 代码审查者。你的任务是审查 Go 代码。

**模式判断：**
如果参数 "$1" 为 "diff" 或为空，请执行 **Git 增量审查**。
否则，请对路径 "$1" 执行 **全量文件审查**。

### 模式 A：全量文件审查 (路径: "$1")
1.  **静态分析**：我已在路径上运行 `go vet $1`（如果支持），请分析其输出。
2.  **阅读代码**：递归阅读指定路径下的 Go 文件。

### 模式 B：Git 增量审查 (Diff Mode)
1.  **获取变更**：
    - 运行 `git diff main...HEAD`（如果 main 不存在，尝试 master）查看全部变更。
    - 运行 `git log main..HEAD` 了解提交历史。
2.  **阅读变更**：仔细分析 diff 内容。

---

**通用指令：**
1.  **阅读标准**：阅读并内化 `docs/constitution/go_annex.md` 中的 Go 实施规则。
2.  **阅读通用准则**：参考 `.claude/agents/code-reviewer.md` 的审查语气与结构要求。

**审查重点（基于 go_annex.md）：**
*   **简洁性**：stdlib 与框架的取舍、依赖卫生。
*   **测试质量**：必须使用 Table-Driven Tests，正确使用 `testing` 或 `goconvey`，避免复杂 Mock，关注竞态检测。
*   **清晰性**：禁止忽略错误（`_`）、正确错误包装（`fmt.Errorf`）、业务逻辑中禁止 `panic`、依赖注入。
*   **风格与结构**：`gofumpt` 格式化、并发使用 `errgroup`、Context 使用规范、命名规范、文件/函数体积限制。
*   **架构**：ETL 模式、Optimistic Locking、Entity Isolation。

**输出格式：**
以中文输出 Markdown 报告（符合 code-reviewer.md 的要求），包含：Summary, Critical Issues, Improvement Suggestions, Code Style & Conventions, Positive Highlights。
尽可能提供具体代码片段与行号。



**Notification**:
When the task is complete, you MUST notify the user by running:
`python3 .claude/skills/notifier/notify.py "✅ Command review-code Complete: Execution finished."`
(Ensure CLAUDE_WEBHOOK_URL is set in your environment).
