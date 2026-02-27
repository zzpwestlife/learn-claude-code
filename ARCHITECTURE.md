# Project Architecture

This document describes the high-level architecture of `learn-claude-code`.

## Overview
`learn-claude-code` is a comprehensive resource for mastering Claude Code, featuring a structured curriculum, practical examples, and an integrated development environment configuration.

## Core Modules

| Directory | Purpose | Key Technologies |
| :--- | :--- | :--- |
| `.claude/` | **Agent Configuration**: Defines custom agents, skills, and project rules. | Markdown, JSON |
| `claude_plugins/` | **Extensions**: Custom MCP servers and language support. | Go, Shell |
| `docs/` | **Knowledge Base**: Guides, tutorials, and design documents. | Markdown, Mermaid |
| `scripts/` | **Automation**: Utility scripts for workflow automation and TUI interfaces. | Python, Bash |

## Data Flow
1.  **User Input**: Commands or queries via terminal.
2.  **Agent Processing**: Claude Code agents (configured in `.claude/`) interpret intent.
3.  **Execution**: Agents invoke tools or run scripts from `scripts/`.
4.  **Feedback**: Results are displayed via TUI (`scripts/tui_menu.py`) or standard output.

## Key Design Decisions
-   **Fractional Lazy Loading**: Context is split into directory-specific `CLAUDE.md` files to optimize token usage.
-   **Auto-Doc**: Documentation is recursively maintained via **File Inventory** tables inside `CLAUDE.md` and structured headers.
-   **Single Source of Truth**: Merged `INDEX.md` functionality into `CLAUDE.md` to streamline context loading.
-   **FlowState Workflow**: Strict adherence to atomic execution and TUI-based handoffs.
