# Trace Recorder — 集成说明

自动录制 skill 调用，生成 skill-evolver dataset 候选 trace。

## 工作原理

两个 Claude Code hooks 协作完成一次录制：

1. **PostToolUse (Skill)** → `trace-recorder.js post-tool`
   - 捕获：skill 名称、args、session_id
   - 写入：`/tmp/skill-stub-<session_id>.json`

2. **Stop** → `trace-recorder.js stop`
   - 读取 stub 文件（无 stub 则立即退出）
   - 从 transcript JSONL 提取当轮 user input + assistant output
   - 写入：`~/.claude/skill-traces/pending.jsonl`
   - 清理 stub 文件

## Pending Trace 结构

```json
{
  "id": "auto-20260522-1748000000000",
  "skill": "observability-skills",
  "input": "帮我查 trace_id=xxx 的调用链",
  "expected_output": "找到 2 个 span...",
  "args": "帮我查 trace_id=xxx",
  "timestamp": "2026-05-22T10:45:00.000Z",
  "session_id": "...",
  "transcript_path": "/Users/admin/.claude/projects/...",
  "status": "pending"
}
```

`status` 可能值：
- `pending`：input + output 均提取成功，可直接 review
- `partial`：JSONL 解析失败，expected_output 为空，需手动补全
- `promoted`：已提升到 dataset
- `deleted`：已在 review 中删除

## Review CLI

```bash
# 交互模式（逐条确认）
node ~/.claude/skills/skill-evolver/scripts/trace-review.js

# 自动模式（全部 pending → dev，无需交互）
node ~/.claude/skills/skill-evolver/scripts/trace-review.js --auto

# 只看某个 skill
node ~/.claude/skills/skill-evolver/scripts/trace-review.js --skill observability-skills

# 自动提升为 gt（谨慎使用）
node ~/.claude/skills/skill-evolver/scripts/trace-review.js --auto --split gt
```

交互模式按键：
- `y` → 提升到 dev split
- `g` → 提升到 gt split
- `n` → 跳过（保留 pending）
- `d` → 删除
- `q` → 退出

## 写入路径

review 后 trace 写入对应 skill 的 dataset 目录：

```
~/.claude/skills/<skill-name>/dataset/
├── dev.jsonl          ← 追加一条 index 记录
├── gt.jsonl           ← 追加（若选 g）
└── traces/
    └── auto-<id>.json ← 完整 trace（含完整 expected_output）
```

## 常见问题

**Q: status=partial 怎么处理？**
在 review 时选 `y` 提升到 dev，然后手动编辑 `traces/<id>.json` 补充 expected_output，再更新对应 dev.jsonl 中的 expected 字段。

**Q: Stop hook 触发了，但 pending.jsonl 没有新增？**
该轮对话未调用 Skill tool（无 stub 文件），属于正常行为，Stop hook 直接退出。

**Q: transcript_path 解析失败？**
recorder 会 glob `~/.claude/projects/**/<session_id>.jsonl`，仍失败则写 partial。可查看 stderr：`claude --debug` 模式下 hook stderr 会显示。

**Q: 如何确认 hook 是否正常工作？**
调用任意 skill 后，检查：
```bash
ls /tmp/skill-stub-*.json     # 应在 Stop 前存在，Stop 后消失
cat ~/.claude/skill-traces/pending.jsonl | tail -5
```

## 注意事项

- 所有 hook 脚本均 exit 0，不会阻断对话
- expected_output 截断至 3000 字符；完整内容存于 `traces/<id>.json`
- 同一轮多次 Skill 调用：生成多条独立 trace
- pending.jsonl 为 append-only JSONL，review 后 status 字段原地更新
