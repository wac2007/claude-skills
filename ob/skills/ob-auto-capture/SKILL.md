---
name: ob-auto-capture
description: |
  Automatically capture ACT NOW items and a session summary to Open Brain
  when a work session is ending. Use when wrapping a brainstorm, parking
  a project, finishing a Panning for Gold run, or otherwise closing a
  session with decisions worth remembering. Triggers on end-of-session
  phrases: "wrap up", "park this", "goodnight", "let's stop here", or
  any clear session-close signal. This is a behavioral protocol — not a
  background hook or daemon.
author: Jared Irish
forked_from: https://github.com/NateBJones-Projects/OB1/tree/main/skills/auto-capture
version: 1.0.0
---

# ob:auto-capture — Session-Close Capture to Open Brain

Captures ACT NOW items and a session summary to Open Brain at the end of a
session. Zero friction — no extra commands required once the skill is loaded.

**Write guard:** this skill does not write vault files. It only calls Open Brain
MCP tools (`capture_thought`, `search_thoughts`; prefixes vary by connector).

## Trigger Conditions

Run this protocol when any of these are true:

- The user signals the session is ending: "wrap up", "park this", "goodnight",
  "let's stop here", "we're done for now", or similar
- A brainstorm or work session produced ACT NOW items worth preserving
- A Panning for Gold run just finished (complements Phase 3.5 — session-level
  summary only; Panning for Gold handles per-thread ACT NOW captures)
- The conversation is about to end with clear value worth preserving

## Step 1 — Identify high-value outputs

From the session, identify:

- Each **ACT NOW item** (high-signal decisions or next actions that would be
  costly to lose)
- One **session summary** (theme, count of items, where the fuller context lives)

Skip: raw transcript text, parked/killed items, obvious duplicates, low-signal
filler.

## Step 2 — Deduplicate against Open Brain

Before capturing each ACT NOW item, search Open Brain for an obvious existing
match using the available search tool (often `search_thoughts`; prefixes vary).

If a near-duplicate exists, skip that item rather than creating noise.

## Step 3 — Capture each ACT NOW item

Call the available Open Brain capture tool (often `capture_thought`) once per
ACT NOW item with:

- **Idea in its strongest form** — one clear sentence
- **Why it matters** — the underlying need or consequence
- **2–3 concrete next actions** — specific enough to act on months later
- **Provenance** — date, source file, thread number, or session context

Example of a good capture vs. a bad one:

| Bad | Good |
|-----|------|
| "discussed API changes" | "ACT NOW: switch webhook retries to queue-based backoff — current linear retry causes thundering herd on recovery. Next: (1) add queue table migration, (2) update retry worker, (3) add dead-letter alert. Origin: 2026-06-17 architecture session." |

## Step 4 — Capture the session summary

One capture for the session as a whole:

- What the session was about
- How many important items emerged
- Main themes or threads
- Where the fuller context lives (file path or document name, if any)

## Step 5 — Report

Tell the user:

```
ob:auto-capture — saved N ACT NOW items + 1 session summary to Open Brain.
```

If the capture tool fails, report clearly:

```
ob:auto-capture — local wrap-up complete. Open Brain capture failed: <reason>.
```

Never invent success if the capture tool errored.

## Integration with ob:panning-for-gold

This skill complements the Panning for Gold Phase 3.5 (which captures
per-thread ACT NOW items). When both skills are active:

- **Panning for Gold** handles granular, per-thread captures during synthesis
- **ob:auto-capture** handles the session-level summary and any ACT NOW items
  that emerged outside the panning run

There is no conflict — captures from both are additive.

## Notes

- Tool names vary by client and connector. Use whatever Open Brain search and
  capture tools are available in the current environment. Do not assume a fixed
  prefix.
- This skill is a behavioral protocol. It activates on session-close signals,
  not on a timer, hook, or background service.
- Prefer specificity. Captures should be self-contained — useful months later
  without reopening the original session.
