# ================================
# shell configuration
# ================================

export TERM="xterm-256color"
export EDITOR="vim"

# ================================
# bindings
# ================================

# Recherche dans l'historique avec les flèches Haut/Bas (comme substring-search)
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ================================
# fonctions utilitaires
# ================================

# Crée le dossier et s'y déplace instantanément
take() {
  mkdir -p "$1" && cd "$1" || exit
}

# Duplique un fichier en lui ajoutant l'extension .bak
# Usage : backup mon_fichier.conf
backup() {
  cp -iv "$1" "${1}.bak"
}

# ================================
# outils externes
# ================================

# initialise fzf
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# initialise la coloration syntaxique et les suggestions de saisie à la volée
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
  source ~/.local/share/blesh/ble.sh
fi

# initialise zoxide uniquement s'il est installé sur le système
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# ================================
# sources internes
# ================================

source ./bash_aliases.sh

source ./ssh/common.sh
source ./ssh/add_key.sh
source ./ssh/delete_key.sh
source ./ssh/list_keys.sh

source ./docker/common.sh
source ./docker/shortcuts.sh
source ./docker/backup.sh
source ./docker/restore.sh
