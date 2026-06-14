#!/usr/bin/env bash
set -euo pipefail

# GH-755-VERIFY-V060-BOUNDARY-NO-PRODUCTION
# TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 boundary verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.6.0 boundary verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "V060-001-RELEASE-BOUNDARY-NO-PRODUCTION-CONTRACT"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "V060-001-LOCAL-OPERATIONAL-RUNTIME-SCOPE"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "V060-001-NO-PRODUCTION-ACCEPTANCE-GATE"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "V060-001-DOWNSTREAM-QUEUE-ORDER"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "V060-001-FORBIDDEN-PRODUCTION-CAPABILITIES"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "productionTradingEnabledByDefault=false"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "productionSecretResolutionEnabled=false"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "productionEndpointConnectionEnabled=false"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "realOrderAuthorizationEnabled=false"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "productionCutoverAuthorized=false"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "GH-755..GH-766"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "GH-756"
require_file_contains \
  "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" \
  "GH-766"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.6.0-boundary.sh"
require_file_contains \
  "checks/automation-readiness.sh" \
  "GH-755-VERIFY-V060-BOUNDARY-NO-PRODUCTION"
require_file_contains \
  "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT"
require_file_contains \
  "docs/validation/validation-plan.md" \
  "GH-755 Release v0.6.0 Boundary / No-production Contract Validation"
require_file_contains \
  "docs/automation/automation-readiness.md" \
  "Release v0.6.0 boundary / no-production contract anchor"

reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "productionTradingEnabledByDefault=true"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "productionSecretResolutionEnabled=true"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "productionEndpointConnectionEnabled=true"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "realOrderAuthorizationEnabled=true"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "productionCutoverAuthorized=true"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "api.binance.com"
reject_file_contains "docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md" "fapi.binance.com"

echo "MTPRO release v0.6.0 boundary / no-production verification passed."
