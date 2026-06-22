#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
WM_MODE="$(cat "$CONFIG_DIR/wm_mode" 2>/dev/null)"
case "$WM_MODE" in
  aerospace|rift) ;;
  *) WM_MODE="aerospace" ;;
esac

workspaces=(1 2 3 Q W E)

get_rift_focused_workspace() {
  local jq_bin="${JQ:-}"
  local workspace_json
  local focused_name
  local focused_index

  # Rift 事件通常会直接传入 RIFT_WORKSPACE_NAME；这里仅处理冷启动或事件缺字段的兜底查询。
  if [ -z "$jq_bin" ]; then
    if [ -x /opt/homebrew/bin/jq ]; then
      jq_bin="/opt/homebrew/bin/jq"
    else
      jq_bin="$(command -v jq 2>/dev/null)"
    fi
  fi
  if [ -z "$jq_bin" ]; then
    return
  fi

  workspace_json="$(rift-cli query workspaces 2>/dev/null)"
  if [ -z "$workspace_json" ]; then
    return
  fi

  focused_name="$(
    printf '%s\n' "$workspace_json" |
      "$jq_bin" -r '.[] | select((.focused // .is_focused // .active // .is_active // false) == true) | (.name // .label // empty)' 2>/dev/null |
      head -n 1
  )"
  if [ -n "$focused_name" ]; then
    printf '%s\n' "$focused_name"
    return
  fi

  # 如果 Rift 只返回运行期 index，就按栏上固定显示顺序映射回 1/2/3/Q/W/E。
  focused_index="$(
    printf '%s\n' "$workspace_json" |
      "$jq_bin" -r '.[] | select((.focused // .is_focused // .active // .is_active // false) == true) | (.index // empty)' 2>/dev/null |
      head -n 1
  )"
  case "$focused_index" in
    ''|*[!0-9]*) return ;;
  esac
  if [ -n "${workspaces[$focused_index]}" ]; then
    printf '%s\n' "${workspaces[$focused_index]}"
  fi
}

# 优先使用窗口管理器事件传入的工作区；Rift 的事件使用 workspace name，对应当前栏里的 1/2/3/Q/W/E。
focused="${FOCUSED_WORKSPACE:-${RIFT_WORKSPACE_NAME:-}}"
if [ -z "$focused" ]; then
  if [ "$WM_MODE" = "aerospace" ]; then
    focused="$(aerospace list-workspaces --focused 2>/dev/null)"
  else
    focused="$(get_rift_focused_workspace)"
  fi
fi

# 在临时文件里记录上一次聚焦的工作区，让普通切换只更新两个 item。
state_file="${TMPDIR:-/tmp}/sketchybar_${WM_MODE}_focused_workspace"
previous=""
args=()

# 如果存在缓存，就读取上一次事件记录的工作区。
if [ -f "$state_file" ]; then
  previous="$(cat "$state_file")"
fi

# 仍无法判断焦点时不刷新，避免把工作区 1 错误高亮后再触发额外修正。
if [ -z "$focused" ]; then
  exit 0
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
