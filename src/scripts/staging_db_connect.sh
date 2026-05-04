#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${CONTEXT:-gke_jump-dev-384216_us-central1-c_main}"
NAMESPACE="${NAMESPACE:-dev-namespace}"
SECRET="${SECRET:-dev-db-secrets}"
CONNECT_MODE="psql"
PROXY_PORT="${PROXY_PORT:-54320}"
PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
DB_SUFFIX=""
DB_USER=""
DB_PASSWORD=""

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd kubectl
require_cmd jq
require_cmd fzf
require_cmd lsof
require_cmd python3

usage() {
  cat <<'EOF'
Connect to a staging environment database.

Usage: staging_db_connect.sh <pr_number> [-c]
       staging_db_connect.sh -gh [-me] [-c]
       staging_db_connect.sh -h

Notes:
  - Run scripts/dev-db-proxy.sh before using this script to start the db proxy.
  - -c prints connection info for app connection instead of opening psql. Use this for Postico.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

fail() {
  echo "$1" >&2
  exit "${2:-1}"
}

ensure_proxy_running() {
  if lsof -nP -iTCP:"$PROXY_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    return
  fi

  fail "Database proxy is not running on $PROXY_HOST:$PROXY_PORT. Please run: scripts/dev-db-proxy.sh"
}

parse_args() {
  if [[ "${1:-}" == "-gh" ]]; then
    require_cmd gh
    local -a gh_author_args=()
    shift
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -me)
          gh_author_args=(--author "@me")
          ;;
        -c)
          CONNECT_MODE="print"
          ;;
      esac
      shift
    done
    local -a gh_pr_cmd=(gh pr list --state open --json number,title,headRefName --limit 200)
    if [[ ${#gh_author_args[@]} -gt 0 ]]; then
      gh_pr_cmd+=("${gh_author_args[@]}")
    fi
    PR_NUMBER=$(
      "${gh_pr_cmd[@]}" \
        | jq -r '.[] | "\(.number) | \(.title) | \(.headRefName)"' \
        | fzf --prompt="Select PR: " --delimiter='|' --with-nth=1,2,3 \
        | awk -F'\\|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1}'
    )
  else
    PR_NUMBER="${1:-}"
    if [[ "${2:-}" == "-c" ]]; then
      CONNECT_MODE="print"
    fi
  fi

  if [[ -z "$PR_NUMBER" ]]; then
    usage >&2
    exit 1
  fi
}

load_entries() {
  local entries_output entries_status
  entries_output=$(
    set -o pipefail
    kubectl --context "$CONTEXT" -n "$NAMESPACE" get secret "$SECRET" -o json \
      | jq -r '.data | to_entries[] | select(.key | test("database_url"; "i")) | "\(.key)=\(.value|@base64d)"' \
      | awk '{uri=$0; sub(/^[^=]+=/, "", uri); sub(/^.*\//, "", uri); print uri "\t" $0}'
  )
  entries_status=$?
  if [[ $entries_status -ne 0 ]]; then
    fail "Failed to load database_url entries from secret $SECRET (context: $CONTEXT, namespace: $NAMESPACE)" "$entries_status"
  fi
  if [[ -z "$entries_output" ]]; then
    fail "No database_url entries found in secret $SECRET"
  fi
  printf '%s\n' "$entries_output"
}

select_entry() {
  local entries_output selection
  entries_output="$1"
  selection=$(printf '%s\n' "$entries_output" | fzf --prompt="Select database: " --delimiter=$'\t' --with-nth=1 | awk -F'\t' '{print $2}')
  if [[ -z "$selection" ]]; then
    fail "No selection made"
  fi
  printf '%s\n' "$selection"
}

parse_database_url() {
  local uri parsed
  uri="$1"
  parsed=$(
    python3 - <<'PY' "$uri"
import sys
from urllib.parse import urlparse, unquote

uri = sys.argv[1]
parsed = urlparse(uri)
user = parsed.username or ""
password = parsed.password or ""
db_name = parsed.path.rsplit("/", 1)[-1]
db_suffix = db_name.rsplit("-", 1)[-1]
print("\t".join((unquote(user), unquote(password), db_suffix)))
PY
  )
  IFS=$'\t' read -r DB_USER DB_PASSWORD DB_SUFFIX <<<"$parsed"
}

connect_or_print() {
  if [[ "$CONNECT_MODE" == "print" ]]; then
    echo "Host: $PROXY_HOST"
    echo "Port: $PROXY_PORT"
    echo "User: $DB_USER"
    echo "Password: $DB_PASSWORD"
    echo "Database: pr-${PR_NUMBER}-${DB_SUFFIX}"
  else
    PGPASSWORD="$DB_PASSWORD" psql -h "$PROXY_HOST" -p "$PROXY_PORT" -U "$DB_USER" -d "pr-${PR_NUMBER}-${DB_SUFFIX}"
  fi
}

ensure_proxy_running
parse_args "$@"
entries="$(load_entries)"
selected="$(select_entry "$entries")"
# Selected format includes a database URL value from the Kubernetes secret.
parse_database_url "${selected#*=}"
connect_or_print
