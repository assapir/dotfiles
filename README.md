# Dotfiles

My dotfiles, managed with symlinks. Works on Arch Linux and macOS.

## New machine setup

```bash
git clone https://github.com/assapir/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh --install    # install tools + link configs + install Zim
cp zsh/.secrets.example ~/.secrets
nano ~/.secrets           # fill in your API tokens
```

## Day-to-day usage

Configs are symlinked from `~` into this repo. Editing `~/.zshrc` edits `~/code/dotfiles/zsh/.zshrc` directly — no sync needed.

```bash
# After changing any config
cd ~/code/dotfiles
git add -A && git commit -m "update zshrc" && git push

# Pull changes on another machine
cd ~/code/dotfiles
git pull
# Symlinks already point here, so changes take effect immediately
```

## What does `install.sh` do?

| Command | What it does |
|---------|-------------|
| `./install.sh` | Link configs only (backs up existing files to `.bak`) |
| `./install.sh --install` | Install tools via pacman/brew, then link configs + install Zim |

Safe to re-run — existing symlinks are overwritten, real files are backed up.

## What's included

| Package | Files | Description |
|---------|-------|-------------|
| `zsh/` | `.zshrc`, `.zimrc` | Zsh config with Zim plugin manager |
| `git/` | `.gitconfig`, `.config/git/ignore` | Git identity and global ignore |
| `starship/` | `.config/starship.toml` | Starship prompt theme |
| `ghostty/` | `.config/ghostty/config` | Ghostty terminal config |
| `paru/` | `.config/paru/paru.conf` | Paru AUR helper config (Linux only) |
| `niri/` | `.config/niri/config.kdl` | Niri compositor config (Linux only) |
| `greetd/` | `/etc/greetd/*`, `/etc/pam.d/greetd` | Login greeter config (Linux only) |

## Tools installed with `--install`

starship, eza, bat, kubectl, kubecolor, fnm, gh, ghostty, terraform, stern, paru (Linux only)

## Secrets

API tokens live in `~/.secrets` (gitignored). The `.zshrc` sources it automatically.
See `zsh/.secrets.example` for the expected variables.

## Adding a new config file

1. Create a package directory: `mkdir -p <package>/<path-relative-to-home>`
2. Move your config into it
3. Add a `link` line to `install.sh`
4. Run `./install.sh`
