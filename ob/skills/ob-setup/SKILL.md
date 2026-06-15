---
name: ob-setup
description: Set up and validate an Obsidian vault as a structured second brain — scaffolds the bucket folders, write guards, metadata schema, tag vocabulary, templates, dashboard, backup, and daily/weekly note automation. Use for a fresh vault or to audit and complete an existing one. Setup only; day-to-day workflows live in separate ob:* skills.
---

# ob:setup — Obsidian Second Brain (Setup & Audit)

Scaffolds and validates an Obsidian vault organized by **lifecycle, not topic**: each folder is a *state* of the material, so humans and AI agents go straight to the right file. This skill only builds and checks the system; the operational reference lives in the vault's own `CLAUDE.md`, which this skill installs. Day-to-day actions are separate `ob:*` skills.

Bundled files are referenced via paths relative to this SKILL.md file (e.g. `./assets/vault-CLAUDE.md`). Substitute `{{ROLE}}`, `{{LANG}}`, `{{VAULT}}` at write time. Each step is **idempotent**: validate first, implement only what is missing.

## When to use
- Bootstrapping a new vault, or auditing/completing an existing one.
- (Re)installing the vault `CLAUDE.md`, tag dictionary, dashboard, templates, or automation.

## Quick reference

| Layer | Components | Source |
| --- | --- | --- |
| Structure | numbered buckets, `_context.md` per project, `00 Dashboard.md` | this skill |
| Operating rules | vault `CLAUDE.md` + global pointer | `assets/vault-CLAUDE.md`, `assets/global-pointer.md` |
| Metadata | frontmatter properties (`type`,`status`,`area`,`project`) | embedded in `CLAUDE.md` |
| Tags | controlled English vocabulary | `assets/Tag System.md` |
| Templates | note, daily, weekly, project, area MOC, TIL, person, asset | `assets/templates/` |
| Plugins | Dataview, Templater, Periodic Notes, Tasks, Calendar, Linter, obsidian-git, Homepage | Step 5 |
| Dashboard | Dataview homepage | `assets/Dashboard.md` |
| Backup | obsidian-git only | `assets/gitignore` |
| Automation | daily rollover + weekly summary (launchd) | `scripts/`, `assets/launchagents/` |
| Hotkeys | optional bindings | `assets/hotkeys.json` |
| Commands | `ob:*` workflow skills | `skills/` |

## Target structure

```
<vault>/
├── 00 Inbox/              # unprocessed capture; MUST tend to zero
├── 01 Atlas/              # notes I AUTHORED: evergreen notes, MOCs
│   └── Tag System.md
├── 02 Projects/           # active builds; each has _context.md
├── 03 End Products/        # shipped & reusable
├── 04 Areas/              # ongoing responsibilities (one MOC each)
│   ├── Areas - Index.md
│   ├── Work/                   # work stuff (repos, meetings, decisions)
│   ├── Dev/                    # + Dev/TILs/
│   ├── Finances/               # Investments/ + Bitcoin/
│   ├── Hobbies/  ├── People/  └── Home Lab & PCs/
├── 05 Resources/          # EXTERNAL captured reference
├── 06 Daily/              # one life-wide daily note: YYYY-MM-DD.md
│   └── Weeks/YYYY-[W]ww/week-[W]ww.md   # weekly summary; that week's dailies move in
├── 07 Claude/             # AGENT WRITE-ZONE
├── 08 Templates/
├── 99 Archives/           # not read unless explicitly asked
├── 00 Dashboard.md
└── CLAUDE.md
```
Area subfolders are illustrative defaults — adapt to the user's responsibilities.

## Setup steps

### Step 0 — Detect context
Ask for the vault's absolute path; confirm `.obsidian/` exists. Inspect what's present: numbered buckets, `<vault>/CLAUDE.md`, `~/.claude/CLAUDE.md`, `.obsidian/community-plugins.json`, templates. Build a present-vs-missing checklist. **Never assume a file exists.**

### Step 1 — Buckets
- **Validate**: do the numbered buckets exist?
- **Implement**: create the missing folders. Don't touch unrelated existing folders; list them for the user to map later.

### Step 2 — Operating rules (`CLAUDE.md`)
- **Validate**: does `<vault>/CLAUDE.md` contain the `BEGIN/END ob` block? Does `~/.claude/CLAUDE.md` contain the `ob vault pointer` block?
- **Implement (vault)**: copy `./assets/vault-CLAUDE.md` into `<vault>/CLAUDE.md`, substituting `{{ROLE}}`/`{{LANG}}`. If the file exists, replace only the region between the markers.
- **Implement (global)**: read `~/.claude/CLAUDE.md` and apply `./assets/global-pointer.md` with `{{VAULT}}` substituted:
  - Markers present (`<!-- BEGIN ob vault pointer -->`) → replace the region.
  - Markers absent but a vault path or `Vault root:` line found → remove those lines, append the managed block.
  - No pointer at all → append the managed block.
  Never clobber content outside the managed region.

### Step 3 — Tag vocabulary
- **Validate**: does `01 Atlas/Tag System.md` exist? Are notes using frontmatter properties?
- **Implement**: copy `./assets/Tag System.md` → `01 Atlas/Tag System.md`. The property schema is documented in the vault `CLAUDE.md` (Step 2).

### Step 4 — Templates (conditional)
- **Validate**: do `08 Templates/{Note,Daily,Weekly,Project Context,Area MOC,TIL,Person,Asset}.md` exist?
- **Implement (fresh vault)**: copy the set from `./assets/templates/` into `08 Templates/`.
- **Implement (existing templates)**: if the user has templates and prefers to keep them, adapt only the 8 ob slots — do not touch anything else:
  1. Rewrite the frontmatter block of each matching template to use the ob property schema (`type`, `status`, `area`, `project`, `created`, `updated`, `tags`). Leave all body sections intact.
  2. Map the user's templates to ob slots by name/purpose; ask if ambiguous.
  3. Templates with no ob equivalent (e.g. `Book.md`, `Course.md`, `Quote File.md`) are left untouched. List them so the user knows they were skipped.

### Step 5 — Plugins
- **Validate**: read `.obsidian/community-plugins.json` and each `.obsidian/plugins/<id>/data.json`; mark installed / enabled / configured.
- **Implement (install)**: for each missing plugin, attempt install in order:
  1. **CLI path** (preferred): check `obsidian plugin:install id=<id> enable`. If `obsidian` is not in PATH or returns an error, fall back.
  2. **Fallback**: download `main.js`, `manifest.json`, and `styles.css` (if present) from the plugin's GitHub release into `.obsidian/plugins/<id>/`. Add the id to `community-plugins.json`. Tell the user to restart Obsidian before continuing.
  - GitHub repos for each plugin: `blacksmithgu/obsidian-dataview`, `SilentVoid13/Templater`, `liamcain/obsidian-periodic-notes`, `obsidian-tasks-group/obsidian-tasks`, `liamcain/obsidian-calendar-plugin`, `platers/obsidian-linter`, `Vinzent03/obsidian-git`, `mirnovov/obsidian-homepage`.
- **Implement (backup)**: before writing any `data.json`, copy the existing file to `~/.claude/ob/backups/<YYYY-MM-DD>/plugins/<id>/data.json`. Create the directory if absent. Skip if the file doesn't exist yet. Tell the user where the backup lives.
- **Implement (config)**: write `data.json` for each plugin regardless of install path:

| Plugin | id | Key config |
| --- | --- | --- |
| Dataview | `dataview` | `enableDataviewJs: true`, `defaultDateFormat: "yyyy-MM-dd"` |
| Templater | `templater-obsidian` | `templates_folder: "08 Templates"`, `trigger_on_file_creation: true`, folder templates (below) |
| Periodic Notes | `periodic-notes` | daily enabled (Step 6); weekly disabled |
| Tasks | `obsidian-tasks-plugin` | default |
| Calendar | `calendar` | `shouldConfirmBeforeCreate: true` |
| Linter | `obsidian-linter` | `lintOnSave: true`; YAML timestamp on `updated`; ignore `08 Templates` |
| obsidian-git | `obsidian-git` | Step 8 |
| Homepage | `homepage` | Step 7 |

Templater folder templates (`data.json` → `folder_templates`): `06 Daily`→Daily, `02 Projects`→Project Context, `04 Areas`→Area MOC, `04 Areas/Dev/TILs`→TIL, `04 Areas/People`→Person, `01 Atlas`/`05 Resources`→Note.

### Step 6 — Daily & weekly automation
Daily creation = Periodic Notes. Empty-day pruning + weekly summary = launchd, installed by one script.
- **Validate**: Periodic Notes daily config present? `~/.claude/ob/ob.env` present and `launchctl list | grep com.ob` shows both agents?
- **Implement (Periodic Notes)** (`.obsidian/plugins/periodic-notes/data.json`): `{ "daily": { "enabled": true, "format": "YYYY-MM-DD", "folder": "06 Daily", "template": "08 Templates/Daily" }, "weekly": { "enabled": false } }`. Weekly notes are made by `ob:weekly`, not Periodic Notes.
- **Implement (automation)**: ask the user: "May I install the daily rollover and weekly summary as launchd jobs? This registers two background agents that run automatically." **Do not run `./scripts/ob-install.sh` until the user explicitly says yes.** If yes, run `./scripts/ob-install.sh "<vault>"`; it writes `~/.claude/ob/ob.env`, copies scripts to `~/.claude/ob/`, renders the plists, and bootstraps both LaunchAgents. If no, skip — the scripts can be run manually from `~/.claude/ob/`.
- `ob:weekly` writes `06 Daily/Weeks/YYYY-[W]ww/week-[W]ww.md`, then moves that week's daily notes into the same folder and posts a digest to the Dashboard. This step only schedules it (Sundays 20:00) and guarantees the folder convention.

### Step 7 — Dashboard
- **Validate**: does `00 Dashboard.md` exist, and does Homepage point to it?
- **Implement**: copy `./assets/Dashboard.md` → `<vault>/00 Dashboard.md`. Set Homepage (`.obsidian/plugins/homepage/data.json`): `{ "defaultHomepage": "00 Dashboard", "openOnStartup": true, "view": "Reading view" }`.

### Step 8 — Backup (one tool: obsidian-git)
- **Validate**: is the vault a git repo with a remote and obsidian-git auto-committing?
- **Implement**: copy `./assets/gitignore` → `<vault>/.gitignore`. `git init` if absent; configure obsidian-git (`data.json`): `{ "autoSaveInterval": 10, "autoPullOnBoot": true, "commitMessage": "vault: {{date}}" }`. Creating the remote and the first `git push` are the user's to run — provide the commands, don't execute them. If `remotely-save`/`local-backup` are enabled, recommend disabling them (one backup tool, no sync loops).

### Step 9 — Workflow skills & agent access
- **Validate**: does each `../ob-*/SKILL.md` exist? Attempt to read `<vault>/CLAUDE.md` directly via the filesystem. If the read fails, abort with: "Cannot access vault at `<vault>` — grant filesystem access and retry." Do NOT attempt to configure MCP servers.
- **Implement**: confirm the `ob:*` skills load under the `/ob:` namespace and list any missing. Do NOT add a PostToolUse auto-commit hook (backup is obsidian-git only).

### Step 10 — Hotkeys (optional)
- **Validate**: are the bindings present in `.obsidian/hotkeys.json`?
- **Implement**: merge `./assets/hotkeys.json` into `.obsidian/hotkeys.json` (don't drop existing bindings).

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Agent reads `99 Archives/` unprompted | Forbidden unless explicitly asked — wastes context |
| Agent writes outside `07 Claude/` / `00 Inbox/` | Output goes to the write-zone; promote manually |
| Inbox accumulates | It must tend to zero (`ob:tidy`) |
| Structure encoded as freeform tags | Use frontmatter properties; tags are topical only |
| Tags invented ad hoc | Must exist in `Tag System.md`; `ob:audit` flags drift |
| Empty daily notes pile up | The rollover script prunes empty previous days |
| Whole vault loaded into context | MOC-first: index → one MOC → 2-3 notes |
| A code repo points into the vault | One-way only: vault → repo, never repo → vault |
| Renaming `08 Templates/` breaks Templater | Update `templates_folder` + folder-template maps |
| Atlas becomes a junk drawer | Atlas = authored only; captured material → Resources |
| Multiple backup plugins fighting | Pick one (obsidian-git); disable the rest |
| Hardcoded paths in scripts | Config lives in `~/.claude/ob/ob.env`; scripts stay generic |
