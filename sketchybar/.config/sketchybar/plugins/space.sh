#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

WORKSPACE="${NAME#space.}"
FOCUSED_WORKSPACE="${FOCUSED_WORKSPACE:-$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)}"
FOCUSED_WORKSPACE="${FOCUSED_WORKSPACE:-1}"

if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on \
                         background.color=$BLUE \
                         background.height=25 \
                         label.color=$BLACK \
                         icon.color=$BLACK
else
  sketchybar --set $NAME background.drawing=off \
                         label.color=$WHITE\
                         icon.color=$WHITE
fi
