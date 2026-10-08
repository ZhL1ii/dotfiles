# Homebrew

BREW_PREFIX="/opt/homebrew"
export HOMEBREW_PREFIX="$BREW_PREFIX"

path=(
  "$BREW_PREFIX/bin"
  "$BREW_PREFIX/sbin"
  $path
)


# LLVM

if [[ -d "$BREW_PREFIX/opt/llvm/bin" ]]; then
  path=("$BREW_PREFIX/opt/llvm/bin" $path)
fi


# Proxy

ZSH_PROXY_PORT=7897


# Skills sync

skill-sync() {
  rsync -av --delete \
    ~/.agents/skills/ \
    ubuntu-dev:~/.agents/skills/
}


# Kitty Tab 标题

if [[ -n "$KITTY_WINDOW_ID" ]]; then
  autoload -Uz add-zsh-hook

  # 空闲时显示目录
  _kitty_title_precmd() {
    printf '\e]2;%s\a' "${PWD:t}"
  }

  # 运行时显示程序
  _kitty_title_preexec() {
    local -a words
    words=(${(z)2})

    if [[ -n "${words[1]}" ]]; then
      printf '\e]2;%s\a' "${words[1]:t}"
    fi
  }

  add-zsh-hook precmd _kitty_title_precmd
  add-zsh-hook preexec _kitty_title_preexec
fi
