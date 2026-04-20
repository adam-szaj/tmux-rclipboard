#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}

content=$("$RCLIP_BIN" get -t "$RCLIP_TOPIC" 2>/dev/null || true)
if [ -n "$content" ]; then
  printf '%s' "$content" | tmux load-buffer -
  tmux paste-buffer -d
fi
