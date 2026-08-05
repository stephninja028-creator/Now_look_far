#!/bin/zsh
set -euo pipefail

readonly INSTALLER_URL="https://raw.githubusercontent.com/stephninja028-creator/Now_look_far/main/scripts/install.sh"
temp_installer="$(mktemp /tmp/now-look-far-update.XXXXXX)"
trap 'rm -f "$temp_installer"' EXIT

curl --fail --location --proto '=https' --tlsv1.2 \
  "$INSTALLER_URL" --output "$temp_installer"

echo "Installer downloaded to $temp_installer"
echo "Reviewing installer before update:"
sed -n '1,260p' "$temp_installer"
echo
echo "Run the downloaded installer only after the user approves the displayed changes."

if [[ "${1:-}" == "--yes" ]]; then
  /bin/zsh "$temp_installer"
else
  echo "Re-run with --yes after explicit user approval."
fi
