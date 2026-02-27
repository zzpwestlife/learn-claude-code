# Scripting Context

This context is automatically loaded when you are working in the `scripts/` directory or editing scripts.

## Directory Responsibilities
-   **TUI Management**: Providing interactive menus for project control.
-   **Automation**: Handling repetitive tasks like testing and formatting.
-   **Configuration**: Script-specific rules.

## File Inventory

| File | Type | Role | Dependencies |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Config | **Context Definition**: Defines coding standards for scripts. | None |
| `tui_menu.py` | Python | **User Interface**: Interactive menu for project commands. | `curses`, `subprocess` |

---

## 1. Python Scripts
- **Standard**: Follow **PEP 8** style guide.
- **Imports**: Organize imports (Standard Library -> Third Party -> Local).
- **Docstrings**: Use Google-style docstrings for functions and classes.
- **Type Hints**: Use type hints (`def func(a: int) -> str:`) where beneficial.
- **Main Guard**: Always use `if __name__ == "__main__":` block.
- **No Hardcoded Paths**: Use relative paths based on `__file__` or environment variables.

## 2. Shell Scripts (Bash)
- **Shebang**: Use `#!/bin/bash` or `#!/usr/bin/env bash`.
- **Safety**: Use `set -e` (exit on error) and `set -u` (treat unset variables as an error) where appropriate.
- **Portability**: Avoid relying on non-standard tools. Check for command existence (`command -v tool >/dev/null`).
- **Permissions**: Ensure scripts are executable (`chmod +x`).

## 3. General Best Practices
- **Logging**: Use proper logging (or formatted print statements) instead of bare `print()`.
- **Arguments**: Use `argparse` (Python) or `getopts` (Bash) for command-line arguments.
- **Comments**: Explain complex logic or "why" something is done a certain way.
- **Idempotency**: Scripts should be safe to run multiple times.
