---
name: ob-world
description: Load vault identity and state at four progressive token budgets. L0=~200 tokens (orientation only); L1=~800 (active project); L2=~2000 (area MOC + recent dailies); L3=full context. Default is L1. Use at the start of any Claude session that touches the vault.
---

# ob:world — Progressive Vault Context Engine

Loads vault context at the requested depth. Each level is a strict superset of the previous. Default is **L1**.

**No vault files modified.**

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop: "ob.env not found — run /ob:setup first."

## Step 1 — Parse level

Argument: `L0`, `L1`, `L2`, `L3` (case-insensitive: `l0`–`l3` also accepted), or none (default: `L1`).

---

## Step 2 — L0: Orientation layer (~200 tokens)

Read `$VAULT/CRITICAL_FACTS.md`. Output its full content verbatim:

```
=== ob:world L0 — Vault Orientation ===
<content of CRITICAL_FACTS.md>
```

If `CRITICAL_FACTS.md` is absent: "CRITICAL_FACTS.md not found — run /ob:setup first."

**Stop here if level is L0.**

---

## Step 3 — L1: Active project layer (~800 tokens total)

From `CRITICAL_FACTS.md`, identify the **active project**: the first listed active project, or the project most relevant to any topic already in the current conversation context.

Read `$VAULT/02 Projects/<project>/_context.md`. Output:

```
=== ob:world L1 — Active Project: <folder name> ===
<full content of _context.md>
```

If the project folder or `_context.md` is missing, note it and skip gracefully.

**Stop here if level is L1.**

---

## Step 4 — L2: Situational layer (~2000 tokens total)

**Area MOC**: from the active project's frontmatter `area` property, find the matching MOC at `$VAULT/04 Areas/<area>/` — look for a file named `<area>.md` or `<area> - MOC.md` or `<area> - Index.md`. Read it.

**Recent dailies**: list all files in `$VAULT/06 Daily/` named `YYYY-MM-DD.md` (exclude anything inside a `Weeks/` subfolder). Sort descending by date, take the 3 most recent. Read each.

Output:

```
=== ob:world L2 — Area + Recent Dailies ===

--- Area: <name> ---
<area MOC content>

--- Daily: <YYYY-MM-DD> ---
<daily note content>

--- Daily: <YYYY-MM-DD> ---
<daily note content>

--- Daily: <YYYY-MM-DD> ---
<daily note content>
```

Skip any missing files silently.

**Stop here if level is L2.**

---

## Step 5 — L3: Full context layer

Read every `.md` file in `$VAULT/01 Atlas/` and `$VAULT/05 Resources/`. For performance, read the first 30 lines of each Resources file (Atlas files read in full).

Output:

```
=== ob:world L3 — Full Vault Context ===

--- Atlas index ---
<list of all Atlas files with their H1 title>

--- Resources index ---
<list of all Resources files with their H1 title>

--- Atlas files ---
<full content of each Atlas file, prefixed with its path>

--- Resources files ---
<first 30 lines of each Resources file, prefixed with its path>
```

---

## Step 6 — Final summary

After all layers, append:
```
---
ob:world — L<n> loaded: <N> files read
```
