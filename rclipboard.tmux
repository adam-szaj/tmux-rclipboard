#!/usr/bin/env bash
# rclipboard tmux plugin: bindings and status helpers

tmux_option() {
  tmux show-option -gqv "$1"
}

RCLIP_HOST=$(tmux_option '@rclip_host'); : "${RCLIP_HOST:=127.0.0.1}"
RCLIP_PORT=$(tmux_option '@rclip_port'); : "${RCLIP_PORT:=8989}"
RCLIP_TOPIC=$(tmux_option '@rclip_topic'); : "${RCLIP_TOPIC:=c}"
RCLIP_UDS=$(tmux_option '@rclip_uds'); : "${RCLIP_UDS:=${XDG_RUNTIME_DIR}/rclipboard.sock}"
RCLIP_ENCODING=$(tmux_option '@rclip_encoding'); : "${RCLIP_ENCODING:=base64}"
RCLIP_APP=$(tmux_option '@rclip_app'); : "${RCLIP_APP:=tmux}"
RCLIP_STATUS=$(tmux_option '@rclip_status'); : "${RCLIP_STATUS:=on}"
RCLIP_BIN=$(tmux_option '@rclip_bin'); : "${RCLIP_BIN:=rclipctl}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export env for scripts
export RCLIP_HOST RCLIP_PORT RCLIP_TOPIC RCLIP_ENCODING RCLIP_APP RCLIP_BIN

# Define commands
tmux set -gq @rclip_publish_cmd "${SCRIPT_DIR}/scripts/publish.sh"
tmux set -gq @rclip_paste_cmd "${SCRIPT_DIR}/scripts/paste.sh"
tmux set -gq @rclip_health_cmd "${SCRIPT_DIR}/scripts/health.sh"

# Default key bindings (customize by overriding in .tmux.conf)
# Copy current selection to rclipboard (clipboard topic)

tmux bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "RCLIP_TOPIC=${RCLIP_TOPIC} RCLIP_ENCODING=${RCLIP_ENCODING} RCLIP_APP=${RCLIP_APP} ${SCRIPT_DIR}/scripts/publish.sh"
tmux bind-key ] run-shell "RCLIP_TOPIC=${RCLIP_TOPIC} RCLIP_ADDR=${RCLIP_ADDR} RCLIP_PORT=${RCLIP_PORT} RCLIP_UDS=${RCLIP_UDS} RCLIP_ENCODING=${RCLIP_ENCODING} ${SCRIPT_DIR}/scripts/paste.sh"

# Status bar segment (optional)
if [ "${RCLIP_STATUS}" = "on" ]; then
  # Prepend health to status-right if not already present
  current=$(tmux show-option -gqv status-right)
  seg='
#[fg=colour244]rc:#[default]#(RCLIP_HOST='"${RCLIP_HOST}"' RCLIP_PORT='"${RCLIP_PORT}"' "${SCRIPT_DIR}/scripts/health.sh")'
  if [[ "$current" != *"health.sh"* ]]; then
    tmux set -g status-right "${seg} | ${current}"
  fi
fi
