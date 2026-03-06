#!/usr/bin/env bash
set -euo pipefail
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

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
    brew install starship eza bat kubectl kubecolor nvm gh \
      ghostty terraform stern 2>/dev/null || true
    brew install --cask visual-studio-code 2>/dev/null || true
  else
    if command -v pacman &>/dev/null; then
      echo "Installing via pacman..."
      sudo pacman -S --needed --noconfirm \
        zsh starship eza bat kubectl kubecolor nvm github-cli \
        ghostty terraform stern
      # Install yay if not present (needed for AUR packages)
      if ! command -v yay &>/dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay-install
        (cd /tmp/yay-install && makepkg -si --noconfirm)
        rm -rf /tmp/yay-install
      fi
      # AUR packages
      yay -S --needed --noconfirm visual-studio-code-bin
    fi
  fi
}

# ─── GitHub auth ─────────────────────────────────────────────────────

setup_git() {
  echo "=== Git & GitHub setup ==="

  # Authenticate gh CLI if not already logged in (uses HTTPS for git operations)
  if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
    echo "Logging into GitHub CLI..."
    gh auth login --protocol https
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
  local dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  Backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  $dst -> $src"
}

# ─── Main ────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--install" ]]; then
  install_tools
  setup_git
  clone_repos
fi

echo "=== Linking dotfiles ==="
link "zsh/.zshrc"                     ".zshrc"
link "zsh/.zimrc"                     ".zimrc"
link "git/.gitconfig"                 ".gitconfig"
link "git/.config/git/ignore"         ".config/git/ignore"
link "starship/.config/starship.toml" ".config/starship.toml"
link "ghostty/.config/ghostty/config" ".config/ghostty/config"

# Linux-only configs
if [[ "$(uname)" != "Darwin" ]]; then
  link "yay/.config/yay/config.json"  ".config/yay/config.json"
fi

# Install Zim if not present
if [[ ! -d ~/.zim ]]; then
  echo ""
  echo "=== Installing Zim ==="
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.sh | zsh
fi

# Reminder for secrets
if [[ ! -f ~/.secrets ]]; then
  echo ""
  echo "NOTE: Copy secrets template and fill in values:"
  echo "  cp $DOTFILES/zsh/.secrets.example ~/.secrets"
fi

echo "=== Done ==="
