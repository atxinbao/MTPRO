#!/usr/bin/env bash
set -euo pipefail

# GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT
# TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION
# V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION
# V0260-001-NO-PRODUCTION-CUTOVER
# GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE
# V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE
# V0260-002-CREDENTIAL-REFERENCE-ONLY
# GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION
# V0260-003-NO-PRODUCTION-CUTOVER
# V0260-003-ORDER-INTENT-VALIDATED
# GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE
# V0260-004-MANUAL-APPROVAL-HARD-CAPS
# V0260-004-IDEMPOTENCY-REDACTION
# GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK
# V0260-005-CANCEL-STATUS-ROLLBACK
# V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY
# GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION
# V0260-006-OMS-EVENT-LOG-RECONCILIATION
# V0260-006-APPEND-ONLY-EVIDENCE
# GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS
# V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD
# V0260-007-REDUCE-ONLY-HARD-CAP
# GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
# TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
# V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS
# V0260-008-NO-DASHBOARD-TRADING-CONTROLS
# GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION
# TVM-RELEASE-V0260-AGGREGATE-VALIDATION
# V0260-009-AGGREGATE-VALIDATION-SUITE
# GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS
# V0260-010-STAGE-CODE-AUDIT
# V0260-010-NO-PRODUCTION-CUTOVER
# V0260-010-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "missing required text in $file: $needle" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    echo "forbidden text present in $file: $needle" >&2
    exit 1
  fi
}

EVIDENCE="Sources/ExecutionClient/FutureGate/ReleaseV0260FuturesTestnetControlledExecutionFoundation.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0260DashboardCLIFuturesTestnetStatusSurface.swift"
CLI="Sources/MTPROCLI/main.swift"
AUDIT="docs/audit/mtpro-release-v0.26.0-binance-usdm-futures-testnet-controlled-execution-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.26.0-binance-usdm-futures-testnet-controlled-execution-foundation-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1394To1403ReleaseV0260FuturesTestnetControlledExecutionFoundation

STATUS_OUTPUT="$(swift run mtpro futures-testnet-controlled-execution status)"
GATES_OUTPUT="$(swift run mtpro futures-testnet-controlled-execution gates)"
EXECUTION_OUTPUT="$(swift run mtpro futures-testnet-controlled-execution execution)"
RECONCILIATION_OUTPUT="$(swift run mtpro futures-testnet-controlled-execution reconciliation)"
BOUNDARIES_OUTPUT="$(swift run mtpro futures-testnet-controlled-execution boundaries)"

for expected in \
  "testnetSubmitCancelReplaceEnabled=true" \
  "productionFuturesOrderExecutionEnabled=false"; do
  if [[ "$STATUS_OUTPUT" != *"$expected"* ]]; then
    echo "status output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "maxNotionalUSDT=25" \
  "riskGatePassed=true" \
  "maxLeverage=2"; do
  if [[ "$GATES_OUTPUT" != *"$expected"* ]]; then
    echo "gates output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "kind:submit-evidence-recorded" \
  "kind:cancel-evidence-recorded" \
  "statusRollbackEvidenceRecorded=true"; do
  if [[ "$EXECUTION_OUTPUT" != *"$expected"* ]]; then
    echo "execution output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "failureClass=reconciliation-mismatch;failClosed=true" \
  "reconciliationEvidenceRecorded=true"; do
  if [[ "$RECONCILIATION_OUTPUT" != *"$expected"* ]]; then
    echo "reconciliation output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "productionOrderSubmitted=false" \
  "okxActiveRuntimeEnabled=false" \
  "dashboardTradingControlsEnabled=false"; do
  if [[ "$BOUNDARIES_OUTPUT" != *"$expected"* ]]; then
    echo "boundaries output missing: $expected" >&2
    exit 1
  fi
done

ANCHORS=(
  "GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT"
  "TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION"
  "V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION"
  "V0260-001-NO-PRODUCTION-CUTOVER"
  "GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE"
  "V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE"
  "V0260-002-CREDENTIAL-REFERENCE-ONLY"
  "GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION"
  "V0260-003-NO-PRODUCTION-CUTOVER"
  "V0260-003-ORDER-INTENT-VALIDATED"
  "GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE"
  "V0260-004-MANUAL-APPROVAL-HARD-CAPS"
  "V0260-004-IDEMPOTENCY-REDACTION"
  "GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK"
  "V0260-005-CANCEL-STATUS-ROLLBACK"
  "V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY"
  "GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION"
  "V0260-006-OMS-EVENT-LOG-RECONCILIATION"
  "V0260-006-APPEND-ONLY-EVIDENCE"
  "GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS"
  "V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD"
  "V0260-007-REDUCE-ONLY-HARD-CAP"
  "GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE"
  "TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE"
  "V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS"
  "V0260-008-NO-DASHBOARD-TRADING-CONTROLS"
  "GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION"
  "TVM-RELEASE-V0260-AGGREGATE-VALIDATION"
  "V0260-009-AGGREGATE-VALIDATION-SUITE"
  "GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS"
  "V0260-010-STAGE-CODE-AUDIT"
  "V0260-010-NO-PRODUCTION-CUTOVER"
  "V0260-010-NO-TAG-OR-RELEASE-PUBLICATION"
)

for file in \
  "$EVIDENCE" \
  "$DASHBOARD" \
  "$CLI" \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$READINESS" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT"; do
  for anchor in "${ANCHORS[@]}"; do
    require_file_contains "$file" "$anchor"
  done
done

for file in "$EVIDENCE" "$DASHBOARD" "$AUDIT" "$NOTES" "$LATEST" "$VERIFICATION"; do
  require_file_contains "$file" "Binance USD-M Futures testnet controlled execution foundation"
  require_file_contains "$file" "productionFuturesOrderExecutionEnabled=false"
  require_file_contains "$file" "production cutover not authorized"
  for forbidden in \
    "productionFuturesOrderExecutionEnabled=true" \
    "productionTradingEnabledByDefault=true" \
    "productionCutoverAuthorized=true" \
    "okxActiveRuntimeEnabled=true" \
    "dashboardTradingControlsEnabled=true" \
    "tradingButtonVisible=true" \
    "orderFormVisible=true" \
    "liveCommandVisible=true" \
    "unrestrictedLiveTradingAuthorized=true" \
    "API Key:" \
    "Secret Key:"; do
    reject_file_contains "$file" "$forbidden"
  done
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.26.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.26.0.sh"

echo "v0.26.0 Futures testnet controlled execution foundation verification passed"
