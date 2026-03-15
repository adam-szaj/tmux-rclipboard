#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}

("$RCLIP_BIN" get -t "$RCLIP_TOPIC" || true) | tmux load-buffer -
tmux paste-buffer -d
