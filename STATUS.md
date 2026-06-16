# STATUS

Checkpoint of the `ob` plugin work. Last updated: 2026-06-15.

## Done
- **Plugin scaffolded** at `./ob` (name `ob`, skills-dir/marketplace-installable). Commands namespace to `/ob:*`.
- **`ob-setup` skill hardened** (`ob/skills/ob-setup/SKILL.md`): 12 idempotent steps, Quick reference, Target structure, Common mistakes. Audited and fixed in a grill session — see Decisions locked below.
- **`ob-setup` issue #2 complete**: Step 11 (CRITICAL_FACTS.md), Step 12 (Projects Index), updated global-pointer.md and vault-CLAUDE.md reading discipline. CRITICAL_FACTS.md gives ≤2-read navigation to any active project.
- **`ob-weekly` skill complete** (`ob/skills/ob-weekly/SKILL.md`): 8-step headless skill — resolves last closed ISO week, extracts tasks/decisions/narrative from daily notes, synthesizes summary, writes weekly file, archives dailies. Fully idempotent.
- **All 8 templates present** (`ob/skills/ob-setup/assets/templates/`): Daily, Weekly, Note, Person, Asset, TIL, Area MOC, Project Context. Daily uses Templater syntax (`<% tp.date.now() %>`); rollover script writes frontmatter inline independently.
- **Scripts** (`ob/skills/ob-setup/scripts/`): `ob-install.sh` (writes `~/.claude/ob/ob.env`, copies scripts, bootstraps launchd — requires explicit user permission), `ob-daily-rollover.sh` (create today inline + prune empty previous), `ob-weekly-run.sh` (headless `claude -p "/ob:weekly"`).
- **Marketplace** catalog at `.claude-plugin/marketplace.json` → `./ob`.

## State of the actual vault (`~/Obsidian/MyNotesVault`)
Built by hand in earlier turns, NOT yet via `ob:setup`, so it diverges from the plugin's target:
- Numbered buckets exist: `00 Inbox` … `99 Archives`, plus `06 Daily` not yet created, `05 Resources`/`07 Claude`/`08 Templates` not yet created.
- `04 Areas/` has early MOCs with OLD names: `Work - CRM`, `Keyboards & Peripherals`, `Maker & Electronics`, `Finances & Bitcoin`, `Home Lab & PCs`, `Knowledge System`, plus `Areas - Index.md`.
- `02 Projects/Knowledge System Setup/`, `03 End Products/References/PKM System Guide.md`, `00 Inbox/About Inbox.md` exist.
- Global pointer block is in `~/.claude/CLAUDE.md` (older unmanaged form; Step 2 will auto-replace it with the managed block).
- Legacy `Talent Stream/` (with `Worklog/`) and `Research/`, `Web Clipper/`, `Quick Ref/`, `Study/` are unmigrated.
- Vault has 30+ templates in `Templates/` — Step 4 will adapt the 8 ob slots and leave the rest untouched.

## Pending
- **Build the other skills**: `ob-capture`, `ob-daily`, `ob-review`, `ob-emerge`, `ob-connect`, `ob-tidy`, `ob-audit`.
- **Run `ob:setup` on the vault** (not done yet). This will reconcile the structure:
  - Rename early Area MOCs to the target taxonomy: `Work - CRM` → `Work`; `Keyboards & Peripherals` + `Maker & Electronics` → under `Hobbies/`; `Finances & Bitcoin` → `Finances/` (with `Investments/` + `Bitcoin/`).
  - Migrate `Talent Stream/Worklog/*` into the unified `06 Daily/`.
  - Move `Research/`, `Web Clipper/`, `YT Transcripts/` → `05 Resources/`.
- Old single-skill version parked at `~/.claude/ob-setup.old/` — safe to delete.

## Decisions locked
- Daily notes: ONE life-wide daily note (work + personal together).
- Work area: fold legacy `Talent Stream/` into `04 Areas/Work`, migrate worklogs into `06 Daily/`.
- Plugin name `ob` → commands `/ob:setup`, `/ob:weekly`, etc.
- Daily creation = Periodic Notes; empty-prune + weekly = launchd (explicit permission required). Backup = obsidian-git only.
- Tags: structure/state in frontmatter properties; topical `#tags` only, from `Tag System.md` (English, kebab-case, max 2 levels).
- All vault/plugin content in English.
- Bundled file paths are relative to SKILL.md (e.g. `./assets/`), not a resolved env var.
- Plugin install: Obsidian CLI first, GitHub release fallback; always backup `data.json` to `~/.claude/ob/backups/<date>/` before writing.
- No Obsidian MCP — rely on native filesystem access; fail fast if vault is unreachable.
- Daily template uses Templater syntax; rollover script writes frontmatter inline (no shared template format).
- Step 2 global pointer: replace managed region if markers present; auto-replace legacy unmanaged pointer; append if absent.
- Step 4 existing templates: rewrite frontmatter only for the 8 ob slots; leave all other user templates untouched.
- Step 6 launchd: hard stop — must get explicit yes before running `ob-install.sh`.

## Open / to confirm
- `08 Templates/` numbering vs keeping `Templates/` — decide after running `ob:setup` (Templater reconfig cost).

## Next step
Build `ob-capture` (quick capture to `00 Inbox/` with frontmatter tagging) — issue #5.
