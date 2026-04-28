# IELTS Skill — Active Feeder

The user's IELTS knowledge repository. This skill only handles "active feeding": ingesting transcripts, extracting rules, manual additions, and setting the sliding anchor. **Passive absorption is entirely handled by english-immersion** — that skill's ON-mode runtime automatically reads the files written by this skill and silently demonstrates rules + detects hits in daily conversations.

## Boundary Declaration (Very Important)

- **ielts is not persistent**：Runs once per `/ielts <sub-command>` and exits. No session state, no passive loop, no reminders.
- **ielts does not correct errors**：Passive detection of the user's daily English input is handled by english-immersion.
- **ielts does not interrupt**：Never主动推送 "Want to feed content?" or "Check your IELTS progress".
- **ielts works even when english-immersion is OFF**：The user can drop a transcript at any time. Data will be written and automatically activated when English Mode is next ON.

## Data Contract (Shared Files with english-immersion)

| File | Owner (Who Writes) | Who Reads |
| :--- | :--- | :--- |
| `sliding_anchor` section in `data/state.md` | ielts writes | english-immersion reads (determines "demonstration density of unmet threshold rules") |
| `data/methodology.md` | ielts writes (ingest/manual additions) | english-immersion reads (rule match + reply demonstration) |
| `data/ielts_vocab.md` | ielts appends + user manual additions | english-immersion reads (ACL preference) |
| `data/absorption_log.md` | english-immersion writes (on hit) | Weekly report reads |

ielts never reads absorption_log.md, inputs_log.md, or errors_tagged.md — those are english-immersion's domain.

---

## Sub-Commands

### `/ielts anchor` — Sliding Anchor

When run for the first time, it asks three mandatory questions, which can be reset at any time:

1. **Exam date** (can say "not decided" → stored as `null`)
2. **Current level** (last test score or self-assessed IELTS score, 1-9 scale)
3. **Target score** (typically 6.0, 6.5, 7.0, etc.)

Writes to the `sliding_anchor` section in state.md (see state.md schema below).

**Anchor's purpose** (only an indicator for english-immersion to read):
- Closer `exam_date` → higher demonstration density of unmet threshold rules in english-immersion replies
- Larger `target - current` → same as above, increased intensity
- No date → linear baseline density (1-2 natural demonstrations of unmet rules per reply)

### `/ielts feed <transcript>` — Feed YouTube Transcript

The user pastes a transcript from an IELTS teacher's讲解 video (技巧讲解 for any section: Writing Task 1/2, Speaking Part 2/3).

**Claude's Processing Flow**：

1. **Identify section**：Determine which IELTS sub-task the transcript covers (Task 1 / Task 2 / Speaking Part 2 / Speaking Part 3)
2. **Extract structured rules**：Extract executable rules from the transcript. Each rule must meet:
   - **Detectable** (can determine if input in inputs_log matches via regex or semantic matching)
   - **Executable** (user knows what to do when they see it, not vague advice like "be sophisticated")
   - **Atomic** (one rule per action, no stacking)
3. **Show to user for confirmation** in this format：

   ```
   Extracted N rules from transcript (section: {{Task 2 Essay}})：

   1. [thesis-paragraph] Essay introduction must contain a thesis sentence, template: While {{counter}}, {{main}} is more important because {{reason}}.
      → Detection: first paragraph contains "While " + "more important" or "primarily because"
   2. [signpost-firstly] Body paragraphs start with signposting conjunctions (Firstly/Moreover/Furthermore), not And/Also.
      → Detection: paragraph first word ∈ {Firstly, Moreover, Furthermore, Additionally, In contrast}
   3. ...

   Approve all / Delete [numbers] / Modify [numbers] / Add [new rule] / Reject all
   ```

4. **After user confirmation**，append to `methodology.md`（see schema）。New rules have initial `hit_count` = 0、`status` = `learning`。
5. **Do not automatically invoke english-immersion**。ielts finishes after writing the file, does not trigger any review / assessment / demonstration。

### `/ielts rule <rule text>` — Manually Add a Rule

The user directly states a rule, and the skill formats it (adds section / ID / detector) and appends it to methodology.md. Skips the feed's "extract-show"流程, writes directly.

Usage example：
> `/ielts rule Task 2 Essay conclusion paragraph must start with In conclusion or To sum up`

Claude generates：
```yaml
- id: conclusion-opener
  section: writing-task2
  rule: "Conclusion paragraph starts with In conclusion / To sum up"
  detector: "Conclusion paragraph starts with phrase ∈ {In conclusion, To sum up, To conclude}"
  hit_count: 0
  status: learning
  source: manual
  added: 2026-04-19
  mastered_at: null
```
Asks "Anything to add?" before saving.

### `/ielts vocab <word list>` — Add High-Frequency Words/Collocations

Appends to existing `ielts_vocab.md` (not overwriting), one collocation per line. english-immersion already reads this file.

**Format validation**:
- Each entry must be a valid collocation pair (verb+noun, adj+noun, or noun+noun), not a single word
- If the user provides single words, ask: "Collocations work best as pairs — e.g., 'conduct research', not just 'research'. Would you like to specify the partner, or should I suggest common collocations for these words?"
- Skip duplicates: check if the collocation already exists in ielts_vocab.md before appending

### `/ielts status` — View Progress (User-initiated, not pushed)

Outputs a one-screen summary：

```
Anchor: exam {{date}} | current {{score}} | target {{target}} | {{days_left}} days
Methodology: {{total}} rules | {{mastered}} mastered ({{pct}}%) | {{learning}} learning
Top 5 unabsorbed rules (sorted by hit_count ascending):
  - [id] rule text — 0 hits
  - ...
Recent hits (last 7 days): {{count}}
```

---

## File Schemas

### `state.md` sliding_anchor section (written by ielts)

Appended to the bottom of existing state.md：

```markdown
## Sliding Anchor (ielts skill)

> Maintained by `ielts` skill. english-immersion reads these fields in ON mode to determine demonstration density of "unmet threshold rules" in replies.

- exam_date: 2026-05-15   # or null if undecided
- current_level: 6.0      # IELTS band score, 1-9
- target_score: 7.0
- set_at: 2026-04-19
- notes: (optional free text)
```

english-immersion reads these fields to determine demonstration density.

### `methodology.md` schema

YAML list，one entry per rule：

```yaml
---
# IELTS Methodology — rules distilled from transcripts + manual additions
# Read by english-immersion during ON mode for passive rule-match and demonstration.
# Mastered rules (hit_count >= 3) are retired from active demonstration to make room for new ones.
---

rules:
  - id: thesis-while-y
    section: writing-task2
    rule: "Essay introduction must contain a thesis, template: While {counter}, {main} is more important because {reason}."
    detector: "first_paragraph contains 'While ' AND ('more important' OR 'primarily because')"
    hit_count: 0
    status: learning   # learning | mastered | retired
    source: transcript:{video_title_or_url}   # or "manual"
    added: 2026-04-19
    mastered_at: null
```

**State transitions**：
- `learning` → `mastered`：when `hit_count >= 3`
- `mastered` → `retired`：when no new hits 7 days after rule mastery（executed during english-immersion weekly check）

### `absorption_log.md` schema（written by english-immersion, ielts only reads description）

```markdown
# Absorption Log — append-only hit stream

## 2026-04-20 09:30
- rule: thesis-while-y
- input: "While cost is a concern, quality is more important because..."
- snippet: "While cost is a concern..."
- new_hit_count: 1
```

---

## Non-Goals (What ielts Deliberately Does NOT Do)

- **Does not do daily English error correction**（handled by english-immersion）
- **Does not do session-end review**（handled by english-immersion）
- **Does not write to inputs_log/errors_tagged/words_learned**（handled by english-immersion）
- **Does not proactively remind to feed transcripts**（passive principle）
- **Does not run `/ielts-*` practice commands**（those are english-immersion's sub-skills：`/ielts-task1`、`/ielts-task2`、`/ielts-speaking`等，no conflict with this skill, both can coexist）
- **Does not do OCR/ASR**：transcripts must already be in text form when pasted by the user

## Difference Between ielts Skill Commands and english-immersion `/ielts-*` Sub-commands

| Command | Skill | Type | Purpose |
| :--- | :--- | :--- | :--- |
| `/ielts feed` / `/ielts rule` / `/ielts anchor` / `/ielts vocab` / `/ielts status` | **ielts**（this skill） | Active feeding | Add content to knowledge base |
| `/ielts-task1` / `/ielts-task2` / `/ielts-speaking` / `/ielts-read-aloud` | english-immersion | Active practice | Run a practice test and score it |

Both sets of commands are "active entry points" and pull-only. The difference: the former adds to the knowledge base, the latter tests yourself using the knowledge base. The naming convention clearly distinguishes between them: `/ielts xxx`（space）vs `/ielts-xxx`（hyphen）.
