# 设计：darwin-skill 边界声明增强

## 概述

基于文章《你蒸馏出来的 Skill，到底够不够好？》的 D4 边界清晰度理念，为 darwin-skill 的
评估 rubric 补充"触发边界声明"子项，使其显式检查 Skill 是否声明了"何时不该触发/介入"。

原始的 audit-skill 设计经过分析后发现与 darwin-skill 80% 功能重叠，缩减为此单点增强。

## 范围

### 构建
- 修改 `~/.claude/skills/darwin-skill/SKILL.md` 维度3评分标准
- 将"触发边界声明"纳入维度3的显式检查点

### 不构建
- 独立的 audit-skill
- 新评分维度（不改变总分结构）

## 关键决策

文章的5维框架中，D1/D2/D3/D5 均已被 darwin-skill 的8维 rubric 覆盖。
唯一独特贡献是 D4 边界清晰度的**触发边界声明**理念——Skill 应明确写出"不适用场景"，
darwin 维度3目前只检查技术容错（异常处理/fallback路径），未检查使用边界。
