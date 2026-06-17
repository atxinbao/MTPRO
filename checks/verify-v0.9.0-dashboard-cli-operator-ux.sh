#!/usr/bin/env bash
set -euo pipefail

# GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX
# TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 Dashboard / CLI operator UX verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 Dashboard / CLI operator UX verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

require_output_contains() {
  local output="$1"
  local expected="$2"

  if [[ "$output" != *"$expected"* ]]; then
    printf 'release v0.9.0 Dashboard / CLI operator UX verification failed: CLI output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if [[ "$output" == *"$forbidden"* ]]; then
    printf 'release v0.9.0 Dashboard / CLI operator UX verification failed: CLI output must not contain: %s\n' "$forbidden" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV090DashboardOperatorUXSurface.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
CLI_VERIFIER="checks/verify-v0.5.0-cli.sh"

swift test --filter AppTests/testGH855DashboardOperatorUXShowsMonitorOperationsWithoutCommands
swift test --filter TargetGraphTests/testGH855DashboardCLIOperatorUXIsAnchoredInV090Guards

# CLI smoke command anchors:
# swift run mtpro monitor start
# swift run mtpro monitor status
# swift run mtpro monitor stop
# swift run mtpro monitor recover
# swift run mtpro monitor export
for action in start status stop recover export; do
  output="$(swift run mtpro monitor "$action" gh-855-monitor-ux)"
  require_output_contains "$output" "mtpro monitor $action v0.9.0"
  require_output_contains "$output" "issue=GH-855"
  require_output_contains "$output" "validationAnchor=TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX"
  require_output_contains "$output" "verificationAnchor=GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX"
  require_output_contains "$output" "operatorUXContract=v0.9.0"
  require_output_contains "$output" "monitorAction=$action"
  require_output_contains "$output" "runID=gh-855-monitor-ux"
  require_output_contains "$output" "dashboardMonitorSurfaces=monitor-state,timelines,alerts,export-status,safe-local-controls"
  require_output_contains "$output" "monitorSessionPath=.local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_session.json"
  require_output_contains "$output" "exportBundlePath=.local/mtpro/runs/<runID>/testnet-readonly-monitor/run-monitor-export-bundle.json"
  require_output_contains "$output" "credentialValueVisible=false"
  require_output_contains "$output" "rawListenKeyVisible=false"
  require_output_contains "$output" "rawPrivatePayloadVisible=false"
  require_output_contains "$output" "tradingButtonVisible=false"
  require_output_contains "$output" "orderFormVisible=false"
  require_output_contains "$output" "liveCommandVisible=false"
  require_output_contains "$output" "brokerCommandCreated=false"
  require_output_contains "$output" "testnetOrderRoutingAllowed=false"
  require_output_contains "$output" "testnetOrderSubmissionAllowed=false"
  require_output_contains "$output" "productionTradingEnabledByDefault=false"
  require_output_contains "$output" "productionSecretRead=false"
  require_output_contains "$output" "productionEndpointConnected=false"
  require_output_contains "$output" "brokerEndpointConnected=false"
  require_output_contains "$output" "productionOrderSubmitted=false"
  require_output_contains "$output" "productionCutoverAuthorized=false"
  require_output_contains "$output" "boundaryHeld=true"
  reject_output_contains "$output" "testnetOrderRoutingAllowed=true"
  reject_output_contains "$output" "testnetOrderSubmissionAllowed=true"
  reject_output_contains "$output" "productionTradingEnabledByDefault=true"
  reject_output_contains "$output" "productionCutoverAuthorized=true"
done

require_file_contains "$SOURCE" "ReleaseV090DashboardOperatorUXSurfaceViewModel"
require_file_contains "$SOURCE" "ReleaseV090DashboardOperatorUXControlRow"
require_file_contains "$SOURCE" "ReleaseV090OperatorUXControl"
require_file_contains "$SOURCE" "monitor-state"
require_file_contains "$SOURCE" "timelines"
require_file_contains "$SOURCE" "alerts"
require_file_contains "$SOURCE" "export-status"
require_file_contains "$SOURCE" "safe-local-controls"
require_file_contains "$SOURCE" "mtpro monitor \\(control.rawValue)"
require_file_contains "$CLI_SOURCE" "monitorSupportedActionCommands"
require_file_contains "$CLI_SOURCE" "mtpro monitor \\(action) v0.9.0"
require_file_contains "$CLI_SOURCE" "monitorActions=\\(monitorSupportedActionCommands.joined(separator: \",\"))"
require_file_contains "$CLI_VERIFIER" "risk-policy,monitor,verify"
require_file_contains "$SHELL_SOURCE" "releaseV090OperatorUXSurface"
require_file_contains "$SHELL_SOURCE" "releaseV090OperatorUXControls"
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV090OperatorUXPanel"
require_file_contains "$APP_TESTS" "testGH855DashboardOperatorUXShowsMonitorOperationsWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH855DashboardCLIOperatorUXIsAnchoredInV090Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 Dashboard / CLI operator UX anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX"
require_file_contains "$VALIDATION_PLAN" "GH-855 Release v0.9.0 Dashboard / CLI Operator UX Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX"
require_file_contains "$CONTRACT" "V090-013-DASHBOARD-CLI-OPERATOR-UX"

for anchor in \
  "GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX" \
  "TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX" \
  "V090-013-DASHBOARD-CLI-OPERATOR-UX" \
  "V090-013-MONITOR-START-STATUS-STOP-RECOVER-EXPORT" \
  "V090-013-DASHBOARD-READ-STATE-TIMELINES-ALERTS-EXPORT" \
  "V090-013-SAFE-LOCAL-READONLY-CONTROLS" \
  "V090-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V090-013-NO-TESTNET-ORDER-ROUTING" \
  "V090-013-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

for file in "$SOURCE" "$CLI_SOURCE"; do
  reject_file_contains "$file" "URLSession"
  reject_file_contains "$file" "URLRequest"
  reject_file_contains "$file" "api.binance.com"
  reject_file_contains "$file" "fapi.binance.com"
  reject_file_contains "$file" "submitOrder"
  reject_file_contains "$file" "cancelOrder"
  reject_file_contains "$file" "replaceOrder"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "testnetOrderRoutingAllowed=true"
  reject_file_contains "$file" "testnetOrderSubmissionAllowed=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

echo "MTPRO release v0.9.0 Dashboard / CLI operator UX verification passed."
