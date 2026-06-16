---
name: ob-ingest
description: Ingest a URL, PDF, or audio file into 05 Resources/ and propagate new knowledge to related 01 Atlas/ notes via managed regions. Touches 5–15 related pages per ingest. Use when you want an external source to enrich your vault, not just be appended to it.
---

# ob:ingest — External Source Ingest

Fetches or reads a source, writes it to `05 Resources/`, finds related Atlas notes, and updates their managed regions with new claims. Re-runnable — idempotent on the source note; Atlas updates accumulate without duplication.

**Write guards:**
- `05 Resources/` — new source notes only
- `01 Atlas/` — managed-region sections only, tagged `source: agent`

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:ingest — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `SOURCE`: all text following `/ob:ingest` (trim whitespace)
- `SOURCE_TYPE`: detect from `SOURCE`:
  - Starts with `http://` or `https://` → `url`
  - Ends with `.pdf` → `pdf`
  - Ends with `.mp3`, `.m4a`, `.wav`, `.ogg` → `audio`
  - Otherwise → `url` (attempt fetch)

If `SOURCE` is empty, prompt once: "What URL, PDF path, or audio file do you want to ingest?" then continue.

## Step 2 — Extract source content

**URL**: Use WebFetch to retrieve the page. Extract title, main text content, and author/date if visible.

**PDF**: Read the file with the Read tool. Extract title (from metadata or first heading) and full text.

**Audio**: If a transcript file (`.txt` or `.srt`) exists alongside the audio, read it. Otherwise, report:
```
ob:ingest — audio transcript not found. Provide a .txt transcript alongside the audio file.
```
and stop.

`SOURCE_TITLE`: title extracted from source, or filename slug if unavailable.
`SOURCE_CONTENT`: extracted text content (may be long; that is fine).
`SOURCE_DATE`: publication or access date as `YYYY-MM-DD`.

## Step 3 — Write source note to 05 Resources/

`SLUG`: lowercase `SOURCE_TITLE`, spaces → `-`, strip non-alphanumeric-or-dash, truncate at 60 chars.
`RESOURCE_FILE`: `$VAULT/05 Resources/<SOURCE_DATE>-<SLUG>.md`

**Idempotency check**: if `RESOURCE_FILE` already exists, skip this step and log "source note already exists".

Write `RESOURCE_FILE`:

```markdown
---
type: resource
source: agent
url: <SOURCE if url, else blank>
source_type: <url|pdf|audio>
created: <SOURCE_DATE>
tags: []
---

# <SOURCE_TITLE>

> Ingested: <SOURCE_DATE>

<SOURCE_CONTENT (truncated to first 2000 words if very long)>
```

## Step 4 — Find related Atlas notes

Use `/ob:find` logic (Step 3 scoring) to identify Atlas notes in `$VAULT/01 Atlas/` related to key topics in `SOURCE_CONTENT`. Extract 5–10 key terms from `SOURCE_CONTENT`. Score all Atlas notes against these terms. Take the top 5–15 matches (score > 0).

`RELATED_NOTES`: list of vault-relative paths to update.

If fewer than 2 matches are found, note it in the report but continue.

## Step 5 — Update related Atlas notes

For each note in `RELATED_NOTES`:

1. Read the note.
2. Extract new claims from `SOURCE_CONTENT` relevant to the note's topic (2–5 bullet points).
3. Locate or create a managed region in the note:

```
<!-- BEGIN ob:ingest -->
...
<!-- END ob:ingest -->
```

4. Append inside the region (never prepend; never remove existing entries):

```
- **<SOURCE_DATE>** [<SOURCE_TITLE>](<05 Resources/<SLUG>.md>) — <claim 1>
- **<SOURCE_DATE>** [<SOURCE_TITLE>](<05 Resources/<SLUG>.md>) — <claim 2>
...
```

**Idempotency guard:** skip any claim line whose source note path already appears inside the managed region for this note.

## Step 6 — Report

```
ob:ingest — ingested: <SOURCE_TITLE>
  Source note: 05 Resources/<RESOURCE_FILE_BASENAME>
  Atlas notes updated: <n>
    <list of updated paths>
```
