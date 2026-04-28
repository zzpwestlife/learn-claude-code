# Skill 边界与治理：现状调研（2026-04-28）

## 背景与目标

用户希望将文章《严肃聊聊, Skill 到底能蒸馏我们的几分之几?》中的观点落到当前项目：评估项目内 skill 是否需要调整，重点关注“触发边界声明”“避免过度 comprehensive”“skill 数量/语义重叠导致路由下降”等风险。

本调研旨在回答：
- 当前仓库内置 skill 的类型与定位是什么？
- 是否存在“边界不清 / 易误触发 / 过度抽象或过度模板锚定”的风险？
- 适合采用什么最小改动集来提升整体可用性与可维护性？

## 仓库内 skill 与相关资产概览

### 内置技能（仓库中可见）

位置：`.claude/skills/*`

可见的内置技能包括（非穷尽）：
- `brainstorming`：设计前置、强 gating 的“想清楚再动手”流程
- `writing-plans`：把 spec 转成可执行的逐步计划
- `executing-plans`：按计划执行与分段 review
- `test-driven-development`：TDD 纪律
- `verification-before-completion`：避免“未验证即宣称完成”
- `code-review`：代码审查流程/脚本

### Skill 管理与流程文档

- `docs/guides/skill-management.md`：强调 frontmatter、Negative Triggers、渐进式披露（progressive disclosure）、复杂逻辑脚本化（deterministic execution）等。
- `.claude/commands/audit-skills.md` + `.claude/scripts/audit_skills.py`：基于日志做“缺口分析”，推荐新 skills（偏“增量扩展”）。
- `docs/specs/2026-04-21--audit-skill.md`：明确从文章框架中抽取“D4 边界清晰度（触发边界声明）”作为增强点（说明本项目已意识到边界问题的独特性）。

### 第三方 skills 记录

`skills-lock.json` 显示存在多个第三方技能来源（例如 baoyu 系列等）。是否全部启用取决于运行环境，但从治理角度，存在“规模上升导致语义路由下降”的潜在风险。

## 与文章观点的对照（风险点）

1) **边界（C：适用条件）不清会导致误触发/越界**
- 文章强调 skill 是可路由单元，C 不只是关键词；同时提出“选择边界（80–100）”与语义重叠会降低路由准确率。
- 项目已有 Negative Triggers 的倡议，但未看到一个“统一的边界声明模板 + 自动检查机制”。

2) **Comprehensive 过度编码 Utility 可能负面**
- 对工程类技能而言，最有效的是 L1（纪律/流程/可验证步骤），而不是 L2（权衡直觉）。
- 强 gating 的技能（如 brainstorming）有价值，但也可能因为触发边界不清而造成“流程摩擦”。

3) **模板/范例锚定风险**
- 文章提到 linkerd-patterns 案例：模板过强会锚死模型，造成过时 API/虚构字段/无关资源。
- 本项目部分技能（以及可能安装的第三方技能）如果大量内嵌固定模板，需要明确“何时不该照抄模板”的边界提示。

## 初步结论（供后续方案选择）

建议优先做“低风险、高收益”的治理类改动：
- P0：统一补齐每个 skill 的“Invoke when / Do not use when”边界声明（可写入 frontmatter 或正文固定段落）
- P1：新增轻量 lint（检查边界字段是否存在、是否出现高频空话模式等），作为 CI 或本地命令
- P2：如 skills 数量确实较多，建立 profiles（core/optional/personal）或按需启用策略，降低路由干扰

