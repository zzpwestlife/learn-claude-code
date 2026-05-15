# Claude Code Session Cutover Handoff Design

**日期**：2026-05-14  
**范围**：在第一轮 soft token guards 的基础上，只强化 `Session Cutover Guard`，把“建议切 session”升级为“建议切 session + 自动生成收口模板”，仍然不引入硬阻断。  

---

## 背景

第一轮 soft token guards 已经完成两件事：

- 在 `statusline.sh` 中输出 `OK / WATCH / CUTOVER` 状态；
- 在 `session-summary.sh` 中于命中阈值时写入“建议切新 session”的简短提示。

这证明系统已经能识别“长上下文泥潭”风险，但真实使用里还有一个关键落差：

- 用户知道“该切了”，却仍然要手工整理上下文；
- Claude Code 新开会话后，往往需要重新解释：
  - 当前任务在做什么；
  - 已经完成了什么；
  - 还有什么没做完；
  - 下一步到底该怎么接。

如果切换成本过高，用户通常会继续硬撑当前长会话，最终导致 token 持续堆高、上下文继续膨胀、失败恢复越来越贵。

所以第二轮的重点不是继续增加提醒，而是降低“切过去继续做”的摩擦成本。

---

## 目标（Goals）

1. **把 CUTOVER 从状态提示升级为可执行承接**：命中阈值时，不只提示“该切了”，还要生成下一会话可直接复用的 handoff 材料。
2. **保留软治理边界**：不自动结束当前会话，不强制切换，不自动创建新 session。
3. **优先做短而稳定的承接模板**：避免再造复杂摘要器，只产出高价值、低噪音的会话交接块。
4. **保留可验证性**：新能力必须有单元测试、手工验证步骤，并保持 `make test`、`make lint-skills`、`make check` 通过。

---

## 非目标（Non-Goals）

- 不实现自动新建 Claude Code session
- 不自动把 handoff 内容注入下一会话
- 不引入新的后台进程、数据库或服务
- 不构建复杂 NLP 摘要链路
- 不扩展到 Fan-out / Router / Output Budget 的第二轮强化

---

## 方案概览

### Approach A：只加强文案

在 `statusline` 与 `session-summary` 中增加更详细的原因说明和建议动作。

**优点**
- 改动最小
- 风险最低

**缺点**
- 用户仍需手工整理承接材料
- “知道该切”但“切不过去”的问题没有解决

### Approach B（推荐）：提醒 + 收口模板

保留现有阈值提醒，并在 `CUTOVER` 命中时自动生成一个专用 handoff 文档。

**优点**
- 最贴近真实“脱困”
- 不改变主流程，不引入硬阻断
- 可以直接用测试验证文档结构与触发行为

**缺点**
- 需要定义稳定的模板结构
- 需要控制好文档长度，避免 handoff 反而变成新噪音

### Approach C：提醒 + 半自动切换

在方案 B 基础上，进一步生成新会话标题、推荐命令、更多上下文拼接内容。

**不选原因**
- 第二轮复杂度明显上升
- 很容易扩大为“会话编排器”，超出当前目标

---

## 核心设计

## 1. Handoff 触发策略

### 状态分层

- `OK`
  - 不生成 handoff
  - 正常继续
- `WATCH`
  - 只提醒接近阈值
  - 仍不生成 handoff
- `CUTOVER`
  - 输出切换提醒
  - 生成 handoff 文档

### 触发条件

沿用第一轮阈值：

- API 请求数 `>= 30`
- 输出 token `>= 50,000`
- cache read token `>= 2,000,000`
- 或会话被标记为续接

### 设计理由

第二轮不新增 `CRITICAL` 档位。  
原因是当前仓库的目标不是做“复杂分级告警系统”，而是先把“切得动”这个核心问题解决掉。

---

## 2. Handoff 文档结构

### 文件路径

- `.claude/tmp/session_cutover.md`

### 模板字段

#### Current Task

一句话描述当前会话最主要的任务。  
第一版允许基于最近 summary、Git 活动和文件改动做保守归纳；如果无法可靠归纳，则明确写：

- `Current Task: 需要人工补充`

#### What Changed

只列 3 类内容：

- 最近改动的关键文件
- 最近提交或最近工作痕迹
- 已确认成立的事实

要求短，不展开成长报告。

#### Open Issues

只保留最关键的 `1-3` 条未解决问题：

- 当前还没完成的事
- 当前实现的限制
- 下一步最可能卡住的点

#### Suggested Next Prompt

生成一个可直接复制到下一会话的短 prompt，结构固定：

```text
继续处理当前任务。先阅读 session_cutover.md，然后：
1. 确认 Current Task 是否准确
2. 优先处理 Open Issues 的第一项
3. 保持修改范围最小，完成后运行对应验证
```

#### Why Cutover

给出命中原因，只保留最关键的阈值信息，例如：

- `cache read token 已超过阈值`
- `当前会话请求次数已超过阈值`
- `检测到 continued session`

---

## 3. 生成逻辑

### 接入点

- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`

### 职责划分

#### `statusline.sh`

- 继续负责实时状态判断
- 在 snapshot 中记录：
  - `guard_status`
  - `api_requests`
  - `output_tokens`
  - `cache_read_input_tokens`
  - `continued_session`

不在这里生成 handoff 文档，避免 statusline 承担过多文档职责。

#### `session-summary.sh`

- 负责读取 snapshot
- 判断是否命中 `CUTOVER`
- 写入 `session_summary.md`
- 如命中 `CUTOVER`，额外生成 `session_cutover.md`

### 为什么不单独新增脚本

- 第二轮仍优先复用现有 hook 链路
- 减少新的入口、配置和测试成本
- 让 cutover 逻辑继续集中在 session 收口阶段

---

## 4. 内容来源与保守策略

### 可用来源

- `.claude/tmp/session_usage_snapshot.json`
- 最近 Git 活动
- 当前工作区 modified files
- 现有 `session_summary.md`

### 保守策略

如果无法高可信度推断：

- 当前任务是什么；
- 哪个问题最重要；

则模板必须明确写“需要人工补充”，而不是虚构结论。

这是本设计的核心约束：  
**宁可不全，也不生成看似流畅但不可靠的 handoff。**

---

## 文件落点

### 必须修改

- `.claude/hooks/session-summary.sh`
- `.claude/scripts/statusline.sh`
- `tests/test_soft_token_guards.py`

### 计划新增

- `docs/reports/2026-05-14-session-cutover-handoff-validation.md`

### 计划更新

- `docs/reports/2026-05-14-soft-token-guards-validation.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

---

## 验收标准（Success Criteria）

- [ ] `CUTOVER` 命中时生成 `.claude/tmp/session_cutover.md`
- [ ] handoff 文档包含：
  - `Current Task`
  - `What Changed`
  - `Open Issues`
  - `Suggested Next Prompt`
  - `Why Cutover`
- [ ] `WATCH` 状态下不生成 handoff 文档
- [ ] `session-summary.sh` 在非 Git 仓库临时目录中仍能稳定运行
- [ ] `tests/test_soft_token_guards.py` 新增 handoff 相关断言并通过
- [ ] `make test`、`make lint-skills`、`make check` 通过
- [ ] 至少完成 1 个手工 `CUTOVER` 场景验证，确认文档内容可直接用于新会话接续

---

## 风险与权衡

- **风险：handoff 内容失真**  
  缓解：采用保守模板；不确定时写“需要人工补充”。

- **风险：handoff 过长，反而带来新 token 成本**  
  缓解：字段固定，限制为短块；不生成长篇总结。

- **风险：Git 活动不足时，handoff 信息太弱**  
  缓解：允许退化为最小模板，只提供结构和建议 prompt。

- **风险：CUTOVER 频繁触发，产生过多临时文档**  
  缓解：复用固定路径 `.claude/tmp/session_cutover.md`，只保留最近一次。

---

## 开放问题（当前结论）

### 是否要自动结束当前 session？

**结论：不做。**  
第二轮只降低切换成本，不替用户做切换决策。

### 是否要自动创建下一会话 prompt 文件？

**结论：先不单独拆文件。**  
先把 `Suggested Next Prompt` 放进 `session_cutover.md`，减少文件数量。

### 是否要为 WATCH 状态也生成 handoff 草稿？

**结论：不做。**  
WATCH 只提醒，不生成承接材料，避免正常会话被过早打断。
