#!/usr/bin/env bash
set -euo pipefail

# GH-964-VERIFY-V0120-DASHBOARD-ASSESSMENT-HISTORY
# TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY
# V0120-013-DASHBOARD-ASSESSMENT-HISTORY
# V0120-013-ASSESSMENT-LIST-DETAIL-GENERATION-HISTORY
# V0120-013-PROVENANCE-VALIDATION-APPROVAL-COMPARISON
# V0120-013-ADVERSARIAL-CI-GUARD
# V0120-013-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.12.0 Dashboard assessment history guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.12.0 Dashboard assessment history guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

require_any_file_contains() {
  local expected="$1"
  shift

  local file
  for file in "$@"; do
    if grep -Fq "$expected" "$file"; then
      return 0
    fi
  done

  printf 'release v0.12.0 Dashboard assessment history guard failed: expected string missing from all checked files: %s\n' "$expected" >&2
  exit 1
}

WORKFLOW=".github/workflows/checks.yml"
DASHBOARD_SOURCE="Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift"
DASHBOARD_SHELL="Sources/Dashboard/DashboardShell.swift"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
VERIFIER="checks/verify-v0.12.0.sh"

require_file_contains "$WORKFLOW" "Verify v0.12.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.12.0-dashboard-macos-guards.sh"
require_file_contains "$WORKFLOW" "Build Dashboard"
require_file_contains "$WORKFLOW" "Run Dashboard smoke"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
v0110_guard = workflow.index("Verify v0.11.0 Dashboard macOS focused guards")
v0120_guard = workflow.index("Verify v0.12.0 Dashboard macOS focused guards")
build = workflow.index("Build Dashboard")
smoke = workflow.index("Run Dashboard smoke")
if not (v0110_guard < v0120_guard < build < smoke):
    raise SystemExit("v0.12 Dashboard focused guard must run after v0.11 guard and before Dashboard build and smoke")
PY

bash checks/verify-v0.12.0.sh
swift test --filter AppTests/testGH964DashboardAssessmentHistoryShowsLocalEvidenceAndAdversarialCoverageWithoutCommands
swift test --filter TargetGraphTests/testGH964DashboardAssessmentHistoryAndAdversarialCIGuardsAreAnchored

if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  SMOKE_OUTPUT="$(DASHBOARD_SMOKE=1 swift run Dashboard)"
  printf '%s\n' "$SMOKE_OUTPUT"

  for expected in \
    "releaseV0120AssessmentHistoryRows=7" \
    "releaseV0120AssessmentHistoryGenerations=3" \
    "releaseV0120AssessmentHistoryAdversarialCases=7" \
    "releaseV0120AssessmentHistoryBoundary=confirmed"; do
    if ! grep -Fq "$expected" <<< "$SMOKE_OUTPUT"; then
      printf 'release v0.12.0 Dashboard assessment history guard failed: smoke output must contain: %s\n' "$expected" >&2
      exit 1
    fi
  done
else
  echo "Skipping Dashboard build and smoke inside v0.12 macOS guard: SwiftUI shell smoke is macOS-only."
fi

for anchor in \
  "GH-964-VERIFY-V0120-DASHBOARD-ASSESSMENT-HISTORY" \
  "TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY" \
  "V0120-013-DASHBOARD-ASSESSMENT-HISTORY" \
  "V0120-013-ASSESSMENT-LIST-DETAIL-GENERATION-HISTORY" \
  "V0120-013-PROVENANCE-VALIDATION-APPROVAL-COMPARISON" \
  "V0120-013-ADVERSARIAL-CI-GUARD" \
  "V0120-013-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$DASHBOARD_SOURCE" "$anchor"
  require_file_contains "$VERIFIER" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

for required in \
  "ReleaseV0120DashboardAssessmentHistorySurfaceViewModel" \
  "ReleaseV0120DashboardAssessmentHistorySurfaceKind" \
  "ReleaseV0120DashboardAssessmentHistoryRow" \
  "releaseV0120AssessmentHistorySurface" \
  "DashboardReleaseV0120AssessmentHistoryPanel" \
  "assessment-list" \
  "assessment-detail" \
  "generation-history" \
  "provenance" \
  "validation-status" \
  "approval-status" \
  "comparison" \
  "symlink-attack" \
  "concurrent-build" \
  "crash-recovery" \
  "checksum-toctou" \
  "file-permissions" \
  "tamper-after-validation" \
  "macos-dashboard-focused-guard" \
  "testGH964DashboardAssessmentHistoryShowsLocalEvidenceAndAdversarialCoverageWithoutCommands" \
  "testGH964DashboardAssessmentHistoryAndAdversarialCIGuardsAreAnchored"; do
  require_any_file_contains \
    "$required" \
    "$DASHBOARD_SOURCE" \
    "$DASHBOARD_SHELL" \
    "$APP_TESTS" \
    "$TARGET_TESTS" \
    "$0"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true" \
  "swift run mtpro submit" \
  "swift run mtpro cancel" \
  "swift run mtpro replace"; do
  reject_file_contains "$WORKFLOW" "$forbidden"
  reject_file_contains "$DASHBOARD_SOURCE" "$forbidden"
  reject_file_contains "$DASHBOARD_SHELL" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

echo "MTPRO release v0.12.0 Dashboard assessment history guard verification passed."
