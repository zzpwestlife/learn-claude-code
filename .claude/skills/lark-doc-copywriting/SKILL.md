---
name: lark-doc-copywriting
version: "1.0.0"
description: "改造版中文文案排版：将飞书文档中的全角标点转为半角、修复空格规范、整理未包裹代码块。当用户说'帮我整理排版'/'标点半角化'/'中文排版修复'/'整理这篇文档的标点'/'代码块整理'时触发。"
metadata:
  requires:
    bins: ["lark-cli", "python3"]
  assets:
    - lark_copywriting.py   # Step 3: 主处理脚本
    - show_summary.py       # Step 4: 摘要展示脚本
    - write_back.py         # Step 5: 写回脚本
---

# lark-doc-copywriting

> **前置条件：** 先阅读 [`../lark-shared/SKILL.md`](../lark-shared/SKILL.md) 了解认证和安全规则。

改造版中文文案排版整理，针对飞书文档执行：
1. 全角标点 → 半角（PUNCT_MAP 映射）
2. 标点前后空格规范化
3. 未包裹代码段 → fenced code block

**不是**通用排版规范，不处理段落间距、列表格式等。

---

## 触发场景

**触发**：用户显式提出排版/标点/代码块整理需求：
- "帮我整理排版" / "整理这篇文档" / "标点半角化"
- "中文排版修复" / "代码块整理"

**不触发**：
- 用户仅读取、查看、搜索文档时
- 文档 URL 缺失或无法解析时（提示用户粘贴完整链接）
- 用户明确说"只看看"/"不用修改"

---

## 执行步骤

### Step 1: 解析文档 URL，获取 doc_id

根据 URL 类型选择对应路径：

**若 URL 含 `/wiki/`**（如 `https://xxx.feishu.cn/wiki/TOKEN`）：
```bash
lark-cli wiki spaces get_node --params '{"token":"WIKI_TOKEN"}'
# 从返回 JSON 的 node.obj_token 字段提取真实 doc_id
echo "OBJ_TOKEN" > /tmp/lark_doc_id.txt
```

**若 URL 含 `/docx/` 或 `/doc/`**（如 `https://xxx.feishu.cn/docx/DOC_ID`）：
```bash
# 直接从 URL 末段提取 DOC_ID
echo "DOC_ID" > /tmp/lark_doc_id.txt
```

> 若 URL 格式无法识别，提示用户"请粘贴完整飞书文档链接（含 /wiki/ 或 /docx/）"，退出。

### Step 2: 获取文档内容

```bash
lark-cli docs +fetch --doc "<doc_id>" 2>&1 | python3 -c "
import json,sys
raw=sys.stdin.read()
try:
    d=json.loads(raw)
    md=d['data']['markdown']
except (json.JSONDecodeError, KeyError) as e:
    print('FETCH_ERROR:', e, '|', raw[:200]); sys.exit(1)
open('/tmp/doc_original.md','w').write(md)
print('Fetched', len(md), 'chars')
"
```

> 若输出含 `FETCH_ERROR:`，提示用户"文档获取失败，请检查 doc_id 是否正确或文档是否可访问"，退出。

### Step 3: 复制并运行处理脚本

使用 Read 工具读取 `.claude/skills/lark-doc-copywriting/lark_copywriting.py`，
然后用 Write 工具写到 `/tmp/lark_copywriting.py`，再运行：

```bash
python3 /tmp/lark_copywriting.py /tmp/doc_original.md
```

脚本逻辑见 `lark_copywriting.py`（PUNCT_MAP 标点替换 + 空格规范 + 代码候选检测）。

### Step 4: 读取结果，展示摘要

使用 Read 工具读取 `.claude/skills/lark-doc-copywriting/show_summary.py`，
然后用 Write 工具写到 `/tmp/show_summary.py`，再运行：

```bash
python3 /tmp/show_summary.py
```

**如果 diff 为空且无候选**：告知用户"文档无需修改"，退出。

否则，向用户展示摘要，使用 `AskUserQuestion` 确认：

**无代码候选时**（或用户无需代码块整理）：
```
AskUserQuestion(
  question="检测到 N 处标点/空格需修正，是否写入文档？",
  options=[
    { label: "确认写入" },
    { label: "取消，不修改" }
  ]
)
```
选"确认写入"→ 进入 Step 5；选"取消"→ 退出。

**有代码候选时**，先打印候选列表，再询问：
```
AskUserQuestion(
  question="检测到 N 处标点/空格 + M 段代码候选，如何处理？",
  options=[
    { label: "写入标点修复，跳过代码候选" },
    { label: "写入标点修复，并逐段确认代码候选" },
    { label: "取消，不修改" }
  ]
)
```
选项1 → Step 5（不处理代码候选）；选项2 → Step 5（处理完后逐段询问包裹）；选项3 → 退出。

> **注意**：「代码候选」仅检测可能未包裹的代码段，不自动包裹 — 需用户逐一确认。

**逐段确认代码候选**（选项2 后执行）：
遍历 `/tmp/code_candidates.json` 每条候选，逐一询问：
```
AskUserQuestion(
  question="代码候选 {i}/{total} [{lang}] 行{start}-{end}: {preview}\n是否包裹？",
  options=[
    { label: "包裹为 {lang} 代码块" },
    { label: "跳过此块" },
    { label: "全部跳过" }
  ]
)
```
选"包裹" → 在 `/tmp/doc_fixed.md` 第 `start` 行前插入 ` ```{lang} `、第 `end+1` 行后插入 ` ``` `；
选"全部跳过" → 退出循环；完成后进入 Step 5。

### Step 5: 用户确认后 — 逐段写回

使用 Read 工具读取 `.claude/skills/lark-doc-copywriting/write_back.py`，
然后用 Write 工具写到 `/tmp/write_back.py`，再运行：

```bash
python3 /tmp/write_back.py
```

脚本读取 `/tmp/doc_original.md`、`/tmp/doc_fixed.md`、`/tmp/lark_doc_id.txt`，
按 `<image token=` 行分段，每段独立调用 `replace_range`（**不走 shell**，避免引号转义）。
失败段索引写入 `/tmp/write_back_failed.json`。

**若输出含 `fail > 0`** — 询问用户是否重试（最多 1 次）：

```
AskUserQuestion(
  question=f"有 {fail} 段写入失败，是否重试？",
  options=[
    { label: "重试失败段落" },
    { label: "跳过，保持现状" }
  ]
)
```

选"重试"时，读取 `/tmp/write_back_failed.json`，对每个 `[i, selection, markdown]` 再次调用相同的 `lark-cli docs +update` subprocess，汇报重试结果。

---

## 关键约束

| 约束 | 原因 |
|------|------|
| `\n\n` 分隔替换内容段落 | 单 `\n` 在 lark-doc 中是软换行，会合并段落 |
| `<image token>` 行原样保留 | image block 无法通过文本替换重建 |
| 已有 ` ``` ` 行跳过 | 已有代码块不重复包裹 |
| subprocess 传参，不走 shell | `@file` 只接受相对路径；复杂内容经 shell 引号易出错 |
| PUNCT_MAP 用 Unicode escape | shell 或文件写入时直接写弯引号可能编码丢失 |
| 先去标点前空格，再补标点后空格 | 顺序错误导致 `做 .下一步` 无法正确处理为 `做. 下一步` |
| 代码候选检测：以首行识别，展开整块 | SQL/bash 块只有首行匹配 pattern，续行是普通内容 |

---

## 错误处理

- **wiki token 解析失败**：提示"请检查 URL 格式，wiki 链接需要 `/wiki/TOKEN` 格式"
- **diff 为空 + 无候选**：告知"文档无需修改"，退出
- **replace_range 失败**：报告具体段落索引和错误信息，其余段落继续执行；所有段落处理完毕后，若 fail > 0，询问用户是否重试失败的段落（最多重试 1 次）
- **doc_id 解析失败**：要求用户提供文档 token 或重新粘贴 URL
- **lark-cli 未登录 / token 过期**：提示用户运行 `lark-cli auth` 重新认证，然后重试
- **文档无编辑权限（只读）**：告知用户当前账号对该文档只有查看权限，无法写入，退出

---

## Companion scripts — 输出格式参考

### `show_summary.py` 输出格式

```
变更行数: N
  BEFORE: 原始行内容
  AFTER:  修复后内容
代码候选: [lang] 行 start-end: 首行预览
```

- 若第一行为 `变更行数: 0` 且无 `代码候选:` 行 → 文档无需修改，退出
- BEFORE/AFTER 示例最多展示 3 对
- `代码候选:` 行每条候选各一行；无候选时无此行
