---
name: ob-review
description: Structured weekly or monthly review — surfaces open tasks, pending decisions, and prompts for next-period priorities. Writes a review note to 06 Daily/Weeks/ or 06 Daily/Months/. Use at the end of a week or month to close loops and set direction.
---

# ob:review — Structured Period Review

Runs a structured review by building on `/ob:recap` output, then adding open-task triage, decision log review, and next-period priorities. Writes a review note. Re-running updates the existing review note rather than creating a duplicate.

**Write guard:** `06 Daily/` only (subfolder `Weeks/` or `Months/`).

**Depends on:** `ob-recap` for the summary layer.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:review — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

Period argument (optional):
- `/ob:review` or `/ob:review week` → weekly review (last 7 days)
- `/ob:review month` → monthly review (last 30 days)

`PERIOD`: `week` | `month`

For **week**: determine ISO week of today → `YYYY-[W]ww` (e.g. `2026-W24`)
For **month**: determine current year-month → `YYYY-MM` (e.g. `2026-06`)

`REVIEW_DIR`:
- week → `$VAULT/06 Daily/Weeks/<YYYY-[W]ww>/`
- month → `$VAULT/06 Daily/Months/<YYYY-MM>/`

`REVIEW_FILE`: `$REVIEW_DIR/review.md`

## Step 2 — Generate recap layer

Execute the logic of `/ob:recap` for the matching period (last 7 days for week, last 30 for month) and capture its output as `RECAP_OUTPUT`. Do not print the recap separately — it will be embedded in the review note.

## Step 3 — Collect open tasks

Scan all project `_context.md` files in `$VAULT/02 Projects/` for incomplete task checkboxes (`- [ ] <text>`) inside `<!-- BEGIN ob:tasks --> ... <!-- END ob:tasks -->` regions. Also scan all daily notes in the period for `- [ ] <text>` lines.

`OPEN_TASKS`: deduplicated list of incomplete task texts with their source path.

## Step 4 — Collect pending decisions

Scan daily notes in the period for lines containing "TBD", "to decide", "open question", "pending" — extract as `PENDING_ITEMS`.

## Step 5 — Prompt for next-period priorities (one interaction)

Ask: "What are your top 3 priorities for the coming <week|month>?"

Accept the answer as `PRIORITIES`. If the user says "skip", set `PRIORITIES` to `(not set)`.

## Step 6 — Write review note

Create `$REVIEW_DIR/` if absent.

**If `REVIEW_FILE` already exists**, overwrite only the managed region (see below). Update `updated` frontmatter.

**If it does not exist**, write `$REVIEW_FILE`:

```markdown
---
type: review
period: <PERIOD>
period_key: <YYYY-[W]ww or YYYY-MM>
created: <DATE>
updated: <DATE>
tags: []
---

# Review: <YYYY-[W]ww or YYYY-MM>

<!-- BEGIN ob:review -->
<!-- END ob:review -->
```

Replace the entire managed region `<!-- BEGIN ob:review --> ... <!-- END ob:review -->` with:

```
*Generated: <DATE>*

## Recap

<RECAP_OUTPUT (stripped of its header line)>

## Open tasks (<n>)

<for each task:>
- [ ] <task text> ← [[<source path>]]

## Pending decisions (<n>)

<for each pending item:>
- <item>

## Priorities for next <week|month>

1. <priority 1>
2. <priority 2>
3. <priority 3>
```

## Step 7 — Report

```
ob:review — <PERIOD> review written: 06 Daily/<Weeks|Months>/<key>/review.md
  Open tasks: <n>
  Pending decisions: <n>
```
