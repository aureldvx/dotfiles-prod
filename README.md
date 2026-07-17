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
```

## Application

```shell
ln -s ~/.vimrc ~/.dotfiles/.vimrc
ln -s ~/.blerc ~/.dotfiles/.blerc
```

```shell
# ~/.bashrc
source ~/.dotfiles/.bashrc
```
