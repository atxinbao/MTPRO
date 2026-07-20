#!/usr/bin/env bash
set -euo pipefail

# GH-1312-VERIFY-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT
# TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT
# V0220-004-BLOCKED-BY-GH1311
# V0220-004-APPROVED-CANARY-SESSION-ONLY
# V0220-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT
# V0220-004-REDACTED-FRESHNESS-STATUS-EVIDENCE
# V0220-004-RAW-ACCOUNT-PAYLOAD-NEVER-PERSISTED
# V0220-004-ENDPOINT-AUTH-TIMESTAMP-PERMISSION-STALE-FAIL-CLOSED
# V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT
# V0220-004-NO-FUTURES-OKX
# V0220-004-NO-ORDER-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 signed account runtime preflight guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 signed account runtime preflight guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-signed-account-runtime-preflight.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1312ReleaseV0220SignedAccountRuntimePreflight

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
  require_file_contains "$file" "GH-1312-VERIFY-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT"
  require_file_contains "$file" "TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT"
  require_file_contains "$file" "V0220-004-BLOCKED-BY-GH1311"
  require_file_contains "$file" "V0220-004-APPROVED-CANARY-SESSION-ONLY"
  require_file_contains "$file" "V0220-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT"
  require_file_contains "$file" "V0220-004-REDACTED-FRESHNESS-STATUS-EVIDENCE"
  require_file_contains "$file" "V0220-004-RAW-ACCOUNT-PAYLOAD-NEVER-PERSISTED"
  require_file_contains "$file" "V0220-004-ENDPOINT-AUTH-TIMESTAMP-PERMISSION-STALE-FAIL-CLOSED"
  require_file_contains "$file" "V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT"
  require_file_contains "$file" "V0220-004-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-004-NO-ORDER-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight"
require_file_contains "$CONTRACT_SOURCE" "GH-1312"
require_file_contains "$CONTRACT_SOURCE" "GH-1311"
require_file_contains "$CONTRACT_SOURCE" "GH-1313"
require_file_contains "$CONTRACT_SOURCE" "GH-1309..GH-1320"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath"
require_file_contains "$CONTRACT_SOURCE" "readyObservation.readyObservationHeld"
require_file_contains "$CONTRACT_SOURCE" "failedPreflightBlocksSubmitPath: Bool = true"
require_file_contains "$CONTRACT_SOURCE" "rawAccountPayloadPersisted: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "signaturePersisted: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "futuresExecutionEnabled: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "okxActiveImplementationEnabled: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "submitCancelReplaceEnabledByThisIssue: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "productionCutoverAuthorized: Bool = false"
require_file_contains "$CONTRACT_DOC" "signed account runtime preflight"
require_file_contains "$CONTRACT_DOC" "Persist only redacted freshness/status evidence"
require_file_contains "$CONTRACT_DOC" "No Futures or OKX runtime"
require_file_contains "$README" "v0.22.0 signed account runtime preflight"
require_file_contains "$READINESS" "Release v0.22.0 signed account runtime preflight anchor"
require_file_contains "$PLAN" "GH-1312 Release v0.22.0 Signed Account Runtime Preflight"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT"
require_file_contains "$VERIFICATION" "GH-1312 v0.22.0 Signed Account Runtime Preflight"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-signed-account-runtime-preflight.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-signed-account-runtime-preflight.sh"
require_file_contains "$TESTS" "testGH1312ReleaseV0220SignedAccountRuntimePreflight"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "rawAccountPayloadPersisted=true"
  reject_file_contains "$file" "signaturePersisted=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "Futures live execution started"
  reject_file_contains "$file" "OKX active implementation started"
done

echo "MTPRO release v0.22.0 signed account runtime preflight verification passed."
