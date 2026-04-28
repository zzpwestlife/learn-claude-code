# darwin-skill 评估报告（verification-before-completion｜边界声明补齐）

**日期**：2026-04-28  
**评估对象**：`.claude/skills/verification-before-completion/SKILL.md`  
**评估方式**：darwin-skill rubric（8维度），其中 **D8 为 dry_run 估计分**（未做 baseline/with-skill 实际对照执行）  

**对比版本**：
- 修改前：`8037ee7`
- 修改后：`9fcca58`（补齐 Invoke / Do not use / Examples）

---

## 分数对比（D1–D8）

| 维度 | 前（8037ee7） | 后（9fcca58） | 变化 | 依据摘要 |
|---:|---:|---:|---:|---|
| D1 Frontmatter（8） | 6 | 9 | +3 | description 从单句升级为 Invoke/Do not/Examples；更利于路由与误用避免 |
| D2 工作流清晰度（15） | 9 | 9 | 0 | 主体流程未变，分步 gate 清晰 |
| D3 边界条件覆盖（10） | 7 | 8 | +1 | 明确“不适用场景”与“无验证命令时的处理方式”（声明限制+给替代检查） |
| D4 检查点设计（7） | 8 | 8 | 0 | “验证门”是核心机制，主体不变 |
| D5 指令具体性（15） | 9 | 9 | 0 | 大量可执行规则与反例，空话少 |
| D6 资源整合度（5） | 8 | 8 | 0 | 不依赖外部资源也可执行；可加但非必要 |
| D7 整体架构（15） | 9 | 9 | 0 | 单一职责明确：防止无证据的完成宣称 |
| D8 实测表现（25，dry_run） | 9 | 9 | 0 | 预期显著降低“未验证就宣称成功”的错误（未做真实对照） |

> 注：括号内为权重。

---

## 总分（满分 100）

计算：`Score = Σ(维度分 1–10 × 权重) / 10`

- **修改前**：86.4  
- **修改后（baseline）**：**89.0**（+2.6）

---

## 结论（baseline）

`verification-before-completion` 在磨过的 rubric 下，当前 **dry_run baseline = 89.0**。  
后续如继续优化，应遵循 ratchet：任何改动必须让总分 **严格高于 89.0** 才保留。

