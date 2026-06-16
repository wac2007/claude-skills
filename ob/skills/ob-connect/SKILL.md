---
name: ob-connect
description: Bridge two unrelated domains using vault content — finds structural similarities and proposes 3-5 novel cross-domain ideas, each grounded in specific vault notes. Read-only. Use when you want unexpected connections between two areas you're working in.
---

# ob:connect — Cross-Domain Bridge

Finds unexpected connections between two domains using existing vault notes and proposes novel bridging ideas. Read-only — no vault files modified.

**No vault files modified.**

**Depends on:** `ob-find` (#7) for vault search capabilities.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:connect — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

Arguments: `/ob:connect <domain-A> <domain-B>`

Separator: the two domains are split on ` vs `, ` and `, ` / `, or ` <> `. If no separator found, split on the first occurrence of two or more spaces.

- `DOMAIN_A`: first domain name (trim whitespace)
- `DOMAIN_B`: second domain name (trim whitespace)

If either domain is empty, prompt once: "Which two domains do you want to connect? (e.g. `/ob:connect machine learning / product design`)" then stop — let the user re-run with arguments.

## Step 2 — Find notes for each domain

Using the `/ob:find` scoring logic (Step 3 of ob-find), search the vault separately for `DOMAIN_A` and `DOMAIN_B`.

`NOTES_A`: top 5–8 most relevant vault notes for `DOMAIN_A` (excluding `99 Archives/` and `08 Templates/`)
`NOTES_B`: top 5–8 most relevant vault notes for `DOMAIN_B`

If fewer than 2 notes found for either domain:
```
ob:connect — not enough vault notes about "<domain>". Try /ob:capture or /ob:ingest to build up that area first.
```
Stop.

## Step 3 — Find structural similarities

Read all notes in `NOTES_A` and `NOTES_B`. Identify:

**Shared structures**: concepts, processes, or patterns that appear in both domains but are described differently (e.g. "feedback loops" in software and in biology, "bottlenecks" in traffic and in pipelines).

**Parallel tensions**: recurring trade-offs or dilemmas in each domain that mirror each other.

**Cross-applicable tools or mental models**: a technique from Domain A that could solve a known problem in Domain B.

Generate 3–5 bridging ideas. Each idea must:
- Name the structural similarity explicitly
- Cite at least one note from `NOTES_A` and one from `NOTES_B` as evidence
- Propose a concrete novel application or question

## Step 4 — Format output

```
ob:connect — <n> bridge(s) between "<DOMAIN_A>" and "<DOMAIN_B>"

## Bridge 1: <short title>

<2–3 sentence description of the structural similarity and novel idea>

From <DOMAIN_A>: [[<path>]] — "<supporting quote ≤25 words>"
From <DOMAIN_B>: [[<path>]] — "<supporting quote ≤25 words>"

Bridging idea: <1 concrete sentence — what you could do or think differently as a result>

---

## Bridge 2: <title>
...
```

If fewer than 3 bridges found:
```
(Only <n> bridge(s) found — vault coverage on one or both domains may be thin)
```
