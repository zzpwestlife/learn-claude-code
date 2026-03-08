# AI 编程 Agent 编排工具指南：Superset, Conductor, OpenCode 与 OpenClaw

> **摘要**：本文档详细对比了当前 macOS 平台上主流的 AI 编程 Agent 编排工具，分析了它们在 "AI 原生开发" 时代的定位，并为进阶开发者提供了一套基于 **Superset** 的最佳实践工作流。

## 1. 核心理念：从 "结对编程" 到 "AI 经理"

随着 AI 编程工具能力的提升，开发者的角色正在发生根本性的转变：

*   **传统模式 (Pair Programmer)**：开发者写代码，AI 作为辅助（自动补全、解释代码）。
*   **新模式 (AI Manager)**：开发者定义需求 (Spec) 和 审查代码 (Review)，AI 负责具体的编码实现 (Implementation)。

为了支持这种 "高并发" 的新模式，我们需要能够同时管理多个 AI Agent 的工具，利用 **Git Worktree** 实现上下文隔离，让多个 Agent 并行工作。

## 2. 工具全景对比

### 2.1 Superset (推荐)
*   **定位**：通用的 AI 编程终端 (IDE for AI Agents)。
*   **核心特性**：
    *   **全平台兼容 (Agent-Agnostic)**：支持 Claude Code, Codex, Cursor Agent, GitHub Copilot CLI, OpenCode 等几乎所有 CLI 工具。
    *   **高并发**：设计目标支持 10+ Agent 并行。
    *   **内置工具**：提供专门的 Diff Viewer 和 Dashboard。
    *   **技术栈**：Electron/React，社区活跃。
*   **适用场景**：需要混合使用多种 AI 工具、追求极致并发和扩展性的开发者。

### 2.2 Conductor
*   **定位**：专为 Claude Code 和 Codex 打造的原生 macOS 应用。
*   **核心特性**：
    *   **原生体验**：极致流畅，UI/UX 打磨精细。
    *   **开箱即用**：零配置，专注于 Anthropic 生态。
*   **局限性**：**封闭生态**。仅支持 Claude Code 和 Codex，不支持 OpenCode 或其他自定义 CLI 工具。
*   **适用场景**：只使用 Claude Code，且对原生 Mac 体验有执念的轻量级用户。

### 2.3 OpenCode
*   **定位**：开源、模型无关 (BYOM) 的终端 Agent。
*   **核心特性**：
    *   **模型自由**：支持 OpenAI, Anthropic, DeepSeek, Gemini 等任意模型。
    *   **架构**：Client/Server 架构，支持会话后台驻留。
    *   **界面**：强大的 TUI (终端图形界面)。
*   **与 Claude Code 的关系**：**互补/替代**。Claude Code 胜在深度推理和稳定性，OpenCode 胜在灵活性和成本控制（如使用 DeepSeek）。

### 2.4 OpenClaw
*   **定位**：个人 AI 系统助手 (Personal AI Assistant)。
*   **核心特性**：
    *   **自动化**：不仅是写代码，更能执行系统级任务（发通知、监控 CI、管理日历等）。
    *   **形态**：CLI/TUI 工具，常驻后台。

## 3. 为什么选择 Superset？

对于 **macOS + Claude Code (主力) + OpenClaw (辅助)** 的技术栈，**Superset 是唯一合理的选择**。

| 维度 | Superset | Conductor |
| :--- | :--- | :--- |
| **OpenClaw 支持** | ✅ **完美支持** (作为普通 CLI 运行) | ❌ **不支持** (无法运行自定义命令) |
| **OpenCode 支持** | ✅ **完美支持** | ❌ **不支持** |
| **多任务灵活性** | ✅ 高 (任意组合) | ⚠️ 低 (仅限 Claude/Codex) |
| **扩展性** | ✅ 强 (跟随 CLI 生态) | ⚠️ 弱 (依赖官方更新) |

Conductor 虽然精致，但它是一个 "有围墙的花园"，无法容纳 OpenClaw 或 OpenCode 这样独立的外部工具。

## 4. 最佳实践工作流 (The "Power User" Setup)

在 Superset 中，建议构建如下的 "混合双打" 工作流，充分发挥各工具的长处：

### 布局建议

*   **Tab 1 (主力开发)**: **Claude Code**
    *   **任务**：核心业务逻辑开发、复杂架构重构。
    *   **优势**：利用 Claude 3.7/3.5 的强推理能力，保证核心代码质量。
    *   **配合**：Git Worktree `feat/core-logic`。

*   **Tab 2 (辅助开发/低成本)**: **OpenCode**
    *   **配置**：连接 DeepSeek V3 或 Gemini 1.5 Pro。
    *   **任务**：
        *   编写单元测试 (DeepSeek 性价比高)。
        *   长文档分析 (Gemini 2M Context 优势)。
        *   算法难题 (切换至 o1/o3-mini 模型)。
    *   **配合**：Git Worktree `feat/tests` 或 `docs/update`。

*   **Tab 3 (管家/运维)**: **OpenClaw**
    *   **任务**：
        *   监控 Tab 1 和 Tab 2 的任务进度。
        *   执行系统级自动化（如 "当 CI 通过时发送 Slack 通知"）。
        *   管理部署流程。
    *   **配合**：主分支或独立的运维 Worktree。

## 5. 常见问题 (FAQ)

**Q: Conductor 真的不能跑 OpenCode 吗？**
A: **不能**。Conductor App 是深度封装的 GUI，无法解析 OpenCode 的 TUI 输出。虽然有一个名为 `opencode-conductor` 的插件，但那是 OpenCode 内部的插件，与 Conductor App 无关。

**Q: OpenCode 和 Claude Code 需要二选一吗？**
A: **不需要**。在 Superset 环境下，它们可以并行运行。建议用 Claude Code 处理 "硬骨头"，用 OpenCode 处理 "体力活" 或需要特定模型优势的任务。

**Q: 这种模式对电脑配置有要求吗？**
A: **有**。Superset (Electron) + 多个 Agent (Node/Go 进程) + IDE + Docker 会占用较多内存。建议 M1/M2/M3 Pro 芯片起步，32GB+ 内存为佳。
