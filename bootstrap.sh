#! /bin/bash

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

if ! grep -q "codespace.*/bin/zsh" /etc/passwd; then
  echo "Changing shell to zsh"
  sudo chsh -s /bin/zsh codespace
fi

export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$GITHUB_TOKEN

cat .zshrc > $HOME/.zshrc

nvm install default
