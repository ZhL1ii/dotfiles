#!/usr/bin/env bash
set -u

workspace_index="${1:-}"
workspace_name="${2:-}"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"
rift_cli="${RIFT_CLI:-/opt/homebrew/bin/rift-cli}"
highlight_pid=""

case "$workspace_index" in
  ''|*[!0-9]*)
    echo "usage: rift_workspace_click.sh workspace_index workspace_name" >&2
    exit 2
    ;;
esac

if [ -n "$workspace_name" ]; then
  RIFT_WORKSPACE_NAME="$workspace_name" "$PLUGIN_DIR/aerospace_workspace_change.sh" >/dev/null 2>&1 &
  highlight_pid="$!"
fi

"$rift_cli" execute workspace switch "$workspace_index"
status=$?

if [ -n "$highlight_pid" ]; then
  wait "$highlight_pid" 2>/dev/null || true
fi

if [ "$status" -ne 0 ]; then
  "$PLUGIN_DIR/aerospace_workspace_change.sh" >/dev/null 2>&1 || true
fi

exit "$status"
