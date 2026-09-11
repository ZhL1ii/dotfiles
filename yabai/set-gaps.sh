#!/usr/bin/env bash

# 显示器 UUID
DSPLAY_SANC_UUID="D1C31F4F-0677-4598-AB9A-1B4427D96F5E"
DSPLAY_BUILTIN_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

# 获取显示器 index
DISPLAY_SANC_IDX=$(
  yabai -m query --displays | jq --arg uuid $DSPLAY_SANC_UUID '.[] | select(.uuid == $uuid) | .index'
)

DISPLAY_BUILTIN_IDX=$(
  yabai -m query --displays | jq --arg uuid $DSPLAY_BUILTIN_UUID '.[] | select(.uuid == $uuid) | .index'
)

set_gaps() {
  local display="$1"
  local top="$2"
  local bottom="$3"
  local left="$4"
  local right="$5"
  local gap="$6"


  # 遍历每一个 Space 调整 gaps
  yabai -m query --spaces --display "$display" |
    jq -r '.[].index' |
    while IFS= read -r space; do
      yabai -m space "$space" \
        --padding "abs:${top}:${bottom}:${left}:${right}"

      yabai -m space "$space" \
        --gap "abs:${gap}"
    done

}

set_gaps "$DISPLAY_SANC_IDX" 35 5 5 5 5

set_gaps "$DISPLAY_BUILTIN_IDX" 3 5 5 5 5

