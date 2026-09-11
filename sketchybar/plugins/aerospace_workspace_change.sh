#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
WM_MODE="$(cat "$CONFIG_DIR/wm_mode" 2>/dev/null)"
case "$WM_MODE" in
  aerospace|rift) ;;
  *) WM_MODE="aerospace" ;;
esac

workspaces=(1 2 3 Q W E)

workspace_known() {
  local target="$1"
  local sid

  for sid in "${workspaces[@]}"; do
    if [ "$sid" = "$target" ]; then
      return 0
    fi
  done
  return 1
}

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

get_current_focused_workspace() {
  if [ "$WM_MODE" = "aerospace" ]; then
    aerospace list-workspaces --focused 2>/dev/null
  else
    get_rift_focused_workspace
  fi
}

token_file="${TMPDIR:-/tmp}/sketchybar_${WM_MODE}_focused_workspace_event"
token="$$.$RANDOM.$RANDOM"
args=()

token_is_latest() {
  local latest=""

  if ! IFS= read -r latest <"$token_file" 2>/dev/null; then
    return 1
  fi
  [ "$latest" = "$token" ]
}

# 标记最新事件。旧脚本实例如果晚到，不再覆盖当前颜色。
printf '%s\n' "$token" >"$token_file"

if [ "$WM_MODE" = "aerospace" ]; then
  # AeroSpace 多显示器快速切换时，事件传入的 workspace 可能已经过期；
  # 这里以窗口管理器当前状态为准，避免旧事件把颜色改回去。
  focused="$(get_current_focused_workspace)"
else
  focused="${RIFT_WORKSPACE_NAME:-${FOCUSED_WORKSPACE:-}}"
  if [ -z "$focused" ]; then
    focused="$(get_current_focused_workspace)"
  fi
fi

# 如果更新过程中又来了新事件，当前实例直接退出，让最新实例负责渲染。
if ! token_is_latest; then
  exit 0
fi

# 仍无法判断焦点或焦点不在栏上时不刷新，避免错误高亮。
if [ -z "$focused" ] || ! workspace_known "$focused"; then
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

# 每次都全量重建焦点颜色。只有 6 个 workspace，一次 SketchyBar 调用比维护
# previous 状态更稳，尤其是多显示器下的连续 workspace 事件。
for sid in "${workspaces[@]}"; do
  if [ "$sid" = "$focused" ]; then
    set_focused "$sid"
  else
    set_unfocused "$sid"
  fi
done

if ! token_is_latest; then
  exit 0
fi

# 用一次 SketchyBar 调用发送所有变更，减少逐 workspace 调用的进程开销。
sketchybar "${args[@]}"
