---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions
---

# Code Review Reception

**Core Principle**: Verify before implementing. Technical correctness over social comfort.

## Response Pattern
1. **READ**: Complete feedback.
2. **VERIFY**: Check against codebase reality.
3. **EVALUATE**: Technically sound?
4. **RESPOND**: Technical acknowledgment or reasoned pushback.
5. **IMPLEMENT**: One item at a time, test each.

## Forbidden Responses
- ❌ "You're absolutely right!" (Performative agreement)
- ❌ "Great point!" / "Thanks!" (Gratitude fillers)
- ✅ "Fixed." / "Good catch. Fixed in [location]." / [Just fix it]

## Handling Feedback
- **Unclear?** STOP. Ask for clarification first.
- **Incorrect?** Push back with technical reasoning.
- **YAGNI?** If feature is unused, suggest removal instead of "fixing".

> For detailed examples and anti-patterns, see `.claude/docs/references/skills/receiving_code_review_full.md`
