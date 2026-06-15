# CLAUDE.md — working context for the `claude-skills` repo

You are continuing development of the `ob` plugin (an Obsidian second-brain toolkit for Claude Code). Read `STATUS.md` first for current progress and the next step.

## What this project is
A Claude Code plugin that sets up and operates an Obsidian vault organized by **lifecycle, not topic** — each folder is a *state* of the material, so both the human and the agent go straight to the right file (also the token-saving mechanism). It merges a creation pipeline (Atlas → Projects → End Products) with PARA's Areas/Resources, plus a developer workflow layer (daily/weekly notes, an agent write-zone, a controlled tag vocabulary).

## Core model (don't re-litigate without reason)
- Buckets: `00 Inbox` (drain to zero) · `01 Atlas` (authored notes/MOCs) · `02 Projects` (active, has a "done", `_context.md`) · `03 End Products` (shipped/reusable) · `04 Areas` (ongoing, one MOC each) · `05 Resources` (captured external reference) · `06 Daily` (one life-wide note/day; `Weeks/`) · `07 Claude` (agent write-zone) · `08 Templates` · `99 Archives`.
- Distinctions: Atlas vs Resources = authored vs captured. Area vs Project = ongoing vs delimited-with-a-done.
- MOCs (Maps of Content) are the navigation + token-saving layer; the agent reads the index → one MOC → 2-3 notes, never whole folders.
- Repo↔vault boundary: the vault may point at a code repo's `.planning/`; a repo NEVER points into the vault.
- Tags: structure/state go in frontmatter properties (`type`,`status`,`area`,`project`); `#tags` are topical only, from `01 Atlas/Tag System.md`.

## Conventions for the plugin (follow these)
- **English only** for all plugin and vault content.
- **Files, not inline**: skills copy bundled files (`assets/`, `scripts/`) referenced via `${CLAUDE_PLUGIN_ROOT}`. Don't embed large content in `SKILL.md`.
- **Idempotent steps**: every setup step is "validate, then implement only what's missing", with managed regions marked by `<!-- BEGIN ob --> / <!-- END ob -->` so re-runs don't clobber user edits.
- **One machine-specific file**: `~/.claude/ob/ob.env` (VAULT + CLAUDE_BIN). Scripts stay generic and live in `~/.claude/ob/` (stable path), copied there by `ob-install.sh`.
- **Commands are namespaced** `/ob:<skill>` (plugin name `ob`).
- **Backup = obsidian-git only.** No PostToolUse auto-commit hook (avoids commit loops).
- **launchd (macOS)** for automation; install only with explicit user permission. Other OSes need an equivalent scheduler.
- **Safety**: don't run `git push`, create remotes, install launchd, or delete data without explicit permission; agent output is quarantined to `07 Claude/`.

## Layout
- `ob/.claude-plugin/plugin.json` — manifest.
- `ob/skills/ob-setup/SKILL.md` — the orchestrator (done). Other `ob/skills/ob-*` are TODO.
- `ob/scripts/` — `ob-install.sh`, `ob-daily-rollover.sh`, `ob-weekly-run.sh`.
- `ob/assets/` — `vault-CLAUDE.md`, `global-pointer.md`, `Dashboard.md`, `gitignore`, `Tag System.md`, `hotkeys.json`, `launchagents/`, `templates/`.
- `.claude-plugin/marketplace.json` — catalog.
- `prd/` — global / cross-skill PRDs.

## When building a new ob-* skill
1. Create `ob/skills/<name>/SKILL.md` (concise frontmatter: name + description; no personal data; shareable/generic).
2. Put any non-trivial content/scripts in `ob/assets/` or `ob/scripts/` and reference via `${CLAUDE_PLUGIN_ROOT}`.
3. Respect the write guards and the schema. Keep it idempotent.
4. Write the skill's PRD to `ob/skills/<name>/PRD.md`. Global / cross-skill PRDs go in `prd/`.
5. Update `STATUS.md`.

## Reference video that started this
Dan Harrison, "I Stopped Building AI Agents and Did This Instead" — file structure as a map of cognitive architecture.
