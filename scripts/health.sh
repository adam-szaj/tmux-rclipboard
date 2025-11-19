#!/usr/bin/env bash
set -euo pipefail

HOST=${RCLIP_HOST:-127.0.0.1}
PORT=${RCLIP_PORT:-8989}
UDS=${RCLIP_UDS:-}

# Load shared config
CONF_FILE=${RCLIP_CONF:-"$HOME/.config/rclipboard/env"}
if [ -r "$CONF_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONF_FILE"
  if [ -z "$UDS" ] && [ -n "${RCLIPBOARD_BIND_UDS:-}" ]; then UDS="$RCLIPBOARD_BIND_UDS"; fi
  if [ -z "${HOST:-}" ] && [ -n "${RCLIPBOARD_BIND_ADDR:-}" ]; then HOST="$RCLIPBOARD_BIND_ADDR"; fi
  if [ -z "${PORT:-}" ] && [ -n "${RCLIPBOARD_BIND_PORT:-}" ]; then PORT="$RCLIPBOARD_BIND_PORT"; fi
fi

if [ -n "$UDS" ]; then
  out=$(clipctl2 health --uds "$UDS" 2>/dev/null || true)
else
  out=$(clipctl2 health --host "$HOST" --port "$PORT" 2>/dev/null || true)
fi
if [ -z "$out" ]; then
  printf '#[fg=red]down#[default]'
  exit 0
fi
ok=$(printf '%s' "$out" | jq -r '.ok')
xok=$(printf '%s' "$out" | jq -r '.xsel_ok')
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
else
  printf 'pxy:#[fg=colour244]-#[default]'
fi
