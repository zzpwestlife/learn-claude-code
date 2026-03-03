---
description: Search for relevant skills based on keywords or intent.
argument-hint: [keywords]
allowed-tools:
  - Read
---

!python3 .claude/lib/python/find_skills.py "$@"

# Instruction
If skills are found:
1.  Read the `SKILL.md` of the top 1 recommended skill to understand its details.
2.  Summarize how this skill helps the user's request.
3.  Ask if they want to invoke it now.
