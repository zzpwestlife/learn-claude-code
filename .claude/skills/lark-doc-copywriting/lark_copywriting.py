#!/usr/bin/env python3
# INPUT: /tmp/doc_original.md (fetched lark doc markdown)
# OUTPUT: /tmp/doc_fixed.md, /tmp/doc_diff.txt, /tmp/code_candidates.json

import re, sys, json, difflib

PUNCT_MAP = [
    ('\uff0c', ','), ('\u3002', '.'), ('\u3001', ','), ('\uff1a', ':'),
    ('\uff08', '('), ('\uff09', ')'),
    ('\u201c', '"'), ('\u201d', '"'),
    ('\uff1f', '?'), ('\uff1b', ';'), ('\uff01', '!'),
    ('\u2014\u2014', '--'), ('\u2014', '-'),
]

CODE_PATTERNS = {
    'sql':  re.compile(r'^(CREATE|SELECT|INSERT|UPDATE|DELETE|ALTER|DROP|--\s)', re.I),
    'json': re.compile(r'^\s*[{\[]'),
    'bash': re.compile(r'^(curl|npm|pip|git|docker|make|cd|ls|cat)\b'),
}

def fix_line(line):
    stripped = line.strip()
    if stripped.startswith('<image ') or stripped.startswith('```'):
        return line
    for src, dst in PUNCT_MAP:
        line = line.replace(src, dst)
    # 顺序关键: 先去标点前空格，再补标点后空格
    line = re.sub(r'\s+([,.:;!?])(?![-/])', r'\1', line)
    line = re.sub(r'(?<![0-9/\s]),(?=[^\s\n,])', ', ', line)
    line = re.sub(r'(?<![0-9/\s\.])\.(?=[\u4e00-\u9fffA-Z])', '. ', line)
    line = re.sub(r'[?!](?=[\u4e00-\u9fff\u0041-\u005A])', lambda m: m.group(0)+' ', line)
    line = re.sub(r':(?!//|[0-9])(?=[^\s\n])', ': ', line)
    line = re.sub(r'(?<=[^\s\-])--(?=[^\s\-])', ' -- ', line)
    line = re.sub(r'(?<!\n)  +', ' ', line)
    return line

def detect_code_candidates(lines):
    """Find bare-code blocks: starts with CODE_PATTERN, >= 3 lines, not inside fence."""
    candidates = []
    in_code = False
    i = 0
    while i < len(lines):
        stripped = lines[i].strip()
        if stripped.startswith('```'):
            in_code = not in_code
            i += 1
            continue
        if in_code:
            i += 1
            continue
        matched_lang = None
        for lang, pat in CODE_PATTERNS.items():
            if pat.match(stripped):
                matched_lang = lang
                break
        if matched_lang:
            block_start = i
            j = i + 1
            while j < len(lines):
                next_stripped = lines[j].strip()
                if not next_stripped or next_stripped.startswith('<image '):
                    break
                j += 1
            block_end = j - 1
            if block_end - block_start + 1 >= 3:
                candidates.append({
                    'start': block_start,
                    'end': block_end,
                    'lang': matched_lang,
                    'preview': lines[block_start][:80].strip()
                })
            i = j
        else:
            i += 1
    return candidates

def process(src_path):
    with open(src_path, encoding='utf-8') as f:
        original_lines = f.readlines()
    fixed_lines = []
    in_code = False
    for line in original_lines:
        stripped = line.strip()
        if stripped.startswith('```'):
            in_code = not in_code
            fixed_lines.append(line)
        elif in_code or stripped.startswith('<image '):
            fixed_lines.append(line)
        else:
            fixed_lines.append(fix_line(line.rstrip('\n')) + '\n')
    with open('/tmp/doc_fixed.md', 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    diff = list(difflib.unified_diff(
        original_lines, fixed_lines, fromfile='original', tofile='fixed', lineterm=''))
    with open('/tmp/doc_diff.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(diff))
    candidates = detect_code_candidates([l.rstrip('\n') for l in original_lines])
    with open('/tmp/code_candidates.json', 'w', encoding='utf-8') as f:
        json.dump(candidates, f, ensure_ascii=False, indent=2)
    changed = sum(1 for d in diff if d.startswith('-') and not d.startswith('---'))
    print(f"Changed: {changed} lines | Code candidates: {len(candidates)}")
    for c in candidates:
        print(f"  [{c['lang']}] lines {c['start']}-{c['end']}: {c['preview']}")

if __name__ == '__main__':
    src = sys.argv[1] if len(sys.argv) > 1 else '/tmp/doc_original.md'
    process(src)
