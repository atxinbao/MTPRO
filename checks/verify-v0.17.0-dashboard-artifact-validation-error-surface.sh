#!/usr/bin/env bash
set -euo pipefail

# GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE
# TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE
# V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE
# V0170-006-FAILURE-REASONS-VISIBLE
# V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE
# V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS
# V0170-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 dashboard artifact validation error surface guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 dashboard artifact validation error surface guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV0170DashboardArtifactValidationErrorSurface.swift"
SHELL="Sources/Dashboard/DashboardShell.swift"
CONTRACT="docs/contracts/release-v0.17.0-dashboard-artifact-validation-error-surface-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter AppTests/testGH1144DashboardArtifactValidationErrorSurfaceShowsFailuresWithoutCommands
swift test --filter TargetGraphTests/testGH1144DashboardArtifactValidationErrorSurfaceIsAnchoredInV0170Guards

for file in "$SOURCE" "$SHELL" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$APP_TESTS" "$TARGET_TESTS"; do
  for anchor in \
    "GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE" \
    "TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE" \
    "V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE" \
    "V0170-006-FAILURE-REASONS-VISIBLE" \
    "V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE" \
    "V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS" \
    "V0170-006-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "dashboardArtifactValidationErrorSurface=ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel" \
  "artifactValidationStatusVisible=true" \
  "failureReasonsVisible=true" \
  "recoveryCaseSummaryVisible=true" \
  "dashboardCommandSurfaceEnabled=false" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "productionTradingEnabledByDefault=false" \
  "productionCutoverAuthorized=false" \
  "ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel" \
  "ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$SHELL" "releaseV0170DashboardArtifactValidationErrorSurface"
require_file_contains "$SHELL" "DashboardReleaseV0170ArtifactValidationErrorPanel"
require_file_contains "$CONTRACT" "#1144 / GH-1144"
require_file_contains "$CONTRACT" "Dashboard artifact validation error surface"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-dashboard-artifact-validation-error-surface.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-dashboard-artifact-validation-error-surface.sh"
require_file_contains "$APP_TESTS" "testGH1144DashboardArtifactValidationErrorSurfaceShowsFailuresWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1144DashboardArtifactValidationErrorSurfaceIsAnchoredInV0170Guards"
require_file_contains "$READINESS" "Release v0.17.0 Dashboard artifact validation error surface anchor"
require_file_contains "$LATEST" "v0.17.0 Dashboard artifact validation error surface"
require_file_contains "$PLAN" "GH-1144 Release v0.17.0 Dashboard Artifact Validation Error Surface"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE"

for file in "$SOURCE" "$SHELL" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 dashboard artifact validation error surface verification passed.\n'
