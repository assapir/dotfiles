# Dotfiles

My dotfiles, managed with symlinks. Works on Arch Linux and macOS.

## Setup on a new machine

```bash
git clone https://github.com/assapir/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh --install    # install tools + link configs
```

Or just link configs without installing tools:

```bash
./install.sh
```

Then set up secrets:

```bash
cp ~/code/dotfiles/zsh/.secrets.example ~/.secrets
nano ~/.secrets  # fill in your API tokens
```

## What's included

| Package | Files | Description |
|---------|-------|-------------|
| `zsh/` | `.zshrc`, `.zimrc` | Zsh config with Zim plugin manager |
| `git/` | `.gitconfig`, `.config/git/ignore` | Git identity and global ignore |
| `starship/` | `.config/starship.toml` | Starship prompt theme |
| `ghostty/` | `.config/ghostty/config` | Ghostty terminal config |
| `yay/` | `.config/yay/config.json` | Yay AUR helper config (Linux only) |

## Tools installed with `--install`

starship, eza, bat, kubectl, kubecolor, nvm, gh, ghostty, terraform, stern, yay (Linux)

## Adding a new config file

1. Create a package directory: `mkdir -p <package>/<path-relative-to-home>`
2. Move your config file into it
3. Add a `link` line to `install.sh`
4. Run `./install.sh` to activate
