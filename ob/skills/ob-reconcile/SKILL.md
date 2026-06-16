---
name: ob-reconcile
description: Find contradictions across 01 Atlas/ and 05 Resources/ notes, propose resolutions, and (with confirmation) update affected notes via managed regions. Use after /ob:health surfaces HIGH-severity contradictions, or after bulk ingestion to maintain vault consistency.
---

# ob:reconcile — Contradiction Detection and Resolution

Scans `01 Atlas/` and `05 Resources/` for conflicting claims, presents a reconciliation report, and (only with explicit confirmation) applies resolutions via managed regions. Exits cleanly if no contradictions are found.

**Write guard:** `01 Atlas/` only — managed-region sections only, never overwrites unmanaged content.

**Depends on:** `ob-synthesize` for the pattern-awareness that makes contradiction detection meaningful.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:reconcile — ob.env not found. Run /ob:setup first.
```

## Step 1 — Discover notes to scan

List all `.md` files in `$VAULT/01 Atlas/` and `$VAULT/05 Resources/` recursively, excluding `99 Archives/` and `08 Templates/`.

`SCAN_NOTES`: resulting list of vault-relative paths.

## Step 2 — Build topic groups

Group notes by shared topic keywords (from filenames, `# H1` headings, and frontmatter `tags`). A note may belong to multiple groups. Only consider groups with ≥ 2 notes.

`TOPIC_GROUPS`: list of `{ topic: string, notes: [paths] }`.

## Step 3 — Detect contradictions

For each topic group, read all notes in the group. Compare factual claims across notes. Flag a contradiction when:
- Two notes make opposing assertions about the same subject (e.g. "X requires Y" vs "X does not require Y")
- A claim in a newer note directly supersedes a claim in an older note without the older note acknowledging the update

For each detected contradiction, record:
- `NOTE_A`: path and the contradicting sentence
- `NOTE_B`: path and the contradicting sentence
- `TOPIC`: the shared subject
- `PROPOSED_RESOLUTION`: which claim is more likely correct (prefer the more recent note; cite evidence if available)

`CONTRADICTIONS`: list of findings.

## Step 4 — Present report

If `CONTRADICTIONS` is empty:
```
ob:reconcile — vault is consistent. No contradictions found across <n> notes.
```
Stop.

Otherwise, print:

```
ob:reconcile — <n> contradiction(s) found

<for each contradiction:>
#<i>. Topic: <TOPIC>
  A: [<NOTE_A path>] "<contradicting sentence A>"
  B: [<NOTE_B path>] "<contradicting sentence B>"
  Proposed resolution: <PROPOSED_RESOLUTION>

Apply resolutions? (yes / no / select <numbers, e.g. 1,3>)
```

Wait for user input before proceeding to Step 5. If the user responds `no`, stop:
```
ob:reconcile — no changes made.
```

## Step 5 — Apply resolutions (with confirmation only)

For each approved contradiction resolution:

In `NOTE_A` (the note whose claim is being superseded), locate or create the managed region:
```
<!-- BEGIN ob:reconcile -->
...
<!-- END ob:reconcile -->
```

Replace the region content with:
```
> **Reconciled <DATE>:** The claim in this note ("...") was superseded by [[<NOTE_B path>]].
> Resolved position: <PROPOSED_RESOLUTION>
```

**Never modify content outside the managed region.** Never delete or rewrite the original contradicting sentence — only add the reconciliation note.

Update `updated` frontmatter field in `NOTE_A` to today's date.

## Step 6 — Report

```
ob:reconcile — <n> contradiction(s) resolved
  <list of updated note paths>
```
