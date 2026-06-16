---
name: ob-health
description: Vault audit — surfaces contradictions, stale notes (>90 days), orphan notes (no backlinks), and missing frontmatter. Produces a structured report by severity. Read-only. Use periodically to keep the vault clean.
---

# ob:health — Vault Audit

Scans the vault and produces a structured report of issues grouped by category and severity. Read-only — no vault files modified.

**No vault files modified.**

**Scope:** all `.md` files except `99 Archives/` and `08 Templates/`.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:health — ob.env not found. Run /ob:setup first.
```

## Step 1 — Discover files

List all `.md` files in `$VAULT` recursively, excluding:
- `99 Archives/`
- `08 Templates/`

`ALL_NOTES`: resulting list of vault-relative paths with last-modified dates.

## Step 2 — Check: missing frontmatter

For each note in `ALL_NOTES`, read its frontmatter (the `---` block at the top). Flag as a finding if:
- No frontmatter block present at all
- `type` field is absent or empty
- `status` field is absent or empty

**Severity:** `low` (easy to fix, no semantic impact)

## Step 3 — Check: stale notes

Flag notes where last-modified date is more than 90 days ago AND `status` is not `archived` or `done`.

**Severity:** `medium` — note may contain outdated claims

## Step 4 — Check: orphan notes

Build a set of all wikilink targets from every note (`[[Note Name]]` and `[[path/to/note]]` patterns). A note is an orphan if its filename (without extension) does not appear in any other note's wikilinks.

Exclude from orphan check: `CRITICAL_FACTS.md`, `Projects - Index.md`, `Areas - Index.md`, daily notes (`06 Daily/`).

**Severity:** `low` — may be fine or may be disconnected knowledge

## Step 5 — Check: contradictions (lightweight)

For each pair of notes in `01 Atlas/` that share a topic keyword (extracted from filenames or `## ` headings), read both and flag if they contain conflicting factual claims: sentences with opposing assertions on the same subject (e.g. "X is Y" vs "X is not Y").

Limit to the top 20 most-linked notes to keep this feasible. Report each suspected contradiction as a finding with both note paths and the conflicting sentences.

**Severity:** `high` — requires manual resolution

## Step 6 — Format report

```
ob:health — vault audit complete (<DATE>)
Scope: <n> notes (99 Archives/ and 08 Templates/ excluded)

## HIGH — Contradictions (<n>)
<if none: "(none found)">
- [<path>] vs [<path>]: "<claim A>" conflicts with "<claim B>"
  ...

## MEDIUM — Stale notes (<n>)
<if none: "(none found)">
- <path> (last modified: <date>, <n> days ago)
  ...

## LOW — Orphan notes (<n>)
<if none: "(none found)">
- <path>
  ...

## LOW — Missing frontmatter (<n>)
<if none: "(none found)">
- <path>: missing <field1>, <field2>
  ...

Run /ob:reconcile to address contradictions.
```
