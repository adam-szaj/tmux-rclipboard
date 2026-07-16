#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/unregister.sh"

if [ "${RCLIP_POPUP:-1}" = "1" ] && [ -n "${TMUX:-}" ]; then
    exec tmux display-popup -E "RCLIP_POPUP=0 RCLIP_BIN='$RCLIP_BIN' bash '$SELF'"
fi

read -r -p "remove local rclipboard identity? [y/N]: " ans
case "$ans" in
    y|Y) "$RCLIP_BIN" unregister ;;
    *)   echo "cancelled" >&2; exit 0 ;;
esac
echo "press enter to close"; read -r _ || true
