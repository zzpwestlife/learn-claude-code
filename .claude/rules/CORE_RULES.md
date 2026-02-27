# CORE RULES & PROTOCOLS (Unified V1.0)

## 1. Engineering Principles (Simplicity & Quality)
- **Simplicity First (YAGNI)**: Implement ONLY requested features; NO speculative abstractions. 
- **Atomic Execution**: Perform ONE task phase per turn. Stop and handoff after completion.
- **Evidence-Based**: Use logs, tests, and diffs for verification. NO "Happy Path" assumptions.
- **Zero-Friction**: Prefer TUI menus (`AskUserQuestion` with `options`) over open-ended text.
- **Root Cause Fixing**: Resolve the source of issues, not just symptoms. Zero hand-holding.
- **Plan-First**: Mandatory plan in `docs/plans/` for tasks >3 steps. STOP on deviation.

## 2. Coding Standards
- **Surgical Changes**: Touch ONLY necessary files. Clean up only your own mess.
- **Strict Typing**: NO `any` type or `eslint-disable`. Use explicit types.
- **Clean Code**: Delete unused code immediately; NO commented-out obsolete code.
- **File Limits**: Single file < 200 lines; functions < 20 lines. Hard wrap at 120 chars.
- **Metadata**: Source files MUST start with 3 header lines: INPUT, OUTPUT, POS.
- **Self-Documenting**: Naming explains "What"; comments explain "Why".

## 3. Workflow Protocol (Handoff & TUI)
- **Universal Handoff**: After EVERY phase (Plan, Exec, Review), display a TUI menu via `AskUserQuestion`.
- **Zero Friction Navigation**: Use `RunCommand(requires_approval=false)` for standard next-steps.
- **Mandatory Pauses**: Respond to "🛑 STOP EXECUTION NOW 🛑" signals immediately.
- **Bilingual Options**: Provide bilingual (EN/CN) labels in `AskUserQuestion` options.
- **Mode Selection**: Diff Mode for incremental changes; Full Path for deep refactoring.

## 4. Operational & Git
- **Conventional Commits**: `type(scope): subject`.
- **Explicit Staging**: NO `git add .`; stage files explicitly after `git status`.
- **SubAgent Strategy**: Delegate exploration, research, and parallel tasks to subagents.
- **Concise Comms**: Redirect long logs to `.claude/tmp/logs.md`. No polite fillers.
- **Cross-Platform**: Support both macOS (BSD) and Linux (GNU) in all scripts.
