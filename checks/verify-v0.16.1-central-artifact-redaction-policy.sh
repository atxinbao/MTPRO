#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

reject_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  local matches
  matches="$(grep -F -- "$needle" "$path" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    echo "forbidden '$needle' in $path" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="Sources/DomainModel/ReleaseV0161OperatorBetaArtifactRedactionPolicy.swift"
ARTIFACT_STORE="Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift"
WORKFLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0160DashboardArtifactBackedExecutionView.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
NOTES="docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md"

anchors=(
  "GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY"
  "TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY"
  "V0161-003-SHARED-REDACTION-POLICY-SOURCE"
  "V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE"
  "V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE"
  "V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE"
  "V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS"
  "V0161-003-NO-PRODUCTION-CUTOVER"
  "GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE"
  "TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE"
  "V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS"
  "V0161-004-SIGNED-QUERY-MARKERS"
  "V0161-004-PRODUCTION-HOST-MARKERS"
  "V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS"
  "V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE"
)

for path in \
  "$POLICY" \
  "$ARTIFACT_STORE" \
  "$WORKFLOW" \
  "$DASHBOARD" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "$NOTES" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "Package.swift" "ReleaseV0161OperatorBetaArtifactRedactionPolicy.swift"
require_file_contains "$POLICY" "ReleaseV0161OperatorBetaArtifactRedactionPolicy"
require_file_contains "$POLICY" "release-v0.16.1-operator-beta-artifact-redaction-policy.v1"
require_file_contains "$POLICY" "requiredForbiddenMarkers"
require_file_contains "$ARTIFACT_STORE" "ReleaseV0161OperatorBetaArtifactRedactionPolicy.current"
require_file_contains "$ARTIFACT_STORE" "redactionPolicy.forbiddenMarkers(in: text)"
require_file_contains "$WORKFLOW" "ReleaseV0161OperatorBetaArtifactRedactionPolicy.current"
require_file_contains "$WORKFLOW" "redactionPolicy.forbiddenMarkers(in: text)"
require_file_contains "$WORKFLOW" "redactionPolicyID="
require_file_contains "$DASHBOARD" "redactionPolicyID"
require_file_contains "$DASHBOARD" "redactionPolicyHeld"
require_file_contains "$DASHBOARD" "ReleaseV0161OperatorBetaArtifactRedactionPolicy.current"
require_file_contains "$TARGET_TESTS" "testGH1135ReleaseV0161CentralArtifactRedactionPolicyIsSharedAcrossSurfaces"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.1-central-artifact-redaction-policy.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.1-central-artifact-redaction-policy.sh"
reject_file_contains "$WORKFLOW" "let markers = ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers + ["

swift test --filter TargetGraphTests/testGH1135ReleaseV0161CentralArtifactRedactionPolicyIsSharedAcrossSurfaces

echo "MTPRO release v0.16.1 central artifact redaction policy verification passed."
