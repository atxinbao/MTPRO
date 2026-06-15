#!/usr/bin/env bash
set -euo pipefail

# GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR
# TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 Dashboard testnet read-only monitor verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 Dashboard testnet read-only monitor verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV080DashboardTestnetReadOnlyMonitorSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH815DashboardTestnetReadOnlyMonitorSurfaceShowsFreshnessLifecycleAndRedactionWithoutCommands
swift test --filter TargetGraphTests/testGH815DashboardTestnetReadOnlyMonitorSurfaceIsAnchoredInV080Guards

require_file_contains "$SOURCE" "ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel"
require_file_contains "$SOURCE" "ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact"
require_file_contains "$SOURCE" "accountSnapshotFreshness"
require_file_contains "$SOURCE" "privateStreamFreshness"
require_file_contains "$SOURCE" "listenKeyLifecycle"
require_file_contains "$SOURCE" "lastObservedEventKind"
require_file_contains "$SOURCE" "credentialRedactionStatus"
require_file_contains "$SOURCE" "stale"
require_file_contains "$SOURCE" "disconnected"
require_file_contains "$SOURCE" "recovered"
require_file_contains "$SHELL_SOURCE" "releaseV080TestnetMonitorSurface"
require_file_contains "$SHELL_SOURCE" "releaseV080TestnetMonitorRows"
require_file_contains "$APP_TESTS" "testGH815DashboardTestnetReadOnlyMonitorSurfaceShowsFreshnessLifecycleAndRedactionWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH815DashboardTestnetReadOnlyMonitorSurfaceIsAnchoredInV080Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 Dashboard testnet read-only monitor anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR"
require_file_contains "$VALIDATION_PLAN" "GH-815 Release v0.8.0 Dashboard Testnet Read-only Monitor Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR"
require_file_contains "$CONTRACT" "V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE"

for anchor in \
  "GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR" \
  "TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR" \
  "V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE" \
  "V080-009-ACCOUNT-SNAPSHOT-FRESHNESS" \
  "V080-009-PRIVATE-STREAM-FRESHNESS" \
  "V080-009-LISTENKEY-LIFECYCLE-VISIBLE" \
  "V080-009-STALE-DISCONNECTED-RECOVERED-STATES" \
  "V080-009-CREDENTIAL-LISTENKEY-REDACTION-STATUS" \
  "V080-009-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V080-009-NO-TESTNET-ORDER-ROUTING" \
  "V080-009-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"
reject_file_contains "$SOURCE" "productionSecretAutoReadEnabled = true"
reject_file_contains "$SOURCE" "productionEndpointConnected = true"
reject_file_contains "$SOURCE" "brokerEndpointConnected = true"

echo "MTPRO release v0.8.0 Dashboard testnet read-only monitor verification passed."
