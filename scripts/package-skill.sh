#!/bin/zsh
set -euo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly VERSION="$(plutil -extract version raw \
  "$PROJECT_DIR/release-manifest.plist")"
readonly SOURCE_DIR="$PROJECT_DIR/skills/eye-break"
readonly OUTPUT_DIR="$PROJECT_DIR/dist/release"
readonly ARCHIVE="$OUTPUT_DIR/eye-break-skill-$VERSION.zip"
readonly WORK_DIR="$(mktemp -d /private/tmp/now-look-far-skill.XXXXXX)"
readonly STAGED_SKILL="$WORK_DIR/eye-break"
readonly VERIFY_DIR="$WORK_DIR/verify"

trap 'rm -rf "$WORK_DIR"' EXIT

[[ -f "$SOURCE_DIR/SKILL.md" && -x "$SOURCE_DIR/scripts/eye_break.sh" ]] || {
  echo "EyeBreak Skill source is incomplete." >&2
  exit 40
}

zsh -n "$SOURCE_DIR/scripts/eye_break.sh"
mkdir -p "$OUTPUT_DIR"
/bin/cp -RX "$SOURCE_DIR" "$STAGED_SKILL"
xattr -cr "$STAGED_SKILL"

cd "$WORK_DIR"
COPYFILE_DISABLE=1 /usr/bin/zip -qry "$ARCHIVE" "eye-break"
/usr/bin/unzip -tq "$ARCHIVE"
/usr/bin/unzip -q "$ARCHIVE" -d "$VERIFY_DIR"

[[ -f "$VERIFY_DIR/eye-break/SKILL.md" && \
   -x "$VERIFY_DIR/eye-break/scripts/eye_break.sh" ]] || {
  echo "Packaged EyeBreak Skill structure is invalid." >&2
  exit 41
}

shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"
echo "Packaged EyeBreak Skill: $ARCHIVE"
cat "$ARCHIVE.sha256"
