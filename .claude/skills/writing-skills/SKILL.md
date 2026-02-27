---
name: writing-skills
description: Use when creating or editing skills. Follows TDD (Red-Green-Refactor) for documentation.
---

# Writing Skills (Reference)

## Core Pattern: Skill TDD
1. **Red**: Run baseline scenario with subagent -> Watch it fail -> Document violations.
2. **Green**: Write minimal `SKILL.md` -> Verify subagent complies.
3. **Refactor**: Close loopholes in documentation -> Re-verify.

## SKILL.md Structure
- **Frontmatter**: `name` (hyphenated), `description` ("Use when..." triggers only).
- **Overview**: Core principle (1-2 sentences).
- **Triggers**: Symptoms and situations signaling use.
- **Core Pattern**: Before/after examples or key steps.
- **Implementation**: Inline code or links to scripts.

## Directory Layout
```
skills/skill-name/
  SKILL.md       # Main reference
  scripts/       # Python/Bash tools
  assets/        # Templates
```

## Critical Rules (CSO)
- **Description**: Triggering conditions ONLY. NO workflow summary (prevents skipping).
- **Format**: Third-person, injected into system prompt.
- **Background**: Move heavy references (>100 lines) to `.claude/docs/archive/`.
