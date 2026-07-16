#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/register.sh"

# When invoked as a key binding, re-launch inside a tmux popup so we can prompt
# interactively without the token touching shell history. RCLIP_POPUP=0 runs
# the prompt inline (used by tests / headless callers).
if [ "${RCLIP_POPUP:-1}" = "1" ] && [ -n "${TMUX:-}" ]; then
    exec tmux display-popup -E "RCLIP_POPUP=0 RCLIP_BIN='$RCLIP_BIN' bash '$SELF'"
fi

read -r -s -p "rclipboard admin token: " token; echo
read -r -p "label [$(hostname)]: " label
label="${label:-$(hostname)}"

if [ -z "$token" ]; then
    echo "aborted: no token given" >&2
    exit 1
fi

"$RCLIP_BIN" register --token "$token" --label "$label"
echo "press enter to close"; read -r _ || true
