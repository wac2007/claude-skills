---
name: ob-emerge
description: Surface unnamed patterns from the last 30 days of notes across 06 Daily/, 00 Inbox/, and 01 Atlas/. Returns 3-7 ranked patterns with supporting evidence. Does not write to vault unless user confirms a pattern should become an Atlas note. Use when you suspect themes are forming but haven't named them.
---

# ob:emerge — Surface Unnamed Patterns

Scans the last 30 days of vault activity and surfaces recurring themes the user never explicitly named. Read-only by default — only writes to the vault with explicit confirmation.

**Write guard (optional):** `01 Atlas/` only, with explicit user confirmation per pattern.

**Depends on:** `ob-ingest` (#14) being available to have populated `05 Resources/` with ingested content.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:emerge — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `LOOKBACK_DAYS`: optional `--days <n>`; default `30`
- `CUTOFF_DATE`: today minus `LOOKBACK_DAYS` days

## Step 2 — Collect recent notes

List `.md` files modified within `LOOKBACK_DAYS` days from:
- `$VAULT/06 Daily/` (daily notes only, not archived weeks)
- `$VAULT/00 Inbox/`
- `$VAULT/01 Atlas/` (excluding `01 Atlas/Synthesis/`)

Read each file. Extract: all `## Log` and `## Notes` entries (daily notes), body text (inbox and Atlas notes).

`RECENT_CONTENT`: list of `{ path, date, text }` objects.

If fewer than 5 notes found:
```
ob:emerge — fewer than 5 notes in the last <LOOKBACK_DAYS> days. Not enough material to surface patterns.
```
Stop.

## Step 3 — Identify recurring patterns

Scan `RECENT_CONTENT` for:
- **Repeated vocabulary**: words or phrases that appear across 3+ notes on different days
- **Recurring activities**: types of work, reading, or thinking that appear multiple times
- **Emotional or evaluative signals**: words indicating friction, excitement, confusion, or clarity that cluster around a topic
- **Unresolved threads**: questions or "I should…" statements that appear more than once

Group these signals into candidate patterns. A pattern needs:
- At least 2 distinct notes as evidence (from different dates)
- A clear unnamed theme (not something the user has already labeled in a heading or tag)

Rank by: number of supporting notes (desc), then recency of most recent occurrence (desc).

Keep top 3–7 patterns.

## Step 4 — Format output

```
ob:emerge — <n> pattern(s) surfaced (last <LOOKBACK_DAYS> days)

## Pattern 1: <short unnamed label>

<2–3 sentence description of what the pattern is and why it seems significant>

Evidence:
- [[<path>]] (<date>): "<supporting quote ≤30 words>"
- [[<path>]] (<date>): "<supporting quote ≤30 words>"
- [[<path>]] (<date>): "<supporting quote ≤30 words>"

---

## Pattern 2: <label>
...
```

After all patterns:
```
Promote any of these to an Atlas note? Enter pattern numbers (e.g. 1,3) or press Enter to skip.
```

## Step 5 — Promote to Atlas (only if confirmed)

For each confirmed pattern number:

`PATTERN_SLUG`: lowercase label, spaces → `-`, strip non-alphanumeric-or-dash.
`ATLAS_FILE`: `$VAULT/01 Atlas/<PATTERN_SLUG>.md`

If `ATLAS_FILE` already exists, append to its `## Notes` section. Otherwise create:

```markdown
---
type: note
source: agent
status: draft
created: <DATE>
updated: <DATE>
tags: []
---

# <Pattern label>

<Pattern description>

## Evidence

<Evidence list from Step 4>

## Notes

<!-- hand-edited content below this line -->
```

Report each promotion:
```
ob:emerge — promoted to Atlas: 01 Atlas/<PATTERN_SLUG>.md
```
