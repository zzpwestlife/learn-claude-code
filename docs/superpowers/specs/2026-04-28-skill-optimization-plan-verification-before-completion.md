# Skill 优化方案（Batch 1）：verification-before-completion

目标：在不增加篇幅的情况下，强化 **R（可复用接口）** 与 “反锚定”，并把关键规则结构化为可复用模块，避免 Comprehensive 过载。

当前文件：`.claude/skills/verification-before-completion/SKILL.md`

---

## 现状问题（来自审计 + 文章启发）

优点：
- 已经有强 T（No-Command/No-Environment STOP）与强证据块模板（Evidence Template）

需要补强：
1) **R 不够“可调用”**：有证据模板，但缺少“交付物清单/输出格式约束”，下游（executing-plans / code-review / CI）难以直接复用。  
2) **L2 内容略多**：大量“为什么”与“合理化反驳”，可能引入 Comprehensive 过载（文章提到 “越全越差”）。  
3) **缺 Anti-anchoring**：需要明确“证据块不是形式主义”，必须绑定真实命令/真实环境/真实输出，禁止用假输出/转述输出。  

---

## 章节级别改造方案（最小 diff）

### 1) Frontmatter：压缩 description（避免路由噪音）
- 目标：`description` 控制在 ~250-350 字符以内，保留：
  - 触发场景（完成宣称/commit/PR 前）
  - 不适用场景（纯信息/无可跑命令）
  - 1 句强调 “证据块”

### 2) 新增一个“R：可复用接口”小节（放在 Overview 后面）
新增小节：
#### Reusable Interface (R)
- 输出必须使用 **Evidence Template**
- 允许被其它 skill 直接引用的 2 个模板：
  1. `Evidence Template`（Claim/Command/Exit code/Evidence）
  2. `Limitation Template`（当无法运行命令时的固定措辞）
- 产物清单（Artifacts）：
  - 验证命令
  - exit code
  - 关键输出 1-3 行
  - 若涉及代码：`git diff --stat`（可选）+ 失败时的下一步

### 3) 新增 “Anti-anchoring（反锚定）” 短小节（放在 Evidence Template 之后）
内容要点（短）：
- 禁止伪造/转述 output
- 禁止把“我确信/看起来正确/应该通过”写进 Evidence
- 示例输出仅作格式示范，不构成证据

### 4) “Why This Matters / Rationalization Prevention” 迁移为附录或压缩
- 把长篇叙述压缩为：
  - 1 段总结 + 1 个表格（保留最强约束）
- 目标：减少 L2 噪音，让 L1（确定性注入：命令→输出→结论）更醒目

---

## 验证方式（改完后怎么证明没写坏）

1) 纯文档：人工检查章节结构是否更清晰（C/π/T/R 是否能一眼看到）
2) 和 executing-plans 的联动：在执行流程里引用 vbc 的 Evidence Template

