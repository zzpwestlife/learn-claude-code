# Skill 优化方案（Batch 2）：writing-plans

目标：对齐微信文章《Skill 到底能蒸馏我们的几分之几？》的结论：
- 写得越“Comprehensive”不一定越好（甚至可能降通过率）
- 更有效的是 **Detailed（步骤明确、可执行、少而精）**

因此本次优化重点是：把 writing-plans 从“尽可能覆盖一切”调整为**最短可复现（MVP）且可验证的计划产物（R 合同）**，并补齐 Anti-Anchoring（防过度覆盖/模板锚定）。

当前文件：`.claude/skills/writing-plans/SKILL.md`

---

## 现状审计结论（简版）

强项：
- C/T 其实已经不错：无 spec → STOP 路由 brainstorming；执行请求 → 路由 executing-plans；多子系统 → AskUserQuestion 确认拆分
- π 很强：计划输出格式非常细，强调无 placeholder

风险（对齐微信文章）：
1) **Comprehensive 过载**：要求“全覆盖 + 零上下文工程师 + 全量代码块”，可能导致计划体积巨大、注意力稀释。  
2) **模板锚定**：计划模板里嵌入大量具体语言/框架示例（Python/pytest），容易让后续执行盲从示例而偏离真实仓库。  
3) **R（可复用接口）缺少“Plan Contract”的显式声明**：虽然有路径/文件要求，但缺少“计划最小必要产物清单”和“验证门引用”的硬约束描述。  

---

## 章节级别改造方案（最小 diff，避免重写）

### 1) Frontmatter：收敛 description（降低路由噪音）
压缩到 2-3 行：
- 触发：已有明确 spec/需求，需要先写计划再动代码
- 硬门槛：无 spec → STOP 路由 brainstorming；要执行 → 路由 executing-plans
- 输出：计划文件 + 最小验证命令清单

### 2) Overview：把 “Write comprehensive” 改为 “Write detailed, minimal, executable”
将核心原则写成一句话：
> Prefer **Detailed MVP plans** over “Comprehensive coverage”. Capture the shortest path to a verifiable increment.

### 3) 新增 “Reusable Interface (R) — Plan Contract” 小节（放在 Overview 后）
明确计划的“最小必要产物”与可复用接口：

**Required outputs**
1) Plan file: `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
2) (Optional) state file：仅在确实需要跟踪/分段执行时创建
3) Verification gate：每个任务至少 1 条可运行的验证命令（test/lint/build），否则必须显式标注 limitation

### 4) 新增 “Anti-Anchoring（反锚定）” 小节（紧跟 R，小而硬）
要点：
- 示例代码/命令是结构演示，不是模板；必须以仓库真实语言/测试框架为准
- 禁止为“显得全面”而罗列大量边界；边界只写“会改变计划结构/验证门”的那部分
- 若 spec 信息不足：STOP 并 AskUserQuestion，而不是用假设填满计划

### 5) “No Placeholders”保留，但增加一条“禁止虚构工具链”
例如：
- 不要写 `pytest`/`npm test`/`go test` 之类除非 repo/Spec 明确；否则改成“Run the repo’s test command (TBD: confirm)”

---

## 验证方式（改完后怎么证明有效）

1) 计划不再追求覆盖所有边界，而是能在 30 秒内读出：C/π/T/R 与最小验证门。  
2) 计划不会强行锚定到某语言/框架示例；示例只提供结构。  

