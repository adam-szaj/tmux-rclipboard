#!/usr/bin/env bash
set -uo pipefail

RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_STATUS_FORMAT=${RCLIP_STATUS_FORMAT:-normal}

out=$(${RCLIP_BIN} health 2>&1 || true)

if [ -z "$out" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi

ok=$(printf '%s' "$out" | jq -r '.ok')

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
  topics=$(${RCLIP_BIN} topics 2>/dev/null | jq -r '.topics | length' 2>/dev/null || echo '?')
  printf ' topics:#[fg=colour250]%s#[default]' "$topics"
fi

printf ' '
