#!/usr/bin/env bash
set -euo pipefail

# GH-881-VERIFY-V0100-SECRET-PROVIDER-READINESS-GATE
# TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 secret provider readiness gate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 secret provider readiness gate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-secret-provider-readiness-gate-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100SecretProviderReadinessGate.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"

for anchor in \
  "V0100-004-SECRET-PROVIDER-READINESS-GATE" \
  "V0100-004-CREDENTIAL-REFERENCE-EXISTS" \
  "V0100-004-PROVIDER-TYPE-REFERENCE-ONLY" \
  "V0100-004-REDACTION-POLICY-REQUIRED" \
  "V0100-004-SECRET-READINESS-JSON" \
  "V0100-004-REDACTION-PROOF-JSON" \
  "V0100-004-CI-NO-SECRET-PROOF" \
  "V0100-004-MANUAL-SECRET-GATE-REQUIRED" \
  "V0100-004-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-881-VERIFY-V0100-SECRET-PROVIDER-READINESS-GATE" \
  "TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for expected in \
  "credentialReferenceExists=true" \
  "providerType=environmentVariableReference" \
  "providerType=keychainItemReference" \
  "providerType=operatorManualReference" \
  "redactionPolicy=redactedIdentifierOnly" \
  "secret_readiness.json" \
  "secret_readiness_evidence_exists=true" \
  "secret_readiness_contains_secret_value=false" \
  "secret_readiness_produced_by_ci=false" \
  "redaction_proof.json" \
  "redaction_proof_evidence_exists=true" \
  "redaction_proof_contains_secret_value=false" \
  "redaction_proof_produced_by_ci=false" \
  "ci_no_secret_proof=true" \
  "manual_secret_gate_required=true" \
  "operatorConfirmationRequired=true" \
  "storesSecretValue=false" \
  "readsSecretValue=false" \
  "printsSecretValue=false" \
  "dashboardDisplaysSecretValue=false" \
  "ciSecretAvailable=false" \
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
  "liveCommandEnabled=false"; do
  require_file_contains "$CONTRACT" "$expected"
done

require_file_contains "$SOURCE" "ReleaseV0100SecretProviderReadinessGate"
require_file_contains "$SOURCE" "ReleaseV0100SecretProviderReference"
require_file_contains "$SOURCE" "ReleaseV0100SecretProviderReadinessEvidenceArtifact"
require_file_contains "$SOURCE" "requiredRedactionPolicy = \"redactedIdentifierOnly\""
require_file_contains "$SOURCE" "credentialReferenceCoverageHeld"
require_file_contains "$SOURCE" "evidenceArtifactsHeld"
require_file_contains "$SOURCE" "productionCapabilitiesDisabled"
require_file_contains "$TESTS" "testGH881SecretProviderReadinessGateKeepsSecretsOutOfRuntimeCIDashboardAndEvidence"
require_file_contains "$PLAN" "GH-881 Release v0.10.0 Secret Provider Readiness Gate Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE"
require_file_contains "$READINESS" "Release v0.10.0 secret provider readiness gate anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-secret-provider-readiness-gate.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-secret-provider-readiness-gate.sh"

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
  "storesSecretValue=true" \
  "readsSecretValue=true" \
  "printsSecretValue=true" \
  "dashboardDisplaysSecretValue=true" \
  "ciSecretAvailable=true" \
  "containsSecretValue=true" \
  "producedByCI=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  reject_file_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 secret provider readiness gate verification passed."
