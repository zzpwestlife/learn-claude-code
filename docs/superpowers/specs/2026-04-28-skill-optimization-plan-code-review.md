# Skill 优化方案（Batch 2）：code-review

目标：基于微信文章《Skill 到底能蒸馏我们的几分之几？》的要点（S=(C,π,T,R)、避免 Comprehensive 过载、反模板锚定），把 `code-review` 从“流程描述”升级为**可审计、可复用、可路由**的审查单元。

当前文件：`.claude/skills/code-review/SKILL.md`

---

## 现状审计结论（简版）

强项：
- C（触发/降级）做得不错：明确 staged/unstaged diff、无 diff STOP、非 git STOP。
- π（步骤）覆盖较全：审查维度、Go 专项检查项、输出模板约束、TUI handoff。

主要改进点（对齐文章）：
1) **R（可复用接口）偏弱**：虽然“生成 CODE_REVIEW.md”是产物，但缺少**固定的审计证据块**与“输入/输出契约”，下游（executing-plans / CI / 人类）复用成本高。  
2) **Anti-anchoring 缺失**：当前引用了大量“审查维度/清单”，但缺少明确声明：  
   - checklist 不能替代 diff 真实阅读  
   - 不允许输出“泛化建议”充数  
   - 示例输出/模板不等于证据  
3) **frontmatter description 可收敛**：目前偏长且较泛，可能增加误触发（文章所述“选择边界/语义近邻冲突”风险）。  

---

## 章节级别改造方案（最小 diff，避免 Comprehensive 过载）

### 1) Frontmatter：压缩 description（降低语义噪音）
把 description 改成 3 行内：
- 触发：用户给了 PR/diff/commit range/文件集合，明确要审查
- 硬门槛：无 diff/非 git → STOP 并请求输入
- 输出：必须产出 `CODE_REVIEW.md`（按模板）+ “Evidence Block”

### 2) 新增 “Reusable Interface (R) — Review Artifact Contract” 小节（放在“执行代码审查”之前）
新增小节内容（固定契约，便于复用）：
1) **Inputs（必须具备其一）**
   - `git diff --cached` 或 `git diff <range>` 或 PR 链接 或 patch
2) **Outputs（必须全部具备）**
   - `CODE_REVIEW.md`（严格遵循 report-template.md）
   - `Review Evidence Block`（见下）
3) **Review Evidence Block（MANDATORY，避免“空话审查”）**
```
Claim: 完成了对 <范围> 的代码审查
Command: <实际用于获取 diff 的命令>
Exit code: <git 命令 exit code>
Evidence: <1-3 行 diff 统计/文件列表，证明确实拿到了变更输入>
Artifacts: CODE_REVIEW.md
```
> 注：这不是为了形式主义，而是为了对齐文章强调的 L1（确定性注入）：输入可验证、产物可复用。

### 3) 新增 “Anti-Anchoring（反锚定）” 小节（放在 R 后面，保持短）
要点（短且硬）：
- checklist 只是辅助，不得替代真实 diff 阅读
- 没有 diff → 不得输出泛化建议充数（必须 STOP）
- 模板/示例是格式，不是证据；结论必须指向具体文件/行/风险

### 4) 收敛“审查维度”中的泛化项（只做轻微删减）
不重写大段内容，做两点“去 Comprehensive”：
- 把“设计与架构”部分改成“只针对 diff 触及的边界做判断”，禁止泛泛而谈大重构
- 把“规范一致性”改成：仅在 repo 存在对应规范且 diff 触及相关模块时才检查（否则不强行扩展）

### 5) TUI handoff：把 3 选项描述更具体（减少误导）
保持 AskUserQuestion，但把选项描述改成“会产出什么文件/下一步做什么”，让流程更可复用。

---

## 验证方式（改完后怎么证明有效）

1) **误触发验证**：无 diff 的情况下必须 STOP（不生成空洞报告）。  
2) **输入证据验证**：有 diff 时必须附 Evidence Block，且能在输出中看到实际审查范围。  
3) **产物验证**：生成/更新 `CODE_REVIEW.md`，结构与模板一致。  

