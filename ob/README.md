# ob — Obsidian Second Brain (Claude Code plugin)

Sets up and operates an Obsidian vault organized by **lifecycle, not topic**
(Inbox / Atlas / Projects / End Products / Areas / Resources), with write guards,
a controlled tag vocabulary, a Dataview dashboard, single-tool git backup, and
daily/weekly note automation.

## Skills
- `/ob:setup` — scaffold & audit the vault (this is the entry point).
- `/ob:weekly` — weekly summary + archive that week's daily notes. *(planned)*
- `/ob:capture` `/ob:daily` `/ob:review` `/ob:emerge` `/ob:connect` `/ob:tidy` `/ob:audit` *(planned)*

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
