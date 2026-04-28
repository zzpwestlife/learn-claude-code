# Skill 优化方案（Batch 1）：test-driven-development

目标：在不牺牲约束力的前提下，**降低 Comprehensive 过载风险**，把 TDD 写成“最短可复现闭环”（L1 确定性注入），并把证据要求与 vbc 对齐。

当前文件：`.claude/skills/test-driven-development/SKILL.md`

---

## 现状问题（来自审计 + 文章启发）

优点：
- C/π/T/R 都较强，且有 “No-Test-Runner STOP” 与 GREEN 证据字段

风险：
1) 篇幅较长（~395 行）：存在 “Comprehensive 过载” 风险（文章指出写得越全反而可能降低通过率）。  
2) 例子偏“语言/劝导”多于“工程契约”：很多段落在反驳借口，容易挤占可执行信息的注意力。  
3) 示例代码（TypeScript）存在潜在锚定风险：读者可能在非 TS 项目里照抄结构而忽略测试框架现实。  

---

## 章节级别改造方案（最小 diff）

### 1) Frontmatter：description 更短、更聚焦于 L1
- 强调三件事：
  - RED：必须先失败
  - GREEN：最小实现
  - 证据：命令/exit/关键输出
- 去掉过多“场景铺陈”

### 2) 重排结构：把 L1（闭环）放到最前面
将核心闭环“RED → Verify RED → GREEN → Verify GREEN → REFACTOR”提升到更靠前，并加入一个“一屏可读”的最小 checklist：
- RED：写一个测试
- Verify RED：运行 *单测命令*，看到 *预期失败*
- GREEN：最小实现
- Verify GREEN：运行 *同一个命令*，看到 pass/0 failures
- Refactor：保持绿

### 3) 新增 “R：可复用接口” 小节（对齐 vbc）
增加小节：
#### Reusable Interface (R): TDD Evidence Blocks
规定每个阶段报告必须使用证据块（与 vbc 模板一致）：
```
Claim:
Command:
Exit code:
Evidence:
```
并建议补充：
- Test path / test name
- 失败原因是否为“预期失败”

### 4) 新增 “Anti-anchoring（反锚定）” 短小节
明确：
- 示例代码仅用于“表达结构”，不可直接照抄到不同语言/框架
- 一切以项目真实测试命令与真实输出为准

### 5) 压缩 “Why Order Matters / Rationalizations” 为附录（或折叠）
保留约束力，但把冗长解释压缩为：
- 1 个表格（Excuse → Reality）
- 1 段总结
把可执行信息置顶，减少 L2 噪音。

---

## 验证方式（改完后怎么证明没写坏）

1) 文档结构检查：是否能在 30 秒内找到：
   - 触发条件（C）
   - 闭环步骤（π）
   - STOP 条件（T）
   - 证据块模板（R）
2) 在真实 bugfix 任务里，强制输出 RED 与 GREEN 的证据块（命令/exit/关键输出）

