#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-clipctl2}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}
RCLIP_ENCODING=${RCLIP_ENCODING:-hex}
HOST=${RCLIP_HOST:-127.0.0.1}
PORT=${RCLIP_PORT:-8989}
UDS=${RCLIP_UDS:-}

# Load shared config
CONF_FILE=${RCLIP_CONF:-"$HOME/.config/rclipboard/env"}
if [ -r "$CONF_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONF_FILE"
  if [ -z "$UDS" ] && [ -n "${RCLIPBOARD_BIND_UDS:-}" ]; then UDS="$RCLIPBOARD_BIND_UDS"; fi
  if [ -z "${HOST:-}" ] && [ -n "${RCLIPBOARD_BIND_ADDR:-}" ]; then HOST="$RCLIPBOARD_BIND_ADDR"; fi
  if [ -z "${PORT:-}" ] && [ -n "${RCLIPBOARD_BIND_PORT:-}" ]; then PORT="$RCLIPBOARD_BIND_PORT"; fi
fi

# Fetch in desired encoding and paste into tmux buffer
if [ -n "$UDS" ]; then
  val=$("$RCLIP_BIN" fetch -c --uds "$UDS" --encoding "$RCLIP_ENCODING" || true)
else
  val=$("$RCLIP_BIN" fetch -c --host "$HOST" --port "$PORT" --encoding "$RCLIP_ENCODING" || true)
fi
if [ -z "$val" ]; then
  exit 0
fi
case "$RCLIP_ENCODING" in
  hex)
    printf '%s' "$val" | xxd -r -p | tmux load-buffer - ;;
  base64)
    # Pad base64 to multiple of 4 and decode
    pad=$(( (4 - ${#val} % 4) % 4 ))
    if [ $pad -gt 0 ]; then val="${val}$(printf '=%.0s' $(seq 1 $pad))"; fi
    printf '%s' "$val" | base64 -d | tmux load-buffer - ;;
  *)
    printf '%s' "$val" | tmux load-buffer - ;;
esac
tmux paste-buffer -d
