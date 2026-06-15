#!/usr/bin/env bash
# Run the weekly summary skill headless. Config from ~/.claude/ob/ob.env.
set -euo pipefail
source "$HOME/.claude/ob/ob.env"

# Sane PATH for launchd's minimal environment; include the dir holding the claude binary.
export PATH="${CLAUDE_BIN%/*}:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

cd "$VAULT"
exec "$CLAUDE_BIN" -p "/ob:weekly"
