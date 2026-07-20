#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV0160DashboardArtifactBackedExecutionView.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
CONTRACT="docs/contracts/release-v0.16.0-dashboard-artifact-backed-execution-view-contract.md"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1108-VERIFY-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW"
  "TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW"
  "V0160-008-LOCAL-ARTIFACT-BACKED-ROWS"
  "V0160-008-ACTION-SEQUENCE-VISIBLE"
  "V0160-008-CHECKSUMS-VISIBLE"
  "V0160-008-OMS-RECONCILIATION-RESULT-VISIBLE"
  "V0160-008-DASHBOARD-READ-ONLY-NO-COMMANDS"
  "V0160-008-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$CONTRACT" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "$SOURCE" "dashboardArtifactBackedExecutionView=ReleaseV0160DashboardArtifactBackedExecutionViewModel"
require_file_contains "$SOURCE" "localArtifactBackedRows=true"
require_file_contains "$SOURCE" "actionSequenceVisible=true"
require_file_contains "$SOURCE" "checksumsVisible=true"
require_file_contains "$SOURCE" "omsReconciliationResultVisible=true"
require_file_contains "$SOURCE" "dashboardCommandSurfaceEnabled=false"
require_file_contains "$SOURCE" "tradingButtonVisible=false"
require_file_contains "$SOURCE" "orderFormVisible=false"
require_file_contains "$SOURCE" "productionTradingEnabledByDefault=false"
require_file_contains "$SOURCE" "productionEndpointConnected=false"
require_file_contains "$SHELL_SOURCE" "releaseV0160DashboardArtifactBackedExecutionView"
require_file_contains "$SHELL_SOURCE" "releaseV0160DashboardArtifactBackedExecutionView(fromLocalReadModelJSON"
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV0160ArtifactBackedExecutionPanel"
require_file_contains "$APP_TESTS" "testGH1108DashboardArtifactBackedExecutionViewShowsLocalArtifactsWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1108DashboardArtifactBackedExecutionViewIsAnchoredInV0160Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh"

swift test --filter AppTests/testGH1108DashboardArtifactBackedExecutionViewShowsLocalArtifactsWithoutCommands
swift test --filter TargetGraphTests/testGH1108DashboardArtifactBackedExecutionViewIsAnchoredInV0160Guards

echo "MTPRO release v0.16.0 Dashboard artifact-backed execution view verification passed."
