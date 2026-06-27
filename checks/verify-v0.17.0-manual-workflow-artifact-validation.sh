#!/usr/bin/env bash
set -euo pipefail

# GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
# TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
# V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION
# V0170-008-SHARED-RUNTIME-VALIDATOR-PATH
# V0170-008-UPLOADED-BUNDLE-VALIDATED
# V0170-008-DOWNLOADED-BUNDLE-VALIDATED
# V0170-008-LOCAL-ONLY-NO-NETWORK
# V0170-008-REDACTED-EVIDENCE-RECORDED
# V0170-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 manual workflow artifact validation guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 manual workflow artifact validation guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170ManualWorkflowArtifactValidation.swift"
WORKFLOW=".github/workflows/release-v0.17.0-manual-artifact-validation.yml"
CONTRACT="docs/contracts/release-v0.17.0-manual-workflow-artifact-validation-contract.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1146ReleaseV0170ManualWorkflowArtifactValidation

for file in "$SOURCE" "$WORKFLOW" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION" \
    "TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION" \
    "V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION" \
    "V0170-008-SHARED-RUNTIME-VALIDATOR-PATH" \
    "V0170-008-UPLOADED-BUNDLE-VALIDATED" \
    "V0170-008-DOWNLOADED-BUNDLE-VALIDATED" \
    "V0170-008-LOCAL-ONLY-NO-NETWORK" \
    "V0170-008-REDACTED-EVIDENCE-RECORDED" \
    "V0170-008-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "manualWorkflowArtifactValidation=ReleaseV0170ManualWorkflowArtifactValidationReport" \
  "uploadedArtifactBundleValidation=true" \
  "downloadedArtifactBundleValidation=true" \
  "sharedRuntimeValidatorUsed=true" \
  "cliValidatorPathUsed=true" \
  "uploadDownloadEvidenceRecorded=true" \
  "localOnlyNoNetwork=true" \
  "redactedEvidenceOnly=true" \
  "ReleaseV0170CLIArtifactVerifyCommand.commandOutput" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$WORKFLOW" "release-v0.17.0-manual-artifact-validation"
require_file_contains "$WORKFLOW" "swift run mtpro verify-operator-beta-artifact-bundle"
require_file_contains "$WORKFLOW" "uploaded_artifact_storage_root"
require_file_contains "$WORKFLOW" "downloaded_artifact_storage_root"
require_file_contains "$CONTRACT" "#1146 / GH-1146"
require_file_contains "$CONTRACT" "manual workflow artifact upload/download validation"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-manual-workflow-artifact-validation.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-manual-workflow-artifact-validation.sh"
require_file_contains "$TESTS" "testGH1146ReleaseV0170ManualWorkflowArtifactValidation"
require_file_contains "$READINESS" "Release v0.17.0 manual workflow artifact validation anchor"
require_file_contains "$LATEST" "v0.17.0 manual workflow artifact validation"
require_file_contains "$PLAN" "GH-1146 Release v0.17.0 Manual Workflow Artifact Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION"

for file in "$SOURCE" "$WORKFLOW" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 manual workflow artifact validation verification passed.\n'
