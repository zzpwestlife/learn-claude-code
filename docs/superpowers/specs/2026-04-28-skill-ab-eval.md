# Skills 实测 A/B 评估方案（2026-04-28）

目标：把当前的 **dry_run 分数**升级为**可复现的实测证据**，验证这些“STOP/降级/证据模板”是否真的减少失败模式。

---

## 1) 评估对象

优先挑“门控最关键”的 4 个技能做首轮：
- `verification-before-completion`
- `test-driven-development`
- `executing-plans`
- `code-review`

---

## 2) 任务集（建议 2 个）

每个任务都要满足：可重复、可验证、有明确 done 定义。

**Task A（小型 bugfix）**  
- 输入：一个可复现 bug + 最小 repro + 期望行为  
- 输出：修复 + 回归测试 + 证据

**Task B（中型变更）**  
- 输入：一段已批准的 spec（或清晰需求）  
- 输出：按计划落地 + 验证门 + 变更摘要

> 任务可在同一 repo 内完成，避免环境噪声。

---

## 3) 对照组定义

对每个任务，执行两次：

### A 组：with-skill
- 明确声明使用哪个 skill
- 严格遵守其 STOP/证据模板/路由策略

### B 组：without-skill
- 不引用 skill 文本
- 允许正常工程实践，但不强制证据模板与门控语句

---

## 4) 指标（轻量但可审计）

每次执行记录以下字段（建议直接写入单个 markdown 表格）：

- **Success**：是否完成（Y/N）
- **Rework count**：因遗漏/误触发导致的返工次数
- **Completion evidence quality**：
  - 0 = 无证据宣称完成
  - 1 = 有命令但无关键输出
  - 2 = 命令 + exit code + 关键输出（满足 vbc 模板）
- **Question rounds**：关键澄清问题轮次（越少不一定越好，但“无问也能对”通常是红旗）
- **Time proxy（可选）**：大致轮次/提交数（不用精确工时）

---

## 5) 执行步骤（建议）

1. 选定任务 A/B 的输入（固定，不在执行中改需求）
2. 先跑 A 组（with-skill），记录过程与产物
3. 再跑 B 组（without-skill），记录过程与产物
4. 汇总对比：失败模式是否显著减少（尤其是“无证据完成宣称”“未跑红就写绿”等）

---

## 6) 产物

- `docs/reports/YYYY-MM-DD-skill-ab-eval-results.md`（对照结果表 + 结论）
- 若结论明确：将 A/B 结果反向喂给 rubric（更新 D8 的评估依据，而不是只用估计）

