#!/usr/bin/env bash
set -euo pipefail

# GH-786-VERIFY-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE
# TVM-RELEASE-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 testnet signed account read-only probe verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 testnet signed account read-only probe verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH786RealBinanceTestnetSignedAccountReadOnlyProbeRequiresOperatorConfirmation

require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetSignedAccountReadOnlyProbe"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetSignedAccountReadOnlyProbeConfiguration"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetSignedAccountReadOnlyProbeArtifact"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "networkReadOnly"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "deterministicFixture"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "credentialResolvedAtCallTime"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "redactedCredentialReference"
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
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "testGH786RealBinanceTestnetSignedAccountReadOnlyProbeRequiresOperatorConfirmation"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "TargetGraphCallCountingSignedAccountCredentialProvider"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.7.0-testnet-signed-account-readonly-probe.sh"
require_file_contains \
  "docs/validation/validation-plan.md" \
  "GH-786 Release v0.7.0 Testnet Signed Account Read-only Probe Validation"
require_file_contains \
  "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE"
require_file_contains \
  "docs/automation/automation-readiness.md" \
  "Release v0.7.0 testnet signed account read-only probe anchor"
require_file_contains \
  "checks/automation-readiness.sh" \
  "GH-786-VERIFY-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE"

for anchor in \
  "GH-786-VERIFY-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE" \
  "TVM-RELEASE-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE" \
  "V070-008-OPERATOR-CONFIRMED-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE" \
  "V070-008-CALL-TIME-CREDENTIAL-RESOLUTION" \
  "V070-008-DETERMINISTIC-FIXTURE-NETWORK-READONLY-SEPARATION" \
  "V070-008-CREDENTIAL-VALUE-REDACTION" \
  "V070-008-PRODUCTION-AND-ORDER-ENDPOINT-REJECTION" \
  "V070-008-NO-ORDER-NO-PRODUCTION-BOUNDARY"; do
  require_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "submitOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "cancelOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "replaceOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "productionCutoverAuthorized = true"

echo "MTPRO release v0.7.0 testnet signed account read-only probe verification passed."
