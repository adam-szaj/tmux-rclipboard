#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}
RCLIP_APP=${RCLIP_APP:-tmux}

exec "$RCLIP_BIN" put -t "$RCLIP_TOPIC" --app "$RCLIP_APP"
