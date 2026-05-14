#!/usr/bin/env python3
# INPUT: Lark doc URL (argv[1]), optional output path (argv[2])
# OUTPUT: formatted .md file saved locally (default: {doc_id}.md)

import sys, re, json, subprocess, os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lark_copywriting import fix_line


def parse_token(url):
    """Return (token, is_wiki) from a Lark URL."""
    m = re.search(r'/wiki/([A-Za-z0-9]+)', url)
    if m:
        return m.group(1), True
    m = re.search(r'/docx?/([A-Za-z0-9]+)', url)
    if m:
        return m.group(1), False
    raise ValueError(f"Cannot parse Lark URL — expected /wiki/ or /docx/ segment: {url}")


def resolve_wiki(wiki_token):
    """Convert wiki node token to underlying docx obj_token."""
    result = subprocess.run(
        ['lark-cli', 'wiki', 'spaces', 'get_node',
         '--params', json.dumps({'token': wiki_token})],
        capture_output=True, text=True,
    )
    try:
        return json.loads(result.stdout)['data']['node']['obj_token']
    except (json.JSONDecodeError, KeyError) as e:
        raise RuntimeError(f"Wiki token resolution failed: {e}\n{result.stdout[:300]}")


def fetch_markdown(doc_id):
    """Fetch raw markdown from Lark via lark-cli."""
    result = subprocess.run(
        ['lark-cli', 'docs', '+fetch', '--doc', doc_id],
        capture_output=True, text=True,
    )
    raw = result.stdout or result.stderr
    try:
        return json.loads(raw)['data']['markdown']
    except (json.JSONDecodeError, KeyError) as e:
        raise RuntimeError(f"Fetch failed: {e}\n{raw[:300]}")


def format_md(content):
    """Apply copywriting fixes (punctuation + spacing) from lark_copywriting."""
    in_code = False
    out = []
    for line in content.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith('```'):
            in_code = not in_code
            out.append(line)
        elif in_code or stripped.startswith('<image '):
            out.append(line)
        else:
            out.append(fix_line(line.rstrip('\n')) + '\n')
    return ''.join(out)


def main():
    if len(sys.argv) < 2:
        print("Usage: lark_to_md.py <lark-url> [output.md]", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    token, is_wiki = parse_token(url)

    if is_wiki:
        print(f"Resolving wiki token {token}...")
        doc_id = resolve_wiki(token)
    else:
        doc_id = token

    print(f"Fetching {doc_id}...")
    content = fetch_markdown(doc_id)
    formatted = format_md(content)

    out_path = sys.argv[2] if len(sys.argv) > 2 else f"{doc_id}.md"
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(formatted)

    print(f"Saved → {out_path}  ({len(formatted):,} chars)")


if __name__ == '__main__':
    main()
