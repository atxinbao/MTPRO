#!/usr/bin/env bash
set -euo pipefail

# GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE
# TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE
# V0170-004-LOCAL-ARTIFACT-STORE-RESUME
# V0170-004-REPLAY-VALIDATION-REQUIRED
# V0170-004-AUDIT-CONTINUITY-PRESERVED
# V0170-004-NO-RESUBMIT-ON-RESUME
# V0170-004-REDACTED-RESUME-EVIDENCE
# V0170-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 operator run resume guard failed: %s\n' "$1" >&2
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
    printf 'release v0.17.0 operator run resume guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170OperatorRunResumeFromArtifactStore.swift"
CONTRACT="docs/contracts/release-v0.17.0-operator-run-resume-from-artifact-store-contract.md"
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

swift test --filter TargetGraphTests/testGH1142ReleaseV0170OperatorRunResumeFromArtifactStore

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE" \
    "TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE" \
    "V0170-004-LOCAL-ARTIFACT-STORE-RESUME" \
    "V0170-004-REPLAY-VALIDATION-REQUIRED" \
    "V0170-004-AUDIT-CONTINUITY-PRESERVED" \
    "V0170-004-NO-RESUBMIT-ON-RESUME" \
    "V0170-004-REDACTED-RESUME-EVIDENCE" \
    "V0170-004-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "operatorRunResumeFromArtifactStore=ReleaseV0170OperatorRunResumeFromArtifactStore" \
  "localArtifactStoreResume=true" \
  "replayValidationRequired=true" \
  "auditContinuityPreserved=true" \
  "noResubmitOnResume=true" \
  "redactedArtifactEvidenceOnly=true" \
  "ReleaseV0170OperatorRunResumeCursor" \
  "ReleaseV0170OperatorRunResumeResult" \
  "ReleaseV0170OperatorRunResumeFromArtifactStore" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$CONTRACT" "#1142 / GH-1142"
require_file_contains "$CONTRACT" "resume cursor"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-operator-run-resume-from-artifact-store.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-operator-run-resume-from-artifact-store.sh"
require_file_contains "$TESTS" "testGH1142ReleaseV0170OperatorRunResumeFromArtifactStore"
require_file_contains "$READINESS" "Release v0.17.0 operator run resume from artifact store anchor"
require_file_contains "$LATEST" "v0.17.0 operator run resume from artifact store"
require_file_contains "$PLAN" "GH-1142 Release v0.17.0 Operator Run Resume From Artifact Store"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 operator run resume verification passed.\n'
