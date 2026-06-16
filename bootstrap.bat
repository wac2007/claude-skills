@echo off
REM First-time setup for Windows: installs all skills from this repo into Claude Code globally.
REM Run this once after cloning. After that, use /install-skills inside Claude Code.
npx skills add "%~dp0" -g -y
echo.
echo Done. Restart your Claude Code session and use /install-skills for future updates.
