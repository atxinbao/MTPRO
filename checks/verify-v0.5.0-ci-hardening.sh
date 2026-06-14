#!/usr/bin/env bash
set -euo pipefail

# GH-738-VERIFY-V050-CI-HARDENING
# TVM-RELEASE-V050-CI-HARDENING

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 CI hardening verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 CI hardening verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

require_file_contains ".github/workflows/checks.yml" "workflow_dispatch:"
require_file_contains ".github/workflows/checks.yml" "tags:"
require_file_contains ".github/workflows/checks.yml" "\"v*\""
require_file_contains ".github/workflows/checks.yml" "linux_checks:"
require_file_contains ".github/workflows/checks.yml" "name: linux-checks"
require_file_contains ".github/workflows/checks.yml" "runs-on: ubuntu-24.04"
require_file_contains ".github/workflows/checks.yml" "bash checks/run.sh"
require_file_contains ".github/workflows/checks.yml" "dashboard_macos:"
require_file_contains ".github/workflows/checks.yml" "name: dashboard-macos"
require_file_contains ".github/workflows/checks.yml" "runs-on: macos-15"
require_file_contains ".github/workflows/checks.yml" "MTPRO macOS Dashboard validation policy"
require_file_contains ".github/workflows/checks.yml" "Swift version 6\\\\."
require_file_contains ".github/workflows/checks.yml" "bash checks/verify-v0.5.0-preflight.sh"
require_file_contains ".github/workflows/checks.yml" "swift build --product Dashboard"
require_file_contains ".github/workflows/checks.yml" "DASHBOARD_SMOKE=1 swift run Dashboard"
require_file_contains ".github/workflows/checks.yml" "name: checks"
require_file_contains ".github/workflows/checks.yml" "needs:"
require_file_contains ".github/workflows/checks.yml" "MTPRO required checks aggregate"
require_file_contains ".github/workflows/checks.yml" "needs.linux_checks.result"
require_file_contains ".github/workflows/checks.yml" "needs.dashboard_macos.result"
require_file_contains "checks/run.sh" "bash checks/verify-v0.5.0-ci-hardening.sh"
require_file_contains "checks/automation-readiness.sh" "GH-738-VERIFY-V050-CI-HARDENING"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.5.0 CI hardening anchor"
require_file_contains "docs/automation/ci-reproducibility.md" "GH-738-CI-DASHBOARD-MACOS-REQUIRED-GATE"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V050-CI-HARDENING"
require_file_contains "docs/validation/validation-plan.md" "GH-738 Release v0.5.0 CI Hardening Validation"

reject_file_contains ".github/workflows/checks.yml" "pull_request_target"
reject_file_contains ".github/workflows/checks.yml" "secrets."
reject_file_contains ".github/workflows/checks.yml" "api.binance.com"
reject_file_contains ".github/workflows/checks.yml" "fapi.binance.com"
reject_file_contains ".github/workflows/checks.yml" "productionTradingEnabledByDefault=true"
reject_file_contains ".github/workflows/checks.yml" "productionEndpointConnected=true"
reject_file_contains ".github/workflows/checks.yml" "productionSecretRead=true"
reject_file_contains ".github/workflows/checks.yml" "productionOrderSubmitted=true"
reject_file_contains ".github/workflows/checks.yml" "productionCutoverAuthorized=true"

echo "MTPRO release v0.5.0 CI hardening verification passed."
