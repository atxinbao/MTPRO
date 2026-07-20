#!/usr/bin/env bash
set -euo pipefail

# GH-890-VERIFY-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER
# TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER

fail() {
  echo "release v0.10.0 Dashboard production readiness center verification failed: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_file_contains() {
  local path="$1"
  local expected="$2"
  grep -Fq "$expected" "$path" || fail "$path must contain: $expected"
}

reject_file_contains() {
  local path="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$path" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    fail "$path must not contain: $forbidden"
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for path in "$SOURCE" "$SHELL_SOURCE" "$APP_TESTS" "$TARGET_TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST" "$AUTOMATION_SCRIPT"; do
  require_file "$path"
done

swift test --filter AppTests/testGH890DashboardProductionReadinessCenterShowsReadinessWithoutCommands
swift test --filter TargetGraphTests/testGH890DashboardProductionReadinessCenterIsAnchoredInV0100Guards

for anchor in \
  "GH-890-VERIFY-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER" \
  "TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER" \
  "V0100-013-DASHBOARD-PRODUCTION-READINESS-CENTER" \
  "V0100-013-READINESS-OVERVIEW" \
  "V0100-013-ENVIRONMENT-PROFILE" \
  "V0100-013-SECRET-READINESS" \
  "V0100-013-ENDPOINT-POLICY" \
  "V0100-013-RISK-CAPITAL-LIMITS" \
  "V0100-013-KILL-SWITCH-NO-TRADE" \
  "V0100-013-COMMAND-SURFACE-DISABLED" \
  "V0100-013-SHADOW-DRY-RUN-PARITY" \
  "V0100-013-APPROVAL-WORKFLOW" \
  "V0100-013-READINESS-BUNDLE" \
  "V0100-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V0100-013-NO-SUBMIT-CANCEL-REPLACE" \
  "V0100-013-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
done

for expected in \
  "ReleaseV0100DashboardProductionReadinessCenterViewModel" \
  "ReleaseV0100DashboardProductionReadinessCenterCard" \
  "ReleaseV0100DashboardProductionReadinessCenterPanel" \
  "readiness-overview" \
  "environment-profile" \
  "secret-readiness" \
  "endpoint-policy" \
  "risk-capital-limits" \
  "kill-switch-no-trade" \
  "command-surface-disabled" \
  "shadow-dry-run-parity" \
  "approval-workflow" \
  "readiness-bundle" \
  "production-readiness-bundle.json" \
  "incident_rollback_readiness.json"; do
  require_file_contains "$SOURCE" "$expected"
done

require_file_contains "$SHELL_SOURCE" "releaseV0100ProductionReadinessCenter"
require_file_contains "$SHELL_SOURCE" "releaseV0100ReadinessCenterCards="
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV0100ProductionReadinessCenterPanel"
require_file_contains "$APP_TESTS" "testGH890DashboardProductionReadinessCenterShowsReadinessWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH890DashboardProductionReadinessCenterIsAnchoredInV0100Guards"
require_file_contains "$READINESS" "Release v0.10.0 Dashboard production readiness center anchor"
require_file_contains "$PLAN" "GH-890 Release v0.10.0 Dashboard Production Readiness Center Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER"
require_file_contains "$LATEST" "\`#890\` 新增 Dashboard Production Readiness Center"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.10.0-dashboard-production-readiness-center.sh"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "submitOrder" \
  "cancelOrder" \
  "replaceOrder" \
  "productionCutoverAuthorized = true" \
  "productionTradingEnabledByDefault = true" \
  "productionSecretAutoReadEnabled = true" \
  "productionEndpointConnected = true" \
  "brokerEndpointConnected = true" \
  "testnetOrderSubmissionEnabled = true" \
  "productionOrderSubmitted = true" \
  "tradingButtonVisible = true" \
  "orderFormVisible = true" \
  "liveCommandVisible = true" \
  "productionCommandEnabled = true" \
  "submitCancelReplaceVisible = true" \
  "readinessApprovalConvertedToTradingPermission = true"; do
  reject_file_contains "$SOURCE" "$forbidden"
done

echo "MTPRO release v0.10.0 Dashboard production readiness center verification passed."
