#!/usr/bin/env bash
# PostToolUse hook: open MR in browser after glab mr note posts a review comment
# Fires on every Bash call; exits silently if the command is not glab mr note.

input=$(cat)

cmd=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

[[ "$cmd" == glab\ mr\ note\ http* ]] || exit 0

url=$(echo "$cmd" | grep -oE 'https?://[^[:space:]]+' | head -1)
[[ "$url" =~ ^https?:// ]] && open "$url" &>/dev/null &
exit 0
