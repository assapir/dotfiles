# === Zsh options ===
setopt HIST_IGNORE_ALL_DUPS
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}

# Keep paths unique when this file is sourced again.
typeset -U path PATH fpath

# === Homebrew (before Zim initializes completions) ===
if [[ $OSTYPE == darwin* ]]; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $_brew ]]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi

# === Static paths (before initializing tools) ===
if [[ $OSTYPE == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  for _dir in "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/coreutils/libexec/gnubin" \
              "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/libpq/bin" \
              "$HOME/.rd/bin" /Applications/SnowflakeCLI.app/Contents/MacOS; do
    [[ -d $_dir ]] && path=("$_dir" $path)
  done
  unset _dir
else
  export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi
path=("$PNPM_HOME" "$HOME/.local/bin" "$HOME/.cargo/bin" $path)
fpath=("${ZDOTDIR:-$HOME}/.zfunc" $fpath)

# === Zim module config ===
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# === Zim init ===
ZIM_HOME=${ZIM_HOME:-${ZDOTDIR:-$HOME}/.zim}
# Bootstrap/update explicitly with install.sh --install, never over the network
# while opening a terminal. A missing installation still leaves a usable shell.
if [[ -r $ZIM_HOME/init.zsh ]]; then
  source "$ZIM_HOME/init.zsh"
fi

# === Post-init: history-substring-search bindings ===
if (( ${+widgets[history-substring-search-up]} && ${+widgets[history-substring-search-down]} )); then
  zmodload -F zsh/terminfo +p:terminfo
  for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
  for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
  bindkey -M vicmd k history-substring-search-up
  bindkey -M vicmd j history-substring-search-down
  unset key
fi

# === Shared config ===
if (( ${+commands[starship]} )); then
  eval "$(starship init zsh)"
fi
(( ${+commands[bat]} )) && alias cat='bat -p --paging=never'
(( ${+commands[eza]} )) && alias ls='eza -alh --icons=auto'
(( ${+commands[kubectl]} )) && alias k='kubectl'
(( ${+commands[terraform]} )) && alias tf='terraform'
export EDITOR=nano

# === OS-specific ===
if [[ $OSTYPE == darwin* ]]; then
  alias flashdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# === fnm (fast node manager) ===
if (( ${+commands[fnm]} )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# === kubectl/kubecolor ===
# The commands table resolves the executable even after kubectl is aliased.
if (( ${+commands[kubectl]} )); then
  _kubectl_bin=$commands[kubectl]
  _kubectl_comp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl_completion.zsh"
  if [[ ! -s $_kubectl_comp || $_kubectl_bin -nt $_kubectl_comp ]]; then
    if mkdir -p "${_kubectl_comp:h}" && \
        _kubectl_tmp=$(mktemp "${_kubectl_comp}.XXXXXX"); then
      if "$_kubectl_bin" completion zsh >| "$_kubectl_tmp" && \
          [[ -s $_kubectl_tmp ]] && zsh -n "$_kubectl_tmp"; then
        command mv -f "$_kubectl_tmp" "$_kubectl_comp"
      fi
      command rm -f "$_kubectl_tmp"
      unset _kubectl_tmp
    fi
  fi
  if [[ -r $_kubectl_comp ]] && (( ${+functions[compdef]} )); then
    source "$_kubectl_comp"
  fi
  if (( ${+commands[kubecolor]} )); then
    (( ${+functions[compdef]} )) && compdef kubecolor=kubectl
    alias kubectl='kubecolor'
  elif [[ ${aliases[kubectl]-} == kubecolor ]]; then
    unalias kubectl
  fi
  unset _kubectl_bin _kubectl_comp
fi

# === Secrets ===
[[ -f ~/.secrets ]] && source ~/.secrets

# Cortex CLI completion (requires completion initialization).
if (( ${+functions[compdef]} )) && [[ -s ~/.zsh/completions/cortex.zsh ]]; then
  source ~/.zsh/completions/cortex.zsh
fi
