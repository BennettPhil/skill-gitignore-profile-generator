#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./scripts/run.sh [targets...]
       ./scripts/run.sh --list

Examples:
  ./scripts/run.sh node,macos,vscode
  printf "python\nterraform\n" | ./scripts/run.sh
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--list" ]]; then
  exec "$SCRIPT_DIR/generate.sh" --list
fi

if [ "$#" -gt 0 ]; then
  parsed_targets="$("$SCRIPT_DIR/parse.sh" "$@")"
else
  parsed_targets="$("$SCRIPT_DIR/parse.sh")"
fi

printf "%s\n" "$parsed_targets" \
  | "$SCRIPT_DIR/generate.sh" \
  | "$SCRIPT_DIR/format.sh"