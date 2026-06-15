#!/usr/bin/env bash
# Install the ob automation: copy scripts to ~/.claude/ob, write ob.env,
# render the LaunchAgent plists, and (re)bootstrap them. Idempotent.
# Usage: ob-install.sh /absolute/path/to/vault
set -euo pipefail

VAULT="${1:?usage: ob-install.sh /absolute/path/to/vault}"
[ -d "$VAULT/.obsidian" ] || { echo "Not an Obsidian vault: $VAULT" >&2; exit 1; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # plugin scripts/ dir
ASSETS="$HERE/../assets"
OB="$HOME/.claude/ob"
LA="$HOME/Library/LaunchAgents"
mkdir -p "$OB/logs" "$LA"

# 1) Per-user env (the only machine-specific file).
CLAUDE_BIN="$(command -v claude || true)"
printf 'VAULT=%q\nCLAUDE_BIN=%q\n' "$VAULT" "$CLAUDE_BIN" > "$OB/ob.env"

# 2) Copy the generic scripts to a stable location (survives plugin updates).
cp "$HERE/ob-daily-rollover.sh" "$HERE/ob-weekly-run.sh" "$OB/"
chmod +x "$OB"/ob-*.sh

# 3) Render + (re)bootstrap each LaunchAgent.
uid="$(id -u)"
for tmpl in "$ASSETS"/launchagents/*.plist.tmpl; do
  out="$LA/$(basename "${tmpl%.tmpl}")"
  sed "s#__OB__#$OB#g" "$tmpl" > "$out"
  label="$(basename "${out%.plist}")"
  launchctl bootout "gui/$uid/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$uid" "$out"
done

echo "ob installed. Scripts: $OB  Agents: com.ob.daily-rollover, com.ob.weekly"
echo "Verify: launchctl list | grep com.ob"
