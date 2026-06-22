#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SOURCE="Sources/Dashboard/Report/ReleaseV0140ReadOnlyExecutionDashboardSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
READINESS_DOC="docs/automation/automation-readiness.md"
READINESS_SCRIPT="checks/automation-readiness.sh"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
LATEST_SUMMARY="docs/validation/latest-verification-summary.md"

require_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "Missing expected text in $file: $needle" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    echo "Forbidden text found in $file: $needle" >&2
    exit 1
  fi
}

ANCHORS=(
  "GH-1063-VERIFY-V0141-DASHBOARD-LOCAL-ARTIFACTS"
  "TVM-RELEASE-V0141-DASHBOARD-LOCAL-ARTIFACTS"
  "V0141-005-DASHBOARD-LOCAL-READ-MODEL-ARTIFACT"
  "V0141-005-DECODE-VALIDATE-BEFORE-DISPLAY"
  "V0141-005-DASHBOARD-READ-ONLY-NO-COMMANDS"
  "V0141-005-NO-PRODUCTION-CUTOVER"
)

for anchor in "${ANCHORS[@]}"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$READINESS_DOC" "$anchor"
  require_file_contains "$READINESS_SCRIPT" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$LATEST_SUMMARY" "$anchor"
done

require_file_contains "$SOURCE" "ReleaseV0141DashboardExecutionSurfaceLocalArtifactInput"
require_file_contains "$SOURCE" "localReadModelArtifact(fromJSON"
require_file_contains "$SOURCE" "localReadModelArtifactInput(fromJSON"
require_file_contains "$SOURCE" "isSafeLocalArtifactPath"
require_file_contains "$SOURCE" "isValidSHA256Reference"
require_file_contains "$SHELL_SOURCE" "releaseV0140ReadOnlyExecutionDashboardSurface(fromLocalReadModelJSON"
require_file_contains "$APP_TESTS" "testGH1063DashboardExecutionSurfaceLoadsLocalReadModelArtifactReadOnly"
require_file_contains "$TARGET_TESTS" "testGH1063DashboardLocalArtifactLoaderAnchorsReadOnlyBoundary"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.1-dashboard-local-artifacts.sh"

for file in "$SOURCE" "$SHELL_SOURCE"; do
  require_file_absent "$file" "productionTradingEnabledByDefault: true"
  require_file_absent "$file" "productionSecretRead: true"
  require_file_absent "$file" "productionEndpointConnected: true"
  require_file_absent "$file" "brokerEndpointConnected: true"
  require_file_absent "$file" "submitCancelReplaceEnabled: true"
  require_file_absent "$file" "productionCutoverAuthorized: true"
  require_file_absent "$file" "dashboardCommandSurfaceEnabled: true"
  require_file_absent "$file" "tradingButtonVisible: true"
  require_file_absent "$file" "orderFormVisible: true"
  require_file_absent "$file" "liveCommandVisible: true"
  require_file_absent "$file" "api.binance.com"
  require_file_absent "$file" "fapi.binance.com"
done

swift test --filter AppTests/testGH1063DashboardExecutionSurfaceLoadsLocalReadModelArtifactReadOnly
swift test --filter TargetGraphTests/testGH1063DashboardLocalArtifactLoaderAnchorsReadOnlyBoundary

printf 'MTPRO v0.14.1 Dashboard local artifact verification passed.\n'
