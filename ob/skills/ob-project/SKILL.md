---
name: ob-project
description: Scaffold a new project folder in 02 Projects/ with a _context.md from the Project Context template and update the Projects Index. Use when starting a new delimited piece of work that has a clear "done" condition.
---

# ob:project — Scaffold New Project

Creates `02 Projects/<name>/` with `_context.md` from the Project Context template, then updates `02 Projects/Projects - Index.md`. Idempotent — re-running when the project already exists does not overwrite `_context.md`.

**Write guard:** `02 Projects/` only.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:project — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `PROJECT_NAME`: all text following `/ob:project` (trim whitespace; title-case it)
- `PROJECT_DIR`: `$VAULT/02 Projects/<PROJECT_NAME>/`
- `CONTEXT_FILE`: `$PROJECT_DIR/_context.md`

If `PROJECT_NAME` is empty, prompt once: "What is the name of the project?" then continue.

## Step 2 — Idempotency check

If `CONTEXT_FILE` already exists, stop:
```
ob:project — already exists: 02 Projects/<PROJECT_NAME>/_context.md
  Use /ob:decide or /ob:daily log to update it.
```

## Step 3 — Ask "done" condition (one question only)

Ask: "What does 'done' look like for **<PROJECT_NAME>**?"

Capture the answer as `DONE_CONDITION`. If the user says "skip" or provides no answer within one turn, set `DONE_CONDITION` to `(to be defined)`.

## Step 4 — Create the project folder and _context.md

Create `$PROJECT_DIR` if it does not exist, then write `$CONTEXT_FILE`:

```markdown
---
type: project
status: active
area: ""
created: <DATE>
updated: <DATE>
tags: []
---

# <PROJECT_NAME>

## Goal

<DONE_CONDITION>

## Decisions

<!-- BEGIN ob:decisions -->
<!-- END ob:decisions -->

## Tasks

<!-- BEGIN ob:tasks -->
<!-- END ob:tasks -->

## Log
```

## Step 5 — Update Projects Index

File: `$VAULT/02 Projects/Projects - Index.md`

Locate or create the managed region:
```
<!-- BEGIN ob:projects -->
...
<!-- END ob:projects -->
```

Append inside the region:
```
- [[02 Projects/<PROJECT_NAME>/_context.md|<PROJECT_NAME>]] — <DONE_CONDITION>
```

**Idempotency guard:** if a line for `<PROJECT_NAME>` already exists inside the region, skip.

## Step 6 — Report

```
ob:project — created: 02 Projects/<PROJECT_NAME>/
  Goal: <DONE_CONDITION>
  Index updated: 02 Projects/Projects - Index.md
```
