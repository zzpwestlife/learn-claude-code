# Claude Code Memory Enhancement Tools

This document outlines the memory enhancement ecosystem for our Claude Code environment, detailing the roles, installation, and usage of key memory tools.

## Overview

Claude Code (v2.1.33+, Feb 2026) introduced native **Auto Memory** and **Agent Memory** capabilities. We combine these native features with specialized tools for a comprehensive memory system.

| Feature | **Native Auto Memory** (Built-in) | **Claudeception** (Installed) | **claude-mem** (Optional Plugin) |
| :--- | :--- | :--- | :--- |
| **Memory Type** | **Per-Project Learning** | **Procedural Memory** (Skills) | **Episodic Memory** (History) |
| **Focus** | "What is this project?" (Patterns, Arch) | "How to do X?" (Solutions, Fixes) | "What happened before?" (Logs, Timeline) |
| **Output** | `~/.claude/projects/<proj>/memory/` | Reusable Skill Files (`.claude/skills/`) | Searchable Session History (ChromaDB) |
| **Trigger** | Automatic background updates | Problem/Context Matching | Temporal/Semantic Search |
| **Sharing** | Private (local user) | **Shareable** (via Git) | Private (local user) |

---

## 1. Native Auto Memory (Built-in)

**Status**: ✅ Active (Default)

### Description
Claude Code automatically maintains a persistent memory directory for each project. It records project patterns, debugging insights, architecture notes, and user preferences as it works.

### Key Features
- **Zero Config**: Works out of the box.
- **Hierarchical Loading**: Loads the first 200 lines of `MEMORY.md` into context automatically.
- **On-Demand**: Loads detailed topic files (e.g., `debugging.md`) only when needed.
- **Scope**: Per-user, per-project (stored in `~/.claude/projects/`).

### Usage
- **Automatic**: Claude updates it as you work.
- **Manual**: Tell Claude "Remember that we use pnpm" or use `/memory` command to edit.

---

## 2. Claudeception (Procedural Memory)

**Status**: ✅ Installed & Active

### Description
Claudeception complements Native Memory by focusing on **extractable, shareable skills**. While Auto Memory remembers "this project uses React", Claudeception remembers "Here is the exact fix for that obscure React hydration error we solved".

### Why Keep It?
- **Portability**: Skills are saved in `.claude/skills/` and can be committed to Git to share with the team.
- **Specificity**: Creates structured "How-To" guides rather than general notes.
- **Cross-Project**: Skills can be reused across different projects if installed globally.

### Usage
- **Automatic**: Triggers via `UserPromptSubmit` hook on complex tasks.
- **Manual**: Run `/claudeception`.

---

## 3. claude-mem (Episodic Memory)

**Status**: 📝 Optional / Advanced

### Description
`claude-mem` provides **deep episodic history**. While Native Auto Memory summarizes "current state", `claude-mem` remembers the *timeline* of events (what we tried 3 days ago that failed).

### When to Use
- You need to search exact quotes or decisions from past sessions.
- You want a "Time Machine" for your development process.
- Native Auto Memory feels too "summarized" for your needs.

### Installation
```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

---

## Summary: The "Brain" Architecture

1.  **Short-Term Context**: Current Session
2.  **Working Memory (Native)**: `Auto Memory` (Project patterns & status)
3.  **Skill Library (Claudeception)**: Reusable solutions & workflows (Shareable)
4.  **Long-Term Archive (claude-mem)**: Detailed history & logs (Optional)
