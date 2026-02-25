# Commands

- **Build**: `make build` (dev: `make build-dev`)
- **Test**: `make test` (gotestsum), `make race` (race detection)
- **Lint**: `make lint` (staticcheck + nilaway)
- **Format**: `make fmt` (gofumpt)
- **Deps**: `make dep` (go mod tidy)
- **Tools**: `make tools` (install dev tools)
- **All**: `make all` (dep+lint+test)
*Note: If `Makefile` is missing, check `README.md` for project-specific commands.*

# Guidelines

> **⚠️ Constitution**: This project strictly follows [constitution.md](../../constitution.md).
> All code modifications must comply with its **11 core principles** and relevant **language annexes** (e.g., [Go Annex](../../.claude/constitution/go_annex.md)).

## Git & Version Control
- **Commit Messages**: **[STRICT]** Conventional Commits (type(scope): subject).
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- **Atomic Commits**: Each commit contains only one feature or fix.

## Workflow (Four Phases)
1. **Research**: Analyze context and patterns. **Review first**: Use `@` to read relevant code before coding and understand existing logic.
2. **Plan**: Use the **Plan Template** below to create step-by-step plans. **Wait for confirmation** for complex tasks. Include **verification steps**.
3. **Implement**: Write code and tests. No `TODO`s allowed.
4. **Verify**: Run tests and lint. Fix root causes, don't suppress errors.

## Plan Template (Mandatory)
When creating plans, you **MUST** include the following "Constitution Check" section:

```markdown
## Constitution Check
*GATE: Must pass before technical design.*

- [ ] **Simplicity (Art. 1):** Is the standard library used? Is over-abstraction avoided?
- [ ] **Test First (Art. 2):** Does the plan include writing tests *before* implementation?
- [ ] **Clarity (Art. 3):** Are errors explicitly handled? No global state?
- [ ] **Core Logic (Art. 4):** Is business logic decoupled from HTTP/CLI interfaces?
- [ ] **Security (Art. 11):** Are inputs validated? No sensitive data leakage?

*If any check fails, provide a strong justification in the "Complexity Tracking" section.*
```

## AI Collaboration Guidelines
- **Stdlib First**: Prioritize standard library solutions, avoid introducing new dependencies.
- **Explain Code**: Provide brief core design explanations for complex logic.
- **Table-Driven Tests**: **MUST** use Table-Driven Tests when writing tests.
- **Concurrency Safety**: Explicitly identify race conditions and explain safety measures (Mutex, Channels).

## Verify First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **Build**: Fix compilation errors and verify rebuilds successfully.
- **Refactor**: Ensure tests pass before and after refactoring.

## Code Style & Patterns
- **Core**: Follow [constitution.md](../../constitution.md) principles.
  - **Limits**: Files < 200 lines, functions < 20 lines, single lines < 80 chars.
  - **Changes**: Minimal diff modifications only.
- **Go**: See [Go Annex](../../.claude/constitution/go_annex.md) (gofumpt, errgroup, no global variables).
