# Token Optimization & Context Management Whitepaper

**Version**: 1.2 (2026-02-27)  
**Status**: Implemented  
**Impact**: Active Token Reduction ~80.0%

## 1. Executive Summary
This document outlines the systematic approach used to optimize the `.claude/` configuration directory. By implementing a "Hot/Cold Data Separation" strategy, we reduced the active context load from ~79k tokens to ~15.6k tokens while maintaining 100% functional integrity through explicit referencing.

## 2. Core Philosophy: JIT (Just-In-Time) Context
The central principle is **"Load what you need, when you need it."**
- **Active Context (Hot)**: Information the Agent MUST know to function safely (Rules, Workflow Steps, Checklists).
- **Reference Context (Cold)**: Information the Agent CAN look up if needed (Tutorials, Examples, Anti-patterns, Deep Dives).

## 3. Architecture Changes

### 3.1 Unified Core Rules
We consolidated fragmented rule files (`workflow-protocol.md`, `coding-standards.md`, `operational-standards.md`) into a single, high-density file:
- **File**: `.claude/rules/CORE_RULES.md`
- **Optimization**: Removed polite fillers, redundant explanations, and "why" narratives. Kept only actionable directives.

### 3.2 Constitution Refactoring
- **Active**: `.claude/constitution/constitution.md` (Condensed to ~80 lines). Contains only the 14 Articles and their sub-clauses.
- **Reference**: `.claude/constitution/constitution_full.md` (Full text). Backup for detailed interpretation.

### 3.3 Skill Refactoring (The "Trigger-Only" Pattern)
We applied a standardized template to high-cost skills (`tdd`, `debugging`, `subagent`, `git`, `review`, `dispatch`):

| Section | Location | Content |
| :--- | :--- | :--- |
| **Frontmatter** | `SKILL.md` | `name`, `description` (Trigger conditions ONLY) |
| **Body** | `SKILL.md` | Core Iron Laws, Checklists, Process Steps |
| **Deep Dive** | `docs/references/` | Tutorials, Examples, Diagrams, Anti-patterns |

**Example (TDD)**:
- `SKILL.md`: "NO PRODUCTION CODE WITHOUT FAILING TEST", Red-Green-Refactor steps.
- `tdd_full.md`: Detailed rationale, "Why order matters", "Common Rationalizations".

### 3.4 Phase 2 Optimizations (Secondary Skills)
We extended JIT optimization to secondary skills:
- `receiving-code-review`
- `dispatching-parallel-agents`
- `brainstorming`
- `using-git-worktrees`
- `review-code` (Command)

### 3.5 Phase 3 Optimizations (Source Isolation)
We isolated executable source code from the active context:
- **Action**: Moved `.py` and `.sh` scripts to `.claude/lib/`.
- **Impact**: Agent knows *how* to call scripts (via arguments) but doesn't waste tokens reading their implementation details unless debugging them.
- **Affected**: `architect.py`, `changelog_agent.py`, `check-complete.sh`, `statusline.sh`.

### 3.6 Phase 4 Optimizations (Agent Definitions)
We refined the Agent definitions themselves:
- **Files**: `code-reviewer.md`, `changelog-generator.md`.
- **Optimization**: Reduced to "Role", "Goal", and "Workflow" bullets. Detailed instructions moved to `docs/references/agents/`.

## 4. Safety Mechanisms (Integrity Verification)

To ensure no functionality is lost, we implemented:

1.  **Explicit Linking**: Every condensed file contains a footer link to its full version.
    > `> For detailed tutorial, see .claude/docs/references/skills/tdd_full.md`
2.  **Context Efficiency Directive**: Added to `AGENTS.md` to instruct the Agent on the JIT strategy.
    > `Read-on-Demand: Do NOT read full skill/doc files unless executing that specific task.`
3.  **Automated Monitoring**: `token-analyzer.py` script distinguishes between Active and Reference tokens.
4.  **Hook Verification**: Verified that critical hooks (e.g., `PostToolUse` for plan checking) point to the correct new paths in `lib/`.

## 5. Token Analysis Tool

A custom Python script (`.claude/scripts/token-analyzer.py`) is provided to monitor context usage.

**Usage**:
```bash
python3 .claude/scripts/token-analyzer.py
```

**Output**:
- **ACTIVE CONTEXT**: Files loaded by default or high-frequency skills.
- **REFERENCE CONTEXT**: Files available for on-demand lookup.
- **SAVINGS**: Percentage of tokens moved from Active to Reference.

## 6. Maintenance Guidelines

When modifying or adding new skills/rules:

1.  **Check Size**: If a file exceeds 100 lines, ask "Is this all active rule?"
2.  **Split**: Move explanations/examples to `docs/references/`.
3.  **Link**: Add a link in the main file.
4.  **Verify**: Run the analyzer to ensure Active Context remains lean.

## 7. Conclusion
Optimization is not deletion; it is organization. By structuring information hierarchically, we enable the Agent to "think fast" (low latency/cost) while retaining the ability to "think deep" (access to full knowledge) when required.
