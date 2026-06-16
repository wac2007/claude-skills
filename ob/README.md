# ob — Obsidian Second Brain (Claude Code plugin)

Sets up and operates an Obsidian vault organized by **lifecycle, not topic**
(Inbox / Atlas / Projects / End Products / Areas / Resources), with write guards,
a controlled tag vocabulary, a Dataview dashboard, single-tool git backup, and
daily/weekly note automation.

## Skills

### Wave 0 — Foundation (done)
- `/ob:setup` — scaffold & audit the vault (entry point; includes CRITICAL_FACTS.md + Projects Index).
- `/ob:weekly` — weekly summary + archive that week's daily notes.

### Wave 1 — Core daily use (done)
- `/ob:world [L0|L1|L2|L3]` — load vault context at four progressive token budgets (default L1).
- `/ob:capture <text>` — zero-friction capture to `00 Inbox/` with correct frontmatter.
- `/ob:daily` / `/ob:daily log <text>` — create today's daily note or append a session log entry.
- `/ob:find <query>` — smart vault search; ranked results with path, type, and summary.
- `/ob:save` — extract decisions, tasks, and people from current conversation and write to vault.

### Wave 2 — People, projects, ingest *(planned)*
- `/ob:person` `/ob:decide` `/ob:project` `/ob:projects` `/ob:ingest` `/ob:synthesize` `/ob:reconcile` `/ob:recap` `/ob:review` `/ob:health` `/ob:adr`

### Wave 3–4 — Deep synthesis *(planned)*
- `/ob:architect` `/ob:emerge` `/ob:connect` `/ob:challenge` `/ob:panel` `/ob:vault-synthesis` `/ob:idea-discovery` `/ob:graduate` `/ob:learn`

## Layout
```
ob/
├── .claude-plugin/plugin.json
├── skills/ob-setup/SKILL.md          # + other ob-* skills
├── scripts/                          # generic; copied to ~/.claude/ob/ at install
│   ├── ob-install.sh                 # writes ob.env, copies scripts, bootstraps launchd
│   ├── ob-daily-rollover.sh
│   └── ob-weekly-run.sh
└── assets/                           # copied into the vault at setup
    ├── vault-CLAUDE.md  global-pointer.md  Dashboard.md  gitignore
    ├── Tag System.md   hotkeys.json
    ├── launchagents/*.plist.tmpl
    └── templates/*.md
```

## Install (local, skills-dir plugin)
Place this folder at `~/.claude/skills/ob/`. It auto-loads as `ob@skills-dir`.
Run `/ob:setup` and follow the steps. Per-user config is written to `~/.claude/ob/ob.env`.

## Distribute
Publish the folder as a GitHub repo and add it to a marketplace's
`.claude-plugin/marketplace.json`; users install with `/plugin install ob@<marketplace>`.

## Notes
- Paths inside the plugin use `${CLAUDE_PLUGIN_ROOT}`. The only machine-specific
  file is `~/.claude/ob/ob.env` (vault path + claude binary).
- launchd jobs are installed only with explicit permission.
- macOS-specific automation (launchd); other OSes need an equivalent scheduler.
