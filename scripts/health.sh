#!/usr/bin/env bash
set -uo pipefail

tmux_option() {
    tmux show-option -gqv "$1"
}

RCLIP_BIN="$(tmux_option '@rclip_bin')" ; : "${RCLIP_BIN:=rclipctl}"
RCLIP_FONT_STYLE="$(tmux_option '@rclip_font_style')" ; : "${RCLIP_FONT_STYLE:=basic}"
RCLIP_STATUS_FORMAT=$(tmux_option '@rclip_status_format'); : "${RCLIP_STATUS_FORMAT:=normal}"

out=$(${RCLIP_BIN} health 2>/dev/null || true)

if [[ "${RCLIP_FONT_STYLE}" = "basic" ]] ; then
    OK_CHAR=+
    NOK_CHAR=-
    DISABLED_CHAR='\\'
    CLIPBOARD_CHAR='RCB'
else
    OK_CHAR=✔
    NOK_CHAR=✗
    DISABLED_CHAR='—'
    CLIPBOARD_CHAR='📋'
fi

if [ -z "$out" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi

ok=$(printf '%s' "$out" | jq -r '.ok' 2>/dev/null || echo "false")

if [[ "$ok" != "true" ]] && [[ "$ok" != "false" ]]; then
    printf "%s" '#[fg=red]\\#[default]'
    exit 0
fi

print_status() {
    prefix=$1
    value=$2
    if [[ "$#" -gt 2 ]] ; then
        enabled="$3"
    else
        enabled="true"
    fi

    printf '#[fg=colour244]'${prefix}:'#[default]'

    if [[ "${enabled}" = "true" ]] ; then
        if [[ "${value}" = "true" ]]; then
            printf "%s" '#[fg=green]'"${OK_CHAR}"'#[default] '
        else
            printf "%s" '#[fg=red]'"${NOK_CHAR}"'#[default] '
        fi
    else
        printf '#[fg=colour244]'"${DISABLED_CHAR}"'#[default]'
    fi
}

print_status "${CLIPBOARD_CHAR}" "${ok}"

if [[ "$RCLIP_STATUS_FORMAT" = "minimal" ]]; then
    printf ' '
    exit 0
fi

xok=$(jq -r '.xsel_good' <<< "${out}")
proxy_enabled=$(jq -r '.proxy_enabled' <<< "${out}")
proxy_good=$(jq -r '.proxy_good' <<< "${out}")

print_status "xsel" "${xok}"
print_status "pxy" "${proxy_good}" "${proxy_enabled}"

if [ "$RCLIP_STATUS_FORMAT" = "full" ]; then
    mon=$(${RCLIP_BIN} monitor status --format tmux 2>/dev/null || true)
    if [ -n "$mon" ]; then
        printf '%s' "$mon"
        exit 0
    fi
fi

printf ' '
