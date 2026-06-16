---
name: ob-save
description: Extract decisions, tasks, and people from the current conversation and write them to the correct vault locations. Run at the end of any working session so nothing is lost. Zero questions asked.
---

# ob:save — Save Conversation to Vault

Scans the current conversation, extracts structured items, and writes them to the vault. No questions asked. Idempotent — running twice does not duplicate entries.

**Write guards:**
- `02 Projects/` — append-only inside managed regions
- `07 Claude/` — ambiguous items only, awaiting triage

**Implementation note:** vault paths contain spaces (e.g. `02 Projects/`). Always use the Bash tool with quoted paths — never the Write/Edit tools directly on vault files.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop: "ob.env not found — run /ob:setup first."

## Step 1 — Extract from the conversation

Scan all turns in the current conversation and extract three categories:

**Decisions** — resolved choices with rationale:
- Look for: "we decided", "going with", "the approach is", "locked", explicit trade-off conclusions
- Extract: the decision statement and its rationale in one sentence each

**Tasks** — action items:
- Look for: "I will", "next step", "TODO", "should", future-tense commitments, agreed follow-ups
- Extract: the action item as an imperative phrase

**People** — named individuals mentioned:
- Look for: any proper name that is a person
- Extract: the name and one sentence of context about their role or the nature of the mention

Deduplicate each list by content — identical items appear only once.

## Step 2 — Identify the target project

Read `$VAULT/CRITICAL_FACTS.md` for the active project. Cross-reference with the current conversation topic. Use `$VAULT/02 Projects/Projects - Index.md` as a fallback lookup.

`PROJECT_NOTE`: `$VAULT/02 Projects/<project>/_context.md`

If no project can be identified with confidence, route all extracted items to `$VAULT/07 Claude/save-<DATE>.md` for manual triage and skip Steps 3–4.

## Step 3 — Write decisions

In `PROJECT_NOTE`, find the `## Decisions` section. Locate or create the managed region:
```
<!-- BEGIN ob:decisions -->
...
<!-- END ob:decisions -->
```

For each new decision, append inside the region:
```
- **<YYYY-MM-DD HH:MM>** <decision statement> — <rationale>
```

**Idempotency guard**: skip any decision whose statement text already appears verbatim inside the managed region.

## Step 4 — Write tasks

In `PROJECT_NOTE`, find or create a `## Tasks` section. Locate or create the managed region:
```
<!-- BEGIN ob:tasks -->
...
<!-- END ob:tasks -->
```

For each new task, append inside the region:
```
- [ ] <task text>
```

**Idempotency guard**: skip any task text already present inside the managed region.

## Step 5 — Process people

For each person extracted, check whether `$VAULT/01 Atlas/People/<Name>.md` exists. If it does not, invoke `/ob:person <Name>` with any context about them from the conversation.

## Step 6 — Report

```
ob:save — Session saved to <project folder name>
  Decisions: <n> new
  Tasks: <n> new
  People: <n> processed
```

If items were routed to `07 Claude/`:
```
  Ambiguous items → 07 Claude/save-<DATE>.md (no active project identified)
```
