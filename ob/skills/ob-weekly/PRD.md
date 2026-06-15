# PRD: ob:weekly — Weekly Summary & Daily Archive

## Problem Statement

After a week of writing daily notes in `06 Daily/`, the user has no way to synthesize what happened, and the daily files pile up in the root of `06 Daily/` indefinitely. There is no structured weekly retrospective, no archiving of completed days, and no visibility into open threads carried from one week to the next. The Dashboard's "Last week" panel has nothing to surface because no weekly file exists.

## Solution

A new `/ob:weekly` skill that runs headlessly (via launchd every Sunday at 20:00, or manually at any time) to:

1. Locate the last fully-closed ISO week.
2. Read that week's daily notes and extract tasks, decisions, and narrative.
3. Write a pre-populated weekly summary note at `06 Daily/Weeks/YYYY-[W]ww/week-[W]ww.md`.
4. Move that week's daily files from `06 Daily/` into the same week subfolder.

The Dashboard's existing Dataview query (`## Last week`) automatically surfaces the new file — no additional wiring needed.

## User Stories

1. As a vault user, I want a weekly summary generated automatically on Sunday evening, so that I start Monday with a curated view of last week without manual effort.
2. As a vault user, I want the weekly summary to include a synthesized narrative paragraph, so that I understand the week's themes at a glance rather than re-reading all daily notes.
3. As a vault user, I want completed tasks from the week aggregated into a Done section, so that I have a record of what I accomplished.
4. As a vault user, I want unchecked tasks surfaced in an Open threads section, so that nothing falls through the cracks between weeks.
5. As a vault user, I want a "Next week — top 3" section pre-filled with my oldest unchecked tasks, so that I have a starting point for Monday without triaging from scratch.
6. As a vault user, I want any decisions recorded in my daily notes to appear in the weekly summary with their date, so that I have a dated decision log without re-reading each day.
7. As a vault user, I want the weekly file to use the same frontmatter schema as other vault notes (`type: weekly`, `week`, `created`, `tags`), so that Dataview queries work without special-casing.
8. As a vault user, I want my daily files moved into the week subfolder after the summary is written, so that `06 Daily/` stays clean and only holds the current week's in-progress notes.
9. As a vault user, I want the skill to be fully headless, so that launchd can run it unattended without waiting for input.
10. As a vault user, I want the skill to be idempotent, so that running it twice (e.g. after a system restart) does not overwrite edits I made to the weekly file.
11. As a vault user, I want a stub weekly file created even for weeks with no daily notes, so that the Dashboard and Dataview queries show a complete record with no invisible gaps.
12. As a vault user, I want the skill to operate on ISO weeks (Monday–Sunday), so that "last week" is unambiguous regardless of which day I run it.
13. As a vault user, I want a clear summary report after the skill runs, so that I can confirm what was written and how many files were archived.
14. As a vault user running the skill manually mid-week, I want it to target the last fully-closed ISO week (not the current in-progress one), so that I never accidentally archive today's daily note.
15. As a vault user, I want the Dashboard's "Last week" panel to automatically reflect the new weekly note, so that I don't need to update any configuration after the skill runs.

## Implementation Decisions

- **Week definition**: last fully-closed ISO week (Monday = day 1, Sunday = day 7). "Last closed" means the ISO week whose Sunday has already passed relative to today. Running on any day of the current week always targets the previous week.
- **Folder and file naming**: `06 Daily/Weeks/YYYY-[W]ww/week-[W]ww.md` using the `[W]` literal bracket notation required by Obsidian Periodic Notes (e.g. `2026-[W]24/week-[W]24.md`).
- **Extraction mapping** from daily sections to weekly sections:
  - `## Tasks` checked items (`- [x] …`) → **Done** (deduped by text)
  - `## Tasks` unchecked items (`- [ ] …`) → **Open threads** (deduped by text)
  - `## Decisions` block (entire section, if present) → **Decisions** (prefaced with `**YYYY-MM-DD**`)
  - `## Notes` + `## Log` full text → **Summary** (synthesized paragraph)
  - First 3 items from Open threads → **Next week — top 3**
- **Summary synthesis**: 2–4 sentence narrative paragraph focusing on themes and context, not a restatement of task lists. Empty Notes/Log produces a `<!-- no notes or log entries found for this week -->` comment.
- **Execution order**: write weekly file → move daily files. This ensures synthesis reads from `06 Daily/` before any files are relocated.
- **Idempotency**: if `week-[W]ww.md` already exists, print a "already processed" message and exit without modifying anything.
- **Stub path**: if no daily files exist for the target week, create the week folder and a minimal stub file with a `<!-- no daily notes found for this week -->` comment and all sections blank.
- **Dashboard**: no changes needed — the existing Dataview query in `00 Dashboard.md` (`## Last week`) auto-surfaces the weekly file once it exists in `06 Daily/Weeks/`.
- **Move guard**: skip any daily file already inside a `Weeks/` subfolder to prevent double-moves on partial reruns.
- **Config source**: vault path is read from `~/.claude/ob/ob.env` (`$VAULT`). If absent, the skill exits with an actionable error.
- **Invocation**: headless via `claude -p "/ob:weekly"` from `$VAULT`, orchestrated by `ob-weekly-run.sh` and the `com.ob.weekly` LaunchAgent (installed by `ob-install.sh`).

## Testing Decisions

Skipped for this iteration. The skill will be validated through manual acceptance testing against the live vault once `/ob:setup` has been run.

## Out of Scope

- Weekly notes created by Obsidian's Periodic Notes plugin (disabled by `ob:setup` — weekly notes are owned by this skill only).
- Pushing the vault to a git remote after the weekly run (backup is obsidian-git's responsibility).
- Summarising content from outside `06 Daily/` (Projects, Areas, etc.).
- Editing or re-synthesising a weekly file that already exists.
- Any user interaction or confirmation prompts.
- Support for non-macOS schedulers (launchd is the only supported automation layer).

## Further Notes

- The `ob:weekly` skill is invoked by `ob-weekly-run.sh`, which sources `~/.claude/ob/ob.env` and runs `claude -p "/ob:weekly"` from `$VAULT`. The LaunchAgent fires every Sunday at 20:00 local time.
- The Weekly template (`08 Templates/Weekly.md`) provides the section headings. The skill writes the file directly rather than invoking Templater, since it runs headlessly outside Obsidian.
- Future skills (`ob-review`, `ob-emerge`) may consume the weekly file as input — the frontmatter schema and section headings are intentionally stable contracts.
