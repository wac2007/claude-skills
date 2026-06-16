---
name: ob-projects
description: Live status view of all active projects — combines vault _context.md frontmatter with recent git commit activity. Read-only. Use at the start of a session to see what's in flight.
---

# ob:projects — Live Project Status

Lists all active projects by reading `02 Projects/` vault notes and, where applicable, correlating with git repo activity. Read-only — no vault files modified.

**No vault files modified.**

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:projects — ob.env not found. Run /ob:setup first.
```

## Step 1 — Discover projects

List all immediate subdirectories of `$VAULT/02 Projects/` (not recursive). For each directory `<project>/` that contains a `_context.md` file, add it to the project list.

## Step 2 — Read project metadata

For each project, read `$VAULT/02 Projects/<project>/_context.md` and extract:
- `STATUS`: frontmatter `status` field (default: `active`)
- `AREA`: frontmatter `area` field (default: blank)
- `UPDATED`: frontmatter `updated` field
- `GOAL`: content of the `## Goal` section (first line only, truncated to 60 chars)

Skip projects where `status` is `archived` or `done` unless `--all` flag is present.

## Step 3 — Check git activity (best-effort)

Read `$VAULT/CRITICAL_FACTS.md` or `$VAULT/02 Projects/<project>/_context.md` for a `repo:` field that maps the project to a local git path.

For each project with a known repo path:
- Run `git -C <repo_path> log --oneline -3 --since="30 days ago"` to get recent commits
- Run `git -C <repo_path> branch --show-current` to get the current branch
- Store as `RECENT_COMMITS` (list of up to 3 one-liners) and `BRANCH`

If the repo path is unknown or git fails, mark git fields as `—`.

## Step 4 — Format output

```
ob:projects — <n> active project(s)

┌─────────────────────────────────────────────────────────────┐
│ Project              Status   Updated     Goal               │
├─────────────────────────────────────────────────────────────┤
│ <name>               <status> <updated>   <goal>             │
│   git: <branch> · <commit1>              │
│         <commit2>                        │
│ ...                                      │
└─────────────────────────────────────────────────────────────┘
```

If no projects found: `No active projects in 02 Projects/.`

Append note if `--all` was not passed and any archived projects were skipped:
```
(archived/done projects hidden — pass --all to include them)
```
