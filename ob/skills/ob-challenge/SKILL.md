---
name: ob-challenge
description: Steelman the opposition to a proposed idea using your own vault history — decisions, past failures, and established principles. Returns 3-5 counter-arguments each grounded in a specific vault note. Read-only. Use before committing to a direction to stress-test it against your own record.
---

# ob:challenge — Vault-Grounded Counter-Arguments

Searches the vault for evidence that contradicts or complicates a proposed idea, returning a structured challenge grounded in the user's own history. Read-only — no vault files modified.

**No vault files modified.**

**Depends on:** `ob-find` (#7) for vault search capabilities.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:challenge — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `IDEA`: all text following `/ob:challenge` (trim whitespace)

If `IDEA` is empty, prompt once: "What idea or plan do you want the vault to challenge?" then continue.

## Step 2 — Find relevant vault evidence

Search the vault for notes related to the `IDEA` using `/ob:find` scoring logic. Search in:
- `01 Atlas/` (principles, authored notes, TILs)
- `02 Projects/` (past project decisions and outcomes)
- `06 Daily/` (log entries mentioning the relevant topic, last 90 days)

`RELEVANT_NOTES`: top 10 vault notes by relevance score (excluding `99 Archives/` and `08 Templates/`).

Also check `02 Projects/*/adr/` for any ADR files whose topic overlaps with `IDEA`.

If fewer than 2 relevant notes found:
```
ob:challenge — not enough vault history on this topic to generate grounded counter-arguments.
  Try /ob:capture to build up your thinking on this area first.
```
Stop.

## Step 3 — Generate counter-arguments

Read all notes in `RELEVANT_NOTES`. For each note, look for:
- **Past failures or reversals**: decisions later reversed, projects abandoned, lessons from retrospectives
- **Contradicting principles**: Atlas notes or ADRs that assert a principle the idea seems to violate
- **Unresolved dependencies**: prior notes that flagged a prerequisite the idea assumes is solved
- **Scope or complexity signals**: entries that suggest similar efforts took longer or were harder than expected

Generate 3–5 counter-arguments. Each must:
- Be grounded in a specific vault note (quote the relevant passage, ≤30 words)
- Make a concrete objection to `IDEA` — not a vague "it might be hard"
- Be the strongest version of the objection (steelman, not strawman)

Sort counter-arguments from strongest to weakest (estimated impact on `IDEA` if the objection holds).

## Step 4 — Format output

```
ob:challenge — <n> counter-argument(s) against: "<IDEA>"

## Counter-argument 1 (strongest)

<Objection stated as a direct challenge in 1–2 sentences>

Evidence: [[<path>]] — "<quote from that note>"

---

## Counter-argument 2

<Objection>

Evidence: [[<path>]] — "<quote>"

---
...

## Summary

<1–2 sentences: the most important thing to resolve before proceeding with this idea>
```
