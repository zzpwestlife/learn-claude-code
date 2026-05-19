# Skill D8 Report Template Design

**日期**：2026-05-19  
**范围**：为 skill 评测中的 `D8（实测表现）` 提供统一、可复用的 Markdown 报告模板，先服务 `darwin-skill`，并可复用于其他 skills 的 A/B 实测与 `dry_run` 评估。  

---

## 背景

当前仓库已经具备 `darwin-skill` 的评估骨架：
- 有 8 维 rubric；
- 有 `keep / revert / results.tsv` 的 ratchet 机制；
- 有 round 报告与 A/B 报告；
- 已经开始为更多 skill 补 `test-prompts.json`。

但 `D8` 仍存在两个明显问题：
- 大量报告仍停留在 `dry_run`，证据形态不统一；
- 即便结构相近，不同报告对 `with-skill / baseline / limitation / Evidence Block / D8 决策` 的表达仍不完全一致。

这导致：
- 报告之间难以横向比较；
- `dry_run` 与 `full_test` 容易混淆；
- 后续若要把 `D8` 前移到 lint/CI 或更硬的门禁，缺少稳定字段。

因此需要一个**通用 D8 子模板**，专门负责承载评测证据，而不是重新定义完整 round 报告。

---

## 目标（Goals）

1. **统一 D8 证据表达**：让 `with-skill / baseline / dry_run fallback / Evidence Block / D8 Decision` 有固定结构。
2. **兼容两种评测模式**：
   - `full_test`：拿到真实 `with-skill / baseline` 对照证据；
   - `dry_run`：环境受限时的诚实降级。
3. **先以文档模板落地**：不引入脚本解析和 CI，优先把结构收敛。
4. **至少有 1 个真实使用样例**：避免模板成为孤立文档。

---

## 非目标（Non-Goals）

- 不重写所有历史报告
- 不把完整 round/baseline/self-host 报告统一成一个超大模板
- 不在本轮引入模板解析脚本
- 不在本轮新增 CI/lint 门禁
- 不在本轮直接触发新的 self-host round

---

## 方案概览

### Approach A：只补约定，不建模板文件

只在 `darwin-skill/SKILL.md` 或设计文档中写明“D8 报告应包含哪些段落”。

**优点**
- 改动最小

**缺点**
- 约束最弱
- 后续仍容易每次手工拼格式
- 很难形成统一字段

### Approach B（推荐）：通用 D8 Markdown 子模板

新增一个通用 Markdown 模板文件，只负责 `D8` 证据表达，并用 1 份现有报告进行试套。

**优点**
- 可复用
- 风险低
- 不与现有 round 报告结构冲突
- 为后续 lint/CI 留出稳定字段

**缺点**
- 仍需人工套用
- 第一轮只验证模板结构，不验证自动化消费链路

### Approach C：直接做脚本化模板与校验

在模板落地同时，新增字段解析脚本或自动校验规则。

**不选原因**
- 范围膨胀过快
- 当前仓库还没有稳定到适合马上固化成门禁
- 会把“统一结构”问题和“自动消费”问题混在一起

---

## 设计细节

## 1. 放置位置与职责边界

### 模板路径

- `docs/reports/templates/skill-d8-eval-template.md`

### 设计原则

- 模板是**通用 D8 子模板**，不是完整实验报告模板；
- 模板不绑定 `darwin-skill`，但优先服务 `darwin-skill`；
- 模板不直接承担 `results.tsv` 记录逻辑，只负责把 `D8` 证据表达清楚。

### 为什么不放到 skill 目录

- 放在单个 skill 目录会让模板看起来像 skill-specific 资产；
- 该模板未来应能被 `executing-plans`、`verification-before-completion` 等技能实测复用；
- `docs/reports/templates/` 更符合“报告模板”的定位。

---

## 2. 模板主结构

模板固定为 7 段：

1. `Header`
2. `Scope`
3. `Method`
4. `Environment Limitation`
5. `Results`
6. `D8 Decision`
7. `Takeaways`

### Header

必须包含：
- 报告标题
- 日期
- 评估对象
- `eval_mode: full_test | dry_run`

### Scope

必须说明：
- 本次评估的 skill
- 使用的 `test-prompts.json` 与 prompt 编号
- 若属于 self-host，补充 round 与目标维度

### Method

必须说明：
- `with-skill` 如何跑
- `baseline` 如何跑
- 用哪些指标支撑 D8 判断
- 若为 `dry_run`，推演判据是什么

### Environment Limitation

规则如下：
- `full_test` 时可省略或写 `None`
- `dry_run` 时必须填写
- 必须明确限制来源，例如：CLI 余额、权限、网络、工具不可用

### Results

包含：
- 一张总表
- 每个 case 的固定结构块
- 每个 case 的统一 `Evidence Block`

### D8 Decision

用于沉淀：
- 本次最终 D8 分数
- 置信度
- 给分理由
- 是否可反哺正式 ratchet 记录

### Takeaways

用于沉淀：
- 对当前 skill 的结论
- 对下一轮优化的建议
- 哪些证据仍然不足

---

## 3. 统一字段

模板中固定以下字段名：

- `eval_mode`
- `with-skill success`
- `baseline success`
- `rework count`
- `evidence quality`
- `question rounds`
- `limitations`
- `d8 score`
- `d8 rationale`

### 关键字段含义

- `eval_mode`
  - `full_test`：有真实对照证据
  - `dry_run`：只有合同级推演或限制条件下的估计分

- `evidence quality`
  - `0` = 无有效证据
  - `1` = 有命令但缺少关键输出
  - `2` = 命令 + exit + 关键输出，满足强证据要求

- `question rounds`
  - 记录关键澄清轮次；
  - 用于观察 skill 是否通过必要提问降低误触发或误做。

---

## 4. `full_test` 与 `dry_run` 的共存方式

### 原则

不做两套模板，而是一套模板两种填法。

### `full_test`

要求：
- `Method` 中明确 `with-skill / baseline` 双跑方式；
- `Results` 中保留真实 transcript 摘要或命令证据；
- `D8 Decision` 基于真实对照得分；
- `confidence` 默认不低于 `medium`。

### `dry_run`

要求：
- `Method` 中明确写“未执行独立对照，只做合同级推演”；
- `Environment Limitation` 变为必填；
- `Evidence Block` 中 `Limitation` 变为必填；
- `D8 Decision` 必须显式写“估计分”；
- `confidence` 默认不高于 `low` 或 `medium`。

### 目的

这样设计的好处是：
- 结构统一；
- 读者一眼能区分“真跑了”还是“没跑成”；
- 后续若要前移成自动检查字段，模板已经具备稳定命名。

---

## 5. 总表与单 case 结构

### 总表格式

```md
| Case | Prompt ID | eval_mode | with-skill success | baseline success | rework count | evidence quality | question rounds | notes |
|---|---:|---|---|---|---:|---:|---:|---|
| Case 1 | 1 | full_test | Y | N | 1 | 2 | 1 | with-skill 明显更稳 |
| Case 2 | 2 | dry_run | 受限 | 受限 | N/A | 0 | N/A | headless 被 402 阻断 |
```

### 单 case 结构

每个 case 固定 4 段：

1. `Prompt`
2. `Contract Delta`
3. `Assessment`
4. `Evidence Block`

### 单 case 设计原则

- `Prompt`：保留原始输入或 `Prompt #N`
- `Contract Delta`：只写与当前 case 最相关的 with-skill / baseline 差异
- `Assessment`：给出一句明确判断；若为 `dry_run`，必须写明“不能视为已验证成功”
- `Evidence Block`：统一字段，便于后续跨 skill 横向复盘

---

## 6. 统一 Evidence Block

模板固定为：

```md
**Evidence Block**
- Claim:
- Command:
- Exit:
- Evidence:
- Limitation:
```

### 设计原因

- 当前仓库已有 `Claim / Command / Exit / Evidence` 的惯例；
- 新增 `Limitation` 是为了把“证据内容”与“证据为什么不完整”拆开；
- `full_test` 时 `Limitation` 可写 `None`；
- `dry_run` 时 `Limitation` 必填。

---

## 7. D8 Decision 格式

模板中的 `D8 Decision` 固定为：

```md
## D8 Decision
- eval_mode:
- d8 score:
- confidence:
- rationale:
- can_feed_results_tsv: yes / no
```

### 字段说明

- `confidence`：建议只用 `high / medium / low`
- `can_feed_results_tsv`
  - `yes`：证据强度足以支撑后续正式记录
  - `no`：当前只适合作为临时或辅助证据

### 设计原因

不是每一次 `dry_run` 都适合直接反哺正式 ratchet 记录，因此必须把“是否能写入主记录链路”显式化。

---

## 8. 首轮试套策略

### 试套对象（推荐）

- `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`

### 推荐原因

- 该报告本身已经接近 A/B + D8 模板场景；
- 已有 `Method / Environment Limitation / Results / Evidence Block`；
- 改造成本低于直接改 self-host round 报告；
- 更适合作为模板首个使用样例。

### 暂不优先试套对象

- `docs/reports/2026-05-19-darwin-skill-self-host-round1.md`

原因：
- 它当前更像 self-host 摘要与评分结论；
- 若首轮直接改它，容易把“D8 子模板”和“完整 round 模板”重新混合。

---

## 9. 最小落地范围

本轮只做三件事：

1. 新建通用模板：
   - `docs/reports/templates/skill-d8-eval-template.md`
2. 用模板重构 1 份现有 A/B 报告：
   - `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
3. 补 1 个引用入口：
   - 在 `.claude/skills/darwin-skill/SKILL.md` 中补一句，说明 D8 报告可复用通用模板

---

## 验证方式

### 文档级验证

- 模板文件存在
- 模板字段完整
- 试套报告结构与模板对齐
- `full_test / dry_run` 至少有一条路径被清楚表达

### 仓库级验证

- `make lint-skills`
- `make test`
- `make check`

### 成功标准

- 模板不是孤立文档；
- 至少有 1 份真实报告采用该结构；
- 不引入新的仓库级失败。

---

## 风险与后续

### 风险

- 仅有模板并不会自动提升 D8 质量；
- 若长期没有真实 transcript，模板仍可能承载很多 `dry_run`；
- 如果后续使用者不复用模板，结构仍可能再次分叉。

### 后续建议

1. 在 `darwin-skill` 的下一轮 self-host 中复用该模板的 `D8 Decision` 与 `Evidence Block`
2. 等 2-3 份报告稳定后，再考虑前移为 lint/CI 约束
3. 条件成熟后，再讨论是否抽取脚本来检查字段完整性
