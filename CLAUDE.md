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

## Workflow (4-Phase)
1. **Research**: Analyze context & patterns. Ask if ambiguous.
2. **Plan**: Create a plan with **Verification Steps** (how to prove it works).
3. **Implement**: Write code + tests. No `TODO`s.
4. **Verify**: Run tests/lint. Fix root causes, don't suppress errors.

## Verification First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **UI**: Compare screenshots/mocks.
- **Build**: Fix compile errors and verify successful rebuild.
- **Refactor**: Ensure tests pass before and after.

## Code Style & Patterns
- **Core**: Follow [constitution.md](constitution.md) Principles (Simplicity, Clarity, SOLID).
- **Go**: See [Go Annex](docs/constitution/go_annex.md) (gofumpt, errgroup, no globals).
- **Other**: Follow standard community best practices (PEP8 for Python, etc.).

## Architecture Patterns (Current Project)
- **ETL**: `Query` -> `Clean` -> `Export`.
- **Optimistic Lock**: `UpdateRecordIfMatchStatus` (Init -> InProcess).
- **Entities**: Multi-entity support (`Futunn`, `MooMoo`, etc.).

## Anti-Hallucination
- **Ambiguity**: Ask questions.
- **Batching**: Prototype 1 file first.
- **Precision**: Match exact symbols.
