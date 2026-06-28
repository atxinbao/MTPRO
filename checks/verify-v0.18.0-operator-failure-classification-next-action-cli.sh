#!/usr/bin/env bash
set -euo pipefail

# GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI
# TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI
# V0180-006-DEPENDENCIES-GH1179-GH1180-DONE
# V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED
# V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED
# V0180-006-RESUME-FAILURE-CLASSIFIED
# V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED
# V0180-006-NEXT-ACTION-CLI
# V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION
# V0180-006-READ-ONLY-OPERATOR-ACTION
# V0180-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 operator failure classification CLI guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    printf 'release v0.18.0 operator failure classification CLI guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0180OperatorFailureClassificationNextActionCLI.swift"
CONTRACT="docs/contracts/release-v0.18.0-operator-failure-classification-next-action-cli-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1181OperatorFailureClassificationNextActionCLIExplainsLocalEvidenceFailures

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI"
  require_file_contains "$file" "TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI"
  require_file_contains "$file" "V0180-006-DEPENDENCIES-GH1179-GH1180-DONE"
  require_file_contains "$file" "V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED"
  require_file_contains "$file" "V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED"
  require_file_contains "$file" "V0180-006-RESUME-FAILURE-CLASSIFIED"
  require_file_contains "$file" "V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED"
  require_file_contains "$file" "V0180-006-NEXT-ACTION-CLI"
  require_file_contains "$file" "V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION"
  require_file_contains "$file" "V0180-006-READ-ONLY-OPERATOR-ACTION"
  require_file_contains "$file" "V0180-006-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT" "#1179 closed / done"
require_file_contains "$CONTRACT" "#1180 closed / done"
require_file_contains "$CONTRACT" "mtpro operator-run explain-failure"
require_file_contains "$SOURCE" "operatorFailureClassificationNextActionCLI=ReleaseV0180OperatorFailureClassificationNextActionCLI"
require_file_contains "$SOURCE" "ReleaseV0180OperatorFailureClassificationNextActionInput"
require_file_contains "$SOURCE" "ReleaseV0180OperatorFailureClassificationNextActionResult"
require_file_contains "$SOURCE" "artifactManifestFailureClassified=true"
require_file_contains "$SOURCE" "statusQueryFailureClassified=true"
require_file_contains "$SOURCE" "resumeFailureClassified=true"
require_file_contains "$SOURCE" "reconciliationReplayFailureClassified=true"
require_file_contains "$SOURCE" "nextActionCLIVisible=true"
require_file_contains "$SOURCE" "venueProductEnvironmentFailureExplanation=true"
require_file_contains "$SOURCE" "readOnlyOperatorAction=true"
require_file_contains "$READINESS" "Release v0.18.0 operator failure classification next-action CLI anchor"
require_file_contains "$PLAN" "GH-1181 Release v0.18.0 Operator Failure Classification Next Action CLI"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI"
require_file_contains "$POLICY" "GH-1181 adds operator-visible failure classification and next-action CLI"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-operator-failure-classification-next-action-cli.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-operator-failure-classification-next-action-cli.sh"
require_file_contains "$TESTS" "testGH1181OperatorFailureClassificationNextActionCLIExplainsLocalEvidenceFailures"

for file in "$SOURCE" "$CONTRACT"; do
  reject_file_contains "$file" "api.binance.com"
  reject_file_contains "$file" "www.okx.com"
  reject_file_contains "$file" "URLSession"
  reject_file_contains "$file" "URLRequest"
  reject_file_contains "$file" "submitOrder"
  reject_file_contains "$file" "cancelOrder"
  reject_file_contains "$file" "replaceOrder"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
done

echo "MTPRO release v0.18.0 operator failure classification next-action CLI verification passed."
