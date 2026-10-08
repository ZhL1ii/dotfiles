# PATH

path=(
  "/usr/local/bin"
  $path
)


# Homebrew

BREW_PREFIX="/home/linuxbrew/.linuxbrew"

if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
  export HOMEBREW_PREFIX="$BREW_PREFIX"

  path=(
    "$BREW_PREFIX/bin"
    "$BREW_PREFIX/sbin"
    $path
  )
fi


# Proxy

ZSH_PROXY_PORT=7890


# SDKMAN

export SDKMAN_DIR="$HOME/.sdkman"

if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
