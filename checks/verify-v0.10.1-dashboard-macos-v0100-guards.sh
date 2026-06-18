#!/usr/bin/env bash
set -euo pipefail

# GH-908-VERIFY-V0101-DASHBOARD-MACOS-V0100-GUARDS
# TVM-RELEASE-V0101-DASHBOARD-MACOS-V0100-GUARDS
# V0101-003-DASHBOARD-MACOS-V0100-GUARDS
# V0101-003-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
# V0101-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.1 Dashboard macOS v0.10 guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.10.1 Dashboard macOS v0.10 guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
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

require_file_contains "$WORKFLOW" "Verify v0.10.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh"
require_file_contains "$WORKFLOW" "Build Dashboard"
require_file_contains "$WORKFLOW" "Run Dashboard smoke"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
guard = workflow.index("Verify v0.10.0 Dashboard macOS focused guards")
build = workflow.index("Build Dashboard")
smoke = workflow.index("Run Dashboard smoke")
if not (guard < build < smoke):
    raise SystemExit("v0.10 Dashboard focused guard must run before Dashboard build and smoke")
PY

bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh

if [[ "$(uname -s)" == "Darwin" ]]; then
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard smoke inside v0.10 macOS guard: SwiftUI shell smoke is macOS-only."
fi

for anchor in \
  "GH-908-VERIFY-V0101-DASHBOARD-MACOS-V0100-GUARDS" \
  "TVM-RELEASE-V0101-DASHBOARD-MACOS-V0100-GUARDS" \
  "V0101-003-DASHBOARD-MACOS-V0100-GUARDS" \
  "V0101-003-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V0101-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

require_file_contains "$DASHBOARD_SOURCE" "V0100-013-DASHBOARD-PRODUCTION-READINESS-CENTER"
require_file_contains "$DASHBOARD_SOURCE" "V0100-013-COMMAND-SURFACE-DISABLED"
require_file_contains "$DASHBOARD_SOURCE" "V0100-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND"
require_file_contains "$DASHBOARD_SOURCE" "V0100-013-NO-SUBMIT-CANCEL-REPLACE"
require_file_contains "$DASHBOARD_SOURCE" "V0100-013-NO-PRODUCTION-CUTOVER"
require_file_contains "$DASHBOARD_SHELL" "releaseV0100ProductionReadinessCenter"
require_file_contains "$DASHBOARD_SHELL" "releaseV0100ProductionReadinessCenter.boundaryHeld"

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

echo "MTPRO release v0.10.1 Dashboard macOS v0.10 focused guard verification passed."
