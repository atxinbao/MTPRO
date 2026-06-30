#!/usr/bin/env bash
set -euo pipefail

# GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
# TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
# V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
# V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER
# V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES
# V0200-010-DASHBOARD-CLI-NO-CONTROLS
# V0200-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 Dashboard / CLI read-only live readiness surface failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

require_text_contains() {
  local text="$1"
  local expected="$2"
  grep -Fq "$expected" <<<"$text" || fail "CLI output must contain: $expected"
}

reject_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.20.0 Dashboard / CLI read-only live readiness surface failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SURFACE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ReadOnlyLiveReadinessSurface.swift"
DASHBOARD_SOURCE="Sources/Dashboard/Report/ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurface.swift"
DASHBOARD_SHELL="Sources/Dashboard/DashboardShell.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_GRAPH_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter AppTests/testGH1248DashboardReadOnlyLiveReadinessSurfaceShowsProductionShadowStateWithoutControls
swift test --filter TargetGraphTests/testGH1248ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurface

cli_output="$(swift run mtpro production-shadow-readiness status)"

for expected in \
  "mtpro production-shadow-readiness status" \
  "issue=GH-1248" \
  "validationAnchor=TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE" \
  "verificationAnchor=GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE" \
  "surfaceRows=8" \
  "states=ready,blocked,fail-closed" \
  "endpointClasses=no-endpoint-connection,public-read-only,signed-read-only-intent,not-applicable" \
  "credentialStates=identity-reference-only,not-applicable,redacted-reference-only,no-credential-required" \
  "noOrderStatuses=not-applicable,blocked" \
  "row=environment-profile" \
  "row=signed-account-readiness" \
  "row=risk-kill-switch-no-trade" \
  "dashboardReadOnly=true" \
  "cliReadOnly=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "submitCancelReplaceEnabled=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretValueRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionCutoverAuthorized=false" \
  "realOrderSent=false" \
  "boundaryHeld=true"; do
  require_text_contains "$cli_output" "$expected"
done

for file in "$SURFACE_SOURCE" "$DASHBOARD_SOURCE" "$DASHBOARD_SHELL" "$CLI_SOURCE" "$README" "$GOAL" \
  "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$RUN_SCRIPT" "$AUTOMATION_SCRIPT" \
  "$APP_TESTS" "$TARGET_GRAPH_TESTS"; do
  for anchor in \
    "GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE" \
    "TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE" \
    "V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE" \
    "V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER" \
    "V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES" \
    "V0200-010-DASHBOARD-CLI-NO-CONTROLS" \
    "V0200-010-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ReadOnlyLiveReadinessSurface" \
  "ReleaseV0200ReadOnlyLiveReadinessSurfaceRow" \
  "ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe.deterministicFixture" \
  "ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.deterministicFixture" \
  "ReleaseV0200ProductionShadowNoOrderCapabilityGuard.deterministicFixture" \
  "ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness.deterministicFixture" \
  "cliCommand = \"production-shadow-readiness\"" \
  "dashboardReadOnly=true" \
  "cliReadOnly=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false" \
  "submitCancelReplaceEnabled=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretValueRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionCutoverAuthorized=false" \
  "realOrderSent=false"; do
  require_contains "$SURFACE_SOURCE" "$required_string"
done

require_contains "$DASHBOARD_SOURCE" "Dashboard command surface: none"
require_contains "$DASHBOARD_SOURCE" "CLI command surface: read-only status only"
require_contains "$DASHBOARD_SOURCE" "Trading button: none"
require_contains "$DASHBOARD_SOURCE" "Order form: none"
require_contains "$DASHBOARD_SOURCE" "Live command: none"
require_contains "$DASHBOARD_SOURCE" "Production cutover: none"
require_contains "$DASHBOARD_SHELL" "releaseV0200DashboardCLIReadOnlyLiveReadinessSurface"
require_contains "$DASHBOARD_SHELL" "DashboardReleaseV0200ReadOnlyLiveReadinessPanel"
require_contains "$DASHBOARD_SHELL" "releaseV0200ReadinessRows"
require_contains "$CLI_SOURCE" "ReleaseV0200ReadOnlyLiveReadinessSurface.cliCommand"
require_contains "$CLI_SOURCE" "ReleaseV0200ReadOnlyLiveReadinessSurface.commandLineOutput"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-dashboard-cli-read-only-live-readiness-surface.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-dashboard-cli-read-only-live-readiness-surface.sh"
require_contains "$APP_TESTS" "testGH1248DashboardReadOnlyLiveReadinessSurfaceShowsProductionShadowStateWithoutControls"
require_contains "$TARGET_GRAPH_TESTS" "testGH1248ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurface"
require_contains "$READINESS" "Release v0.20.0 Dashboard / CLI read-only live readiness surface anchor"
require_contains "$LATEST" "v0.20.0 Dashboard / CLI read-only live readiness surface"
require_contains "$PLAN" "GH-1248 Release v0.20.0 Dashboard / CLI Read-only Live Readiness Surface"
require_contains "$MATRIX" "TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE"

for file in "$SURFACE_SOURCE" "$DASHBOARD_SOURCE" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "productionEndpointConnected=true"
  reject_contains "$file" "brokerEndpointConnected=true"
  reject_contains "$file" "signedOrderMaterialGenerated=true"
  reject_contains "$file" "accountEndpointConnected=true"
  reject_contains "$file" "orderEndpointTouched=true"
  reject_contains "$file" "submitCancelReplaceEnabled=true"
  reject_contains "$file" "dashboardTradingButtonVisible=true"
  reject_contains "$file" "orderFormVisible=true"
  reject_contains "$file" "liveCommandVisible=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "futuresRuntimeEnabled=true"
  reject_contains "$file" "okxActiveImplementationEnabled=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 Dashboard / CLI read-only live readiness surface verification passed.\n'
