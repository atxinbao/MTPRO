#!/usr/bin/env bash
set -euo pipefail

# GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS
# TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS
# V0150-009-DASHBOARD-READ-MODEL-ARTIFACT
# V0150-009-SUBMIT-CANCEL-CANCEL-REPLACE-STATUS
# V0150-009-OMS-RECONCILIATION-FAILURE-REASONS
# V0150-009-DASHBOARD-READ-ONLY-NO-COMMANDS
# V0150-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 dashboard testnet execution status guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.15.0 dashboard testnet execution status guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV0150DashboardTestnetExecutionStatusSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
CONTRACT="docs/contracts/release-v0.15.0-dashboard-testnet-execution-status-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter AppTests/testGH1074DashboardTestnetExecutionStatusSurfaceShowsReadOnlyStatusWithoutCommands
swift test --filter TargetGraphTests/testGH1074DashboardTestnetExecutionStatusSurfaceIsAnchoredInV0150Guards

for anchor in \
  "GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS" \
  "TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS" \
  "V0150-009-DASHBOARD-READ-MODEL-ARTIFACT" \
  "V0150-009-SUBMIT-CANCEL-CANCEL-REPLACE-STATUS" \
  "V0150-009-OMS-RECONCILIATION-FAILURE-REASONS" \
  "V0150-009-DASHBOARD-READ-ONLY-NO-COMMANDS" \
  "V0150-009-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

for required_string in \
  "ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel" \
  "ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput" \
  "dashboardConsumesReadModelArtifactsOnly=true" \
  "submitCancelCancelReplaceStatusVisible=true" \
  "omsStateVisible=true" \
  "reconciliationStateVisible=true" \
  "failureReasonsVisible=true" \
  "dashboardCommandSurfaceEnabled=false" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionSubmitCancelReplaceEnabled=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$SHELL_SOURCE" "releaseV0150DashboardTestnetExecutionStatusSurface"
require_file_contains "$SHELL_SOURCE" "releaseV0150DashboardTestnetExecutionStatusSurface(fromLocalReadModelJSON"
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV0150TestnetExecutionStatusPanel"
require_file_contains "$SHELL_SOURCE" "releaseV0150ExecutionStatusRows"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-dashboard-testnet-execution-status.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-dashboard-testnet-execution-status.sh"
require_file_contains "$READINESS" "Release v0.15.0 Dashboard testnet execution status anchor"
require_file_contains "$LATEST" "v0.15.0 Dashboard testnet execution status"
require_file_contains "$PLAN" "GH-1074 Release v0.15.0 Dashboard Testnet Execution Status"
require_file_contains "$MATRIX" "TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS"
require_file_contains "$APP_TESTS" "testGH1074DashboardTestnetExecutionStatusSurfaceShowsReadOnlyStatusWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1074DashboardTestnetExecutionStatusSurfaceIsAnchoredInV0150Guards"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionSubmitCancelReplaceEnabled=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$CONTRACT" "$forbidden"
done

printf 'MTPRO release v0.15.0 dashboard testnet execution status verification passed.\n'
