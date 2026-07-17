# Fonction interne : extrait les blocs Host de ~/.ssh/config
_sshfunctions_hosts_raw() {
  local ssh_config_file="$HOME/.ssh/config"

  if [ ! -f "$ssh_config_file" ]; then
    echo "Fichier de config introuvable : $ssh_config_file" >&2
    return 1
  fi

  local result
  result="$(awk '
    /^Host[ \t]+/ {
        if (host != "") {
            printf "%s\t%s\t%s\t%s\t%s\n", host, (hostname==""?"-":hostname), (user==""?"-":user), (port==""?"-":port), (identity==""?"-":identity)
        }
        host=$2; hostname=""; user=""; port=""; identity=""
        next
    }
    $1 == "HostName"     { hostname=$2 }
    $1 == "User"         { user=$2 }
    $1 == "Port"         { port=$2 }
    $1 == "IdentityFile" { identity=$2 }
    END {
        if (host != "") {
            printf "%s\t%s\t%s\t%s\t%s\n", host, (hostname==""?"-":hostname), (user==""?"-":user), (port==""?"-":port), (identity==""?"-":identity)
        }
    }
  ' "$ssh_config_file" | grep -Ev $'^[^\t]*[*?]')"

  if [ -z "$result" ]; then
    echo "Aucun host trouvé dans $ssh_config_file" >&2
    return 1
  fi

  echo "$result"
}

# Fonction interne : affiche le tableau des hosts et gère la sélection utilisateur
_sshfunctions_select_host() {
  printf "%-4s %-20s %-30s %-15s %-6s %s\n" "#" "ALIAS" "HOSTNAME" "USER" "PORT" "CLÉ" >&2
  local i

  # shellcheck disable=SC2154
  for ((i = 0; i < ${#aliases[@]}; i++)); do
    local key_display="${identities[$i]}"
    if [ "$key_display" != "-" ]; then
      key_display="${key_display/#\~/$HOME}"
      key_display="${key_display#"$HOME"/.ssh/keys/}"
      key_display="${key_display}.pub"
    fi
    printf "%-4s %-20s %-30s %-15s %-6s %s\n" "$((i + 1))" "${aliases[$i]}" "${hostnames[$i]}" "${users[$i]}" "${ports[$i]}" "$key_display" >&2
  done

  echo "" >&2
  local choice
  printf "Numéro du host (Entrée ou q pour annuler) : " >&2
  read -r choice

  if [ -z "$choice" ] || [ "$choice" = "q" ]; then
    return 1
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#aliases[@]}" ]; then
    echo "Sélection invalide : $choice" >&2
    return 1
  fi

  echo "${aliases[$((choice - 1))]}"
}
