#!/usr/bin/env bash
set -euo pipefail

READINESS_DOMAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$READINESS_DOMAIN_DIR/../.." && pwd)"

cd "$ROOT"

fail() {
  printf 'automation readiness domain check failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] || fail "missing required file: $file"
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

require_absent() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

require_missing_path() {
  local path="$1"
  [[ ! -e "$path" ]] || fail "retired path must not exist: $path"
}
