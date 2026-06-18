# ob:auto-capture

> **Forked from:** [NateBJones-Projects/OB1 — skills/auto-capture](https://github.com/NateBJones-Projects/OB1/tree/main/skills/auto-capture)

*Behavioral skill that captures ACT NOW items and a session summary to Open Brain when a session ends.*

## What It Does

When a work session, brainstorm, or [Panning for Gold](../ob-panning-for-gold/) run is wrapping up, this skill captures the highest-value outputs to Open Brain automatically — no extra commands required. It triggers on natural end-of-session language ("wrap up", "park this", "goodnight") and stores each ACT NOW item as its own thought plus one session summary.

The result: important decisions and next actions are searchable in Open Brain the next session instead of disappearing into closed tabs.

## When to Use It

- Finishing any brainstorm or planning session with decisions worth keeping
- After a Panning for Gold run (adds a session-level summary on top of the per-thread captures that Panning for Gold already handles)
- Parking a project mid-flight with clear next actions
- Any session where you'd otherwise lose track of what was decided

## Prerequisites

- Working Open Brain setup with a capture tool available
- Open Brain MCP tools connected (`capture_thought`, `search_thoughts`; prefixes vary by connector)
- Recommended: Open Brain search tool available so the skill can avoid duplicate captures

## Installation

This skill is part of the `ob` plugin. Install via:

```bash
# From the claude-skills repo root
npx skills add . -g -y
```

Or inside Claude Code after initial setup:

```
/install-skills
```

## Trigger Conditions

End the session with any of:

- "wrap up"
- "park this"
- "goodnight"
- "let's stop here"
- Any clear session-close signal with decisions worth preserving

## Expected Outcome

At session close:

- One Open Brain thought per ACT NOW item — self-contained, with concrete next actions and provenance
- One Open Brain thought summarising the session (theme, item count, file paths)
- No captures for raw transcript noise, parked/killed items, or obvious duplicates

## Relationship to Panning for Gold

[ob:panning-for-gold](../ob-panning-for-gold/) handles per-thread granular captures during Phase 3.5 synthesis. ob:auto-capture handles session-level summaries and ACT NOW items that surface outside a panning run. Both are additive — install them together.

## Notes

Tool prefixes vary by connector. The skill uses whatever Open Brain search and capture tools are available in the current environment — it does not assume a fixed prefix.
