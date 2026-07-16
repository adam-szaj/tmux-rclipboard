#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}
RCLIP_APP=${RCLIP_APP:-tmux}

mode=clear
while [ $# -gt 0 ]; do
    case "$1" in
        --mode) mode="${2:-clear}"; shift 2 ;;
        *) echo "usage: copy.sh [--mode clear|encrypted|default]" >&2; exit 2 ;;
    esac
done

if [ "$mode" = "default" ]; then
    enc=$(tmux show-option -gqv '@rclip_encrypt' 2>/dev/null || true)
    if [ "$enc" = "on" ]; then mode=encrypted; else mode=clear; fi
fi

case "$mode" in
    clear)     exec "$RCLIP_BIN" put -t "$RCLIP_TOPIC" --app "$RCLIP_APP" ;;
    encrypted) exec "$RCLIP_BIN" put -t "$RCLIP_TOPIC" --app "$RCLIP_APP" -E --fetch-keys ;;
    *) echo "copy.sh: invalid mode '$mode'" >&2; exit 2 ;;
esac
