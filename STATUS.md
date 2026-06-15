# STATUS

Checkpoint of the `ob` plugin work. Last updated: 2026-06-15.

## Done
- **Plugin scaffolded** at `./ob` (name `ob`, skills-dir/marketplace-installable). Commands namespace to `/ob:*`.
- **`ob-setup` skill complete** (`ob/skills/ob-setup/SKILL.md`): 10 idempotent steps (validate + implement), Quick reference, Target structure, Common mistakes. References bundled files instead of inlining content.
- **Assets extracted** (`ob/assets/`): `vault-CLAUDE.md`, `global-pointer.md`, `Dashboard.md`, `gitignore`, `Tag System.md`, `hotkeys.json`, `launchagents/*.plist.tmpl`, `templates/Daily.md`, `templates/Weekly.md`.
- **Scripts** (`ob/scripts/`): `ob-install.sh` (writes `~/.claude/ob/ob.env`, copies scripts, bootstraps launchd), `ob-daily-rollover.sh` (create today + prune empty previous), `ob-weekly-run.sh` (headless `claude -p "/ob:weekly"`).
- **Marketplace** catalog at `.claude-plugin/marketplace.json` → `./ob`.

## State of the actual vault (`~/Obsidian/MyNotesVault`)
Built by hand in earlier turns, NOT yet via `ob:setup`, so it diverges from the plugin's target:
- Numbered buckets exist: `00 Inbox` … `99 Archives`, plus `06 Daily` not yet created, `05 Resources`/`07 Claude`/`08 Templates` not yet created.
- `04 Areas/` has early MOCs with OLD names: `Work - CRM`, `Keyboards & Peripherals`, `Maker & Electronics`, `Finances & Bitcoin`, `Home Lab & PCs`, `Knowledge System`, plus `Areas - Index.md`.
- `02 Projects/Knowledge System Setup/`, `03 End Products/References/PKM System Guide.md`, `00 Inbox/About Inbox.md` exist.
- Global pointer block is in `~/.claude/CLAUDE.md` (older form; plugin ships a newer one in `assets/global-pointer.md`).
- Legacy `Talent Stream/` (with `Worklog/`) and `Research/`, `Web Clipper/`, `Quick Ref/`, `Study/` are unmigrated.

## Pending
- **Build the other skills**: `ob-weekly` (next — summary + move that week's dailies into `06 Daily/Weeks/YYYY-[W]ww/`), then `ob-capture`, `ob-daily`, `ob-review`, `ob-emerge`, `ob-connect`, `ob-tidy`, `ob-audit`.
- **Remaining templates**: `Note`, `Project Context`, `Area MOC`, `TIL`, `Person`, `Asset`.
- **Run `ob:setup` on the vault** (not done yet). This will reconcile the structure, but:
  - Rename early Area MOCs to the target taxonomy: `Work - CRM` → `Work`; `Keyboards & Peripherals` + `Maker & Electronics` → under `Hobbies/`; `Finances & Bitcoin` → `Finances/` (with `Investments/` + `Bitcoin/`).
  - Migrate `Talent Stream/Worklog/*` into the unified `06 Daily/` (decision below).
  - Move `Research/`, `Web Clipper/`, `YT Transcripts/` → `05 Resources/`.
- **launchd install** only with explicit permission (`ob-install.sh`).
- Old single-skill version parked at `~/.claude/ob-setup.old/` — safe to delete.

## Decisions locked
- Daily notes: ONE life-wide daily note (work + personal together).
- Work area: fold legacy `Talent Stream/` into `04 Areas/Work`, migrate worklogs into `06 Daily/`.
- Plugin name `ob` → commands `/ob:setup`, `/ob:weekly`, etc.
- Daily creation = Periodic Notes; empty-prune + weekly = launchd. Backup = obsidian-git only.
- Tags: structure/state in frontmatter properties; topical `#tags` only, from `Tag System.md` (English, kebab-case, max 2 levels).
- All vault/plugin content in English.

## Open / to confirm
- Confirm `/ob:` namespace naming is acceptable (vs another plugin name).
- `08 Templates/` numbering vs keeping `Templates/` (Templater reconfig cost).

## Next step
Build `ob-weekly` (the weekly summary + dailies-archiving skill).
