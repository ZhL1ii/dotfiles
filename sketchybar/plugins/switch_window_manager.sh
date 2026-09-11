#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
case "$mode" in
  aerospace|rift) ;;
  *)
    echo "usage: switch_window_manager.sh aerospace|rift" >&2
    exit 2
    ;;
esac

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
printf '%s\n' "$mode" >"$CONFIG_DIR/wm_mode"

sketchybar --reload
