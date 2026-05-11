#!/usr/bin/env python3
# INPUT: /tmp/doc_diff.txt, /tmp/code_candidates.json
# OUTPUT: stdout — change count, up to 3 before/after examples, code candidates

import json

lines = open('/tmp/doc_diff.txt').readlines()
changed = [l for l in lines if l.startswith('-') and not l.startswith('---')]
examples = []
for i, l in enumerate(lines):
    if (l.startswith('-') and not l.startswith('---')
            and i + 1 < len(lines) and lines[i + 1].startswith('+')):
        examples.append((l.strip()[1:], lines[i + 1].strip()[1:]))
    if len(examples) >= 3:
        break

print(f'变更行数: {len(changed)}')
for old, new in examples:
    print(f'  BEFORE: {old}')
    print(f'  AFTER:  {new}')

candidates = json.load(open('/tmp/code_candidates.json'))
for x in candidates:
    print(f'代码候选: [{x["lang"]}] 行 {x["start"]}-{x["end"]}: {x["preview"]}')
