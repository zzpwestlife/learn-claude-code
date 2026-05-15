# Claude Code Cutover Handoff Quality Design

**日期**：2026-05-14  
**范围**：在第二轮 `Session Cutover Handoff` 基础上，只增强 `session_cutover.md` 的内容质量，重点提升 `Current Task` 与 `Open Issues` 的保守自动归纳能力；不引入模型、不增加新服务、不改动 hard guard。  

---

## 背景

第二轮已经让 `CUTOVER` 从“只提醒切 session”升级为“提醒 + 生成 handoff”，并验证了以下能力：

- `CUTOVER` 命中后会生成 `.claude/tmp/session_cutover.md`
- 文档包含固定的 5 个区块
- `WATCH` / `OK` 不会残留旧 handoff
- 当前实现仍保持软治理，不自动创建新 session，也不自动注入下一轮 prompt

但现阶段仍有一个明显短板：

- `Current Task` 常常退化为“需要人工补充”
- `Open Issues` 也经常退化为保守占位

这意味着 handoff 已经“可用”，但还不够“可接手”。  
第三轮的目标不是再扩展功能，而是让现有 handoff 在不牺牲可信度的前提下，更接近真实工作交接材料。

---

## 目标（Goals）

1. **增强 handoff 的可接手性**：让 `Current Task` 和 `Open Issues` 在信息足够时生成更具体的短归纳。
2. **坚持保守归纳**：不调用 LLM，不做激进推断；信息不足时，仍明确退回“需要人工补充”。
3. **复用现有本地信号**：仅基于 Git 痕迹、`session_summary.md`、snapshot 和工作区变更做规则式归纳。
4. **保持短文本输出**：每个字段都必须短，避免 handoff 变成长摘要。
5. **可测试、可回退**：新增单元测试覆盖具体归纳、保守回退、条目数量上限。

---

## 非目标（Non-Goals）

- 不引入模型或外部摘要服务
- 不自动分析业务“根因”
- 不对 `What Changed`、`Suggested Next Prompt`、`Why Cutover` 做大改
- 不扩展到 Fan-out、Router、Output Budget 的第三轮强化
- 不自动创建新 session 或自动执行交接

---

## 方案概览

### Approach A：只读 Git 痕迹

数据源只使用：

- `recent commit`
- `git status`
- modified files

**优点**
- 最稳
- 规则简单

**缺点**
- 信息过弱
- 很多场景仍会退化成“需要人工补充”

### Approach B（推荐）：Git + Session Summary 关键词归纳

数据源使用：

- `.claude/tmp/session_summary.md`
- `recent commit`
- modified files
- `.claude/tmp/session_usage_snapshot.json`

**优点**
- 比纯 Git 更有用
- 仍然完全本地、完全规则化
- 能显著提升 `Current Task` 与 `Open Issues` 的实用性

**缺点**
- 需要谨慎定义关键词和优先级
- 错误规则会让 handoff 看起来“像总结”，但其实不可靠

### Approach C：本地启发式摘要器

增加更多路径语义、文件名分类和提交信息映射规则，尽量自动填满字段。

**不选原因**
- 容易膨胀成复杂规则系统
- 与第三轮“保守归纳”的约束冲突

---

## 核心设计

## 1. 数据来源与优先级

### 可用输入

- `.claude/tmp/session_summary.md`
- `.claude/tmp/session_usage_snapshot.json`
- `git log --since="1 hour ago" --oneline --no-merges`
- `git status --short`

### 优先级

#### `Current Task`

优先使用：

1. `session_summary.md` 中最近活动标题或可提炼短句
2. 最近 commit message
3. modified files 的主路径 / 主模块
4. 无法可靠归纳时回退 `需要人工补充`

#### `Open Issues`

优先基于以下信号生成：

1. 存在未提交改动
2. 没有 recent commit，说明可能仍在探索阶段
3. 命中 `CUTOVER`，新会话应先确认优先级和第一步

不允许凭空生成业务问题、根因判断或未被证据支持的下一步。

---

## 2. Current Task 归纳规则

### 规则 1：优先从 recent commit 提炼

如果最近 1 小时内存在 commit，则：

- 取第一条 recent commit 的 message
- 清除 hash
- 生成短句：
  - `正在处理：<commit message>`

例如：

- recent commit: `feat: add session cutover handoff`
- 输出：`正在处理：session cutover handoff`

### 规则 2：无 commit 时，从主改动路径归纳

如果没有 recent commit，但存在 modified files：

- 取前 1-2 个最具代表性的路径
- 生成短句：
  - `正在处理 <path/module> 相关工作`

例如：

- `.claude/hooks/session-summary.sh`
- `tests/test_soft_token_guards.py`
- 输出：`正在处理 session-summary 与 soft token guard 相关工作`

### 规则 3：无可靠信号时保守回退

如果：

- 没有 recent commit
- 没有 modified files
- 或提取结果过于噪音化

则输出：

- `需要人工补充`

---

## 3. Open Issues 归纳规则

### 输出约束

- 最多 `3` 条
- 每条最多一行
- 必须来自可验证信号

### 规则 1：存在未提交改动

当 `git status --short` 非空时，加入：

- `仍有未提交改动，建议新会话先确认本轮修改边界`

### 规则 2：没有 recent commit

当最近 1 小时内没有 commit 时，加入：

- `最近没有提交记录，可能仍处于探索或整理阶段`

### 规则 3：命中 CUTOVER

命中 `CUTOVER` 时，加入：

- `当前会话已触发 cutover，建议新会话先确认第一优先任务`

### 规则 4：信息不足时保守回退

如果以上信号都不足以生成任何问题，则输出：

- `需要人工补充当前未完成事项`

---

## 4. 文本约束

### Current Task

- 只允许一句话
- 不超过 `40` 个汉字或同等长度

### Open Issues

- `1-3` 条
- 不允许长解释
- 不允许出现“可能根因是...”这类推测性表达

### Why Cutover

- 保持第二轮现状
- 只保留状态值，不补解释性文字

---

## 5. 接入方式

### 修改范围

- `.claude/hooks/session-summary.sh`
- `tests/test_soft_token_guards.py`
- `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

### 为什么尽量不改 `statusline.sh`

第三轮重点是“消费已有信号”而不是“再引入新信号”。  
现有 snapshot 已足够支持 CUTOVER 判断与 handoff 生成，所以本轮优先不扩大 statusline 责任。

---

## 验收标准（Success Criteria）

- [ ] 存在 recent commit 时，`Current Task` 能生成具体短句，而不是默认占位
- [ ] 没有 recent commit、但存在 modified files 时，`Current Task` 能生成保守路径归纳
- [ ] 信息不足时，`Current Task` 仍回退为 `需要人工补充`
- [ ] `Open Issues` 基于可验证信号生成，且最多 `3` 条
- [ ] `Open Issues` 不生成未被证据支持的业务问题或根因判断
- [ ] `tests/test_soft_token_guards.py` 新增归纳相关用例并通过
- [ ] `make test`、`make lint-skills`、`make check` 通过

---

## 风险与权衡

- **风险：文件路径归纳过于机械**  
  缓解：优先 recent commit，其次路径归纳；路径归纳只做短句，不做复杂语义解释。

- **风险：summary 关键词误导 handoff**  
  缓解：第三轮不依赖自由文本长摘要，只提取有限、可验证信号。

- **风险：Open Issues 过于模板化**  
  缓解：允许在有实际信号时生成更具体条目，否则回退占位，而不是虚构问题。

- **风险：规则逐渐膨胀**  
  缓解：本轮只做 3-4 条核心规则，不构建启发式“大系统”。

---

## 开放问题（当前结论）

### 是否要在第三轮引入更复杂的路径语义映射？

**结论：不做。**  
先验证“recent commit + modified files + summary 信号”是否足够。

### 是否要把 `Open Issues` 直接变成待办清单？

**结论：不做。**  
第三轮仍然只生成交接提示，不替代任务系统。

### 是否要自动读取测试失败信息来增强 Open Issues？

**结论：先不做。**  
这会让第三轮范围扩张到更复杂的执行态分析。
