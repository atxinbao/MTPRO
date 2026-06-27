#!/usr/bin/env bash
set -euo pipefail

# GH-1167-VERIFY-V0171-MANUAL-WORKFLOW-FAIL-CLOSED
# TVM-RELEASE-V0171-MANUAL-WORKFLOW-FAIL-CLOSED
# V0171-002-UPLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW
# V0171-002-DOWNLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW
# V0171-002-REQUIRE-PASSED-STATUS
# V0171-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.1 manual workflow fail-closed guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.1 manual workflow fail-closed guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170ManualWorkflowArtifactValidation.swift"
WORKFLOW=".github/workflows/release-v0.17.0-manual-artifact-validation.yml"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
VERIFIER="checks/verify-v0.17.1-manual-workflow-fail-closed.sh"

swift test --filter TargetGraphTests/testGH1167ReleaseV0171ManualWorkflowRejectsFailedArtifactStatus

for file in "$SOURCE" "$WORKFLOW" "$RUN_SCRIPT" "$AUTOMATION_SCRIPT" "$TESTS" "$VERIFIER"; do
  for anchor in \
    "GH-1167-VERIFY-V0171-MANUAL-WORKFLOW-FAIL-CLOSED" \
    "TVM-RELEASE-V0171-MANUAL-WORKFLOW-FAIL-CLOSED" \
    "V0171-002-UPLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW" \
    "V0171-002-DOWNLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW" \
    "V0171-002-REQUIRE-PASSED-STATUS" \
    "V0171-002-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

require_file_contains "$WORKFLOW" "set -euo pipefail"
require_file_contains "$WORKFLOW" 'uploaded_output="$(swift run mtpro verify-operator-beta-artifact-bundle'
require_file_contains "$WORKFLOW" 'downloaded_output="$(swift run mtpro verify-operator-beta-artifact-bundle'
require_file_contains "$WORKFLOW" 'grep -Fq "status=passed" <<<"$uploaded_output"'
require_file_contains "$WORKFLOW" 'grep -Fq "status=passed" <<<"$downloaded_output"'
require_file_contains "$WORKFLOW" 'grep -Fq "boundaryHeld=true" <<<"$uploaded_output"'
require_file_contains "$WORKFLOW" 'grep -Fq "boundaryHeld=true" <<<"$downloaded_output"'
require_file_contains "$SOURCE" "failedUploadedArtifactRejectsWorkflow=true"
require_file_contains "$SOURCE" "failedDownloadedArtifactRejectsWorkflow=true"
require_file_contains "$SOURCE" "workflowRequiresPassedStatus=true"
require_file_contains "$SOURCE" "failedStatusCannotSatisfyWorkflow=true"
require_file_contains "$SOURCE" "cliFailedValidationPropagatesNonzeroExit=true"
require_file_contains "$SOURCE" "workflowFailClosedHeld"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1-manual-workflow-fail-closed.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1-manual-workflow-fail-closed.sh"
require_file_contains "$TESTS" "testGH1167ReleaseV0171ManualWorkflowRejectsFailedArtifactStatus"

for file in "$SOURCE" "$WORKFLOW" "$VERIFIER"; do
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
done

printf 'MTPRO release v0.17.1 manual workflow fail-closed verification passed.\n'
