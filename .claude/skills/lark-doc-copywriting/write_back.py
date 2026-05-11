#!/usr/bin/env python3
# INPUT: /tmp/doc_original.md, /tmp/doc_fixed.md, /tmp/lark_doc_id.txt
# OUTPUT: stdout — per-segment success/fail summary; exits 0 even on partial failure

import subprocess, json, re

def split_by_image(text):
    lines = text.split('\n')
    segments, current = [], []
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

def write_segment(doc_id, selection, markdown):
    return subprocess.run(
        ['lark-cli', 'docs', '+update',
         '--doc', doc_id,
         '--mode', 'replace_range',
         '--selection-with-ellipsis', selection,
         '--markdown', markdown],
        capture_output=True, text=True
    )

original = open('/tmp/doc_original.md', encoding='utf-8').read()
fixed    = open('/tmp/doc_fixed.md',    encoding='utf-8').read()
doc_id   = open('/tmp/lark_doc_id.txt').read().strip()

orig_segs  = split_by_image(original)
fixed_segs = split_by_image(fixed)

success, fail = 0, 0
failed_items = []  # (i, selection, markdown)

for i, (orig_seg, fixed_seg) in enumerate(zip(orig_segs, fixed_segs)):
    if orig_seg == fixed_seg:
        continue

    orig_lines = [l for l in orig_seg.strip().split('\n')
                  if l.strip() and not l.strip().startswith('<image ')]
    if not orig_lines:
        continue
    first_line = orig_lines[0][:50].strip()
    last_line  = orig_lines[-1][-50:].strip() if len(orig_lines) > 1 else ''
    selection  = f"{first_line}...{last_line}" if last_line and first_line != last_line else first_line

    fixed_lines = [l.rstrip() for l in fixed_seg.split('\n')]
    while fixed_lines and not fixed_lines[0]: fixed_lines.pop(0)
    while fixed_lines and not fixed_lines[-1]: fixed_lines.pop()
    markdown = '\n\n'.join(fixed_lines)

    result = write_segment(doc_id, selection, markdown)
    resp = json.loads(result.stdout) if result.stdout.strip().startswith('{') else {}
    if resp.get('data', {}).get('success'):
        success += 1
    else:
        fail += 1
        failed_items.append((i, selection, markdown))
        print(f"Segment {i} FAILED: {result.stdout[:200]}")

print(f"\n完成: {success} 段成功, {fail} 段失败")

# Write failed_items to /tmp for retry loop
import json as _json
_json.dump(failed_items, open('/tmp/write_back_failed.json', 'w'), ensure_ascii=False)
