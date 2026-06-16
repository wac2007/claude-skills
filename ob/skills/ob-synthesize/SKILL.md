---
name: ob-synthesize
description: Detect patterns across recent Resources and Atlas notes, then write synthesis pages to 01 Atlas/Synthesis/. Agent-authored notes are tagged source:agent and backlinked to their sources. Re-runnable — updates existing synthesis notes via managed regions rather than creating duplicates.
---

# ob:synthesize — Pattern Detection and Synthesis

Scans recent `05 Resources/` and `01 Atlas/` notes, detects recurring patterns and themes, and writes synthesis notes to `01 Atlas/Synthesis/`. Idempotent — re-running updates existing synthesis notes.

**Write guard:** `01 Atlas/Synthesis/` only.

**Depends on:** `ob-ingest` for the source material that feeds this skill.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:synthesize — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `LOOKBACK_DAYS`: optional integer argument `--days <n>`; default `30`
- `CUTOFF_DATE`: today minus `LOOKBACK_DAYS` days

## Step 2 — Collect source material

List all `.md` files in `$VAULT/05 Resources/` modified within `LOOKBACK_DAYS` days. List all `.md` files in `$VAULT/01 Atlas/` modified within `LOOKBACK_DAYS` days (excluding `01 Atlas/Synthesis/`).

`SOURCE_NOTES`: combined list of vault-relative paths.

If `SOURCE_NOTES` is empty:
```
ob:synthesize — no notes modified in the last <LOOKBACK_DAYS> days.
```
Stop.

## Step 3 — Read and cluster

Read each note in `SOURCE_NOTES`. Extract key topics from headings, first paragraphs, and frontmatter tags.

Group notes by shared topic clusters (minimum 2 notes per cluster). A note may belong to multiple clusters.

`CLUSTERS`: list of `{ topic: string, notes: [paths] }` objects. Keep clusters where `notes.length >= 2`.

If no clusters found:
```
ob:synthesize — no cross-source patterns found in the last <LOOKBACK_DAYS> days.
```
Stop.

## Step 4 — Write synthesis notes

For each cluster in `CLUSTERS`:

`TOPIC_SLUG`: lowercase `cluster.topic`, spaces → `-`, strip non-alphanumeric-or-dash, truncate at 50 chars.
`SYNTHESIS_FILE`: `$VAULT/01 Atlas/Synthesis/<TOPIC_SLUG>.md`

**If `SYNTHESIS_FILE` does not exist**, create it:

```markdown
---
type: note
source: agent
status: draft
created: <DATE>
updated: <DATE>
tags: []
---

# Synthesis: <cluster.topic>

<!-- BEGIN ob:synthesis -->
<!-- END ob:synthesis -->
```

**If it exists**, read it (the managed region will be updated below).

Locate or create the managed region `<!-- BEGIN ob:synthesis --> ... <!-- END ob:synthesis -->`.

Replace the entire region content with fresh synthesis (do not append — re-synthesize each run):

```
*Last synthesized: <DATE>*

## Pattern

<2–4 sentence description of the recurring theme or pattern observed across the source notes>

## Supporting notes

<for each note in cluster.notes:>
- [[<path>]] — <one sentence of relevant content from that note>

## Open questions

<1–3 questions that this pattern raises but doesn't yet answer>
```

Update `updated` frontmatter field to today's date.

## Step 5 — Report

```
ob:synthesize — complete
  Lookback: last <LOOKBACK_DAYS> days (<n> notes scanned)
  Patterns found: <n>
  Synthesis notes written/updated:
    <list of 01 Atlas/Synthesis/<slug>.md paths>
```
