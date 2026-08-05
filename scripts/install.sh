#!/bin/zsh
set -euo pipefail

readonly REPO_SLUG="stephninja028-creator/Now_look_far"
readonly RAW_BASE="https://raw.githubusercontent.com/$REPO_SLUG/main"
readonly MANIFEST_URL="$RAW_BASE/release-manifest.plist"
readonly APP_TARGET="$HOME/Applications/EyeBreak.app"
readonly SUPPORT_DIR="$HOME/Library/Application Support/NowLookFar"
readonly BIN_DIR="$SUPPORT_DIR/bin"
readonly CLI_TARGET="$BIN_DIR/now-look-far"
readonly LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.zhangmingliang.nowlookfar.plist"
readonly LEGACY_LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.zhangmingliang.eyebreak.plist"
readonly CODEX_SKILL="$HOME/.codex/skills/eye-break"

temp_dir="$(mktemp -d /tmp/now-look-far.XXXXXX)"
manifest="$temp_dir/release-manifest.plist"
backup_app="$temp_dir/EyeBreak.backup.app"
backup_plist="$temp_dir/launch-agent.backup.plist"
had_app=false
had_plist=false
mutation_started=false

cleanup() {
  rm -rf "$temp_dir"
}

rollback() {
  [[ "$mutation_started" == true ]] || return
  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" 2>/dev/null || true
  killall EyeBreak 2>/dev/null || true

  if [[ "$had_app" == true && -d "$backup_app" ]]; then
    rm -rf "$APP_TARGET"
    ditto "$backup_app" "$APP_TARGET"
  else
    rm -rf "$APP_TARGET"
  fi

  if [[ "$had_plist" == true && -f "$backup_plist" ]]; then
    cp "$backup_plist" "$LAUNCH_AGENT"
    launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT" 2>/dev/null || true
  else
    rm -f "$LAUNCH_AGENT"
  fi
}

on_error() {
  code=$?
  echo "Installation failed; restoring the previous installation." >&2
  rollback
  cleanup
  exit "$code"
}

trap on_error ERR
trap cleanup EXIT

json_value() {
  plutil -extract "$1" raw -o - "$manifest"
}

require_hex_sha() {
  [[ ${#1} -eq 64 && "$1" != *[^0-9a-fA-F]* ]] || {
    echo "Manifest contains an invalid SHA-256." >&2
    exit 20
  }
}

require_release_url() {
  case "$1" in
    "https://github.com/$REPO_SLUG/releases/download/"*) ;;
    *)
      echo "Manifest contains an untrusted release URL: $1" >&2
      exit 21
      ;;
  esac
}

echo "Fetching the signed release manifest..."
curl --fail --location --proto '=https' --tlsv1.2 \
  "$MANIFEST_URL" --output "$manifest"

published="$(json_value published)"
[[ "$published" == true ]] || {
  echo "Now Look Far is not published for public installation yet." >&2
  exit 10
}

version="$(json_value version)"
min_macos_major="$(json_value min_macos_major)"
architectures="$(json_value architectures)"
bundle_id="$(json_value bundle_id)"
team_id="$(json_value team_id)"
app_url="$(json_value app_url)"
app_sha256="$(json_value app_sha256)"
skill_url="$(json_value skill_url)"
skill_sha256="$(json_value skill_sha256)"

current_macos="$(sw_vers -productVersion)"
current_major="${current_macos%%.*}"
(( current_major >= min_macos_major )) || {
  echo "Requires macOS $min_macos_major or newer; found $current_macos." >&2
  exit 11
}

current_arch="$(uname -m)"
case "$architectures:$current_arch" in
  universal:arm64|universal:x86_64|arm64:arm64|x86_64:x86_64) ;;
  *)
    echo "Release '$architectures' does not support '$current_arch'." >&2
    exit 12
    ;;
esac

require_release_url "$app_url"
require_release_url "$skill_url"
require_hex_sha "$app_sha256"
require_hex_sha "$skill_sha256"
[[ "$team_id" != "REPLACE_WITH_APPLE_TEAM_ID" && -n "$team_id" ]] || {
  echo "Manifest does not contain a release Team ID." >&2
  exit 13
}

app_zip="$temp_dir/EyeBreak-$version.zip"
skill_zip="$temp_dir/eye-break-skill-$version.zip"
echo "Downloading Now Look Far $version..."
curl --fail --location --proto '=https' --tlsv1.2 "$app_url" --output "$app_zip"
curl --fail --location --proto '=https' --tlsv1.2 "$skill_url" --output "$skill_zip"

echo "$app_sha256  $app_zip" | shasum -a 256 --check --status
echo "$skill_sha256  $skill_zip" | shasum -a 256 --check --status

app_extract="$temp_dir/app"
skill_extract="$temp_dir/skill"
mkdir -p "$app_extract" "$skill_extract"
ditto -x -k "$app_zip" "$app_extract"
ditto -x -k "$skill_zip" "$skill_extract"

app_source="$app_extract/EyeBreak.app"
skill_source="$skill_extract/eye-break"
[[ -d "$app_source" && -f "$skill_source/SKILL.md" ]] || {
  echo "Release archive structure is invalid." >&2
  exit 14
}

actual_bundle_id="$(plutil -extract CFBundleIdentifier raw \
  "$app_source/Contents/Info.plist")"
[[ "$actual_bundle_id" == "$bundle_id" ]] || {
  echo "Bundle identifier mismatch." >&2
  exit 15
}

codesign --verify --deep --strict "$app_source"
actual_team_id="$(codesign -dv --verbose=4 "$app_source" 2>&1 |
  awk -F= '/^TeamIdentifier=/{print $2; exit}')"
[[ "$actual_team_id" == "$team_id" ]] || {
  echo "Developer ID Team mismatch." >&2
  exit 16
}
spctl --assess --type execute --verbose=2 "$app_source"

mkdir -p "$HOME/Applications" "$HOME/Library/LaunchAgents" "$BIN_DIR"
if [[ -d "$APP_TARGET" ]]; then
  had_app=true
  ditto "$APP_TARGET" "$backup_app"
fi
if [[ -f "$LAUNCH_AGENT" ]]; then
  had_plist=true
  cp "$LAUNCH_AGENT" "$backup_plist"
fi
mutation_started=true

launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" 2>/dev/null || true
launchctl bootout "gui/$(id -u)" "$LEGACY_LAUNCH_AGENT" 2>/dev/null || true
killall EyeBreak 2>/dev/null || true
rm -rf "$APP_TARGET"
ditto "$app_source" "$APP_TARGET"

cp "$skill_source/scripts/eye_break.sh" "$CLI_TARGET"
chmod 755 "$CLI_TARGET"

if [[ -d "$HOME/.codex" ]]; then
  mkdir -p "$HOME/.codex/skills"
  rm -rf "$CODEX_SKILL"
  ditto "$skill_source" "$CODEX_SKILL"
fi

/usr/libexec/PlistBuddy -c "Clear dict" "$LAUNCH_AGENT" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :Label string com.zhangmingliang.nowlookfar" "$LAUNCH_AGENT"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments array" "$LAUNCH_AGENT"
/usr/libexec/PlistBuddy -c \
  "Add :ProgramArguments:0 string $APP_TARGET/Contents/MacOS/EyeBreak" "$LAUNCH_AGENT"
/usr/libexec/PlistBuddy -c "Add :RunAtLoad bool true" "$LAUNCH_AGENT"
/usr/libexec/PlistBuddy -c "Add :KeepAlive bool false" "$LAUNCH_AGENT"
plutil -lint "$LAUNCH_AGENT"
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT"

sleep 1
codesign --verify --deep --strict "$APP_TARGET"
spctl --assess --type execute "$APP_TARGET"
launchctl print "gui/$(id -u)/com.zhangmingliang.nowlookfar" >/dev/null
pgrep -x EyeBreak >/dev/null
"$CLI_TARGET" status >/dev/null
"$CLI_TARGET" status

mutation_started=false
echo "Now Look Far $version installed successfully."
