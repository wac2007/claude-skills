---
name: install-skills
description: Install all skills from this repo into the global ~/.claude/skills/ directory for local testing. Use when you want to test skills after making changes.
---

# Install Skills

Run this to install all skills from the current repo into the global Claude Code skills directory:

```bash
npx skills add ~/development/claude-skills -g
```

After the command completes, confirm the install succeeded by checking:

```bash
ls ~/.claude/skills/ | grep -E "ob-"
```

Then report which skills were installed or updated.
