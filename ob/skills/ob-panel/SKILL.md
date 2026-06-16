---
name: ob-panel
description: Convene a panel of 3-5 distinct named perspectives on a decision — each grounded in vault notes where possible — then synthesize a final recommendation. Read-only. Use when you want to stress-test a choice from multiple angles before committing.
---

# ob:panel — Perspective Panel with Synthesis

Generates 3–5 distinct named perspectives on a decision, each grounded in vault content, then produces a synthesis with a final recommendation. Read-only — no vault files modified.

**No vault files modified.**

**Depends on:** `ob-emerge` (#21) for pattern-awareness that shapes the perspective generation.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:panel — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `DECISION`: all text following `/ob:panel` (trim whitespace)

If `DECISION` is empty, prompt once: "What decision do you want the panel to weigh in on?" then continue.

## Step 2 — Load vault context

Search the vault for notes related to `DECISION` using `/ob:find` scoring logic (excluding `99 Archives/` and `08 Templates/`). Read the top 6–10 results.

Also read:
- `$VAULT/CRITICAL_FACTS.md` (for active project context)
- Any ADR files in `$VAULT/02 Projects/*/adr/` related to `DECISION`

`VAULT_CONTEXT`: collected relevant notes and their content.

## Step 3 — Assign perspectives

Select 3–5 distinct perspective roles that are relevant to `DECISION`. Choose from the set below, picking those most likely to surface different concerns:

| Role | Lens |
|------|------|
| Pragmatist | What is the fastest path that avoids known failure modes? |
| Long-term thinker | What does this look like in 2–5 years? What does it foreclose? |
| Skeptic | What is most likely to go wrong? What are we assuming? |
| User advocate | How does this feel from the end-user's perspective? |
| Resource realist | What does this actually cost in time, money, or attention? |
| Principled dissenter | Does this violate any established principle or past decision? |
| Domain expert | What does best practice in this area say? |

Always include Skeptic and at least one of Pragmatist or Long-term thinker.

`PERSPECTIVES`: list of selected `{ role, lens }` items.

## Step 4 — Generate each perspective

For each perspective role:

1. Adopt the lens described for that role.
2. Ground the verdict in vault content where possible (cite specific notes or ADRs).
3. Produce:
   - **Verdict**: one clear sentence — does this perspective favor, oppose, or conditionally support the decision?
   - **Rationale**: 2–4 sentences explaining why, referencing vault evidence if available.
   - **Vault evidence** (optional): 1 note path + quote (≤25 words) that most supports this perspective's view.

## Step 5 — Synthesize

After all perspectives:

**Tally**: count favor / conditional / oppose.

**Key tension**: identify the single most important disagreement between perspectives (the crux).

**Recommendation**: given the tally and the key tension, state a recommended path in 2–3 sentences. If the panel is split evenly, identify what new information would break the tie.

## Step 6 — Format output

```
ob:panel — "<DECISION>"
<n> perspectives · <favor> favor · <conditional> conditional · <oppose> oppose

---

## <Role 1>

**Verdict:** <one sentence>

<Rationale>

Vault evidence: [[<path>]] — "<quote>"

---

## <Role 2>
...

---

## Synthesis

**Key tension:** <what the perspectives disagree most about>

**Recommendation:** <recommended path>
```
