#!/usr/bin/env bash
set -euo pipefail

# GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT
# TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT
# V0170-001-V0161-PREFLIGHT-GATE
# V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE
# V0170-001-BINANCE-SPOT-TESTNET-ONLY
# V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED
# V0170-001-QUEUE-ORDER
# V0170-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 operator beta runtime hardening contract guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 operator beta runtime hardening contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170OperatorBetaRuntimeHardeningContract.swift"
CONTRACT="docs/contracts/release-v0.17.0-operator-beta-artifact-status-runtime-hardening-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1139ReleaseV0170OperatorBetaRuntimeHardeningContract

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT" \
    "TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT" \
    "V0170-001-V0161-PREFLIGHT-GATE" \
    "V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE" \
    "V0170-001-BINANCE-SPOT-TESTNET-ONLY" \
    "V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED" \
    "V0170-001-QUEUE-ORDER" \
    "V0170-001-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0170OperatorBetaRuntimeHardeningContract" \
  "ReleaseV0170OperatorBetaHardeningMode" \
  "ReleaseV0170OperatorBetaPreflightRequirement" \
  "ReleaseV0170OperatorBetaForbiddenCapability" \
  "GH-1139..GH-1148" \
  "GH-1138" \
  "MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening" \
  'requiredAllowedProductTypes = ["spot"]' \
  "explicitOperatorConfirmationRequired" \
  "redactedArtifactEvidenceRequired" \
  "artifactReplayValidationRequired" \
  "statusRuntimeHardeningScopeOnly" \
  "testnetCredentialValueReadEnabledByThisIssue == false" \
  "testnetNetworkConnectionEnabledByThisIssue == false" \
  "testnetOrderSubmissionImplementedByThisIssue == false" \
  "productionTradingEnabledByDefault == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

for child_issue in "#1140" "#1141" "#1142" "#1143" "#1144" "#1145" "#1146" "#1147" "#1148"; do
  require_file_contains "$CONTRACT" "$child_issue"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-operator-beta-runtime-hardening-contract.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-operator-beta-runtime-hardening-contract.sh"
require_file_contains "$TESTS" "testGH1139ReleaseV0170OperatorBetaRuntimeHardeningContract"
require_file_contains "$README" "MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening"
require_file_contains "$GOAL" "MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening"
require_file_contains "$ROADMAP" "GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT"
require_file_contains "$READINESS" "Release v0.17.0 operator beta runtime hardening contract anchor"
require_file_contains "$LATEST" "v0.17.0 operator beta artifact + status runtime hardening contract"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "testnetCredentialValueReadEnabledByThisIssue=true"
  reject_file_contains "$file" "testnetNetworkConnectionEnabledByThisIssue=true"
  reject_file_contains "$file" "testnetOrderSubmissionImplementedByThisIssue=true"
  reject_file_contains "$file" "createsTagOrRelease=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.17.0 operator beta runtime hardening contract verification passed.\n'
