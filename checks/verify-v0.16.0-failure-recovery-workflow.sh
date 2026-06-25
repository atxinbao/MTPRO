#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160FailureRecoveryWorkflow.swift"
CONTRACT="docs/contracts/release-v0.16.0-failure-recovery-workflow-contract.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1109-VERIFY-V0160-FAILURE-RECOVERY-WORKFLOW"
  "TVM-RELEASE-V0160-FAILURE-RECOVERY-WORKFLOW"
  "V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED"
  "V0160-009-NETWORK-TIMEOUT-POSSIBLE-EXCHANGE-RECEIPT"
  "V0160-009-CANCEL-UNKNOWN-STATE"
  "V0160-009-STATUS-QUERY-COMPENSATION-WORKFLOW"
  "V0160-009-NO-AUTOMATIC-PRODUCTION-RETRY"
  "V0160-009-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$CONTRACT" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "$SOURCE" "failureRecoveryWorkflow=ReleaseV0160FailureRecoveryWorkflowEngine"
require_file_contains "$SOURCE" "submitSucceededArtifactWriteFailedCovered=true"
require_file_contains "$SOURCE" "networkTimeoutPossibleExchangeReceiptCovered=true"
require_file_contains "$SOURCE" "cancelUnknownStateCovered=true"
require_file_contains "$SOURCE" "statusQueryCompensationWorkflowCovered=true"
require_file_contains "$SOURCE" "noAutomaticRetryIntoProduction=true"
require_file_contains "$SOURCE" "productionTradingEnabledByDefault=false"
require_file_contains "$SOURCE" "productionEndpointConnected=false"
require_file_contains "$SOURCE" "productionOrderSubmitted=false"
require_file_contains "$TARGET_TESTS" "testGH1109ReleaseV0160FailureRecoveryWorkflowHandlesAmbiguousStatesFailClosed"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.0-failure-recovery-workflow.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-failure-recovery-workflow.sh"

swift test --filter TargetGraphTests/testGH1109ReleaseV0160FailureRecoveryWorkflowHandlesAmbiguousStatesFailClosed

echo "MTPRO release v0.16.0 failure recovery workflow verification passed."
