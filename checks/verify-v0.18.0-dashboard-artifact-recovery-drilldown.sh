#!/usr/bin/env bash
set -euo pipefail

# GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN
# TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN
# V0180-007-DEPENDENCIES-GH1179-GH1180-GH1181-DONE
# V0180-007-REAL-LOCAL-BUNDLE-EVIDENCE
# V0180-007-LIFECYCLE-STATUS-RESUME-RECONCILIATION-DRILLDOWN
# V0180-007-VENUE-PRODUCT-ENVIRONMENT-DRILLDOWN
# V0180-007-FAILURE-CLASS-NEXT-ACTION-GUIDANCE
# V0180-007-DASHBOARD-READ-ONLY-NO-COMMANDS
# V0180-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 Dashboard artifact recovery drilldown guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    printf 'release v0.18.0 Dashboard artifact recovery drilldown guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift"
SHELL="Sources/Dashboard/DashboardShell.swift"
CONTRACT="docs/contracts/release-v0.18.0-dashboard-artifact-recovery-drilldown-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH1182DashboardArtifactRecoveryDrilldownShowsRealBundleEvidenceWithoutCommands
swift test --filter TargetGraphTests/testGH1182DashboardArtifactRecoveryDrilldownIsAnchoredInV0180Guards

for file in \
  "$SOURCE" \
  "$SHELL" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$APP_TESTS" \
  "$TARGET_TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN"
  require_file_contains "$file" "TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN"
  require_file_contains "$file" "V0180-007-DEPENDENCIES-GH1179-GH1180-GH1181-DONE"
  require_file_contains "$file" "V0180-007-REAL-LOCAL-BUNDLE-EVIDENCE"
  require_file_contains "$file" "V0180-007-LIFECYCLE-STATUS-RESUME-RECONCILIATION-DRILLDOWN"
  require_file_contains "$file" "V0180-007-VENUE-PRODUCT-ENVIRONMENT-DRILLDOWN"
  require_file_contains "$file" "V0180-007-FAILURE-CLASS-NEXT-ACTION-GUIDANCE"
  require_file_contains "$file" "V0180-007-DASHBOARD-READ-ONLY-NO-COMMANDS"
  require_file_contains "$file" "V0180-007-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT" "#1179 closed / done"
require_file_contains "$CONTRACT" "#1180 closed / done"
require_file_contains "$CONTRACT" "#1181 closed / done"
require_file_contains "$CONTRACT" "Dashboard artifact / recovery drilldown"
require_file_contains "$SOURCE" "dashboardArtifactRecoveryDrilldownSurface=ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel"
require_file_contains "$SOURCE" "localBundleEvidenceVisible=true"
require_file_contains "$SOURCE" "namespaceVisible=true"
require_file_contains "$SOURCE" "failureClassVisible=true"
require_file_contains "$SOURCE" "nextActionGuidanceVisible=true"
require_file_contains "$SOURCE" "dashboardDependsOnExecutionClientTarget=false"
require_file_contains "$SOURCE" "dashboardCommandSurfaceEnabled=false"
require_file_contains "$SOURCE" "tradingButtonVisible=false"
require_file_contains "$SOURCE" "orderFormVisible=false"
require_file_contains "$SHELL" "releaseV0180DashboardArtifactRecoveryDrilldownSurface"
require_file_contains "$SHELL" "DashboardReleaseV0180ArtifactRecoveryDrilldownPanel"
require_file_contains "$READINESS" "Release v0.18.0 Dashboard artifact recovery drilldown anchor"
require_file_contains "$PLAN" "GH-1182 Release v0.18.0 Dashboard Artifact Recovery Drilldown"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN"
require_file_contains "$POLICY" "GH-1182 adds Dashboard artifact / recovery drilldown"
require_file_contains "$APP_TESTS" "testGH1182DashboardArtifactRecoveryDrilldownShowsRealBundleEvidenceWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1182DashboardArtifactRecoveryDrilldownIsAnchoredInV0180Guards"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-dashboard-artifact-recovery-drilldown.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-dashboard-artifact-recovery-drilldown.sh"

BINANCE_PRODUCTION_ENDPOINT="api."
OKX_PRODUCTION_ENDPOINT="www."
for file in "$SOURCE" "$CONTRACT"; do
  reject_file_contains "$file" "${BINANCE_PRODUCTION_ENDPOINT}binance.com"
  reject_file_contains "$file" "${OKX_PRODUCTION_ENDPOINT}okx.com"
  reject_file_contains "$file" "URLSession"
  reject_file_contains "$file" "URLRequest"
  reject_file_contains "$file" "submitOrder"
  reject_file_contains "$file" "cancelOrder"
  reject_file_contains "$file" "replaceOrder"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
done

echo "MTPRO release v0.18.0 Dashboard artifact recovery drilldown verification passed."
