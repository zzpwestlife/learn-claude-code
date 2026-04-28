# darwin-skill Phase 2 报告（verification-before-completion｜Round 2）

**日期**：2026-04-28  
**Skill**：`verification-before-completion`  
**改动 commit**：`2b528c6`  
**改动摘要**：新增 “No-Command / No-Environment Rule (MANDATORY)”：当无法运行验证命令时必须 STOP，不得宣称成功；改为说明限制、请求所需输入，并给出降级证据优先级（CI 日志 > 复现证据 > diff 推理仅作假设）。  
**评估方式**：darwin-skill rubric（8维度），D8 为 dry_run 估计分。  

---

## Ratchet 对比

> 上一轮基线：89.8（Round 1 KEEP 后作为对照点）

### 维度评分（估计）

| 维度 | 89.8 基线 | Round 2 | 变化 | 备注 |
|---:|---:|---:|---:|---|
| D1 Frontmatter | 9 | 9 | 0 | 不变 |
| D2 工作流清晰度 | 9 | 9 | 0 | 不变 |
| D3 边界条件覆盖 | 8 | 9 | +1 | 补齐“无法运行命令/环境不具备”的停止与替代证据策略 |
| D4 检查点设计 | 8 | 8 | 0 | 不变 |
| D5 指令具体性 | 10 | 10 | 0 | 不变 |
| D6 资源整合度 | 8 | 8 | 0 | 不变 |
| D7 整体架构 | 9 | 9 | 0 | 不变 |
| D8 实测表现（dry_run） | 9 | 9 | 0 | 预期减少“没法跑命令仍宣称成功”的失败模式 |

### 总分

- **旧分（Round 1 baseline）**：89.8  
- **新分（Round 2）**：**90.8**（+1.0）

---

## Keep / Revert 结论

新分 **90.8 > 89.8**，满足 ratchet 规则，本轮变更 **KEEP**。  
`verification-before-completion` Phase 2 在“最多 2 轮”的约束下已完成。

