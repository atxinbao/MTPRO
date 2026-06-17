#!/usr/bin/env bash
set -euo pipefail

# GH-882-VERIFY-V0100-ENDPOINT-POLICY-READINESS-GATE
# TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 endpoint policy readiness gate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 endpoint policy readiness gate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-endpoint-policy-readiness-gate-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100EndpointPolicyReadinessGate.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"

for anchor in \
  "V0100-005-ENDPOINT-POLICY-READINESS-GATE" \
  "V0100-005-TESTNET-ENDPOINT-ALLOWLIST" \
  "V0100-005-PRODUCTION-ENDPOINT-ALLOWLIST" \
  "V0100-005-ENVIRONMENT-BINDING" \
  "V0100-005-HOST-VALIDATION" \
  "V0100-005-SCHEME-VALIDATION" \
  "V0100-005-NO-SILENT-FALLBACK" \
  "V0100-005-ENDPOINT-POLICY-READINESS-JSON" \
  "V0100-005-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-882-VERIFY-V0100-ENDPOINT-POLICY-READINESS-GATE" \
  "TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for expected in \
  "endpoint_policy_readiness.json" \
  "endpoint_policy_readiness_evidence_exists=true" \
  "endpoint_policy_readiness_contains_endpoint_response=false" \
  "endpoint_policy_readiness_produced_by_connection=false" \
  "environment=testnet" \
  "environment=production" \
  "testnetEndpointHost=testnet.binance.vision" \
  "testnetEndpointHost=testnet.binancefuture.com" \
  "productionEndpointHost=api.binance.com" \
  "productionEndpointHost=fapi.binance.com" \
  "scheme=https" \
  "productTypes=spot,usdsPerpetual" \
  "environmentBound=true" \
  "hostValidationRequired=true" \
  "schemeValidationRequired=true" \
  "endpointConnectionAllowed=false" \
  "production_endpoint_connected=false" \
  "fallback_to_production=false" \
  "testnet_to_production_fallback_forbidden=true" \
  "no_silent_fallback_required=true" \
  "invalidEndpointHostAccepted=false" \
  "invalidEndpointSchemeAccepted=false" \
  "cutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonEnabled=false" \
  "orderFormEnabled=false" \
  "liveCommandEnabled=false"; do
  require_file_contains "$CONTRACT" "$expected"
done

require_file_contains "$SOURCE" "ReleaseV0100EndpointPolicyReadinessGate"
require_file_contains "$SOURCE" "ReleaseV0100EndpointPolicyReadinessRow"
require_file_contains "$SOURCE" "ReleaseV0100EndpointPolicyReadinessEvidenceArtifact"
require_file_contains "$SOURCE" "requiredScheme = \"https\""
require_file_contains "$SOURCE" "endpointPolicyCoverageHeld"
require_file_contains "$SOURCE" "evidenceBoundaryHeld"
require_file_contains "$SOURCE" "productionCapabilitiesDisabled"
require_file_contains "$TESTS" "testGH882EndpointPolicyReadinessGateRejectsProductionConnectionAndSilentFallback"
require_file_contains "$PLAN" "GH-882 Release v0.10.0 Endpoint Policy Readiness Gate Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE"
require_file_contains "$READINESS" "Release v0.10.0 endpoint policy readiness gate anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh"

for forbidden in \
  "productionEndpointConnected=true" \
  "fallbackToProduction=true" \
  "cutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true" \
  "endpointConnectionAllowed=true" \
  "containsEndpointResponse=true" \
  "producedByConnection=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 endpoint policy readiness gate verification passed."
