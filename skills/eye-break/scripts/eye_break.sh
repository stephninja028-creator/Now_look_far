#!/bin/zsh
set -euo pipefail

readonly DOMAIN="com.zhangmingliang.nowlookfar"
readonly APP_PATH="$HOME/Applications/EyeBreak.app"
readonly PLIST_PATH="$HOME/Library/LaunchAgents/com.zhangmingliang.nowlookfar.plist"
readonly LABEL="com.zhangmingliang.nowlookfar"

read_int() {
  defaults read "$DOMAIN" "$1" 2>/dev/null || echo "$2"
}

status() {
  local work idle snooze running version
  work="$(read_int workMinutes 45)"
  idle="$(read_int idlePauseMinutes 3)"
  snooze="$(defaults read "$DOMAIN" allowSnooze 2>/dev/null || echo 1)"
  version="$(plutil -extract CFBundleShortVersionString raw \
    "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo unknown)"
  if pgrep -x EyeBreak >/dev/null 2>&1; then
    running="running"
  else
    running="stopped"
  fi
  echo "state=$running version=$version work_minutes=$work idle_pause_minutes=$idle snooze=$snooze app=$APP_PATH"
}

restart_app() {
  if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
    launchctl kickstart -k "gui/$(id -u)/$LABEL"
  else
    killall EyeBreak 2>/dev/null || true
    open "$APP_PATH"
  fi
}

case "${1:-status}" in
  status)
    status
    ;;
  set-work)
    value="${2:?work minutes required}"
    (( value >= 20 && value <= 90 )) || {
      echo "work minutes must be 20-90" >&2
      exit 2
    }
    defaults write "$DOMAIN" workMinutes -int "$value"
    restart_app
    status
    ;;
  set-idle)
    value="${2:?idle minutes required}"
    (( value >= 1 && value <= 15 )) || {
      echo "idle minutes must be 1-15" >&2
      exit 2
    }
    defaults write "$DOMAIN" idlePauseMinutes -int "$value"
    restart_app
    status
    ;;
  set-snooze)
    case "${2:-}" in
      on) defaults write "$DOMAIN" allowSnooze -bool true ;;
      off) defaults write "$DOMAIN" allowSnooze -bool false ;;
      *) echo "set-snooze expects on or off" >&2; exit 2 ;;
    esac
    restart_app
    status
    ;;
  pause)
    seconds="${2:?pause seconds required}"
    (( seconds > 0 )) || { echo "pause seconds must be positive" >&2; exit 2; }
    until_epoch="$(( $(date +%s) + seconds ))"
    defaults write "$DOMAIN" pauseUntilEpoch -int "$until_epoch"
    restart_app
    status
    ;;
  resume)
    defaults delete "$DOMAIN" pauseUntilEpoch 2>/dev/null || true
    restart_app
    status
    ;;
  start)
    [[ -d "$APP_PATH" ]] || {
      echo "EyeBreak is not installed at $APP_PATH" >&2
      exit 3
    }
    if [[ -f "$PLIST_PATH" ]]; then
      launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true
      launchctl kickstart -k "gui/$(id -u)/$LABEL"
    else
      open "$APP_PATH"
    fi
    status
    ;;
  stop)
    launchctl bootout "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true
    killall EyeBreak 2>/dev/null || true
    status
    ;;
  *)
    echo "usage: $0 {status|set-work N|set-idle N|set-snooze on|off|pause SECONDS|resume|start|stop}" >&2
    exit 2
    ;;
esac
