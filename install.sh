#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    current="$(readlink "$target")"

    if [[ "$current" == "$source" ]]; then
      echo "skip: $target"
      return
    fi

    echo "replace symlink: $target"
    rm "$target"
  elif [[ -e "$target" ]]; then
    echo "conflict: $target already exists"
    return 1
  fi

  ln -s "$source" "$target"
  echo "link: $target -> $source"
}

# Common: macOS + Linux

link "$DOTFILES/nvim" "$CONFIG_HOME/nvim"
link "$DOTFILES/kitty" "$CONFIG_HOME/kitty"
link "$DOTFILES/ghostty" "$CONFIG_HOME/ghostty"
link "$DOTFILES/yazi" "$CONFIG_HOME/yazi"
link "$DOTFILES/fzf" "$CONFIG_HOME/fzf"
link "$DOTFILES/yamllint" "$CONFIG_HOME/yamllint"

# macOS only

if [[ "$(uname -s)" == "Darwin" ]]; then
  link "$DOTFILES/aerospace" "$CONFIG_HOME/aerospace"
  link "$DOTFILES/karabiner" "$CONFIG_HOME/karabiner"
  link "$DOTFILES/sketchybar" "$CONFIG_HOME/sketchybar"
  link "$DOTFILES/skhd" "$CONFIG_HOME/skhd"
  link "$DOTFILES/yabai" "$CONFIG_HOME/yabai"
fi
