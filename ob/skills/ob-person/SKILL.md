---
name: ob-person
description: Create or update a person note in 01 Atlas/People/ using the Person template. If the note already exists, merge new information from the conversation. Use when someone new appears in a session or to enrich an existing contact.
---

# ob:person — Person Note (Create or Update)

Creates or updates a person note in `01 Atlas/People/` using the Person template. Idempotent — re-running for the same name updates rather than duplicates.

**Write guard:** `01 Atlas/People/` only. Never writes outside this folder.

**Implementation note:** vault paths contain spaces. Always use the Bash tool with quoted paths.

## Step 0 — Resolve vault path

Read `~/.claude/ob/ob.env` to get `$VAULT`. If absent, stop:
```
ob:person — ob.env not found. Run /ob:setup first.
```

## Step 1 — Parse arguments

- `NAME`: all text following `/ob:person` (trim whitespace)
- `PERSON_FILE`: `$VAULT/01 Atlas/People/<NAME>.md`

If `NAME` is empty, prompt once: "Who do you want to capture?" then continue.

## Step 2 — Extract context from the conversation

Scan the current conversation for mentions of `NAME`:
- **Known for**: role, expertise, or relationship to the user (1–2 sentences)
- **Notes**: any specific facts, context, or interaction details mentioned
- **Links**: URLs, social handles, or related note paths mentioned

Extract only what is present; leave sections blank if no relevant content found.

## Step 3 — Create or update

**If `PERSON_FILE` does not exist**, create it:

```markdown
---
type: person
status: active
area: "[[People]]"
created: <DATE>
updated: <DATE>
tags: []
---

# <NAME>

## Known for

<known-for content, or blank>

## Notes

<notes content, or blank>

## Links

<links content, or blank>
```

**If `PERSON_FILE` already exists**, update it:
- Set `updated` frontmatter field to today's date
- For each of `## Known for`, `## Notes`, `## Links`: append new information extracted in Step 2 only if it does not already appear verbatim in the section
- Never overwrite or delete existing content

## Step 4 — Report

```
ob:person — <created|updated>: 01 Atlas/People/<NAME>.md
```
