#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./scripts/parse.sh [targets...]

Parses target names from arguments or stdin.
Accepted separators: commas, semicolons, whitespace, and newlines.
Outputs one normalized target per line.
EOF
  exit 0
fi

if [ "$#" -gt 0 ]; then
  raw_input="$(printf "%s\n" "$@")"
elif [ -t 0 ]; then
  echo "Error: provide targets as args or stdin." >&2
  exit 1
else
  raw_input="$(cat)"
fi

if [ -z "${raw_input//[[:space:]]/}" ]; then
  echo "Error: no targets provided." >&2
  exit 1
fi

printf "%s\n" "$raw_input" \
  | tr ',;' '\n' \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
  | awk 'NF > 0 && !seen[$0]++ { print $0 }'