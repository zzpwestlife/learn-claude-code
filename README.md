# Learn Claude Code 学习套件

**Learn Claude Code** 是一个标准化的 Claude Code 配置套件，旨在帮助开发者快速将最佳实践集成到自己的项目中。它通过引入“宪法机制”和“角色化 Agent”，确保 AI 生成的代码安全、健壮且易于维护。

现在支持多语言配置（Go / PHP），可根据项目类型自动适配。

---

## 📂 核心组件

本仓库包含以下核心文件：

### 1. 规则基石
- **[`constitution.md`](constitution.md)** (项目宪法)
  - 定义了 11 条不可动摇的开发原则（如简单性、测试优先、安全第一）。
  - **作用**：作为 AI 的最高行为准则，防止幻觉和低质量代码。
- **[`CLAUDE.md`](profiles/go/CLAUDE.md)** (AI 协作指南)
  - 包含了项目的角色定义、构建命令、代码风格和工作流。
  - **作用**：强制 Claude 在编码前先制定验证计划，并严格遵守宪法。

### 2. 多语言配置模板 - `profiles/`
- **`profiles/go/`**: 针对 Go 语言优化的 `CLAUDE.md` 和 `AGENTS.md`。
- **`profiles/php/`**: 针对 PHP（Lumen/Laravel）优化的配置。

### 3. 智能体（Agents）- `.claude/agents/`
预设了多个专家角色，用于处理特定任务：
- **`architect`**: 架构设计与技术选型。
- **`security-auditor`**: 代码安全审计与漏洞扫描。
- **`test-validator`**: 测试用例生成与覆盖率分析。
- **`code-scribe`**: 文档编写与维护。

### 4. 扩展文档 - `docs/`
- **`docs/constitution/go_annex.md`**: Go 语言实施细则。
- **`docs/constitution/php_annex.md`**: PHP 语言实施细则。

---

## 🚀 一键集成指南

将以下能力引入你的现有项目，只需一条命令：

### 方法一：本地集成（推荐）
如果你已经克隆了本仓库，可以直接运行 `install.sh` 脚本。它会自动检测目标项目的语言（Go 或 PHP），并安装对应的配置文件。

```bash
# 用法: ./install.sh <你的目标项目路径>
./install.sh ../my-awesome-project
```

### 方法二：手动集成
如果你更喜欢手动控制，可以从 `profiles/` 目录复制对应语言的配置：

1. **复制核心文件**（以 Go 项目为例）
   ```bash
   # 复制配置文件
   cp profiles/go/CLAUDE.md profiles/go/AGENTS.md constitution.md ../my-app/
   # 复制 Agent
   cp -r .claude ../my-app/
   ```
2. **复制文档**
   ```bash
   mkdir -p ../my-app/docs/constitution
   cp docs/constitution/go_annex.md ../my-app/docs/constitution/
   ```

---

## 🛠 配置与验证

### 1. 个性化配置
集成完成后，请检查目标项目中的 **`CLAUDE.md`** 和 **`AGENTS.md`**：
- 确认 `# Commands` 部分的构建/测试命令是否符合你项目的实际情况。
- 如果是 PHP 项目，确认是否使用了 `php-cs-fixer` 等工具。

### 2. 验证
在你的项目中使用 Claude Code 并提问：
> "这个项目的核心开发原则是什么？"

如果 Claude 能准确列出 `constitution.md` 中的 11 条原则，说明集成成功。

---

## 💡 最佳实践理念

- **验证先行（Verification First）**: 我们强制 AI 在写代码前先想好怎么测。
- **宪法治国**: 所有的 Prompt 与 Context 都服从于 `constitution.md`。
- **角色分离**: 让专业的 Agent 做专业的事，而不是让通用模型包打天下。
