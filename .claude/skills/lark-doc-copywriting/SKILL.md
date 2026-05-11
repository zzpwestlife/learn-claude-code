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
d=json.load(sys.stdin)
open('/tmp/doc_original.md','w').write(d['data']['markdown'])
print('Fetched', len(d['data']['markdown']), 'chars')
"
```

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

### Step 5: 用户确认后 — 逐段写回

以 `<image token=` 行为天然分隔符将文档切成若干段，每段独立调用 `replace_range`。
使用 Python subprocess 传参（**不走 shell**，避免引号转义问题）。

```python
import subprocess, json, re

def split_by_image(text):
    """按 <image token= 行分割，image 行随前段。"""
    lines = text.split('\n')
    segments = []
    current = []
    for line in lines:
        if line.strip().startswith('<image ') and current:
            current.append(line)
            segments.append('\n'.join(current))
            current = []
        else:
            current.append(line)
    if current:
        segments.append('\n'.join(current))
    return segments

original = open('/tmp/doc_original.md', encoding='utf-8').read()
fixed    = open('/tmp/doc_fixed.md',    encoding='utf-8').read()

orig_segs  = split_by_image(original)
fixed_segs = split_by_image(fixed)

doc_id = open('/tmp/lark_doc_id.txt').read().strip()  # written by Step 1
success, fail = 0, 0

for i, (orig_seg, fixed_seg) in enumerate(zip(orig_segs, fixed_segs)):
    if orig_seg == fixed_seg:
        continue  # 无变更，跳过

    # 取段落内非 image 行作为选区
    orig_lines = [l for l in orig_seg.strip().split('\n')
                  if l.strip() and not l.strip().startswith('<image ')]
    if not orig_lines:
        continue
    first_line = orig_lines[0][:50].strip()
    last_line  = orig_lines[-1][-50:].strip() if len(orig_lines) > 1 else ''
    selection  = f"{first_line}...{last_line}" if last_line and first_line != last_line else first_line

    # 用 \n\n 分隔段落（单 \n 在 lark-doc 中只是软换行）
    fixed_lines = [l for l in fixed_seg.split('\n') if l.strip()]
    markdown = '\n\n'.join(fixed_lines)

    result = subprocess.run(
        ['lark-cli', 'docs', '+update',
         '--doc', doc_id,
         '--mode', 'replace_range',
         '--selection-with-ellipsis', selection,
         '--markdown', markdown],
        capture_output=True, text=True
    )
    resp = json.loads(result.stdout) if result.stdout.strip().startswith('{') else {}
    if resp.get('data', {}).get('success'):
        success += 1
    else:
        fail += 1
        print(f"Segment {i} FAILED: {result.stdout[:200]}")

print(f"\n完成: {success} 段成功, {fail} 段失败")
```

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
- **replace_range 失败**：报告具体段落索引和错误信息，其余段落继续执行
- **doc_id 解析失败**：要求用户提供文档 token 或重新粘贴 URL
- **lark-cli 未登录 / token 过期**：提示用户运行 `lark-cli auth` 重新认证，然后重试
- **文档无编辑权限（只读）**：告知用户当前账号对该文档只有查看权限，无法写入，退出
