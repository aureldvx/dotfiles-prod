# Sauvegarde le contenu d'un volume docker dans /tmp/backup.tar.gz
backup_volume() {
  if [ -n "$ZSH_VERSION" ]; then
    emulate -L bash
  fi

  local volume_name="$1"
  local backup_path=""

  # Étape 1 : Sélection interactive si aucun volume n'est passé en paramètre
  if [ -z "$volume_name" ]; then
    volume_name=$(_dockerfunctions_select_volume) || {
      echo "Annulé."
      return 0
    }
  fi

  # Étape 2 : Demander le chemin cible dans le volume à sauvegarder
  shift 1
  local paths=("$@")

  if [ ${#paths[@]} -eq 0 ]; then
    printf "Chemin dans le volume à sauvegarder [/data] : "
    read -r backup_path
    [ -z "$backup_path" ] && backup_path="/data"
    paths+=("$backup_path")
  fi

  echo "Sauvegarde du volume '$volume_name' (dossier: ${paths[*]}) vers /tmp/backup.tar.gz..."

  # On monte le volume directement sur /volume_to_backup dans Alpine
  # pour pouvoir archiver indépendamment de l'état d'un conteneur actif.
  docker run --rm \
    -v /tmp:/backup \
    -v "${volume_name}:/volume_to_backup" \
    alpine tar -czvf /backup/backup.tar.gz -C /volume_to_backup "${paths[@]#/}"
}
