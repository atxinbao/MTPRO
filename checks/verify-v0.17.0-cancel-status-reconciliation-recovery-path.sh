#!/usr/bin/env bash
set -euo pipefail

# GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH
# TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH
# V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION
# V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY
# V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED
# V0170-005-STATUS-COMPENSATION-REQUIRED
# V0170-005-NO-AUTOMATIC-ORDER-RETRY
# V0170-005-REDACTED-RECOVERY-EVIDENCE
# V0170-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 cancel/status reconciliation recovery guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.17.0 cancel/status reconciliation recovery guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170CancelStatusReconciliationRecoveryPath.swift"
CONTRACT="docs/contracts/release-v0.17.0-cancel-status-reconciliation-recovery-path-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1143ReleaseV0170CancelStatusReconciliationRecoveryPath

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH" \
    "TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH" \
    "V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION" \
    "V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY" \
    "V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED" \
    "V0170-005-STATUS-COMPENSATION-REQUIRED" \
    "V0170-005-NO-AUTOMATIC-ORDER-RETRY" \
    "V0170-005-REDACTED-RECOVERY-EVIDENCE" \
    "V0170-005-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "cancelStatusReconciliationRecovery=ReleaseV0170CancelStatusReconciliationRecoveryPath" \
  "cancelStatusMismatchClassification=true" \
  "interruptedStatusEvidenceRecovery=true" \
  "resumeCursorContinuityRequired=true" \
  "statusCompensationRequired=true" \
  "noAutomaticOrderRetry=true" \
  "redactedRecoveryEvidenceOnly=true" \
  "ReleaseV0170CancelStatusReconciliationRecoveryCase" \
  "ReleaseV0170CancelStatusReconciliationRecoveryReport" \
  "ReleaseV0170CancelStatusReconciliationRecoveryPath" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$CONTRACT" "#1143 / GH-1143"
require_file_contains "$CONTRACT" "cancel/status reconciliation recovery"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-cancel-status-reconciliation-recovery-path.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-cancel-status-reconciliation-recovery-path.sh"
require_file_contains "$TESTS" "testGH1143ReleaseV0170CancelStatusReconciliationRecoveryPath"
require_file_contains "$READINESS" "Release v0.17.0 cancel/status reconciliation recovery path anchor"
require_file_contains "$LATEST" "v0.17.0 cancel/status reconciliation recovery path"
require_file_contains "$PLAN" "GH-1143 Release v0.17.0 Cancel Status Reconciliation Recovery Path"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 cancel/status reconciliation recovery verification passed.\n'
