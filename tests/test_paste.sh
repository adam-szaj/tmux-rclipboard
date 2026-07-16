#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$DIR/.." && pwd)"

# Stub tmux: record calls, return @rclip_encrypt from $RCLIP_ENCRYPT_OPT.
STUB_BIN="$(mktemp -d)"
cat > "$STUB_BIN/tmux" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = "show-option" ]; then printf '%s' "${RCLIP_ENCRYPT_OPT:-}"; exit 0; fi
exit 0
EOF
chmod +x "$STUB_BIN/tmux"

fail=0
run_paste() {
    local tmp; tmp="$(mktemp)"
    FAKE_LOG="$tmp" PATH="$DIR:$STUB_BIN:$PATH" RCLIP_BIN=fake-rclipctl \
        RCLIP_ENCRYPT_OPT="${2:-}" \
        bash "$PLUGIN_DIR/scripts/paste.sh" $1 </dev/null || true
    cat "$tmp"; rm -f "$tmp"
}
assert_contains(){ [[ "$1" == *"$2"* ]] && echo "ok: $3" || { echo "FAIL: $3 (got: $1)"; fail=1; }; }
assert_not_contains(){ [[ "$1" != *"$2"* ]] && echo "ok: $3" || { echo "FAIL: $3 (got: $1)"; fail=1; }; }

out="$(run_paste '--mode clear')"
assert_contains "$out" "get" "clear invokes get"
assert_not_contains "$out" "--decrypt" "clear has no --decrypt"

out="$(run_paste '--mode encrypted')"
assert_contains "$out" "--decrypt" "encrypted adds --decrypt"

out="$(run_paste '--mode default' 'on')"
assert_contains "$out" "--decrypt" "default+on → decrypt"

out="$(run_paste '--mode default' 'off')"
assert_not_contains "$out" "--decrypt" "default+off → no decrypt"

# Regression: --mode without value should exit 2, not crash with shift error
tmp="$(mktemp)"
exit_code=0
FAKE_LOG="$tmp" PATH="$DIR:$STUB_BIN:$PATH" RCLIP_BIN=fake-rclipctl \
    bash "$PLUGIN_DIR/scripts/paste.sh" --mode </dev/null || exit_code=$?
rm -f "$tmp"
if [ $exit_code -eq 2 ]; then echo "ok: --mode without value exits 2"; else echo "FAIL: --mode without value exits $exit_code (expected 2)"; fail=1; fi

rm -rf "$STUB_BIN"
exit $fail
