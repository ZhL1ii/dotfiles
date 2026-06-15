#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
LOCK_DIR="${TMPDIR:-/tmp}/sketchybar_workspace_icons.lock"
args=()
workspaces=(1 2 3 Q W E)

# 刷新过程可能由快速切换连续触发；已有刷新在跑时直接跳过本次。
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

# SketchyBar's native window event can arrive before AeroSpace has finished
# updating its workspace window list for some apps. Give AeroSpace a brief
# moment to settle, while the lock coalesces any duplicate events.
if [ "$SENDER" = "space_windows_change" ]; then
    sleep 0.5
fi

# 复用图标映射函数，避免每个 app 都启动一次 icon_map_fn.sh。
source "$CONFIG_DIR/plugins/icon_map_fn.sh"

update_space_icons() {
    local sid=$1
    local icon_strip=""
    # 直接向 Aerospace 请求 app 名称，避免解析较慢且脆弱的默认表格输出。
    local apps=$(aerospace list-windows --workspace "$sid" --format "%{app-name}")

    if [ "${apps}" != "" ]; then
        icon_strip=" "
        while read -r app; do
            icon_map "$app"
            icon_strip+=" $icon_result"
        done <<<"${apps}"
    fi

    args+=(--set "space.$sid" drawing=on label="$icon_strip")
}

# 按固定显示顺序刷新工作区图标，避免 Aerospace 返回顺序影响 SketchyBar。
for sid in "${workspaces[@]}"; do
    update_space_icons "$sid"
done

# 一次性提交所有 workspace 图标更新，减少 SketchyBar 调用次数。
sketchybar "${args[@]}"
