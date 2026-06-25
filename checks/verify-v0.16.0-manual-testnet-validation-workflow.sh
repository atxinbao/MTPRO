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

reject_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  local matches
  matches="$(grep -F -- "$needle" "$path" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    echo "forbidden '$needle' in $path" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift"
WORKFLOW=".github/workflows/release-v0.16.0-manual-testnet-validation.yml"
CONTRACT="docs/contracts/release-v0.16.0-manual-testnet-validation-workflow-contract.md"
RUNBOOK="docs/operators/release-v0.16.0-manual-testnet-validation-workflow-runbook.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW"
  "TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW"
  "V0160-011-MANUAL-WORKFLOW-ONLY"
  "V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE"
  "V0160-011-RECONCILIATION-PASSED"
  "V0160-011-REDACTED-EVIDENCE-BUNDLE"
  "V0160-011-CHECKSUM-REFERENCES"
  "V0160-011-NO-PRODUCTION-CREDENTIALS"
  "V0160-011-NO-PRODUCTION-ENDPOINT"
  "V0160-011-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$WORKFLOW" \
  "$CONTRACT" \
  "$RUNBOOK" \
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

require_file_contains "$SOURCE" "manualTestnetValidationWorkflow=ReleaseV0160ManualTestnetValidationWorkflow"
require_file_contains "$SOURCE" "manualWorkflowOnly=true"
require_file_contains "$SOURCE" "submitStatusCancelStatusReconciliationSequence=true"
require_file_contains "$SOURCE" "redactedEvidenceBundleRequired=true"
require_file_contains "$SOURCE" "checksumReferencesRequired=true"
require_file_contains "$SOURCE" "githubWorkflowDispatchOnly=true"
require_file_contains "$SOURCE" "productionTradingEnabledByDefault=false"
require_file_contains "$SOURCE" "productionEndpointConnected=false"
require_file_contains "$SOURCE" "productionOrderSubmitted=false"
require_file_contains "$WORKFLOW" "workflow_dispatch:"
require_file_contains "$WORKFLOW" "dry_run_only"
require_file_contains "$WORKFLOW" "operator_confirmed_redaction"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh"
reject_file_contains "$WORKFLOW" "secrets."
reject_file_contains "$WORKFLOW" "api.binance.com/api"
require_file_contains "$TARGET_TESTS" "testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle"
require_file_contains "README.md" "#1111 manual testnet validation workflow is current WIP=1"
require_file_contains "GOAL.md" "#1111 manual testnet validation workflow is current WIP=1"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-manual-testnet-validation-workflow.sh"

swift test --filter TargetGraphTests/testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle

echo "MTPRO release v0.16.0 manual testnet validation workflow verification passed."
