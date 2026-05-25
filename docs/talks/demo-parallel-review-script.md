# Demo 脚本 · 并行 Subagent 改造 GitLab MR Code Review

> 本地录制 + 播放预案
> 目标时长：9 min（录屏 7 min + 现场口播 2 min）
> 触发方式：粘贴 MR URL，无 slash 命令，Skill 按 description 自动路由

---

## 一、本地录制准备（按顺序一次跑通）

### 1.1 安装 + 认证 glab CLI

```bash
brew install glab && glab --version          # 其他平台见官方 install 文档
```

**自托管 GitLab 必看**：glab ≥ 1.99 默认走 OAuth，自托管站会报 `Set 'client_id' first`。绕开：用 PAT。

1. 去 `https://gitlab.<company>.com/-/user_settings/personal_access_tokens` 生成
   PAT，scope 勾选 `read_api` + `read_repository`（要让 CC 发评论再加 `api`）
2. 用 token 登录（stdin 喂入，PAT 不进命令行/history）：
   ```bash
   read -rs PAT && echo "$PAT" | glab auth login --hostname gitlab.<company>.com --stdin && unset PAT
   ```
   或交互式 `glab auth login --hostname gitlab.<company>.com` 提示时选 Token

公开 gitlab.com 直接 `glab auth login`。验证：

```bash
glab auth status   # 期望 ✓ Logged in to gitlab.<host> as <user>
```

### 1.3 选一个适合录制的 MR

**MR 标准**：1-3 文件 · < 200 行 diff · 含真实可 review 问题 · 内容可外发（含敏感信息要换或脱敏）

**两条路径**：
- **A. 自造 demo MR**（推荐内网分享）：开 demo 仓库，提一个故意埋问题的 MR，参考附录 A
- **B. 借用公开 MR**（录制后公开发布）：在 gitlab.com 找小型开源项目活跃 MR

测试：`glab mr view <URL>` 看到元信息；`glab mr diff <URL> | head` 看到 diff 头

### 1.4 安装 review-mr Skill

```bash
mkdir -p ~/.claude/skills/review-mr
cp docs/talks/example-skill-review-mr/SKILL.md ~/.claude/skills/review-mr/
```

或装到项目级 `.claude/skills/review-mr/`，二选一。

### 1.5 安装 Hook：review 发完自动打开 MR

这一步让四大装备凑齐（Skills + Subagents + CLI + **Hooks**）。

**复制 hook 脚本**

```bash
mkdir -p ~/.claude/hooks
cp docs/talks/example-skill-review-mr/open-mr-after-note.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/open-mr-after-note.sh
```

**在 `~/.claude/settings.json` 加 PostToolUse 配置**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/open-mr-after-note.sh" }]
      }
    ]
  }
}
```

效果：`glab mr note <URL> --message "..."` 成功后，Hook 自动解析 URL，调 `open <URL>`——MR 页面自己跳出来，零点击。

### 1.6 给 CC 放行 glab 命令

避免录屏中途弹 permission 弹窗打断节奏，提前在 `~/.claude/settings.json` 加：

```json
{
  "permissions": {
    "allow": ["Bash(glab mr diff:*)", "Bash(glab mr view:*)", "Bash(glab auth status)", "Bash(glab mr note:*)"]
  }
}
```

### 1.7 录屏前烟雾测试（**必做**）

不录屏，先在 CC 里把整条链路完整跑一遍：

```
请帮我 review 这个 MR：<你的 MR URL>
```

逐项确认：
- [ ] CC 自动识别 review-mr skill（看 system 日志或主动确认 "Loading skill: review-mr"）
- [ ] `glab mr diff` 成功返回 diff
- [ ] **3 个 subagent 在同一条消息里并行启动**（这是最强卖点，必须可视化）
- [ ] 输出是结构化表格，含 file/lens/line/issue/suggestion 5 列
- [ ] 总耗时在 3-5 min 之间（太短没层次感，太长录屏要剪）

逐项确认（新增 Hook 验证项）：
- [ ] `glab mr note` 执行后浏览器**自动打开 MR 页面**（Hook 生效）

任何一步不通就修，**录屏前一定要跑通**。

### 1.8 录屏工具配置

录制：`Cmd+Shift+5` / Kap / CleanShot · 1920×1080 录、1280×720 导
终端：iTerm2 ≥ 18pt + 浅色主题 · 隐藏桌面通知和 Dock 红点

---

## 二、录屏脚本（逐步，目标 7 min 内）

### Step 1 · 展示 Skill 文件（0:00 - 0:45）

**命令**：
```bash
bat ~/.claude/skills/review-mr/SKILL.md   # 或 cat
```

**口播**：
> "我把 MR review 流程写成了一个 Skill，关键就这句 —— 拿到 diff 后派三个 subagent 并行跑。注意没有 slash 命令，CC 看 description 自动触发。"

### Step 2 · 启动 CC + 粘贴 MR URL（0:45 - 1:30）

```bash
claude
```

粘贴：
```
请帮我 review 这个 MR：<MR_URL>
```

**预期画面**：
1. CC 显示 "Loading skill: review-mr"
2. 调用 `glab mr view` 显示 MR 标题/作者
3. 调用 `glab mr diff` 拿到 diff

**口播**：
> "看，CC 自己认出了 URL，去查 MR 元信息和 diff —— 这一步用 glab CLI，不是 MCP。下一秒它要派 subagent 了。"

### Step 3 · 三个 Subagent 并行运行（1:30 - 4:30）

**预期画面**：CC 在**一条消息**里发出 3 个 Agent 工具调用，UI 显示 3 条任务并行 spinner。

**口播（重点）**：
> "三个 subagent，三个独立上下文。安全的不知道性能在看什么，性能的不知道可读性在看什么 —— 互不干扰，避免提示词污染。如果是串行做，每个 subagent 都要重新读一遍 diff，token 翻三倍。"

**录制翻车应对**：
- 没并行（变成串行）→ 检查 SKILL.md 里 "single message" 那句，重录
- 全部跑完超过 4 min → 录屏剪掉中间等待，加 "（中间省略）" 字幕
- 某 subagent 没找到问题 → 强调 "AI review 不是替代人，是把第一遍人肉劳动省掉"

### Step 4 · 汇总输出（4:30 - 6:00）

**预期画面**：CC 输出结构化表格（见 SKILL.md 第 4 步示例）。

**口播**：
> "这就是结果 —— 不是一坨自由文本，是结构化表格。每一行都能直接进 MR 评论。"

### Step 5 · 后续动作演示（6:00 - 7:00）

让 CC 跑这条（不录全程，演示一下即可）：
```
把这份报告发到 MR 评论里
```

**口播**：
> "拿到 review 不是终点，CC 可以直接 `glab mr note` 把它贴回 MR。整个 review 流程，从 URL 到评论，全在一个会话里完成。"

---

## 三、现场口播段（7:00 - 9:00，无录屏）

| 时间 | 内容 |
|---|---|
| 7:00 - 8:00 | 对比传统 review：一个人盯 30 min vs 5 min 拿到结构化第一版 |
| 8:00 - 8:30 | 强调：AI 不取代 review，把它从体力活变成判断活 |
| 8:30 - 9:00 | 回扣段 2 装备 4：这里没用 GitLab MCP，就是 glab CLI + Bash —— "MCP 会被 CLI 替代" 的活样本 |

---

## 四、播放翻车预案（现场）

| 故障 | 处置 |
|---|---|
| 投影没声 | 录屏本来就是无声口播版，不影响 |
| 视频卡顿 | 提前拷本地，不靠在线播放 |
| 视频打不开 | 备份 GIF 版（关键 3 步截 GIF） |
| 投影黑屏 | 跳到 "今天就能抄" 清单，提前进 Q&A |
| 有人质疑 "录的吧" | 现场 `claude` 起来跑 Step 2，让他看一眼真在并行 |

---

## 五、录屏成品验收清单

- [ ] 总时长 ≤ 7 min（含口播 9 min）
- [ ] 字号在投影上能看清（手机离屏幕 3 米拍照测试）
- [ ] 三个 subagent 并行的画面清晰可见（**最强卖点**）
- [ ] 输出表格完整 5 列；MR URL 中如有公司域名确认可外发
- [ ] 720p / 1080p 各一份；本地 + U 盘 + 云盘三处备份

---

## 附录 A · demo MR 故意埋坑代码（路径 A 用）

三个文件，每个对应一个 lens，diff < 30 行，subagent 命中率 100%：

```go
// auth.go（安全）：SQL 注入 + 明文密码 + 吞错误
q := "SELECT id FROM users WHERE name='" + user + "' AND pass='" + pass + "'"
rows, _ := db.Query(q)

// cache.go（性能）：for 循环单条查询，N+1
for _, id := range ids { out = append(out, fetchOne(id)) }

// util.go（可读性）：函数名烂 + 4 层嵌套
func D(x, y int) int {
    if x > 0 { if y > 0 { if x > y { return x-y } else { return y-x } } else { return x } }
    return 0
}
```
