#!/bin/zsh
set -euo pipefail

cli="$HOME/Library/Application Support/NowLookFar/bin/now-look-far"
[[ -x "$cli" ]] || {
  echo "Now Look Far CLI is not installed. Read AGENT_INSTALL.md." >&2
  exit 3
}
exec "$cli" "$@"
