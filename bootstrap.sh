#! /bin/bash

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if ! grep -q "codespace.*/bin/zsh" /etc/passwd; then
  echo "Changing shell to zsh"
  sudo chsh -s /bin/zsh codespace
fi

export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$GITHUB_TOKEN

# install starship
curl -fsSL https://starship.rs/install.sh | zsh

# copy starship config
mkdir -p $HOME/.config
cp starship.toml $HOME/.config/starship.toml

echo "==========================================================="
echo "             import zshrc                                  "
echo "-----------------------------------------------------------"
cat .zshrc > $HOME/.zshrc
