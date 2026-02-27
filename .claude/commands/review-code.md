---
description: Review specified code files or directories, or perform Git incremental review.
argument-hint: [path_to_review | diff] [output_dir]
model: sonnet
allowed-tools: [AskUserQuestion, Read, Grep, Glob, RunCommand, Bash, Write]
---

# Code Review Command

**Mode Detection**:
- `diff` (or empty): Incremental Git Review (`git diff main...HEAD`).
- `path`: Full File Review.

**Process**:
1. **Static Analysis**: `go vet`, `flake8`, etc.
2. **Review**: Check Clarity, Simplicity, Style, Architecture.
3. **Report**: Save to `{output_dir}/CODE_REVIEW.md`.

**Handoff (MANDATORY TUI)**:
- **Options**:
  1. Generate Changelog (`/changelog-generator`)
  2. Fix Critical Issues (`/write-plan`)
  3. Manual Verification

> For detailed instructions, see `.claude/docs/references/commands/review_code_full.md`
