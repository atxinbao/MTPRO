#!/usr/bin/env bash
set -euo pipefail

# GH-765-VERIFY-V060-TESTNET-READONLY-PROBE
# TVM-RELEASE-V060-TESTNET-READONLY-PROBE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 testnet read-only probe verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.6.0 testnet read-only probe verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH765TestnetReadOnlyProbeRequiresExplicitConfirmationAndRedactsCredentials

require_file_contains \
  "Package.swift" \
  "\"Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift\""
require_file_contains \
  "Package.swift" \
  "dependencies: [\"DomainModel\", \"Database\", \"DataClient\", \"Portfolio\"]"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV060TestnetReadOnlyProbe"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV060TestnetReadOnlyProbeArtifact"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "operatorConfirmedReadOnlyProbe"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "productionEndpointForbidden"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "testnet.binance.vision"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "api.binance.com"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "redactedCredentialReference"
require_file_contains \
  "Sources/MTPROCLI/main.swift" \
  "ReleaseV060TestnetReadOnlyProbe.cliCommand"
require_file_contains \
  "Sources/MTPROCLI/main.swift" \
  "ReleaseV060TestnetReadOnlyProbe.commandLineOutput"
require_file_contains \
  "checks/verify-v0.5.0-cli.sh" \
  "testnet-readonly-probe"
require_file_contains \
  "docs/contracts/release-v0.6.0-testnet-read-only-probe-contract.md" \
  "V060-011-TESTNET-READ-ONLY-PROBE"
require_file_contains \
  "docs/contracts/release-v0.6.0-testnet-read-only-probe-contract.md" \
  "V060-011-OPERATOR-CONFIRMED-TESTNET-PROFILE"
require_file_contains \
  "docs/contracts/release-v0.6.0-testnet-read-only-probe-contract.md" \
  "V060-011-CREDENTIAL-REDACTION-DASHBOARD-CLI"
require_file_contains \
  "docs/contracts/release-v0.6.0-testnet-read-only-probe-contract.md" \
  "TVM-RELEASE-V060-TESTNET-READONLY-PROBE"
require_file_contains \
  "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V060-TESTNET-READONLY-PROBE"
require_file_contains \
  "docs/validation/validation-plan.md" \
  "GH-765 Release v0.6.0 Testnet Read-only Probe Validation"
require_file_contains \
  "docs/automation/automation-readiness.md" \
  "Release v0.6.0 testnet read-only probe anchor"
require_file_contains \
  "checks/automation-readiness.sh" \
  "GH-765-VERIFY-V060-TESTNET-READONLY-PROBE"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.6.0-testnet-readonly-probe.sh"

reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "submitOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "cancelOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "replaceOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "productionCutoverAuthorized = true"

echo "MTPRO release v0.6.0 testnet read-only probe verification passed."
