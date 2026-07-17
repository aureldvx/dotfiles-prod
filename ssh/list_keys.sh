# Liste les hosts et permet de s'y connecter de façon interactive
sshls() {
  if [ -n "$ZSH_VERSION" ]; then
    emulate -L bash
  fi

  local ssh_config_file="$HOME/.ssh/config"
  local direct_target="$1"

  local hosts_raw
  hosts_raw="$(_sshfunctions_hosts_raw)" || return 1

  local aliases=() hostnames=() users=() ports=() identities=()
  while IFS=$'\t' read -r h hn u p id; do
    aliases+=("$h")
    hostnames+=("$hn")
    users+=("$u")
    ports+=("$p")
    identities+=("$id")
  done <<<"$hosts_raw"

  if [ -n "$direct_target" ]; then
    local i
    for ((i = 0; i < ${#aliases[@]}; i++)); do
      if [ "${aliases[$i]}" = "$direct_target" ]; then
        echo "Connexion à ${aliases[$i]} (${users[$i]}@${hostnames[$i]}:${ports[$i]})..."
        ssh "$direct_target"
        return $?
      fi
    done
    echo "Alias '$direct_target' introuvable dans $ssh_config_file" >&2
    return 1
  fi

  local selected
  selected="$(_sshfunctions_select_host)" || {
    echo "Annulé"
    return 0
  }

  echo "Connexion à $selected..."
  ssh "$selected"
}
