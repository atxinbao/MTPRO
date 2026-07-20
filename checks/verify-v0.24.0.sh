#!/usr/bin/env bash
set -euo pipefail

# GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT
# TVM-RELEASE-V0240-DUAL-PRODUCT-CONTRACT
# V0240-001-SPOT-FUTURES-DUAL-PRODUCT-UNIFICATION
# V0240-001-BLOCKED-BY-V0231-COMPLETION
# GH-1359-VERIFY-V0240-PRODUCT-AWARE-OMS-EVIDENCE
# V0240-002-UNIFIED-OMS-EVENT-EVIDENCE
# V0240-002-NO-FUTURES-ORDER-EXECUTION
# GH-1360-VERIFY-V0240-UNIFIED-PORTFOLIO-PROJECTION
# V0240-003-SPOT-CANARY-FUTURES-READONLY-PORTFOLIO
# V0240-003-FUTURES-READONLY-NOT-TRADING-AUTHORIZATION
# GH-1361-VERIFY-V0240-UNIFIED-RISK-READINESS
# V0240-004-SPOT-FUTURES-RISK-READINESS
# V0240-004-READINESS-NOT-PRODUCTION-RISK-APPROVAL
# GH-1362-VERIFY-V0240-DUAL-PRODUCT-RECONCILIATION
# V0240-005-SPOT-FUTURES-RECONCILIATION-FOUNDATION
# V0240-005-NO-BROKER-RECONCILIATION-RUNTIME
# GH-1363-VERIFY-V0240-DUAL-PRODUCT-FAILURE-MATRIX
# V0240-006-DUAL-PRODUCT-FAILURE-CLASSIFICATION
# V0240-006-FAIL-CLOSED-EVIDENCE
# GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE
# TVM-RELEASE-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE
# V0240-007-DASHBOARD-CLI-DUAL-PRODUCT-READONLY
# V0240-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
# GH-1365-VERIFY-V0240-AGGREGATE-VALIDATION
# TVM-RELEASE-V0240-AGGREGATE-VALIDATION
# V0240-008-AGGREGATE-VALIDATION-SUITE
# V0240-008-STAGE-AUDIT-RELEASE-DOCS
# V0240-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.24.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.24.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.24.0-spot-futures-unified-readonly-foundation-contract.md"
AUDIT="docs/audit/mtpro-release-v0.24.0-spot-futures-unified-readonly-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.24.0-spot-futures-unified-readonly-foundation-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
CLI="Sources/MTPROCLI/main.swift"
EVIDENCE="Sources/ExecutionClient/FutureGate/ReleaseV0240SpotFuturesUnifiedReadOnlyFoundation.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0240DashboardCLIDualProductReadOnlyEvidenceSurface.swift"

swift test --filter TargetGraphTests/testGH1358To1365ReleaseV0240SpotFuturesUnifiedReadOnlyFoundation

STATUS_OUTPUT="$(swift run mtpro dual-product-readonly-readiness status)"
OMS_OUTPUT="$(swift run mtpro dual-product-readonly-readiness oms)"
PORTFOLIO_OUTPUT="$(swift run mtpro dual-product-readonly-readiness portfolio)"
RISK_OUTPUT="$(swift run mtpro dual-product-readonly-readiness risk)"
RECON_OUTPUT="$(swift run mtpro dual-product-readonly-readiness reconciliation)"
FAILURE_OUTPUT="$(swift run mtpro dual-product-readonly-readiness failures)"
DASHBOARD_OUTPUT="$(swift run mtpro dual-product-readonly-readiness dashboard)"

printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "productType:spot"
printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "productType:usdsPerpetual"
printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "futuresOrderExecutionEnabled=false"
printf '%s\n' "$OMS_OUTPUT" | grep -Fq "futuresOrderLifecycleCreated=false"
printf '%s\n' "$PORTFOLIO_OUTPUT" | grep -Fq "futuresReadOnlyNotTradingAuthorization=true"
printf '%s\n' "$RISK_OUTPUT" | grep -Fq "productionRiskApproval=false"
printf '%s\n' "$RECON_OUTPUT" | grep -Fq "brokerReconciliationRuntime=false"
printf '%s\n' "$FAILURE_OUTPUT" | grep -Fq "failureClass=production-cutover-attempted;failClosed=true"
printf '%s\n' "$DASHBOARD_OUTPUT" | grep -Fq "tradingButtonVisible=false"

for file in \
  "$CONTRACT" \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$CLI" \
  "$EVIDENCE" \
  "$DASHBOARD" \
  "$0"; do
  require_file_contains "$file" "GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0240-DUAL-PRODUCT-CONTRACT"
  require_file_contains "$file" "V0240-001-SPOT-FUTURES-DUAL-PRODUCT-UNIFICATION"
  require_file_contains "$file" "GH-1359-VERIFY-V0240-PRODUCT-AWARE-OMS-EVIDENCE"
  require_file_contains "$file" "V0240-002-UNIFIED-OMS-EVENT-EVIDENCE"
  require_file_contains "$file" "GH-1360-VERIFY-V0240-UNIFIED-PORTFOLIO-PROJECTION"
  require_file_contains "$file" "V0240-003-SPOT-CANARY-FUTURES-READONLY-PORTFOLIO"
  require_file_contains "$file" "GH-1361-VERIFY-V0240-UNIFIED-RISK-READINESS"
  require_file_contains "$file" "V0240-004-SPOT-FUTURES-RISK-READINESS"
  require_file_contains "$file" "GH-1362-VERIFY-V0240-DUAL-PRODUCT-RECONCILIATION"
  require_file_contains "$file" "V0240-005-SPOT-FUTURES-RECONCILIATION-FOUNDATION"
  require_file_contains "$file" "GH-1363-VERIFY-V0240-DUAL-PRODUCT-FAILURE-MATRIX"
  require_file_contains "$file" "V0240-006-DUAL-PRODUCT-FAILURE-CLASSIFICATION"
  require_file_contains "$file" "GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE"
  require_file_contains "$file" "V0240-007-DASHBOARD-CLI-DUAL-PRODUCT-READONLY"
  require_file_contains "$file" "GH-1365-VERIFY-V0240-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0240-008-AGGREGATE-VALIDATION-SUITE"
  require_file_contains "$file" "V0240-008-NO-PRODUCTION-CUTOVER"
done

for file in "$CONTRACT" "$AUDIT" "$NOTES" "$EVIDENCE" "$DASHBOARD"; do
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "orderFormEnabled=true"
  reject_file_contains "$file" "liveCommandEnabled=true"
  reject_file_contains "$file" "brokerReconciliationRuntimeEnabled=true"
done

printf 'MTPRO v0.24.0 Spot + Futures unified read-only foundation checks passed.\n'
