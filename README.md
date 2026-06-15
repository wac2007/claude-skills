# claude-skills

A personal Claude Code marketplace. Each top-level folder is a plugin; `.claude-plugin/marketplace.json` is the catalog.

## Plugins

### `ob` — Obsidian Second Brain
Sets up and operates an Obsidian vault organized by **lifecycle, not topic**
(`00 Inbox` / `01 Atlas` / `02 Projects` / `03 End Products` / `04 Areas` / `05 Resources` / `06 Daily` / `07 Claude` / `99 Archives`), with write guards, a controlled tag vocabulary, a Dataview dashboard, single-tool git backup, and daily/weekly note automation.

Entry skill: `/ob:setup`. See `ob/README.md` for the full layout and `STATUS.md` for current progress.

## Use locally
This repo is the source of truth. To run a plugin, load it from here:

```
claude --plugin-dir ~/development/claude-skills
```

…or add the marketplace and install:

```
/plugin marketplace add ~/development/claude-skills
/plugin install ob@claude-skills
```

(Skills-dir auto-load — i.e. dropping a copy in `~/.claude/skills/ob/` — also works, but keep this repo as the editable source.)

## Distribute
Push as a public GitHub repo; others add it with `/plugin marketplace add <owner>/<repo>` and install `ob@claude-skills`.

## Continuation
- `STATUS.md` — what's done, what's pending, open decisions.
- `CLAUDE.md` — design context and conventions for resuming work in a fresh session.
