---
name: ob-adr
description: Create a lightweight Architecture Decision Record in the current project. Captures context, decision, and consequences as a dated file in 02 Projects/<project>/adr/. Use when making a significant technical or design choice you want to reconstruct later.
---

# ob:adr — Architecture Decision Record

Creates a dated ADR file under `02 Projects/<project>/adr/` and updates the project's managed Decisions section with a backlink. Idempotent — re-running with the same title does not create a duplicate.

**Write guard:** `02 Projects/` only.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:adr — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `TITLE`: all text following `/ob:adr` (trim whitespace)

If `TITLE` is empty, prompt once: "What is the decision title?" then continue.

## Step 2 — Identify the target project

Read `$VAULT/CRITICAL_FACTS.md` for the active project. Cross-reference with conversation context. Fallback: read `$VAULT/02 Projects/Projects - Index.md`.

`PROJECT_DIR`: `$VAULT/02 Projects/<project>/`
`ADR_DIR`: `$PROJECT_DIR/adr/`

If no project can be identified, ask once: "Which project is this ADR for?"

## Step 3 — Derive ADR number and filename

List existing files in `$ADR_DIR` matching `ADR-NNN-*.md`. Take the highest existing number + 1. If none exist, start at `001`.

`ADR_NUM`: zero-padded three-digit number (e.g. `001`, `012`)
`SLUG`: lowercase `TITLE`, spaces → `-`, strip non-alphanumeric-or-dash, truncate at 50 chars
`ADR_FILE`: `$ADR_DIR/ADR-<ADR_NUM>-<SLUG>.md`

## Step 4 — Idempotency check

If any file in `$ADR_DIR` has a slug matching `<SLUG>`, stop:
```
ob:adr — already exists: 02 Projects/<project>/adr/ADR-<num>-<SLUG>.md
```

## Step 5 — Gather context (interactive, max 3 questions)

Ask in sequence, accepting a blank answer to skip:
1. "What is the context / problem being solved?"
2. "What are the main alternatives considered?"
3. "What are the consequences (positive and negative)?"

Store as `CONTEXT`, `ALTERNATIVES`, `CONSEQUENCES`.

## Step 6 — Write the ADR file

Create `$ADR_DIR/` if absent. Write `$ADR_FILE`:

```markdown
---
type: adr
status: accepted
project: <project folder name>
created: <DATE>
tags: []
---

# ADR-<ADR_NUM>: <TITLE>

**Date:** <DATE>
**Status:** Accepted

## Context

<CONTEXT, or "(not provided)">

## Decision

<TITLE>

## Alternatives considered

<ALTERNATIVES, or "(not provided)">

## Consequences

<CONSEQUENCES, or "(not provided)">
```

## Step 7 — Update project _context.md Decisions region

In `$PROJECT_DIR/_context.md`, find or create the managed region:
```
<!-- BEGIN ob:decisions -->
...
<!-- END ob:decisions -->
```

Append inside the region:
```
- **<DATE>** ADR-<ADR_NUM>: [[02 Projects/<project>/adr/ADR-<ADR_NUM>-<SLUG>|<TITLE>]]
```

**Idempotency guard:** skip if a line referencing `ADR-<ADR_NUM>` already exists.

## Step 8 — Report

```
ob:adr — created: 02 Projects/<project>/adr/ADR-<ADR_NUM>-<SLUG>.md
  Linked in: 02 Projects/<project>/_context.md
```
