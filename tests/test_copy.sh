#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$DIR/.." && pwd)"

fail=0
run_copy() {
    # $1 = mode arg string (may be empty); remaining env vars set by caller
    local tmp; tmp="$(mktemp)"
    FAKE_LOG="$tmp" PATH="$DIR:$PATH" RCLIP_BIN=fake-rclipctl \
        bash "$PLUGIN_DIR/scripts/copy.sh" $1 </dev/null || true
    cat "$tmp"; rm -f "$tmp"
}

assert_contains() { # haystack needle label
    if [[ "$1" != *"$2"* ]]; then echo "FAIL: $3 (got: $1)"; fail=1;
    else echo "ok: $3"; fi
}
assert_not_contains() {
    if [[ "$1" == *"$2"* ]]; then echo "FAIL: $3 (got: $1)"; fail=1;
    else echo "ok: $3"; fi
}

# The fake needs a topic; copy.sh sets defaults.
out="$(run_copy '--mode clear')"
assert_contains "$out" "put" "clear invokes put"
assert_not_contains "$out" "-E" "clear has no -E"

out="$(run_copy '--mode encrypted')"
assert_contains "$out" "-E" "encrypted adds -E"
assert_contains "$out" "--fetch-keys" "encrypted adds --fetch-keys"

out="$(run_copy '')"
assert_not_contains "$out" "-E" "no-arg defaults to clear"

exit $fail
