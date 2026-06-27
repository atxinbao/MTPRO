#!/usr/bin/env bash
set -euo pipefail

# GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
# TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
# V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED
# V0171-003-MISSING-ARTIFACT-FAILS-CLOSED
# V0171-003-MISSING-MANIFEST-FAILS-CLOSED
# V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED
# V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE
# V0171-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.1 artifact negative regression guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.1 artifact negative regression guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170CLIArtifactVerifyCommand.swift"
MANUAL_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170ManualWorkflowArtifactValidation.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
VERIFIER="checks/verify-v0.17.1-artifact-negative-regressions.sh"

swift test --filter TargetGraphTests/testGH1168ReleaseV0171ArtifactNegativeRegressionsFailClosed

for file in "$SOURCE" "$MANUAL_SOURCE" "$RUN_SCRIPT" "$AUTOMATION_SCRIPT" "$TESTS" "$VERIFIER"; do
  for anchor in \
    "GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS" \
    "TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS" \
    "V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED" \
    "V0171-003-MISSING-ARTIFACT-FAILS-CLOSED" \
    "V0171-003-MISSING-MANIFEST-FAILS-CLOSED" \
    "V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED" \
    "V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE" \
    "V0171-003-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

require_file_contains "$SOURCE" "failureDetails="
require_file_contains "$SOURCE" "corruptBundleValidationFailsClosed=true"
require_file_contains "$SOURCE" "missingArtifactValidationFailsClosed=true"
require_file_contains "$SOURCE" "negativeFailureDetailsOperatorReadable=true"
require_file_contains "$MANUAL_SOURCE" "releaseV0171ArtifactNegativeRegressionAnchors"
require_file_contains "$MANUAL_SOURCE" "releaseV0171ArtifactNegativeRegressionValidationCommands"
require_file_contains "$MANUAL_SOURCE" "missingManifestValidationFailsClosed=true"
require_file_contains "$TESTS" "testGH1168ReleaseV0171ArtifactNegativeRegressionsFailClosed"
require_file_contains "$TESTS" "expectedReason: \"checksumMismatch\""
require_file_contains "$TESTS" "expectedReason: \"bundleReadFailed\""
require_file_contains "$TESTS" "expectedReason: \"actionSequenceMismatch,reconciliationArtifactMissing\""
require_file_contains "$TESTS" "expectedDetail: \"run-manifest.json\""
require_file_contains "$TESTS" "expectedDetail: \"final artifact must be reconciliation\""
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1-artifact-negative-regressions.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1-artifact-negative-regressions.sh"

for file in "$SOURCE" "$MANUAL_SOURCE" "$VERIFIER"; do
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
done

printf 'MTPRO release v0.17.1 artifact negative regression verification passed.\n'
