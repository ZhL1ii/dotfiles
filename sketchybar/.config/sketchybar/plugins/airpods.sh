#!/bin/sh

# 仅当当前声音输出设备是 AirPods 时显示这个状态项。
# SwitchAudioSource 已在本机安装，用它读取当前正在使用的输出设备。

# 当前输出设备名称，例如 "MacBook Pro Speakers" 或 "xxx's AirPods"。
OUTPUT_DEVICE="$(SwitchAudioSource -c -t output 2>/dev/null)"

# 这个图标只表示声音输出设备，不表示蓝牙连接状态或耳机电量。
# 因此只有 AirPods 是当前输出设备时才显示。
if printf "%s\n" "$OUTPUT_DEVICE" | grep -qi "AirPods"; then
  sketchybar --set "$NAME" drawing=on icon="􀪷 " label=""
else
  sketchybar --set "$NAME" drawing=off
fi
