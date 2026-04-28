# darwin-skill Phase 2 报告（verification-before-completion｜Round 1）

**日期**：2026-04-28  
**Skill**：`verification-before-completion`  
**改动 commit**：`18b38f0`  
**改动摘要**：新增 “Evidence Template (MANDATORY)”：把成功宣称强制落到可执行证据块（Claim/Command/Exit code/Evidence），减少空洞的“验证过了”表述。  
**评估方式**：darwin-skill rubric（8维度），D8 为 dry_run 估计分。  

---

## Ratchet 对比

> 基线（baseline）：89.0（dry_run，见 results.tsv）

### 维度评分（估计）

| 维度 | 基线 | Round 1 | 变化 | 备注 |
|---:|---:|---:|---:|---|
| D1 Frontmatter | 9 | 9 | 0 | 不变 |
| D2 工作流清晰度 | 9 | 9 | 0 | 不变 |
| D3 边界条件覆盖 | 8 | 8 | 0 | 不变 |
| D4 检查点设计 | 8 | 8 | 0 | 不变 |
| D5 指令具体性 | 9 | 10 | +1 | 新增强制模板，使“证据”输出格式可执行、可检查 |
| D6 资源整合度 | 8 | 8 | 0 | 不变 |
| D7 整体架构 | 9 | 9 | 0 | 不变 |
| D8 实测表现（dry_run） | 9 | 9 | 0 | 预期降低“只说验证不贴证据”的失败模式 |

### 总分

- **旧分（baseline）**：89.0  
- **新分（Round 1）**：**89.8**（+0.8）

---

## Keep / Revert 结论

新分 **89.8 > 89.0**，满足 ratchet 规则，本轮变更 **KEEP**。  
后续 baseline 应以 89.8 为新的对照点（如进入 Round 2）。

