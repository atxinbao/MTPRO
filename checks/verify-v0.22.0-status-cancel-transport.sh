#!/usr/bin/env bash
set -euo pipefail

# GH-1314-VERIFY-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT
# TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT
# V0220-006-BLOCKED-BY-GH1313
# V0220-006-STATUS-QUERY-BY-EXCHANGE-AND-CLIENT-ID
# V0220-006-CANCEL-APPROVED-CANARY-ORDER-ONLY
# V0220-006-IDEMPOTENCY-KEY-RETRY-CLASSIFICATION
# V0220-006-REDACTED-STATUS-CANCEL-EVIDENCE
# V0220-006-AMBIGUOUS-STATE-REQUIRES-RECONCILIATION
# V0220-006-UNKNOWN-STATE-FAILS-CLOSED
# V0220-006-NO-FUTURES-OKX
# V0220-006-NO-DASHBOARD-TRADING-CONTROLS
# V0220-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 status/cancel transport guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 status/cancel transport guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryStatusCancelTransport.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-status-cancel-transport.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1314ReleaseV0220LiveOrderStatusCancelTransport

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
  require_file_contains "$file" "GH-1314-VERIFY-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT"
  require_file_contains "$file" "TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT"
  require_file_contains "$file" "V0220-006-BLOCKED-BY-GH1313"
  require_file_contains "$file" "V0220-006-STATUS-QUERY-BY-EXCHANGE-AND-CLIENT-ID"
  require_file_contains "$file" "V0220-006-CANCEL-APPROVED-CANARY-ORDER-ONLY"
  require_file_contains "$file" "V0220-006-IDEMPOTENCY-KEY-RETRY-CLASSIFICATION"
  require_file_contains "$file" "V0220-006-REDACTED-STATUS-CANCEL-EVIDENCE"
  require_file_contains "$file" "V0220-006-AMBIGUOUS-STATE-REQUIRES-RECONCILIATION"
  require_file_contains "$file" "V0220-006-UNKNOWN-STATE-FAILS-CLOSED"
  require_file_contains "$file" "V0220-006-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-006-NO-DASHBOARD-TRADING-CONTROLS"
  require_file_contains "$file" "V0220-006-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence"
require_file_contains "$CONTRACT_SOURCE" "requiredRunID"
require_file_contains "$CONTRACT_SOURCE" "requiredClientOrderID"
require_file_contains "$CONTRACT_SOURCE" "requiredExchangeOrderID"
require_file_contains "$CONTRACT_SOURCE" "requiredIdempotencyKey"
require_file_contains "$CONTRACT_SOURCE" "redactedStatusEvidenceEnvelope"
require_file_contains "$CONTRACT_SOURCE" "redactedCancelEvidenceEnvelope"
require_file_contains "$CONTRACT_SOURCE" "idempotentDuplicateRetry"
require_file_contains "$CONTRACT_SOURCE" "ambiguousStateRequiresReconciliation"
require_file_contains "$CONTRACT_SOURCE" "cancelTargetOutsideApprovedOrder"
require_file_contains "$CONTRACT_DOC" "approved Binance Spot live canary status / cancel transport"
require_file_contains "$CONTRACT_DOC" "Duplicate retry is accepted only when the idempotency key matches"
require_file_contains "$README" "v0.22.0 live order status / cancel transport"
require_file_contains "$READINESS" "Release v0.22.0 live order status / cancel transport anchor"
require_file_contains "$PLAN" "GH-1314 Release v0.22.0 Live Order Status / Cancel Transport"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT"
require_file_contains "$VERIFICATION" "GH-1314 v0.22.0 Live Order Status / Cancel Transport"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-status-cancel-transport.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-status-cancel-transport.sh"
require_file_contains "$TESTS" "testGH1314ReleaseV0220LiveOrderStatusCancelTransport"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "rawStatusPayloadPersisted=true"
  reject_file_contains "$file" "rawCancelPayloadPersisted=true"
  reject_file_contains "$file" "rawCredentialValuePersisted=true"
  reject_file_contains "$file" "signaturePersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "Futures live execution started"
  reject_file_contains "$file" "OKX active implementation started"
  reject_file_contains "$file" "Dashboard trading button enabled"
done

echo "MTPRO release v0.22.0 status/cancel transport verification passed."
