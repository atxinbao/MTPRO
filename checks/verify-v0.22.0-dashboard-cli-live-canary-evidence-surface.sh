#!/usr/bin/env bash
set -euo pipefail

# GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
# TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
# V0220-010-BLOCKED-BY-GH1317
# V0220-010-LIVE-CANARY-EVIDENCE-CHAIN
# V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION
# V0220-010-FAILURE-CLASS-NEXT-ACTION
# V0220-010-READ-ONLY-DASHBOARD-CLI
# V0220-010-REDACTION-FAILURE-STATES-VISIBLE
# V0220-010-NO-TRADING-COMMANDS
# V0220-010-NO-FUTURES-OKX
# V0220-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0220DashboardCLILiveCanaryEvidenceSurface.swift"
DASHBOARD_SHELL="Sources/Dashboard/DashboardShell.swift"
CLI="Sources/MTPROCLI/main.swift"
PACKAGE="Package.swift"
CONTRACT="docs/contracts/release-v0.22.0-dashboard-cli-live-canary-evidence-surface.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
VERIFICATION="verification.md"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH1318DashboardCLILiveCanaryEvidenceSurfaceShowsCanaryEvidenceWithoutCommands
swift test --filter TargetGraphTests/testGH1318ReleaseV0220DashboardCLILiveCanaryEvidenceSurface

STATUS_OUTPUT="$(swift run mtpro canary-live-evidence status)"
FAILURES_OUTPUT="$(swift run mtpro canary-live-evidence failures)"
ROLLBACK_OUTPUT="$(swift run mtpro canary-live-evidence rollback)"
RECON_OUTPUT="$(swift run mtpro canary-live-evidence reconciliation)"

for expected in \
  "mtpro canary-live-evidence status" \
  "issue=GH-1318" \
  "surfaceRows=9" \
  "approvalVisible=true" \
  "preflightVisible=true" \
  "submitVisible=true" \
  "statusCancelVisible=true" \
  "omsVisible=true" \
  "reconciliationVisible=true" \
  "failureStatesVisible=true" \
  "nextActionsVisible=true" \
  "dashboardReadOnly=true" \
  "cliReadOnly=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "submitCancelReplaceEnabled=false" \
  "futuresEnabled=false" \
  "okxEnabled=false" \
  "rawOrderIDVisible=false" \
  "rawBrokerPayloadVisible=false" \
  "productionCutoverAuthorized=false" \
  "boundaryHeld=true"; do
  if [[ "$STATUS_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: status output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for expected in \
  "mtpro canary-live-evidence failures" \
  "failureClass=auth" \
  "failureClass=artifact" \
  "failClosed=true" \
  "blocksSubmit=true" \
  "blocksCancel=true" \
  "requiresOperatorAction=true" \
  "redactedEvidenceRequired=true" \
  "boundaryHeld=true"; do
  if [[ "$FAILURES_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: failures output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for expected in \
  "mtpro canary-live-evidence rollback" \
  "rollbackCommands=submit,cancel" \
  "killSwitchActive=true" \
  "noTradeActive=true" \
  "blockedBeforeTransport=true" \
  "blockedBeforeBrokerGateway=true" \
  "unintendedSubmitSent=false" \
  "unintendedCancelSent=false" \
  "boundaryHeld=true"; do
  if [[ "$ROLLBACK_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: rollback output missing %s\n' "$expected" >&2
    exit 1
  fi
done

for expected in \
  "mtpro canary-live-evidence reconciliation" \
  "reconciliationEvidenceVisible=true" \
  "upstreamEvidenceHeld=true" \
  "matchedExchangeOrderID=" \
  "matchedOMSReference=" \
  "reconciliationArtifactReference=" \
  "boundaryHeld=true"; do
  if [[ "$RECON_OUTPUT" != *"$expected"* ]]; then
    printf 'release v0.22.0 Dashboard / CLI live canary evidence surface failed: reconciliation output missing %s\n' "$expected" >&2
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
  require_file_contains "$file" "GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE"
  require_file_contains "$file" "TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE"
  require_file_contains "$file" "V0220-010-BLOCKED-BY-GH1317"
  require_file_contains "$file" "V0220-010-LIVE-CANARY-EVIDENCE-CHAIN"
  require_file_contains "$file" "V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION"
  require_file_contains "$file" "V0220-010-FAILURE-CLASS-NEXT-ACTION"
  require_file_contains "$file" "V0220-010-READ-ONLY-DASHBOARD-CLI"
  require_file_contains "$file" "V0220-010-REDACTION-FAILURE-STATES-VISIBLE"
  require_file_contains "$file" "V0220-010-NO-TRADING-COMMANDS"
  require_file_contains "$file" "V0220-010-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-010-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface"
require_file_contains "$SOURCE" "cliCommand = \"canary-live-evidence\""
require_file_contains "$SOURCE" "requiredFailureClassOutputLines"
require_file_contains "$SOURCE" "deterministicRows"
require_file_contains "$DASHBOARD" "CLI command surface: read-only status / failures / rollback / reconciliation only"
require_file_contains "$DASHBOARD_SHELL" "releaseV0220DashboardCLILiveCanaryEvidenceSurface"
require_file_contains "$DASHBOARD_SHELL" "DashboardReleaseV0220LiveCanaryEvidencePanel"
require_file_contains "$CLI" "ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.cliCommand"
require_file_contains "$CLI" "ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.commandLineOutput"
require_file_contains "$PACKAGE" "\"ExecutionEngine\""
require_file_contains "$READINESS" "Release v0.22.0 Dashboard / CLI live canary evidence surface anchor"
require_file_contains "$PLAN" "GH-1318 Release v0.22.0 Dashboard / CLI Live Canary Evidence Surface"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE"
require_file_contains "$LATEST" "v0.22.0 Dashboard / CLI live canary evidence surface"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh"
require_file_contains "$APP_TESTS" "testGH1318DashboardCLILiveCanaryEvidenceSurfaceShowsCanaryEvidenceWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1318ReleaseV0220DashboardCLILiveCanaryEvidenceSurface"

for file in "$SOURCE" "$DASHBOARD" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "futuresEnabled=true"
  reject_file_contains "$file" "okxEnabled=true"
  reject_file_contains "$file" "dashboardTradingCommandEnabled=true"
  reject_file_contains "$file" "tradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "rawOrderIDVisible=true"
  reject_file_contains "$file" "rawBrokerPayloadVisible=true"
  reject_file_contains "$file" "rawBrokerPayloadPersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.22.0 Dashboard / CLI live canary evidence surface verification passed."
