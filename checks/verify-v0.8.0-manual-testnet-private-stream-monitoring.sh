#!/usr/bin/env bash
set -euo pipefail

# GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING
# TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 manual testnet private stream monitoring verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 manual testnet private stream monitoring verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetPrivateStreamMonitoringProof.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder

require_file_contains "Package.swift" "Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetPrivateStreamMonitoringProof.swift"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofWorkflow"
require_file_contains "$SOURCE" "listenKeyOpened"
require_file_contains "$SOURCE" "privateStreamObserved"
require_file_contains "$SOURCE" "listenKeyClosed"
require_file_contains "$SOURCE" "accountBalancePositionReadModelObserved"
require_file_contains "$SOURCE" "redactedListenKeyReference"
require_file_contains "$SOURCE" "executionReportCommandPathEnabled"
require_file_contains "$SOURCE" "testnetReadOnlyMonitoringAllowed"
require_file_contains "$SOURCE" "testnetOrderRoutingAllowed"
require_file_contains "$TESTS" "testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 manual testnet private stream monitoring anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING"
require_file_contains "$VALIDATION_PLAN" "GH-814 Release v0.8.0 Manual Testnet Private Stream Monitoring Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING"
require_file_contains "$CONTRACT" "V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING"

for anchor in \
  "GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING" \
  "TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING" \
  "V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING" \
  "V080-008-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE" \
  "V080-008-ACCOUNT-BALANCE-POSITION-READMODEL" \
  "V080-008-REDACTED-LISTENKEY-CREDENTIAL-REFERENCE" \
  "V080-008-EXECUTIONREPORT-COMMAND-PATH-REJECTION" \
  "V080-008-NO-TESTNET-ORDER-ROUTING" \
  "V080-008-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"
reject_file_contains "$SOURCE" "productionSecretRead = true"
reject_file_contains "$SOURCE" "productionEndpointConnected = true"

echo "MTPRO release v0.8.0 manual testnet private stream monitoring verification passed."
