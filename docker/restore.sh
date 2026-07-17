# Restore files from /tmp/backup.tar.gz into a docker volume
volume_restore() {
  if [ -n "$ZSH_VERSION" ]; then
    emulate -L bash
  fi

  local volume_name="$1"
  local restore_path=""

  # Étape 1 : Sélection interactive si non fourni
  if [ -z "$volume_name" ]; then
    volume_name=$(_dockerfunctions_select_volume) || {
      echo "Annulé."
      return 0
    }
  fi

  # Étape 2 : Demander le chemin de destination
  shift 1
  local paths=("$@")

  if [ ${#paths[@]} -eq 0 ]; then
    printf "Chemin de restauration dans le volume [/data] : "
    read -r restore_path
    [ -z "$restore_path" ] && restore_path="/data"
    paths+=("$restore_path")
  fi

  if [ ! -f "/tmp/backup.tar.gz" ]; then
    echo "Erreur : Le fichier /tmp/backup.tar.gz est introuvable." >&2
    return 1
  fi

  echo "Restauration de /tmp/backup.tar.gz dans le volume '$volume_name' (chemin: ${paths[*]})..."
  docker run --rm \
    -v /tmp:/backup \
    -v "${volume_name}:/volume_to_restore" \
    alpine tar -xzvf /backup/backup.tar.gz -C /volume_to_restore

  echo "Vérification des fichiers restaurés..."
  docker run --rm \
    -v "${volume_name}:/volume_to_restore" \
    alpine ls -lh "/volume_to_restore/${paths[*]#/}"
}
