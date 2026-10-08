# PATH

typeset -U path

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  $path
)

# config directory

ZSH_CONFIG_DIR="${${(%):-%x}:A:h}"

# platform

case "$OSTYPE" in
  darwin*)
    source "$ZSH_CONFIG_DIR/macos.zsh"
    ;;
  linux*)
    source "$ZSH_CONFIG_DIR/linux.zsh"
    ;;
esac

# public config

source "$ZSH_CONFIG_DIR/common.zsh"

unset ZSH_CONFIG_DIR
