#!/usr/bin/env bash
set -euo pipefail

# GH-886-VERIFY-V0100-SHADOW-DRY-RUN-PARITY
# TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY

fail() {
  echo "release v0.10.0 shadow dry-run parity assessment verification failed: $*" >&2
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

CONTRACT="docs/contracts/release-v0.10.0-shadow-dry-run-parity-assessment-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100ShadowDryRunParityAssessment.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"

for path in "$CONTRACT" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-009-SHADOW-DRY-RUN-PARITY-ASSESSMENT" \
  "V0100-009-SHADOW-DRY-RUN-PARITY-JSON" \
  "V0100-009-MARKET-READONLY-OBSERVATION" \
  "V0100-009-STRATEGY-INTENT" \
  "V0100-009-RISK-DECISION-AUDITED" \
  "V0100-009-OMS-DRY-RUN-LIFECYCLE" \
  "V0100-009-PORTFOLIO-PROJECTION-AUDITED" \
  "V0100-009-RECONCILIATION-TIMELINE-AUDITED" \
  "V0100-009-READINESS-DIFF-AUDITED" \
  "V0100-009-ORDERS-SUBMITTED-FALSE" \
  "V0100-009-BROKER-COMMAND-CREATED-FALSE" \
  "V0100-009-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-886-VERIFY-V0100-SHADOW-DRY-RUN-PARITY" \
  "TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for exact in \
  "shadow_dry_run_parity.json" \
  "marketReadOnlyObservationAudited=true" \
  "strategyIntentAudited=true" \
  "riskDecisionAudited=true" \
  "portfolioProjectionAudited=true" \
  "reconciliationTimelineAudited=true" \
  "readinessDiffAudited=true" \
  "ordersSubmitted=false" \
  "brokerCommandCreated=false" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverUnblocked=false" \
  "cutoverAuthorized=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionOrderSubmissionEnabled=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandEnabled=false" \
  "productionCommandEnabled=false" \
  "shadowDryRunBypassEnabled=false"; do
  require_file_contains "$CONTRACT" "$exact"
done

for stage in \
  "market/read-only observation" \
  "strategy intent" \
  "risk decision" \
  "OMS dry-run lifecycle" \
  "portfolio projection" \
  "reconciliation timeline" \
  "readiness diff"; do
  require_file_contains "$CONTRACT" "$stage"
  require_file_contains "$SOURCE" "$stage"
done

require_file_contains "$SOURCE" "ReleaseV0100ShadowDryRunParityAssessment"
require_file_contains "$SOURCE" "ReleaseV0100ShadowDryRunParityArtifact"
require_file_contains "$SOURCE" "ReleaseV0100ShadowDryRunParityStageEvidence"
require_file_contains "$TESTS" "testGH886ShadowDryRunParityAssessmentAuditsNearProductionPathWithoutOrders"
require_file_contains "$PLAN" "GH-886 Release v0.10.0 Shadow Dry-run Parity Assessment Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY"
require_file_contains "$READINESS" "Release v0.10.0 shadow dry-run parity assessment anchor"
require_file_contains "$LATEST" "\`#886\` 定义 ShadowDryRunParityAssessment reference-only contract"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-shadow-dry-run-parity.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-shadow-dry-run-parity.sh"

for forbidden in \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "productionCutoverUnblocked=true" \
  "cutoverAuthorized=true" \
  "ordersSubmitted=true" \
  "brokerCommandCreated=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonVisible=true" \
  "orderFormVisible=true" \
  "liveCommandEnabled=true" \
  "productionCommandEnabled=true" \
  "shadowDryRunBypassEnabled=true" \
  "createsOrderPayload=true" \
  "createsBrokerCommand=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "containsOrderPayload=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 shadow dry-run parity assessment verification passed."
