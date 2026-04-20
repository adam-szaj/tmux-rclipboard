#!/usr/bin/env bash
# rclipboard tmux plugin: bindings and status helpers

tmux_option() {
    tmux show-option -gqv "$1"
}

RCLIP_TOPIC=$(tmux_option '@rclip_topic'); : "${RCLIP_TOPIC:=c}"
RCLIP_APP=$(tmux_option '@rclip_app'); : "${RCLIP_APP:=tmux}"
RCLIP_STATUS=$(tmux_option '@rclip_status'); : "${RCLIP_STATUS:=on}"
RCLIP_BIN=$(tmux_option '@rclip_bin'); : "${RCLIP_BIN:=rclipctl}"
RCLIP_STATUS_FORMAT=$(tmux_option '@rclip_status_format'); : "${RCLIP_STATUS_FORMAT:=normal}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export env for scripts
export RCLIP_TOPIC RCLIP_APP RCLIP_BIN RCLIP_STATUS_FORMAT

main() {
    # Define commands
    tmux set -gq @rclip_copy_cmd "${SCRIPT_DIR}/scripts/copy.sh"
    tmux set -gq @rclip_paste_cmd "${SCRIPT_DIR}/scripts/paste.sh"
    tmux set -gq @rclip_health_cmd "${SCRIPT_DIR}/scripts/health.sh"

    # Default key bindings (customize by overriding in .tmux.conf)
    # Copy current selection to rclipboard (clipboard topic)
    tmux unbind-key ]
    local copy_cmd="RCLIP_BIN=${RCLIP_BIN} RCLIP_TOPIC=${RCLIP_TOPIC} RCLIP_APP=${RCLIP_APP} ${SCRIPT_DIR}/scripts/copy.sh"
    tmux bind-key -T copy-mode-vi y                  send -X copy-pipe-and-cancel "$copy_cmd"
    tmux bind-key -T copy-mode-vi Enter              send -X copy-pipe-and-cancel "$copy_cmd"
    tmux bind-key -T copy-mode-vi MouseDragEnd1Pane  send -X copy-pipe-and-cancel "$copy_cmd"
    # ] pastes from rclipboard (replaces tmux default paste-buffer).
    # To also bind a copy-mode-vi paste key, add to ~/.tmux.conf:
    #   bind-key -T copy-mode-vi P send -X cancel \; run-shell "... paste.sh"
    tmux bind-key ] run-shell \
        "RCLIP_BIN=${RCLIP_BIN} RCLIP_TOPIC=${RCLIP_TOPIC} ${SCRIPT_DIR}/scripts/paste.sh"

    # Status bar segment (optional)
    if [ "${RCLIP_STATUS}" = "on" ]; then
        # Prepend health to status-right if not already present
        current=$(tmux show-option -gqv status-right)
        if [[ "$current" != *"health.sh"* ]]; then
            seg="#[fg=colour244]📋:#[default]#(RCLIP_BIN=${RCLIP_BIN} RCLIP_STATUS_FORMAT=${RCLIP_STATUS_FORMAT} ${SCRIPT_DIR}/scripts/health.sh)"
            tmux set -g status-right "${seg}${current}"
        fi
    fi
}

main
