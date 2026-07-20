#!/usr/bin/env bash
set -euo pipefail

# GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT
# TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE
# V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS
# V0280-001-NOT-PRODUCTION-CUTOVER
# V0280-001-SPOT-USDM-FUTURES-ONLY
# V0280-001-OKX-NOT-ACTIVE
# GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY
# V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL
# V0280-002-NO-DEFAULT-SECRET-READ
# V0280-002-REDACTION-REQUIRED
# GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST
# V0280-003-ENDPOINT-ALLOWLIST
# V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION
# V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS
# GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION
# V0280-004-MANUAL-APPROVAL-REQUIRED
# V0280-004-OPERATOR-CONFIRMATION-REQUIRED
# V0280-004-NO-AUTO-CUTOVER
# GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE
# V0280-005-CAPITAL-RISK-GATE
# V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS
# V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED
# GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP
# V0280-006-KILL-SWITCH-REQUIRED
# V0280-006-NO-TRADE-STATE-REQUIRED
# V0280-006-ROLLBACK-INCIDENT-STOP-READY
# GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE
# V0280-007-DASHBOARD-CLI-READINESS
# V0280-007-NO-TRADING-BUTTON
# V0280-007-NO-ORDER-FORM
# V0280-007-NO-LIVE-COMMAND
# GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
# V0280-008-AGGREGATE-VALIDATION
# V0280-008-STAGE-AUDIT-RELEASE-DOCS
# V0280-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.28.0 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.28.0 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0280ProductionCutoverReadinessGate.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0280DashboardCLIProductionReadinessSurface.swift"
CLI="Sources/MTPROCLI/main.swift"
AUDIT="docs/audit/mtpro-release-v0.28.0-binance-production-cutover-readiness-gate-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.28.0-binance-production-cutover-readiness-gate-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1429To1436ReleaseV0280ProductionCutoverReadinessGate

for file in \
  "$SOURCE" \
  "$DASHBOARD" \
  "$CLI" \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$ROADMAP" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE"
  require_file_contains "$file" "V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS"
  require_file_contains "$file" "V0280-001-NOT-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0280-001-SPOT-USDM-FUTURES-ONLY"
  require_file_contains "$file" "V0280-001-OKX-NOT-ACTIVE"
  require_file_contains "$file" "GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY"
  require_file_contains "$file" "V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL"
  require_file_contains "$file" "V0280-002-NO-DEFAULT-SECRET-READ"
  require_file_contains "$file" "V0280-002-REDACTION-REQUIRED"
  require_file_contains "$file" "GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST"
  require_file_contains "$file" "V0280-003-ENDPOINT-ALLOWLIST"
  require_file_contains "$file" "V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION"
  require_file_contains "$file" "V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS"
  require_file_contains "$file" "GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION"
  require_file_contains "$file" "V0280-004-MANUAL-APPROVAL-REQUIRED"
  require_file_contains "$file" "V0280-004-OPERATOR-CONFIRMATION-REQUIRED"
  require_file_contains "$file" "V0280-004-NO-AUTO-CUTOVER"
  require_file_contains "$file" "GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE"
  require_file_contains "$file" "V0280-005-CAPITAL-RISK-GATE"
  require_file_contains "$file" "V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS"
  require_file_contains "$file" "V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED"
  require_file_contains "$file" "GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP"
  require_file_contains "$file" "V0280-006-KILL-SWITCH-REQUIRED"
  require_file_contains "$file" "V0280-006-NO-TRADE-STATE-REQUIRED"
  require_file_contains "$file" "V0280-006-ROLLBACK-INCIDENT-STOP-READY"
  require_file_contains "$file" "GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE"
  require_file_contains "$file" "V0280-007-DASHBOARD-CLI-READINESS"
  require_file_contains "$file" "V0280-007-NO-TRADING-BUTTON"
  require_file_contains "$file" "V0280-007-NO-ORDER-FORM"
  require_file_contains "$file" "V0280-007-NO-LIVE-COMMAND"
  require_file_contains "$file" "GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT"
  require_file_contains "$file" "V0280-008-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0280-008-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0280-008-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CLI" "ReleaseV0280ProductionCutoverReadinessGate.cliCommand"
require_file_contains "$CLI" "ReleaseV0280ProductionCutoverReadinessGate.commandLineOutput"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.28.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.28.0.sh"

for file in "$SOURCE" "$DASHBOARD" "$CLI" "$AUDIT" "$NOTES" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$ROADMAP" "$README" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretReadEnabledByDefault=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabledByDefault=true"
  reject_file_contains "$file" "brokerEndpointConnectionEnabledByDefault=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
  reject_file_contains "$file" "futuresProductionOrderExecutionEnabled=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "orderFormEnabled=true"
  reject_file_contains "$file" "liveCommandEnabled=true"
done

printf 'MTPRO v0.28.0 Binance production cutover readiness gate checks passed.\n'
