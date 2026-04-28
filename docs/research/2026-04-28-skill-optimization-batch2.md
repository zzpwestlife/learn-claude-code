# Batch2：后续 Skills 优化范围调研（2026-04-28）

## 目标

在已完成的试点（`brainstorming`、`writing-plans`）基础上，继续对项目内其它 skills 做：
1) “边界声明模板”补齐（Invoke / Do not use / Examples）  
2) 用磨过的 darwin-skill rubric 做结构评估（dry_run baseline），记录到 results.tsv  
3) 进入棘轮式（ratchet）迭代：只保留严格提升的改动

## 当前可见技能清单（仓库内置）

位于：`.claude/skills/*/SKILL.md`

- `code-review`
- `darwin-skill`
- `design-first`
- `executing-plans`
- `systematic-debugging`
- `test-driven-development`
- `verification-before-completion`
- `brainstorming`（已试点）
- `writing-plans`（已试点）

## 约束与注意事项（来自文章观点落地）

- 优先优化“可路由 / 可执行”的 L1/L1.5 层内容：
  - L1：流程/检查清单/可执行规则/明确验证
  - L1.5：风格/范例锚定（必须给 examples，避免互相矛盾或冗余）
- 避免陷入 Comprehensive / Utility（L2）过度编码：
  - 不把“权衡口号”写成指令；如必须提及，写成“提示 + 让模型显式列出权衡 + 人类确认”，而非硬规则穷举。
- 防 anti-distill 空壳：
  - 避免“遵循规范/视情况/最佳实践”等抽象句式；若出现必须配套判别条件或示例锚点。

## 建议的优化顺序（按收益/风险）

1) `executing-plans`：与计划/执行链路耦合紧，边界声明可显著减少误用
2) `verification-before-completion`：声明“何时必须触发、何时不必触发”能减少摩擦
3) `test-driven-development`：同上，且可明确哪些情况需要人类许可
4) `code-review`：明确“不是简单语法修正”之类的负触发
5) `systematic-debugging`：明确适用的故障类型与不适用（纯需求变更不应触发）
6) `design-first`：与 brainstorming 边界可能重叠，需要明确互斥/优先级

