# tmux-rclipboard

A minimal tmux plugin that integrates rclipboard with tmux copy/paste and shows rclipboard health in the status bar.

Features
- Copy current tmux selection to rclipboard (topic c/p/s) via `rclipctl`.
- Paste the latest value from rclipboard into the current pane (no-op if topic is empty).
- Optional status-right segment showing service health, xsel state, proxy state, and topic count.

Requirements
- rclipboard HTTP service running (see top-level README).
- `rclipctl` available on PATH.
- `curl` and `jq` installed.

Install (TPM)
- In `~/.tmux.conf`:
  set -g @plugin 'tmux-plugins/tpm'
  set -g @plugin 'your/repo/tmux-rclipboard'
  run '~/.tmux/plugins/tpm/tpm'

Install (local, without TPM)
- Source the plugin file directly:
  run-shell '/path/to/repo/tmux-rclipboard/rclipboard.tmux'

Options (tmux @options)
- `@rclip_topic` (default: c)          — clipboard topic to read/write
- `@rclip_app` (default: tmux)         — meta.app tag sent with clip.put
- `@rclip_status` (default: on)        — enable status-right segment
- `@rclip_status_format` (default: normal) — controls status detail level:
    minimal  — ok/down indicator only
    normal   — ok + xsel + proxy state (default)
    full     — normal + active topic count
- `@rclip_bin` (default: rclipctl)     — path to rclipctl binary

Key Bindings (defaults)
- Copy (copy-mode-vi): `y` → copy selection to rclipboard
- Paste (normal mode): `]` → fetch from rclipboard and paste into pane

Note: `]` replaces tmux's built-in paste-buffer binding. If you want a
copy-mode-vi paste binding too, add to `~/.tmux.conf`:
  bind-key -T copy-mode-vi P send -X cancel \; \
    run-shell "RCLIP_TOPIC=c /path/to/tmux-rclipboard/scripts/paste.sh"

Status Bar
- normal:  `📋: ✔ xsel:✗ pxy:—`
  - `✔` / `✗` — server up/down
  - `xsel:✔/✗` — X11 clipboard integration (yellow when disabled, green when ok)
  - `pxy:✔/✗/—` — proxy: green=connected, red=enabled but not connected, grey dash=disabled
- full:    adds `topics:2` — number of topics currently stored

Example (append to ~/.tmux.conf)
  set -g @rclip_topic 'c'
  set -g @rclip_status 'on'
  set -g @rclip_status_format 'normal'
  run-shell '/path/to/repo/tmux-rclipboard/rclipboard.tmux'

License
- See repository license. This plugin ships as part of rclipboard.
