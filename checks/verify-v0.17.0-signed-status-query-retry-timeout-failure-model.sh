#!/usr/bin/env bash
set -euo pipefail

# GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
# TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
# V0170-003-BOUNDED-STATUS-QUERY-RETRY
# V0170-003-PER-ATTEMPT-TIMEOUT
# V0170-003-CLASSIFIED-FAILURE-EVIDENCE
# V0170-003-RETRY-LIMIT-FAIL-CLOSED
# V0170-003-REDACTED-FAILURE-EVIDENCE
# V0170-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 signed status query failure model guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 signed status query failure model guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel.swift"
STATUS_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift"
CONTRACT="docs/contracts/release-v0.17.0-signed-status-query-retry-timeout-failure-model-contract.md"
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

swift test --filter TargetGraphTests/testGH1141ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel

for file in "$SOURCE" "$STATUS_FLOW" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL" \
    "TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL" \
    "V0170-003-BOUNDED-STATUS-QUERY-RETRY" \
    "V0170-003-PER-ATTEMPT-TIMEOUT" \
    "V0170-003-CLASSIFIED-FAILURE-EVIDENCE" \
    "V0170-003-RETRY-LIMIT-FAIL-CLOSED" \
    "V0170-003-REDACTED-FAILURE-EVIDENCE" \
    "V0170-003-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "signedStatusQueryRetryTimeoutFailureModel=ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel" \
  "boundedRetry=true" \
  "timeoutClassification=true" \
  "classifiedFailureEvidence=true" \
  "retryLimitFailClosed=true" \
  "redactedFailureEvidenceOnly=true" \
  "ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel" \
  "ReleaseV0170SignedStatusQueryRetryPolicy" \
  "ReleaseV0170SignedStatusQueryAttemptFailure" \
  "ReleaseV0170SignedStatusQueryRetryTimeoutFailureError" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$CONTRACT" "#1141 / GH-1141"
require_file_contains "$CONTRACT" "retry / timeout / classified failure"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-signed-status-query-retry-timeout-failure-model.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-signed-status-query-retry-timeout-failure-model.sh"
require_file_contains "$TESTS" "testGH1141ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel"
require_file_contains "$READINESS" "Release v0.17.0 signed status query retry / timeout failure model anchor"
require_file_contains "$LATEST" "v0.17.0 signed status query retry / timeout failure model"
require_file_contains "$PLAN" "GH-1141 Release v0.17.0 Signed Status Query Retry / Timeout Failure Model"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL"

for file in "$SOURCE" "$STATUS_FLOW" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 signed status query failure model verification passed.\n'
