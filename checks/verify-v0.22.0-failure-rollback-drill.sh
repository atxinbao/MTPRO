#!/usr/bin/env bash
set -euo pipefail

# GH-1317-VERIFY-V0220-FAILURE-ROLLBACK-DRILL
# TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL
# V0220-009-BLOCKED-BY-GH1315-GH1316
# V0220-009-FAILURE-CLASSIFICATION
# V0220-009-AUTH-ENDPOINT-RISK-KILL-NOTRADE-SUBMIT-CANCEL-STATUS-RECONCILIATION-ARTIFACT
# V0220-009-DETERMINISTIC-NEXT-ACTION
# V0220-009-KILL-SWITCH-BLOCKS-SUBMIT-CANCEL
# V0220-009-NO-TRADE-BLOCKS-SUBMIT-CANCEL
# V0220-009-ROLLBACK-DRILL-EVIDENCE
# V0220-009-NO-UNINTENDED-ORDERS
# V0220-009-NO-FUTURES-OKX
# V0220-009-NO-DASHBOARD-TRADING-CONTROLS
# V0220-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 failure rollback drill guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 failure rollback drill guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryFailureRollbackDrill.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-failure-rollback-drill.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1317ReleaseV0220FailureClassificationRollbackKillSwitchNoTradeDrill

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1317-VERIFY-V0220-FAILURE-ROLLBACK-DRILL"
  require_file_contains "$file" "TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL"
  require_file_contains "$file" "V0220-009-BLOCKED-BY-GH1315-GH1316"
  require_file_contains "$file" "V0220-009-FAILURE-CLASSIFICATION"
  require_file_contains "$file" "V0220-009-AUTH-ENDPOINT-RISK-KILL-NOTRADE-SUBMIT-CANCEL-STATUS-RECONCILIATION-ARTIFACT"
  require_file_contains "$file" "V0220-009-DETERMINISTIC-NEXT-ACTION"
  require_file_contains "$file" "V0220-009-KILL-SWITCH-BLOCKS-SUBMIT-CANCEL"
  require_file_contains "$file" "V0220-009-NO-TRADE-BLOCKS-SUBMIT-CANCEL"
  require_file_contains "$file" "V0220-009-ROLLBACK-DRILL-EVIDENCE"
  require_file_contains "$file" "V0220-009-NO-UNINTENDED-ORDERS"
  require_file_contains "$file" "V0220-009-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-009-NO-DASHBOARD-TRADING-CONTROLS"
  require_file_contains "$file" "V0220-009-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryFailureRollbackDrillEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryReconciliationEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryFailureClass"
require_file_contains "$CONTRACT_SOURCE" "killSwitchNoTradeEvidencePresent"
require_file_contains "$CONTRACT_SOURCE" "noUnintendedOrders"
require_file_contains "$CONTRACT_DOC" "failure classification"
require_file_contains "$CONTRACT_DOC" "rollback drill"
require_file_contains "$README" "v0.22.0 failure rollback drill"
require_file_contains "$READINESS" "Release v0.22.0 failure rollback drill anchor"
require_file_contains "$PLAN" "GH-1317 Release v0.22.0 Failure Rollback Drill"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL"
require_file_contains "$VERIFICATION" "GH-1317 v0.22.0 Failure Rollback Drill"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-failure-rollback-drill.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-failure-rollback-drill.sh"
require_file_contains "$TESTS" "testGH1317ReleaseV0220FailureClassificationRollbackKillSwitchNoTradeDrill"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "unintendedSubmitSent=true"
  reject_file_contains "$file" "unintendedCancelSent=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "futuresEnabled=true"
  reject_file_contains "$file" "okxEnabled=true"
  reject_file_contains "$file" "dashboardTradingCommandEnabled=true"
  reject_file_contains "$file" "rawBrokerPayloadPersisted=true"
done

echo "MTPRO release v0.22.0 failure rollback drill verification passed."
