# 2026-05-14 Soft Token Guards Validation

## 范围

本报告只覆盖本轮 Soft Token Guards 的软治理验证，目标是确认以下 4 类 guard 已进入仓库主链路，并保持“提醒优先、不做硬阻断”：

- Session Cutover Guard
- Fan-out Budget Guard
- Task-Class Router
- Output Budget Templates

设计文档：`docs/superpowers/specs/2026-05-14-soft-token-guards-design.md`

## Session Cutover Guard

### 验证对象

- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`

### 命中条件

- API 请求数 `>= 30`
- 输出 token `>= 50000`
- cache read token `>= 2000000`
- 或会话被标记为续接

### 手工验证

1. 用高 cache read token 的 payload 调用 `statusline.sh`
2. 确认输出包含 `CUTOVER`
3. 写入 usage snapshot 后调用 `session-summary.sh`
4. 确认 summary 里出现 `Session Guard` 和“建议切新 session”

### 结果

- `statusline.sh` 会在阈值命中时显示 `CUTOVER`
- `session-summary.sh` 会在收口文档中追加切 session 建议
- 当前实现只输出状态与简短原因，没有硬阻断行为，符合软治理目标

## Round 2: Session Cutover Handoff

- 第二轮设计文档：`docs/superpowers/specs/2026-05-14-session-cutover-handoff-design.md`
- 第二轮验证报告：`docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- `CUTOVER` 命中后新增 `.claude/tmp/session_cutover.md`
- 该文档包含 `Current Task`、`What Changed`、`Open Issues`、`Suggested Next Prompt`、`Why Cutover`
- 第二轮仍只做短承接，不自动创建新 session，也不自动注入下一会话 prompt

## Fan-out Budget Guard

### 验证对象

- `.claude/skills/dispatching-parallel-agents/SKILL.md`

### 检查点

- fan-out 前必须先做预算检查
- 研究/分析/高不确定性任务优先分段执行
- 子任务失败后只允许重试最小子段
- 长会话续接或上下文膨胀时优先收口，而不是继续并行

### 结果

- skill 文档已补入明确规则，能把“先判断是否真的独立”前置到并行决策之前
- 当前形态是强规则文本，不自动拒绝并行，符合第一轮范围

## Task-Class Router

### 验证对象

- `.claude/skills/using-superpowers/SKILL.md`

### 检查点

- 文档包含 `Task-Class Router`
- 明确区分轻任务、中任务、重任务
- 给出模型档位与会话长度建议

### 结果

- 轻任务、中任务、重任务分类已写入 skill
- 路由建议已补充“轻任务优先轻量模型或短会话；重任务再进入重模型主链路”
- 当前只做建议，不做自动模型切换，符合设计约束

## Output Budget Templates

### 验证对象

- `.claude/skills/verification-before-completion/SKILL.md`

### 检查点

- 文档包含 `Output Budget`
- 测试步骤、UI 建议、changelog 的长度上限明确
- 调试结论使用固定四段模板
- 明确保留 exit code、失败用例名、命令证据

### 结果

- 轻任务输出预算与不可压缩证据项均已落地
- 模板能约束解释性废话，同时保留验证证据

## 回归验证

执行命令：

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

覆盖点：

- `statusline.sh` 阈值命中时输出 `CUTOVER`
- `session-summary.sh` 在 snapshot 存在时写入 `Session Guard`
- 3 份 skill 文档包含 router / fan-out / output budget 规则

## 结论

- 4 类 Soft Token Guards 已进入 statusline、session-summary 与关键 skill 文档
- 当前行为全部为软提醒或软约束，没有引入流程硬阻断
- 后续仍需通过真实长会话继续校准阈值，尤其是 `cache read token` 与 `continued session` 的触发频率
