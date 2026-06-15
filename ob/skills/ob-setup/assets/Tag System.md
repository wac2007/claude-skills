---
type: reference
---
# Tag System

The controlled vocabulary for this vault. The agent uses ONLY tags listed here; to add one, add it here first.

## Rules
- Structure and state go in frontmatter properties (`type`, `status`, `area`, `project`), NOT tags.
- Tags are for cross-cutting topics only.
- Style: lowercase, kebab-case, English, max two levels.

## Vocabulary
Domain (hierarchical): `#area/dev` `#area/work` `#area/finances` `#area/hobbies` `#area/home-lab`
Type (flat): `#til` `#decision` `#idea` `#analysis` `#reference` `#bug` `#connection`
State (flat): `#wip` `#blocked` `#done`
Entity (flat): `#person` `#asset` `#project`
