#!/usr/bin/env bash
set -euo pipefail

# GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
# TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
# V0210-011-DASHBOARD-CLI-CANARY-STATUS
# V0210-011-CANARY-STATE-GATES
# V0210-011-RISK-ORDER-CANCEL-RECONCILIATION
# V0210-011-READ-ONLY-NO-COMMANDS
# V0210-011-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 Dashboard / CLI canary status surface failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 Dashboard / CLI canary status surface failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210CanaryStatusReadOnlySurface.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0210DashboardCLICanaryStatusSurface.swift"
DASHBOARD_SHELL="Sources/Dashboard/DashboardShell.swift"
CLI="Sources/MTPROCLI/main.swift"
PACKAGE="Package.swift"
CONTRACT="docs/contracts/release-v0.21.0-dashboard-cli-canary-status-surface.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH1283DashboardCLIReadOnlyCanaryStatusSurfaceShowsCanaryEvidenceWithoutCommands
swift test --filter TargetGraphTests/testGH1283ReleaseV0210DashboardCLIReadOnlyCanaryStatusSurface

STATUS_OUTPUT="$(swift run mtpro canary-status status)"
EVENTS_OUTPUT="$(swift run mtpro canary-status events)"
RECON_OUTPUT="$(swift run mtpro canary-status reconciliation)"

for expected in \
  "mtpro canary-status status" \
  "issue=GH-1283" \
  "surfaceRows=7" \
  "row=canary-state" \
  "row=reconciliation" \
  "dashboardReadOnly=true" \
  "cliReadOnly=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "submitCancelReplaceEnabled=false" \
  "productionEndpointConnected=false" \
  "rawOrderIDVisible=false" \
  "rawBrokerPayloadVisible=false" \
  "realOrderSent=false" \
  "boundaryHeld=true"; do
  if [[ "$STATUS_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.21.0 Dashboard / CLI canary status surface failed: status output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for expected in \
  "mtpro canary-status events" \
  "eventRows=7" \
  "kind=submit request" \
  "kind=reconciliation" \
  "redactedEvidenceOnly=true" \
  "rawOrderIDVisible=false" \
  "rawBrokerPayloadVisible=false" \
  "boundaryHeld=true"; do
  if [[ "$EVENTS_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.21.0 Dashboard / CLI canary status surface failed: events output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for expected in \
  "mtpro canary-status reconciliation" \
  "matchedOutcome=matched" \
  "canaryLifecycleReconstructable=true" \
  "reconciliationEvidenceRecorded=true" \
  "productionCutoverAuthorized=false" \
  "boundaryHeld=true"; do
  if [[ "$RECON_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.21.0 Dashboard / CLI canary status surface failed: reconciliation output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for file in \
  "$PACKAGE" \
  "$SOURCE" \
  "$DASHBOARD" \
  "$DASHBOARD_SHELL" \
  "$CLI" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$APP_TESTS" \
  "$TARGET_TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE"
  require_file_contains "$file" "TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE"
  require_file_contains "$file" "V0210-011-DASHBOARD-CLI-CANARY-STATUS"
  require_file_contains "$file" "V0210-011-CANARY-STATE-GATES"
  require_file_contains "$file" "V0210-011-RISK-ORDER-CANCEL-RECONCILIATION"
  require_file_contains "$file" "V0210-011-READ-ONLY-NO-COMMANDS"
  require_file_contains "$file" "V0210-011-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0210CanaryStatusReadOnlySurface"
require_file_contains "$SOURCE" "requiredUpstreamReconciliationEvidenceID"
require_file_contains "$SOURCE" "defaultEventRows"
require_file_contains "$SOURCE" "defaultReconciliationSnapshot"
require_file_contains "$SOURCE" "cliCommand = \"canary-status\""
require_file_contains "$SOURCE" "rawOrderIDVisible == false"
require_file_contains "$SOURCE" "rawBrokerPayloadVisible == false"
require_file_contains "$DASHBOARD" "Dashboard command surface: none"
require_file_contains "$DASHBOARD" "CLI command surface: read-only status / events / reconciliation only"
require_file_contains "$DASHBOARD_SHELL" "releaseV0210DashboardCLICanaryStatusSurface"
require_file_contains "$DASHBOARD_SHELL" "DashboardReleaseV0210CanaryStatusPanel"
require_file_contains "$CLI" "ReleaseV0210CanaryStatusReadOnlySurface.cliCommand"
require_file_contains "$CLI" "ReleaseV0210CanaryStatusReadOnlySurface.commandLineOutput"
require_file_contains "$PACKAGE" "\"ExecutionEngine\""
require_file_contains "$READINESS" "Release v0.21.0 Dashboard / CLI canary status surface anchor"
require_file_contains "$PLAN" "GH-1283 Release v0.21.0 Dashboard / CLI Canary Status Surface"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE"
require_file_contains "$LATEST" "v0.21.0 Dashboard / CLI canary status surface"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-dashboard-cli-canary-status-surface.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-dashboard-cli-canary-status-surface.sh"
require_file_contains "$APP_TESTS" "testGH1283DashboardCLIReadOnlyCanaryStatusSurfaceShowsCanaryEvidenceWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1283ReleaseV0210DashboardCLIReadOnlyCanaryStatusSurface"

for file in "$SOURCE" "$DASHBOARD" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "signedOrderMaterialGenerated=true"
  reject_file_contains "$file" "accountEndpointConnected=true"
  reject_file_contains "$file" "orderEndpointTouched=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "dashboardTradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "rawOrderIDVisible=true"
  reject_file_contains "$file" "rawBrokerPayloadVisible=true"
  reject_file_contains "$file" "realOrderSent=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 Dashboard / CLI canary status surface verification passed."
