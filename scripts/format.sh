#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./scripts/format.sh

Formats .gitignore content from stdin:
- Deduplicates non-comment patterns
- Collapses repeated blank lines
EOF
  exit 0
fi

if [ -t 0 ]; then
  echo "Error: expected .gitignore content on stdin." >&2
  exit 1
fi

awk '
  BEGIN { blank = 0 }
  {
    line = $0
    if (line ~ /^[[:space:]]*$/) {
      if (blank) next
      blank = 1
      print ""
      next
    }

    blank = 0
    if (line ~ /^[[:space:]]*#/) {
      print line
      next
    }

    if (!seen[line]++) print line
  }
'