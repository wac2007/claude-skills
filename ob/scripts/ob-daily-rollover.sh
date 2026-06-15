#!/usr/bin/env bash
# Ensure today's daily note exists; delete the previous day's note if it is empty.
# Config (VAULT) comes from ~/.claude/ob/ob.env, written by ob-install.sh.
set -euo pipefail
source "$HOME/.claude/ob/ob.env"

DAILY="$VAULT/06 Daily"
TEMPLATE="$VAULT/08 Templates/Daily.md"
TODAY="$(date +%F)"                       # YYYY-MM-DD
TODAY_FILE="$DAILY/$TODAY.md"
mkdir -p "$DAILY"

# 1) Ensure today's note exists.
if [ ! -f "$TODAY_FILE" ]; then
  if [ -f "$TEMPLATE" ]; then
    sed "s/{{date}}/$TODAY/g" "$TEMPLATE" > "$TODAY_FILE"
  else
    printf -- '---\ntype: daily\ndate: %s\n---\n## Tasks\n## Notes\n' "$TODAY" > "$TODAY_FILE"
  fi
fi

# 2) Prune the most recent PRIOR daily note if empty.
#    "Empty" = nothing after frontmatter except blank lines, headings, or empty checkboxes.
prev="$(ls -1 "$DAILY"/*.md 2>/dev/null \
      | grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' \
      | grep -v "/$TODAY.md$" | sort | tail -n1 || true)"
[ -z "${prev:-}" ] && exit 0

body="$(awk 'BEGIN{fm=0} /^---[[:space:]]*$/{fm++; next} fm>=2{print}' "$prev" \
      | grep -vE '^[[:space:]]*$' \
      | grep -vE '^[[:space:]]*#' \
      | grep -vE '^[[:space:]]*-[[:space:]]*(\[[ xX]\])?[[:space:]]*$' || true)"
[ -z "$body" ] && rm -f "$prev"
