# PRD: npx skills Compatibility

## Goal

Every skill in this repo is installable via `npx skills add wac2007/claude-skills` and works correctly after a standalone install.

## Rules

### 1. Manifest stays current

`.claude-plugin/marketplace.json` must list every skill in the `skills` array of its plugin entry.

- Paths are relative to the plugin `source` dir (e.g. `"./skills/ob-capture"` for `ob/skills/ob-capture/`)
- **When you add a new skill, update this file before committing.**

### 2. Each skill is self-contained

`npx skills` installs one skill directory at a time (e.g. `ob/skills/ob-capture/` → `~/.claude/skills/ob-capture/`). At install time, no other skill's files are present.

- All bundled files (assets, scripts) must live **inside** the skill's own directory
- Paths to bundled files must be **relative to `SKILL.md`** (e.g. `./assets/`, `./scripts/`)
- Exception: `ob-setup` is the sole bundled-file owner; all other `ob-*` skills are instruction-only

### 3. Runtime dependencies via ob.env only

Skills may depend on `~/.claude/ob/ob.env` (written by `/ob:setup`) at invocation time. They must **not** read files from sibling skill directories at runtime.

### 4. Valid SKILL.md frontmatter

Every `SKILL.md` must have both `name` and `description` in YAML frontmatter, or `npx skills` will skip it.

```yaml
---
name: ob-capture
description: One-line description of what the skill does and when to use it
---
```

## Checklist for adding a new ob-* skill

- [ ] Create `ob/skills/<name>/SKILL.md` with valid frontmatter
- [ ] Add `"./skills/<name>"` to the `skills` array in `.claude-plugin/marketplace.json`
- [ ] Confirm the skill has no file reads outside its own directory
- [ ] Confirm the skill declares its dependency on `/ob:setup` (i.e. `ob.env` must exist)
