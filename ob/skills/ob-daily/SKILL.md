---
name: ob-daily
description: Create or open today's daily note in 06 Daily/, pre-filled from the Daily template. Use /ob:daily log <text> to append a work session entry without opening the file. Use at the start of a work session or to log what you worked on.
---

# ob:daily — Daily Note & Session Log

Creates today's daily note in `06 Daily/` from the Daily template, or appends a timestamped log entry to it.

**Write guard:** `06 Daily/` only. Never writes to any other bucket.

**Implementation note:** vault paths contain spaces (e.g. `06 Daily/`). Always use the Bash tool with quoted paths — never the Write/Edit tools directly on vault files.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop: "ob.env not found — run /ob:setup first."

## Step 1 — Parse arguments

Two modes:
- **Create mode**: `/ob:daily` with no sub-command — create or confirm today's note
- **Log mode**: `/ob:daily log <text>` — append a timestamped entry to today's note

Common variables:
- `DATE`: today's date as `YYYY-MM-DD`
- `DAILY_FILE`: `$VAULT/06 Daily/$DATE.md`

## Step 2 — Create mode

**If `DAILY_FILE` already exists**, stop:
```
ob:daily — today's note already exists: 06 Daily/<DATE>.md
```

**If it does not exist**, write `DAILY_FILE` with the Daily template content. Replace `<% tp.date.now("YYYY-MM-DD") %>` with `DATE`:

```markdown
---
type: daily
date: <DATE>
tags: []
---
## Tasks

## Notes

## Log
```

Report:
```
ob:daily — created: 06 Daily/<DATE>.md
```

## Step 3 — Log mode (`/ob:daily log <text>`)

If `DAILY_FILE` does not exist, run Step 2 first (create the note), then continue.

- `TIMESTAMP`: current time as `HH:MM`
- `ENTRY`: `- <TIMESTAMP> <text>`

Find the `## Log` section in `DAILY_FILE`. Append `ENTRY` as a new line after the last existing log entry in that section. If the section is empty, append directly after the `## Log` heading.

**Guard**: multiple log entries accumulate; never overwrite previous entries.

Report:
```
ob:daily — logged to 06 Daily/<DATE>.md
```
