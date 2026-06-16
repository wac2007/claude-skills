---
name: install-skills
description: Install all skills from this repo into the global ~/.claude/skills/ directory for local testing. Use when you want to test skills after making changes.
---

# Install Skills

Find the repo root by looking for `skills-lock.json` starting from the current working directory and walking up. Run:

```bash
git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null
```

If that returns a path containing `skills-lock.json`, use it as `<REPO_ROOT>`. Otherwise ask the user where the repo is cloned.

Then install all skills globally:

```bash
npx skills add <REPO_ROOT> -g -y
```

After the command completes, confirm the install succeeded by checking:

```bash
ls ~/.claude/skills/ | grep -E "ob-"
```

Then report which skills were installed or updated.
