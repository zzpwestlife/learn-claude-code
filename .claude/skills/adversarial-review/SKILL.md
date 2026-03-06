---
name: "adversarial-review"
description: "Review code using adversarial agents (Skeptic, Architect, Minimalist). Use this skill when high reliability is required or to break confirmation bias."
---

# Adversarial Review Skill

This skill implements the "Adversarial Review" pattern. It spawns independent reviewer processes to challenge your code from specific perspectives.

## Usage

To run an adversarial review, execute the python script directly:

```bash
python3 .claude/skills/adversarial-review/scripts/adversarial_review.py <files...> -i "<intent>"
```

## Workflow

1.  **Analyze Scope**: The script automatically determines the scope (Small/Medium/Large) based on line count.
2.  **Spawn Reviewers**:
    *   **Skeptic**: Focuses on correctness, security, error handling.
    *   **Architect**: Focuses on system design, coupling.
    *   **Minimalist**: Focuses on simplicity, YAGNI.
3.  **Synthesize**: The script outputs a consolidated report.

## Output

The script prints the findings to stdout. You should read this output and decide which findings to Accept or Reject.

## Configuration

- **Lenses**: `.claude/skills/adversarial-review/references/reviewer-lenses.md`
- **Principles**: `.claude/skills/adversarial-review/references/principles.md`
