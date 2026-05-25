# Claude Code 的隐藏装备

> 从 "AI 帮我写代码" 到 "AI 帮我搭工作流"
> 时长：30 min · 听众：6-7 人，已用过 CC 但用法浅 · 目标：炫技 + 启发

---

## 节奏（30 min）

| 时间 | 段落 | 内容 |
|---|---|---|
| 00:00 - 05:00 | 破冰提问 | 4 问校准现场 + 收集需求 |
| 05:00 - 08:00 | 为什么是 CC | 不是 Cursor / Copilot，三个关键差异 |
| 08:00 - 16:00 | 四大装备速览 | Skills · Hooks · Subagents · CLI |
| 16:00 - 25:00 | 炸场 demo（录屏） | 并行 Subagent 改造 Code Review |
| 25:00 - 28:00 | 今天就能抄 | 4 条最小起点 + 启发问题 |
| 28:00 - 30:00 | Q&A | 兜底，预期会自然延展 |

---

## 段 1 · 破冰提问 · 先听再讲（5 min）

### 为什么开场不直接讲

"听众已用过 CC 但用法浅" 只是预设。先用 4 个问题校准现场，
顺带把每个人的痛点钉在白板上，后面 demo 可以精准回扣。

### 4 个问题（建议每问 1 min，最后 1 min 总结 + 衔接）

1. **举手题** · 用过哪些 AI 编程工具？
   - 选项：Copilot · Cursor / Windsurf · CC · ChatGPT 网页 · 都没用过
   - 目的：摸观众基线，决定后面装备段讲多深

2. **点名题**（请 1-2 人说）· 你平时怎么用 CC？
   - 引导：写代码 / 解释代码 / debug / 接业务 API / 跑自动化？
   - 目的：揭示 "用法浅" 的具体形态，后面引出 "其实它能做更多"

3. **举手题** · 自己写过 Skill / Hook / 自定义 slash 命令吗？写过什么？
   - 目的：大概率多数人没写过 → 完美引出今天 4 大装备

4. **白板题**（每人一句）· 你最希望 AI 多帮你做什么？
   - 把答案写白板上 → demo 后回扣 "这件事今天的方法能不能做到"
   - 目的：把听众从 "听讲" 切到 "我自己的需求"

### 衔接到下一段

> "听完大家说的，能看到一个共同点 —— 大家都在 '用 AI 做单点任务'。
> 但 CC 跟其他工具的核心差异，恰恰是它能做 '多步任务' 和 '团队复用'。
> 这就是今天想分享的隐藏装备。"

---

## 段 2 · 为什么是 Claude Code（3 min）

> 接住破冰段的答案：刚才大家说的 "怎么用 CC"，多数停在 "更聪明的补全"。
> 这一段说清楚 —— 它跟 Copilot / Cursor 不在一个赛道。

### 一句话定调

> 你不只是在用一个 AI 工具，你在编程一个 AI 同事。

### 对比四象限

| 工具 | 形态 | 可编程性 | 适合场景 |
|---|---|---|---|
| Copilot | IDE 补全 | 低 | 行级补全 |
| Cursor / Windsurf | IDE Agent | 中（界面驱动） | 单文件改造 |
| ChatGPT 网页 | 对话框 | 无 | 问答、写片段 |
| **Claude Code** | **CLI Agent** | **高（文件即配置）** | **跨文件、跨步骤、可团队复用的工作流** |

### 三个关键差异

1. **CLI-first 即可编程**
   Hook / Skill / settings.json 全是文件，可 git 追踪，团队共享。
   "Cursor 的设置在 GUI 里，CC 的设置在你的代码仓库里。"

2. **Agentic 不是 Completion**
   能自己规划、调工具、读输出再决定下一步。
   "Copilot 在补完一行，CC 在完成一个任务。"

3. **生态可组合**
   Skill + Hook + Subagent + CLI 是工程化的乐高。
   "别的工具是黑盒功能，CC 是你能改的开源工作流。"

---

## 段 3 · 四大隐藏装备（8 min · 每个 2 min）

每个装备固定 3 行：**是什么 / 一句话价值 / 30 秒最小起点**。

### 1. Skills · 把团队最佳实践打包成可触发的技能

- **是什么**：一个目录 + 一份 SKILL.md，写清触发条件和操作流程
- **价值**：团队的 "code review 流程 / PR 描述模板 / 调试 SOP" 沉淀为可复用资产
- **最小起点**：在 `.claude/skills/pr-desc/SKILL.md` 写 30 行，让 CC 看到 `git diff` 自动生成 PR 描述

### 2. Hooks · 工具调用前后自动跑你的脚本

- **是什么**：settings.json 里挂钩 PreToolUse / PostToolUse / Stop 事件
- **价值**：把 "每次都要记得做" 变成 "永远不会忘"
- **最小起点**：PreToolUse 拦 `rm -rf` 危险命令；PostToolUse 在改完 .go 后自动 `make lint`

### 3. Subagents · 并行派发独立任务，不污染主上下文

- **是什么**：主 agent 派发子任务给 subagent，子 agent 独立上下文，结果汇总回来
- **价值**：调研 / 审查 / 多目录探索这类 "可拆分任务" 直接并行
- **最小起点**：让一个 subagent 跑 `Explore` 找代码，主 agent 继续做别的事

### 4. CLI Tools · 别用 MCP，用现有 CLI 让 CC 直连真实世界

> 个人观点：**MCP 会被 CLI 替代**。MCP 要起 server、管生命周期、调协议；
> 主流场景一个 CLI（`gh` / `aws` / `jq` / `kubectl` / `lark-cli`）就够了，CC Bash 直接调，更稳更可调试。

- **是什么**：把团队已有的 CLI 工具加入 settings 的 allow list
- **价值**：CC 立刻能查 PR、查 K8s、查内部 wiki，零协议成本
- **最小起点**：`"Bash(gh pr view *)"` 加进 permissions，让 CC 用 `gh pr view --json` 查 PR

---

## 段 4 · 炸场 demo（9 min，录屏播放）

### 主题：并行 Subagent 改造 GitLab MR Code Review

**为什么选这个**：视觉冲击强（多 agent 同跑），一举覆盖 Skill + Subagent + CLI 三件装备（用 `glab` 不用 GitLab MCP，正好回扣段 3 装备 4），9 min 可讲完。

### 一句话场景

> 粘贴 MR URL → Skill 按 description 自动触发 → `glab mr diff` 拿 diff → 同时派 3 个 subagent（安全/性能/可读性）→ 主 agent 汇总 → 结构化 review 报告。

### 数据流

```
用户: review 这个 MR <URL>
   ▼  [主 Agent] 按 description 自动触发 review-mr skill (无 slash)
   ▼  glab mr diff <URL> → 拿到 diff，拆三个独立任务
        ├─► [Subagent 1: 安全]   ──┐
        ├─► [Subagent 2: 性能]   ──┤  并行 · 各自独立上下文
        └─► [Subagent 3: 可读性] ──┘
   ▼  [主 Agent 汇总] → Markdown 表格 → glab mr note 一键回贴 MR
```

### 录屏播放节奏（9 min）

| 时间 | 录屏画面 | 口播要点 |
|---|---|---|
| 0:00 - 0:45 | Skill 文件内容 | "MR review 写成 Skill，关键就是派三个 subagent" |
| 0:45 - 1:30 | 粘贴 MR URL → glab 拿 diff | "URL 自动触发，glab CLI 拿 diff，没用 MCP" |
| 1:30 - 4:30 | 三个 subagent 并行运行 | "三个独立上下文，互不干扰，避免提示词污染" |
| 4:30 - 6:00 | 汇总输出表格 | "结构化报告，每行能直接进 MR 评论" |
| 6:00 - 7:00 | `glab mr note` 回贴 MR | "从 URL 到评论，全在一个会话里完成" |
| 7:00 - 9:00 | 现场口播（无录屏） | 对比传统 review + 回扣段 3 装备 4 |

> demo 详细脚本见 `docs/talks/demo-parallel-review-script.md`

---

## 段 5 · 今天就能抄（3 min）+ 回扣破冰白板

### 加分项 · 反向引导（1 min，可选口播）

> 仓库已内置 Grill-Me；再加一句 Prompt 可减少「列完问题 AI 自己猜答案就写代码」的翻车。

**魔法句**（复制到需求或设计前）：

```text
在开始之前，先列出你需要了解的所有问题。
列完问题之后停下来，等我回答，不要自己假设答案。
```

- 问答结束后生成 **需求确认书**（模板在 `docs/plans/_templates/requirements-ack.md`）
- 详解：`docs/guides/reverse-prompting.md` · 分析：`docs/research/2026-05-25-wechat-reverse-prompting.md`

### 清单（投影一页，让大家拍照）

```
□ 把组里那个 "反复要做的检查" 写成 Skill（< 50 行）
□ 在 .claude/settings.json 加一个 PreToolUse Hook 拦危险命令
□ 下次做 review / 调研，试试 Subagent 并行
□ 把常用 CLI（gh / kubectl / 内部 cli）加进 allow list
□ 复杂需求前用「反向引导」魔法句 + 需求确认书再开写
```

### 回扣破冰白板（关键动作）

逐条念破冰段第 4 问收集的 "希望 AI 做什么"，每条用一句话点评：
- 哪些今天的装备能直接做？（Skill / Hook / Subagent / CLI 对号入座）
- 哪些需要组合 2-3 件装备？
- 哪些目前还做不到？（诚实承认边界）

> 这一步是把分享从 "我讲你听" 变成 "你提的需求被认真回应"，决定他们回去会不会真的动手。

### 启发问题（引导 Q&A）

1. 我们组哪个重复劳动最适合做成 Skill？
2. CI 之外，还有哪些 "人肉检查" 值得 Hook 自动化？
3. 哪些 "调研类任务" 可以拆给 Subagent 并行？

### 收尾金句

> "工具的天花板不在工具，在你愿意把多少团队智慧灌进去。"

---

## 附录 · 分享前自检

- [ ] 录屏跑通，时长在 9 min 内
- [ ] 投影分辨率确认，字号够大（命令行至少 16pt）
- [ ] 准备一个尖锐问题的 30 秒回答（"这玩意比 Cursor 强在哪？"）
- [ ] 备好 `docs/talks/` 这两份 markdown 链接，分享后发群里
- [ ] 可选：附带 `docs/guides/reverse-prompting.md` 与 `docs/research/2026-05-25-wechat-reverse-prompting.md`
- [ ] **白板/记事本就位**，能记下破冰第 4 问的答案，最后回扣用
- [ ] 提前想好一个 "兜底答案"：如果破冰第 4 问大家都说不出，自己抛 1-2 个例子带节奏
