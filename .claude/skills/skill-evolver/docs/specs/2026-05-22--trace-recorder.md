# 设计：Skill Trace 自动录制层

## 概述

在 Claude Code hooks 的驱动下，每次 skill 被调用后自动将 user input + assistant response 作为候选 trace 写入全局暂存区，供后续一键促进为 skill-evolver dataset，无需手动粘贴对话。

## 范围

### 构建
- `trace-recorder.js`：双模式 hook 脚本（post-tool / stop）
- `trace-review.js`：review CLI（交互 + --auto 模式）
- `settings.json` 新增 PostToolUse hook，Stop hook 追加一条
- `~/.claude/skill-traces/pending.jsonl` 全局暂存区
- `references/trace-recorder.md`：集成说明文档

### 不构建
- 不修改 skill-evolver 的迭代循环（Review→Ideate→...）
- 不自动运行 L2/L3 eval（trace 录制与评估解耦）
- 不支持 expected_output 的 LLM 自动评分（留给人工 review）
- 不构建 Web UI

## 架构

```
每轮对话：
  PostToolUse(Skill) → trace-recorder.js post-tool
    → /tmp/skill-stub-<session_id>.json

  Stop → trace-recorder.js stop
    → 读 stub（无则退出）
    → 读 transcript JSONL，提取 user + assistant 消息
    → append ~/.claude/skill-traces/pending.jsonl
    → 删 stub

定期 review：
  node trace-review.js [--skill <name>] [--auto] [--split dev|gt]
    → 读 pending.jsonl
    → 写 ~/.claude/skills/<skill>/dataset/{dev,gt}.jsonl
    → 标记 status=promoted
```

## 组件

### trace-recorder.js

**模式 post-tool**（PostToolUse hook）
- 读 stdin: `{ tool_name, tool_input: {skill, args}, session_id }`
- 写 `/tmp/skill-stub-<session_id>.json`（append，支持同轮多次 Skill 调用）
- 字段缺失时静默 exit 0

**模式 stop**（Stop hook）
- 读 stdin: `{ session_id, transcript_path? }`
- 查 stub 文件，不存在则 exit 0
- 解析 transcript JSONL：优先用 `transcript_path`，回退 glob `~/.claude/projects/**/<session_id>.jsonl`
- 提取当轮最后一条 type=user + 最后一条 type=assistant
- 构造 PendingTrace，expected_output 截断至 3000 chars
- Append → `~/.claude/skill-traces/pending.jsonl`
- 删 stub
- 任何错误：降级为 `status=partial`，stderr 记录，exit 0

### trace-review.js

```
--auto          所有 pending → dev，无需交互
--skill <name>  仅处理该 skill 的 trace
--split <s>     指定目标 split（dev|gt，默认 dev）
```

交互模式按键：`[y]dev [g]gt [n]skip [d]delete [q]quit`

写入路径：`~/.claude/skills/<skill>/dataset/{dev,gt}.jsonl` + `traces/<id>.json`

### pending trace 结构

```json
{
  "id": "auto-20260522-001",
  "skill": "observability-skills",
  "input": "...",
  "expected_output": "...",
  "args": "...",
  "timestamp": "2026-05-22T10:45:00+08:00",
  "session_id": "...",
  "transcript_path": "...",
  "status": "pending"
}
```

## 数据流

```
User → Claude → [PostToolUse] → stub file
                [Stop]        → stub + JSONL → pending.jsonl
User → CLI   → trace-review  → pending.jsonl → skill dataset
```

## 错误处理

| 场景 | 处理 |
|---|---|
| transcript_path 缺失 | glob 查找，失败则写 partial |
| JSONL 解析失败 | 写 partial stub，stderr 记录，exit 0 |
| pending.jsonl 不存在 | 自动创建目录 |
| skill 无对应 dataset 目录 | review 时提示，或跳过 |
| 同轮多次 Skill 调用 | stub append 模式，生成多条 trace |
| **所有 hook 脚本** | 必须 exit 0，不阻断对话 |

## 测试策略

| 类型 | 用例 |
|---|---|
| Happy path | skill 调用 → pending 新增完整 trace |
| Partial | 无效 session_id → status=partial，不崩溃 |
| 无 Skill 轮次 | Stop 触发，无 stub → 立即退出，pending 不变 |
| --auto review | 3 条 pending → 全写入 dev.jsonl，标记 promoted |
| 交互 g | 写入 gt.jsonl |
| 多 Skill 同轮 | stub 2 条 → 生成 2 个独立 trace |

## 关键决策

1. **全局暂存 vs 按 skill 分存** → 全局 `~/.claude/skill-traces/`，与具体 skill 解耦，所有 skill 共享一个录制管道
2. **PostToolUse + Stop 双 hook vs 仅 Stop** → 双 hook：PostToolUse 直接从 payload 获取 skill 名，比 JSONL 解析更可靠
3. **expected_output 自动提取 vs 手动** → 自动从 transcript JSONL 提取，review 时只需 y/n，最大化自动化
4. **录制与评估解耦** → 录制层不改动 skill-evolver 迭代循环，二者独立，避免引入耦合风险
5. **降级策略** → 任何解析失败写 partial，不丢失录制机会，review 时手动补全

## 未知项

- **transcript JSONL 精确格式**：Claude Code 内部格式无公开文档，Stop hook 的 payload 字段需实测确认（特别是 `transcript_path` 是否存在）。负责人：实施后首次 hook 触发时记录实际 payload，据此调整解析逻辑。
- **PostToolUse payload 的 session_id 字段名**：需实测确认与 Stop hook 的 session_id 是否一致。
