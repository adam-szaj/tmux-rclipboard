# tmux-rclipboard

A minimal tmux plugin that integrates rclipboard with tmux copy/paste and shows rclipboard health in the status bar.

Features
- Copy current tmux selection to rclipboard (topic c/p/s) via `clipctl2`.
- Paste the latest value from rclipboard into the current pane.
- Optional status-right segment with health of the rclipboard service (ok/xsel/proxy).

Requirements
- rclipboard HTTP service running (see top-level README).
- `clipctl2` available on PATH.
- `curl`, `jq`, and `xxd` (for hex decode) installed.

Install (TPM)
- In `~/.tmux.conf`:
  set -g @plugin 'tmux-plugins/tpm'
  set -g @plugin 'your/repo/tmux-rclipboard'
  run '~/.tmux/plugins/tpm/tpm'

Install (local, without TPM)
- Source the plugin file directly:
  run-shell '/path/to/repo/tmux-rclipboard/rclipboard.tmux'

Options (tmux @options)
- `@rclip_host` (default: 127.0.0.1)
- `@rclip_port` (default: 8989)
- `@rclip_topic` (default: c)
- `@rclip_encoding` (default: base64)
- `@rclip_app` (default: tmux)
- `@rclip_status` (default: on) — enable status segment
- `@rclip_bin` (default: clipctl2)

Key Bindings (defaults)
- Copy (copy-mode-vi): `y` → publish selection to rclipboard
- Paste: `P` → fetch from rclipboard and paste into pane

Status Bar
- Adds a segment like: `rc: up xsel:✓ pxy:✓` with colors.

Example (append to ~/.tmux.conf)
  set -g @rclip_host '127.0.0.1'
  set -g @rclip_port '8989'
  set -g @rclip_topic 'c'
  set -g @rclip_encoding 'base64'
  set -g @rclip_status 'on'
  run-shell '/path/to/repo/tmux-rclipboard/rclipboard.tmux'

License
- See repository license. This plugin ships as part of rclipboard.
