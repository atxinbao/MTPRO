#!/usr/bin/env bash
set -euo pipefail

# GH-909-VERIFY-V0101-CLI-V0100-WORDING
# TVM-RELEASE-V0101-CLI-V0100-WORDING
# V0101-004-CLI-V0100-READINESS-CONTRACT-WORDING
# V0101-004-REFERENCE-EVIDENCE-MODEL
# V0101-004-NOT-OPERATIONAL-PRODUCTION-READINESS
# V0101-004-NO-PRODUCTION-CUTOVER
# V0101-004-NO-ENDPOINT-READINESS-CLAIM
# V0101-004-NO-LIVE-ORDER-AUTHORIZATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_contains() {
  local haystack="$1"
  local expected="$2"
  local context="$3"

  if [[ "$haystack" != *"$expected"* ]]; then
    printf 'release v0.10.1 CLI v0.10.0 wording guard failed: %s must contain: %s\n' "$context" "$expected" >&2
    exit 1
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.1 CLI v0.10.0 wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_contains() {
  local haystack="$1"
  local forbidden="$2"
  local context="$3"

  if [[ "$haystack" == *"$forbidden"* ]]; then
    printf 'release v0.10.1 CLI v0.10.0 wording guard failed: %s must not contain: %s\n' "$context" "$forbidden" >&2
    exit 1
  fi
}

OUTPUT="$(swift run mtpro verify)"

for required in \
  "mtpro verify v0.10.0" \
  "issue=GH-909" \
  "validationAnchor=TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK" \
  "verificationAnchor=GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK" \
  "wordingGuard=GH-909-VERIFY-V0101-CLI-V0100-WORDING" \
  "wordingValidationAnchor=TVM-RELEASE-V0101-CLI-V0100-WORDING" \
  "releaseModel=production-readiness-contract-reference-evidence" \
  "releaseScope=MTPRO Release v0.10.0 Production Readiness Contract / Reference Evidence Model" \
  "readinessContractOnly=true" \
  "referenceEvidenceModel=true" \
  "operationalProductionReadiness=false" \
  "productionCutoverReadinessClaim=false" \
  "productionEndpointReadinessClaim=false" \
  "liveOrderAuthorization=false" \
  "productionCutoverRequiresSeparateGate=true" \
  "checks=verify-v0.10.0-contract,verify-v0.10.0-dashboard-production-readiness-center,verify-v0.10.1-cli-verify-v0100-wording,verify-v0.10.0,automation-readiness,checks-run" \
  "historicalV090Issue=GH-856" \
  "historicalV090ValidationAnchor=TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK" \
  "historicalV090VerificationAnchor=GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK" \
  "historicalV090Checks=verify-v0.9.0-contract,verify-v0.9.0-dashboard-cli-operator-ux,verify-v0.9.0" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretRead=false" \
  "productionEndpointConnected=false" \
  "productionOrderSubmitted=false" \
  "productionCutoverAuthorized=false" \
  "boundaryHeld=true"; do
  require_contains "$OUTPUT" "$required" "mtpro verify output"
done

for anchor in \
  "V0101-004-CLI-V0100-READINESS-CONTRACT-WORDING" \
  "V0101-004-REFERENCE-EVIDENCE-MODEL" \
  "V0101-004-NOT-OPERATIONAL-PRODUCTION-READINESS" \
  "V0101-004-NO-PRODUCTION-CUTOVER" \
  "V0101-004-NO-ENDPOINT-READINESS-CLAIM" \
  "V0101-004-NO-LIVE-ORDER-AUTHORIZATION"; do
  require_contains "$OUTPUT" "$anchor" "mtpro verify output"
done

for forbidden in \
  "mtpro verify v0.9.0" \
  "operationalProductionReadiness=true" \
  "productionCutoverReadinessClaim=true" \
  "productionEndpointReadinessClaim=true" \
  "liveOrderAuthorization=true" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true" \
  "production endpoint ready" \
  "live order authorized"; do
  reject_contains "$OUTPUT" "$forbidden" "mtpro verify output"
done

for anchor in \
  "GH-909-VERIFY-V0101-CLI-V0100-WORDING" \
  "TVM-RELEASE-V0101-CLI-V0100-WORDING" \
  "V0101-004-CLI-V0100-READINESS-CONTRACT-WORDING" \
  "V0101-004-REFERENCE-EVIDENCE-MODEL" \
  "V0101-004-NOT-OPERATIONAL-PRODUCTION-READINESS" \
  "V0101-004-NO-PRODUCTION-CUTOVER" \
  "V0101-004-NO-ENDPOINT-READINESS-CLAIM" \
  "V0101-004-NO-LIVE-ORDER-AUTHORIZATION"; do
  require_file_contains "docs/automation/automation-readiness.md" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "$anchor"
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh"
require_file_contains "checks/verify-v0.10.0.sh" "bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.1-cli-verify-v0100-wording.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH909CLIVerifyV0100WordingUsesReadinessContractReferenceEvidence"

echo "MTPRO release v0.10.1 CLI verify v0.10.0 wording verification passed."
