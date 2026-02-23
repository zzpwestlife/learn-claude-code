---
name: modern-tui
version: "1.0.0"
description: Provides a modern, rich Text User Interface for project workflow management.
user-invocable: true
allowed-tools:
  - RunCommand
---

# Modern TUI Skill

This skill provides a set of interactive TUI components for the FlowState workflow.
It uses `rich` and `questionary` to provide a better user experience than standard text output.

## Usage

You can invoke the TUI directly to check status:

```bash
# Check status of current task plan
/modern-tui status
```

## Internal Commands

The underlying script is located at `.claude/skills/modern-tui/scripts/tui.py`.
It requires a Python environment with `rich` and `questionary` installed.

### Commands

1.  **Status**: Show the current status of the task plan.
    `python tui.py status --file task_plan.md`

2.  **Optimize Handoff**: Show the menu after prompt optimization.
    `python tui.py optimize-handoff --dir {output_dir}`

3.  **Plan Handoff**: Show the menu after planning is complete.
    `python tui.py plan-handoff --file task_plan.md`

4.  **Execution Handoff**: Show the menu after a phase is complete.
    `python tui.py execution-handoff --phase {phase_num} --file task_plan.md`
