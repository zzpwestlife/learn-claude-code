# Skill 边界声明模板（试点）Design

**日期**：2026-04-28  
**范围**：先对 2 个内置 skill 做试点（`brainstorming`、`writing-plans`），仅补齐“触发/不触发边界声明”，不改动技能正文流程与硬门禁逻辑。  

---

## 背景

文章《严肃聊聊, Skill 到底能蒸馏我们的几分之几?》指出：
- Skill 的有效性存在精度阶梯：L1（纪律/规则/精确路由）最稳定；L2（Utility 权衡）不可被语言完整编码，写得“过度全面”可能适得其反。
- Skill 作为“可路由单元”，其 **适用条件（C）** 与 **边界声明** 是关键；skill 数量/语义重叠会带来路由混乱。

本项目已有 `docs/guides/skill-management.md` 提到 Negative Triggers，但缺少“统一模板 + 统一落点”，导致：
- 新增/维护 skill 时边界容易缺失；
- 使用时误触发概率上升，尤其是强流程型 skill（如 brainstorming）会造成不必要摩擦。

---

## 目标（Goals）

1. **统一表达**：为试点 skill 的 frontmatter `description` 增加标准化的边界声明结构。
2. **降低误触发**：明确“不应该触发”的场景，减少语义路由冲突与强流程误用。
3. **不引入破坏性改动**：不改 skill 主体内容，不调整硬门禁逻辑，不新增脚本。

---

## 非目标（Non-Goals）

- 不新增 lint/CI 检查器
- 不引入 profiles（core/optional/personal）
- 不重写技能流程，不改变任何步骤顺序或强制门禁

---

## 方案概览

### Approach A（推荐）：只改 frontmatter description，使用统一模板

对试点技能文件：
- `.claude/skills/brainstorming/SKILL.md`
- `.claude/skills/writing-plans/SKILL.md`

将其 YAML frontmatter 的 `description` 从“单句描述”升级为带结构的多行描述（YAML block scalar），包含：
- `Invoke when:`（应该触发）
- `Do not use when:`（不该触发）
- （可选）`Examples:`（2–4 个例子，帮助路由对齐）

**理由：**
- `description` 是路由的重要信号源，把边界放在这里最“靠近触发机制”；
- 不影响正文内容，改动最小；
- 统一风格后可逐步推广到其它 skills。

---

## 边界声明模板（可复制）

> 注意：模板文字需要“短、可判别、非空话”。不要写“视情况而定/遵循最佳实践”这类无法执行的抽象句式。

```yaml
---
name: <skill-name>
description: |
  Invoke when:
  - <触发条件 1：可判别、与其它 skill 区分明显>
  - <触发条件 2>

  Do not use when:
  - <不适用条件 1：避免误触发/越界>
  - <不适用条件 2>

  Examples:
  - "<用户请求示例 1>"
  - "<用户请求示例 2>"
version: "<保持原版本或按需更新>"
---
```

---

## 试点技能的边界要点（拟定）

### 1) brainstorming

**Invoke when（应该触发）**：
- 用户要“创建/修改功能或行为”，需要先澄清需求与方案
- 任务存在多解/风险，需要先比较方案并获得确认

**Do not use when（不该触发）**：
- 纯信息问答/概念解释（不涉及改动）
- 仅做非常小的文本改动/拼写修正（无需设计流程）

### 2) writing-plans

**Invoke when（应该触发）**：
- 已有 spec/明确需求，需要写可执行的分步实施计划（含文件路径、测试命令等）

**Do not use when（不该触发）**：
- 仍在需求不清/方案未定阶段（应回到 brainstorming）
- 只是执行既有计划（应使用 executing-plans）

---

## 验收标准（Success Criteria）

- [ ] 两个试点 skill 的 `description` 都包含 `Invoke when` 与 `Do not use when`，且措辞具体、可区分、避免空话
- [ ] 不改动 skill 正文内容（除非为了与 frontmatter 对齐做极小的标题调整）
- [ ] 形成可推广模板，后续可扩展到其它 skills

---

## 风险与权衡

- **风险：description 过长影响路由**  
  缓解：保持每段 2–4 条 bullet，例子 2 条即可；优先“区分性”而非“全面性”。
- **风险：边界写得太抽象（变成 anti-distill 的空壳）**  
  缓解：强制用“可判别条件 + 具体例子”，避免“最佳实践/视情况”等词。

