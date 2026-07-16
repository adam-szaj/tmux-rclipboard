#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$DIR/.." && pwd)"

fail=0
# register.sh inline: token from stdin line 1, label from line 2 (blank=default)
tmp="$(mktemp)"
printf 'my-token\nlaptop\n' | \
    FAKE_LOG="$tmp" PATH="$DIR:$PATH" RCLIP_BIN=fake-rclipctl RCLIP_POPUP=0 \
    bash "$PLUGIN_DIR/scripts/register.sh" || true
out="$(cat "$tmp")"; rm -f "$tmp"
[[ "$out" == *"register"* ]] && echo "ok: calls register" || { echo "FAIL: calls register (got: $out)"; fail=1; }
[[ "$out" == *"--token my-token"* ]] && echo "ok: passes token" || { echo "FAIL: passes token (got: $out)"; fail=1; }
[[ "$out" == *"--label laptop"* ]] && echo "ok: passes label" || { echo "FAIL: passes label (got: $out)"; fail=1; }

# unregister.sh inline: confirm 'y' on stdin
tmp="$(mktemp)"
printf 'y\n' | \
    FAKE_LOG="$tmp" PATH="$DIR:$PATH" RCLIP_BIN=fake-rclipctl RCLIP_POPUP=0 \
    bash "$PLUGIN_DIR/scripts/unregister.sh" || true
out="$(cat "$tmp")"; rm -f "$tmp"
[[ "$out" == *"unregister"* ]] && echo "ok: calls unregister" || { echo "FAIL: calls unregister (got: $out)"; fail=1; }

exit $fail
