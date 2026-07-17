# Dotfiles pour production

## Installation

```shell
# Copie du repository
git clone https://github.com/aureldvx/dotfiles-prod.git ~/.dotfiles

# Installation de fzf (https://github.com/junegunn/fzf)
sudo apt install fzf

# Installation de zoxide (https://github.com/ajeetdsouza/zoxide)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Installation de ble.sh (https://github.com/akinomyoga/ble.sh)
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local

# Installation de starship (https://starship.rs/)
curl -sS https://starship.rs/install.sh | sh
```

## Application

```shell
ln -s ~/.vimrc ~/.dotfiles/.vimrc
ln -s ~/.blerc ~/.dotfiles/.blerc
mkdir -p ~/.config && ln -s ~/.config/starship.toml ~/.dotfiles/starship.toml
```

```shell
# ~/.bashrc
source ~/.dotfiles/.bashrc
```
