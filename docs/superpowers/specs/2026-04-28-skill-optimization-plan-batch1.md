# Skill 优化方案（Batch 1）— 基于微信文章 + 业界实践

范围：仅针对第一批 3 个 skill 的“章节级别改造方案”，避免一次性重写导致 Comprehensive 过载。

参考：微信文章《Skill 到底能蒸馏我们的几分之几？》的落地清单见：
- `docs/research/2026-04-28-wechat-skill-optimization-checklist.md`
- `docs/research/2026-04-28-skill-audit-from-wechat.md`

## 选定的第一批目标（2-3 个）

1. `verification-before-completion`
2. `executing-plans`
3. `test-driven-development`

原因：它们最贴近文章提到的 L1（确定性注入）与工程实践的“验证门”，对整个 skill 体系的外溢收益最大。

## Batch 1 的统一改造原则（防止“写得越全越差”）

### 1) 用 S=(C, π, T, R) 组织结构（并显式写出来）
- C：触发/误触发降级（triage，1-3 个判断点足够）
- π：最短可复现路径（MVP）+ 少量高质量例子（避免模板锚定）
- T：STOP 条件 + 需要用户补充什么信息
- R：固定输出格式（让别的 skill/流程可以复用）

### 2) 反锚定（Anti-anchoring）
任何“示例命令/示例代码/示例模板”，都必须声明：
- 示例仅用于“范例定锚点”，不能替代对当前仓库/当前 diff/当前环境的真实验证
- 一旦与现实冲突：以现实为准，示例立即失效

### 3) 把 L2（扩散激活/风格指令）收敛到最小
- 去掉重复、冲突的抽象口号
- 只保留少量“方向性”+ 1-2 个范例（不要堆 10 条同义句）

## 交付物

- 对每个 skill 出一份“章节级别 diff 计划”（本目录下另外 3 份文件）
- 批量落地改动后，跑一次评估/ratchet，更新对比报告

