#!/usr/bin/env bash
set -euo pipefail

# GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS
# TVM-RELEASE-V0210-CANARY-HARD-LIMITS
# V0210-006-CANARY-SYMBOL-ALLOWLIST
# V0210-006-NOTIONAL-QUANTITY-CAPS
# V0210-006-ORDER-TYPE-COUNT-WINDOW-LIMITS
# V0210-006-PRE-TRADE-FAIL-CLOSED
# V0210-006-NO-SUBMIT-CANCEL-REPLACE
# V0210-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 canary hard limits guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 canary hard limits guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

LIMITS_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotCanaryHardLimitPreTradeGate.swift"
LIMITS_DOC="docs/contracts/release-v0.21.0-binance-spot-canary-hard-limits.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1278ReleaseV0210CanaryHardLimitPreTradeGate

for file in \
  "$LIMITS_SOURCE" \
  "$LIMITS_DOC" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS"
  require_file_contains "$file" "TVM-RELEASE-V0210-CANARY-HARD-LIMITS"
  require_file_contains "$file" "V0210-006-CANARY-SYMBOL-ALLOWLIST"
  require_file_contains "$file" "V0210-006-NOTIONAL-QUANTITY-CAPS"
  require_file_contains "$file" "V0210-006-ORDER-TYPE-COUNT-WINDOW-LIMITS"
  require_file_contains "$file" "V0210-006-PRE-TRADE-FAIL-CLOSED"
  require_file_contains "$file" "V0210-006-NO-SUBMIT-CANCEL-REPLACE"
  require_file_contains "$file" "V0210-006-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$LIMITS_SOURCE" "ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence"
require_file_contains "$LIMITS_SOURCE" "ReleaseV0210SpotCanaryHardLimitPolicy"
require_file_contains "$LIMITS_SOURCE" "ReleaseV0210SpotCanaryHardLimitDecision"
require_file_contains "$LIMITS_SOURCE" "GH-1278"
require_file_contains "$LIMITS_SOURCE" "GH-1277"
require_file_contains "$LIMITS_SOURCE" "GH-1279"
require_file_contains "$LIMITS_SOURCE" "GH-1273..GH-1286"
require_file_contains "$LIMITS_SOURCE" "ReleaseV0181TradingEnvironment.productionLive"
require_file_contains "$LIMITS_SOURCE" "requiredAllowedSymbols = [\"BTCUSDT\"]"
require_file_contains "$LIMITS_SOURCE" "requiredAllowedOrderTypes = [ReleaseV0210SpotCanaryHardLimitOrderType.limit]"
require_file_contains "$LIMITS_SOURCE" "requiredMaxNotionalMinorUnits = 1_000"
require_file_contains "$LIMITS_SOURCE" "requiredMaxQuantityBaseMinorUnits = 100_000"
require_file_contains "$LIMITS_SOURCE" "requiredMaxOrderCountInWindow = 1"
require_file_contains "$LIMITS_SOURCE" "requiredWindowSeconds = 300"
require_file_contains "$LIMITS_SOURCE" "symbolAllowlistEnforced"
require_file_contains "$LIMITS_SOURCE" "notionalCapEnforced"
require_file_contains "$LIMITS_SOURCE" "quantityCapEnforced"
require_file_contains "$LIMITS_SOURCE" "orderTypeAllowlistEnforced"
require_file_contains "$LIMITS_SOURCE" "orderCountCapEnforced"
require_file_contains "$LIMITS_SOURCE" "timeWindowLimitEnforced"
require_file_contains "$LIMITS_SOURCE" "preTradeFailClosedBeforeOrderCreation"
require_file_contains "$LIMITS_SOURCE" "submitCancelReplaceEnabled == false"
require_file_contains "$LIMITS_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$LIMITS_DOC" "GH-1278"
require_file_contains "$LIMITS_DOC" "GH-1277"
require_file_contains "$LIMITS_DOC" "GH-1279"
require_file_contains "$LIMITS_DOC" "canary symbol / notional / order type hard limits"
require_file_contains "$LIMITS_DOC" "symbol allowlist"
require_file_contains "$LIMITS_DOC" "notional"
require_file_contains "$LIMITS_DOC" "quantity"
require_file_contains "$LIMITS_DOC" "order count"
require_file_contains "$LIMITS_DOC" "time window"
require_file_contains "$LIMITS_DOC" "does not submit / cancel / replace"
require_file_contains "$READINESS" "Release v0.21.0 canary hard limits anchor"
require_file_contains "$PLAN" "GH-1278 Release v0.21.0 Canary Hard Limits"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CANARY-HARD-LIMITS"
require_file_contains "$LATEST" "v0.21.0 canary hard limits"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-canary-hard-limits.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-canary-hard-limits.sh"
require_file_contains "$TESTS" "testGH1278ReleaseV0210CanaryHardLimitPreTradeGate"

for file in "$LIMITS_SOURCE" "$LIMITS_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "rawOrderPayloadPersisted=true"
  reject_file_contains "$file" "orderEndpointTouched=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "dashboardTradingButtonEnabled=true"
  reject_file_contains "$file" "orderFormEnabled=true"
  reject_file_contains "$file" "liveCommandEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 canary hard limits verification passed."
