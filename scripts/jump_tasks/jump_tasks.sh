#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/Users/sheltontolbert/repos/Jump/api"
STAGING_DB_SCRIPT="/Users/sheltontolbert/.dot-files/src/scripts/staging_db_connect.sh"

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"
PGDATABASE="${PGDATABASE:-jump_dev}"
LOGS_PGDATABASE="${LOGS_PGDATABASE:-jump_logs_dev}"
VECTORS_PGDATABASE="${VECTORS_PGDATABASE:-jump_vectors_dev}"
VECTORS_NEXT_PGDATABASE="${VECTORS_NEXT_PGDATABASE:-jump_vectors_next_dev}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF_USAGE'
Jump tasks helper for the Jump API repo.

Usage:
  jump_tasks.sh                # interactive menu
  jump_tasks.sh list            # list common commands
  jump_tasks.sh migrate <repo>  # repo: dev | logs | vectors | vectors_next
  jump_tasks.sh psql <repo>     # repo: dev | logs
  jump_tasks.sh staging <args>  # forwards args to staging_db_connect.sh

Environment defaults (override as needed):
  PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE
  LOGS_PGDATABASE, VECTORS_PGDATABASE, VECTORS_NEXT_PGDATABASE
EOF_USAGE
}

list_commands() {
  cat <<'EOF_LIST'
Common commands:
  - Migrate Jump.Repo:         mix ecto.migrate -r Jump.Repo
  - Migrate Jump.LogsRepo:     mix ecto.migrate -r Jump.LogsRepo
  - Migrate Jump.VectorsRepo:  mix ecto.migrate -r Jump.VectorsRepo
  - Migrate Jump.VectorsNext:  mix ecto.migrate -r Jump.VectorsNextRepo
  - psql dev db:               psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE
  - psql logs db:              psql -h $PGHOST -p $PGPORT -U $PGUSER -d $LOGS_PGDATABASE
  - staging db connect:        /Users/sheltontolbert/.dot-files/src/scripts/staging_db_connect.sh
EOF_LIST
}

run_migrate() {
  local repo="$1"
  require_cmd mix
  (
    cd "$REPO_ROOT"
    mix ecto.migrate -r "$repo"
  )
}

run_psql() {
  local db_name="$1"
  require_cmd psql
  PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name"
}

run_staging() {
  if [[ ! -x "$STAGING_DB_SCRIPT" ]]; then
    echo "Missing staging db script: $STAGING_DB_SCRIPT" >&2
    exit 1
  fi
  "$STAGING_DB_SCRIPT" "$@"
}

menu() {
  cat <<'EOF_MENU'
Select a task:
  1) Migrate Jump.Repo (dev)
  2) Migrate Jump.LogsRepo (logs)
  3) Migrate Jump.VectorsRepo (vectors)
  4) Migrate Jump.VectorsNextRepo (vectors_next)
  5) Connect psql to dev db
  6) Connect psql to logs db
  7) Connect to staging db
  8) List commands
  9) Exit
EOF_MENU

  read -r -p "Enter choice: " choice
  case "$choice" in
    1) run_migrate "Jump.Repo" ;;
    2) run_migrate "Jump.LogsRepo" ;;
    3) run_migrate "Jump.VectorsRepo" ;;
    4) run_migrate "Jump.VectorsNextRepo" ;;
    5) run_psql "$PGDATABASE" ;;
    6) run_psql "$LOGS_PGDATABASE" ;;
    7) run_staging ;;
    8) list_commands ;;
    9) exit 0 ;;
    *) echo "Unknown choice" >&2; exit 1 ;;
  esac
}

main() {
  case "${1:-}" in
    "") menu ;;
    -h|--help) usage ;;
    list) list_commands ;;
    migrate)
      case "${2:-}" in
        dev) run_migrate "Jump.Repo" ;;
        logs) run_migrate "Jump.LogsRepo" ;;
        vectors) run_migrate "Jump.VectorsRepo" ;;
        vectors_next) run_migrate "Jump.VectorsNextRepo" ;;
        *) echo "Unknown repo: ${2:-}" >&2; exit 1 ;;
      esac
      ;;
    psql)
      case "${2:-}" in
        dev) run_psql "$PGDATABASE" ;;
        logs) run_psql "$LOGS_PGDATABASE" ;;
        *) echo "Unknown repo: ${2:-}" >&2; exit 1 ;;
      esac
      ;;
    staging)
      shift
      run_staging "$@"
      ;;
    *)
      echo "Unknown command: ${1:-}" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
