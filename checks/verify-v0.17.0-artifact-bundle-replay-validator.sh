#!/usr/bin/env bash
set -euo pipefail

# GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# V0170-002-REAL-ARTIFACT-BUNDLE-INGEST
# V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION
# V0170-002-ACTION-SEQUENCE-VALIDATION
# V0170-002-RECONCILIATION-ARTIFACT-REQUIRED
# V0170-002-DETERMINISTIC-PASS-FAIL-RESULT
# V0170-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 artifact bundle replay validator guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 artifact bundle replay validator guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170OperatorBetaArtifactBundleReplayValidator.swift"
CONTRACT="docs/contracts/release-v0.17.0-operator-beta-artifact-bundle-replay-validator-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1140ReleaseV0170ArtifactBundleReplayValidator

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR" \
    "TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR" \
    "V0170-002-REAL-ARTIFACT-BUNDLE-INGEST" \
    "V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION" \
    "V0170-002-ACTION-SEQUENCE-VALIDATION" \
    "V0170-002-RECONCILIATION-ARTIFACT-REQUIRED" \
    "V0170-002-DETERMINISTIC-PASS-FAIL-RESULT" \
    "V0170-002-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "artifactBundleReplayValidator=ReleaseV0170OperatorBetaArtifactBundleReplayValidator" \
  "realArtifactBundleIngest=true" \
  "schemaValidation=true" \
  "checksumValidation=true" \
  "actionSequenceValidation=true" \
  "reconciliationArtifactRequired=true" \
  "deterministicPassFailResult=true" \
  "redactedArtifactEvidenceOnly=true" \
  "ReleaseV0170OperatorBetaArtifactBundleValidationResult" \
  "ReleaseV0170OperatorBetaArtifactBundleReplayValidator" \
  "requiredActionSequence" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$CONTRACT" "#1140 / GH-1140"
require_file_contains "$CONTRACT" "schema / checksum / action sequence / reconciliation"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-artifact-bundle-replay-validator.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-artifact-bundle-replay-validator.sh"
require_file_contains "$TESTS" "testGH1140ReleaseV0170ArtifactBundleReplayValidator"
require_file_contains "$READINESS" "Release v0.17.0 artifact bundle replay validator anchor"
require_file_contains "$LATEST" "v0.17.0 artifact bundle replay validator"
require_file_contains "$PLAN" "GH-1140 Release v0.17.0 Artifact Bundle Replay Validator"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 artifact bundle replay validator verification passed.\n'
