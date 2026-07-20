#!/usr/bin/env bash
set -euo pipefail

# GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST
# TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST
# V0150-002-CREDENTIAL-REFERENCE
# V0150-002-HMAC-SHA256-SIGNED-REQUEST
# V0150-002-BINANCE-SPOT-TESTNET-ONLY
# V0150-002-NO-PRODUCTION-SECRET-AUTO-READ
# V0150-002-PRODUCTION-ENDPOINT-BLOCKED
# V0150-002-REDACTED-EVIDENCE
# V0150-002-NO-NETWORK-ACTION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 testnet credential signed request guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 testnet credential signed request guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift"
CONTRACT="docs/contracts/release-v0.15.0-testnet-credential-provider-signed-request-builder-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1067ReleaseV0150SpotTestnetSignedRequestBuilderIsRedactedAndDeterministic

for anchor in \
  "GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST" \
  "TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST" \
  "V0150-002-CREDENTIAL-REFERENCE" \
  "V0150-002-HMAC-SHA256-SIGNED-REQUEST" \
  "V0150-002-BINANCE-SPOT-TESTNET-ONLY" \
  "V0150-002-NO-PRODUCTION-SECRET-AUTO-READ" \
  "V0150-002-PRODUCTION-ENDPOINT-BLOCKED" \
  "V0150-002-REDACTED-EVIDENCE" \
  "V0150-002-NO-NETWORK-ACTION"; do
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
  "ReleaseV0150BinanceSpotTestnetCredentialReference" \
  "ReleaseV0150BinanceSpotTestnetCredentialMaterial" \
  "ReleaseV0150BinanceSpotTestnetSignedRequestBuilder" \
  "ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence" \
  "testnet.binance.vision" \
  "/api/v3/order" \
  "X-MBX-APIKEY" \
  "redactedIdentifierOnly" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretAutoRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$TESTS" "testGH1067ReleaseV0150SpotTestnetSignedRequestBuilderIsRedactedAndDeterministic"
require_file_contains "$TESTS" "d15c1572ca392246ef69bff7715a21e7f2ffef81d7a7be08880c8d2c070553da"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-testnet-credential-signed-request.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-testnet-credential-signed-request.sh"
require_file_contains "$READINESS" "Release v0.15.0 testnet credential / signed request anchor"
require_file_contains "$LATEST" "v0.15.0 testnet credential / signed request builder"
require_file_contains "$PLAN" "bash checks/verify-v0.15.0-testnet-credential-signed-request.sh"
require_file_contains "$MATRIX" "bash checks/verify-v0.15.0-testnet-credential-signed-request.sh"

for forbidden in \
  "URLRequest(" \
  "URLSession(" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretAutoRead=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$CONTRACT" "$forbidden"
done

printf 'MTPRO release v0.15.0 testnet credential signed request verification passed.\n'
