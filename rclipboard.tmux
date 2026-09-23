#!/usr/bin/env bash
# rclipboard tmux plugin: bindings and status helpers

tmux_option() {
    tmux show-option -gqv "$1"
}

rclip_bin=~/.config/rclipboard/bin/rclipctl
# basic | reach
# RCLIP_FONT_STYLE=$(tmux_option '@rclip_font_style');
# : "${RCLIP_FONT_STYLE:-basic}"
RCLIP_BIN=$(tmux_option '@rclip_bin'); : "${RCLIP_BIN:-${rclip_bin}}"
RCLIP_TOPIC=$(tmux_option '@rclip_topic'); : "${RCLIP_TOPIC:-c}"
RCLIP_APP=$(tmux_option '@rclip_app'); : "${RCLIP_APP:-tmux}"
RCLIP_STATUS=$(tmux_option '@rclip_status'); : "${RCLIP_STATUS:-on}"
RCLIP_BIN=$(tmux_option '@rclip_bin'); : "${RCLIP_BIN:=rclipctl}"
RCLIP_STATUS_FORMAT=$(tmux_option '@rclip_status_format'); : "${RCLIP_STATUS_FORMAT:=normal}"
RCLIP_BUFFER=$(tmux_option '@rclip_sticky_buffer'); : "${RCLIP_BUFFER:=default}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export env for scripts
export RCLIP_TOPIC RCLIP_APP RCLIP_BIN RCLIP_STATUS_FORMAT RCLIP_BUFFER

main() {
    # Define commands
    tmux set -gq @rclip_copy_cmd "${SCRIPT_DIR}/scripts/copy.sh"
    tmux set -gq @rclip_paste_cmd "${SCRIPT_DIR}/scripts/paste.sh"
    tmux set -gq @rclip_health_cmd "${SCRIPT_DIR}/scripts/health.sh"
    tmux set -gq @rclip_sticky_paste_cmd "RCLIP_BIN=${RCLIP_BIN} RCLIP_BUFFER=${RCLIP_BUFFER} ${SCRIPT_DIR}/scripts/sticky.sh --mode paste"
    tmux set -gq @rclip_sticky_print_cmd "RCLIP_BIN=${RCLIP_BIN} RCLIP_BUFFER=${RCLIP_BUFFER} ${SCRIPT_DIR}/scripts/sticky.sh --mode print"

    # Encryption mode for *-default commands (user sets in .tmux.conf).
    tmux set -gq @rclip_encrypt off

    # Per-mode copy/paste commands (bind these yourself; defaults unchanged).
    local envp="RCLIP_BIN=${RCLIP_BIN} RCLIP_TOPIC=${RCLIP_TOPIC} RCLIP_APP=${RCLIP_APP}"
    tmux set -gq @rclip_copy_clear_cmd      "${envp} ${SCRIPT_DIR}/scripts/copy.sh --mode clear"
    tmux set -gq @rclip_copy_encrypted_cmd  "${envp} ${SCRIPT_DIR}/scripts/copy.sh --mode encrypted"
    tmux set -gq @rclip_copy_default_cmd    "${envp} ${SCRIPT_DIR}/scripts/copy.sh --mode default"
    tmux set -gq @rclip_paste_clear_cmd     "${envp} ${SCRIPT_DIR}/scripts/paste.sh --mode clear"
    tmux set -gq @rclip_paste_encrypted_cmd "${envp} ${SCRIPT_DIR}/scripts/paste.sh --mode encrypted"
    tmux set -gq @rclip_paste_default_cmd   "${envp} ${SCRIPT_DIR}/scripts/paste.sh --mode default"
    tmux set -gq @rclip_register_cmd        "RCLIP_BIN=${RCLIP_BIN} ${SCRIPT_DIR}/scripts/register.sh"
    tmux set -gq @rclip_unregister_cmd      "RCLIP_BIN=${RCLIP_BIN} ${SCRIPT_DIR}/scripts/unregister.sh"

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
            seg="#(RCLIP_BIN=${RCLIP_BIN} RCLIP_STATUS_FORMAT=${RCLIP_STATUS_FORMAT} ${SCRIPT_DIR}/scripts/health.sh)"
            tmux set -g status-right "${seg}${current}"
        fi
    fi
}

main
