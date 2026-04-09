#!/usr/bin/env bash
set -euo pipefail
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# ─── Zim installation ───────────────────────────────────────────────

install_zim() {
  echo "=== Installing Zim ==="

  if ! command -v zsh &>/dev/null; then
    echo "zsh is required to install Zim"
    return 1
  fi

  local zim_home="$HOME/.zim"
  local zimrc="$DOTFILES/zsh/.zimrc"
  local zimfw_url="https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh"

  if [[ ! -f "$zimrc" ]]; then
    echo "Missing $zimrc"
    return 1
  fi

  if [[ ! -s "$zim_home/zimfw.zsh" ]]; then
    echo "  Downloading zimfw..."
    if command -v curl &>/dev/null; then
      curl -fsSL --create-dirs -o "$zim_home/zimfw.zsh" "$zimfw_url"
    elif command -v wget &>/dev/null; then
      mkdir -p "$zim_home"
      wget -nv -O "$zim_home/zimfw.zsh" "$zimfw_url"
    else
      echo "curl or wget is required to install Zim"
      return 1
    fi
  fi

  if [[ ! -s "$zim_home/zimfw.zsh" ]]; then
    echo "Failed to download $zim_home/zimfw.zsh"
    return 1
  fi

  ZIM_HOME="$zim_home" ZIM_CONFIG_FILE="$zimrc" zsh -c '
    source "$ZIM_HOME/zimfw.zsh" init -q
  '
}

# ─── Tool installation ───────────────────────────────────────────────

install_tools() {
  echo "=== Installing tools ==="
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "Homebrew not found. Installing..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "Installing via Homebrew..."
    brew install starship eza bat kubectl kubecolor fnm gh \
      ghostty stern 2>/dev/null || true
    brew tap hashicorp/tap 2>/dev/null || true
    if brew list --versions terraform &>/dev/null && ! brew list --versions hashicorp/tap/terraform &>/dev/null; then
      echo "Replacing deprecated Homebrew terraform formula..."
      brew uninstall terraform 2>/dev/null || true
    fi
    brew install hashicorp/tap/terraform 2>/dev/null || \
      brew upgrade hashicorp/tap/terraform 2>/dev/null || \
      brew reinstall hashicorp/tap/terraform 2>/dev/null || true
    brew install --cask visual-studio-code 2>/dev/null || true
  else
    if command -v pacman &>/dev/null; then
      echo "Installing via pacman..."
      sudo pacman -S --needed --noconfirm \
        zsh starship eza bat kubectl kubecolor fnm github-cli \
        ghostty terraform stern greetd git base-devel
      if ! command -v paru &>/dev/null; then
        echo "Installing paru..."
        git clone https://aur.archlinux.org/paru.git /tmp/paru-install
        (cd /tmp/paru-install && makepkg -si --noconfirm)
        rm -rf /tmp/paru-install
      fi
      paru -S --needed --noconfirm visual-studio-code-bin greetd-tuigreet-fork-bin
    fi
  fi

  echo ""
  install_zim
}

# ─── GitHub auth ─────────────────────────────────────────────────────

setup_git() {
  echo "=== Git & GitHub setup ==="

  # Authenticate gh CLI if not already logged in (uses HTTPS for git operations)
  if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
    echo "Logging into GitHub CLI..."
    gh auth login
  fi
}

# ─── Clone repos ─────────────────────────────────────────────────────

clone_repos() {
  echo "=== Cloning repos ==="

  # Claude Code agent skills (global)
  if [[ ! -d "$HOME/.claude/skills" ]]; then
    echo "Cloning agent-skills to ~/.claude/skills..."
    mkdir -p "$HOME/.claude"
    git clone https://github.com/assapir/agent-skills.git "$HOME/.claude/skills"
  else
    echo "agent-skills already present, pulling latest..."
    git -C "$HOME/.claude/skills" pull
  fi
}

# ─── Symlink helper ──────────────────────────────────────────────────

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/${1#*/}"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  Backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  $dst -> $src"
}

link_dotfiles() {
  echo "=== Linking dotfiles ==="
  link "zsh/.zshrc"
  link "zsh/.zimrc"
  link "git/.gitconfig"
  link "git/.config/git/ignore"
  link "starship/.config/starship.toml"
  link "ghostty/.config/ghostty/config"

  # Linux-only configs
  if [[ "$(uname)" != "Darwin" ]]; then
    link "paru/.config/paru/paru.conf"
    link "niri/.config/niri/config.kdl"

    # greetd configs (system-level, copied because greetd runs as root before user session)
    if command -v greetd &>/dev/null; then
      echo "  Installing greetd configs (requires sudo)..."
      sudo cp "$DOTFILES/greetd/config.toml"   /etc/greetd/config.toml
      sudo cp "$DOTFILES/greetd/tuigreet.toml" /etc/greetd/tuigreet.toml
      sudo cp "$DOTFILES/greetd/greetd-pam"    /etc/pam.d/greetd
    fi
  fi
}

# ─── Main ────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--install" ]]; then
  install_tools
  setup_git
  clone_repos
fi

link_dotfiles

if [[ ! -f ~/.secrets ]]; then
  echo ""
  echo "NOTE: Copy secrets template and fill in values:"
  echo "  cp $DOTFILES/zsh/.secrets.example ~/.secrets"
fi

echo "=== Done ==="
