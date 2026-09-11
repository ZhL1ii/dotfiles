#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# 旧的单 workspace 焦点更新脚本；当前快速路径在 aerospace_workspace_change.sh。 （已弃用）
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.color=0x88FF00FF label.shadow.drawing=off icon.shadow.drawing=off background.border_width=2
else
  sketchybar --set "$NAME" background.color=0x44FFFFFF label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
fi
