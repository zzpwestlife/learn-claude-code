# Learn Claude Code 学习套件

**Learn Claude Code** 是一个标准化的 Claude Code 配置套件，旨在帮助开发者快速将最佳实践集成到自己的项目中。它通过引入“宪法机制”和“角色化 Agent”，确保 AI 生成的代码安全、健壮且易于维护。

现在支持多语言配置（Go / PHP / Python），可根据项目类型自动适配。

---

## 📂 核心组件

本仓库包含以下核心文件，集成后将主要收敛于 `.claude/` 目录，保持项目根目录整洁：

### 1. 规则基石 (位于 `.claude/`)
- **`constitution.md`** (项目宪法)
  - 定义了 11 条不可动摇的开发原则（如简单性、测试优先、安全第一）。
  - **作用**：作为 AI 的最高行为准则，防止幻觉和低质量代码。
- **`AGENTS.md`** (智能体定义)
  - 定义了项目中的专家角色及其职责。

### 2. AI 协作入口 (位于项目根目录)
- **`CLAUDE.md`**
  - 包含了项目的构建命令、代码风格和工作流入口。
  - **作用**：强制 Claude 在编码前先制定验证计划，并严格遵守宪法。

### 3. 多语言配置模板 - `profiles/`
- **`profiles/go/`**: 针对 Go 语言优化的配置。
- **`profiles/php/`**: 针对 PHP（Lumen/Laravel）优化的配置。
- **`profiles/python/`**: 针对 Python (3.10+) 优化的配置。

### 4. 智能体与工具集 - `.claude/`
- **`agents/`**: 预设专家角色（Architect, Security Auditor, Code Reviewer 等）。
- **`commands/`**: 自定义 Slash 命令（如 `/review-code` 支持 Git 增量审查）。
- **`hooks/`**: 自动化钩子（如自动格式化、语法检查）。
- **`skills/`**: 扩展能力（如 YouTube 剪辑、文档搜索、**Notifier 通知中心**）。
- **`constitution/`**: 语言实施细则 (go_annex.md 等)。

### 5. FinClaude 金融级开发套件 (新增)
集成了 `finclaude` 的核心能力，提供高安全标准的开发流程：
- **/fin:plan**: 生成符合审计要求的架构方案。
- **/fin:dev**: 强制执行 TDD (红-绿-重构) 循环。
- **/fin:review**: 执行严格的安全与复杂度审计。
- **Notifier**: 统一通知中心，支持 Slack/Discord Webhook 集成。

---

## 🚀 一键集成指南

将以下能力引入你的现有项目，只需一条命令：

### 方法一：本地集成（推荐）
如果你已经克隆了本仓库，可以直接运行 `install.sh` 脚本。它会自动检测目标项目的语言（Go, PHP 或 Python），并安装对应的配置文件。

脚本支持 **Smart Clean Root** 策略，将大部分配置隐藏在 `.claude/` 目录下，并支持 **Makefile 智能合并**（保留你原有的构建目标）。

```bash
# 用法: ./install.sh <你的目标项目路径>
./install.sh ../my-awesome-project
```

### 方法二：手动集成
如果你更喜欢手动控制，请遵循 **Clean Root** 结构：

1. **复制入口文件**
   ```bash
   cp profiles/python/CLAUDE.md ../my-app/
   # 如果是 Go 项目，也可以复制 Makefile
   # cp profiles/go/Makefile ../my-app/
   ```

2. **构建 .claude 配置目录**
   ```bash
   mkdir -p ../my-app/.claude/constitution
   
   # 复制核心规则
   cp constitution.md profiles/python/AGENTS.md ../my-app/.claude/
   
   # 复制语言附录
   cp docs/constitution/python_annex.md ../my-app/.claude/constitution/
   
   # 复制工具集
   cp -r .claude/agents .claude/commands .claude/hooks .claude/skills .claude/settings.json ../my-app/.claude/
   ```

3. **修正路径引用** (关键步骤)
   你需手动修改 `../my-app/CLAUDE.md` 和 `.claude/AGENTS.md` 中的相对路径，使其指向正确的位置（推荐使用 `install.sh` 自动处理）。

---

## ✨ 核心特性

### 1. 智能增量代码审查
`/review-code` 命令不仅支持审查指定路径，还支持 **Git 增量模式**：
- 运行 `/review-code diff` 即可自动分析当前分支与 `main` 分支的差异。
- 智能体 `code-reviewer` 会基于 Git Diff 提供针对性的改进建议。

### 2. 自动化合规检查
- **Hooks**: 每次文件变更后自动运行格式化工具 (gofmt, black, php-cs-fixer)。
- **Constitution Check**: 在生成代码前，AI 必须通过 11 条宪法原则的自检。

### 3. 无侵入式集成
- **Makefile Smart Merge**: 安装脚本会解析你现有的 Makefile，智能追加新的构建目标，而不是粗暴覆盖。
- **Directory Cleanliness**: 保持根目录清爽，所有 AI 资产收敛于 `.claude/`。

---

## 🛠 配置与验证

### 1. 个性化配置
集成完成后，请检查目标项目中的 **`CLAUDE.md`**：
- 确认 `# Commands` 部分的构建/测试命令是否符合你项目的实际情况。

### 2. 验证
在你的项目中使用 Claude Code 并提问：
> "这个项目的核心开发原则是什么？"

如果 Claude 能准确列出 `constitution.md` 中的 11 条原则，说明集成成功。

---

## 💡 最佳实践理念

- **验证先行（Verification First）**: 我们强制 AI 在写代码前先想好怎么测。
- **宪法治国**: 所有的 Prompt 与 Context 都服从于 `constitution.md`。
- **角色分离**: 让专业的 Agent 做专业的事，而不是让通用模型包打天下。
