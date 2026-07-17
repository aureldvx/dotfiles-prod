# ================================
# Confirmations de sécurité
# ================================
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias ln='ln -iv'
alias please='sudo $(fc -ln -1)' # Relance la dernière commande avec les privilèges root

# ================================
# Navigation
# ================================
alias ll='ls -lah'                  # Liste détaillée, lisible (tailles en Ko/Mo/Go) et masqués
alias l='ls -CF'                    # Liste rapide et compacte
alias ..='cd ..'                    # Retour arrière rapide
alias ...='cd ../..'                # Retour arrière de deux dossiers
alias path='echo -e ${PATH//:/\\n}' # Affiche proprement chaque dossier du PATH sur une nouvelle ligne

# ================================
# Coloration
# ================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

# ================================
# Git
# ================================
alias gst="git status"
alias gaa="git add --all"
alias gc="git commit -m "
alias gp="git push"
alias gl="git pull"
alias uncommit="git reset --soft HEAD~1"

# ================================
# Ressources
# ================================
alias mem='ps auxf | sort -nr -k 4 | head -10' # Affiche les 10 processus les plus gourmands en mémoire (RAM)
alias cpu='ps auxf | sort -nr -k 3 | head -10' # Affiche les 10 processus les plus gourmands en processeur (CPU)
alias dfg='df -h -x devtmpfs -x tmpfs'         # Version moderne et beaucoup plus lisible de 'df -h' (affiche l'espace disque en colonnes claires)
alias ports='ss -tulpn'                        # Lister tous les ports TCP/UDP actuellement ouverts et à l'écoute
