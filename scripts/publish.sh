#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}
RCLIP_ENCODING=${RCLIP_ENCODING:-base64}
RCLIP_APP=${RCLIP_APP:-tmux}
HOST=${RCLIP_HOST:-127.0.0.1}
PORT=${RCLIP_PORT:-8989}
UDS=${RCLIP_UDS:-}

# Load shared config from rclipboard env if present
CONF_FILE=${RCLIP_CONF:-"$HOME/.config/rclipboard/env"}
if [ -r "$CONF_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONF_FILE"
  if [ -z "$UDS" ] && [ -n "${RCLIPBOARD_BIND_UDS:-}" ]; then UDS="$RCLIPBOARD_BIND_UDS"; fi
  if [ -z "${HOST:-}" ] && [ -n "${RCLIPBOARD_BIND_ADDR:-}" ]; then HOST="$RCLIPBOARD_BIND_ADDR"; fi
  if [ -z "${PORT:-}" ] && [ -n "${RCLIPBOARD_BIND_PORT:-}" ]; then PORT="$RCLIPBOARD_BIND_PORT"; fi
fi

if [ -n "$UDS" ]; then
  exec "$RCLIP_BIN" publish -t "$RCLIP_TOPIC" --encoding "$RCLIP_ENCODING" --uds "$UDS" --app "$RCLIP_APP"
else
  exec "$RCLIP_BIN" publish -t "$RCLIP_TOPIC" --encoding "$RCLIP_ENCODING" --host "$HOST" --port "$PORT" --app "$RCLIP_APP"
fi
