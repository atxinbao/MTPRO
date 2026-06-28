#!/usr/bin/env bash
set -euo pipefail

# GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES
# TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES
# V0180-008-DEPENDENCIES-GH1177-GH1178-DONE
# V0180-008-CORRUPT-BUNDLE-FAILS-CLOSED
# V0180-008-MISSING-FIELDS-FAIL-CLOSED
# V0180-008-WRONG-VENUE-PRODUCT-ENVIRONMENT-FAILS-CLOSED
# V0180-008-FAILED-VALIDATION-STATE-REJECTS-WORKFLOW
# V0180-008-FAILED-CHECKS-CANNOT-PASS-WITH-FAILED-STATUS-STRING
# V0180-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.18.0 manual workflow fixture negative cases guard failed: %s\n' "$1" >&2
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
    printf 'release v0.18.0 manual workflow fixture negative cases guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170ManualWorkflowArtifactValidation.swift"
CONTRACT="docs/contracts/release-v0.18.0-manual-workflow-fixture-negative-cases-contract.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
READINESS_DOC="docs/automation/automation-readiness.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
RELEASE_POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
VERIFIER="checks/verify-v0.18.0-manual-workflow-fixture-negative-cases.sh"

swift test --filter TargetGraphTests/testGH1183ManualWorkflowFixtureNegativeCasesFailClosed

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$READINESS_DOC" \
  "$VALIDATION_PLAN" \
  "$TRADING_MATRIX" \
  "$RELEASE_POLICY" \
  "$TESTS" \
  "$VERIFIER"; do
  for anchor in \
    "GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES" \
    "TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES" \
    "V0180-008-DEPENDENCIES-GH1177-GH1178-DONE" \
    "V0180-008-CORRUPT-BUNDLE-FAILS-CLOSED" \
    "V0180-008-MISSING-FIELDS-FAIL-CLOSED" \
    "V0180-008-WRONG-VENUE-PRODUCT-ENVIRONMENT-FAILS-CLOSED" \
    "V0180-008-FAILED-VALIDATION-STATE-REJECTS-WORKFLOW" \
    "V0180-008-FAILED-CHECKS-CANNOT-PASS-WITH-FAILED-STATUS-STRING" \
    "V0180-008-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

require_file_contains "$SOURCE" "ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite"
require_file_contains "$SOURCE" "corruptBundleFixtureFailsClosed=true"
require_file_contains "$SOURCE" "missingFieldFixtureFailsClosed=true"
require_file_contains "$SOURCE" "wrongVenueFixtureFailsClosed=true"
require_file_contains "$SOURCE" "wrongProductFixtureFailsClosed=true"
require_file_contains "$SOURCE" "wrongEnvironmentFixtureFailsClosed=true"
require_file_contains "$SOURCE" "failedValidationStateRejectsWorkflow=true"
require_file_contains "$SOURCE" "failedChecksCannotPassWithFailedStatusString=true"
require_file_contains "$SOURCE" "noSecretUpload=true"
require_file_contains "$SOURCE" "noOrderArtifactGeneratedFromWorkflowAlone=true"
require_file_contains "$TESTS" "testGH1183ManualWorkflowFixtureNegativeCasesFailClosed"
require_file_contains "$TESTS" "failureReasons=checksumMismatch"
require_file_contains "$TESTS" "productionShadow"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-manual-workflow-fixture-negative-cases.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-manual-workflow-fixture-negative-cases.sh"
require_file_contains "$READINESS_DOC" "Release v0.18.0 manual workflow fixture negative cases anchor"
require_file_contains "$VALIDATION_PLAN" "GH-1183 Release v0.18.0 Manual Workflow Fixture Negative Cases"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES"
require_file_contains "$RELEASE_POLICY" "GH-1183 adds manual workflow fixture upload / download negative cases"
require_file_contains "$CONTRACT" "#1183 / GH-1183"
require_file_contains "$CONTRACT" "#1177 closed / done"
require_file_contains "$CONTRACT" "#1178 closed / done"

for file in "$SOURCE" "$CONTRACT" "$VERIFIER" "$READINESS_DOC" "$VALIDATION_PLAN" "$TRADING_MATRIX" "$RELEASE_POLICY"; do
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
done

printf 'MTPRO release v0.18.0 manual workflow fixture negative cases verification passed.\n'
