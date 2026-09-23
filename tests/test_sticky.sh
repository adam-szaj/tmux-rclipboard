#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$DIR/.." && pwd)"
STUB_BIN="$(mktemp -d)"
FAKE_LOG="$STUB_BIN/calls.log"
BUFFER_LOG="$STUB_BIN/buffer.log"
export FAKE_LOG BUFFER_LOG

cat > "$STUB_BIN/rclipctl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FAKE_LOG"
case "${2:-}" in
    list) printf '[{"id":17,"buffer":"notes","content":"first line","labels":["work"]}]' ;;
    paste) printf 'selected\nnote\n' ;;
    print) printf 'selected note' ;;
esac
EOF
cat > "$STUB_BIN/jq" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = "length" ]; then
    cat >/dev/null
    printf '1\n'
else
    cat >/dev/null
    printf '17\twork\tfirst line\n'
fi
EOF
cat > "$STUB_BIN/fzf" <<'EOF'
#!/usr/bin/env bash
IFS= read -r selected
printf '%s\n' "$selected"
EOF
cat > "$STUB_BIN/tmux" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
    load-buffer) cat > "$BUFFER_LOG" ;;
    paste-buffer) printf '%s\n' "$*" >> "$FAKE_LOG" ;;
    display-popup) printf '%s\n' "$*" >> "$FAKE_LOG" ;;
esac
EOF
cat > "$STUB_BIN/less" <<'EOF'
#!/usr/bin/env bash
cat
EOF
chmod +x "$STUB_BIN"/*

fail=0
TMUX=stub RCLIP_PICKER_POPUP=0 RCLIP_BIN=rclipctl RCLIP_BUFFER=notes \
    PATH="$STUB_BIN:$PATH" bash "$PLUGIN_DIR/scripts/sticky.sh" --mode paste
if [[ "$(cat "$BUFFER_LOG")" == $'selected\nnote' ]]; then
    echo "ok: paste mode loads the chosen note into tmux"
else
    echo "FAIL: paste mode content was $(cat "$BUFFER_LOG")"
    fail=1
fi
if rg -q 'sticky paste 17 --buffer notes' "$FAKE_LOG"; then
    echo "ok: picker passes the selected ID and buffer"
else
    echo "FAIL: picker did not pass selected note"
    fail=1
fi

out=$(TMUX=stub RCLIP_PICKER_POPUP=0 RCLIP_BIN=rclipctl RCLIP_BUFFER=notes \
    PATH="$STUB_BIN:$PATH" bash "$PLUGIN_DIR/scripts/sticky.sh" --mode print)
if [ "$out" = "selected note" ]; then
    echo "ok: print mode displays the chosen note"
else
    echo "FAIL: print mode output was '$out'"
    fail=1
fi

TMUX=stub RCLIP_PICKER_POPUP=1 RCLIP_BIN=rclipctl RCLIP_BUFFER=notes \
    PATH="$STUB_BIN:$PATH" bash "$PLUGIN_DIR/scripts/sticky.sh" --mode paste
if rg -q 'display-popup -E -w 80% -h 70%' "$FAKE_LOG" \
    && rg -q 'sticky.sh.*--mode.*paste' "$FAKE_LOG"; then
    echo "ok: picker starts in a tmux popup"
else
    echo "FAIL: picker popup was not launched"
    fail=1
fi

rm -rf "$STUB_BIN"
exit "$fail"
