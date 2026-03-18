# 🛠 Learn Claude Code 学习套件 (Tool Suite)

**Learn Claude Code** 是一个标准化的 Claude Code 配置套件，旨在帮助开发者快速将最佳实践集成到自己的项目中。本版本基于 [Obra Superpowers](https://github.com/obra/superpowers)，经过精简重构，专注于 **Golang** 开发环境的优化。

## 核心特性

1.  **规则基石**：`.claude/constitution/constitution.md` 与 `.claude/rules/CORE_RULES.md` 共同定义了不可动摇的开发原则与工程规范。它们通过 `CLAUDE.md` -> `.claude/AGENTS.md` 链式加载，作为 **Non-Negotiable (不可协商)** 的上下文强制生效，确保 AI 始终遵循项目宪法。
2.  **认知架构**：深度集成**奥卡姆剃刀**（做减法）、**费曼技巧**（做加法）与**苏格拉底提问法**（做验证），构建自我调节的 AI 思维模型 (`.claude/constitution/prompt_engineering_annex.md`)。
3.  **角色化技能 (Role-Based Skills)**：专家角色（如 Code Reviewer）直接集成在 `.claude/skills/` 中。
4.  **Golang 原生支持**：提供深度优化的 Go 语言开发规范 (`.claude/constitution/go_annex.md`) 与自动化格式化钩子 (`.claude/hooks/go/format-go-code.sh`)，集成 `gofmt`、`goimports`、`gofumpt` 等最佳实践工具链。
5.  **自动化闭环 (Automation Loop)**：内置 **Session Recovery** 与 **Skill Audit** 机制。
    *   `/audit-skills`：智能分析日志，自动发现工作流缺口并推荐新技能。
    *   `/recover`：一键恢复上下文（基于 `SessionEnd` Hook 自动生成的摘要），快速回到工作状态。
    *   `/find-skills`：智能技能导航，解决“工具太多不知道用哪个”的难题。
6.  **双重人格架构 (Dual Persona)**：独创的 **Builder (Opus)** vs **Critic (Codex)** 协作模式。Opus 负责从 0 到 1 的创造与文档，Codex 负责严格的代码审查与安全审计 (`.claude/skills/review-code/SKILL.md`)。
7.  **智能体技能库**：内置 Python 驱动的高级技能（如 `changelog-generator`、`skill-architect`），位于 `.claude/skills/` 目录，提供自动变更日志、技能进化等能力（仅依赖系统 Python，无需额外配置）。
8.  **动态上下文卫生**：内置 Token 优化协议 (`.claude/rules/CORE_RULES.md`)，指导 Agent 主动过滤大型输出，防止上下文爆炸。
9.  **决策树压力测试 (Grill-Me Protocol)**：在 `/brainstorm` 阶段强制引入**多轮结构化拷问**机制。AI 会将需求拆解为决策树，并主动探索代码库以消除歧义。只有在所有边缘情况和分支都达成深度共识后，才会生成 Design 文档，从源头杜绝“想当然”的代码。
10. **自动化集成**：通过 `install.sh` 一键将配置注入到你的项目中，支持 macOS 原生 GUI 交互与智能文件合并（Smart Merge）。

---

## 🌊 FlowState: 零摩擦 AI 工作流 (Zero-Friction AI Workflow)

**FlowState** 是本套件的核心工作流引擎，通过智能引导将**提示词优化**、**方案规划**、**代码实现**、**代码审查**、**变更日志**与**提交信息**无缝串联，让开发过程像水一样自然流动。

### 🚀 快速上手 (Quick Start)

#### 1. 安装 (Installation)

**前置要求**：Claude Code CLI、Python 3.8+、Git。

推荐使用 `make` 命令安装：

```bash
make install
```

#### 2. 体验工作流 (The Flow Experience)

安装完成后，在你的项目根目录下：

```bash
"帮我构思一个 Python 斐波那契数列工具"
# 或者明确调用技能:
# "使用 brainstorming 技能，实现一个 Python 斐波那契数列工具"
```

**后续的所有操作，系统会根据你的意图自动加载相应的技能（如 writing-plans, executing-plans 等），您只需要自然地表达需求或使用方向键和 Enter 即可完成：**

```text
[FlowState] 方案已确认。是否需要为您生成实施计划？ (Use arrow keys)
 » 🟢 是的，请生成计划 (Invoke writing-plans skill)
   ⚪️ 不，我还有其他想法
```

**真实的交互体验**：在底层，这通过 Claude Code 的原生 `AskUserQuestion` 工具实现。你看到的界面类似于：

```text
⏺ User answered Claude's questions:
  ⎿  · 设计确认 / Design approval? → 确认，进入规划阶段
```

**真正的 "Hands-free" 体验，让您专注于决策而非命令。**

### 🎮 交互模式 (Interaction Model)

本插件采用 **Zero-Friction (零摩擦)** 交互设计：

1.  **全流程智能引导**: 系统主动提示下一步操作。
2.  **方向键导航**: 使用方向键选择，Enter 确认。
3.  **一键直达**: 确认后自动执行命令，无需手动输入。

### 📊 工作流全景 (Interactive Workflow)

```mermaid
graph TD
    Start["表达需求<br/>(Intent: brainstorming)"] --> Interview["决策树压力测试<br/>(Grill-Me Protocol)"]
    Interview -->|Loop until branches resolved| Interview
    Interview -->|Shared Understanding| Optimize["生成 design.md"]
    Optimize -->|Intent: write plan| Plan["生成 BDD 状态文件<br/>(.local.md)"]
    Plan -->|Intent: execute| Execute["Red-Green 循环执行<br/>(State-Driven)"]
    Execute -->|Red Task| Red["编写失败测试"]
    Red -->|Green Task| Green["实现功能通过测试"]
    Green -->|Loop until done| Execute
    Execute -->|On Failure| Debug["系统性调试<br/>(Intent: engineering-standards)"]
    Execute -->|Start Fresh| Review["/new -> /review-code<br/>(Fresh Context & Codex)"]
    Review -->|Select & Enter| Changelog["/changelog-generator<br/>(Visual Confirmation)"]
    Changelog -->|Select & Enter| Commit["/commit-message-generator<br/>(Reflective Selection)"]
    Commit --> Finish[Done]
```

**全程可视化进度**:
`[✔ Brainstorm] → [✔ Design] → [✔ Plan] → [➤ Execute] → [Review] → [Changelog] → [Commit]`

## 🛠️ 核心能力详解

| 能力 (Skill/Command) | 描述 | 适用场景 |
| :--- | :--- | :--- |
| `brainstorming` (Skill) | **创意引擎**：启动任务，进行**多轮结构化拷问 (Grill-Me)** 与决策树拆解，生成 `design.md`。 | 新功能开发、复杂问题探索 |
| `/optimize-prompt` | **提示词优化师**：交互式优化你的 Prompt，确保最佳 AI 表现。 | 任务指令模糊、需要高质量输出时 |
| `writing-plans` (Skill) | **架构师**：将设计文档转化为 **BDD 状态追踪文件** (`.local.md`)。 | 确定方案后，开始编码前 |
| `/audit-skills` | **技能审计师**：分析历史日志，发现高频操作并推荐新 Skill。 | 定期优化工作流、觉得操作繁琐时 |
| `/recover` | **会话恢复专家**：智能分析 Git 状态与会话摘要，重建上下文。 | 每日开工、中断后恢复 |
| `executing-plans` (Skill) | **执行者**：基于 `.local.md` 状态文件，执行 **Red-Green 循环**。 | 编码阶段，批量任务处理 |
| `engineering-standards` (Skill) | **工程标准**：统一管理 TDD、调试与验证流程，确保代码质量。 | 开发、调试、验收阶段 |
| `review-code` (Skill) | **全能审查员**：统一处理代码审查的请求、执行与接收。 | 提交代码前，尤其是 Pull Request 前 |
| `/changelog-generator` | **日志专家**：自动分析 Git Diff，更新 `CHANGELOG.md`。 | 版本发布、功能合并后 |
| `/commit-message-generator` | **提交助手**：生成符合 Conventional Commits 规范的提交信息。 | 准备 git commit 时 |
| `/archive-task` | **归档员**：将当前任务的计划文件归档，保持工作区整洁。 | 任务完成后 |
| `/tidy-memory` | **记忆整理**：整理项目的核心记忆，优化上下文。 | 长期项目维护，定期执行 |

## 📂 目录结构说明

```text
.claude/
├── checklists/     # 检查清单 (Mental Model Checklist)
├── commands/       # 自定义命令脚本 (MCP/Slash Commands)
├── constitution/   # 项目宪法与核心原则 (Constitution)
├── docs/           # 详细文档与参考资料
├── hooks/          # Git Hooks (Pre-commit formatting)
├── rules/          # 具体工程规则 (Core Rules)
├── scripts/        # 实用脚本 (Installers, Analyzers)
└── skills/         # 智能体技能库 (Python/Node 驱动的高级能力)
```

## 📚 文档与指南

- [**Agent BDD Loop (Red-Green) 工作流指南**](.claude/docs/guides/agent_bdd_loop.md): 详细介绍了基于状态追踪的红绿 Agent 开发模式，确保复杂任务的原子化执行与零 Laziness。
- [**Claude Code Golang LSP 配置指南**](docs/guides/claude-code-lsp-setup.md): 开启 `ENABLE_LSP_TOOL`，让 Claude Code 拥有 IDE 级的代码跳转与补全能力 (50ms 响应)。
