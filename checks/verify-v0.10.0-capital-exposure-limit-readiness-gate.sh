#!/usr/bin/env bash
set -euo pipefail

# GH-883-VERIFY-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE
# TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 capital exposure limit readiness gate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 capital exposure limit readiness gate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-capital-exposure-limit-readiness-gate-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100CapitalExposureLimitReadinessGate.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"

for anchor in \
  "V0100-006-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE" \
  "V0100-006-MAX-CAPITAL-LIMIT" \
  "V0100-006-MAX-NOTIONAL-LIMIT" \
  "V0100-006-MAX-SINGLE-ORDER-NOTIONAL-LIMIT" \
  "V0100-006-MAX-SYMBOL-EXPOSURE-LIMIT" \
  "V0100-006-MAX-PRODUCT-EXPOSURE-LIMIT" \
  "V0100-006-MAX-DAILY-LOSS-LIMIT" \
  "V0100-006-MAX-OPEN-ORDERS-LEVERAGE-LIMIT" \
  "V0100-006-ALLOWED-SYMBOLS-PRODUCT-TYPES" \
  "V0100-006-RISK-POLICY-HASH-BINDING" \
  "V0100-006-CAPITAL-EXPOSURE-LIMITS-JSON" \
  "V0100-006-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-883-VERIFY-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE" \
  "TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for expected in \
  "capital_exposure_limits.json" \
  "capital_exposure_limits_evidence_exists=true" \
  "capital_exposure_limits_contains_broker_or_account_response=false" \
  "capital_exposure_limits_produced_by_endpoint_connection=false" \
  "maxCapital=100000.00" \
  "maxNotional=25000.00" \
  "maxSingleOrderNotional=5000.00" \
  "maxSymbolExposure=15000.00" \
  "maxProductExposure=50000.00" \
  "maxDailyLoss=2500.00" \
  "maxOpenOrders=10" \
  "maxLeverage=3.0" \
  "allowedSymbols=BTCUSDT,ETHUSDT" \
  "allowedProductTypes=spot,usdsPerpetual" \
  "riskPolicyID=v0.10.0-capital-exposure-risk-policy" \
  "riskPolicyVersion=v0.10.0-production-readiness" \
  "riskPolicyHashAlgorithm=sha256" \
  "riskPolicyHash=sha256:v0100-capital-exposure-risk-policy-reference" \
  "risk_policy_hash_bound=true" \
  "operator_review_required=true" \
  "order_submission_enabled=false" \
  "cutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonEnabled=false" \
  "orderFormEnabled=false" \
  "liveCommandEnabled=false" \
  "capitalExposureLimitBypassEnabled=false"; do
  require_file_contains "$CONTRACT" "$expected"
done

require_file_contains "$SOURCE" "ReleaseV0100CapitalExposureLimitReadinessGate"
require_file_contains "$SOURCE" "ReleaseV0100CapitalExposureLimitProfile"
require_file_contains "$SOURCE" "ReleaseV0100CapitalExposureRiskPolicyIdentity"
require_file_contains "$SOURCE" "requiredRiskPolicyHash = \"sha256:v0100-capital-exposure-risk-policy-reference\""
require_file_contains "$SOURCE" "riskPolicyHashBound"
require_file_contains "$SOURCE" "operatorReviewRequired"
require_file_contains "$SOURCE" "productionCapabilitiesDisabled"
require_file_contains "$TESTS" "testGH883CapitalExposureLimitReadinessGateBindsRiskPolicyAndDisablesOrders"
require_file_contains "$PLAN" "GH-883 Release v0.10.0 Capital / Exposure Limit Readiness Gate Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE"
require_file_contains "$READINESS" "Release v0.10.0 capital / exposure limit readiness gate anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh"

for forbidden in \
  "risk_policy_hash_bound=false" \
  "operator_review_required=false" \
  "order_submission_enabled=true" \
  "cutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true" \
  "capitalExposureLimitBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 capital exposure limit readiness gate verification passed."
