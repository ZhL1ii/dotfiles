# Environment

export EDITOR="nvim"
export VISUAL="nvim"
export STARSHIP_CONFIG="$HOME/.config/starship/nerd-font.toml"

if [[ -f "$HOME/.config/fzf/fzfrc" ]]; then
  export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzfrc"
fi


# History

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS


# Shell

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

autoload -Uz compinit
compinit -C


# Prompt and navigation

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi


# Aliases

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -la --icons=auto --git --group-directories-first'
  alias la='eza -a --icons=auto --group-directories-first'
  alias lt='eza -T -L 2 --icons=auto --group-directories-first'
else
  alias ll='ls -lah'
  alias la='ls -A'
fi

if (( $+commands[bat] )); then
  alias cat='bat'
fi

alias py='python3'
alias nv='nvim'
alias l='lazygit'
alias cl='clear'


# Yazi

y() {
  local tmp cwd

  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1

  command yazi "$@" --cwd-file="$tmp"

  cwd="$(< "$tmp")"
  rm -f -- "$tmp"

  if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
    builtin cd -- "$cwd"
  fi
}


# Proxy

proxy_on() {
  local proxy="http://127.0.0.1:${ZSH_PROXY_PORT}"

  export http_proxy="$proxy"
  export https_proxy="$proxy"
  export all_proxy="$proxy"

  export HTTP_PROXY="$proxy"
  export HTTPS_PROXY="$proxy"
  export ALL_PROXY="$proxy"

  echo "Proxy enabled: 127.0.0.1:${ZSH_PROXY_PORT}"
}

proxy_off() {
  unset http_proxy https_proxy all_proxy
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY

  echo "Proxy disabled"
}

proxy_status() {
  echo "http_proxy=${http_proxy:-}"
  echo "https_proxy=${https_proxy:-}"
  echo "all_proxy=${all_proxy:-}"
}

proxy_test() {
  curl -I --max-time 10 https://www.google.com
}


# Plugins

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi
