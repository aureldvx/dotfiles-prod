# Génère une nouvelle clé et l'ajoute au fichier de configuration
sshadd() {
  if [ -n "$ZSH_VERSION" ]; then
    emulate -L bash
  fi

  local name="" host="" hostname="" port="22" user="" password="" comment=""

  while [ $# -gt 0 ]; do
    case "$1" in
    --name)
      name="$2"
      shift 2
      ;;
    --host)
      host="$2"
      shift 2
      ;;
    --hostname)
      hostname="$2"
      shift 2
      ;;
    --port)
      port="$2"
      shift 2
      ;;
    --user)
      user="$2"
      shift 2
      ;;
    --password)
      password="$2"
      shift 2
      ;;
    --comment)
      comment="$2"
      shift 2
      ;;
    *)
      echo "sshadd: paramètre inconnu '$1'" >&2
      return 1
      ;;
    esac
  done

  if [ -z "$name" ]; then
    printf "Nom de la clé (ex: github/my_account): "
    read -r name
    while [ -z "$name" ]; do
      printf "Le nom est obligatoire : "
      read -r name
    done
  fi

  if [ -z "$host" ]; then
    printf "Alias SSH [%s]: " "${name##*/}"
    read -r host
    [ -z "$host" ] && host="${name##*/}"
  fi

  if [ -z "$hostname" ]; then
    printf "HostName []: "
    read -r hostname
  fi

  if [ "$port" = "22" ]; then
    printf "Port [22]: "
    read -r port
    [ -z "$port" ] && port="22"
  fi

  if [ -z "$user" ]; then
    printf "Utilisateur SSH []: "
    read -r user
  fi

  if [ -z "$password" ]; then
    printf "Passphrase []: "
    read -rs password
    echo
  fi

  if [ -z "$comment" ]; then
    printf "Commentaire []: "
    read -r comment
  fi

  local ssh_config_file="$HOME/.ssh/config"
  local relative_ssh_config_file=~/"${ssh_config_file#"$HOME"/}"
  local key_path="$HOME/.ssh/keys/$name"
  local relative_key_path=~/"${key_path#"$HOME"/}"
  local key_directory
  key_directory="$(dirname "$key_path")"

  local os_name
  os_name="$(uname -s)"
  local is_macos=false
  if [ "$os_name" = "Darwin" ]; then
    is_macos=true
  fi

  mkdir -p "$key_directory"
  chmod 700 "$HOME/.ssh"
  chmod 700 "$key_directory"

  local keygen_args=(-t ed25519 -f "$key_path" -N "$password")
  if [ -n "$comment" ]; then
    keygen_args+=(-C "$comment")
  fi

  if ! ssh-keygen "${keygen_args[@]}" >/dev/null 2>&1; then
    echo "Échec de la génération de la clé SSH" >&2
    return 1
  fi
  echo "Clé SSH générée : $relative_key_path"

  if [ -f "$ssh_config_file" ]; then
    local tmp_file
    tmp_file="$(mktemp)"
    awk '
    {
      lines[NR] = $0
      if (NF) last_non_empty = NR
    }
    END {
      for (i = 1; i <= last_non_empty; i++) print lines[i]
    }' "$ssh_config_file" >"$tmp_file"
    cat "$tmp_file" >"$ssh_config_file"
    rm -f "$tmp_file"
    if [ -s "$ssh_config_file" ]; then
      echo >>"$ssh_config_file"
    fi
  fi

  {
    echo "Host $host"
    if [ -n "$hostname" ]; then
      echo "  HostName $hostname"
    fi
    echo "  Port $port"
    if [ -n "$user" ]; then
      echo "  User $user"
    fi
    echo "  IdentityFile $relative_key_path"
    echo "  IdentitiesOnly yes"
    echo "  AddKeysToAgent yes"
    if [ "$is_macos" = true ]; then
      echo "  UseKeychain yes"
      echo "  IgnoreUnknown UseKeychain"
    fi
  } >>"$ssh_config_file"
  chmod 600 "$ssh_config_file"
  echo "Bloc Host '$host' ajouté à $relative_ssh_config_file"

  if [ "$is_macos" = true ]; then
    ssh-add --apple-use-keychain "$key_path" >/dev/null 2>&1
  else
    if [ -z "$SSH_AUTH_SOCK" ]; then
      eval "$(ssh-agent -s)" >/dev/null
    fi
    ssh-add "$key_path" >/dev/null 2>&1
  fi

  if [ $? -ne 0 ]; then
    echo "Échec de l'ajout de la clé à l'agent SSH" >&2
    return 1
  fi

  echo "Clé ajoutée à l'agent SSH"
}
