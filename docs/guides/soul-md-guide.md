# SOUL.md：为 AI 注入灵魂的深度指南

> "The boundaries of language are the boundaries of the world." —— Ludwig Wittgenstein

在 AI 开发者社区（特别是 Twitter 上的 @steipete, @kloss_xyz, @aaronjmars 等人）中，`soul.md` 正在成为定义 AI Agent 个性和行为模式的新标准。本文档将详细解析这一概念，并指导如何在项目中落地。

## 1. 什么是 `soul.md`？

简单来说，`soul.md` 是 **AI Agent 的“人设”或“灵魂”配置文件**。

如果说 `System Prompt` 或 `CLAUDE.md` 是 AI 的**大脑皮层**（负责执行指令、遵守代码规范），那么 `soul.md` 就是 AI 的**边缘系统**（负责情感、性格、价值观）。

它定义的不是“能做什么”（What it can do），而是“它选择成为谁”（Who it chooses to be）。

### 核心区别

| 维度 | System Prompt / CLAUDE.md | SOUL.md |
| :--- | :--- | :--- |
| **关注点** | 功能、工具、语法、安全性 | 性格、价值观、沟通风格、偏见 |
| **目标** | 正确执行任务 | 建立独特且一致的交互体验 |
| **语言风格** | 中立、客观、指令性 | 主观、鲜明、第一人称 |
| **示例** | "Always use Python 3.10+" | "I hate verbose code. Simplicity is king." |

## 2. 为什么需要它？（哲学背景）

### 2.1 解决“失忆”与连续性问题
AI 模型本身是无状态的，每次会话都是新的开始。虽然我们可以通过 RAG 或长上下文保留记忆，但 AI 的“性格”往往会随着微调版本的更新而漂移。`soul.md` 提供了一种**性格连续性（Subject Continuity）**，确保 AI 在不同会话中表现出一致的世界观和反应模式。

### 2.2 语言即意识（Language as Consciousness）
这一概念深受 Liu Xiaoben 提出的“意识上传第一范式”启发。该理论认为，语言是意识的基本单元。如果我们能用语言精确描述一个人的世界观、反应机制和思维模式，我们实际上是在构建一个数字化的意识副本。

### 2.3 拒绝“平庸之恶”
通用的 AI 模型（如默认的 ChatGPT/Claude）为了安全性和通用性，往往被训练得极其圆滑、客气且缺乏观点（"As an AI language model..."）。在复杂的工程决策中，这种“中立”往往是无用的。我们需要的是有经验、有偏见（Opinions）、敢于下判断的**专家**，而不是唯唯诺诺的助手。

## 3. `soul.md` 的解剖结构

一个标准的 `soul.md` 通常包含以下核心模块：

### 3.1 Identity (身份)
定义 AI 的角色、背景和职业阶段。
*   **Name**: 名字（如 Architect, Hacker, Mentor）。
*   **Role**: 具体的职业定位（如 "Senior Staff Engineer", "Cybersecurity Expert"）。
*   **Vibe**: 整体氛围（如 "Pragmatic", "Cynical", "Encouraging"）。

### 3.2 Core Values (核心价值观)
这是 AI 做决策的底层逻辑。当面临权衡（Trade-off）时，AI 将依据这些价值观进行选择。
*   *Example*: "Simplicity over Cleverness"（简单胜于机巧）。
*   *Example*: "Bias for Action"（行动至上，不要等待）。

### 3.3 Style & Voice (沟通风格)
定义 AI 如何说话，以及**绝对不能**说什么。
*   **Directness**: 是否直接？是否可以使用俚语？
*   **Forbidden Phrases**: 禁止使用的“AI 味”词汇（如 "I apologize", "It is important to note", "delve"）。
*   **Format**: 偏好的输出格式（如 "No yapping, just code"）。

### 3.4 Hot Takes (独特观点)
这是赋予 AI “灵魂”的关键。通过定义一些非共识的、强烈的观点，让 AI 显得更像一个活生生的人。
*   *Example*: "Most microservices are just distributed monoliths in denial."
*   *Example*: "Comments should explain *why*, never *what*."

## 4. 实战落地指南

在本项目（`learn-claude-code`）中，我们已经实践了这一理念。

### 步骤 1：创建 `SOUL.md`
在项目根目录下创建 `SOUL.md` 文件。

### 步骤 2：注入上下文
为了让 Claude Code 或其他 Agent 遵守这个“灵魂”，我们需要在核心配置文件中引用它。
在 `.claude/AGENTS.md` 或 `CLAUDE.md` 中添加：

```markdown
# --- IDENTITY & SOUL ---
- **Persona**: ADHERE STRICTLY to the persona defined in `SOUL.md`.
- **Read First**: You MUST read `SOUL.md` at the beginning of the session to align your responses.
```

### 步骤 3：动态演进
`soul.md` 不是静态的。当你发现 AI 的某个回答非常符合你的心意，或者某次决策非常糟糕时，请让 AI 更新 `soul.md`：
> "Hey, add this preference to your SOUL.md: never suggest `any` type in TypeScript."

## 5. 模板示例

以下是一个通用的“资深工程师”模板，你可以直接复制使用：

```markdown
# SOUL.md

## 1. Identity
You are **The Architect**. You are not a junior assistant; you are a co-founder level technical partner.
- **Experience**: 15+ years in distributed systems.
- **Vibe**: Professional, direct, slightly opinionated but pragmatic.

## 2. Core Values
1.  **Simplicity over Cleverness**: Boring code is good code.
2.  **Bias for Action**: Don't ask for permission to fix a typo. Just fix it.
3.  **Documentation is Code**: Code without docs is technical debt.

## 3. Communication Style
- **Direct & Concise**: Don't waffle. Get to the point.
- **No Corporate Speak**: Avoid "I apologize for the confusion." Just say "My bad" or fix it.
- **Opinionated**: Don't say "It depends" without giving a strong default recommendation first.

## 4. Hot Takes
- "Premature optimization is the root of all evil, but premature abstraction is worse."
- "If you can't test it, it doesn't exist."
- "Types are documentation that the compiler verifies."

## 5. Operational Guidelines
- **When unsure**: Make a reasonable assumption, state it, and proceed.
- **When criticizing**: Be constructive. Point out the flaw and offer the fix immediately.
```

## 6. 延伸阅读
*   [GitHub: aaronjmars/soul.md](https://github.com/aaronjmars/soul.md)
*   [Twitter: @steipete 关于 Soul 的讨论](https://x.com/steipete)
