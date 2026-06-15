#!/usr/bin/env bash
set -euo pipefail

# GH-787-VERIFY-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE
# TVM-RELEASE-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 testnet private stream read-only probe verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 testnet private stream read-only probe verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH787TestnetPrivateStreamReadOnlyProbeOpensObservesAndClosesRedactedListenKey

require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetPrivateStreamReadOnlyProbe"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetPrivateStreamReadOnlyProbeConfiguration"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "ReleaseV070TestnetPrivateStreamReadOnlyProbeArtifact"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "listenKeyOpened"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "privateStreamObserved"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "listenKeyClosed"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "redactedListenKeyReference"
require_file_contains \
  "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" \
  "executionReportCommandPathEnabled"
require_file_contains \
  "Sources/DataClient/Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift" \
  "stream.binance.com"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "testGH787TestnetPrivateStreamReadOnlyProbeOpensObservesAndClosesRedactedListenKey"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.7.0-testnet-private-stream-readonly-probe.sh"
require_file_contains \
  "docs/validation/validation-plan.md" \
  "GH-787 Release v0.7.0 Testnet Private Stream Read-only Probe Validation"
require_file_contains \
  "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE"
require_file_contains \
  "docs/automation/automation-readiness.md" \
  "Release v0.7.0 testnet private stream read-only probe anchor"
require_file_contains \
  "checks/automation-readiness.sh" \
  "GH-787-VERIFY-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE"

for anchor in \
  "GH-787-VERIFY-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE" \
  "TVM-RELEASE-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE" \
  "V070-009-OPERATOR-CONFIRMED-TESTNET-PRIVATE-STREAM-READONLY-PROBE" \
  "V070-009-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE" \
  "V070-009-LISTENKEY-AND-CREDENTIAL-REDACTION" \
  "V070-009-ACCOUNT-POSITION-BALANCE-READMODEL-EVIDENCE" \
  "V070-009-EXECUTIONREPORT-COMMAND-PATH-REJECTION" \
  "V070-009-NO-ORDER-NO-PRODUCTION-BOUNDARY"; do
  require_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "submitOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "cancelOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "replaceOrder"
reject_file_contains "Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV060TestnetReadOnlyProbe.swift" "productionCutoverAuthorized = true"

echo "MTPRO release v0.7.0 testnet private stream read-only probe verification passed."
