---
name: ob-weekly
description: Generate the weekly summary note for the last completed ISO week, pre-populated from that week's daily notes, then archive the daily files into the week folder. Fully headless and idempotent — safe to run via launchd or manually.
---

# ob:weekly — Weekly Summary & Daily Archive

Generates `06 Daily/Weeks/YYYY-[W]ww/week-[W]ww.md` for the last fully-closed ISO week (Monday–Sunday), pre-populated by reading that week's daily notes, then moves those daily files into the same folder.

**Headless**: no questions asked. Reports what it did at the end.  
**Idempotent**: if the weekly file already exists, exits cleanly.  
**Week**: always the last fully-closed ISO week — the one that ended last Sunday. Running on any day of the current week looks back to the previous week.

## Step 0 — Resolve the vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If the file is absent, stop: "ob.env not found — run ob:setup first."

## Step 1 — Compute the target week

Determine today's date. Find the last Sunday (= end of the previous ISO week). Compute:
- `YEAR` and `WEEK` in ISO format: e.g. `2026-W24`
- `WEEK_LABEL`: `W24`
- `WEEK_START`: the Monday of that week (`YYYY-MM-DD`)
- `WEEK_END`: the Sunday of that week (`YYYY-MM-DD`)
- `WEEK_FOLDER`: `$VAULT/06 Daily/Weeks/YYYY-[W]ww` (e.g. `2026-[W]24`)
- `WEEK_FILE`: `$WEEK_FOLDER/week-[W]ww.md` (e.g. `week-[W]24.md`)

Use the `[W]` literal bracket notation to match the folder naming convention already established in the vault.

## Step 2 — Idempotency check

If `$WEEK_FILE` already exists, print:

```
ob:weekly — Week W<nn> already processed. Nothing to do.
```

Then stop.

## Step 3 — Collect daily notes

Scan `$VAULT/06 Daily/` for files named `YYYY-MM-DD.md` where the date falls within `[WEEK_START, WEEK_END]` (inclusive). Sort chronologically.

If none found: proceed to Step 4 with `DAILY_FILES=()` (stub path).

## Step 4 — Extract content from daily notes

For each daily file, parse these sections:

| Source | Extract |
|---|---|
| `## Tasks` — checked lines (`- [x] …`) | add to `DONE_ITEMS` with the date label |
| `## Tasks` — unchecked lines (`- [ ] …`) | add to `OPEN_ITEMS` |
| `## Decisions` block (entire section, if present) | add to `DECISIONS_BLOCKS` with the date label |
| `## Notes` + `## Log` (all text) | add to `RAW_NARRATIVE` |

Dedup `DONE_ITEMS` and `OPEN_ITEMS` by line content (same text appearing on multiple days = one entry).

**Next week — top 3**: take the first 3 items from `OPEN_ITEMS` (chronologically earliest unchecked tasks). If fewer than 3, use what exists. If none, leave the section blank.

## Step 5 — Synthesize the summary

Read `RAW_NARRATIVE` (all Notes + Log text across the week). Write 2–4 sentences that capture the week's themes, significant events, or context — not a list, a paragraph. Focus on the *why* and *so what*, not a restatement of tasks.

If `RAW_NARRATIVE` is empty: write `<!-- no notes or log entries found for this week -->` in the Summary section.

## Step 6 — Write the weekly file

Create `$WEEK_FOLDER/` if it does not exist. Write `$WEEK_FILE`:

```markdown
---
type: weekly
week: <YEAR>-[W]<NN>
created: <today's date>
tags: []
---
# Week [W]<NN>

## Summary

<synthesized paragraph, or the empty-content comment>

## Done

<DONE_ITEMS as a markdown checklist, checked. If none: *Nothing logged as completed this week.*>

## Decisions

<DECISIONS_BLOCKS verbatim, each prefaced with **YYYY-MM-DD**. If none: *No decisions recorded.*>

## Open threads

<OPEN_ITEMS as a markdown checklist, unchecked. If none: *No open tasks.*>

## Next week — top 3

<top 3 from OPEN_ITEMS as a checklist, unchecked. If none: leave blank.>
```

If no daily notes were found at all (stub path), write:

```markdown
---
type: weekly
week: <YEAR>-[W]<NN>
created: <today's date>
tags: []
---
# Week [W]<NN>

<!-- no daily notes found for this week -->

## Summary

## Done

## Decisions

## Open threads

## Next week — top 3
```

## Step 7 — Move daily files

For each file in `DAILY_FILES`, move it from `$VAULT/06 Daily/<date>.md` to `$VAULT/06 Daily/Weeks/<YEAR>-[W]<NN>/<date>.md`.

Skip any file that is already inside a `Weeks/` subfolder (safety guard against double-move).

## Step 8 — Report

Print a single summary:

```
ob:weekly — Week W<nn> done.
  Summary written: 06 Daily/Weeks/<YEAR>-[W]<NN>/week-[W]<NN>.md
  Daily notes archived: <count> files
  Open threads carried forward: <count>
```

If the stub path was taken:
```
ob:weekly — Week W<nn> done (no daily notes found).
  Stub created: 06 Daily/Weeks/<YEAR>-[W]<NN>/week-[W]<NN>.md
```
