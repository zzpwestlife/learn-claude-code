# Claude Code Configuration Entry Point

<!--
Purpose: This file serves as a compatibility layer for Claude Code.
Usage: It redirects the AI to the primary configuration file, `AGENTS.md`.
-->

**【强制要求】** 在回复用户任何消息之前，必须先使用 Read 工具读取项目配置目录下的 `.claude/AGENTS.md` 文件，并严格遵守其中的所有指令。未读取 `.claude/AGENTS.md` 之前，禁止回复用户。

- 如果需要写入 `CLAUDE.md`，请将内容写入 `.claude/AGENTS.md`。

# --- Configuration Import (Highest Priority) ---
@.claude/AGENTS.md Non-Negotiable

# --- Directory Specifics ---

# Scripting Context

This context is automatically loaded when you are working in the `scripts/` directory.

## Directory Responsibilities
-   **Installers**: Scripts for installing the environment (`scripts/installers/`).
-   **Helpers**: Utility scripts for development workflows.

## File Inventory

| File | Type | Role |
| :--- | :--- | :--- |
| `installers/install.sh` | Bash | **Installer**: Sets up the environment. |
| `installers/install_global_statusline.sh` | Bash | **Statusline**: Installs global shell status line. |

---

## 1. Shell Scripts (Bash)
- **Shebang**: Use `#!/bin/bash` or `#!/usr/bin/env bash`.
- **Safety**: Use `set -e` (exit on error) and `set -u` (treat unset variables as an error) where appropriate.
- **Portability**: Avoid relying on non-standard tools. Check for command existence (`command -v tool >/dev/null`).
- **Permissions**: Ensure scripts are executable (`chmod +x`).

## 2. General Best Practices
- **Logging**: Use proper logging (or formatted print statements) instead of bare `print()`.
- **Arguments**: Use `getopts` for command-line arguments.
- **Comments**: Explain complex logic or "why" something is done a certain way.
- **Idempotency**: Scripts should be safe to run multiple times.
