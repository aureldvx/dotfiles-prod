# Supprime un host et ses fichiers de clés associés
sshdel() {
  if [ -n "$ZSH_VERSION" ]; then
    emulate -L bash
  fi

  local host="$1"
  local ssh_config_file="$HOME/.ssh/config"
  local keys_root="$HOME/.ssh/keys"
  local identity_file="" public_key_file="" key_directory=""

  if [ -z "$host" ]; then
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

    host="$(_sshfunctions_select_host)" || {
      echo "Annulé"
      return 0
    }
  fi

  if [ ! -f "$ssh_config_file" ]; then
    echo "Fichier de config introuvable : $ssh_config_file" >&2
    return 1
  fi

  if ! grep -q "^Host $host\$" "$ssh_config_file"; then
    echo "Aucun bloc Host '$host' trouvé dans $ssh_config_file"
    return 1
  fi

  local os_name
  os_name="$(uname -s)"
  local is_macos=false
  if [ "$os_name" = "Darwin" ]; then
    is_macos=true
  fi

  identity_file="$(awk -v host="$host" '
    $1 == "Host" && $2 == host { in_block=1; next }
    $1 == "Host" && in_block   { in_block=0 }
    in_block && $1 == "IdentityFile" { print $2; exit }
  ' "$ssh_config_file")"

  identity_file="${identity_file/#\~/$HOME}"

  local other_hosts_using_key
  other_hosts_using_key=$(awk -v key="$identity_file" -v home="$HOME" -v current_host="$host" '
    BEGIN { in_target_block = 0; found = 0 }
    $1 == "Host" {
      if (in_target_block) in_target_block = 0;
      else if ($2 == current_host) in_target_block = 1;
      current_host_block = $2;
      next;
    }
    $1 == "IdentityFile" {
      path = $2;
      if (substr(path, 1, 1) == "~") path = home substr(path, 2);
      if (path == key && !in_target_block) {
        print current_host_block;
        found = 1;
      }
    }
    END { exit !found }
' "$ssh_config_file")

  if [ -n "$other_hosts_using_key" ]; then
    echo "Erreur : La clé '$identity_file' est aussi utilisée par : $other_hosts_using_key" >&2
    echo "Suppression annulée." >&2
    return 1
  fi

  local tmp_file
  tmp_file="$(mktemp)"
  awk -v host="$host" '
    BEGIN { in_block = 0 }
    $1 == "Host" && $2 == host {
      in_block = 1
      next
    }
    in_block && /^[ \t]/ {
      next
    }
    in_block && !/^[ \t]/ {
      in_block = 0
    }
    { print }
  ' "$ssh_config_file" >"$tmp_file" && mv "$tmp_file" "$ssh_config_file"
  chmod 600 "$ssh_config_file"
  echo "Bloc Host '$host' supprimé de $ssh_config_file"

  if [ -z "$identity_file" ]; then
    echo "Aucun IdentityFile trouvé pour '$host', rien d'autre à nettoyer"
    return 0
  fi

  identity_file="${identity_file/#\~/$HOME}"

  if [ "$is_macos" = true ]; then
    if ssh-add -d --apple-use-keychain "$identity_file" >/dev/null 2>&1; then
      echo "Clé $identity_file retirée de l'agent SSH et du trousseau"
    else
      echo "Clé $identity_file introuvable dans l'agent SSH"
    fi
  else
    if ssh-add -d "$identity_file" >/dev/null 2>&1; then
      echo "Clé $identity_file retirée de l'agent SSH"
    else
      echo "Clé $identity_file introuvable dans l'agent SSH"
    fi
  fi

  if [ -f "$identity_file" ]; then
    rm "$identity_file"
    echo "Fichier de clé privée supprimé : $identity_file"
  else
    echo "Fichier de clé privée absent, ignoré : $identity_file"
  fi

  public_key_file="${identity_file}.pub"
  if [ -f "$public_key_file" ]; then
    rm "$public_key_file"
    echo "Fichier de clé publique supprimé : $public_key_file"
  else
    echo "Fichier de clé publique absent, ignoré : $public_key_file"
  fi

  key_directory="$(dirname "$identity_file")"
  while [ "$key_directory" != "$keys_root" ] && [ "$key_directory" != "$HOME/.ssh" ] && [ "$key_directory" != "/" ]; do
    if [ -d "$key_directory" ] && [ -z "$(ls -A "$key_directory")" ]; then
      rmdir "$key_directory"
      echo "Dossier vide supprimé : $key_directory"
      key_directory="$(dirname "$key_directory")"
    else
      break
    fi
  done
}
