# Extrait la liste des volumes Docker nommés (on ignore les volumes anonymes à ID longs de 64 caractères)
_dockerfunctions_get_volumes() {
  local volumes
  volumes=$(docker volume ls --format "{{.Name}}")

  if [ -z "$volumes" ]; then
    echo "Aucun volume Docker trouvé sur cette machine." >&2
    return 1
  fi

  # Filtrer les volumes anonymes (généralement des chaînes hexadécimales de 64 caractères)
  echo "$volumes" | grep -vE '^[a-f0-9]{64}$'
}

# Affiche le menu de sélection et retourne le volume choisi
_dockerfunctions_select_volume() {
  local volumes=()
  while IFS= read -r line; do
    [ -n "$line" ] && volumes+=("$line")
  done < <(_dockerfunctions_get_volumes)

  if [ ${#volumes[@]} -eq 0 ]; then
    echo "Aucun volume Docker nommé disponible." >&2
    return 1
  fi

  printf "%-4s %-50s\n" "#" "NOM DU VOLUME DOCKER" >&2
  printf "%-4s %-50s\n" "---" "--------------------------------------------------" >&2

  local i
  for ((i = 0; i < ${#volumes[@]}; i++)); do
    printf "%-4s %-50s\n" "$((i + 1))" "${volumes[$i]}" >&2
  done

  echo "" >&2
  local choice
  printf "Sélectionnez un volume (Entrée ou q pour annuler) : " >&2
  read -r choice

  if [ -z "$choice" ] || [ "$choice" = "q" ]; then
    return 1
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#volumes[@]}" ]; then
    echo "Sélection invalide." >&2
    return 1
  fi

  echo "${volumes[$((choice - 1))]}"
}
