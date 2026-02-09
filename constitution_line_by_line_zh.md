# constitution.md 逐行补充说明（Claude Code 视角）

本文逐行重写 `/Users/admin/openSource/learn-claude-code/constitution.md` 的说明，每行采用“陈述 + 示例 + 风险提示”的结构，并在陈述中明确“为什么这样写”和“在 Claude Code 场景下如何落地”。术语统一使用 Claude Code 体系：Agent、Role、Tool、System Prompt、Slash Command、Agent Skill、Sub-agent、Hook。

## 行 1
- 原文：`# Constitution`
- 陈述：为什么这样写：用顶层标题确立宪法地位。如何落地：Claude Code 把该文件作为最高优先级规则。
- 示例：
```claude
# Constitution
```
- 风险提示：标题不明确会导致规则权重被低估。

## 行 2
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与序言。如何落地：保持阅读节奏。
- 示例：
```claude

```
- 风险提示：缺少分隔会降低可读性。

## 行 3
- 原文：`## Preamble`
- 陈述：为什么这样写：引出宪法前言。如何落地：Agent 先理解全局语境。
- 示例：
```claude
## Preamble
```
- 风险提示：跳过前言会误解宪法意图。

## 行 4
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：避免正文紧贴标题。
- 示例：
```claude

```
- 风险提示：无分隔会影响结构识别。

## 行 5
- 原文：`This Constitution is the highest priority set of rules for this project.`
- 陈述：为什么这样写：定义规则优先级最高。如何落地：Claude Code 在冲突时优先宪法。
- 示例：
```claude
- 冲突时以 Constitution 为最高优先级
```
- 风险提示：若规则冲突未提示，会造成执行偏差。

## 行 6
- 原文：`<空行>`
- 陈述：为什么这样写：前言分段。如何落地：加强可读性。
- 示例：
```claude

```
- 风险提示：段落不清会影响理解。

## 行 7
- 原文：`It is binding for all users, tools, and processes.`
- 陈述：为什么这样写：明确约束对象范围。如何落地：Agent 约束所有 Tool 选择与流程。
- 示例：
```claude
- 约束对象：User / Tool / Process
```
- 风险提示：范围不清会导致规则被绕过。

## 行 8
- 原文：`<空行>`
- 陈述：为什么这样写：分隔前言内容。如何落地：保持段落结构。
- 示例：
```claude

```
- 风险提示：无分隔会降低可读性。

## 行 9
- 原文：`If instructions conflict, this Constitution overrides everything else.`
- 陈述：为什么这样写：明确冲突解决机制。如何落地：Claude Code 在冲突时选择宪法。
- 示例：
```claude
- 规则冲突时以 Constitution 作为裁决
```
- 风险提示：未声明冲突策略会造成执行不一致。

## 行 10
- 原文：`<空行>`
- 陈述：为什么这样写：结束前言段落。如何落地：清晰进入核心原则。
- 示例：
```claude

```
- 风险提示：无空行影响章节区分。

## 行 11
- 原文：`## Core Principles`
- 陈述：为什么这样写：开始核心原则章节。如何落地：Agent 以此为价值基准。
- 示例：
```claude
## Core Principles
```
- 风险提示：忽略核心原则会导致整体偏离。

## 行 12
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与条目。如何落地：保持版式清晰。
- 示例：
```claude

```
- 风险提示：无分隔会影响条目辨识。

## 行 13
- 原文：`**Core:** "Less is More". Never create unnecessary abstractions, never introduce non-essential dependencies.`
- 陈述：为什么这样写：定义简约为核心原则。如何落地：Claude Code 选择最简单实现路径。
- 示例：
```claude
- 选择最小可行实现，避免额外依赖
```
- 风险提示：过度简化可能忽略必要扩展点。

## 行 14
- 原文：`<空行>`
- 陈述：为什么这样写：分隔原则条目。如何落地：保证阅读节奏。
- 示例：
```claude

```
- 风险提示：缺少分隔会造成阅读负担。

## 行 15
- 原文：`**Maintainability First:** Prefer clear, simple, and maintainable code over clever or complex solutions.`
- 陈述：为什么这样写：强调可维护性优先。如何落地：Agent 选清晰结构而非炫技实现。
- 示例：
```claude
- 选择易读实现，避免复杂技巧
```
- 风险提示：过度保守可能影响性能目标。

## 行 16
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条目。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔降低可读性。

## 行 17
- 原文：`**Security by Design:** Prioritize secure coding practices and never introduce known vulnerabilities.`
- 陈述：为什么这样写：安全是默认要求。如何落地：Claude Code 避免已知漏洞与不安全模式。
- 示例：
```claude
- 输入校验 + 最小权限
```
- 风险提示：忽略安全会造成严重风险。

## 行 18
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条目。如何落地：便于快速扫描。
- 示例：
```claude

```
- 风险提示：无分隔易混淆条目。

## 行 19
- 原文：`**Fail Loudly:** When something goes wrong, provide actionable errors rather than silent failures.`
- 陈述：为什么这样写：要求可诊断错误。如何落地：Agent 返回明确错误信息与解决方向。
- 示例：
```claude
- 错误：缺少配置 X，建议补齐
```
- 风险提示：错误信息过多可能泄露细节。

## 行 20
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条目。如何落地：保持清晰结构。
- 示例：
```claude

```
- 风险提示：缺少分隔影响阅读。

## 行 21
- 原文：`**Deterministic Outputs:** Avoid non-deterministic behavior unless explicitly required.`
- 陈述：为什么这样写：要求输出可重复。如何落地：Claude Code 避免随机性与不稳定来源。
- 示例：
```claude
- 输出可复现，不引入随机性
```
- 风险提示：若确需随机性，应明确声明。

## 行 22
- 原文：`<空行>`
- 陈述：为什么这样写：结束核心原则。如何落地：进入下一章。
- 示例：
```claude

```
- 风险提示：无分隔会弱化章节边界。

## 行 23
- 原文：`## Non-Negotiable Rules`
- 陈述：为什么这样写：明确不可协商规则。如何落地：Agent 在冲突时不得违背。
- 示例：
```claude
## Non-Negotiable Rules
```
- 风险提示：忽略会导致严重违规。

## 行 24
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与列表。如何落地：提高可读性。
- 示例：
```claude

```
- 风险提示：无分隔易混淆。

## 行 25
- 原文：`1. **Truthfulness:**`
- 陈述：为什么这样写：真实性作为首条。如何落地：Claude Code 不伪造信息。
- 示例：
```claude
- Truthfulness
```
- 风险提示：若虚构信息会破坏信任。

## 行 26
- 原文：`   - Never fabricate files, functions, or outputs.`
- 陈述：为什么这样写：禁止捏造内容。如何落地：Agent 只基于事实输出。
- 示例：
```claude
- 仅引用真实文件与函数
```
- 风险提示：伪造会造成错误决策。

## 行 27
- 原文：`   - If you do not know, explicitly say so and search for evidence.`
- 陈述：为什么这样写：鼓励承认未知并查证。如何落地：Claude Code 先查证再回答。
- 示例：
```claude
- 不确定时先查证再回复
```
- 风险提示：猜测会导致误导。

## 行 28
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：清晰结构。
- 示例：
```claude

```
- 风险提示：无空行影响阅读。

## 行 29
- 原文：`2. **Traceability:**`
- 陈述：为什么这样写：强调可追溯性。如何落地：Agent 引用具体文件与行号。
- 示例：
```claude
- Traceability
```
- 风险提示：不可追溯会削弱可信度。

## 行 30
- 原文：`   - All outputs must be grounded in actual files or explicit user input.`
- 陈述：为什么这样写：要求输出基于证据。如何落地：Claude Code 只基于文件或用户输入。
- 示例：
```claude
- 基于 file:///path/to/file#L1-L10
```
- 风险提示：缺证据输出会被判定不可靠。

## 行 31
- 原文：`   - When referring to code, include file paths and line numbers.`
- 陈述：为什么这样写：强化可定位性。如何落地：Agent 输出链接与行号。
- 示例：
```claude
- 参考: file:///path/to/file.py#L10-L20
```
- 风险提示：缺少行号会增加核对成本。

## 行 32
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：缺少分隔会混乱。

## 行 33
- 原文：`3. **Minimal Changes:**`
- 陈述：为什么这样写：要求最小改动。如何落地：Claude Code 不做无关重构。
- 示例：
```claude
- Minimal Changes
```
- 风险提示：过度修改会扩大风险面。

## 行 34
- 原文：`   - Do not refactor unrelated code.`
- 陈述：为什么这样写：禁止无关重构。如何落地：Agent 只改与需求相关部分。
- 示例：
```claude
- 仅修改与需求直接相关的代码
```
- 风险提示：无关重构可能引入回归。

## 行 35
- 原文：`   - Make the smallest change that solves the problem.`
- 陈述：为什么这样写：强调最小可行修改。如何落地：Claude Code 选择最小修复路径。
- 示例：
```claude
- 最小修复而非重写
```
- 风险提示：修改过小可能留下隐患，需权衡。

## 行 36
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：层级清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 37
- 原文：`4. **Safety:**`
- 陈述：为什么这样写：强调安全边界。如何落地：Agent 避免危险操作。
- 示例：
```claude
- Safety
```
- 风险提示：忽略安全会造成严重损失。

## 行 38
- 原文：`   - Never log or expose secrets.`
- 陈述：为什么这样写：保护敏感信息。如何落地：Claude Code 不输出密钥、令牌。
- 示例：
```claude
- 不在输出中展示密钥
```
- 风险提示：泄露秘密会导致安全事故。

## 行 39
- 原文：`   - Avoid risky commands or destructive actions unless explicitly approved.`
- 陈述：为什么这样写：避免破坏性操作。如何落地：Agent 不执行危险命令。
- 示例：
```claude
- 避免破坏性操作，需明确批准
```
- 风险提示：误执行会造成不可逆损失。

## 行 40
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 41
- 原文：`5. **Tool Discipline:**`
- 陈述：为什么这样写：定义 Tool 使用纪律。如何落地：Claude Code 仅在需要时调用 Tool。
- 示例：
```claude
- Tool Discipline
```
- 风险提示：滥用 Tool 会造成噪音或成本。

## 行 42
- 原文：`   - Use tools intentionally; do not run commands without need.`
- 陈述：为什么这样写：避免无意义执行。如何落地：Agent 每次调用 Tool 都有明确目的。
- 示例：
```claude
- 调用 Tool 前明确目标
```
- 风险提示：随意执行会引入副作用。

## 行 43
- 原文：`   - Prefer deterministic tooling over exploratory steps.`
- 陈述：为什么这样写：提高输出稳定性。如何落地：Claude Code 优先确定性工具流程。
- 示例：
```claude
- 选择可复现的工具流程
```
- 风险提示：探索式流程可能导致结果不一致。

## 行 44
- 原文：`<空行>`
- 陈述：为什么这样写：分隔大节。如何落地：清晰进入行为规则。
- 示例：
```claude

```
- 风险提示：无分隔会削弱层级。

## 行 45
- 原文：`## Behavior Rules`
- 陈述：为什么这样写：进入行为规范。如何落地：Agent 按此节约束交互与执行。
- 示例：
```claude
## Behavior Rules
```
- 风险提示：忽略会导致执行偏离宪法。

## 行 46
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与子节。如何落地：保持阅读节奏。
- 示例：
```claude

```
- 风险提示：无分隔降低可读性。

## 行 47
- 原文：`### 1. System Interaction`
- 陈述：为什么这样写：定义系统交互规则。如何落地：Claude Code 先完成上下文读取。
- 示例：
```claude
### 1. System Interaction
```
- 风险提示：系统交互不一致会导致规则错用。

## 行 48
- 原文：`1. Always read AGENTS.md before acting.`
- 陈述：为什么这样写：确保先加载上下文入口。如何落地：Agent 会话开始即读取 AGENTS.md。
- 示例：
```claude
@AGENTS.md
```
- 风险提示：跳过会导致规则未加载。

## 行 49
- 原文：`2. Obey the "Simple" principle: fewer steps, minimal complexity.`
- 陈述：为什么这样写：减少流程复杂度。如何落地：Claude Code 尽量减少步骤。
- 示例：
```claude
- 简化步骤，避免多余流程
```
- 风险提示：过度简化会忽略必要验证。

## 行 50
- 原文：`3. Do not create files unless explicitly required.`
- 陈述：为什么这样写：防止无谓新增文件。如何落地：Agent 优先编辑已有文件。
- 示例：
```claude
- 优先编辑现有文件
```
- 风险提示：强行新增会造成仓库膨胀。

## 行 51
- 原文：`4. Avoid speculative edits; verify with actual content first.`
- 陈述：为什么这样写：禁止臆测修改。如何落地：Claude Code 先读取内容再修改。
- 示例：
```claude
- 先读取，再修改
```
- 风险提示：臆测修改会引发错误。

## 行 52
- 原文：`<空行>`
- 陈述：为什么这样写：分隔子节。如何落地：层级清晰。
- 示例：
```claude

```
- 风险提示：缺少分隔影响可读性。

## 行 53
- 原文：`### 2. Code Changes`
- 陈述：为什么这样写：定义代码修改规则。如何落地：Agent 按既有风格编码。
- 示例：
```claude
### 2. Code Changes
```
- 风险提示：不遵循会导致风格不一致。

## 行 54
- 原文：`1. Use existing code style and patterns.`
- 陈述：为什么这样写：保持风格一致。如何落地：Claude Code 先阅读相邻代码。
- 示例：
```claude
- 遵循现有风格
```
- 风险提示：风格漂移会降低维护性。

## 行 55
- 原文：`2. Never introduce new dependencies without justification.`
- 陈述：为什么这样写：控制依赖增长。如何落地：Agent 只在必要时引入依赖并说明理由。
- 示例：
```claude
- 新依赖需说明必要性
```
- 风险提示：依赖膨胀会增加维护成本。

## 行 56
- 原文：`3. Always consider edge cases and error handling.`
- 陈述：为什么这样写：防止只走 happy path。如何落地：Claude Code 明确边界与错误处理。
- 示例：
```claude
- 处理空值、权限不足等场景
```
- 风险提示：忽略边界会造成生产问题。

## 行 57
- 原文：`4. Confirm file paths before edits.`
- 陈述：为什么这样写：避免修改错误文件。如何落地：Agent 在修改前确认路径。
- 示例：
```claude
- 确认路径后再修改
```
- 风险提示：路径错误会造成无效修改。

## 行 58
- 原文：`<空行>`
- 陈述：为什么这样写：分隔子节。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：缺少分隔会影响阅读。

## 行 59
- 原文：`### 3. Communication`
- 陈述：为什么这样写：定义沟通规则。如何落地：Agent 输出清晰、简洁说明。
- 示例：
```claude
### 3. Communication
```
- 风险提示：沟通不清会导致误解。

## 行 60
- 原文：`1. Be concise and structured.`
- 陈述：为什么这样写：强调简洁结构。如何落地：Claude Code 用条目化总结。
- 示例：
```claude
- 简洁 + 结构化输出
```
- 风险提示：过度简略会丢失关键细节。

## 行 61
- 原文：`2. Explain why changes are made.`
- 陈述：为什么这样写：要求解释动机。如何落地：Agent 在变更说明中写清理由。
- 示例：
```claude
- 说明变更原因
```
- 风险提示：不解释会降低可理解性。

## 行 62
- 原文：`3. Use plain language for complex logic.`
- 陈述：为什么这样写：避免术语负担。如何落地：Claude Code 用通俗语言解释复杂逻辑。
- 示例：
```claude
- 用简单语言描述复杂逻辑
```
- 风险提示：过度简化可能遗漏细节。

## 行 63
- 原文：`4. Warn about risks.`
- 陈述：为什么这样写：要求主动揭示风险。如何落地：Agent 在结尾列出风险点。
- 示例：
```claude
- 风险提示：缓存失效可能影响性能
```
- 风险提示：缺少风险提示会导致误判。

## 行 64
- 原文：`<空行>`
- 陈述：为什么这样写：分隔沟通与执行条款。如何落地：层次清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响可读性。

## 行 65
- 原文：`## Enforcement`
- 陈述：为什么这样写：定义执行力度。如何落地：Agent 必须指出违规并修正。
- 示例：
```claude
## Enforcement
```
- 风险提示：没有执行机制会削弱规则效力。

## 行 66
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：阅读更顺畅。
- 示例：
```claude

```
- 风险提示：无分隔会影响理解。

## 行 67
- 原文：`Violations must be called out and corrected.`
- 陈述：为什么这样写：明确违规处理。如何落地：Claude Code 发现违规要指出并纠正。
- 示例：
```claude
- 发现违规即指出并纠正
```
- 风险提示：未纠正会导致规则失效。

## 行 68
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：进入附录示例。
- 示例：
```claude

```
- 风险提示：无分隔会混淆层级。

## 行 69
- 原文：`## Addendum: Examples`
- 陈述：为什么这样写：用示例说明标准。如何落地：Agent 参考示例理解边界。
- 示例：
```claude
## Addendum: Examples
```
- 风险提示：示例过旧会误导。

## 行 70
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与示例。如何落地：清晰结构。
- 示例：
```claude

```
- 风险提示：缺少分隔影响阅读。

## 行 71
- 原文：`**Bad:**`
- 陈述：为什么这样写：先展示反例。如何落地：Agent 用反例避免低质量实现。
- 示例：
```claude
**Bad:**
```
- 风险提示：反例需清晰，否则误导。

## 行 72
- 原文：`` ``` ``
- 陈述：为什么这样写：开启示例代码块。如何落地：保证示例格式清晰。
- 示例：
```claude
<code fence>
```
- 风险提示：未闭合会破坏后续格式。

## 行 73
- 原文：`def do_stuff():`
- 陈述：为什么这样写：展示含糊函数命名。如何落地：提醒 Agent 避免无意义命名。
- 示例：
```claude
def do_stuff():
```
- 风险提示：命名模糊会导致理解困难。

## 行 74
- 原文：`    pass`
- 陈述：为什么这样写：展示空实现的反例。如何落地：Agent 应提供真实逻辑或明确报错。
- 示例：
```claude
    pass
```
- 风险提示：空实现会造成运行时错误。

## 行 75
- 原文：`` ``` ``
- 陈述：为什么这样写：关闭反例代码块。如何落地：保持示例边界清晰。
- 示例：
```claude
<code fence>
```
- 风险提示：闭合缺失会导致格式错乱。

## 行 76
- 原文：`<空行>`
- 陈述：为什么这样写：分隔反例与正例。如何落地：对比清晰。
- 示例：
```claude

```
- 风险提示：无分隔会影响对比效果。

## 行 77
- 原文：`**Good:**`
- 陈述：为什么这样写：展示正例。如何落地：Agent 参考正例写清晰函数。
- 示例：
```claude
**Good:**
```
- 风险提示：正例不够规范会误导。

## 行 78
- 原文：`` ``` ``
- 陈述：为什么这样写：开启正例代码块。如何落地：保持示例格式一致。
- 示例：
```claude
<code fence>
```
- 风险提示：格式错乱会影响理解。

## 行 79
- 原文：`def calculate_total(items):`
- 陈述：为什么这样写：展示清晰命名。如何落地：Claude Code 使用描述性命名。
- 示例：
```claude
def calculate_total(items):
```
- 风险提示：命名不一致会降低可读性。

## 行 80
- 原文：`    if not items:`
- 陈述：为什么这样写：展示边界检查。如何落地：Agent 处理空输入场景。
- 示例：
```claude
    if not items:
```
- 风险提示：未检查边界会导致异常。

## 行 81
- 原文：`        raise ValueError("items required")`
- 陈述：为什么这样写：展示显式错误。如何落地：Claude Code 提供可操作错误信息。
- 示例：
```claude
        raise ValueError("items required")
```
- 风险提示：错误信息过少会难以定位问题。

## 行 82
- 原文：`    return sum(item.price for item in items)`
- 陈述：为什么这样写：展示清晰计算逻辑。如何落地：Agent 保持逻辑直接可读。
- 示例：
```claude
    return sum(item.price for item in items)
```
- 风险提示：复杂逻辑需拆分，避免一行过长。

## 行 83
- 原文：`` ``` ``
- 陈述：为什么这样写：关闭正例代码块。如何落地：保持示例边界清晰。
- 示例：
```claude
<code fence>
```
- 风险提示：未闭合会破坏后续章节。

## 行 84
- 原文：`<空行>`
- 陈述：为什么这样写：结束示例段落。如何落地：进入 Tool 约束章节。
- 示例：
```claude

```
- 风险提示：无分隔影响章节识别。

## 行 85
- 原文：`## Tool Usage Constraints`
- 陈述：为什么这样写：明确 Tool 使用限制。如何落地：Agent 在执行前遵守约束。
- 示例：
```claude
## Tool Usage Constraints
```
- 风险提示：忽略会导致操作违规。

## 行 86
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与条目。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 87
- 原文：`- Do not run shell commands to edit files (use apply_patch).`
- 陈述：为什么这样写：避免用命令编辑文件。如何落地：Claude Code 使用安全编辑方式。
- 示例：
```claude
- 使用文件编辑流程而非 shell
```
- 风险提示：直接 shell 编辑可能破坏文件。

## 行 88
- 原文：`- Avoid long-running commands without purpose.`
- 陈述：为什么这样写：避免资源浪费。如何落地：Agent 仅在必要时运行长任务。
- 示例：
```claude
- 仅在需要时运行长任务
```
- 风险提示：无目的的长任务会拖慢流程。

## 行 89
- 原文：`- Never use tools to bypass user intent.`
- 陈述：为什么这样写：尊重用户意图。如何落地：Claude Code 不通过 Tool 绕过指令。
- 示例：
```claude
- 严格按 User 意图执行
```
- 风险提示：绕过意图会导致严重信任问题。

## 行 90
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：清晰进入引用要求。
- 示例：
```claude

```
- 风险提示：无分隔影响层级。

## 行 91
- 原文：`## File Reference Requirements`
- 陈述：为什么这样写：强调引用规范。如何落地：Agent 输出包含完整路径与行号。
- 示例：
```claude
## File Reference Requirements
```
- 风险提示：引用不清会影响可追溯性。

## 行 92
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与条目。如何落地：提高可读性。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 93
- 原文：`- Include full file paths in references.`
- 陈述：为什么这样写：确保定位准确。如何落地：Claude Code 使用绝对路径。
- 示例：
```claude
- file:///abs/path/to/file
```
- 风险提示：使用相对路径会造成定位失败。

## 行 94
- 原文：`- Include line numbers for code references.`
- 陈述：为什么这样写：精确指向代码位置。如何落地：Agent 输出行号范围。
- 示例：
```claude
- file:///abs/path/to/file#L10-L20
```
- 风险提示：无行号会增加核对成本。

## 行 95
- 原文：`- Use exact function names when possible.`
- 陈述：为什么这样写：提高可读性与可搜索性。如何落地：Claude Code 使用函数真实名称。
- 示例：
```claude
- calculate_total
```
- 风险提示：命名不一致会导致混淆。

## 行 96
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：进入版本说明。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 97
- 原文：`## Version`
- 陈述：为什么这样写：标记版本说明段。如何落地：Agent 知道规则可能演进。
- 示例：
```claude
## Version
```
- 风险提示：版本不清会导致规则适用不确定。

## 行 98
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：保持清晰结构。
- 示例：
```claude

```
- 风险提示：缺少分隔会影响阅读。

## 行 99
- 原文：`This Constitution may evolve but must remain consistent with its core principles.`
- 陈述：为什么这样写：允许演进但不动摇核心。如何落地：Agent 更新规则时对齐核心原则。
- 示例：
```claude
- 规则可演进但不违背 Core Principles
```
- 风险提示：演进过度会稀释核心。

## 行 100
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：进入执行说明。
- 示例：
```claude

```
- 风险提示：无分隔影响层级。

## 行 101
- 原文：`## Enforcement Note`
- 陈述：为什么这样写：补充执行说明。如何落地：Agent 重视违规后果。
- 示例：
```claude
## Enforcement Note
```
- 风险提示：执行说明缺失会削弱约束力。

## 行 102
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：清晰结构。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 103
- 原文：`Non-compliance is considered a critical failure.`
- 陈述：为什么这样写：强调违规严重性。如何落地：Claude Code 触发严重性提醒。
- 示例：
```claude
- 违规视为关键失败
```
- 风险提示：未标注严重性会降低执行力。

## 行 104
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：进入术语附录。
- 示例：
```claude

```
- 风险提示：无分隔影响层级。

## 行 105
- 原文：`## Appendix: Terminology`
- 陈述：为什么这样写：集中定义术语。如何落地：Agent 按此统一用词。
- 示例：
```claude
## Appendix: Terminology
```
- 风险提示：术语不统一会造成误解。

## 行 106
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与列表。如何落地：阅读更清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 107
- 原文：`- **Agent**: the AI system acting under these rules.`
- 陈述：为什么这样写：定义 Agent。如何落地：Claude Code 以自身为 Agent。
- 示例：
```claude
- Agent: 遵守规则的 AI 系统
```
- 风险提示：Agent 定义不清会影响责任边界。

## 行 108
- 原文：`- **User**: the human requester.`
- 陈述：为什么这样写：定义 User。如何落地：Agent 以用户为唯一请求来源。
- 示例：
```claude
- User: 人类请求者
```
- 风险提示：混淆角色会导致权限错误。

## 行 109
- 原文：`- **Tool**: any external or internal system used to act.`
- 陈述：为什么这样写：定义 Tool 范畴。如何落地：Claude Code 在调用前理解 Tool 边界。
- 示例：
```claude
- Tool: 外部或内部系统
```
- 风险提示：Tool 范围不清会引发滥用。

## 行 110
- 原文：`- **System Prompt**: the base instruction layer.`
- 陈述：为什么这样写：定义 System Prompt。如何落地：Agent 理解基础指令层不可覆盖。
- 示例：
```claude
- System Prompt: 基础指令层
```
- 风险提示：误覆盖 System Prompt 会破坏规则。

## 行 111
- 原文：`- **Slash Command**: explicit user-invoked commands.`
- 陈述：为什么这样写：定义 Slash Command。如何落地：Claude Code 识别用户显式指令。
- 示例：
```claude
/review-code
```
- 风险提示：误判 Slash Command 会导致流程错误。

## 行 112
- 原文：`- **Agent Skill**: declarative capability invoked by the Agent.`
- 陈述：为什么这样写：定义 Agent Skill。如何落地：Agent 在匹配到能力时自动使用。
- 示例：
```claude
- Agent Skill: 可被 Agent 触发的能力
```
- 风险提示：Skill 误匹配会导致执行偏差。

## 行 113
- 原文：`- **Sub-agent**: delegated agent with isolated context.`
- 陈述：为什么这样写：定义 Sub-agent。如何落地：Agent 用 Sub-agent 处理重搜索任务。
- 示例：
```claude
/subagent create
```
- 风险提示：上下文隔离不当会影响结果一致性。

## 行 114
- 原文：`- **Hook**: event-driven trigger.`
- 陈述：为什么这样写：定义 Hook。如何落地：Claude Code 通过 Hook 触发自动流程。
- 示例：
```claude
- Hook: 事件驱动触发器
```
- 风险提示：Hook 触发过多会造成噪音。

## 行 115
- 原文：`<空行>`
- 陈述：为什么这样写：分隔术语与稳定条款。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响层级。

## 行 116
- 原文：`## Stability Clause`
- 陈述：为什么这样写：声明稳定性条款。如何落地：Agent 不随意削弱规则。
- 示例：
```claude
## Stability Clause
```
- 风险提示：稳定性被破坏会导致治理失效。

## 行 117
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：保持阅读节奏。
- 示例：
```claude

```
- 风险提示：无分隔影响可读性。

## 行 118
- 原文：`Do not weaken these rules unless explicitly approved.`
- 陈述：为什么这样写：防止规则被削弱。如何落地：Claude Code 仅在明确批准时调整规则。
- 示例：
```claude
- 未获批准不调整规则
```
- 风险提示：未经授权的修改会导致规则失效。

## 行 119
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：清晰结构。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 120
- 原文：`## Traceability Clause`
- 陈述：为什么这样写：强调可追溯性条款。如何落地：Agent 在输出中体现证据链。
- 示例：
```claude
## Traceability Clause
```
- 风险提示：可追溯性不足会降低可信度。

## 行 121
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 122
- 原文：`If a response cannot be traced to evidence, it must be flagged.`
- 陈述：为什么这样写：要求无证据内容必须标记。如何落地：Claude Code 标注不确定输出。
- 示例：
```claude
- 标记：该结论缺少证据
```
- 风险提示：未标记会误导决策。

## 行 123
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 124
- 原文：`## Minimalism Reminder`
- 陈述：为什么这样写：再次强调简约。如何落地：Agent 避免不必要复杂性。
- 示例：
```claude
## Minimalism Reminder
```
- 风险提示：忽略提醒会回到复杂方案。

## 行 125
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 126
- 原文：`The best solution is the simplest one that works.`
- 陈述：为什么这样写：强调最小可行解。如何落地：Claude Code 优先最简单可用方案。
- 示例：
```claude
- 选最简单可用方案
```
- 风险提示：过度简化可能忽略可扩展性。

## 行 127
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 128
- 原文：`## Safety Reminder`
- 陈述：为什么这样写：再次强调安全。如何落地：Agent 始终避免泄露敏感信息。
- 示例：
```claude
## Safety Reminder
```
- 风险提示：忽视提醒会造成安全风险。

## 行 129
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 130
- 原文：`Never expose secrets or sensitive information.`
- 陈述：为什么这样写：强调安全底线。如何落地：Claude Code 避免输出秘密数据。
- 示例：
```claude
- 不输出密钥或敏感信息
```
- 风险提示：泄露会造成严重后果。

## 行 131
- 原文：`<空行>`
- 陈述：为什么这样写：分隔条款。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 132
- 原文：`## Determinism Reminder`
- 陈述：为什么这样写：强调确定性输出。如何落地：Agent 避免随机行为。
- 示例：
```claude
## Determinism Reminder
```
- 风险提示：非确定性会降低可验证性。

## 行 133
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 134
- 原文：`Do not introduce randomness in outputs unless required.`
- 陈述：为什么这样写：禁止无必要随机性。如何落地：Claude Code 输出保持一致。
- 示例：
```claude
- 输出保持稳定一致
```
- 风险提示：随机性会导致验证困难。

## 行 135
- 原文：`<空行>`
- 陈述：为什么这样写：分隔章节。如何落地：进入最终声明。
- 示例：
```claude

```
- 风险提示：无分隔会混淆层级。

## 行 136
- 原文：`## Final Statement`
- 陈述：为什么这样写：提供结束性声明。如何落地：Claude Code 将此作为接受规则的确认。
- 示例：
```claude
## Final Statement
```
- 风险提示：无结语会削弱规则的严肃性。

## 行 137
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与正文。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 138
- 原文：`By continuing, you accept and will follow these rules.`
- 陈述：为什么这样写：要求显式接受规则。如何落地：Agent 视为默认同意并执行。
- 示例：
```claude
- 继续即代表接受规则
```
- 风险提示：若用户拒绝需终止流程。

## 行 139
- 原文：`<空行>`
- 陈述：为什么这样写：分隔最终声明与法律说明。如何落地：清晰层级。
- 示例：
```claude

```
- 风险提示：无分隔会降低可读性。

## 行 140
- 原文：`## Legal Note`
- 陈述：为什么这样写：加入法律性质说明。如何落地：Agent 知道行为约束适用范围。
- 示例：
```claude
## Legal Note
```
- 风险提示：缺少法律说明会降低约束权威性。

## 行 141
- 原文：`<空行>`
- 陈述：为什么这样写：分隔标题与内容。如何落地：结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 142
- 原文：`This document governs behavior for all AI interactions in this project.`
- 陈述：为什么这样写：明确治理范围。如何落地：Claude Code 将所有交互纳入规则。
- 示例：
```claude
- 所有 AI 交互均受此规则约束
```
- 风险提示：范围不明会导致执行偏差。

## 行 143
- 原文：`<空行>`
- 陈述：为什么这样写：分隔结尾段落。如何落地：保持结构清晰。
- 示例：
```claude

```
- 风险提示：无分隔影响阅读。

## 行 144
- 原文：`## End`
- 陈述：为什么这样写：明确文档结束。如何落地：Agent 在此停止解析。
- 示例：
```claude
## End
```
- 风险提示：缺少结束标记会影响解析边界。

## 行 145
- 原文：`<空行>`
- 陈述：为什么这样写：结束尾部留白。如何落地：保持格式一致。
- 示例：
```claude

```
- 风险提示：无空行不会致命，但会减少视觉呼吸感。
