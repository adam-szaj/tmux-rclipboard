#!/usr/bin/env bash
set -uo pipefail

. ~/.bash_setup_path

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_STATUS_FORMAT=${RCLIP_STATUS_FORMAT:-normal}

out=$(${RCLIP_BIN} health 2>/dev/null || true)

if [ -z "$out" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi

ok=$(printf '%s' "$out" | jq -r '.ok' 2>/dev/null || echo "false")
if [ "$ok" != "true" ] && [ "$ok" != "false" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi

if [ "$ok" = "true" ]; then
  printf '#[fg=green]✔#[default]'
else
  printf '#[fg=red]✗#[default]'
fi

if [ "$RCLIP_STATUS_FORMAT" = "minimal" ]; then
  printf ' '
  exit 0
fi

xok=$(printf '%s' "$out" | jq -r '.xsel_good')
proxy_enabled=$(printf '%s' "$out" | jq -r '.proxy_enabled')
proxy_good=$(printf '%s' "$out" | jq -r '.proxy_good')

printf ' '
if [ "$xok" = "true" ]; then
  printf 'xsel:#[fg=green]✔#[default]'
else
  printf 'xsel:#[fg=yellow]✗#[default]'
fi
printf ' '

if [ "$proxy_enabled" = "false" ]; then
  printf 'pxy:#[fg=colour244]—#[default]'
elif [ "$proxy_good" = "true" ]; then
  printf 'pxy:#[fg=green]✔#[default]'
else
  printf 'pxy:#[fg=red]✗#[default]'
fi

if [ "$RCLIP_STATUS_FORMAT" = "full" ]; then
  mon=$(${RCLIP_BIN} monitor status --format tmux 2>/dev/null || true)
  if [ -n "$mon" ]; then
    printf '%s' "$mon"
    exit 0
  fi
fi

printf ' '
