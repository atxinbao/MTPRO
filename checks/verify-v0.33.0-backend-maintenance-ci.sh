#!/usr/bin/env bash
set -euo pipefail

# GH-1575-V0330-BACKEND-MAINTENANCE-CI
# GH-1575-CROSS-PLATFORM-CRYPTO
# GH-1575-SWIFT-SQLITE-PREREQUISITES
# GH-1575-FAIL-CLOSED-SELF-TEST

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="${MTPRO_MAINTENANCE_CI_ROOT:-$SCRIPT_ROOT}"

fail() {
  printf 'v0.33 backend maintenance CI verification failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$ROOT/$1" ]] || fail "missing file: $1"
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$ROOT/$file" || fail "$file must contain: $expected"
}

require_file "Package.swift"
require_file ".github/workflows/checks.yml"
require_file "checks/run.sh"
require_file "checks/verify-v0.33.0-demo-validation.sh"
require_file "docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md"
require_file "docs/release/mtpro-release-v0.33.0-demo-validation-notes.md"

require_contains "Package.swift" "https://github.com/apple/swift-crypto.git"
require_contains "Package.swift" '.product(name: "Crypto", package: "swift-crypto")'
require_contains ".github/workflows/checks.yml" "runs-on: ubuntu-24.04"
require_contains ".github/workflows/checks.yml" 'MTPRO_CI_SWIFT_VERSION_FAMILY: "6.3.x"'
require_contains ".github/workflows/checks.yml" "sudo apt-get install -y libsqlite3-dev"
require_contains ".github/workflows/checks.yml" "runs-on: macos-15"
require_contains ".github/workflows/checks.yml" "swift build --product Dashboard"
require_contains ".github/workflows/checks.yml" "bash checks/verify-v0.33.0-backend-maintenance-ci.sh"
require_contains "checks/run.sh" "set -euo pipefail"
require_contains "checks/run.sh" "require_swift_toolchain"
require_contains "checks/run.sh" "require_sqlite_pkg_config"
require_contains "checks/run.sh" "bash checks/verify-v0.33.0-backend-maintenance-ci.sh"
require_contains "checks/verify-v0.33.0-demo-validation.sh" "set -euo pipefail"
require_contains "docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md" "GH-1579-V0330-BACKEND-MAINTENANCE-CLOSEOUT"
require_contains "docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md" "patchReleaseDecision=not-warranted"
require_contains "docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md" "v0.33.1TagCreated=false"
require_contains "docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md" "v0.33.0TagMoved=false"
require_contains "docs/release/mtpro-release-v0.33.0-demo-validation-notes.md" "GH-1579-V0330-BACKEND-MAINTENANCE-CLOSEOUT"
require_contains "docs/release/mtpro-release-v0.33.0-demo-validation-notes.md" "productionCutoverAuthorized=false"

crypto_kit_matches="$(
  find "$ROOT/Sources" -type f -name '*.swift' -print0 \
    | xargs -0 grep -Hn -F 'import CryptoKit' 2>/dev/null \
    || true
)"
if [[ -n "$crypto_kit_matches" ]]; then
  printf '%s\n' "$crypto_kit_matches" >&2
  fail "production Sources must use cross-platform Crypto instead of CryptoKit"
fi

if [[ "${MTPRO_MAINTENANCE_CI_SKIP_SELF_TEST:-0}" != "1" ]]; then
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-maintenance-ci.XXXXXX")"
  trap 'rm -rf "$fixture_root"' EXIT

  mkdir -p \
    "$fixture_root/.github/workflows" \
    "$fixture_root/checks" \
    "$fixture_root/docs/audit" \
    "$fixture_root/docs/release" \
    "$fixture_root/Sources/MaintenanceFixture"
  cp "$ROOT/Package.swift" "$fixture_root/Package.swift"
  cp "$ROOT/.github/workflows/checks.yml" "$fixture_root/.github/workflows/checks.yml"
  cp "$ROOT/checks/run.sh" "$fixture_root/checks/run.sh"
  cp \
    "$ROOT/checks/verify-v0.33.0-demo-validation.sh" \
    "$fixture_root/checks/verify-v0.33.0-demo-validation.sh"
  cp \
    "$ROOT/docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md" \
    "$fixture_root/docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md"
  cp \
    "$ROOT/docs/release/mtpro-release-v0.33.0-demo-validation-notes.md" \
    "$fixture_root/docs/release/mtpro-release-v0.33.0-demo-validation-notes.md"
  printf 'import CryptoKit\n' > "$fixture_root/Sources/MaintenanceFixture/Forbidden.swift"

  set +e
  negative_output="$(
    MTPRO_MAINTENANCE_CI_ROOT="$fixture_root" \
      MTPRO_MAINTENANCE_CI_SKIP_SELF_TEST=1 \
      bash "$0" 2>&1
  )"
  negative_status=$?
  set -e

  [[ "$negative_status" -ne 0 ]] || fail "CryptoKit drift self-test must return nonzero"
  grep -Fq "must use cross-platform Crypto instead of CryptoKit" <<< "$negative_output" \
    || fail "CryptoKit drift self-test must report the failed boundary"
fi

printf 'MTPRO v0.33 backend maintenance cross-platform CI verification passed.\n'
