#!/usr/bin/env bash
set -euo pipefail

PLUG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST=${RCLIP_HOST:-127.0.0.1}
PORT=${RCLIP_PORT:-8989}
TOPIC=${RCLIP_TOPIC:-c}

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found" >&2; exit 1
fi

sess="rclip_demo_$$"

# Create a detached session
tmux new-session -d -s "$sess" -x 120 -y 30 "bash -lc 'echo rclip-demo; sleep 0.1'"

# Publish a demo message via plugin script
msg="HelloFromDemo"
tmux run-shell -t "$sess":0.0 \
  "printf '%s' '$msg' | RCLIP_HOST=$HOST RCLIP_PORT=$PORT RCLIP_TOPIC=$TOPIC RCLIP_ENCODING=base64 RCLIP_APP=tmux '$PLUG_DIR/scripts/publish.sh'"

sleep 0.3

# Paste via plugin script
tmux run-shell -t "$sess":0.0 \
  "RCLIP_HOST=$HOST RCLIP_PORT=$PORT RCLIP_TOPIC=$TOPIC RCLIP_ENCODING=hex '$PLUG_DIR/scripts/paste.sh'"

sleep 0.3

out=$(tmux capture-pane -pt "$sess":0.0 -S -50)

tmux kill-session -t "$sess" >/dev/null 2>&1 || true

if grep -q "$msg" <<<"$out"; then
  echo "OK: pasted message found"
  exit 0
else
  echo "FAIL: pasted message not found" >&2
  echo "Captured output:" >&2
  echo "$out" >&2
  exit 2
fi

