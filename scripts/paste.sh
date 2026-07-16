#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}

mode=clear
while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            [ $# -ge 2 ] || { echo "usage: paste.sh [--mode clear|encrypted|default]" >&2; exit 2; }
            mode="$2"; shift 2 ;;
        *) echo "usage: paste.sh [--mode clear|encrypted|default]" >&2; exit 2 ;;
    esac
done

if [ "$mode" = "default" ]; then
    enc=$(tmux show-option -gqv '@rclip_encrypt' 2>/dev/null || true)
    if [ "$enc" = "on" ]; then mode=encrypted; else mode=clear; fi
fi

case "$mode" in
    clear)     content=$("$RCLIP_BIN" get -t "$RCLIP_TOPIC" 2>/dev/null || true) ;;
    encrypted) content=$("$RCLIP_BIN" get -t "$RCLIP_TOPIC" --decrypt 2>/dev/null || true) ;;
    *) echo "paste.sh: invalid mode '$mode'" >&2; exit 2 ;;
esac

if [ -n "$content" ]; then
    printf '%s' "$content" | tmux load-buffer -
    tmux paste-buffer -d
fi
