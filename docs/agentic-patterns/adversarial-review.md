# Adversarial Review Pattern

> "Reviewers challenge whether the work achieves the intent well, not whether the intent is correct."

## Concept

**Adversarial Review** is an agentic pattern that introduces "heterogeneous intelligence" to break the "Confirmation Bias" of a single model. Instead of asking the same model to review its own work (which often leads to self-validation), this pattern spawns independent reviewer agents—ideally using a different underlying model or a radically different persona—to attack the code from specific "lenses".

### Core Philosophy

1.  **Break the Echo Chamber**: A single model session builds up context that reinforces its own decisions. To get a real review, you need a fresh context and a different perspective.
2.  **Intent-First**: Reviewers must judge *execution against intent*, not the intent itself.
3.  **Dynamic Scoping**: The depth of review adapts to the size of the change (Small -> Skeptic; Medium -> +Architect; Large -> +Minimalist).
4.  **Adversarial by Design**: Reviewers are instructed to find problems, not to be nice.
5.  **Lead Judgment**: The primary agent (you) acts as the "Lead Engineer", synthesizing the feedback and deciding what to accept or reject.

## Workflow

1.  **Load Principles**: The system loads core engineering principles (Skepticism, Minimalism, Architecture).
2.  **Determine Scope & Intent**:
    *   **Intent**: What is the author trying to achieve?
    *   **Scope**:
        *   **Small** (< 50 lines): 1 Reviewer (Skeptic)
        *   **Medium** (50-200 lines): 2 Reviewers (Skeptic + Architect)
        *   **Large** (200+ lines): 3 Reviewers (Skeptic + Architect + Minimalist)
3.  **Spawn Reviewers**:
    *   The system spawns independent processes (e.g., via CLI `claude -p` or `codex exec`) for each reviewer.
    *   Each reviewer gets a distinct **Lens** and **Prompt**.
    *   They run in parallel to avoid groupthink.
4.  **Synthesize Verdict**:
    *   The primary agent collects all findings.
    *   Verdict: **PASS**, **CONTESTED**, or **REJECT**.
5.  **Render Judgment**:
    *   The primary agent evaluates the findings and decides the final action plan.

## Reviewer Lenses

| Lens | Focus | Typical Questions |
| :--- | :--- | :--- |
| **The Skeptic** | Correctness, Security, Error Handling | "What happens if this input is null?", "Is there a race condition here?", "Where are the tests?" |
| **The Architect** | System Design, Coupling, Interfaces | "Does this break the layer boundary?", "Is this dependency necessary?", "How does this affect the data model?" |
| **The Minimalist** | Simplicity, YAGNI, Readability | "Can this be done in fewer lines?", "Is this abstraction premature?", "Is this name clear?" |

## Implementation in This Project

We have implemented this pattern as a **Skill** (`adversarial-review`).

### Usage

```bash
# Invoke the skill (which runs the script)
/adversarial-review <files...>
```

### Configuration

The skill uses a Python script (`scripts/adversarial_review.py`) to manage the review process. It attempts to use the `claude` CLI to spawn reviewers. You can configure the specific CLI command in `.claude/skills/adversarial-review/config.json`.
