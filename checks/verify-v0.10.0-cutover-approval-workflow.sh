#!/usr/bin/env bash
set -euo pipefail

# GH-888-VERIFY-V0100-CUTOVER-APPROVAL-WORKFLOW
# TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW

fail() {
  echo "release v0.10.0 cutover approval workflow verification failed: $*" >&2
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

require_file_not_contains() {
  local path="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$path"; then
    fail "$path must not contain: $forbidden"
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-cutover-approval-workflow-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100CutoverApprovalWorkflow.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"

for path in "$CONTRACT" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-011-CUTOVER-APPROVAL-WORKFLOW" \
  "V0100-011-CUTOVER-APPROVAL-WORKFLOW-JSON" \
  "V0100-011-APPROVAL-STATES-REPRESENTED" \
  "V0100-011-APPROVED-NOT-CUTOVER-AUTHORIZED" \
  "V0100-011-APPROVED-NOT-ORDER-SUBMISSION-ENABLED" \
  "V0100-011-APPROVED-NOT-PRODUCTION-TRADING-ENABLED" \
  "V0100-011-PRODUCTION-CUTOVER-AUTHORIZED-FALSE" \
  "V0100-011-ORDER-SUBMISSION-ENABLED-FALSE" \
  "V0100-011-PRODUCTION-TRADING-ENABLED-FALSE" \
  "V0100-011-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-888-VERIFY-V0100-CUTOVER-APPROVAL-WORKFLOW" \
  "TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for state in requested reviewing approved rejected expired revoked; do
  require_file_contains "$CONTRACT" "$state"
  require_file_contains "$SOURCE" "$state"
done

for exact in \
  "cutover_approval_workflow.json" \
  "workflowChecksum=sha256:" \
  "approvalStateEvidenceCanRepresentApproved=true" \
  "approvalStateEvidenceCanRepresentRejected=true" \
  "approvedStateIsReviewEvidenceOnly=true" \
  "previousProductionReadinessBundleHeld=true" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "productionTradingEnabled=false" \
  "no_secret_value=true" \
  "noSecretValue=true" \
  "no_order_payload=true" \
  "noOrderPayload=true"; do
  require_file_contains "$CONTRACT" "$exact"
done

require_file_contains "$SOURCE" "ReleaseV0100CutoverApprovalWorkflow"
require_file_contains "$SOURCE" "ReleaseV0100CutoverApprovalState"
require_file_contains "$SOURCE" "ReleaseV0100CutoverApprovalStateEvidence"
require_file_contains "$SOURCE" "ReleaseV0100CutoverApprovalWorkflowArtifact"
require_file_contains "$TESTS" "testGH888CutoverApprovalWorkflowRepresentsApprovalWithoutTradingPermission"
require_file_contains "$PLAN" "GH-888 Release v0.10.0 Cutover Approval Workflow Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW"
require_file_contains "$READINESS" "Release v0.10.0 cutover approval workflow anchor"
require_file_contains "$LATEST" "\`#888\` 定义 CutoverApprovalWorkflow reference-only contract"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-cutover-approval-workflow.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-cutover-approval-workflow.sh"

for forbidden in \
  "productionCutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "productionTradingEnabled=true" \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "orderPayloadCreated=true" \
  "brokerCommandCreated=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonVisible=true" \
  "orderFormVisible=true" \
  "liveCommandEnabled=true" \
  "readinessApprovalConvertedToTradingPermission=true" \
  "approvalWorkflowBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "containsOrderPayload=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 cutover approval workflow verification passed."
