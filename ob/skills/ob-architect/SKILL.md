---
name: ob-architect
description: Scan a codebase and write maintained architecture notes to 01 Atlas/Architecture/. Agent-authored sections are tagged source:agent and enclosed in managed regions so hand edits are preserved on re-runs. Use when starting work on a new codebase or when architecture notes are stale.
---

# ob:architect — Codebase Architecture Notes

Scans a codebase and produces maintained architecture notes in `01 Atlas/Architecture/`. Re-runnable — updates auto-generated managed regions without touching content outside them.

**Write guard:** `01 Atlas/Architecture/` only.

**No blockers** — can run immediately after `ob-setup`.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:architect — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `REPO_PATH`: optional path argument following `/ob:architect`; defaults to the current working directory
- `PROJECT_NAME`: basename of `REPO_PATH` (e.g. `claude-skills`)

Verify `REPO_PATH` is a directory and contains at least one source file (any of: `.js`, `.ts`, `.py`, `.go`, `.rb`, `.rs`, `.java`, `.swift`, `.kt`, `.md`). If not, stop:
```
ob:architect — no source files found at <REPO_PATH>.
```

## Step 2 — Discover codebase structure

From `REPO_PATH`, gather:

**Top-level layout:** list direct subdirectories and root-level files (one level deep).

**Entry points:** `README.md` (first 60 lines), `package.json` / `Cargo.toml` / `pyproject.toml` / equivalent manifest (name, description, main script, scripts).

**Module list:** list all directories that contain source files, sorted by file count (most files first). Cap at 20 modules.

**Key files:** `CLAUDE.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `docs/` (list filenames only).

Read these files using the Read tool. Do not read the full codebase — use only what's listed above.

## Step 3 — Synthesize architecture

From the gathered information, produce:

**Overview** (3–5 sentences): what the project does, its primary users, and its deployment model.

**Module map** (table): for each top-level module — folder path, one-line description of responsibility, estimated file count.

**Key design decisions** (3–7 bullet points): patterns, conventions, or constraints evident from the layout and manifests (e.g. "skills are self-contained directories with a SKILL.md", "no shared state between skills").

**Entry points** (list): primary command or script the user invokes and what it does.

**Open questions** (2–4): architectural aspects that aren't clear from static inspection.

## Step 4 — Write architecture note

`ARCH_FILE`: `$VAULT/01 Atlas/Architecture/<PROJECT_NAME>.md`

**If `ARCH_FILE` does not exist**, create it:

```markdown
---
type: note
source: agent
status: draft
project: <PROJECT_NAME>
created: <DATE>
updated: <DATE>
tags: []
---

# Architecture: <PROJECT_NAME>

<!-- BEGIN ob:architect -->
<!-- END ob:architect -->

## Notes

<!-- hand-edited content below this line is preserved on re-runs -->
```

**If it exists**, read it and update only the managed region.

Replace the entire `<!-- BEGIN ob:architect --> ... <!-- END ob:architect -->` region with:

```
*Last scanned: <DATE> · repo: <REPO_PATH>*

## Overview

<OVERVIEW>

## Module map

| Module | Responsibility | Files |
|--------|---------------|-------|
| <module> | <description> | <n> |
...

## Key design decisions

- <decision 1>
- <decision 2>
...

## Entry points

- `<command>` — <what it does>
...

## Open questions

- <question 1>
- <question 2>
...
```

Update `updated` frontmatter field to today's date.

## Step 5 — Report

```
ob:architect — architecture note written: 01 Atlas/Architecture/<PROJECT_NAME>.md
  Repo: <REPO_PATH>
  Modules scanned: <n>
  Re-run at any time to refresh the managed sections.
```
