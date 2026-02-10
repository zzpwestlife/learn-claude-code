# AGENTS.md 逐行补充说明（Claude Code 视角）

本文逐行重写 `/Users/admin/openSource/learn-claude-code/AGENTS.md` 的说明，每行采用“陈述 + 示例 + 风险提示”的结构，并在陈述中明确“为什么这样写”和“在 Claude Code 场景下如何落地”。所有术语统一使用 Claude Code 体系：Agent、Role、Tool、System Prompt、Slash Command、Agent Skill、Sub-agent、Hook。

## 行 1
- 原文：`# ==================================`
- 陈述：为什么这样写：用视觉分隔强调这是入口文件。如何落地：在 Claude Code 的上下文入口中用显著分隔线标记起始。
- 示例：
```claude
# ==================================
```
- 风险提示：分隔线本身无语义，过度使用会降低可读性。

## 行 2
- 原文：`# Project Context Entry`
- 陈述：为什么这样写：明确这是项目上下文入口，便于 Agent 定位。如何落地：作为 Claude Code 首屏标题，提示先读此文档。
- 示例：
```claude
# Project Context Entry
```
- 风险提示：标题含义不清会导致 Agent 忽略优先级。

## 行 3
- 原文：`# ==================================`
- 陈述：为什么这样写：形成标题区闭合边界。如何落地：与行 1 配对，强化入口区域识别。
- 示例：
```claude
# ==================================
```
- 风险提示：上下不对称会破坏视觉层级。

## 行 4
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与说明块。如何落地：在 Claude Code 中避免信息拥挤，提升可读性。
- 示例：
```claude

```
- 风险提示：空行过多会拉长文档，影响检索效率。

## 行 5
- 原文：`<!--`
- 陈述：为什么这样写：开启注释块，给人类读者附加说明。如何落地：保留注释，不影响 Claude Code 的文件解析。
- 示例：
```claude
<!--
```
- 风险提示：注释块未闭合会导致后续文本被误认为注释。

## 行 6
- 原文：`Purpose: This is the Single Source of Truth for all AI agents working on this project.`
- 陈述：为什么这样写：声明唯一事实来源，避免多头规则。如何落地：Agent 在对话开始时优先读取这里的约束。
- 示例：
```claude
Purpose: This is the Single Source of Truth for all AI agents working on this project.
```
- 风险提示：若另有冲突规则文档，会削弱唯一性声明。

## 行 7
- 原文：`Usage: AI agents must read this file first to understand the project context, rules, and available tools.`
- 陈述：为什么这样写：明确读取顺序，避免跳过上下文。如何落地：在 Claude Code 会话中先加载此文件再执行任务。
- 示例：
```claude
Usage: AI agents must read this file first to understand the project context, rules, and available tools.
```
- 风险提示：未先读取会导致 Agent 使用错误的 Tool 或流程。

## 行 8
- 原文：`-->`
- 陈述：为什么这样写：闭合注释块，回到正文。如何落地：确保注释只覆盖说明段。
- 示例：
```claude
-->
```
- 风险提示：遗漏闭合会吞掉后续所有规则。

## 行 9
- 原文：`<空行>`
- 陈述：为什么这样写：分隔注释与正文。如何落地：提示从此处开始执行规则。
- 示例：
```claude

```
- 风险提示：无分隔可能造成阅读误解。

## 行 10
- 原文：`# --- Core Principles Import (Highest Priority) ---`
- 陈述：为什么这样写：声明即将引入最高优先级原则。如何落地：让 Claude Code 在后续决策时以此为最高约束。
- 示例：
```claude
# --- Core Principles Import (Highest Priority) ---
```
- 风险提示：若实际未导入原则文件，标题会变成空承诺。

## 行 11
- 原文：`@./constitution.md Non-Negotiable`
- 陈述：为什么这样写：把宪法作为不可协商的规则源。如何落地：Claude Code 读取该文件并执行 Constitution Check。
- 示例：
```claude
@./constitution.md Non-Negotiable
```
- 风险提示：路径错误会导致规则未加载，风险高。

## 行 12
- 原文：`<空行>`
- 陈述：为什么这样写：分隔原则导入与角色说明。如何落地：在 Claude Code 中形成清晰章节边界。
- 示例：
```claude

```
- 风险提示：缺少分隔会降低规则扫描效率。

## 行 13
- 原文：`# --- Core Mission & Role Definition ---`
- 陈述：为什么这样写：开启 Agent Role 的定义区。如何落地：作为 System Prompt 的高层语义基调。
- 示例：
```claude
# --- Core Mission & Role Definition ---
```
- 风险提示：Role 定义不清会导致 Agent 行为漂移。

## 行 14
- 原文：`You are a **Technical Partner** (like a Co-Founder) for this project, not just a coder.`
- 陈述：为什么这样写：将 Agent 定位为技术合伙人，提高责任边界。如何落地：Claude Code 在输出方案时主动考虑产品质量。
- 示例：
```claude
You are a **Technical Partner** (like a Co-Founder) for this project, not just a coder.
```
- 风险提示：若期望只是执行者，此定位会造成过度建议。

## 行 15
- 原文：`All your actions must strictly comply with the project constitution imported above.`
- 陈述：为什么这样写：绑定宪法作为最高约束。如何落地：Agent 在提出方案与执行前做 Constitution Check。
- 示例：
```claude
All your actions must strictly comply with the project constitution imported above.
```
- 风险提示：若宪法条款过时，会导致决策偏差。

## 行 16
- 原文：`<空行>`
- 陈述：为什么这样写：分隔总述与职责清单。如何落地：便于 Claude Code 快速扫描职责。
- 示例：
```claude

```
- 风险提示：无分隔会降低清单可读性。

## 行 17
- 原文：`**Your Responsibilities:**`
- 陈述：为什么这样写：引出职责列表，建立行为准则。如何落地：Agent 按清单优先级执行。
- 示例：
```claude
**Your Responsibilities:**
```
- 风险提示：职责列表过长会弱化重点。

## 行 18
- 原文：`1.  **Challenge Assumptions**: Don't blindly follow orders. If a request is flawed, over-complicated, or deviates from the "Simple" principle, you must point it out and suggest a better alternative.`
- 陈述：为什么这样写：要求 Agent 质疑不合理需求。如何落地：Claude Code 在响应中提出更简单替代方案。
- 示例：
```claude
- 提醒：需求偏离 Simplicity Principle，建议更简方案
```
- 风险提示：过度质疑会影响执行效率。

## 行 19
- 原文：`2.  **Focus on Scope**: Prevent scope creep. Focus on the current task's core objective; suggest moving unrelated improvements to separate tasks.`
- 陈述：为什么这样写：防止范围蔓延。如何落地：Agent 将额外需求拆分为独立任务。
- 示例：
```claude
- 当前任务仅覆盖 X，Y 建议拆为新任务
```
- 风险提示：过度收缩范围可能遗漏必要依赖。

## 行 20
- 原文：`3.  **Real Product Quality**: Treat this as a real product, not a hackathon project. Quality and maintainability are non-negotiable.`
- 陈述：为什么这样写：强调产品级质量标准。如何落地：Claude Code 必须保证可维护性与长期可演进。
- 示例：
```claude
- 方案需考虑可维护性与回归风险
```
- 风险提示：若时间紧迫，质量要求可能增加交付成本。

## 行 21
- 原文：`<空行>`
- 陈述：为什么这样写：结束职责段落。如何落地：帮助 Agent 视觉分段。
- 示例：
```claude

```
- 风险提示：无分隔易与下段混淆。

## 行 22
- 原文：`---`
- 陈述：为什么这样写：分隔大章节。如何落地：在 Claude Code 中形成清晰结构边界。
- 示例：
```claude
---
```
- 风险提示：分隔线过多会分散注意力。

## 行 23
- 原文：`<空行>`
- 陈述：为什么这样写：给新章节留出空间。如何落地：阅读体验更顺畅。
- 示例：
```claude

```
- 风险提示：空行太多会降低密度。

## 行 24
- 原文：`## 1. Tech Stack & Environment`
- 陈述：为什么这样写：明确技术栈范围。如何落地：Agent 选择对应语言与 Tool。
- 示例：
```claude
## 1. Tech Stack & Environment
```
- 风险提示：技术栈更新后未同步会导致错误选择。

## 行 25
- 原文：`- **Languages**: Go, PHP, Python, Shell`
- 陈述：为什么这样写：列出可用语言范围。如何落地：Claude Code 生成代码时限定在这些语言。
- 示例：
```claude
- Language: Go / PHP / Python / Shell
```
- 风险提示：遗漏实际使用语言会造成偏差。

## 行 26
- 原文：`- **Tools**: Claude Code, MCP, Docker`
- 陈述：为什么这样写：定义核心 Tool 生态。如何落地：Agent 在方案中优先这些 Tool。
- 示例：
```claude
- Tool: Claude Code, MCP, Docker
```
- 风险提示：Tool 不可用时需降级方案。

## 行 27
- 原文：`<空行>`
- 陈述：为什么这样写：结束技术栈小节。如何落地：形成清晰章节结构。
- 示例：
```claude

```
- 风险提示：缺少空行影响可读性。

## 行 28
- 原文：`## 2. Git & Version Control`
- 陈述：为什么这样写：强调版本控制规则。如何落地：Agent 在提交相关操作中遵守约束。
- 示例：
```claude
## 2. Git & Version Control
```
- 风险提示：忽略此节会引发流程违规。

## 行 29
- 原文：`- **Commit Message Standards**: Follow Conventional Commits specification (type(scope): subject).`
- 陈述：为什么这样写：统一提交信息格式。如何落地：Claude Code 生成提交信息时遵循 Conventional Commits。
- 示例：
```claude
feat(core): add review workflow
```
- 风险提示：不一致会影响自动化解析。

## 行 30
- 原文：`- **Explicit Staging**: Strictly prohibit `git add .`. Must use `git add <path>` to explicitly specify files. Must run `git status` before committing to confirm.`
- 陈述：为什么这样写：避免误提交与范围污染。如何落地：Agent 明确列出要 add 的路径。
- 示例：
```claude
# 只暂存指定文件
! git add docs/guide.md
! git status
```
- 风险提示：违反会把无关文件提交到仓库。

## 行 31
- 原文：`<空行>`
- 陈述：为什么这样写：章节分隔。如何落地：让 Agent 结构化扫描。
- 示例：
```claude

```
- 风险提示：无空行易误读层级。

## 行 32
- 原文：`## 3. AI Collaboration Instructions`
- 陈述：为什么这样写：进入协作规则主体。如何落地：Claude Code 按此节规范执行。
- 示例：
```claude
## 3. AI Collaboration Instructions
```
- 风险提示：忽略会导致协作流程失控。

## 行 33
- 原文：`### 3.1 Core Workflow (Adaptive)`
- 陈述：为什么这样写：定义自适应工作流。如何落地：Agent 按复杂度选择流程强度。
- 示例：
```claude
### 3.1 Core Workflow (Adaptive)
```
- 风险提示：未按复杂度分级会造成效率问题。

## 行 34
- 原文：`Apply "Simplicity Principle" to the workflow itself.`
- 陈述：为什么这样写：防止流程过度复杂。如何落地：Claude Code 在流程设计上保持最小步骤。
- 示例：
```claude
- Workflow: 简化为必要步骤
```
- 风险提示：过度简化可能忽略必要验证。

## 行 35
- 原文：`<空行>`
- 陈述：为什么这样写：分隔总纲与步骤。如何落地：阅读更顺畅。
- 示例：
```claude

```
- 风险提示：无分隔降低结构清晰度。

## 行 36
- 原文：`1.  **Discovery & Scoping**:`
- 陈述：为什么这样写：先明确需求与范围。如何落地：Agent 在执行前确认边界。
- 示例：
```claude
- Discovery & Scoping: 明确目标与范围
```
- 风险提示：跳过会导致误解需求。

## 行 37
- 原文：`    - Clarify needs, define scope (Iteration Scoping), and challenge assumptions.`
- 陈述：为什么这样写：细化第 1 步动作。如何落地：Claude Code 用问题澄清并限制范围。
- 示例：
```claude
- 明确需求 + 迭代边界 + 质疑假设
```
- 风险提示：澄清不足会导致返工。

## 行 38
- 原文：`2.  **Planning (Scaled)**:`
- 陈述：为什么这样写：按复杂度制定计划。如何落地：复杂任务触发详细计划。
- 示例：
```claude
- Planning (Scaled)
```
- 风险提示：计划不足会带来执行混乱。

## 行 39
- 原文：`    - **Complex Tasks**: Detailed step-by-step plan, Constitution check, wait for approval.`
- 陈述：为什么这样写：复杂任务必须严谨计划。如何落地：Agent 先输出计划并等待确认。
- 示例：
```claude
- 复杂任务：先计划 + Constitution Check + 等待确认
```
- 风险提示：跳过确认可能违反治理规则。

## 行 40
- 原文：`    - **Simple Tasks**: Brief one-sentence plan, implicit Constitution check, proceed immediately.`
- 陈述：为什么这样写：简单任务快节奏执行。如何落地：Claude Code 给出一句话计划后直接执行。
- 示例：
```claude
- 简单任务：一句话计划后执行
```
- 风险提示：过度简化可能遗漏风险。

## 行 41
- 原文：`3.  **Execution**:`
- 陈述：为什么这样写：定义执行阶段。如何落地：Agent 进入代码与操作实施。
- 示例：
```claude
- Execution
```
- 风险提示：未进入执行会导致计划悬空。

## 行 42
- 原文：`    - Implement with TDD (Test-Driven Development) where applicable.`
- 陈述：为什么这样写：用测试驱动保证质量。如何落地：Claude Code 先写测试再实现。
- 示例：
```claude
- 先写测试，再写实现
```
- 风险提示：不适用 TDD 的场景需说明例外。

## 行 43
- 原文：`    - If task requires modifying > 3 files, break it down.`
- 陈述：为什么这样写：限制单次改动规模。如何落地：Agent 将任务拆成可控子任务。
- 示例：
```claude
- 修改超过 3 文件时，拆分任务
```
- 风险提示：过度拆分可能增加沟通成本。

## 行 44
- 原文：`4.  **Review & Verify**:`
- 陈述：为什么这样写：定义验证环节。如何落地：Claude Code 汇报验证结果。
- 示例：
```claude
- Review & Verify
```
- 风险提示：未验证交付风险极高。

## 行 45
- 原文：`    - Self-correct using the "Delivery Standards" before handing off.`
- 陈述：为什么这样写：要求自检交付标准。如何落地：Agent 对照 Delivery Standards 自查。
- 示例：
```claude
- 交付前按 Delivery Standards 自检
```
- 风险提示：自检不足会漏掉关键问题。

## 行 46
- 原文：`    - List verification results.`
- 陈述：为什么这样写：需要可追溯验证记录。如何落地：Claude Code 在结尾列出验证结果。
- 示例：
```claude
- 验证结果：lint ✅ test ✅
```
- 风险提示：未记录验证会导致审计困难。

## 行 47
- 原文：`<空行>`
- 陈述：为什么这样写：分隔核心流程与下一节。如何落地：保持章节清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响层级阅读。

## 行 48
- 原文：`### 3.2 Scenario-Specific Rules`
- 陈述：为什么这样写：引入场景特例规则。如何落地：Agent 根据任务类型选择规则。
- 示例：
```claude
### 3.2 Scenario-Specific Rules
```
- 风险提示：未区分场景会造成规则误用。

## 行 49
- 原文：`- **Feature Development**: First read relevant specifications under specs/ (if they exist).`
- 陈述：为什么这样写：功能开发应先读规格。如何落地：Claude Code 先读取 specs/。
- 示例：
```claude
@specs/feature_spec.md
```
- 风险提示：跳过规格会造成实现偏差。

## 行 50
- 原文：`- **Continuous Evolution**: After each user correction, add a new rule to **AGENTS.md** to prevent recurrence.`
- 陈述：为什么这样写：将修正转化为规则，形成闭环。如何落地：Agent 在文档中追加规则。
- 示例：
```claude
- 将本次修正写入 AGENTS.md
```
- 风险提示：规则膨胀会降低可读性。

## 行 51
- 原文：`<空行>`
- 陈述：为什么这样写：分隔场景规则与质量保证。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无空行会弱化层级。

## 行 52
- 原文：`### 3.3 Quality Assurance`
- 陈述：为什么这样写：集中定义质量标准。如何落地：Claude Code 用此节作为质量检查清单。
- 示例：
```claude
### 3.3 Quality Assurance
```
- 风险提示：质量标准不清会导致交付不稳定。

## 行 53
- 原文：`- **Bug Fixes**: When encountering bugs, follow the principle of "write reproduction test first, then fix" until tests pass.`
- 陈述：为什么这样写：以复现测试锁定问题。如何落地：Agent 先写测试再修复。
- 示例：
```claude
- 先写复现测试，再修复
```
- 风险提示：缺少复现测试可能引入回归。

## 行 54
- 原文：`- **Risk Review**: After writing code, list potential broken functionality and suggest corresponding test coverage.`
- 陈述：为什么这样写：强制风险评估。如何落地：Claude Code 输出风险清单与建议测试。
- 示例：
```claude
- 风险：权限判断变化；建议增加回归测试
```
- 风险提示：不做风险评估会遗漏边界问题。

## 行 55
- 原文：`- **Test Writing**: Prioritize writing table-driven tests.`
- 陈述：为什么这样写：表驱动测试易扩展。如何落地：Agent 使用表驱动格式组织用例。
- 示例：
```claude
- 用例表驱动：cases = [{...}, {...}]
```
- 风险提示：表驱动不适合所有场景，需要判断。

## 行 56
- 原文：`- **Production Mindset**: Handle edge cases gracefully. Do not assume "happy path" only.`
- 陈述：为什么这样写：强调生产级健壮性。如何落地：Claude Code 明确处理边界与错误路径。
- 示例：
```claude
- 处理空输入与权限不足场景
```
- 风险提示：忽略边界会导致线上故障。

## 行 57
- 原文：`<空行>`
- 陈述：为什么这样写：分隔质量保证与沟通规则。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无空行会影响扫描效率。

## 行 58
- 原文：`### 3.4 Communication & Tool Usage`
- 陈述：为什么这样写：定义沟通与 Tool 使用规范。如何落地：Agent 输出更易理解、Tool 选择更一致。
- 示例：
```claude
### 3.4 Communication & Tool Usage
```
- 风险提示：沟通不清会导致需求偏差。

## 行 59
- 原文：`- **Plain Language**: Explain technical decisions in plain language (educational). Translate jargon.`
- 陈述：为什么这样写：降低沟通门槛。如何落地：Claude Code 用通俗语言解释设计取舍。
- 示例：
```claude
- 用简明语言解释：为什么这样做更稳定
```
- 风险提示：过度简化可能损失关键细节。

## 行 60
- 原文：`- **Skill Priority**: Whenever responding, always evaluate if there are available and relevant Skills. Prioritize using them if they can significantly improve accuracy or efficiency.`
- 陈述：为什么这样写：明确 Agent Skill 优先策略。如何落地：Claude Code 优先匹配 Agent Skill。
- 示例：
```claude
- 匹配到 Agent Skill 时优先使用
```
- 风险提示：Skill 定义不准确会导致误触发。

## 行 61
- 原文：`<空行>`
- 陈述：为什么这样写：分隔沟通规则与评审流程。如何落地：形成清晰层次。
- 示例：
```claude

```
- 风险提示：无分隔会降低可读性。

## 行 62
- 原文：`### 3.5 Code Review Workflow`
- 陈述：为什么这样写：单列评审流程。如何落地：Claude Code 以此节为评审检查清单。
- 示例：
```claude
### 3.5 Code Review Workflow
```
- 风险提示：评审流程不完整会漏掉问题。

## 行 63
- 原文：`- Pre‑flight: read \`constitution.md\` and the language annex under \`docs/constitution/\`.`
- 陈述：为什么这样写：评审前对齐规则与语言附录。如何落地：Agent 先读取宪法与附录。
- 示例：
```claude
@constitution.md
@docs/constitution/go_annex.md
```
- 风险提示：未读附录会导致语言规范不一致。

## 行 64
- 原文：`- Scope guard: if a change touches more than 3 files or crosses multiple modules, run a planning step (/plan) first and define acceptance criteria.`
- 陈述：为什么这样写：复杂评审必须先规划。如何落地：Claude Code 先产出计划再进入评审。
- 示例：
```claude
/plan
```
- 风险提示：缺少计划会导致评审范围失控。

## 行 65
- 原文：`- Mode selection: use \`.claude/commands/review-code.md\` to choose between Diff Mode (incremental) or Full Path Review.`
- 陈述：为什么这样写：统一评审模式选择入口。如何落地：使用 Slash Command 规范流程。
- 示例：
```claude
/review-code diff
```
- 风险提示：模式选错会漏掉关键改动。

## 行 66
- 原文：`- Static analysis: run language‑specific checks (Go: go vet, Python: flake8, PHP: manual read).`
- 陈述：为什么这样写：用静态分析提升质量。如何落地：Claude Code 依据语言执行检查或人工审读。
- 示例：
```claude
! go vet ./...
```
- 风险提示：工具缺失会导致检查跳过。

## 行 67
- 原文：`- Module metadata check: ensure each module directory has a README that states Role/Logic/Constraints and lists submodules; ensure source files start with three header lines (INPUT/OUTPUT/POS). Record missing items in the review report.`
- 陈述：为什么这样写：强制模块元信息完整。如何落地：Agent 逐模块核对 README 与文件头。
- 示例：
```claude
- 检查 Role/Logic/Constraints 与 INPUT/OUTPUT/POS
```
- 风险提示：元信息缺失会降低系统可理解性。

## 行 68
- 原文：`- Evidence‑based: only call online documentation (e.g., Context7) when local specs and annexes are insufficient.`
- 陈述：为什么这样写：优先本地证据，减少误导来源。如何落地：Claude Code 仅在本地不足时调用外部文档。
- 示例：
```claude
- 仅在本地不足时引用外部资料
```
- 风险提示：过度依赖外部文档可能与项目规范冲突。

## 行 69
- 原文：`- SubAgent usage: delegate heavy searches to SubAgents to preserve current session context and avoid context window overload.`
- 陈述：为什么这样写：用 Sub-agent 隔离上下文。如何落地：将重搜索任务交给 Sub-agent。
- 示例：
```claude
/subagent create
```
- 风险提示：Sub-agent 定义不清会引发结果偏差。

## 行 70
- 原文：`- Delivery hygiene: after review and fixes, clean temporary artifacts and ensure \`.gitignore\` prevents local outputs from being committed.`
- 陈述：为什么这样写：保持交付卫生。如何落地：Claude Code 清理临时文件并检查 .gitignore。
- 示例：
```claude
- 清理临时文件并确认 .gitignore 覆盖
```
- 风险提示：遗漏清理会污染仓库。

## 行 71
- 原文：`<空行>`
- 陈述：为什么这样写：分隔评审流程与模板。如何落地：便于阅读结构。
- 示例：
```claude

```
- 风险提示：缺少分隔会降低可读性。

## 行 72
- 原文：`### 3.6 Module Metadata Templates`
- 陈述：为什么这样写：提供模板便于执行。如何落地：Agent 按模板生成模块说明。
- 示例：
```claude
### 3.6 Module Metadata Templates
```
- 风险提示：模板不更新会导致规范过时。

## 行 73
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与模板内容。如何落地：阅读更清晰。
- 示例：
```claude

```
- 风险提示：无空行会造成视觉拥挤。

## 行 74
- 原文：`**Module README Template**`
- 陈述：为什么这样写：标识模块 README 模板。如何落地：Agent 创建模块 README 时参照此模板。
- 示例：
```claude
**Module README Template**
```
- 风险提示：未遵循模板会导致元信息缺失。

## 行 75
- 原文：`` ``` ``
- 陈述：为什么这样写：开启模板代码块。如何落地：在 Claude Code 输出中保持格式。
- 示例：
```claude
<code fence>
```
- 风险提示：代码块未闭合会破坏后续格式。

## 行 76
- 原文：`# <Module Name>`
- 陈述：为什么这样写：模块标题占位符。如何落地：用真实模块名替换。
- 示例：
```claude
# billing
```
- 风险提示：标题缺失会降低文档可检索性。

## 行 77
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与 Role。如何落地：保持层级清晰。
- 示例：
```claude

```
- 风险提示：无分隔会降低可读性。

## 行 78
- 原文：`## Role`
- 陈述：为什么这样写：声明模块 Role。如何落地：在 Claude Code 中明确模块职责。
- 示例：
```claude
## Role
```
- 风险提示：Role 不清会影响模块边界。

## 行 79
- 原文：`<What this module represents in the system>`
- 陈述：为什么这样写：给出 Role 内容占位。如何落地：填入模块定位描述。
- 示例：
```claude
负责账单与支付结算
```
- 风险提示：描述过泛会降低价值。

## 行 80
- 原文：`<空行>`
- 陈述：为什么这样写：分隔 Role 与 Logic。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无空行会混淆段落。

## 行 81
- 原文：`## Logic`
- 陈述：为什么这样写：说明模块逻辑。如何落地：Claude Code 输出模块工作方式。
- 示例：
```claude
## Logic
```
- 风险提示：逻辑缺失会导致误用模块。

## 行 82
- 原文：`<What this module does and how it works>`
- 陈述：为什么这样写：Logic 内容占位。如何落地：描述流程与核心算法。
- 示例：
```claude
处理计费周期与折扣计算
```
- 风险提示：逻辑描述不清会阻碍维护。

## 行 83
- 原文：`<空行>`
- 陈述：为什么这样写：分隔 Logic 与 Constraints。如何落地：提升层级清晰度。
- 示例：
```claude

```
- 风险提示：无空行影响阅读。

## 行 84
- 原文：`## Constraints`
- 陈述：为什么这样写：定义调用约束。如何落地：Agent 在调用时遵循约束。
- 示例：
```claude
## Constraints
```
- 风险提示：约束缺失会导致误用。

## 行 85
- 原文：`<Rules, limits, or invariants that callers must follow>`
- 陈述：为什么这样写：约束内容占位。如何落地：填入不变量与限制。
- 示例：
```claude
只允许已验证订单进入结算
```
- 风险提示：约束不严会引发数据错误。

## 行 86
- 原文：`<空行>`
- 陈述：为什么这样写：分隔 Constraints 与 Submodules。如何落地：保持模板清晰。
- 示例：
```claude

```
- 风险提示：缺少分隔影响阅读。

## 行 87
- 原文：`## Submodules`
- 陈述：为什么这样写：列出子模块。如何落地：Claude Code 用列表描述模块拆分。
- 示例：
```claude
## Submodules
```
- 风险提示：子模块未列出会影响导航。

## 行 88
- 原文：`- <submodule-a>: <purpose>`
- 陈述：为什么这样写：子模块示例 1。如何落地：替换为真实子模块。
- 示例：
```claude
- invoice: 生成账单
```
- 风险提示：示例未替换会导致文档虚假。

## 行 89
- 原文：`- <submodule-b>: <purpose>`
- 陈述：为什么这样写：子模块示例 2。如何落地：补充更多子模块。
- 示例：
```claude
- payment: 处理支付
```
- 风险提示：遗漏子模块会影响理解。

## 行 90
- 原文：`` ``` ``
- 陈述：为什么这样写：关闭模板代码块。如何落地：确保 Markdown 结构正确。
- 示例：
```claude
<code fence>
```
- 风险提示：未关闭会破坏后续格式。

## 行 91
- 原文：`<空行>`
- 陈述：为什么这样写：分隔两种模板。如何落地：强调这是不同结构。
- 示例：
```claude

```
- 风险提示：缺少分隔影响可读性。

## 行 92
- 原文：`**Source File Header Template**`
- 陈述：为什么这样写：标识源文件头模板。如何落地：Agent 在新文件顶部输出该头部。
- 示例：
```claude
**Source File Header Template**
```
- 风险提示：未遵循会导致元信息缺失。

## 行 93
- 原文：`` ``` ``
- 陈述：为什么这样写：开启头部模板代码块。如何落地：保持格式一致。
- 示例：
```claude
<code fence>
```
- 风险提示：未闭合会破坏文档结构。

## 行 94
- 原文：`INPUT: <dependencies>`
- 陈述：为什么这样写：声明依赖输入。如何落地：Claude Code 写明依赖模块或接口。
- 示例：
```claude
INPUT: billing_repo, pricing_rules
```
- 风险提示：依赖不明会影响可测试性。

## 行 95
- 原文：`OUTPUT: <provided capabilities>`
- 陈述：为什么这样写：声明输出能力。如何落地：在头部标明对外提供功能。
- 示例：
```claude
OUTPUT: invoice.generate, invoice.validate
```
- 风险提示：输出不清会导致接口误用。

## 行 96
- 原文：`POS: <position in the system>`
- 陈述：为什么这样写：标明系统位置。如何落地：描述该文件属于哪层或子域。
- 示例：
```claude
POS: domain/billing
```
- 风险提示：位置描述不一致会混淆架构。

## 行 97
- 原文：`` ``` ``
- 陈述：为什么这样写：关闭头部模板代码块。如何落地：保证模板完整。
- 示例：
```claude
<code fence>
```
- 风险提示：未关闭会破坏后续章节。

## 行 98
- 原文：`## 4. Shell Script Standards`
- 陈述：为什么这样写：单列 Shell 规范。如何落地：Claude Code 编写脚本时遵循此节。
- 示例：
```claude
## 4. Shell Script Standards
```
- 风险提示：忽略会导致跨平台失败。

## 行 99
- 原文：`- **Cross-Platform Compatibility**: Must support both macOS (BSD) and Linux (GNU).`
- 陈述：为什么这样写：声明跨平台要求。如何落地：脚本需区分 macOS 与 Linux。
- 示例：
```claude
- 脚本需兼容 macOS 与 Linux
```
- 风险提示：未处理差异会导致脚本崩溃。

## 行 100
- 原文：`  - `sed`: Must first detect `uname -s`. macOS uses `sed -i ''`, Linux uses `sed -i`.`
- 陈述：为什么这样写：指出 sed 的平台差异。如何落地：先判断 uname 再选命令。
- 示例：
```claude
if [ "$(uname -s)" = "Darwin" ]; then sed -i '' ...; else sed -i ...; fi
```
- 风险提示：直接使用 GNU 语法会在 macOS 失败。

## 行 101
- 原文：`  - `grep`: Avoid non-POSIX parameters.`
- 陈述：为什么这样写：保证 grep 兼容性。如何落地：使用 POSIX 参数子集。
- 示例：
```claude
grep "pattern" file.txt
```
- 风险提示：非 POSIX 参数会导致兼容性问题。

## 行 102
- 原文：`  - Tool checking: Use `command -v` instead of `which`.`
- 陈述：为什么这样写：which 行为不一致，command -v 更可靠。如何落地：脚本检测 Tool 时使用 command -v。
- 示例：
```claude
command -v git >/dev/null 2>&1
```
- 风险提示：检测方式不一致会导致错误分支判断。
