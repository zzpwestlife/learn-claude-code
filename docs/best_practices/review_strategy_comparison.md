# Code Review Strategy Comparison: `/new` Session vs. SubAgent (Multi-Model)

When designing an AI-assisted code review workflow, two primary strategies exist to ensure objectivity and quality. This document compares them to help you choose the right tool for the job.

## 1. Strategy A: The "Fresh Eyes" Approach (`/new`)

**Mechanism**: The user manually types `/new` to clear the context window, then runs `/review-code` (often with a high-reasoning model like Opus).

| Feature | Description |
| :--- | :--- |
| **Context Isolation** | **Perfect (100%)**. The reviewer knows NOTHING about the "struggle" of writing the code. It only sees the final artifact. |
| **Bias Elimination** | **High**. It won't be swayed by previous justifications ("I did it this way because X failed"). |
| **Cost** | **Medium**. Requires re-reading the necessary files/diffs into context. |
| **UX Friction** | **High**. Requires manual user action (typing `/new`, then the command). Disrupts the flow. |

**Best For**: 
- **Final Pre-Merge Review**: The "Gatekeeper" check.
- **Complex Refactoring**: When you need to ensure the new architecture stands on its own.
- **Security Audits**: Where "assumption blindness" is dangerous.

## 2. Strategy B: The "Parallel Critic" Approach (SubAgent)

**Mechanism**: The main agent (Sonnet) dispatches a subagent (using Opus or o1) to review a specific chunk of code *within the same session*, but with a distinct system prompt.

| Feature | Description |
| :--- | :--- |
| **Context Isolation** | **Partial**. The subagent prompt can be crafted to ignore previous chat history, but it still lives within the parent's "world". |
| **Model Diversity** | **High**. You can explicitly dispatch `model: opus` or `model: o1` for the review task while the main agent stays on `sonnet`. |
| **Speed** | **Fast**. Can run in parallel with other tasks (e.g., writing tests). |
| **UX Friction** | **Zero**. It's just a tool call. The user doesn't need to switch sessions. |

**Best For**:
- **TDD Cycles (Red-Green-Refactor)**: Quick feedback loop.
- **Incremental Sanity Checks**: "Did I miss an edge case in this function?"
- **Draft Reviews**: Catching silly mistakes before they become architectural problems.

## 3. Comparative Analysis

| Dimension | `/new` Session | SubAgent (Multi-Model) |
| :--- | :--- | :--- |
| **Objectivity** | 🏆 **Winner** (True Clean Slate) | 🥈 Runner-up (Prompt Engineered Isolation) |
| **Convenience** | ❌ Poor (Context Switching) | 🏆 **Winner** (Seamless) |
| **Depth** | 🏆 **Winner** (Full Context Window available for Review) | ⚠️ Limited (Shares context with parent task) |
| **Cost Efficiency** | ⚠️ Re-reads files (Duplicate tokens) | 🏆 **Winner** (Can reuse some context) |

## 4. Recommendation: The Hybrid "Shift-Left" Workflow

Don't choose one; use both at different stages.

1.  **During Development (SubAgent)**: 
    - Use the **Codex Persona** (SubAgent) frequently.
    - Command: `/review-code --quick` (hypothetical) or simply asking "Review this function".
    - **Goal**: Fast feedback, catching typos and obvious bugs.

2.  **Before Merge (New Session)**:
    - **MANDATORY**: Run `/new` -> `/review-code`.
    - **Goal**: Simulation of a new team member reading the code for the first time. If the AI can't understand it without the chat history, your code (or docs) is broken.

## 5. Implementation in `learn-claude-code`

Currently, our `review-code` command is configured for **Strategy A (`/new`)** because we prioritize **Quality over Convenience** for the final gatekeeping step.

> **Rule**: If you have to explain *why* the code works in the chat for the reviewer to pass it, the code isn't good enough. `/new` enforces self-documenting code.
