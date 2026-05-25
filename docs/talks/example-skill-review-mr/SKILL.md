---
name: review-mr
description: Multi-perspective GitLab Merge Request code review. Triggered when user pastes a GitLab MR URL (matches /-/merge_requests/), or asks to review a merge request. Fetches the diff via glab CLI, spawns 3 parallel subagents (security, performance, readability), aggregates findings into a markdown table grouped by file. Triggers include "review this MR", "审一下这个 MR", "code review 这个 merge request", or any URL containing "/-/merge_requests/".
---

# review-mr

## When to use

User pastes a GitLab MR URL or asks to review a merge request. Examples:

- "Review https://gitlab.com/foo/bar/-/merge_requests/42"
- "审一下这个 MR：https://gitlab.example.com/team/proj/-/merge_requests/123"
- "帮我 code review 这个 merge request <URL>"

## Prerequisites

- `glab` CLI installed and authenticated. Verify with `glab auth status`.
- The authenticated user has read access to the target MR.

If `glab auth status` fails, tell the user to run `glab auth login --hostname <host>` first and stop.

## Steps

### 1. Parse the MR URL

Extract from URL `https://<host>/<group>/<project>/-/merge_requests/<iid>`:
- `host` (e.g. `gitlab.futunn.com`)
- `repo` = `<group>/<project>` (e.g. `verify/verify_service`)
- `iid` (the integer after `/-/merge_requests/`)

If no URL given, ask the user to paste one and stop.

### 2. Fetch diff and metadata

**Always pass the full URL** — not `-R OWNER/REPO`. The URL carries the host, so glab will not fall back to a wrong default (e.g. gitlab.com). Use the exact URL the user pasted.

**Do NOT pass `--hostname`** to `glab mr` subcommands; that flag is only valid for `glab auth login`.

```
glab mr view <FULL_URL>
glab mr diff <FULL_URL>
```

Example: for `https://gitlab.futunn.com/joeyzou/cc-demo/-/merge_requests/1`:
```
glab mr view https://gitlab.futunn.com/joeyzou/cc-demo/-/merge_requests/1
glab mr diff https://gitlab.futunn.com/joeyzou/cc-demo/-/merge_requests/1
```

If the URL is missing the trailing IID (e.g. ends with `/merge_requests`), ask the user to paste the full URL with the number.

If diff > 1500 lines, ask user to narrow scope before continuing — three subagents on a huge diff burns context fast.

### 3. Spawn 3 subagents in parallel

**Critical**: emit all three Agent tool calls in a **single message**. Sequential calls = no parallelism.

Each subagent receives the same diff and one specific lens. Use `subagent_type: general-purpose`.

#### Lens 1 — Security

> Review the diff below for **security issues only**: SQL injection, XSS, secret leaks, auth bypass, unsafe deserialization, path traversal, weak crypto, missing input validation. Ignore performance and style.
>
> Return findings as a markdown list. Each item: `- {file}:{line} — {issue}. Fix: {suggestion}`. If nothing found, output exactly `No security issues.`
>
> Diff:
> ```
> {paste diff}
> ```

#### Lens 2 — Performance

> Review the diff below for **performance issues only**: N+1 queries, hot loops, large allocations, blocking IO on hot paths, missing caching, O(n²) where O(n) suffices, unnecessary re-computation. Ignore security and style.
>
> Same output format as Lens 1. If nothing found, output exactly `No performance issues.`
>
> Diff: ...

#### Lens 3 — Readability

> Review the diff below for **readability only**: bad/unclear names, deep nesting, missing comments where the WHY is non-obvious, dead code, magic numbers, functions too long. Ignore security and performance.
>
> Same output format as Lens 1. If nothing found, output exactly `No readability issues.`
>
> Diff: ...

### 4. Aggregate

Combine all three subagent outputs into one markdown report:

```
## MR Review · {title}
**Author**: {author} · **Source → Target**: {source} → {target} · **Files**: {n}

| File | Lens | Line | Issue | Suggestion |
|---|---|---|---|---|
| auth.go | Security | 12 | SQL string concatenation | Use parameterized query |
| auth.go | Readability | 14 | Function name `D` unclear | Rename to absDiff |
| cache.go | Performance | 8 | N+1 query | Batch with WHERE id IN (?) |

✅ Security: 1 · Performance: 1 · Readability: 1
```

Group rows by file. List lenses with no issues below the table.

### 5. Stop and offer follow-up

Do **not** implement fixes. Offer three options:
1. Post this report as MR comment: `glab mr note <FULL_URL> --message "<report>"`
2. Fix specific findings — tell me row numbers
3. Drill into a specific finding for more detail

## Notes

- Always emit subagent calls in **one message** — single-message-multiple-tool-uses is what makes them parallel
- Don't read files yourself; subagents read what they need from the diff context
- For self-hosted GitLab: configure glab with the right host (`glab auth login --hostname gitlab.example.com`)
- If a subagent returns prose instead of the list format, re-prompt it once with the format reminder
