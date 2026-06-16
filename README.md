# claude-skills

Personal Claude Code skills. Skills are discovered via `.claude-plugin/marketplace.json` and installable with `npx skills`.

## Plugins

### `ob` — Obsidian Second Brain
Sets up and operates an Obsidian vault organized by **lifecycle, not topic**
(`00 Inbox` / `01 Atlas` / `02 Projects` / `03 End Products` / `04 Areas` / `05 Resources` / `06 Daily` / `07 Claude` / `99 Archives`), with write guards, a controlled tag vocabulary, a Dataview dashboard, single-tool git backup, and daily/weekly note automation.

Entry skill: `/ob:setup`. See `ob/README.md` for the full layout and `STATUS.md` for current progress.

## Install

### From GitHub (public)

```bash
npx skills add wac2007/claude-skills
```

### From a local clone

```bash
npx skills add ~/development/claude-skills
```

Both commands are interactive — select which skills and agents to install. Add `-g` to install globally (`~/.claude/skills/`) or `-y` to skip prompts.

```bash
# Global, non-interactive, Claude Code only
npx skills add wac2007/claude-skills -g -a claude-code -y
```

## Distribute
Push as a public GitHub repo. Others install with:

```bash
npx skills add wac2007/claude-skills
```

## Inspiration
- [eugeniughelbur/obsidian-second-brain](https://github.com/eugeniughelbur/obsidian-second-brain) — AI-first vault commands; source reference for most `ob:*` skill designs
- [sennaBruno/claude-skills](https://github.com/sennaBruno/claude-skills) — Claude Code skills reference

## Continuation
- `STATUS.md` — what's done, what's pending, open decisions.
- `CLAUDE.md` — design context and conventions for resuming work in a fresh session.
