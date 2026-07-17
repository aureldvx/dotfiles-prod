# ==========================================
# FONCTION PRIVÉE DE DÉTECTION (PARTAGÉE)
# ==========================================
_detect_compose_files() {
  # Cette fonction s'attend à ce que la fonction parente
  # ait défini un tableau local nommé 'compose_flags'
  local base_file=""

  # 1. Recherche du fichier de base
  for f in compose.yaml compose.yml docker-compose.yaml docker-compose.yml; do
    if [ -f "$f" ]; then
      base_file="$f"
      break
    fi
  done

  # 2. Si trouvé, on ajoute le fichier de base et son éventuel override de prod
  if [ -n "$base_file" ]; then
    compose_flags+=("-f" "$base_file")

    local prod_file="${base_file%.*}.prod.${base_file##*.}"
    if [ -f "$prod_file" ]; then
      compose_flags+=("-f" "$prod_file")
    fi
  fi
}

# ==========================================
# RACCOURCIS (UTILISATIONS)
# ==========================================

# `docker compose up`
function dcu() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" up "$@"
}

# `docker compose up -d` (detached)
function dcud() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" up -d "$@"
}

# `docker compose build`
function dcb() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" build "$@"
}

# `docker compose up -d --build` (build puis detach)
function dcub() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" up -d --build "$@"
}

# `docker compose run`
function dcr() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" run --remove-orphans --rm "$@"
}

# `docker compose exec`
function dce() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" exec "$@"
}

# `docker compose down`
function dcd() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" down --remove-orphans "$@"
}

# `docker compose logs` (avec suivi optionnel, ex: dcl -f)
function dcl() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" logs "$@"
}

# `docker compose ps` (état des conteneurs)
function dcps() {
  local compose_flags=()
  _detect_compose_files
  docker compose "${compose_flags[@]}" ps "$@"
}

# `docker ps` (état des conteneurs compact)
function dps() {
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# (start|stop|restart|status) docker rootless service
function dock() {
  systemctl --user "$@" docker
}

# supprime toutes les ressources inutilisées
function dclean() {
  docker system prune -a
}

# Affiche la consommation de ressources (CPU/RAM) des conteneurs en temps réel, triée
function dtop() {
  docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}
