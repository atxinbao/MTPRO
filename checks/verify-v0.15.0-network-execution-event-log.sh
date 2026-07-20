#!/usr/bin/env bash
set -euo pipefail

# GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG
# TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG
# V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG
# V0150-006-REQUEST-RESPONSE-IDENTITY
# V0150-006-CHECKSUM-CHAIN
# V0150-006-RAW-SECRET-NOT-PERSISTED
# V0150-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 network execution event log guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 network execution event log guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift"
SUBMIT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift"
CONTRACT="docs/contracts/release-v0.15.0-network-execution-event-log-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts

for anchor in \
  "GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG" \
  "TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG" \
  "V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG" \
  "V0150-006-REQUEST-RESPONSE-IDENTITY" \
  "V0150-006-CHECKSUM-CHAIN" \
  "V0150-006-RAW-SECRET-NOT-PERSISTED" \
  "V0150-006-NO-PRODUCTION-CUTOVER"; do
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
  "ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind" \
  "ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact" \
  "ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog" \
  "fromSubmitRuntimeEvidence" \
  "appendOnlyNetworkExecutionEventLog=true" \
  "redactedRequestIdentity=true" \
  "redactedResponseIdentity=true" \
  "checksumChainVerified=true" \
  "rawSecretPersisted=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretAutoRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$SUBMIT_SOURCE" "GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME"
require_file_contains "$TESTS" "testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-network-execution-event-log.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-network-execution-event-log.sh"
require_file_contains "$READINESS" "Release v0.15.0 network execution event log anchor"
require_file_contains "$LATEST" "v0.15.0 network execution event log"
require_file_contains "$PLAN" "bash checks/verify-v0.15.0-network-execution-event-log.sh"
require_file_contains "$MATRIX" "bash checks/verify-v0.15.0-network-execution-event-log.sh"

for forbidden in \
  "rawSecretPersisted=true" \
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

printf 'MTPRO release v0.15.0 network execution event log verification passed.\n'
