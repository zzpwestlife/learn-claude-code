# Commands

- **Build**: `make build` (dev: `make build-dev`)
- **Test**: `make test` (all unit tests), `make race` (race detection)
- **Lint**: `make lint` (golangci-lint), `make vet` (go vet)
- **Format**: `make fmt` (gofumpt)
- **Deps**: `make dep` (go mod tidy)
- **All**: `make all` (fmt+lint+vet+test+race+build)

# Guidelines

> **⚠️ Constitution**: This project strictly adheres to [constitution.md](constitution.md).
> All code changes MUST comply with its 10 Core Principles.

## Workflow (4-Phase)
1. **Research**: Analyze context & patterns. Ask if ambiguous.
2. **Plan**: Create a plan with **Verification Steps** (how to prove it works).
3. **Implement**: Write code + tests. No `TODO`s.
4. **Verify**: Run `make all`. Fix root causes, don't suppress errors.

## Verification First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **UI**: Compare screenshots/mocks.
- **Build**: Fix compile errors and verify successful rebuild.
- **Refactor**: Ensure tests pass before and after.

## Code Style
- **Go**: Go 1.23+, `gofumpt`. Concrete types > `any`.
- **Concurrency**: `errgroup` + channels. **NO** `time.Sleep`.
- **Errors**: Explicit check (no `_`), wrap: `fmt.Errorf("ctx: %w", err)`.
- **Context**: Propagate `ctx` (timeout/cancel).

## Architecture Patterns
- **ETL**: `Query` -> `Clean` -> `Export`.
- **Optimistic Lock**: `UpdateRecordIfMatchStatus` (Init -> InProcess).
- **Entities**: Multi-entity support (`Futunn`, `MooMoo`, etc.).

## Code Snippets
**Optimistic Lock**
```go
func (r *Repo) UpdateStatus(ctx context.Context, id uint64, old, new string) error {
    res := q.Record.WithContext(ctx).Where(q.Record.ID.Eq(id), q.Record.Status.Eq(old)).Updates(map[string]interface{}{"status": new})
    if res.RowsAffected == 0 { return constant.UpdateRecordStatusEffectRowsZeroErr }
    return res.Error
}
```

## Anti-Hallucination
- **Ambiguity**: Ask questions.
- **Batching**: Prototype 1 file first.
- **Precision**: Match exact symbols.
