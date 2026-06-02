#!/bin/bash

SPACE_SIDS=(1 2 3 4 5 Q W E S D)

sketchybar --add event aerospace_workspace_change

for sid in "${SPACE_SIDS[@]}"
do
  space=(
    icon=$sid                                  
    icon.padding_left=10
    icon.padding_right=10
    label.font="sketchybar-app-font:Regular:16.0" 
    label.drawing=off
    label.y_offset=-1                          
    script="$PLUGIN_DIR/space.sh"
    updates=on
    click_script="/opt/homebrew/bin/aerospace workspace $sid"
  )
  sketchybar --add item space.$sid left                                 \
             --set space.$sid "${space[@]}"                            \
             --subscribe space.$sid aerospace_workspace_change
done

sketchybar --add item space_separator left                             \
           --set space_separator icon="􀆓"                                \
                                 icon.color=$WHITE \
                                 icon.padding_left=4                   \
                                 label.drawing=off                     \
                                 background.drawing=off
