---
name: ob-recap
description: On-demand narrative summary of a day, week, or month from daily notes and project activity. Default period is the last 7 days. Read-only — no vault files modified. Use when you want a quick summary without running a full weekly review.
---

# ob:recap — Period Summary

Generates a human-readable summary of a specified period from daily notes and project activity. Read-only.

**No vault files modified.**

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:recap — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

Period argument (optional):
- `/ob:recap` or `/ob:recap week` → last 7 days
- `/ob:recap day` → today only
- `/ob:recap month` → last 30 days

`PERIOD_LABEL`: `day` | `week` | `month`
`START_DATE`: today minus 0 days (day), 6 days (week), or 29 days (month), as `YYYY-MM-DD`
`END_DATE`: today as `YYYY-MM-DD`

## Step 2 — Collect daily notes in range

List all files in `$VAULT/06 Daily/` matching `YYYY-MM-DD.md` where the date falls within [`START_DATE`, `END_DATE`]. Read each file.

If no daily notes found for the range:
```
ob:recap — no daily notes found for <PERIOD_LABEL> (<START_DATE> to <END_DATE>).
```
Stop.

## Step 3 — Extract structured data

From all collected daily notes, extract:

**Completed tasks**: lines matching `- [x] <text>` — collect all unique completed tasks.

**Key decisions**: lines in `## Log` that contain decision language ("decided", "going with", "chosen", "locked") — collect up to 5 most recent.

**Narrative material**: lines in `## Log` and `## Notes` that describe what was worked on or learned.

## Step 4 — Generate summary

Synthesize the extracted data into a structured summary:

```
ob:recap — <PERIOD_LABEL> summary (<START_DATE> → <END_DATE>)

## Completed tasks (<n>)
- <task 1>
- <task 2>
...

## Key decisions
- <decision 1>
- <decision 2>
...

## Summary
<2–4 sentence narrative paragraph synthesized from Log and Notes entries. 
Focus on what was accomplished and any notable shifts.>
```

If a category has no entries, omit that section header rather than showing an empty section.
