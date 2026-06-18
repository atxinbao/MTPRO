#!/usr/bin/env bash
set -euo pipefail

# GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING
# TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_output_contains() {
  local output="$1"
  local expected="$2"

  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'release v0.8.1 CLI verify wording failed: output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" <<< "$output"; then
    printf 'release v0.8.1 CLI verify wording failed: output must not contain: %s\n' "$forbidden" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 CLI verify wording failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

SOURCE="Sources/MTPROCLI/main.swift"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH837TopLevelCLIVerifyUsesV080ReleaseVerificationWording

verify_output="$(swift run mtpro verify)"
require_output_contains "$verify_output" "mtpro verify v0.10.0"
require_output_contains "$verify_output" "issue=GH-909"
require_output_contains "$verify_output" "validationAnchor=TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "verificationAnchor=GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "wordingGuard=GH-909-VERIFY-V0101-CLI-V0100-WORDING"
require_output_contains "$verify_output" "checks=verify-v0.10.0-contract,verify-v0.10.0-dashboard-production-readiness-center,verify-v0.10.1-cli-verify-v0100-wording,verify-v0.10.0,automation-readiness,checks-run"
require_output_contains "$verify_output" "releaseModel=production-readiness-contract-reference-evidence"
require_output_contains "$verify_output" "readinessContractOnly=true"
require_output_contains "$verify_output" "referenceEvidenceModel=true"
require_output_contains "$verify_output" "operationalProductionReadiness=false"
require_output_contains "$verify_output" "productionCutoverReadinessClaim=false"
require_output_contains "$verify_output" "productionEndpointReadinessClaim=false"
require_output_contains "$verify_output" "liveOrderAuthorization=false"
require_output_contains "$verify_output" "historicalV090Issue=GH-856"
require_output_contains "$verify_output" "historicalV090ValidationAnchor=TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "historicalV090VerificationAnchor=GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "historicalV090Checks=verify-v0.9.0-contract,verify-v0.9.0-dashboard-cli-operator-ux,verify-v0.9.0"
require_output_contains "$verify_output" "historicalV080Issue=GH-820"
require_output_contains "$verify_output" "historicalV080Checks=verify-v0.8.0-contract,verify-v0.8.0-release-publication-policy,verify-v0.8.0-cli-local-session,verify-v0.8.0-validation-lanes,verify-v0.8.0"
require_output_contains "$verify_output" "historicalV070Checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli"
require_output_contains "$verify_output" "persistentLocalSessionContract=v0.8.0"
require_output_contains "$verify_output" "productionTradingEnabledByDefault=false"
require_output_contains "$verify_output" "productionSecretRead=false"
require_output_contains "$verify_output" "productionEndpointConnected=false"
require_output_contains "$verify_output" "productionOrderSubmitted=false"
require_output_contains "$verify_output" "productionCutoverAuthorized=false"
reject_output_contains "$verify_output" "mtpro verify v0.7.0"
reject_output_contains "$verify_output" "productionTradingEnabledByDefault=true"
reject_output_contains "$verify_output" "productionSecretRead=true"
reject_output_contains "$verify_output" "productionEndpointConnected=true"
reject_output_contains "$verify_output" "productionOrderSubmitted=true"
reject_output_contains "$verify_output" "productionCutoverAuthorized=true"

for anchor in \
  "GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING" \
  "TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING" \
  "V081-003-CLI-VERIFY-V080-WORDING" \
  "V081-003-HISTORICAL-V070-GUARDS" \
  "V081-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1-cli-verify-v080-wording.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.1 CLI verify v0.8.0 wording anchor"
require_file_contains "$VALIDATION_PLAN" "GH-837 Release v0.8.1 CLI Verify v0.8.0 Wording Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING"
require_file_contains "$TARGET_TESTS" "testGH837TopLevelCLIVerifyUsesV080ReleaseVerificationWording"
require_file_contains "$TARGET_TESTS" "testGH909CLIVerifyV0100WordingUsesReadinessContractReferenceEvidence"

echo "MTPRO release v0.8.1 CLI verify v0.8.0 wording verification passed."
