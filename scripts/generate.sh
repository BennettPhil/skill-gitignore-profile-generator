#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${TEMPLATE_FILE:-$SCRIPT_DIR/../data/templates.json}"

usage() {
  cat <<'EOF'
Usage: ./scripts/generate.sh [targets...]
       ./scripts/generate.sh --list

Generates annotated .gitignore sections for supported targets.
Reads normalized target names from args or stdin.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

if [[ "${1:-}" == "--list" ]]; then
  jq -r 'keys[]' "$TEMPLATE_FILE"
  exit 0
fi

if [ "$#" -gt 0 ]; then
  input_targets="$(printf "%s\n" "$@")"
elif [ -t 0 ]; then
  echo "Error: provide targets as args or stdin." >&2
  exit 1
else
  input_targets="$(cat)"
fi

if [ -z "${input_targets//[[:space:]]/}" ]; then
  echo "Error: no targets provided." >&2
  exit 1
fi

missing=()
while IFS= read -r target; do
  [ -z "$target" ] && continue
  exists="$(jq -r --arg t "$target" 'has($t)' "$TEMPLATE_FILE")"
  if [ "$exists" != "true" ]; then
    missing+=("$target")
    continue
  fi
  printf "# ---- %s ----\n" "$target"
  jq -r --arg t "$target" '.[$t][]' "$TEMPLATE_FILE"
  echo ""
done <<<"$input_targets"

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Error: unknown target(s): ${missing[*]}" >&2
  echo "Use ./scripts/generate.sh --list to see supported targets." >&2
  exit 1
fi