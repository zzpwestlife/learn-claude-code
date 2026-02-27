---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

**Core Principle**: Dispatch one agent per independent problem domain.

## When to Use
- **Independent**: Failures are in different files/subsystems.
- **No Shared State**: Agents won't edit the same files.
- **Parallelizable**: Tasks don't depend on each other's output.

## The Pattern
1. **Identify Domains**: Group failures by subsystem/file.
2. **Create Tasks**: One agent per domain.
   - **Scope**: Specific file/test.
   - **Goal**: "Fix tests in X".
   - **Constraint**: "Do NOT touch Y".
3. **Dispatch**: Run concurrently.
4. **Integrate**: Review summaries -> Merge -> Run full suite.

## Anti-Patterns
- ❌ "Fix everything" (Too broad)
- ❌ Dispatching on related bugs (Race conditions between agents)
- ❌ Editing same file (Merge conflicts)

> For detailed decision tree and examples, see `.claude/docs/references/skills/dispatching_parallel_agents_full.md`
