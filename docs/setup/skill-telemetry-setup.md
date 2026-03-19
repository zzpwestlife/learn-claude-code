# Claude Code Session Evaluator - Setup Guide

## 一键迁移到新电脑/项目

只需要一条命令，把脚本拷贝过去即可。

### 方式 A：拷贝脚本（推荐）

```bash
# 在新电脑/项目目录下运行
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/learn-claude-code/main/.claude/scripts/session-eval.sh -o .claude/scripts/session-eval.sh && chmod +x .claude/scripts/session-eval.sh
```

### 方式 B：手动复制

把以下文件复制到目标电脑/项目：
- `.claude/scripts/session-eval.sh`

### 前置依赖

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

---

## 使用方法

### 在项目内运行（自动找当前项目会话）

```bash
# 导出最新会话
.claude/scripts/session-eval.sh

# 导出指定会话
.claude/scripts/session-eval.sh <session_id>

# 导出到指定目录
.claude/scripts/session-eval.sh latest /tmp/my_eval
```

### 跨项目全局扫描（不依赖项目目录）

```bash
# 列出所有会话
.claude/scripts/session-eval.sh --global list

# 导出全局最新会话
.claude/scripts/session-eval.sh --global latest

# 导出指定会话到指定目录
.claude/scripts/session-eval.sh --global 1eb2a445 /tmp/my_eval
```

---

## 输出文件（8个）

| 文件 | 内容 |
|------|------|
| `user_prompts.*` | User Prompt 列表 |
| `api_requests.*` | API 调用元数据（token、model、stop_reason）|
| `tool_decisions.*` | 工具调用决策（tool_use）|
| `tool_results.*` | 工具执行结果 |

格式：`*.jsonl`（原始数据）+ `*.csv`（可直接导入 Excel/BI）

---

## 典型工作流

```bash
# 1. 列出所有可用会话
.claude/scripts/session-eval.sh --global list

# 2. 导出指定会话
.claude/scripts/session-eval.sh --global 1eb2a445 /tmp/eval/20260319

# 3. 查看 CSV
cat /tmp/eval/20260319/api_requests.csv

# 4. 对比两个会话
# (未来可扩展 compare-sessions.sh)
```
