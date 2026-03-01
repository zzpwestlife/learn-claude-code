# Code Review Best Practices: The Fresh-Eyes Principle

## 1. The Challenge of "Context Bias"

When you use an AI assistant to write code, the AI builds up a large context window containing:
- Your initial intent and requirements.
- Intermediate reasoning steps.
- Failed attempts and corrections.
- Implicit assumptions made during the session.

If you ask the *same* AI session to review its own code, it suffers from **Context Bias**:
- It "knows" what the code *should* do, so it might gloss over what the code *actually* does.
- It shares the same blind spots as the "writer" persona.
- It might hallucinate that certain checks were performed because they were discussed earlier, even if they aren't in the code.

## 2. The Solution: Independent Audit (Fresh Context + Stronger Model)

To achieve a true "Code Review," we must simulate an independent auditor. This involves two key shifts:

### A. Fresh Context (The `/new` Command)
By starting a new session (`/new`), you force the AI to:
- Read the code from scratch, just like a human reviewer would.
- Rely **only** on the code and documentation present in the files.
- Identify clarity issues: If the AI can't understand the code without the previous conversation history, the code is likely hard to maintain.

### B. Heterogeneous Models (The "Opus" Reviewer)
We explicitly configure the `/review-code` command to use **Claude 3 Opus** (or the most capable reasoning model available), while development might happen with Sonnet.
- **Why?** Different models have different training distributions and reasoning patterns.
- **Benefit**: This acts as a form of "Adversarial Review," where a stronger model checks the work of a faster model, catching subtle logic errors and architectural flaws.

### C. What if I used Opus for development?
A common question: *"If I already used Opus to write the code, does using Opus for review just bring me back to square one?"*

**Answer: No.** 
The "Fresh Context" factor (Step A) is far more critical than the "Different Model" factor.
- **Opus (Writer)**: Biased by the creation process, "knows" the intent, might ignore implementation gaps.
- **Opus (Reviewer)**: Unbiased, sees only the code, forced to be objective.

Even if the model architecture is identical, the **State** is different. An amnesiac genius is an excellent auditor for a genius with baggage.
- **Recommendation**: Always use the most capable model available (currently Opus) for review, regardless of what was used for development. Downgrading the reviewer (e.g., using Sonnet to review Opus code) is never recommended.

## 3. The Recommended Workflow

1.  **Develop**: Use `/brainstorm`, `/plan`, and `/execute` with the default model (e.g., Sonnet) to build the feature.
2.  **Finish**: Once the feature is complete and tests pass, **STOP**. Do not ask for a review yet.
3.  **Reset**: Type `/new` to start a fresh session.
4.  **Review**: Type `/review-code`.
    - The system will now load the specialized `review-code` command.
    - It will use the **Opus** model.
    - It will read the files without any prior bias.
5.  **Act**:
    - If issues are found, use `/write-plan` in the *current* review session to fix them.
    - If the code is clean, proceed to `/changelog-generator` and `/commit-message-generator`.

## 4. Configuration

This workflow is enforced by the `.claude/commands/review-code.md` configuration:

```yaml
---
description: Review specified code files or directories with a fresh perspective (Opus model). Ideally run in a new session.
model: opus
---
```

**Key Takeaway**: Treat your AI session like a developer. When the developer is done, hire an independent auditor (a new session with a smarter model) to check the work.
