---
name: ob-fireflies
description: Fetch a Fireflies meeting transcript via MCP and save it to 05 Resources/ in the vault, ready for /ob:save. Pass a Fireflies meeting URL or transcript ID.
---

# ob:fireflies — Fetch Meeting Transcript to Vault

Fetches a Fireflies.ai meeting transcript using the Fireflies MCP server and writes it to `05 Resources/` as a structured note. The note is immediately available for `/ob:save` to extract decisions and tasks into the active project.

**Prerequisites:**
- Fireflies MCP server configured as `"fireflies"` in Claude Code MCP settings
- `ob.env` written by `/ob:setup`

**Write guard:** `05 Resources/` only.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:fireflies — ob.env not found. Run /ob:setup first.
```

## Step 1 — Discover Fireflies MCP tools

Use ToolSearch with query `"select:mcp__fireflies__get_transcript,mcp__fireflies__list_transcripts,mcp__fireflies__search_transcripts"` to load available Fireflies MCP tool schemas.

If no Fireflies MCP tools are found, stop:
```
ob:fireflies — Fireflies MCP not available.
Add this to your Claude Code MCP settings and restart:

  "fireflies": {
    "command": "npx",
    "args": ["mcp-remote", "https://api.fireflies.ai/mcp"]
  }
```

## Step 2 — Parse arguments

The text following `/ob:fireflies` is `INPUT` (trimmed).

If `INPUT` is empty, prompt once: "Paste the Fireflies meeting URL or transcript ID:" then continue.

**Extract transcript ID from `INPUT`:**

- If `INPUT` matches `https://app.fireflies.ai/view/...::TRANSCRIPT_ID` — extract everything after the last `::` as `TRANSCRIPT_ID`
- If `INPUT` is a plain alphanumeric ID (no spaces, no `://`) — use it directly as `TRANSCRIPT_ID`
- If `INPUT` is any other URL — extract the last path segment after the final `/` or `::` as a best-effort `TRANSCRIPT_ID`
- If none of the above match — stop: `ob:fireflies — could not extract a transcript ID from: <INPUT>`

## Step 3 — Fetch the transcript via MCP

Call `mcp__fireflies__get_transcript` with `{ id: TRANSCRIPT_ID }` (or the equivalent parameter name from the discovered schema).

If the tool returns an error or empty result, try `mcp__fireflies__search_transcripts` if available, searching by the ID or any title embedded in `INPUT`.

If the fetch fails, stop:
```
ob:fireflies — transcript not found: <TRANSCRIPT_ID>
Check that you have access to this meeting in Fireflies.
```

Extract from the response:
- `MEETING_TITLE`: title field, or `"Meeting <TRANSCRIPT_ID>"` if absent
- `MEETING_DATE`: date field formatted as `YYYY-MM-DD`, or today's date if absent
- `PARTICIPANTS`: list of attendee names (join with `, `)
- `DURATION_MINS`: duration in minutes, or blank if absent
- `SUMMARY`: AI summary field if present, else blank
- `TRANSCRIPT_TEXT`: full transcript text (speaker-labelled turns if available)
- `ACTION_ITEMS`: any action items the MCP returns, as a bullet list (blank if none)

## Step 3.5 — Generate summary and action items from transcript

**Do this inline — no additional MCP or tool calls.**

Using only the already-fetched `TRANSCRIPT_TEXT` (and any `SUMMARY` / `ACTION_ITEMS` the MCP returned), synthesise:

- **`SUMMARY`**: 3–5 sentence prose summary of what was discussed and decided. If the MCP already returned a non-empty summary, enrich it with any key points it missed; otherwise write one from scratch.
- **`ACTION_ITEMS`**: a bullet list of concrete next steps with an owner name in brackets where determinable (e.g. `- [ ] Send proposal draft [Alice]`). If the MCP already returned action items, merge and de-duplicate; otherwise derive them from the transcript. If no actions are evident, write `- None identified.`

Do not call any tool yet — hold `SUMMARY` and `ACTION_ITEMS` in memory for Step 5.

## Step 4 — Derive file path

- `SLUG`: lowercase `MEETING_TITLE` → spaces and punctuation → `-` → strip non-alphanumeric-or-dash → truncate at 60 chars
- `RESOURCE_FILE`: `$VAULT/05 Resources/<MEETING_DATE>-<SLUG>.md`

**Idempotency check:** if `RESOURCE_FILE` already exists, stop:
```
ob:fireflies — already saved: 05 Resources/<MEETING_DATE>-<SLUG>.md
Run /ob:save to route items to your active project.
```

## Step 5 — Write the resource note

Create `RESOURCE_FILE` using the Bash tool (quoted path):

```markdown
---
type: resource
source: agent
source_type: transcript
url: <INPUT if it is a URL, else blank>
transcript_id: <TRANSCRIPT_ID>
created: <MEETING_DATE>
participants: <PARTICIPANTS>
duration_mins: <DURATION_MINS>
tags: []
---

# <MEETING_TITLE>

> Transcript fetched: <today's date as YYYY-MM-DD>
> Meeting date: <MEETING_DATE>
> Participants: <PARTICIPANTS>
> Duration: <DURATION_MINS> min

## Summary

<SUMMARY if present, else "No AI summary available.">

## Action Items

<ACTION_ITEMS bullet list if present, else "None identified.">

## Full Transcript

<TRANSCRIPT_TEXT>
```

## Step 6 — Report

```
ob:fireflies — saved: 05 Resources/<MEETING_DATE>-<SLUG>.md
  Meeting: <MEETING_TITLE>
  Date: <MEETING_DATE>
  Participants: <PARTICIPANTS>

Run /ob:save to extract decisions and tasks into your active project.
```
