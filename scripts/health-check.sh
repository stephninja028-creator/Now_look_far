#!/bin/zsh
set -u

readonly APP_PATH="$HOME/Applications/EyeBreak.app"
readonly PLIST_PATH="$HOME/Library/LaunchAgents/com.zhangmingliang.nowlookfar.plist"
readonly CLI_PATH="$HOME/Library/Application Support/NowLookFar/bin/now-look-far"
readonly SKILL_PATH="$HOME/.codex/skills/eye-break/SKILL.md"

failures=0

check() {
  label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS  $label"
  else
    echo "FAIL  $label"
    failures=$(( failures + 1 ))
  fi
}

check "Application installed" test -d "$APP_PATH"
check "Bundle identifier" test \
  "$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Contents/Info.plist" 2>/dev/null)" \
  = "com.zhangmingliang.nowlookfar"
check "Code signature" codesign --verify --deep --strict "$APP_PATH"
check "Gatekeeper assessment" spctl --assess --type execute "$APP_PATH"
check "LaunchAgent plist" plutil -lint "$PLIST_PATH"
check "LaunchAgent loaded" launchctl print \
  "gui/$(id -u)/com.zhangmingliang.nowlookfar"
check "EyeBreak running" pgrep -x EyeBreak
check "Agent CLI installed" test -x "$CLI_PATH"

if [[ -d "$HOME/.codex" ]]; then
  check "Codex Skill installed" test -f "$SKILL_PATH"
else
  echo "SKIP  Codex Skill (Codex not detected)"
fi

if [[ -x "$CLI_PATH" ]]; then
  "$CLI_PATH" status
fi

if (( failures > 0 )); then
  echo "Health check failed: $failures check(s)." >&2
  exit 1
fi

echo "Health check passed."
