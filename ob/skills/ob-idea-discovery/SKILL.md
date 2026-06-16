---
name: ob-idea-discovery
description: Rank the 3-5 most promising next-direction candidates from open inbox items, unfinished Atlas notes, and orphan research. Scoring weighs recency of related activity, connection density, and alignment with active projects. Read-only. Use when you're not sure what to work on next.
---

# ob:idea-discovery — Rank Next-Direction Candidates

Scans open ideas, inbox items, and under-connected research notes to rank the 3–5 most promising next directions. Each candidate includes supporting evidence and a suggested first action. Read-only.

**No vault files modified.**

**Depends on:** `ob-emerge` (#21) for pattern-awareness that informs relevance scoring.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:idea-discovery — ob.env not found. Run /ob:setup first.
```

## Step 1 — Discover candidate ideas

Collect notes from:
1. **`00 Inbox/`**: all notes with `status: draft` (not yet processed)
2. **`01 Atlas/`**: notes with `status: draft` or no `status` (unfinished authored notes)
3. **`05 Resources/`**: notes not linked from any Atlas note (orphan research — potential undeveloped seeds)

`CANDIDATES`: list of `{ path, type, title, last_modified, body_excerpt (first 200 chars) }`.

If fewer than 3 candidates found:
```
ob:idea-discovery — fewer than 3 candidate ideas found. Your inbox and Atlas may be well-processed.
```
Stop.

## Step 2 — Score each candidate

For each candidate, compute a composite score:

**Recency signal** (0–3 pts):
- Modified within last 7 days: +3
- Modified within last 30 days: +2
- Modified within last 90 days: +1
- Older: +0

**Connection density** (0–3 pts):
- Count how many other vault notes wikilink to this note
- 3+ backlinks: +3 · 2 backlinks: +2 · 1 backlink: +1 · 0 backlinks: +0

**Active project alignment** (0–3 pts):
- Read `$VAULT/CRITICAL_FACTS.md` for active projects
- If the candidate's topic overlaps with an active project: +3
- If it overlaps with a non-active `02 Projects/` project: +1
- No overlap: +0

**Emergence signal** (0–2 pts):
- If the candidate's topic was identified as a pattern by `/ob:emerge` output (check `01 Atlas/Synthesis/` for matching synthesis notes): +2
- Mentioned in any daily note `## Log` in the last 30 days: +1 (cap at +2 combined)

`TOTAL_SCORE`: sum of all signals (max 11).

Sort `CANDIDATES` by `TOTAL_SCORE` descending. Keep top 3–5.

## Step 3 — Generate suggested first action

For each top candidate, propose a concrete first action based on the note type:
- Inbox note → suggest `/ob:capture` follow-up or `/ob:graduate` if idea is mature
- Unfinished Atlas note → suggest a specific question to answer or section to complete
- Orphan research → suggest a specific Atlas note to link it to, or `/ob:synthesize` to surface connections

## Step 4 — Format output

```
ob:idea-discovery — <n> next-direction candidate(s)

## #1 — <TITLE> (score: <n>/11)

Path: [[<path>]]
Last touched: <last_modified>
Backlinks: <n> · Project alignment: <yes/no> · Emergence signal: <yes/no>

Why now: <1–2 sentences synthesizing why this scored high>

Suggested first action: <concrete next step>

---

## #2 — <TITLE> (score: <n>/11)
...
```
