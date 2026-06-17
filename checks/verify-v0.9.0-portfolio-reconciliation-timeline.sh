#!/usr/bin/env bash
set -euo pipefail

# GH-851-VERIFY-V090-PORTFOLIO-RECONCILIATION-TIMELINE
# TVM-RELEASE-V090-PORTFOLIO-RECONCILIATION-TIMELINE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 portfolio reconciliation timeline verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 portfolio reconciliation timeline verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH851PortfolioReconciliationTimelineBindsExpectedObservedDeltaAndAckMetadata

require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationTimelineReadModel"
require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationTimelineRecord"
require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationStateSnapshot"
require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationOperatorAcknowledgement"
require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationReviewHistoryEntry"
require_file_contains "$SOURCE" "ReleaseV090PortfolioReconciliationTimelineStatus"
require_file_contains "$SOURCE" "expectedState"
require_file_contains "$SOURCE" "observedState"
require_file_contains "$SOURCE" "deltaQuantity"
require_file_contains "$SOURCE" "staleReason"
require_file_contains "$SOURCE" "operatorAcknowledgement"
require_file_contains "$SOURCE" "reviewHistory"
require_file_contains "$SOURCE" "portfolioReconciliationTimeline"
require_file_contains "$SOURCE" "correctionCommandCreated"
require_file_contains "$SOURCE" "brokerWriteCreated"
require_file_contains "$SOURCE" "accountMutationCreated"
require_file_contains "$SOURCE" "tradingAdjustmentCreated"
require_file_contains "$TARGET_TESTS" "testGH851PortfolioReconciliationTimelineBindsExpectedObservedDeltaAndAckMetadata"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-portfolio-reconciliation-timeline.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 Portfolio reconciliation timeline anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-851-VERIFY-V090-PORTFOLIO-RECONCILIATION-TIMELINE"
require_file_contains "$VALIDATION_PLAN" "GH-851 Release v0.9.0 Portfolio Reconciliation Timeline Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-PORTFOLIO-RECONCILIATION-TIMELINE"
require_file_contains "$CONTRACT" "V090-009-PORTFOLIO-RECONCILIATION-TIMELINE"

for anchor in \
  "GH-851-VERIFY-V090-PORTFOLIO-RECONCILIATION-TIMELINE" \
  "TVM-RELEASE-V090-PORTFOLIO-RECONCILIATION-TIMELINE" \
  "V090-009-PORTFOLIO-RECONCILIATION-TIMELINE" \
  "V090-009-EXPECTED-OBSERVED-DELTA" \
  "V090-009-STALE-REASON-REVIEW-HISTORY" \
  "V090-009-OPERATOR-ACKNOWLEDGEMENT-METADATA-ONLY" \
  "V090-009-MONITOR-SESSION-EVIDENCE-BINDING" \
  "V090-009-NO-CORRECTION-COMMAND" \
  "V090-009-NO-BROKER-WRITE" \
  "V090-009-NO-ACCOUNT-MUTATION" \
  "V090-009-NO-TRADING-ADJUSTMENT" \
  "V090-009-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "correctionCommandCreated=true"
reject_file_contains "$SOURCE" "brokerWriteCreated=true"
reject_file_contains "$SOURCE" "accountMutationCreated=true"
reject_file_contains "$SOURCE" "tradingAdjustmentCreated=true"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "brokerEndpointConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"

echo "MTPRO release v0.9.0 portfolio reconciliation timeline verification passed."
