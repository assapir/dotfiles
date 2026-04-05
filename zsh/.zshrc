# === Zsh options ===
setopt HIST_IGNORE_ALL_DUPS
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}

# === Zim module config ===
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# === Zim init ===
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# === Post-init: history-substring-search bindings ===
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# === Shared config ===
eval "$(starship init zsh)"
alias cat='bat -p --paging=never'
alias ls='eza -alh --icons=auto'
alias k='kubectl'
alias tf='terraform'
export EDITOR=nano

# === OS-specific ===
if [[ "$(uname)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/libpq/bin:$PATH"
  alias flashdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
  [[ -d "$HOME/.rd/bin" ]] && export PATH="$HOME/.rd/bin:$PATH"
fi

# === fnm (fast node manager) ===
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# === kubectl/kubecolor ===
if command -v kubectl &>/dev/null; then
  _kubectl_comp="$HOME/.zsh_cache/kubectl_completion.zsh"
  if [[ ! -f "$_kubectl_comp" || "$(command -v kubectl)" -nt "$_kubectl_comp" ]]; then
    mkdir -p "$HOME/.zsh_cache"
    kubectl completion zsh > "$_kubectl_comp"
  fi
  source "$_kubectl_comp"
  unset _kubectl_comp
  compdef kubecolor=kubectl
  alias kubectl='kubecolor'
fi

# === PATH and secrets ===
export PATH="$HOME/.cargo/bin:$PATH"
fpath+=~/.zfunc
[[ -f ~/.secrets ]] && source ~/.secrets
