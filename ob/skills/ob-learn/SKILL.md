---
name: ob-learn
description: Review vault learnings (TILs and retrospective insights), identify stale ones (>180 days), flag those that contradict current practice, and surface patterns ready to be promoted to Atlas principles. Produces a triage report — no auto-deletion. Read-only unless user confirms a promotion.
---

# ob:learn — Learning Review and Promotion

Audits `01 Atlas/TILs/` and all notes with `type: til` for staleness, contradiction with current practice, and promotion readiness. Produces a triage report. No notes deleted or modified without explicit user confirmation.

**Write guard (optional):** `01 Atlas/` only, with explicit user confirmation per promotion.

**Depends on:** `ob-emerge` (#21) for the pattern-awareness that identifies promotion candidates.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:learn — ob.env not found. Run /ob:setup first.
```

## Step 1 — Collect learnings

List all `.md` files in:
- `$VAULT/01 Atlas/TILs/`
- Any note in `$VAULT/01 Atlas/` with frontmatter `type: til`

`LEARNINGS`: list of `{ path, title, created, last_modified, body }`.

If no learnings found:
```
ob:learn — no TIL notes found in 01 Atlas/TILs/ or with type: til.
  Capture learnings with /ob:capture then move them to 01 Atlas/TILs/.
```
Stop.

## Step 2 — Identify stale candidates

A learning is stale if `last_modified` is more than 180 days ago. Stale does not mean wrong — it means it hasn't been revisited and may need validation.

`STALE`: list of stale learnings sorted by age (oldest first).

## Step 3 — Identify contradiction candidates

For each learning, search the vault (Atlas notes, ADRs, recent daily logs) for content that contradicts the learning's core claim. A contradiction is:
- A project decision (ADR) that reversed a practice the TIL advocates
- A newer TIL that asserts the opposite
- A `## Log` entry describing a failure caused by following the TIL's advice

`CONTRADICTION_CANDIDATES`: list of `{ learning_path, contradicting_path, evidence_quote }`.

## Step 4 — Identify promotion candidates

A learning is ready to promote to a standing Atlas principle when:
- It has been valid and uncontradicted for more than 90 days
- The same insight appears in 2+ different TIL notes (clustering signal from ob-emerge logic)
- It is referenced in at least 1 project decision or daily log

`PROMOTION_CANDIDATES`: list of learnings meeting 2 or more of these criteria.

## Step 5 — Format triage report

```
ob:learn — learning review (<n> TILs scanned)

## Stale candidates (<n>) — not visited in 180+ days
<if none: "(none)">
- [[<path>]] (<n> days old): "<title>"
  Action options: mark reviewed (update date), archive, or delete

## Contradiction candidates (<n>) — may be outdated by current practice
<if none: "(none)">
- [[<learning_path>]]: "<claim>"
  ↔ Contradicted by [[<contradicting_path>]]: "<evidence_quote>"

## Promotion candidates (<n>) — ready to become Atlas principles
<if none: "(none)">
- [[<path>]]: "<title>"
  Evidence: <why this is ready (age, clustering, citations)>

Promote any of these? Enter numbers (e.g. 2,3) or press Enter to skip.
```

## Step 6 — Promote to Atlas principle (only if confirmed)

For each confirmed promotion candidate:

`PRINCIPLE_SLUG`: lowercase title, spaces → `-`, strip non-alphanumeric-or-dash.
`PRINCIPLE_FILE`: `$VAULT/01 Atlas/Principles/<PRINCIPLE_SLUG>.md`

If `PRINCIPLE_FILE` already exists, append to its body. Otherwise create:

```markdown
---
type: note
status: active
source: promoted-from-til
created: <DATE>
updated: <DATE>
tags: []
---

# <Title>

<Learning body>

## Source TILs

- [[<original TIL path>]]

## Notes

<!-- hand-edited content below this line -->
```

Update the original TIL note's frontmatter: set `status: promoted` and add `promoted_to: [[01 Atlas/Principles/<PRINCIPLE_SLUG>]]`.

Report each promotion:
```
ob:learn — promoted to Atlas principle: 01 Atlas/Principles/<PRINCIPLE_SLUG>.md
```
