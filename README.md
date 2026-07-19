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
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git; \
sudo apt install make; \
make -C ble.sh install PREFIX=~/.local; \
rm -rf ./ble.sh

# Installation de starship (https://starship.rs/)
curl -sS https://starship.rs/install.sh | sh

# Installation de catppuccin-vim (https://github.com/catppuccin/vim)
git clone https://github.com/catppuccin/vim.git ~/.vim/pack/vendor/start/catppuccin
```

## Application

```shell
ln -s ~/.dotfiles/.vimrc ~/.vimrc; \
ln -s ~/.dotfiles/.blerc ~/.blerc; \
mkdir -p ~/.config && ln -s ~/.dotfiles/starship.toml ~/.config/starship.toml
```

```shell
# ~/.bashrc
source ~/.dotfiles/.bashrc
```
