#!/usr/bin/env bash
set -euo pipefail

# GH-880-VERIFY-V0100-PRODUCTION-ENVIRONMENT-PROFILE
# TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 production environment profile verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 production environment profile verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-production-environment-profile-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100ProductionEnvironmentProfile.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"

for anchor in \
  "V0100-003-PRODUCTION-ENVIRONMENT-PROFILE-CONTRACT" \
  "V0100-003-REFERENCE-ONLY-POLICY-REFS" \
  "V0100-003-BINANCE-SPOT-USDSM-PERPETUAL-SCOPE" \
  "V0100-003-PRODUCTION-CUTOVER-DISABLED" \
  "V0100-003-ORDER-SUBMISSION-DISABLED" \
  "V0100-003-PRODUCTION-ENDPOINT-CONNECTION-DISABLED" \
  "GH-880-VERIFY-V0100-PRODUCTION-ENVIRONMENT-PROFILE" \
  "TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for expected in \
  "environment=production" \
  "venue=Binance" \
  "productTypes=spot,usdsPerpetual" \
  "endpointPolicyRef=v0.10.0-production-endpoint-policy-ref" \
  "secretPolicyRef=v0.10.0-production-secret-policy-ref" \
  "riskPolicyRef=v0.10.0-production-risk-policy-ref" \
  "referencesOnlyPersisted=true" \
  "cutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "productionSecretValueStored=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonEnabled=false" \
  "orderFormEnabled=false" \
  "liveCommandEnabled=false" \
  "storesResolvedValue=false" \
  "readsSecretValue=false" \
  "connectsEndpoint=false" \
  "enablesOrderSubmission=false"; do
  require_file_contains "$CONTRACT" "$expected"
done

require_file_contains "$SOURCE" "ReleaseV0100ProductionEnvironmentProfile"
require_file_contains "$SOURCE" "ReleaseV0100ProductionEnvironmentPolicyReference"
require_file_contains "$SOURCE" "requiredProductTypes = [\"spot\", \"usdsPerpetual\"]"
require_file_contains "$SOURCE" "referenceCoverageHeld"
require_file_contains "$SOURCE" "productionCapabilitiesDisabled"
require_file_contains "$TESTS" "testGH880ProductionEnvironmentProfilePersistsReferencesOnlyAndKeepsProductionDisabled"
require_file_contains "$PLAN" "GH-880 Release v0.10.0 Production Environment Profile Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE"
require_file_contains "$READINESS" "Release v0.10.0 production environment profile contract anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-production-environment-profile.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-production-environment-profile.sh"

for forbidden in \
  "cutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "productionSecretValueStored=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true" \
  "storesResolvedValue=true" \
  "readsSecretValue=true" \
  "connectsEndpoint=true" \
  "enablesOrderSubmission=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  reject_file_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 production environment profile verification passed."
