#!/usr/bin/env bash

# 优先使用 Aerospace 事件传入的工作区；手动执行脚本时再直接查询当前工作区。
focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# 在临时文件里记录上一次聚焦的工作区，让普通切换只更新两个 item。
state_file="${TMPDIR:-/tmp}/sketchybar_aerospace_focused_workspace"
previous=""
args=()
workspaces=(1 2 3 Q W E)

# 如果存在缓存，就读取上一次事件记录的工作区。
if [ -f "$state_file" ]; then
  previous="$(cat "$state_file")"
fi

# 把选中工作区需要设置的 SketchyBar 属性加入批量参数。
set_focused() {
  args+=(
    --set "space.$1"
    background.color=0xFF6495ED
    label.shadow.drawing=off
    icon.shadow.drawing=off
    background.border_width=2
  )
}

# 把非选中工作区需要设置的 SketchyBar 属性加入批量参数。
set_unfocused() {
  args+=(
    --set "space.$1"
    background.color=0x44FFFFFF
    label.shadow.drawing=off
    icon.shadow.drawing=off
    background.border_width=0
  )
}

# 快速路径：已知上一个工作区时，只更新旧焦点和新焦点。
if [ -n "$previous" ] && [ "$previous" != "$focused" ]; then
  set_unfocused "$previous"
  set_focused "$focused"
else
  # 冷启动或重复事件时全量重建状态，避免残留错误高亮。
  for sid in "${workspaces[@]}"; do
    if [ "$sid" = "$focused" ]; then
      set_focused "$sid"
    else
      set_unfocused "$sid"
    fi
  done
fi

# 用一次 SketchyBar 调用发送所有变更，减少逐 workspace 调用的进程开销。
sketchybar "${args[@]}"

# 保存当前焦点，供下一次事件走只更新两个 item 的快速路径。
printf '%s\n' "$focused" >"$state_file"
