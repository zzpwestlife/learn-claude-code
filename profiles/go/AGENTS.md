# Commands

- **Build**: `make build` (dev: `make build-dev`)
- **Test**: `make test` (all unit tests), `make race` (race detection)
- **Lint**: `make lint` (golangci-lint), `make vet` (go vet)
- **Format**: `make fmt` (gofumpt)
- **Deps**: `make dep` (go mod tidy)
- **All**: `make all` (fmt+lint+vet+test+race+build)
*Note: If `Makefile` is missing, check `README.md` for project-specific commands.*

# Guidelines

> **⚠️ Constitution**: This project strictly adheres to [constitution.md](constitution.md).
> All code changes MUST comply with its **11 Core Principles** and relevant **Language Annexes** (e.g., [Go Annex](docs/constitution/go_annex.md)).

## Git & Version Control
- **Commit Message**: **[Strictly Follow]** Conventional Commits (type(scope): subject).
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- **Atomic Commits**: One feature/fix per commit.

## Workflow (4-Phase)
1. **Research**: Analyze context & patterns. **Review First**: Before coding, use `@` to read relevant code and understand existing logic.
2. **Plan**: Create a step-by-step plan. **Wait for confirmation** if the task is complex. Include **Verification Steps**.
3. **Implement**: Write code + tests. No `TODO`s.
4. **Verify**: Run tests/lint. Fix root causes, don't suppress errors.

## AI Collaboration Directives
- **Standard Lib First**: Prioritize standard library solutions over new dependencies.
- **Explain Code**: For complex logic, provide brief explanations of the core design.
- **Table-Driven Tests**: When writing tests, **MUST** use Table-Driven Tests.
- **Concurrency Safety**: Explicitly identify race conditions and explain safety measures (Mutex, Channels).

## Verification First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **Build**: Fix compile errors and verify successful rebuild.
- **Refactor**: Ensure tests pass before and after.

## Code Style & Patterns
- **Core**: Follow [constitution.md](constitution.md) Principles.
  - **Limits**: File < 200 lines, Func < 20 lines, Line < 80 chars.
  - **Changes**: Minimal diffs only.
- **Go**: See [Go Annex](docs/constitution/go_annex.md) (gofumpt, errgroup, no globals).
