# Claude Code 软治理 Token Guards Design

**日期**：2026-05-14  
**范围**：为当前项目增加第一轮“软提醒优先”的 token 脱困 guard，仅提供运行时提醒、路由建议与短输出模板，不做流程硬阻断。  

---

## 背景

前一轮 token 优化已经证明：
- 通过 RTK、轻量模型分流、上下文去重等手段，可以显著降低静态 prompt 与部分动态输出成本；
- 但真实 session 复盘表明，Claude Code 的高消耗问题更常见于：
  - 长会话滚动；
  - `continued from previous conversation` 续接；
  - fan-out 后失败重试；
  - 轻任务长期占用 Sonnet/Opus；
  - “调试步骤 / 测试步骤 / UI 建议”这类轻任务产生过长输出。

也就是说，单纯压 prompt 不足以“脱困”。项目需要一层更贴近真实使用路径的运行时治理机制。

---

## 目标（Goals）

1. **把脱困建议带入运行时**：在 statusline、session-summary、skill 路由与执行模板中给出明确提醒，而不是只停留在报告中。
2. **坚持软治理**：第一轮只提醒、建议、收口，不阻断用户流程，不强制拒绝执行。
3. **聚焦 4 类高收益 guard**：
   - Session Cutover Guard
   - Fan-out Budget Guard
   - Task-Class Router
   - Output Budget Templates
4. **可验证**：改动后必须能通过 `make test`、`make lint-skills`、`make check`，且能通过最小手工场景看到提醒行为。

---

## 非目标（Non-Goals）

- 不引入新的后台守护进程或独立服务
- 不做自动强制切 session
- 不在第一轮实现全自动模型切换器
- 不尝试拦截所有输出，只优先覆盖高频高价值场景

---

## 方案概览

### Approach A：仅文档规则

只更新 skills / docs / reports，把四类 guard 写成规则。

**优点**
- 风险最低
- 不影响现有工作流

**缺点**
- 不进入运行时
- 对真实使用时的约束力弱

### Approach B（推荐）：软提醒闭环

沿现有主链路接入 guard：
- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`
- `.claude/skills/using-superpowers/SKILL.md`
- `.claude/skills/dispatching-parallel-agents/SKILL.md`
- `.claude/skills/verification-before-completion/SKILL.md`

**优点**
- 已进入真实 Claude Code 使用路径
- 风险可控
- 能快速验证提醒是否有效

**缺点**
- 第一轮仍依赖用户/代理遵守建议
- 不能保证百分之百阻止失控

### Approach C：硬阻断

命中阈值后拒绝 fan-out、拒绝长输出或强制切新 session。

**不选原因**
- 现阶段误伤风险高
- 仓库现有 workflow/skill 约束已经较多，叠加硬阻断会降低可用性

---

## 设计细节

## 1. Session Cutover Guard

### 目标

当会话已接近“长上下文泥潭”时，提前提醒用户或代理：
- 现在适合收口；
- 应考虑切新 session；
- 应避免继续把不相关任务叠到当前线程。

### 接入点

- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`

### 行为

在不阻断流程的前提下，提供两层信号：

- **实时信号**：statusline 中展示“guard 命中状态”
- **会话收口信号**：session-summary 中附上“为什么建议切 session”

### 默认阈值（第一轮）

- API 请求数 `> 30`
- 累计输出 token `> 50,000`
- cache read token `> 2,000,000`
- 出现 `continued from previous conversation`

### 输出原则

- 文案必须短，不在 statusline 中解释原因链
- 只给出：
  - 正常
  - 接近阈值
  - 建议切 session

---

## 2. Fan-out Budget Guard

### 目标

减少以下高成本模式：
- 无必要的并行 agent fan-out
- 子任务失败后携带完整背景重试
- 大研究任务一次性拆成多个长输出再回灌主会话

### 接入点

- `.claude/skills/dispatching-parallel-agents/SKILL.md`
- `.claude/skills/subagent-driven-development/SKILL.md`

### 行为

在 skill 指南中显式增加“预算检查前置”：
- 并行之前先判断是否真的独立
- 当任务是研究/分析/高不确定性场景时，优先建议分段执行而非一次性 fan-out
- 子任务失败后，只允许重试最小子段，不允许把完整背景原样重发

### 第一轮边界

- 不做自动拒绝并行
- 不做动态计费查询
- 先以强规则文本 + 可验证模板方式落地

---

## 3. Task-Class Router

### 目标

减少“轻任务长期占用重模型主链路”的情况。

### 接入点

- `.claude/skills/using-superpowers/SKILL.md`
- 必要时补充 command frontmatter 的使用示例或规则说明

### 任务分类（第一轮）

- **轻任务**
  - 文档润色
  - changelog
  - commit message
  - 测试步骤整理
  - 简单 UI 建议
- **中任务**
  - 普通 bugfix
  - 小范围实现
  - 单模块调试
- **重任务**
  - 架构设计
  - 大范围重构
  - 多源研究
  - 长上下文续接任务

### 行为

- 路由层提供“建议模型档位”
- 第一轮只做建议，不强制自动改模型

---

## 4. Output Budget Templates

### 目标

减少轻任务产生过长输出，尤其是：
- 调试说明
- 测试步骤
- UI 建议
- 交付总结

### 接入点

- `.claude/skills/verification-before-completion/SKILL.md`
- `.claude/skills/executing-plans/SKILL.md`

### 第一轮模板

- **测试步骤**：最多 `8` 步
- **UI 建议**：最多 `5` 条
- **changelog**：最多 `100` 字
- **调试结论**：固定四段
  - 问题
  - 原因
  - 修复
  - 验证

### 原则

- 优先压缩“解释性废话”
- 不压缩关键证据
- 证据块仍必须保留

---

## 文件落点

### 第一批（本轮必须落）

- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`
- `.claude/skills/using-superpowers/SKILL.md`
- `.claude/skills/dispatching-parallel-agents/SKILL.md`
- `.claude/skills/verification-before-completion/SKILL.md`

### 第二批（如第一批顺利，再追加）

- `.claude/skills/subagent-driven-development/SKILL.md`
- `.claude/skills/executing-plans/SKILL.md`
- 相关 command frontmatter
- benchmark / 报告补充

---

## 验收标准（Success Criteria）

- [ ] statusline 能显示 session guard 的软提醒状态
- [ ] session-summary 能在命中阈值时给出“建议切 session”的简短原因
- [ ] `using-superpowers` 明确写出任务分类与模型档位建议
- [ ] `dispatching-parallel-agents` 明确增加 fan-out 前预算检查规则
- [ ] `verification-before-completion` 增加统一短输出模板要求
- [ ] `make test`、`make lint-skills`、`make check` 全部通过
- [ ] 至少完成 2 个手工验证场景：
  - 命中 session guard
  - 命中 fan-out / output budget 提示

---

## 风险与权衡

- **风险：提醒过多，形成噪音**  
  缓解：statusline 只显示简短信号；session-summary 只在命中阈值时输出理由。

- **风险：阈值太激进，影响正常长任务**  
  缓解：第一轮仅建议切换，不阻断执行；阈值可后续根据真实 session 再校准。

- **风险：skill 规则过多，造成路由负担**  
  缓解：只在最核心的 3 个 skill 中增加 guard，不全仓库铺开。

- **风险：Output Budget 变成“过度压缩”**  
  缓解：只约束轻任务表达长度，不压缩证据块、不压缩关键验证信息。

---

## 开放问题（当前结论）

### 是否要第一轮就做自动模型切换？

**结论：不做。**  
第一轮先做“建议模型档位”，避免自动切换引发误路由和结果波动。

### 是否要第一轮就做硬阻断？

**结论：不做。**  
第一轮先证明软提醒闭环有效，再考虑是否升级到硬治理。

### 是否要把 guard 逻辑做成单独脚本？

**结论：暂不新增。**  
优先复用现有 hook / statusline / skill 文本链路，减少系统复杂度。
