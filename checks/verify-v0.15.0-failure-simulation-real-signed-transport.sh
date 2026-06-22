#!/usr/bin/env bash
set -euo pipefail

# GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT
# TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT
# V0150-010-REJECTED-TIMEOUT-RATELIMIT
# V0150-010-CREDENTIAL-SIGNATURE-FAILURES
# V0150-010-CANCEL-NOT-FOUND
# V0150-010-RECONCILIATION-MISMATCH
# V0150-010-APPEND-ONLY-REDACTED-FAILURE-EVIDENCE
# V0150-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 failure simulation guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 failure simulation guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetFailureSimulation.swift"
CONTRACT="docs/contracts/release-v0.15.0-failure-simulation-real-signed-transport-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1075ReleaseV0150FailureSimulationCoversSignedTransportAndReconciliationFailures

for anchor in \
  "GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT" \
  "TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT" \
  "V0150-010-REJECTED-TIMEOUT-RATELIMIT" \
  "V0150-010-CREDENTIAL-SIGNATURE-FAILURES" \
  "V0150-010-CANCEL-NOT-FOUND" \
  "V0150-010-RECONCILIATION-MISMATCH" \
  "V0150-010-APPEND-ONLY-REDACTED-FAILURE-EVIDENCE" \
  "V0150-010-NO-PRODUCTION-CUTOVER"; do
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
  "ReleaseV0150BinanceSpotTestnetFailureSimulationCase" \
  "ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence" \
  "ReleaseV0150BinanceSpotTestnetFailureSimulationReport" \
  "ReleaseV0150BinanceSpotTestnetFailureSimulationSuite" \
  "rejectedRequest" \
  "timeout" \
  "rateLimit" \
  "staleCredential" \
  "badSignature" \
  "cancelNotFound" \
  "reconciliationMismatch" \
  "failureSimulationOnly=true" \
  "deterministicFailureSimulation=true" \
  "appendOnlyFailureEvidence=true" \
  "redactedRequestIdentity=true" \
  "redactedResponseIdentity=true" \
  "omsStateExplainable=true" \
  "reconciliationMismatchFailClosed=true" \
  "rawSecretPersisted=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretAutoRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh"
require_file_contains "$READINESS" "Release v0.15.0 failure simulation real signed transport anchor"
require_file_contains "$LATEST" "v0.15.0 failure simulation for real signed transport"
require_file_contains "$PLAN" "GH-1075 Release v0.15.0 Failure Simulation for Real Signed Transport"
require_file_contains "$MATRIX" "TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT"
require_file_contains "$TESTS" "testGH1075ReleaseV0150FailureSimulationCoversSignedTransportAndReconciliationFailures"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com"; do
  reject_file_contains "$SOURCE" "$forbidden"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretAutoRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$CONTRACT" "$forbidden"
done

printf 'MTPRO release v0.15.0 failure simulation verification passed.\n'
