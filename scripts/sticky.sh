#!/usr/bin/env bash
set -euo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_BUFFER=${RCLIP_BUFFER:-default}
mode=paste
while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            [ $# -ge 2 ] || { echo "usage: sticky.sh [--mode paste|print]" >&2; exit 2; }
            mode="$2"; shift 2 ;;
        *) echo "usage: sticky.sh [--mode paste|print]" >&2; exit 2 ;;
    esac
done
case "$mode" in
    paste|print) ;;
    *) echo "sticky.sh: invalid mode '$mode'" >&2; exit 2 ;;
esac

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sticky.sh"
shell_quote() { printf "'%s'" "${1//\'/\'\\\'\'}"; }
if [ "${RCLIP_PICKER_POPUP:-1}" = "1" ] && [ -n "${TMUX:-}" ]; then
    command="RCLIP_PICKER_POPUP=0 RCLIP_BIN=$(shell_quote "$RCLIP_BIN") RCLIP_BUFFER=$(shell_quote "$RCLIP_BUFFER") bash $(shell_quote "$SELF") --mode $(shell_quote "$mode")"
    exec tmux display-popup -E -w 80% -h 70% "$command"
fi

if ! command -v fzf >/dev/null 2>&1; then
    echo "sticky picker requires fzf" >&2
    exit 1
fi

notes=$("$RCLIP_BIN" sticky list --buffer "$RCLIP_BUFFER" --json)
if [ "$(printf '%s' "$notes" | jq 'length')" -eq 0 ]; then
    echo "No sticky notes in buffer '$RCLIP_BUFFER'."
    exit 0
fi
selected=$(printf '%s' "$notes" | jq -r \
    '.[] | [.id, (.labels | join(",")), (.content | split("\n")[0] | gsub("[\t\r]"; " "))] | @tsv' \
    | fzf --delimiter="$(printf '\t')" --with-nth=2.. --prompt="Sticky note> " --layout=reverse --border) || exit 0
note_id=${selected%%$'\t'*}

case "$mode" in
    paste)
        "$RCLIP_BIN" sticky paste "$note_id" --buffer "$RCLIP_BUFFER" | tmux load-buffer -
        tmux paste-buffer -d
        ;;
    print)
        if command -v less >/dev/null 2>&1; then
            "$RCLIP_BIN" sticky print "$note_id" --buffer "$RCLIP_BUFFER" | less
        else
            "$RCLIP_BIN" sticky print "$note_id" --buffer "$RCLIP_BUFFER"
            printf '\n\nPress Enter to close'
            read -r _ || true
        fi
        ;;
esac
