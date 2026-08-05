#!/bin/zsh
set -euo pipefail

readonly APP_PATH="$HOME/Applications/EyeBreak.app"
readonly PLIST_PATH="$HOME/Library/LaunchAgents/com.zhangmingliang.nowlookfar.plist"
readonly LEGACY_PLIST_PATH="$HOME/Library/LaunchAgents/com.zhangmingliang.eyebreak.plist"
readonly SUPPORT_PATH="$HOME/Library/Application Support/NowLookFar"
readonly SKILL_PATH="$HOME/.codex/skills/eye-break"
readonly DOMAIN="com.zhangmingliang.nowlookfar"

[[ "${1:-}" == "--yes" ]] || {
  echo "This will stop EyeBreak and move its app, support files, and Codex Skill to Trash."
  echo "Run with --yes only after the user explicitly confirms."
  exit 2
}

stamp="$(date +%Y%m%d-%H%M%S)"
trash_dir="$HOME/.Trash/NowLookFar-$stamp"
mkdir -p "$trash_dir"

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true
launchctl bootout "gui/$(id -u)" "$LEGACY_PLIST_PATH" 2>/dev/null || true
killall EyeBreak 2>/dev/null || true

[[ ! -d "$APP_PATH" ]] || mv "$APP_PATH" "$trash_dir/EyeBreak.app"
[[ ! -d "$SUPPORT_PATH" ]] || mv "$SUPPORT_PATH" "$trash_dir/NowLookFar-support"
[[ ! -d "$SKILL_PATH" ]] || mv "$SKILL_PATH" "$trash_dir/eye-break-skill"
rm -f "$PLIST_PATH"
rm -f "$LEGACY_PLIST_PATH"

if [[ "${2:-}" == "--purge" || "${1:-}" == "--purge" ]]; then
  defaults delete "$DOMAIN" 2>/dev/null || true
  echo "Preferences deleted."
else
  echo "Preferences preserved."
fi

echo "Now Look Far moved to $trash_dir"
