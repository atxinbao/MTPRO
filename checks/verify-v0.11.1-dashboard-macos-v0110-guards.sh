#!/usr/bin/env bash
set -euo pipefail

# GH-946-VERIFY-V0111-DASHBOARD-MACOS-V0110-GUARDS
# TVM-RELEASE-V0111-DASHBOARD-MACOS-V0110-GUARDS
# V0111-002-DASHBOARD-MACOS-V0110-GUARDS
# V0111-002-READINESS-ARTIFACT-STATE-SURFACE
# V0111-002-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
# V0111-002-NO-PRODUCTION-CUTOVER
# GH-947-VERIFY-V0111-DASHBOARD-SHA256-STATE-INVARIANTS
# TVM-RELEASE-V0111-DASHBOARD-SHA256-STATE-INVARIANTS
# V0111-003-DASHBOARD-SHA256-STATE-INVARIANTS
# V0111-003-STRICT-SHA256-LOWERCASE-HEX
# V0111-003-VALID-STALE-INVALID-CHECKSUM-MAPPING
# V0111-003-MISSING-BLOCKED-CHECKSUM-MISMATCH-FAIL-CLOSED
# V0111-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.11.1 Dashboard macOS v0.11 guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.11.1 Dashboard macOS v0.11 guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"
DASHBOARD_SOURCE="Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift"
DASHBOARD_SHELL="Sources/Dashboard/DashboardShell.swift"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"

require_file_contains "$WORKFLOW" "Verify v0.11.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh"
require_file_contains "$WORKFLOW" "Build Dashboard"
require_file_contains "$WORKFLOW" "Run Dashboard smoke"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
v0100_guard = workflow.index("Verify v0.10.0 Dashboard macOS focused guards")
guard = workflow.index("Verify v0.11.0 Dashboard macOS focused guards")
build = workflow.index("Build Dashboard")
smoke = workflow.index("Run Dashboard smoke")
if not (v0100_guard < guard < build < smoke):
    raise SystemExit("v0.11 Dashboard focused guard must run after v0.10 guard and before Dashboard build and smoke")
PY

bash checks/verify-v0.11.0.sh
swift test --filter AppTests/testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly
swift test --filter AppTests/testGH947DashboardReadinessArtifactStateInvariantsRequireStrictSHA256AndExplicitStateMapping
swift test --filter TargetGraphTests/testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors

if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard build and smoke inside v0.11 macOS guard: SwiftUI shell smoke is macOS-only."
fi

for anchor in \
  "GH-946-VERIFY-V0111-DASHBOARD-MACOS-V0110-GUARDS" \
  "TVM-RELEASE-V0111-DASHBOARD-MACOS-V0110-GUARDS" \
  "V0111-002-DASHBOARD-MACOS-V0110-GUARDS" \
  "V0111-002-READINESS-ARTIFACT-STATE-SURFACE" \
  "V0111-002-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V0111-002-NO-PRODUCTION-CUTOVER" \
  "GH-947-VERIFY-V0111-DASHBOARD-SHA256-STATE-INVARIANTS" \
  "TVM-RELEASE-V0111-DASHBOARD-SHA256-STATE-INVARIANTS" \
  "V0111-003-DASHBOARD-SHA256-STATE-INVARIANTS" \
  "V0111-003-STRICT-SHA256-LOWERCASE-HEX" \
  "V0111-003-VALID-STALE-INVALID-CHECKSUM-MAPPING" \
  "V0111-003-MISSING-BLOCKED-CHECKSUM-MISMATCH-FAIL-CLOSED" \
  "V0111-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

require_file_contains "$DASHBOARD_SOURCE" "GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0110DashboardReadinessArtifactState"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0111DashboardReadinessArtifactInvariantAnchors"
require_file_contains "$DASHBOARD_SOURCE" "isValidSHA256Reference"
require_file_contains "$DASHBOARD_SOURCE" "checksumMatchesInputState"
require_file_contains "$DASHBOARD_SOURCE" "artifactStates(fromReadinessManifestJSON data: Data)"
require_file_contains "$DASHBOARD_SOURCE" "bundleState(fromBundleValidationJSON data: Data)"
require_file_contains "$DASHBOARD_SOURCE" "checksum-mismatch"
require_file_contains "$DASHBOARD_SHELL" "releaseV0100ProductionReadinessCenter.boundaryHeld"
require_file_contains "$APP_TESTS" "testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly"
require_file_contains "$APP_TESTS" "testGH947DashboardReadinessArtifactStateInvariantsRequireStrictSHA256AndExplicitStateMapping"
require_file_contains "$TARGET_TESTS" "testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors"
require_file_contains "$TARGET_TESTS" "testGH947DashboardSHA256AndReadinessStateInvariantsAreGuarded"

for forbidden in \
  "productionCutoverAuthorized=true" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "swift run mtpro submit" \
  "swift run mtpro cancel" \
  "swift run mtpro replace"; do
  reject_file_contains "$WORKFLOW" "$forbidden"
done

echo "MTPRO release v0.11.1 Dashboard macOS v0.11 focused guard verification passed."
