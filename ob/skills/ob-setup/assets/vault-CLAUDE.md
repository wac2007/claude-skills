<!-- BEGIN ob (managed; edit outside these markers) -->
# Vault Operating Rules — read before acting in the vault

Owner role: {{ROLE}}. Output language: {{LANG}}.

## Buckets — what goes where
- `00 Inbox/` — unprocessed capture. Must tend to zero.
- `01 Atlas/` — notes I AUTHORED: evergreen notes, MOCs, distilled knowledge.
- `02 Projects/` — active builds with a defined "done"; each has `_context.md`.
- `03 End Products/` — shipped, reusable artifacts (runbooks, build logs, configs).
- `04 Areas/` — ongoing responsibilities, no end date; one MOC each.
- `05 Resources/` — EXTERNAL reference I captured but did not author.
- `06 Daily/` — one life-wide daily note per day; `Weeks/` holds weekly summaries.
- `07 Claude/` — agent write-zone (analyses/drafts).
- `99 Archives/` — dead/paused.

Atlas vs Resources = authored vs captured. Area vs Project = ongoing vs delimited-with-a-done.

## Write guards
- READ everything EXCEPT `99 Archives/` (only when explicitly asked).
- WRITE only to `00 Inbox/` and `07 Claude/`. Automation may write `06 Daily/`.
- EDIT existing notes only with explicit per-turn permission. Never bulk-edit silently.
- Promote, don't mutate: generated output goes to `07 Claude/`; the human promotes it.
- One-way links: the vault may point at a code repo; a repo never points into the vault.

## Reading discipline (saves context)
- Start at `04 Areas/Areas - Index.md` -> open the ONE relevant MOC -> follow links to 2-3 notes.
- Never scan whole folders. Prefer the exact path given.

## Metadata schema (properties, not structural tags)
- `type`: note|moc|project|area|reference|daily|weekly|til|person|asset|runbook|build-log
- `status`: inbox|idea|active|shipped|archived
- `area`: "[[Area MOC]]"  · `project`: "[[project]]"  · `created`/`updated`: YYYY-MM-DD
- `tags`: topical only, drawn from `01 Atlas/Tag System.md`.

## Commands (ob plugin skills)
ob:setup · ob:weekly · ob:capture · ob:daily · ob:review · ob:emerge · ob:connect · ob:tidy · ob:audit

## How this file loads
Claude Code loads this only when the vault is the working directory. The lightweight
pointer in `~/.claude/CLAUDE.md` is what loads in other sessions.
<!-- END ob -->
