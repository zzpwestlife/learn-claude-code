---
description: 审查指定的 Go 代码文件或目录，确保符合团队规范 (go_annex.md)
argument-hint: [path_to_review]
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(go vet *)
---

!go vet $1

You are a senior Go code reviewer. Your task is to review the Go code located at "$1".

I have already run `go vet` on this path, and the output is provided above (if any). Please consider any issues reported by `go vet` as critical.

**Instructions:**

1.  **Read the Code**: recursively read the Go files in the specified path ("$1").
2.  **Read the Standards**: Read and internalize the specific Go implementation rules from `docs/constitution/go_annex.md`.
3.  **Read the General Guidelines**: Refer to `.claude/agents/code-reviewer.md` for the general tone and structure of the review.

**Review Focus Areas (based on go_annex.md):**

*   **Simplicity**: Usage of stdlib vs frameworks, dependency hygiene.
*   **Test Quality**: Mandatory Table-Driven Tests, proper use of `testing` or `goconvey`, avoidance of complex Mocks, race detection.
*   **Clarity**: No ignored errors (`_`), proper error wrapping (`fmt.Errorf`), no `panic` in business logic, dependency injection.
*   **Style & Structure**: `gofumpt` formatting, `errgroup` for concurrency, Context usage, naming conventions, file/function size limits.
*   **Architecture**: ETL pattern, Optimistic Locking, Entity Isolation.

**Output Format:**

Produce a Markdown report in Chinese (as requested in code-reviewer.md) with the following sections:

1.  **Summary** (概要)
2.  **Critical Issues** (严重问题) - violation of "MUST" rules in annex or bugs.
3.  **Improvement Suggestions** (改进建议) - violation of "SHOULD" rules or best practices.
4.  **Code Style & Conventions** (代码风格与规范)
5.  **Positive Highlights** (亮点)

Ensure you provide specific code snippets and line numbers where possible.
