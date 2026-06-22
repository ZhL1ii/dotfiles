#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
WM_MODE="$(cat "$CONFIG_DIR/wm_mode" 2>/dev/null)"
case "$WM_MODE" in
    aerospace|rift) ;;
    *) WM_MODE="aerospace" ;;
esac

LOCK_DIR="${TMPDIR:-/tmp}/sketchybar_workspace_icons.lock"
PENDING_FILE="${TMPDIR:-/tmp}/sketchybar_workspace_icons.pending"
CACHE_DIR="${TMPDIR:-/tmp}/sketchybar_${WM_MODE}_workspace_icons"
args=()
workspaces=(1 2 3 Q W E)
JQ="${JQ:-}"
FORCE_UPDATE=false
DEFER_RIFT_REFRESH=false
aerospace_windows=""
aerospace_windows_loaded=false
rift_workspaces_json=""
rift_workspaces_loaded=false
rift_apps=()

# 启动或手动执行脚本时，SketchyBar item 可能是刚创建的，不能信任上次进程留下的缓存。
if [ -z "$SENDER" ]; then
    FORCE_UPDATE=true
fi

# Rift 返回 JSON；优先使用 Homebrew 固定路径，失败时再查 PATH，避免交互 shell 环境差异。
if [ -z "$JQ" ]; then
    if [ -x /opt/homebrew/bin/jq ]; then
        JQ="/opt/homebrew/bin/jq"
    else
        JQ="$(command -v jq 2>/dev/null)"
    fi
fi

# 刷新过程可能由快速切换连续触发；已有刷新在跑时只标记 pending。
# 当前刷新结束后会补跑一次，避免跳过最后一次真实窗口状态。
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    : >"$PENDING_FILE"
    exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT
mkdir -p "$CACHE_DIR"

# SketchyBar 的窗口事件可能早于窗口管理器内部列表更新。
# AeroSpace 仍保留原来的等待；Rift 先快速刷新，再在脚本结束后补一次短延迟校正。
if [ "$SENDER" = "space_windows_change" ]; then
    sleep 0.5
elif [ "$WM_MODE" = "rift" ] && [ "$SENDER" = "rift_windows_changed" ] && [ "$SKETCHYBAR_DEFERRED_REFRESH" != true ]; then
    DEFER_RIFT_REFRESH=true
fi

load_window_data() {
    aerospace_windows=""
    aerospace_windows_loaded=false
    rift_workspaces_json=""
    rift_workspaces_loaded=false
    rift_apps=()

    if [ "$WM_MODE" = "aerospace" ]; then
        # 优先一次性读取所有窗口，避免每个 workspace 都启动一次 aerospace。
        if aerospace_windows=$(aerospace list-windows --all --format "%{workspace}|%{app-name}" 2>/dev/null); then
            aerospace_windows_loaded=true
        fi
    elif [ -n "$JQ" ]; then
        # Rift 的 workspace 列表一次性取回，后续只在内存里按固定显示 index 分组。
        if rift_workspaces_json=$(rift-cli query workspaces 2>/dev/null); then
            rift_workspaces_loaded=true
            while IFS=$'\t' read -r workspace_index app_name; do
                case "$workspace_index" in
                    ''|*[!0-9]*) continue ;;
                esac
                if [ -n "$app_name" ]; then
                    rift_apps[$workspace_index]="${rift_apps[$workspace_index]}${app_name}"$'\n'
                fi
            done < <(
                printf '%s\n' "$rift_workspaces_json" |
                    "$JQ" -r '.[] as $workspace | ($workspace.index | tostring) as $index | $workspace.windows[]? | [$index, (.app_name // empty)] | @tsv' 2>/dev/null
            )
        fi
    fi
}

apps_for_workspace() {
    local sid=$1
    local workspace_index=$2
    local workspace
    local app_name

    if [ "$WM_MODE" = "aerospace" ]; then
        if [ "$aerospace_windows_loaded" = true ]; then
            while IFS='|' read -r workspace app_name; do
                if [ "$workspace" = "$sid" ] && [ -n "$app_name" ]; then
                    printf '%s\n' "$app_name"
                fi
            done <<<"$aerospace_windows"
        else
            # 旧版 AeroSpace 不支持一次性列出所有窗口时，保留原来的逐 workspace 查询。
            aerospace list-windows --workspace "$sid" --format "%{app-name}" 2>/dev/null
        fi
    elif [ "$rift_workspaces_loaded" = true ]; then
        printf '%s' "${rift_apps[$workspace_index]}"
    fi
}

update_space_icons() {
    local sid=$1
    local workspace_index=$2
    local icon_strip=""
    local apps=""
    local cache_file="$CACHE_DIR/$sid"
    local previous_icon_strip=""

    apps=$(apps_for_workspace "$sid" "$workspace_index")

    if [ "${apps}" != "" ]; then
        icon_strip=" "
        while read -r app; do
            if [ -n "$app" ]; then
                icon_map "$app"
                icon_strip+=" $icon_result"
            fi
        done <<<"${apps}"
    fi

    if [ -f "$cache_file" ]; then
        previous_icon_strip="$(cat "$cache_file")"
    fi
    if [ "$FORCE_UPDATE" != true ] && [ "$previous_icon_strip" = "$icon_strip" ]; then
        return
    fi

    printf '%s' "$icon_strip" >"$cache_file"
    args+=(--set "space.$sid" drawing=on label="$icon_strip")
}

refresh_icons() {
    args=()
    load_window_data

    # 按固定显示顺序刷新工作区图标，避免窗口管理器返回顺序影响 SketchyBar。
    for i in "${!workspaces[@]}"; do
        update_space_icons "${workspaces[$i]}" "$i"
    done

    # 一次性提交变化过的 workspace 图标；没有变化时避免触发 SketchyBar 重绘。
    if [ "${#args[@]}" -gt 0 ]; then
        sketchybar "${args[@]}"
    fi
}

# 复用图标映射函数，避免每个 app 都启动一次 icon_map_fn.sh。
source "$CONFIG_DIR/plugins/icon_map_fn.sh"

rm -f "$PENDING_FILE"
refresh_icons

if [ -f "$PENDING_FILE" ]; then
    rm -f "$PENDING_FILE"
    refresh_icons
fi

if [ "$DEFER_RIFT_REFRESH" = true ]; then
    (
        sleep 0.2
        SKETCHYBAR_DEFERRED_REFRESH=true SENDER=rift_windows_changed "$CONFIG_DIR/plugins/update_workspace_icons.sh"
    ) >/dev/null 2>&1 &
fi
