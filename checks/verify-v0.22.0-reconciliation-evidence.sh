#!/usr/bin/env bash
set -euo pipefail

# GH-1316-VERIFY-V0220-RECONCILIATION-EVIDENCE
# TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE
# V0220-008-BLOCKED-BY-GH1312-GH1315
# V0220-008-OMS-EXCHANGE-STATUS-ACCOUNT-RECONCILIATION
# V0220-008-MATCHED-PENDING-AMBIGUOUS-REJECTED-CANCELLED-FILL-LIKE
# V0220-008-REDACTED-RECONCILIATION-ARTIFACT
# V0220-008-MISSING-EXCHANGE-EVIDENCE-FAILS-CLOSED
# V0220-008-AMBIGUOUS-STATE-FAILS-CLOSED
# V0220-008-NEXT-OPERATOR-ACTION
# V0220-008-NO-FUTURES-OKX
# V0220-008-NO-DASHBOARD-TRADING-CONTROLS
# V0220-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 reconciliation evidence guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 reconciliation evidence guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryReconciliationEvidence.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-reconciliation-evidence.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1316ReleaseV0220ReconcilesOMSWithSignedAccountAndOrderStatusEvidence

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1316-VERIFY-V0220-RECONCILIATION-EVIDENCE"
  require_file_contains "$file" "TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE"
  require_file_contains "$file" "V0220-008-BLOCKED-BY-GH1312-GH1315"
  require_file_contains "$file" "V0220-008-OMS-EXCHANGE-STATUS-ACCOUNT-RECONCILIATION"
  require_file_contains "$file" "V0220-008-MATCHED-PENDING-AMBIGUOUS-REJECTED-CANCELLED-FILL-LIKE"
  require_file_contains "$file" "V0220-008-REDACTED-RECONCILIATION-ARTIFACT"
  require_file_contains "$file" "V0220-008-MISSING-EXCHANGE-EVIDENCE-FAILS-CLOSED"
  require_file_contains "$file" "V0220-008-AMBIGUOUS-STATE-FAILS-CLOSED"
  require_file_contains "$file" "V0220-008-NEXT-OPERATOR-ACTION"
  require_file_contains "$file" "V0220-008-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-008-NO-DASHBOARD-TRADING-CONTROLS"
  require_file_contains "$file" "V0220-008-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryReconciliationEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryOMSEventLogEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight"
require_file_contains "$CONTRACT_SOURCE" "matchedArtifact"
require_file_contains "$CONTRACT_SOURCE" "pendingArtifact"
require_file_contains "$CONTRACT_SOURCE" "ambiguousArtifact"
require_file_contains "$CONTRACT_SOURCE" "rejectedArtifact"
require_file_contains "$CONTRACT_SOURCE" "cancelledArtifact"
require_file_contains "$CONTRACT_SOURCE" "fillLikeArtifact"
require_file_contains "$CONTRACT_SOURCE" "missingExchangeEvidenceArtifact"
require_file_contains "$CONTRACT_SOURCE" "localOnlyRejectedArtifact"
require_file_contains "$CONTRACT_SOURCE" "missingOMSEventLogArtifact"
require_file_contains "$CONTRACT_SOURCE" "nextOperatorActionRequired"
require_file_contains "$CONTRACT_DOC" "redacted reconciliation artifact"
require_file_contains "$CONTRACT_DOC" "matched / pending / ambiguous / rejected / cancelled / fill-like"
require_file_contains "$README" "v0.22.0 reconciliation evidence"
require_file_contains "$READINESS" "Release v0.22.0 reconciliation evidence anchor"
require_file_contains "$PLAN" "GH-1316 Release v0.22.0 Reconciliation Evidence"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE"
require_file_contains "$VERIFICATION" "GH-1316 v0.22.0 Reconciliation Evidence"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-reconciliation-evidence.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-reconciliation-evidence.sh"
require_file_contains "$TESTS" "testGH1316ReleaseV0220ReconcilesOMSWithSignedAccountAndOrderStatusEvidence"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "rawPayloadPersisted=true"
  reject_file_contains "$file" "rawCredentialValuePersisted=true"
  reject_file_contains "$file" "signaturePersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "localOnlyReconciliation=true"
  reject_file_contains "$file" "Futures reconciliation enabled"
  reject_file_contains "$file" "OKX reconciliation enabled"
  reject_file_contains "$file" "Dashboard trading button enabled"
done

echo "MTPRO release v0.22.0 reconciliation evidence verification passed."
