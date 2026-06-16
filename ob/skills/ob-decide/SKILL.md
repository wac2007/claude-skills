---
name: ob-decide
description: Log a decision to the relevant project note in 02 Projects/. Appends a timestamped entry under a managed Decisions section. Use immediately after making a decision so it's captured before the session ends.
---

# ob:decide — Log a Decision

Appends a timestamped decision to the active project note's managed Decisions region. Append-only — never overwrites previous decisions.

**Write guard:** `02 Projects/` only, managed-region sections only.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:decide — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `DECISION_TEXT`: all text following `/ob:decide` (trim whitespace)

If `DECISION_TEXT` is empty, prompt once: "What decision do you want to log?" then continue.

## Step 2 — Identify the target project

Read `$VAULT/CRITICAL_FACTS.md` for the active project. Cross-reference with the current conversation topic.

Fallback: read `$VAULT/02 Projects/Projects - Index.md` and pick the project most relevant to the conversation context.

`PROJECT_NOTE`: `$VAULT/02 Projects/<project>/_context.md`

If no project can be identified with confidence, ask once: "Which project should this decision go to?" Accept a folder name or partial match. If still unresolved, write to `$VAULT/07 Claude/decide-<DATE>.md` and report the fallback path.

## Step 3 — Append the decision

In `PROJECT_NOTE`, locate the `## Decisions` section. Find or create the managed region:
```
<!-- BEGIN ob:decisions -->
...
<!-- END ob:decisions -->
```

Append inside the region:
```
- **<YYYY-MM-DD HH:MM>** <DECISION_TEXT>
```

**Idempotency guard:** if a line with the exact `DECISION_TEXT` already exists inside the managed region, skip and report "already logged".

## Step 4 — Report

```
ob:decide — logged to 02 Projects/<project>/_context.md
  Decision: <DECISION_TEXT>
```
