---
name: ob-vault-synthesis
description: Deep cross-reference of every vault note on a topic — maps agreements, contradictions, stale claims, and open questions. Every finding cites specific note paths. Read-only. Use when you want an exhaustive picture of everything you know about a topic.
---

# ob:vault-synthesis — Deep Topic Cross-Reference

Cross-references every vault note on a topic and produces a comprehensive map: agreements, contradictions, stale claims, and open questions. More thorough than `/ob:find` (reads full content) and more focused than `/ob:health` (single topic). Read-only.

**No vault files modified.**

**Depends on:** `ob-health` (#19) for the contradiction-detection patterns it established.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:vault-synthesis — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `TOPIC`: all text following `/ob:vault-synthesis` (trim whitespace)

If `TOPIC` is empty, prompt once: "What topic do you want a deep synthesis of?" then continue.

## Step 2 — Find all relevant notes

Search the full vault (excluding `99 Archives/` and `08 Templates/`) for notes related to `TOPIC` using the `/ob:find` scoring logic. Use a lower threshold than ob-find — include notes with score ≥ 1.

`ALL_NOTES`: all matching vault notes with their paths and last-modified dates.

If fewer than 2 notes found:
```
ob:vault-synthesis — fewer than 2 vault notes found about "<TOPIC>".
  Run /ob:capture or /ob:ingest to build up this topic first.
```
Stop.

Read every note in `ALL_NOTES` fully.

## Step 3 — Cluster by stance

Group notes into clusters based on the angle or stance they take toward `TOPIC`:
- Each cluster gets a short label (e.g. "argues in favor", "implementation guide", "historical context", "cautionary examples")
- A note may appear in only one cluster (pick the dominant stance)

`CLUSTERS`: list of `{ label, notes: [paths] }`.

## Step 4 — Map agreements

Identify claims about `TOPIC` that appear (with same or compatible meaning) in 2+ notes. For each agreement:
- State the shared claim in one sentence
- List the notes that support it with brief quotes

`AGREEMENTS`: list of `{ claim, sources: [{path, quote}] }`.

## Step 5 — Map contradictions

Identify claims in one note that directly conflict with claims in another note on the same sub-topic. For each contradiction:
- State both conflicting claims
- Cite the notes and quotes
- Note which is more recent (prefer newer unless there's evidence the older was deliberate)

`CONTRADICTIONS`: list of `{ claim_A: {path, quote}, claim_B: {path, quote}, newer: path }`.

## Step 6 — Flag stale claims

Identify factual claims in notes not modified in more than 90 days where the claim concerns a rapidly changing domain (technology, market, current events). Flag as potentially stale.

`STALE_CLAIMS`: list of `{ path, claim_excerpt, last_modified }`.

## Step 7 — Surface open questions

Collect explicit questions from all notes (`?` sentences, "TBD", "open question", "unclear") and implicit gaps (where the notes assert X and Y but never address Z, which Z would be needed to conclude).

`OPEN_QUESTIONS`: list of questions with source paths.

## Step 8 — Format output

```
ob:vault-synthesis — "<TOPIC>" (<n> notes scanned)

## Notes found

<for each cluster:>
**<label>** (<n> notes): [[<path1>]], [[<path2>]], ...

## Agreements (<n>)

<for each agreement:>
- "<claim>" — supported by [[<path1>]] ("<quote1>"), [[<path2>]] ("<quote2>")

## Contradictions (<n>)
<if none: "(none found)">

<for each contradiction:>
- [[<pathA>]]: "<quoteA>"
  ↔ [[<pathB>]]: "<quoteB>"
  (newer: [[<newer_path>]])

## Stale claims (<n>)
<if none: "(none found)">

- [[<path>]] (last modified <date>): "<claim excerpt>"

## Open questions (<n>)

- <question> (from [[<path>]])
...
```
