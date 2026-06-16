#!/usr/bin/env bash
# First-time setup: installs all skills from this repo into Claude Code globally.
# Run this once after cloning. After that, use /install-skills inside Claude Code.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing skills from $REPO_DIR ..."
npx skills add "$REPO_DIR" -g -y

echo ""
echo "Done. Restart your Claude Code session and use /install-skills for future updates."
