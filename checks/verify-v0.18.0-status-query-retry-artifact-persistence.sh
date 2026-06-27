#!/usr/bin/env bash
set -euo pipefail

# GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
# TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
# V0180-003-DEPENDENCY-GH1177-DONE
# V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED
# V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
# V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION
# V0180-003-REDACTION-STATUS-PERSISTED
# V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE
# V0180-003-LOCAL-ARTIFACT-STORE-REPLAY
# V0180-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 status query retry artifact guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    printf 'release v0.18.0 status query retry artifact guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift"
ARTIFACT_STORE="Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift"
CONTRACT="docs/contracts/release-v0.18.0-status-query-retry-artifact-persistence-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1178StatusQueryRetryResultPersistsNamespaceAndFailureIntoArtifactStore

for file in \
  "$SOURCE" \
  "$ARTIFACT_STORE" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE"
  require_file_contains "$file" "TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE"
  require_file_contains "$file" "V0180-003-DEPENDENCY-GH1177-DONE"
  require_file_contains "$file" "V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED"
  require_file_contains "$file" "V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE"
  require_file_contains "$file" "V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION"
  require_file_contains "$file" "V0180-003-REDACTION-STATUS-PERSISTED"
  require_file_contains "$file" "V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE"
  require_file_contains "$file" "V0180-003-LOCAL-ARTIFACT-STORE-REPLAY"
  require_file_contains "$file" "V0180-003-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT" "#1177 closed / done"
require_file_contains "$SOURCE" "ReleaseV0180StatusQueryRetryArtifactNamespace"
require_file_contains "$SOURCE" "ReleaseV0180StatusQueryRetryArtifactSnapshot"
require_file_contains "$SOURCE" "ReleaseV0180StatusQueryRetryArtifactPersistence"
require_file_contains "$SOURCE" "appendStatusQueryRetryResult"
require_file_contains "$SOURCE" "validateStatusQueryRetryResult"
require_file_contains "$SOURCE" "retryAttemptsPersisted=true"
require_file_contains "$SOURCE" "timeoutResultPersisted=true"
require_file_contains "$SOURCE" "classifiedFailurePersisted=true"
require_file_contains "$SOURCE" "redactionStatusPersisted=true"
require_file_contains "$SOURCE" "venueProductEnvironmentNamespacePersisted=true"
require_file_contains "$SOURCE" "localArtifactStoreReplayable=true"
require_file_contains "$SOURCE" "failedStatusQueryFailClosed=true"
require_file_contains "$SOURCE" "operatorVisibleFailureEvidence=true"
require_file_contains "$ARTIFACT_STORE" "statusQueryRetrySnapshot"
require_file_contains "$CONTRACT" "operatorVisibleFailureEvidence=true"
require_file_contains "$CONTRACT" "failedStatusQueryFailClosed=true"
require_file_contains "$CONTRACT" "operatorNextAction=review-redacted-status-query-failure-before-resume"
require_file_contains "$READINESS" "Release v0.18.0 status query retry artifact persistence anchor"
require_file_contains "$PLAN" "GH-1178 Release v0.18.0 Status Query Retry Artifact Persistence"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE"
require_file_contains "$POLICY" "GH-1178 persists signed status-query retry / timeout / failure classification results"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-status-query-retry-artifact-persistence.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-status-query-retry-artifact-persistence.sh"
require_file_contains "$TESTS" "testGH1178StatusQueryRetryResultPersistsNamespaceAndFailureIntoArtifactStore"

for file in "$SOURCE" "$ARTIFACT_STORE" "$CONTRACT"; do
  reject_file_contains "$file" "api.binance.com"
  reject_file_contains "$file" "www.okx.com"
  reject_file_contains "$file" "URLSession"
  reject_file_contains "$file" "URLRequest"
  reject_file_contains "$file" "submitOrder"
  reject_file_contains "$file" "cancelOrder"
  reject_file_contains "$file" "replaceOrder"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretReadEnabled=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
done

echo "MTPRO release v0.18.0 status query retry artifact persistence verification passed."
