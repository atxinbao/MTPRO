#!/usr/bin/env bash
set -euo pipefail

# GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME
# TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL
# V0150-004-CANCEL-REQUEST-CONSTRUCTION
# V0150-004-SIGNED-TESTNET-TRANSPORT
# V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE
# V0150-004-OMS-CANCEL-STATE-TRANSITION
# V0150-004-APPEND-ONLY-CANCEL-EVENT
# V0150-004-PRODUCTION-ENDPOINT-BLOCKED
# V0150-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 real Spot Testnet cancel runtime guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 real Spot Testnet cancel runtime guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift"
EVENT_LOG_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift"
SUBMIT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift"
SIGNED_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift"
CONTRACT="docs/contracts/release-v0.15.0-real-spot-testnet-cancel-runtime-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1069ReleaseV0150SpotTestnetCancelRuntimeAppendsRedactedCancelEvidence

for anchor in \
  "GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME" \
  "TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL" \
  "V0150-004-CANCEL-REQUEST-CONSTRUCTION" \
  "V0150-004-SIGNED-TESTNET-TRANSPORT" \
  "V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE" \
  "V0150-004-OMS-CANCEL-STATE-TRANSITION" \
  "V0150-004-APPEND-ONLY-CANCEL-EVENT" \
  "V0150-004-PRODUCTION-ENDPOINT-BLOCKED" \
  "V0150-004-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for required_string in \
  "ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference" \
  "ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial" \
  "ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence" \
  "ReleaseV0150BinanceSpotTestnetCancelOperatorGate" \
  "ReleaseV0150BinanceSpotTestnetCancelTransport" \
  "ReleaseV0150BinanceSpotTestnetCancelTransportResult" \
  "ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence" \
  "ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence" \
  "ReleaseV0150BinanceSpotTestnetCancelRuntime" \
  "httpMethod=DELETE" \
  "testnet.binance.vision" \
  "/api/v3/order" \
  "testnetNetworkCancelPerformed=true" \
  "appendOnlyCancelEvidenceCreated=true" \
  "omsStateTransitionIntegrated=true" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretAutoRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$EVENT_LOG_SOURCE" "fromCancelRuntimeEvidence"
require_file_contains "$EVENT_LOG_SOURCE" ".cancel: [.cancelRequested, .cancelled]"
require_file_contains "$SUBMIT_SOURCE" "GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME"
require_file_contains "$SIGNED_SOURCE" "GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST"
require_file_contains "$TESTS" "testGH1069ReleaseV0150SpotTestnetCancelRuntimeAppendsRedactedCancelEvidence"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh"
require_file_contains "$READINESS" "Release v0.15.0 real Spot Testnet cancel runtime anchor"
require_file_contains "$LATEST" "v0.15.0 real Spot Testnet cancel runtime"
require_file_contains "$PLAN" "GH-1069 Release v0.15.0 Real Spot Testnet Cancel Runtime"
require_file_contains "$MATRIX" "TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretAutoRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com"; do
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$CONTRACT" "$forbidden"
done

printf 'MTPRO release v0.15.0 real Spot Testnet cancel runtime verification passed.\n'
