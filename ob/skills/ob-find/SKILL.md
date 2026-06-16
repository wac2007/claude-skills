---
name: ob-find
description: Smart vault search with context — returns ranked results with path, type, and a one-sentence summary per match. Excludes 99 Archives/ by default. Use when you want to locate notes without remembering exact titles.
---

# ob:find — Smart Vault Search

Searches the vault by content and filename, returns ranked results with context. Read-only.

**No vault files modified.**

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop: "ob.env not found — run /ob:setup first."

## Step 1 — Parse arguments

- `QUERY`: all text following `/ob:find`
- `INCLUDE_ARCHIVES`: false by default; set true if `--include-archives` flag is present

If `QUERY` is empty, prompt once: "What are you looking for?"

## Step 2 — Build the search scope

Search all `.md` files in `$VAULT` recursively, excluding:
- `08 Templates/` (always)
- `99 Archives/` (unless `INCLUDE_ARCHIVES` is true)

## Step 3 — Score each file

For each `.md` file, compute a relevance score:

| Signal | Points |
|---|---|
| Filename contains a QUERY word (case-insensitive) | +3 per word |
| Frontmatter `title` or first `# H1` heading contains a QUERY word | +2 per word |
| Body text contains a QUERY word | +1 per word (cap at +5) |
| File modified within last 7 days | +2 |
| File modified within last 30 days (but not 7) | +1 |

Keep the top 10 results. Discard files with score 0.

## Step 4 — Summarize each match

For each result, extract:
- `PATH`: vault-relative path (e.g. `01 Atlas/Some Note.md`)
- `TYPE`: value of `type` frontmatter property, or `unknown` if absent
- `SUMMARY`: one sentence ≤25 words, drawn from the note's H1, first paragraph, or frontmatter `description` field

## Step 5 — Format and output

```
ob:find — <count> result(s) for "<QUERY>"

1. <PATH> [<TYPE>]
   <SUMMARY>

2. <PATH> [<TYPE>]
   <SUMMARY>

...
```

If no results: `No notes matched "<QUERY>".`

If `INCLUDE_ARCHIVES` is false, append:
```
(99 Archives/ excluded — pass --include-archives to search it)
```
