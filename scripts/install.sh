#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./scripts/install.sh

Checks required dependencies for gitignore-profile-generator and prints
install guidance if anything is missing.
EOF
  exit 0
fi

required_tools="${REQUIRED_TOOLS:-jq awk sed grep}"
missing=()

for tool in $required_tools; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing+=("$tool")
  fi
done

if [ "${#missing[@]}" -eq 0 ]; then
  echo "Environment ready. All required tools are installed."
  exit 0
fi

echo "Missing dependencies: ${missing[*]}" >&2
case "$(uname -s)" in
  Darwin) echo "Install suggestion: brew install ${missing[*]}" >&2 ;;
  Linux) echo "Install suggestion: use your package manager (apt/dnf/pacman)." >&2 ;;
  *) echo "Install the missing tools and rerun ./scripts/install.sh." >&2 ;;
esac
exit 1