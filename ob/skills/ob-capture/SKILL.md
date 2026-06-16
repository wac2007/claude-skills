---
name: ob-capture
description: Zero-friction idea capture to 00 Inbox/ — one command, no questions. Takes the idea text, writes a note with correct frontmatter. Use when you want to capture an idea, thought, or reference without breaking flow.
---

# ob:capture — Zero-Friction Inbox Capture

Writes a single note to `00 Inbox/` with correct frontmatter. No questions asked — one command, done.

**Write guard:** `00 Inbox/` only. Never writes outside this folder.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:capture — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse the idea text

The text following `/ob:capture` is the **idea text**. It may be a short phrase or several sentences.

If called with no text, prompt once: "What do you want to capture?" then continue.

## Step 2 — Derive the filename

- `DATE`: today's date as `YYYY-MM-DD`
- `SLUG`: take the first 6 words of the idea text → lowercase → replace spaces and punctuation with `-` → strip everything non-alphanumeric-or-dash → truncate at 50 chars
- `FILENAME`: `${DATE}-${SLUG}.md`
- `TARGET`: `$VAULT/00 Inbox/$FILENAME`

Example: idea text "Build the ob-capture skill today" → `2026-06-16-build-the-ob-capture-skill-today.md`

## Step 3 — Idempotency check

If `$TARGET` already exists, stop:
```
ob:capture — already captured: 00 Inbox/<FILENAME>
```

## Step 4 — Infer area (best-effort)

Read `$VAULT/04 Areas/Areas - Index.md` for the list of area names. From the idea text, pick the most relevant area. If none fits clearly, leave `area` blank.

## Step 5 — Write the note

Create `$TARGET`:

```markdown
---
type: note
status: draft
area: <inferred area, or blank>
created: <DATE>
tags: []
---
# <Title: first sentence of the idea text, or first 8 words, title-cased>

<Full idea text verbatim>
```

## Step 6 — Report

```
ob:capture — saved: 00 Inbox/<FILENAME>
```
