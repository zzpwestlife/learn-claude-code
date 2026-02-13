# Learn Claude Code & AI 原生开发工作流实战

本项目包含两大部分核心内容：
1. **Learn Claude Code 学习套件**：一套标准化的 Claude Code 配置工具与最佳实践。
2. **AI 原生开发工作流实战课程**：极客时间《AI 原生开发工作流实战》课程的全套文档与资源。

---

## 📂 项目结构说明

经过重构与优化，项目采用了标准化的目录结构：

```
.
├── docs/                   # 课程核心文档 (Markdown)
│   ├── 00_introduction.md  # 课程章节 (00-23)
│   ├── ...
│   └── constitution/       # 课程相关的宪法文档附录
├── assets/                 # 静态资源目录
│   └── images/             # 课程文档引用的图片资源
├── .claude/                # Claude Code 核心配置与工具集
│   ├── agents/             # 智能体角色定义
│   ├── commands/           # 自定义 Slash 命令
│   ├── hooks/              # 自动化钩子
│   └── skills/             # 扩展技能
├── profiles/               # 多语言配置模板 (Go/PHP/Python)
├── constitution.md         # 项目核心宪法文件
├── AGENTS.md               # 项目上下文总入口 (Context Entry)
├── CLAUDE.md               # Claude Code 兼容入口 (Redirect)
├── install.sh              # 自动化安装脚本
└── README.md               # 项目说明文档
```

---

## 📚 AI 原生开发工作流实战 (Course)

本课程深入探讨如何将 AI 从“辅助工具”转变为“原生工作流”的一部分。所有课程章节均位于 `docs/` 目录下，按章节顺序编号。

### 目录概览

- **开篇与理念**
    - [00_introduction.md](docs/00_introduction.md): 开篇词｜AI 工作流革命
    - [01_paradigm_evolution.md](docs/01_paradigm_evolution.md): 范式演进：从人机协作到 AI 原生
    - [02_core_engine_spec_driven.md](docs/02_core_engine_spec_driven.md): 核心引擎：规范驱动开发
    - ...

- **环境与工具**
    - [04_environment_setup.md](docs/04_environment_setup.md): 环境搭建
    - [05_interaction_model.md](docs/05_interaction_model.md): 核心交互模型
    - ...

- **核心实战**
    - [17_requirements_and_design.md](docs/17_requirements_and_design.md): 需求与设计
    - [19_coding_and_testing.md](docs/19_coding_and_testing.md): 编码与测试
    - ...

---

## 🛠 Learn Claude Code 学习套件 (Tool Suite)

**Learn Claude Code** 是一个标准化的 Claude Code 配置套件，旨在帮助开发者快速将最佳实践集成到自己的项目中。

### 核心特性

1.  **规则基石**: `constitution.md` 定义了不可动摇的开发原则。
2.  **角色化 Agent**: 预设 Architect, Code Reviewer 等专家角色。
3.  **多语言支持**: 提供 Go, PHP, Python 的标准化配置模板 (`profiles/`)。
4.  **自动化集成**: 通过 `install.sh` 一键将配置注入到你的项目中。

### 评审与元信息约定

- **评审入口**: 使用 `.claude/commands/review-code.md` 统一执行差异审查与全量审查。
- **计划前置**: 变更触及 3 个以上文件或跨模块时，先进入 /plan 明确范围与验收标准。
- **模块元信息**: 每个模块目录需要 README，说明 Role/Logic/Constraints 与子模块清单。
- **源文件头部**: 源文件前三行包含 INPUT/OUTPUT/POS，变更后需要同步更新。
- **交付卫生**: 本地产物与日志不得进入仓库，确保 `.gitignore` 覆盖。

#### 模板示例

模块 README 模板

```
# <模块名称>

## Role
<该模块在系统中的角色与职责>

## Logic
<该模块的核心逻辑与工作方式>

## Constraints
<使用方必须遵循的约束/不变量>

## Submodules
- <子模块A>: <用途>
- <子模块B>: <用途>
```

源文件头部三行模板

```
INPUT: <该文件依赖的输入/模块/接口>
OUTPUT: <该文件对外提供的能力/接口/副作用>
POS: <该文件在系统中的位置/角色>
```

#### 快速实践：最小示例模块

- 创建业务模块目录（示例）：`modules/example-module/`
- 在模块目录中放置 `README.md`（按“模块 README 模板”填写 Role/Logic/Constraints 与 Submodules）
- 在源码文件头部添加三行注释（按“源文件头部三行模板”填写 INPUT/OUTPUT/POS）
- 提交前运行评审命令，确保模块元信息完整：参考 `.claude/commands/review-code.md`

### 快速开始

**本地集成（推荐）**

如果你已经克隆了本仓库，可以直接运行 `install.sh` 脚本。它会自动检测目标项目的语言，并安装对应的配置文件。

```bash
# 用法: ./install.sh <你的目标项目路径>
./install.sh ../my-awesome-project
```

脚本支持 **Smart Clean Root** 策略，将大部分配置隐藏在 `.claude/` 目录下，并支持 **Makefile 智能合并**。

✅ **跨平台支持**：脚本自动识别 macOS/Linux 环境，适配 sed/grep 等工具差异。
🛡️ **安全机制**：内置自动备份与回滚功能，安装失败自动恢复，详细日志记录在 `install_claude_code.log`。

### 🤖 智能引导工作流 (Smart Guided Workflow)

本项目内置了一套无缝衔接的 AI 开发工作流，通过智能引导将**提示词优化**、**方案规划**、**代码实现**、**代码审查**、**变更日志**与**提交信息**串联起来。

只需执行首个命令，系统将在每个阶段完成后自动引导进入下一步：

1.  **`/optimize-prompt`**: 优化原始需求提示词 -> 引导规划
2.  **`/planning-with-files:plan`**: 执行详细的任务规划与实施 -> 引导审查
3.  **`/review-code`**: 智能代码审查 -> 引导变更日志
4.  **`/changelog-generator`**: 生成 CHANGELOG.md -> 引导提交信息
5.  **`/commit-message-generator`**: 生成标准 Commit Message

**体验方式**：
```bash
/optimize-prompt <你的原始需求>
```
*(系统将在每一步结束时弹出 Y/N 确认框，按键盘即可快速响应)*

### 更多文档

详细的工具使用说明与核心组件介绍，请参考 `docs/` 目录下的相关章节，或直接查看 `.claude/` 目录下的具体配置文件。

---

## 🤝 贡献与反馈

欢迎提交 Issue 或 Pull Request 来改进本项目。请确保遵循项目的代码规范与目录结构标准。
