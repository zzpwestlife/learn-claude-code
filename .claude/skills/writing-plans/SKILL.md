---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

**Goal**: Comprehensive implementation plan assuming zero context.

## Structure & Creation
1. **Analyze & Create (AUTO-START)**:
   - Read the design document.
   - **IMMEDIATELY** generate the BDD plan file `docs/plans/YYYY-MM-DD-<feature-name>.md`.
   - **AND** generate the State Tracking File `docs/plans/YYYY-MM-DD-<feature-name>-state.local.md` (Refer to `.claude/docs/guides/agent_bdd_loop.md` for format).
   - **Do NOT wait** or ask for confirmation to write the plan (loading this skill IS confirmation).
   - Only use `AskUserQuestion` if the design is critically missing or unintelligible.

## Plan Document Header
Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure (Red-Green Loop)

Bite-sized (2-5 mins) tracked in the `.local.md` file.

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: [Red] Write the failing test**
```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Verify failure**
Run: `pytest tests/path/test.py::test_name -v`

- [ ] **Step 3: [Green] Minimal implementation**
```python
def function(input):
    return expected
```

- [ ] **Step 4: Verify pass**
Run: `pytest tests/path/test.py::test_name -v`

- [ ] **Step 5: Commit**
```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders & Self-Review

Every step must contain the actual content an engineer needs. These are **plan failures**:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- Steps that describe what to do without showing how (code blocks required for code steps)

**Self-Review:**
After writing the complete plan, look at the spec with fresh eyes and check the plan against it.
Fix any missing coverage, placeholders, or type inconsistencies inline.

## Transition Gate (CRITICAL TOOL CALL REQUIRED)

**STOP**: Do NOT auto-execute the plan. Do NOT just print "Plan created".
You **MUST ACTUALLY EXECUTE** the `AskUserQuestion` tool before ending your turn.
- Set `question`: "Implementation plan and BDD State file created. What's next?"
- Set `options`:
  1. `label`: "Execute Plan", `description`: "Proceed to execution (Invoke executing-plans or subagent-driven-development)"
  2. `label`: "Review Plan", `description`: "I want to review/annotate the plan file"
  3. `label`: "Refine Plan", `description`: "Let's discuss changes"

## Rules
- **TUI First**: NEVER start execution without explicit user approval via `AskUserQuestion`.
