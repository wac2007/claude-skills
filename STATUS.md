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

## Wave 1 skills — complete (2026-06-16)
- **`ob-capture`** (`ob/skills/ob-capture/SKILL.md`): zero-friction `00 Inbox/` capture with frontmatter. Idempotent filename (date-slug).
- **`ob-find`** (`ob/skills/ob-find/SKILL.md`): smart vault search with recency+relevance scoring. Read-only. Excludes `99 Archives/` by default.
- **`ob-daily`** (`ob/skills/ob-daily/SKILL.md`): creates `06 Daily/YYYY-MM-DD.md` from Daily template; `/ob:daily log <text>` appends to `## Log`. Idempotent.
- **`ob-world`** (`ob/skills/ob-world/SKILL.md`): L0–L3 progressive context engine. L0=CRITICAL_FACTS.md, L1=+project _context.md, L2=+area MOC+last 3 dailies, L3=full Atlas+Resources.
- **`ob-save`** (`ob/skills/ob-save/SKILL.md`): extracts decisions/tasks/people from current conversation, writes to managed regions in project note. Idempotent. Ambiguous → `07 Claude/`.
- **Issue #3 done**: root README.md has Inspiration section.
- **Marketplace updated**: all 5 new skills added to `.claude-plugin/marketplace.json`.

## Wave 2 skills — complete (2026-06-16)
- **`ob-person`** (#10): create/update person note in `01 Atlas/People/` using Person template. Idempotent (update if exists).
- **`ob-decide`** (#11): append timestamped decision to active project's managed Decisions region. Append-only.
- **`ob-project`** (#12): scaffold `02 Projects/<name>/` with `_context.md` + managed regions; updates Projects Index. One-question "done" condition.
- **`ob-projects`** (#13): live project table from `_context.md` frontmatter + git activity. Read-only.
- **`ob-ingest`** (#14): fetch URL/PDF/audio → write to `05 Resources/`, update 5–15 related `01 Atlas/` notes via managed regions. Idempotent.
- **`ob-synthesize`** (#15): cluster recent Resources+Atlas notes → write/update synthesis pages in `01 Atlas/Synthesis/`. `source: agent` tagged. Idempotent.
- **`ob-reconcile`** (#16): detect contradictions across Atlas+Resources, propose resolutions, apply only with confirmation. Managed-region writes only.
- **`ob-recap`** (#17): on-demand day/week/month summary from daily notes. Read-only.
- **`ob-review`** (#18): structured week/month review — recap + open tasks + pending decisions + next-period priorities. Writes to `06 Daily/Weeks/` or `06 Daily/Months/`.
- **`ob-health`** (#19): vault audit — HIGH(contradictions), MEDIUM(stale), LOW(orphans, missing frontmatter). Read-only.
- **`ob-adr`** (#20): create dated ADR in `02 Projects/<project>/adr/` and backlink in `_context.md`. Idempotent.
- **Marketplace updated**: all 11 new skills added to `.claude-plugin/marketplace.json`.

## Wave 3–4 skills — complete (2026-06-16)
- **`ob-architect`** (#9): scan codebase → write `01 Atlas/Architecture/<project>.md` with managed region. Re-run refreshes auto-generated sections; preserves hand-edited content below the region.
- **`ob-emerge`** (#21): scan last 30 days of Daily/Inbox/Atlas → surface 3–7 unnamed patterns with evidence quotes. Optional promotion to Atlas note with confirmation.
- **`ob-connect`** (#22): find 3–5 structural bridges between two named domains using vault notes. Cites one note from each domain per bridge. Read-only.
- **`ob-challenge`** (#23): generate 3–5 vault-grounded counter-arguments against a proposed idea using past decisions, failures, and principles. Sorted strongest-first. Read-only.
- **`ob-vault-synthesis`** (#25): deep cross-reference of all vault notes on a topic → agreements, contradictions, stale claims, open questions. All findings cite note paths. Read-only.
- **`ob-graduate`** (#27): promote inbox/Atlas idea → `02 Projects/<name>/` with `_context.md` + task list; marks source note `status: graduated`. Bidirectional links.
- **`ob-panel`** (#24): 3–5 named perspective roles (Skeptic, Pragmatist, etc.) each grounded in vault notes → synthesis with final recommendation. Read-only.
- **`ob-idea-discovery`** (#26): rank 3–5 next-direction candidates by composite score (recency, backlinks, project alignment, emergence signal). Read-only.
- **`ob-learn`** (#28): audit TILs → stale candidates (>180 days), contradiction candidates, promotion candidates. Optional promotion to `01 Atlas/Principles/` with confirmation.
- **Marketplace updated**: all 9 new skills added to `.claude-plugin/marketplace.json`.

## Vault status (2026-06-16)
- **`ob:setup` run**: all 12 steps validated. Daily.md template patched (`status:` field added). Linter now ignores `08 Templates/`. Both launchd agents registered.
- **`ob:health` run**: 112 notes audited — 1 HIGH (empty ghost `data replication.md`), 68 MEDIUM (stale Computing Concepts notes from 2024), 100 LOW orphans (no MOC), 99 LOW missing frontmatter (pre-ob notes). All expected and understood.
- **GitHub issues**: all 21 issues closed (#1, #9–#28). Repository at `wac2007/claude-skills` has 0 open issues.
- **Optional remaining hygiene**: create `01 Atlas/Computing Concepts.md` MOC; migrate `Study/` into ob buckets; move 4 SVGZ files from vault root.

## Pending
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
All 28 skills from issue #1 are implemented. Run `ob:setup` on the actual vault to apply the structure and smoke-test the skills end-to-end.
