#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run.sh"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL: $1 -- $2"; }

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if printf "%s" "$haystack" | grep -Fq "$needle"; then
    pass "$desc"
  else
    fail "$desc" "missing '$needle'"
  fi
}

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    pass "$desc"
  else
    fail "$desc" "expected '$expected', got '$actual'"
  fi
}

echo "Running gitignore-profile-generator tests"
echo "========================================="

list_output="$("$RUNNER" --list)"
assert_contains "list includes node target" "node" "$list_output"
assert_contains "list includes python target" "python" "$list_output"

main_output="$("$RUNNER" "node,macos,vscode")"
assert_contains "node section header exists" "# ---- node ----" "$main_output"
assert_contains "macos pattern exists" ".DS_Store" "$main_output"
assert_contains "vscode pattern exists" ".vscode/" "$main_output"

stdin_output="$(printf "python\nmacos\n" | "$RUNNER")"
assert_contains "stdin path includes python cache rule" "__pycache__/" "$stdin_output"
assert_contains "stdin path includes macos rule" ".DS_Store" "$stdin_output"

dedupe_output="$("$RUNNER" "node,react")"
dist_count="$(printf "%s\n" "$dedupe_output" | awk '$0=="dist/" {c++} END {print c+0}')"
assert_eq "duplicate dist/ pattern is emitted once" "1" "$dist_count"

set +e
"$RUNNER" not-a-real-target >/tmp/gitignore-skill-test.out 2>/tmp/gitignore-skill-test.err
unknown_code=$?
set -e
unknown_err="$(cat /tmp/gitignore-skill-test.err)"
assert_eq "unknown target exits non-zero" "1" "$unknown_code"
assert_contains "unknown target prints helpful error" "unknown target" "$unknown_err"

echo "========================================="
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]