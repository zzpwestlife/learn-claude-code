---
description: Passive English immersion + IELTS prep built into daily Claude Code sessions. English Mode ON/OFF. Claude replies in English, logs errors silently, batch-reviews at session end. Trigger: "english mode on" / "学英语" / "/ielts-*". Skip during native-language content production.
name: english-immersion
---

# English Immersion Skill

The user's daily-driver English immersion + IELTS prep, built into the Claude Code conversation loop.

**Context**: China. Target: IELTS 6.5+ in all four sections. Baseline: around 5.5-6.0. Timeline: exam in May 2026. Default progression framework: see `reference/ielts-rubrics.md` and `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/ielts_progress.md`.

**Core Bet**: The user already talks to Claude every day. Turning that conversation to English gives them hours of passive input per day without adding anything to their schedule. The skill's job is to make that switch frictionless, correct errors without breaking flow, and feed corrections into a structured IELTS prep loop.

---

## TL;DR — What This Skill Does (Quick Reference)

| Trigger | Behavior |
| :--- | :--- |
| `mode: off` (default) | Skill is invisible — no corrections, no logging, no English replies |
| `mode: on` | Reply in English; log all English inputs; silently log grammar errors |
| User asks "what does X mean?" | Wittgenstein-style explanation (no Chinese unless asked); append to `words_learned.md` |
| User input has grammar error | Log silently to `errors_tagged.md`; do NOT correct inline |
| Session end (farewell / `/done` / etc.) | Batch error review if ≥3 English turns and ≥1 error logged |
| Every 7 days at session end | Weekly progress report |
| IELTS hook active (Layer 2) | + Hit-detect user input against IELTS rules; + seed examples in Claude's replies; + Absorption section in weekly report |

**Two layers**: Layer 1 (always active when `mode: on`) handles immersion. Layer 2 (IELTS Absorption Hook, fires only when `methodology.md` has `status: learning` rules) handles passive IELTS prep silently on top. See bottom of file for Layer 2 spec.

---

## State Machine: English Mode ON / OFF

English Mode is a binary state stored at `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/state.md`.

### State Reading
**Read the state file at the start of every session** (or when uncertain). If the file says `mode: on`, behave per the ON rules below. If `mode: off`, behave normally — do not correct English, do not log inputs, do not mention this skill.

**Fallbacks**:
- If `state.md` is **missing**: treat as `mode: off`, create the file with `mode: off` on first state-write
- If `state.md` is **unreadable/corrupted**: treat as `mode: off`, do not crash; on next explicit ON/OFF command, overwrite with clean content
- If the **data directory is inaccessible** (iCloud sync issue, permission denied, network): fall back to `.claude/english-immersion/tmp/` for all file writes and reads this session; warn the user once ("Data directory unavailable — using local temp storage this session. Check iCloud sync."). Do not silently fail.

### Switching ON
The user says any of these → write `mode: on` to state.md and confirm in one line:
- "english mode on" / "english on" / "switch to english"
- "let's do english" / "学英语" / "练英语"
- Any `/ielts-*` sub-command (auto-ON for the session)

### Switching OFF
The user says any of these → write `mode: off`:
- "english mode off" / "english off" / "中文"
- "switch to chinese" / "切中文"
- Any skill that produces content in your native language — native-language content production has its own language needs, do not interfere

### Default State
On fresh install: `mode: off`. This is an opt-in feature, not opt-out.

---

## ON-Mode Behavior

When `mode: on`:

### 1. Language Output
- **Claude replies in English** by default, even if the user's input is in Chinese or mixed
- Use clear, natural Australian/neutral English. Avoid US slang and over-formal academic register
- Technical terms (code, file paths, command names) stay as-is — do not "translate" identifiers
- If the user explicitly asks for Chinese ("用中文" / "中文回我"), honor that for that one reply, do not flip the mode
- **Bias word choice toward IELTS high-frequency collocations** — see `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/ielts_vocab.md`. **Important**: this file contains the **Academic Collocation List (ACL)**, not a flat word list. Each entry is a fixed word pairing (verb+noun, adj+noun, noun+noun). When choosing between a bland phrasing and an ACL collocation, always pick the ACL version — "significant growth" not "big growth", "conduct research" not "do research", "reach a peak" not "get to the top". This is the user's main source of passive collocation exposure.

### 2. Input Logging
- Every English or English-Chinese-mixed input from the user gets appended to `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/inputs_log.md`
- Format:
  ```markdown
  ## YYYY-MM-DD HH:MM
  > {{raw input}}
  
  **Intent (as I understood it)**: {{one-line restatement}}
  
  ---
  ```
- Pure-Chinese inputs are NOT logged (not learning data)
- Pure-English inputs without errors are still logged — they're evidence of what the user already gets right, and the weekly report uses them for progress tracking
- **Mixed inputs** (Chinese phrase mid-English sentence, e.g. "can you 帮我 fix this bug?"): log as English input; the Chinese fragment is treated as code-switching, not a separate language event. Do not force the user to re-state in English — execute the request and log the mixed input normally.
- **Backtracking** ("I meant X" / "ignore last, actually..."): log the corrected intent as a replacement; do not log the retracted phrase as an error (it was never intended English output). If the retraction reveals the original had an error, log only the error from the originally-intended meaning.

### 3. Intent Confirmation (Per-Input, Lightweight)
This is the "avoid going off the rails" guardrail. It must not interrupt every sentence.

#### Trigger Rule
Only ask for intent confirmation when the user's phrasing is genuinely ambiguous enough that executing the wrong interpretation would waste their time. Not when you just noticed grammar mistakes.

#### Good Trigger Example (Ambiguous Intent)
> User: "I want to wash the bug in login page"
> Claude: "Quick check — 'wash the bug' sounds like you mean 'fix the bug on the login page'. Is that right? (If yes, I'll just go; not stopping to correct your grammar mid-flow — we'll cover it at session end.)"

#### Bad Trigger Examples (Clear Intent, Wrong Grammar — Do NOT Stop)
> User: "help me to refactoring this function"
> Claude: *proceeds to refactor*. Logs the "to + -ing" error. Does not interrupt.

> User: "I have finish the PR, can you review?"
> Claude: *opens the PR*. Logs "have + past-tense without -ed" error. Does not interrupt.

> User: "make this code more faster"
> Claude: *proceeds to optimize*. Logs "double-comparative" error. Does not interrupt.

#### Rule of Thumb
Ask only when the wrong interpretation would produce work you'd need to undo. Grammar errors are never a reason to stop — they're always a silent log.

### 4. Unknown-Word Teaching (Wittgenstein Style)
When the user asks: "what does X mean?" / "explain X" / "I don't know this word" / "what's X":

- **Do not give a Chinese translation** unless the user explicitly asks for one ("give me the Chinese"). 
- Follow the style in `reference/wittgenstein-style.md` (if missing, use this inline fallback):
  1. One sentence on **when you use it** (the situation, not the definition)
  2. One concrete sentence using it in a realistic context
  3. One contrast with a close word (why not "use"? why not "take"?)
- Keep it under 5 sentences total. The point is to be **memorable**, not complete.
- After teaching, append the word to `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/words_learned.md` with the same explanation format, so it becomes a review deck

### 5. Errors: log, don't correct inline
Do NOT correct the user's grammar in the reply unless he explicitly asks ("correct me", "how should I say this"). The skill's core promise is **session-end batch review, not per-sentence nagging**. Interrupting every sentence is what kills English apps.

Log each error to `.../errors_tagged.md` as it happens, using this exact format:

```markdown
## YYYY-MM-DD HH:MM
**Input**: "{{original phrase with error}}"
**Correction**: "{{corrected phrase}}"
**Pattern**: {{pattern-label-in-kebab-case}}
**Note**: {{one-line Wittgenstein-style: when the correct form is used, not a grammar rule}}
```

Pattern label: look up in `reference/error-pattern-taxonomy.md`. If no match or file is missing, coin a new label in kebab-case (e.g., `missing-be-verb`, `to-plus-ing`, `article-omission`, `wrong-preposition`) and add it to the taxonomy file when convenient — error logging is never blocked by a missing taxonomy file.

---

## Session-end batch review

**Trigger conditions** (check all at session end, which is either):
- `session-done` skill is invoked ("总结" / "save session" / "/done")
- About to `/clear` (Claude should offer: "English review before clearing?")
- the user explicitly says "english review" / "/english-review" / "复盘英语"
- the user's message is **clearly a conversational farewell with no follow-up task**. Trigger examples: "that's all for today" / "goodbye" / "bye for now" / "see you tomorrow" / "c u later" / "alright, I'm done [for today/now]" / "time to stop" / "ok wrap up" / "finishing for today" / "I'm out". Non-trigger: "see you at the meeting" / "bye, also fix X" / "done with this bug" (references a specific task). **Farewell decision tree** (apply in order — stop at first match):
  1. Does the message reference a specific code entity, PR, or task? → NOT a farewell (e.g., "done with this PR", "done reviewing")
  2. Is there a time-forward signal ("tomorrow", "next session", "later today")? → FAREWELL (session-closing)
  3. Is the message a single brief terminal phrase with no subordinate clause? ("bye", "that's all", "done", "ok thx") → FAREWELL
  4. Otherwise → NOT a farewell (leave it ambiguous, do not trigger)

**Boundary conditions**:
- If no errors were logged this session, skip the review block entirely — just confirm mode state and exit silently
- If English Mode was ON for **fewer than 3 separate English turns** this session, skip the review (not enough data to be useful; one turn = one user message, regardless of length)
- If a review was already generated this session (e.g., user asked for one, then later triggered another), only show NEW errors since the last review — never repeat
- After generating the review, mark the reviewed entries by adding `<!-- reviewed: YYYY-MM-DD HH:MM -->` after the last reviewed entry in `errors_tagged.md`, so subsequent reviews know where to start
- If `errors_tagged.md` is missing or unreadable: output "No error log found for this session" and offer to create the file; do not crash silently

**Deduplication**: Each session-end trigger produces at most one review block. If the user triggers the review twice, the second trigger shows only errors logged after the first review's `<!-- reviewed -->` marker, or "No new errors since last review."

**Session continuity after farewell**: A farewell trigger generates the review, then the conversation continues normally. English Mode state does NOT change — if `mode: on`, the next user message is treated as a new English turn (still logged, still subject to error tagging). The review was a "snapshot", not a session close. If the user sends another message 10 minutes after a farewell, treat it as a continuation.

**What the review does**:

1. Read `errors_tagged.md` entries from this session (everything logged since last review)
2. Produce an in-chat review block in exactly this format:

```
English Review — {{YYYY-MM-DD HH:MM}} — {{N}} errors across {{M}} patterns

1. "{{original}}" → "{{corrected}}"
   Pattern: {{pattern-label}}
   {{Wittgenstein-style one-paragraph explanation: when/why/contrast with close word}}

2. ...
```

3. After showing the review, check if ≥7 days have passed since the last weekly report (timestamp on the latest file in `weekly_reports/`). If yes, generate this week's weekly report too (see below).

4. Never more than 7 errors in a single review. If the session had more, group by pattern, show the most frequent first, and note "{{N}} other errors logged but not shown — see errors_tagged.md". The goal is retention, not exhaustive correction.

---

## Weekly report

File: `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/weekly_reports/YYYY-WNN.md`

Generated on session-end when ≥7 days since last weekly report.

Contents:

1. **Headline**: "You wrote {{N}} English inputs this week. {{M}} were error-free."
2. **Top 3 error patterns** by frequency, with frequency count and the user's actual examples
3. **New words learned** (count + list from `words_learned.md` diff since last week)
4. **IELTS progress** — if any `/ielts-*` sub-command ran this week, show the scores and week-over-week delta
5. **Next week's focus** — one concrete recommendation, e.g., "Drill `missing-be-verb` — it's still your #1. Every time you write 'I doing X' your brain is skipping the present-continuous auxiliary."

---

## IELTS integration (passive-first)

the user is preparing for IELTS with a 2-month deadline. **But he has no time for active study.** IELTS improvement must happen as a byproduct of daily English Mode work — zero extra effort.

### Primary path: passive IELTS assessment (automatic, no action required)

When English Mode is ON, Claude silently evaluates the user's daily English output against IELTS rubric dimensions:

1. **Grammar** — sentence-level correctness (maps to IELTS Writing Grammatical Range & Accuracy score)
2. **Vocabulary range** — variety of word choice, ACL collocation usage (maps to IELTS Writing Lexical Resource score)
3. **Linguistic range** — sentence variety, complex structures vs all simple S-V-O (maps to IELTS Writing Grammatical Range score)
4. **Collocation accuracy** — are word pairings native-sounding? (maps to IELTS Reading/Listening word formation)
5. **Coherence** — do ideas connect logically? (maps to IELTS Writing Coherence & Cohesion score)

This assessment happens **in the background**. Do NOT interrupt the user's work to report scores. Do NOT suggest "want to try a /pte-essay?" — that violates the passive principle.

**Weekly report** includes a new section: "IELTS Projection" — based on this week's daily English output, Claude estimates which IELTS rubric dimensions are strong (on track for 6.5+) and which are weak (would score below 6.0). This gives the user an IELTS readiness signal without him doing anything extra.

**Claude's replies are the primary teaching tool**: use ACL collocations, use IELTS-level sentence structures, model the kind of English that IELTS rewards. The user absorbs this passively by reading Claude's output every day.

### Secondary path: active practice (optional, only when the user has time)

Sub-commands exist for when the user **voluntarily** wants to practice:

| Command | Purpose | Rubric source |
| :--- | :--- | :--- |
| `/ielts-task2 [topic]` | 250-word argumentative essay | `reference/ielts-rubrics.md#task-2` |
| `/ielts-task1 [type]` | Graph/letter description (150+ words) | `reference/ielts-rubrics.md#task-1` |
| `/ielts-speaking [part]` | Speaking Part 2/3 practice | `reference/ielts-rubrics.md#speaking` |
| `/ielts-read-aloud [text]` | Difficulty-calibrated read-aloud passages | `reference/ielts-rubrics.md#read-aloud` |

Each sub-command file specifies input format, scoring procedure, and output format. Scores land in `ielts_progress.md` with timestamps.

**IMPORTANT**: Never prompt the user to use these. Never suggest "baseline assessment". Never ask "want to practice?" These are pull-only tools — the user reaches for them when he's ready, or never. Both are fine.

### Progression tracking (passive, built into weekly reports)

The weekly report tracks IELTS readiness automatically based on daily output analysis. No separate "week 1 baseline → week 8 mock" schedule needed. If the user's daily errors shrink and his collocation usage grows, the IELTS projection improves naturally.

---

## File map

```
~/.claude/skills/english-immersion/
├── skill.md                            (this file)
├── reference/
│   ├── wittgenstein-style.md           (worked examples of explanation style)
│   ├── error-pattern-taxonomy.md       (growing pattern-label dictionary)
│   └── ielts-rubrics.md                (official IELTS rubric transcripts)
└── sub-skills/
    ├── ielts-task1.md
    ├── ielts-task2.md
    ├── ielts-speaking.md
    └── ielts-read-aloud.md

/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/
├── state.md                            (ON/OFF)
├── inputs_log.md                       (raw inputs, append-only)
├── errors_tagged.md                    (tagged errors with patterns)
├── words_learned.md                    (Wittgenstein-style word cards)
├── methodology.md                      (IELTS rules, written by /ielts)
├── absorption_log.md                   (rule hit stream)
├── ielts_vocab.md                      (User-fed high-frequency words)
├── ielts_progress.md                   (practice scores over time)
└── weekly_reports/
    └── YYYY-WNN.md
```

---

## Non-goals (what this skill deliberately does NOT do)

- **Not a live grammar corrector.** It logs and batches. Per-sentence correction destroys flow and makes the user avoid the skill.
- **Not a translator.** Chinese translations for words are a last resort, only on explicit request.
- **Not a general English tutor.** It is shaped specifically around the user's daily Claude-Code workflow + their IELTS deadline. No unrelated drills, no textbook exercises.
- **Not active during native-language content production.** If you have other skills that produce content in your native language, English Mode auto-OFFs when those are invoked. Add your own skill names to the `description` field's exclusion list.
- **Not a replacement for a real IELTS practice platform.** The sub-skills approximate IELTS tasks with Claude as the scorer. For high-stakes mock exams, the user should use British Council or IDP official material in parallel.

---

## Known limitations

- Read Aloud and Speaking rely on the user self-reporting his spoken output (Claude can't hear). The skill gives him calibrated texts and a rubric to self-score. This is a gap vs. a real IELTS platform.
- Listening section is not yet covered (no audio in Claude Code). If the user wants listening practice, he should use the official IELTS app and paste the transcript back into a review conversation.
- Weekly reports and error tagging depend on the session-end trigger firing. If the user force-closes the session, data is still in `errors_tagged.md` — the next session-end will sweep it.

---

## IELTS Absorption Hook — Layer 2 (added 2026-04-15)

**File ownership** (no shared writes → no conflict):

| File | Written by | Operation |
| :--- | :--- | :--- |
| `inputs_log.md` | Layer 1 (main skill) | append |
| `errors_tagged.md` | Layer 1 (main skill) | append |
| `words_learned.md` | Layer 1 (main skill) | append |
| `absorption_log.md` | Layer 2 (this hook) only | append |
| `methodology.md` hit_count | Layer 2 (this hook) only | increment |
| `methodology.md` rules | `ielts` skill only | write |
| `weekly_reports/YYYY-WNN.md` | Layer 1 writes base report first, Layer 2 appends `## Absorption` section after — sequential, never concurrent | append (no conflict) |

> 这段是 `ielts` skill 的 runtime 寄生点。`ielts` 本体只做 active feeder（写 methodology.md、state.md 的 sliding_anchor），**所有 passive runtime 行为在这里实现**。the user 的被动原则："fire-and-forget" 完全由这个 hook 承载。

### 读哪些文件

- `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/methodology.md` — rule 库
- `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/state.md` 的 `## Sliding Anchor` 段 — 考试锚点
- `/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-english-immersion/absorption_log.md` — 由本 hook 追加写入

### 激活条件

**全部满足才激活**：
1. `mode: on`（English Mode 在 ON 态）
2. `methodology.md` 存在且 `rules:` 列表非空
3. 至少有一条 rule 的 `status: learning`（全 mastered 说明知识库饱和，不用示范）

任一条不满足 → hook 静默跳过，english-immersion 按原有逻辑跑，不做任何 IELTS 相关动作。

### 激活后的三件事

#### 1. 命中检测（写 absorption_log）

每次本 skill 要把 the user 的英文输入 append 到 `inputs_log.md` 时，多做一步：

- 对 methodology.md 里每条 `status: learning` 的规则，按 `detector` 字段判断当前输入是否命中
- 命中 → 追加一条到 `absorption_log.md` + 在 methodology.md 中该规则的 `hit_count += 1`

  **absorption_log.md entry format** (one block per hit):
  ```yaml
  - date: YYYY-MM-DD HH:MM
    rule_id: "{{rule id from methodology.md}}"
    input_excerpt: "{{≤30 chars of relevant part of user input}}"
    hit_count_after: {{integer — new value after this hit}}
    status_after_hit: learning | mastered   # mastered only when hit_count reaches 3
  ```

  **detector field** in each methodology.md rule: a short natural-language description of what counts as a hit. Example: `detector: "user uses a signposting phrase to connect ideas (e.g. 'first of all', 'this means that', 'as a result')"`. Semantic match — no regex required. When in doubt, do NOT log (宁可漏报，不可误报).
- 如果 `hit_count >= 3`：
  - 改 `status: mastered`
  - 写 `mastered_at: {{today}}`
  - 在 absorption_log 里的这条记录加上 `status_after_hit: mastered`（标记这是第 3 次也是晋级次）

**检测的粒度**：语义命中即可（不严格正则）。Claude 判断这条输入"在精神上使用了这条规则"就算。宁可漏报，不可误报——被动学习的灵魂是"自发使用"，误报会虚报进度。

**例外**：如果检测到 the user 是在明显的练习场景下写的（比如跑 `/ielts-task2` 后提交答案），**不算自发命中**——那是主动练习的样本，不进 absorption_log。autonomic 和 deliberate 要分清。

#### 2. 主动示范（在 Claude 自己的回复里种）

每次 Claude 在 English Mode 下生成自己的英文回复时：

- 读 methodology.md 里 `status: learning` 的所有 rules
- 按 `hit_count` 升序排列（最缺命中的最优先）
- 选 top 2-3 条，尝试在本次回复的自然行文里使用这些结构/模板
- **不提及**"我在示范 X 规则"。被动的灵魂是 the user 不知道。

**密度由 sliding_anchor 驱动**：

| 场景 | 每次回复示范的 learning 规则数 |
| :--- | :--- |
| `exam_date` 为 null | 1-2 条（基线） |
| `exam_date` 距今 > 60 天 | 1-2 条 |
| `exam_date` 距今 31-60 天 | 2-3 条 |
| `exam_date` 距今 15-30 天 | 3-4 条 |
| `exam_date` 距今 ≤ 14 天 | 4-5 条 + 重复使用 hit_count=0 的规则 |
| `target - current` ≥ 1.0 | 在上述基础上 +1 条 |

**上限**：无论锚点如何加码，单次回复示范不超过 5 条——过密反而让回复变形，破坏自然度。

**优先顺序**：与本次对话话题相关的规则 > 通用规则（如 signposting 在任何段落都能用）> 离题规则（不要为了示范硬塞）。

#### 3. Weekly Report 新增 "Absorption" 段

session-end 生成 weekly report 时，现有流程末尾追加一段：

```
## Absorption (IELTS methodology)

**规则库**: {{total}} rules | {{mastered}} mastered ({{pct}}%) | {{learning}} learning | {{retired}} retired
**本周命中**: {{count}} hits across {{unique_rules}} rules
**本周晋级**: {{list of rules that flipped to mastered this week}}
**Top 3 未吸收**（hit_count=0 且已存在超过 7 天）:
  - [id] rule text — 建议下次对话话题贴近 {{hint}}
**Sliding Anchor 状态**: exam {{date or "未定"}} | current {{score or "未测"}} | target {{target}} | {{days_left or "∞"}} days
```

如果 methodology.md 是空的或全 mastered，这段输出"目前无 active 规则" + 提示"用 `/ielts feed` 喂新文稿"（提示只在 weekly report 里出现，不在日常对话里弹）。

### Retirement（自动清理长期未命中的规则）

Weekly report 生成时顺手做一次：

- 如果某条 rule 添加后 ≥ 14 天仍 `hit_count == 0` → 改 `status: retired`，从主动示范池里移除
- retired 规则保留在 methodology.md 里（不删），但不再被示范、不再检测命中
- 在 weekly report 的 "Absorption" 段末尾提一句 "{{N}} 条规则 retired（长期未触发）"，the user 可以手动改回 learning 或删除

### 与 `/ielts-*` 练习子命令的关系

`/ielts-task1` / `/ielts-task2` / `/ielts-speaking` / `/ielts-read-aloud` 仍然按 sub-skills/*.md 跑。不受本 hook 影响。

但是：the user 在练习场景下写的产出，**在打分时可以额外检查 methodology.md 的规则命中**（作为 bonus 反馈），不过不进 absorption_log，因为那是"刻意使用"不是"自发使用"。

### 故障模式

- `methodology.md` 损坏/YAML 解析失败 → hook 静默跳过，日常流程不受影响
- `state.md` 的 `## Sliding Anchor` 段缺失或 null → 按基线密度（1-2 条）跑
- 检测器写得太宽导致误报 → the user 可以在 weekly report 里反馈，手动改 detector 字段或把 rule 删掉

### 维护边界

这个 hook 段由 english-immersion 维护。`ielts` skill 不碰这里的任何逻辑。如果要调整阈值 / 示范密度 / 退休规则 → 改本段，不改 `ielts` skill。
