# PRD: ob:setup — Obsidian Second Brain Setup & Audit

## Problem Statement

Setting up an Obsidian vault as a structured second brain is a multi-layer operation: numbered bucket folders, vault-level and global CLAUDE.md operating rules, a controlled tag vocabulary, eight note templates, eight community plugins with precise configuration, daily/weekly note automation via launchd, a Dataview dashboard, git backup, and workflow skill registration. Doing this manually is slow, error-prone, and not repeatable across machines. Existing vaults diverge from the target over time (ad-hoc folders, unmanaged global pointers, stale plugin configs) with no audit path back to a known-good state.

## Solution

A single Claude Code skill — `ob:setup` — that scaffolds and audits an Obsidian vault in ten idempotent steps. Each step validates first, then implements only what is missing or outdated. The skill works on both fresh vaults and existing ones, preserving content it didn't create and migrating only what it owns (managed regions, ob-slot templates, plugin config). Re-running the skill is safe and converges the vault toward the target structure without data loss.

## User Stories

1. As a new user, I want the skill to ask for my vault path and confirm it is a valid Obsidian vault before doing anything, so that I don't accidentally modify the wrong directory.
2. As a new user, I want the skill to show me a checklist of what is present and what is missing before it makes any changes, so that I understand what will happen.
3. As a new user, I want the skill to create all numbered bucket folders that are absent, so that my vault has the correct lifecycle structure.
4. As a new user, I want the skill to leave any folders it did not create untouched, so that my existing organisation is not disrupted.
5. As a new user, I want unmigrated folders listed explicitly, so that I can decide how to map them into the target structure myself.
6. As a new user, I want a `CLAUDE.md` installed at the vault root with operating rules for Claude Code, so that the agent behaves correctly whenever the vault is the working directory.
7. As a new user, I want the global `~/.claude/CLAUDE.md` updated with a lightweight vault pointer, so that the agent knows where my vault is in any session.
8. As an existing user, I want the vault `CLAUDE.md` to be updated in-place using managed region markers, so that any content I added outside the markers is preserved.
9. As an existing user whose global pointer was written by hand (no markers), I want the skill to replace it automatically with the managed block, so that I don't end up with duplicate vault pointers.
10. As a new user, I want the tag vocabulary installed at `01 Atlas/Tag System.md`, so that both I and the agent have a shared controlled vocabulary for topical tags.
11. As a new user with no templates, I want all eight ob note templates installed (`Note`, `Daily`, `Weekly`, `Project Context`, `Area MOC`, `TIL`, `Person`, `Asset`), so that Templater can scaffold new notes with the correct frontmatter schema.
12. As an existing user with templates, I want only the frontmatter block of each matching template updated to the ob property schema, so that my custom body sections are preserved.
13. As an existing user, I want templates that have no ob equivalent (e.g. `Book.md`, `Course.md`) left completely untouched, so that my non-ob workflow is undisturbed.
14. As an existing user, I want a list of which templates were skipped, so that I know exactly what the skill did not touch.
15. As a new user, I want the skill to attempt community plugin installation via the Obsidian CLI first, so that plugins are installed through the official path when Obsidian is running.
16. As a user without the Obsidian CLI in PATH, I want the skill to fall back to downloading plugin files from GitHub releases, so that setup can complete without requiring the CLI.
17. As a user using the GitHub fallback, I want to be told explicitly to restart Obsidian before continuing, so that the downloaded plugins are loaded correctly.
18. As an existing user, I want the skill to back up each plugin's `data.json` to `~/.claude/ob/backups/<date>/plugins/<id>/data.json` before overwriting it, so that I can recover my previous configuration if something goes wrong.
19. As a new user, I want Periodic Notes configured for daily notes only (weekly disabled), so that `ob:weekly` owns the weekly note lifecycle without conflicts.
20. As a new user, I want to be explicitly asked for permission before any launchd jobs are installed, so that I can choose whether to enable background automation.
21. As a user who declines launchd, I want to know the scripts are available at `~/.claude/ob/` for manual execution, so that I can run them on demand without re-running setup.
22. As a new user who approves launchd, I want both agents (daily rollover and weekly summary) registered and verifiable via `launchctl list | grep com.ob`, so that I can confirm automation is active.
23. As a new user, I want a Dataview dashboard installed at `00 Dashboard.md` and set as the Homepage plugin's opening file, so that my vault opens to a live view of active notes and tasks.
24. As a new user, I want the vault initialised as a git repo with obsidian-git configured for auto-commit every 10 minutes, so that my notes are backed up automatically.
25. As a new user, I want the git remote and first push left to me, so that the skill does not push to a remote without my explicit action.
26. As a user with other backup plugins enabled, I want the skill to recommend disabling them, so that I avoid sync loop conflicts with obsidian-git.
27. As a new user, I want the skill to confirm which `ob:*` workflow skills are loaded under the `/ob:` namespace, so that I know which day-to-day operations are available.
28. As a user whose vault filesystem is inaccessible to the agent, I want the skill to abort immediately with a clear error, so that I know to resolve access before retrying.
29. As a new user, I want an optional hotkey binding step that merges the ob bindings into `.obsidian/hotkeys.json` without dropping existing bindings, so that I can opt in without losing my custom shortcuts.
30. As any user, I want every step to be re-runnable without side effects, so that I can run `ob:setup` again after any partial failure or change.

## Implementation Decisions

- **Relative paths**: all bundled file references in SKILL.md use paths relative to the SKILL.md file itself (e.g. `./assets/vault-CLAUDE.md`). There is no resolved environment variable — the agent derives the skill root from the path at which it read the SKILL.md.

- **Managed regions**: the vault `CLAUDE.md` is governed by `<!-- BEGIN ob --> / <!-- END ob -->` markers; the global pointer block by `<!-- BEGIN ob vault pointer --> / <!-- END ob vault pointer -->`. Steps 2's implement logic is: if markers present → replace region; if legacy unmanaged pointer found → remove it and append managed block; if nothing found → append. Never touch content outside the managed region.

- **Template schema**: all ob templates use Obsidian's Templater plugin syntax (`<% tp.* %>`). Properties are: `type`, `status`, `area`, `project`, `created`, `updated`, `tags`. The `id` and `created_date`/`updated_date` fields from prior templates are dropped — Obsidian's filename is the identifier; Linter manages `updated` on save.

- **Daily template split**: the vault template (`08 Templates/Daily.md`) uses `<% tp.date.now("YYYY-MM-DD") %>` for Obsidian/Periodic Notes. The `ob-daily-rollover.sh` script always writes its own frontmatter inline and never reads the vault template. These are two independent writers with the same output shape, not one template serving two consumers.

- **Plugin install order**: (1) attempt `obsidian plugin:install id=<id> enable` via the Obsidian CLI; (2) on failure or CLI absence, download `main.js` + `manifest.json` + `styles.css` from the plugin's GitHub release into `.obsidian/plugins/<id>/`; (3) always write `data.json` config regardless of install path. GitHub repos are hardcoded in SKILL.md for the eight required plugins.

- **Plugin config backup**: before writing any `data.json`, the existing file is copied to `~/.claude/ob/backups/<YYYY-MM-DD>/plugins/<id>/data.json`. Date-stamped directory so re-runs accumulate rather than overwrite. The user is told the backup path at the end of Step 5.

- **launchd permission gate**: Step 6 must surface an explicit question to the user before executing `./scripts/ob-install.sh`. The script is not run if the answer is no. If no, the user is told the scripts are available at `~/.claude/ob/` for manual use.

- **Filesystem access**: the skill relies entirely on the agent's native filesystem tools. No MCP server is registered. Step 9 validates access by reading `<vault>/CLAUDE.md` directly; failure aborts the skill with a clear error.

- **`08 Templates/` naming**: the target structure uses `08 Templates/`. If the user's vault has a legacy `Templates/` folder, the decision on whether to rename it (and update Templater's `templates_folder` config) is deferred until after the first `ob:setup` run, when the actual Templater `data.json` content is known.

## Testing Decisions

A good test for this skill observes the vault's resulting state — file presence, frontmatter content, plugin config values, launchd registration — not the sequence of agent tool calls. Steps are idempotent, so the post-condition should be identical whether the step ran once or three times.

**Scenarios to cover**:

- **Fresh vault**: all ten steps run to completion; verify all bucket folders, both CLAUDE.md files, all eight templates, all plugin `data.json` files, Dashboard, `.gitignore`, and (with permission) launchd agents are present with correct content.
- **Idempotency**: run `ob:setup` twice on the same vault; the second run makes no changes and reports all steps as already satisfied.
- **Existing vault (partial)**: some buckets exist, some plugins already installed and configured, a legacy global pointer is present. Verify the skill fills gaps without touching what it didn't create, and replaces the legacy pointer.
- **Existing templates**: vault has user templates. Verify only the frontmatter of the 8 ob slots is rewritten, body sections are unchanged, and non-ob templates are untouched.
- **Plugin CLI available**: `obsidian plugin:install` succeeds; verify `data.json` backup is made before config is written.
- **Plugin CLI absent**: fallback download path runs; user is instructed to restart Obsidian.
- **launchd permission declined**: Step 6 runs without calling `ob-install.sh`; scripts are reported as available at `~/.claude/ob/`.
- **Filesystem inaccessible**: Step 9 read fails; skill aborts with an error before making further changes.
- **Global pointer states**: (a) markers present → region replaced; (b) legacy unmanaged pointer → removed and replaced; (c) nothing → block appended.

Prior art: the `ob-daily-rollover.sh` script's idempotency (create only if absent, prune only if empty) is the reference model for validate-then-implement at the script level.

## Out of Scope

- Day-to-day vault operations (`ob:capture`, `ob:daily`, `ob:review`, `ob:tidy`, `ob:audit`, `ob:weekly`, `ob:emerge`, `ob:connect`) — these are separate skills.
- Area MOC content and Area subfolder naming — the target structure shows illustrative defaults; the user decides their own area taxonomy.
- Remote git setup (creating the remote, first `git push`) — the skill provides commands but does not execute them.
- Windows or Linux launchd equivalents — the automation step is macOS-only; other platforms are out of scope for this skill version.
- Vault content migration (renaming legacy MOCs, migrating Worklog into Daily, moving Research/ into Resources/) — these are one-time vault-specific migrations run after `ob:setup`, not part of the skill itself.
- Obsidian MCP server registration — the skill does not configure any MCP server.

## Further Notes

- The `ob-install.sh` script is designed to be invoked from the plugin's `scripts/` directory (its source location), not from the `~/.claude/ob/` copy. The copy is for `ob-daily-rollover.sh` and `ob-weekly-run.sh` only.
- Step 5 hardcodes GitHub repos for the eight required plugins. If a plugin moves repos, the SKILL.md needs a manual update — there is no dynamic registry lookup.
- The `08 Templates/` vs `Templates/` naming decision is explicitly deferred. After the first real `ob:setup` run on the user's vault, the cost of the Templater `templates_folder` reconfig will be visible and the decision can be made with concrete data.
