# 2026-05-14 Session Cutover Handoff Validation

## 范围

本报告覆盖第二轮 `Session Cutover Handoff` 的设计落地，以及第三轮 `Handoff Quality` 的内容质量增强验证，目标是确认：

- `CUTOVER` 命中后会额外生成承接文档，而不只是提示切 session
- handoff 文档结构稳定、足够短、可直接作为下一会话入口
- 当前实现仍保持软治理，不自动创建新 session，也不自动注入下一会话 prompt
- 第三轮只消费可验证信号，提升 `Current Task` 与 `Open Issues` 的可接手性

设计文档：`docs/superpowers/specs/2026-05-14-session-cutover-handoff-design.md`

## Trigger

### 验证对象

- `.claude/scripts/statusline.sh`
- `.claude/hooks/session-summary.sh`
- `tests/test_soft_token_guards.py`

### 命中条件

- `guard_status = CUTOVER`
- 当 snapshot 未显式写入 `guard_status` 时，`session-summary.sh` 会按以下阈值回退判断：
- API 请求数 `>= 30`
- 输出 token `>= 50000`
- cache read token `>= 2000000`
- 或会话被标记为续接

### 结果

- `statusline.sh` 会把 `guard_status`、`api_requests`、`output_tokens`、`cache_read_input_tokens`、`continued_session` 写入 `.claude/tmp/session_usage_snapshot.json`
- `session-summary.sh` 在读取到 `CUTOVER` 时，会在常规 summary 之外额外生成 handoff 文档
- `WATCH` 或 `OK` 状态下不会保留 `session_cutover.md`

## Generated Files

- `.claude/tmp/session_summary.md`
- `.claude/tmp/session_cutover.md`
- `.claude/tmp/session_usage_snapshot.json`

## Handoff Structure

当前生成的 `session_cutover.md` 包含以下固定字段：

- `Current Task`
- `What Changed`
- `Open Issues`
- `Suggested Next Prompt`
- `Why Cutover`

对应的当前实现行为：

- `Current Task` 默认写入“需要人工补充”，避免在信息不足时虚构结论
- `What Changed` 优先写最近 1 小时内的最近 commit；无 commit 时写 `No recent commit detected.`
- `Open Issues` 保守退化为“需要人工补充当前未完成事项”
- `Suggested Next Prompt` 输出固定 3 步短 prompt，可直接复制到下一会话
- `Why Cutover` 记录 API requests、output tokens、cache read tokens、continued session 的当前值

## Round 3: Handoff Quality

第三轮不再扩展 handoff 字段，而是只增强已有字段的保守归纳质量。

- `Current Task` 优先使用 recent commit 生成“正在处理：...”摘要
- 无 recent commit 但存在工作区改动时，回退为“正在处理 <文件名> 相关工作”
- 两类信号都缺失时，继续保留 `需要人工补充`，避免虚构任务结论
- `Open Issues` 只基于未提交改动、最近无提交记录、已命中 `CUTOVER` 这三类可验证信号生成
- `Open Issues` 最多输出 3 条，保证 handoff 仍可快速消费

对应验证证据：

- `test_session_summary_uses_recent_commit_for_current_task`
- `test_session_summary_uses_modified_files_for_current_task_when_no_recent_commit`
- `test_session_summary_keeps_manual_placeholder_when_no_reliable_signal`
- `test_session_summary_generates_bounded_open_issues`

第三轮设计文档：`docs/superpowers/specs/2026-05-14-cutover-handoff-quality-design.md`

## 手工验证

1. 构造高 usage payload 调用 `statusline.sh`
2. 确认 statusline 输出包含 `CUTOVER`
3. 检查 `.claude/tmp/session_usage_snapshot.json` 已写入 handoff 所需字段
4. 在包含 snapshot 的目录调用 `session-summary.sh`
5. 确认 `.claude/tmp/session_summary.md` 包含 `Session Guard` 和“建议切新 session”
6. 确认 `.claude/tmp/session_cutover.md` 已生成，且包含 5 个固定段落
7. 再用 `WATCH` snapshot 复跑 `session-summary.sh`
8. 确认旧的 `session_cutover.md` 会被删除，不会在非 `CUTOVER` 状态残留

## 自动化验证

执行命令：

```bash
python3 -m unittest tests.test_soft_token_guards -v
```

覆盖点：

- `statusline.sh` 阈值命中时输出 `CUTOVER`
- `statusline.sh` 写出的 snapshot 保留 cutover handoff 所需字段
- `session-summary.sh` 在 `CUTOVER` 状态生成 `session_cutover.md`
- `session-summary.sh` 在 `WATCH` 状态删除旧 handoff，避免残留误导
- handoff 文档包含 5 个固定字段
- `Current Task` 会按 recent commit -> modified files -> 人工补充 的顺序保守回退
- `Open Issues` 只使用可验证信号，且条目数量被限制在 3 条以内
- 第一轮 soft guards 相关 skill 规则仍保留

## 结论

- 第二轮 `Session Cutover Guard` 已从“只提醒切 session”升级为“提醒 + 生成短 handoff”
- 第三轮继续提升 handoff 可接手性，但仍坚持“只用可验证信号”的保守策略
- 当前 handoff 结构满足设计要求，并且在信息不足时保守退化为“需要人工补充”
- 当前实现仍严格停留在软治理范围内，不自动切会话、不自动接管下一轮任务
