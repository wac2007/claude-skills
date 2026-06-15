---
type: note
---
# Dashboard

## Last week
```dataview
TABLE WITHOUT ID file.link AS Week FROM "06 Daily/Weeks" WHERE type = "weekly" SORT file.name DESC LIMIT 1
```

## Active projects
```dataview
TABLE status, updated FROM "02 Projects" WHERE type = "project" AND status = "active" SORT updated DESC
```

## Inbox to drain
```dataview
LIST FROM "00 Inbox" SORT file.ctime ASC
```

## Pending tasks
```dataview
TASK FROM !"08 Templates" WHERE !completed SORT due ASC LIMIT 15
```

## Recent TILs
```dataview
TABLE file.mtime AS Updated FROM #til SORT file.mtime DESC LIMIT 5
```

## Orphan notes (no links in or out)
```dataview
LIST WHERE length(file.inlinks) = 0 AND length(file.outlinks) = 0 AND file.name != "00 Dashboard"
```
