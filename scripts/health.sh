#!/usr/bin/env bash
set -uo pipefail

# Load shared config
RCLIP_BIN=${RCLIP_BIN:-rclipctl}
RCLIP_TOPIC=${RCLIP_TOPIC:-c}

out=$(${RCLIP_BIN} health 2>&1 || true)

if [ -z "$out" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi
ok=$(printf '%s' "$out" | jq -r '.ok')
xok=$(printf '%s' "$out" | jq -r '.xsel_good')
pc=$(printf '%s' "$out" | jq -r '.proxy_connected')

if [ "$ok" = "true" ]; then
  printf '#[fg=green]up#[default]'
else
  printf '#[fg=red]down#[default]'
fi
printf ' '
if [ "$xok" = "true" ]; then
  printf 'xsel:#[fg=green]✓#[default]'
else
  printf 'xsel:#[fg=yellow]!#[default]'
fi
printf ' '
if [ "$pc" = "true" ]; then
  printf 'pxy:#[fg=green]✓#[default]'
fi
