---
name: ob-graduate
description: Promote an idea fragment from 00 Inbox/ or 01 Atlas/ into a full project in 02 Projects/ with a _context.md, initial task list, and a link back to the source idea. Use when an idea has matured enough to become a delimited project with a clear done condition.
---

# ob:graduate — Promote Idea to Project

Elevates an idea note to a first-class project: creates `02 Projects/<name>/` with `_context.md` and an initial task list, marks the source note as `status: graduated`, and links both directions. Idempotent — re-running when the project already exists stops safely.

**Write guards:**
- `02 Projects/` — new project folder (uses `ob-project` conventions)
- `00 Inbox/` or `01 Atlas/` — updates `status` frontmatter of the source note only

**Depends on:** `ob-project` (#12) for the project scaffolding conventions.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:graduate — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `SOURCE_REF`: all text following `/ob:graduate` (trim whitespace)

`SOURCE_REF` may be:
- A vault-relative path (e.g. `00 Inbox/2026-06-10-some-idea.md`)
- A note title or partial title (resolve via `/ob:find` logic — take the top match)
- A bare idea description (search for it; if ambiguous, list top 3 matches and ask user to pick)

`SOURCE_FILE`: resolved absolute path to the source note.

If `SOURCE_FILE` cannot be found, stop:
```
ob:graduate — source note not found: "<SOURCE_REF>".
  Try /ob:find <query> to locate the right note.
```

## Step 2 — Read the source note

Read `SOURCE_FILE`. Extract:
- `IDEA_TITLE`: first `# H1` heading or filename slug (title-cased)
- `IDEA_BODY`: full note body
- `CURRENT_STATUS`: frontmatter `status` field

If `CURRENT_STATUS` is already `graduated`, stop:
```
ob:graduate — already graduated: <SOURCE_FILE>
```

## Step 3 — Ask "done" condition (one question)

Ask: "What does 'done' look like for **<IDEA_TITLE>**?"

Capture as `DONE_CONDITION`. If the user says "skip" or provides no answer, set `DONE_CONDITION` to `(to be defined)`.

## Step 4 — Derive initial task list

From `IDEA_BODY`, extract any explicit tasks or "next step" statements. Format each as a checkbox: `- [ ] <task>`. Cap at 5 initial tasks. If none found, leave the task list empty.

`INITIAL_TASKS`: list of checkbox lines.

## Step 5 — Scaffold the project

`PROJECT_NAME`: `IDEA_TITLE` (title-cased, trim whitespace)
`PROJECT_DIR`: `$VAULT/02 Projects/<PROJECT_NAME>/`
`CONTEXT_FILE`: `$PROJECT_DIR/_context.md`

**Idempotency check:** if `CONTEXT_FILE` already exists, stop:
```
ob:graduate — project already exists: 02 Projects/<PROJECT_NAME>/_context.md
```

Create `$PROJECT_DIR/` and write `$CONTEXT_FILE`:

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

> Graduated from: [[<SOURCE_FILE_VAULT_RELATIVE>]]

## Goal

<DONE_CONDITION>

## Tasks

<!-- BEGIN ob:tasks -->
<INITIAL_TASKS>
<!-- END ob:tasks -->

## Decisions

<!-- BEGIN ob:decisions -->
<!-- END ob:decisions -->

## Log
```

Update `$VAULT/02 Projects/Projects - Index.md` — locate or create the managed region `<!-- BEGIN ob:projects --> ... <!-- END ob:projects -->` and append:
```
- [[02 Projects/<PROJECT_NAME>/_context.md|<PROJECT_NAME>]] — <DONE_CONDITION>
```

## Step 6 — Update source note status

In `SOURCE_FILE`, update the frontmatter:
- Set `status: graduated`
- Add or update `project: <PROJECT_NAME>`

Append to the source note body (before any existing content):
```
> **Graduated <DATE>** → [[02 Projects/<PROJECT_NAME>/_context.md]]
```

## Step 7 — Report

```
ob:graduate — promoted: "<IDEA_TITLE>"
  Project created: 02 Projects/<PROJECT_NAME>/_context.md
  Source updated:  <SOURCE_FILE_VAULT_RELATIVE> (status: graduated)
  Initial tasks:   <n>
```
