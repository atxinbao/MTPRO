#!/usr/bin/env bash
set -euo pipefail

# GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL
# TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL
# V0210-003-CREDENTIAL-SECRET-READ-APPROVAL
# V0210-003-EXPLICIT-OPERATOR-APPROVAL
# V0210-003-REDACTED-AUDIT-EVIDENCE
# V0210-003-NO-AUTOMATIC-SECRET-DISCOVERY
# V0210-003-NO-SECRET-LOGGING
# V0210-003-NO-ENDPOINT-ORDER-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 credential secret-read approval guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 credential secret-read approval guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

APPROVAL_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.swift"
APPROVAL_DOC="docs/contracts/release-v0.21.0-binance-spot-canary-credential-secret-read-approval.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1275ReleaseV0210CredentialSecretReadApprovalPath

for file in \
  "$APPROVAL_SOURCE" \
  "$APPROVAL_DOC" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL"
  require_file_contains "$file" "TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL"
  require_file_contains "$file" "V0210-003-CREDENTIAL-SECRET-READ-APPROVAL"
  require_file_contains "$file" "V0210-003-EXPLICIT-OPERATOR-APPROVAL"
  require_file_contains "$file" "V0210-003-REDACTED-AUDIT-EVIDENCE"
  require_file_contains "$file" "V0210-003-NO-AUTOMATIC-SECRET-DISCOVERY"
  require_file_contains "$file" "V0210-003-NO-SECRET-LOGGING"
  require_file_contains "$file" "V0210-003-NO-ENDPOINT-ORDER-CUTOVER"
done

require_file_contains "$APPROVAL_SOURCE" "ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath"
require_file_contains "$APPROVAL_SOURCE" "ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence"
require_file_contains "$APPROVAL_SOURCE" "GH-1275"
require_file_contains "$APPROVAL_SOURCE" "GH-1274"
require_file_contains "$APPROVAL_SOURCE" "GH-1276"
require_file_contains "$APPROVAL_SOURCE" "GH-1273..GH-1286"
require_file_contains "$APPROVAL_SOURCE" "ReleaseV0181TradingEnvironment.productionLive"
require_file_contains "$APPROVAL_SOURCE" "approvedForScopedSecretRead"
require_file_contains "$APPROVAL_SOURCE" "operatorApprovalEvidencePresent"
require_file_contains "$APPROVAL_SOURCE" "operatorApprovalEvidenceRedacted"
require_file_contains "$APPROVAL_SOURCE" "credentialSecretReadApproved"
require_file_contains "$APPROVAL_SOURCE" "credentialSecretReadExecutedByThisIssue == false"
require_file_contains "$APPROVAL_SOURCE" "automaticSecretDiscoveryEnabled == false"
require_file_contains "$APPROVAL_SOURCE" "fallbackSecretProviderEnabled == false"
require_file_contains "$APPROVAL_SOURCE" "productionEndpointConnectionEnabled == false"
require_file_contains "$APPROVAL_SOURCE" "orderSubmitCancelReplaceEnabled == false"
require_file_contains "$APPROVAL_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$APPROVAL_DOC" "GH-1275"
require_file_contains "$APPROVAL_DOC" "GH-1276"
require_file_contains "$APPROVAL_DOC" "explicit Human operator approval"
require_file_contains "$APPROVAL_DOC" "redacted credential reference"
require_file_contains "$APPROVAL_DOC" "does not read secret value"
require_file_contains "$APPROVAL_DOC" "does not discover fallback secrets"
require_file_contains "$APPROVAL_DOC" "does not connect"
require_file_contains "$APPROVAL_DOC" "does not submit / cancel / replace"
require_file_contains "$READINESS" "Release v0.21.0 credential secret-read approval anchor"
require_file_contains "$PLAN" "GH-1275 Release v0.21.0 Credential Secret-read Approval"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL"
require_file_contains "$LATEST" "v0.21.0 credential secret-read approval"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-credential-secret-read-approval.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-credential-secret-read-approval.sh"
require_file_contains "$TESTS" "testGH1275ReleaseV0210CredentialSecretReadApprovalPath"

for file in "$APPROVAL_SOURCE" "$APPROVAL_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "credentialSecretReadExecutedByThisIssue=true"
  reject_file_contains "$file" "automaticSecretDiscoveryEnabled=true"
  reject_file_contains "$file" "fallbackSecretProviderEnabled=true"
  reject_file_contains "$file" "secretValueLogged=true"
  reject_file_contains "$file" "rawCredentialMaterialStored=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "signedAccountEndpointRuntimeEnabled=true"
  reject_file_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "orderSubmitCancelReplaceEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

echo "MTPRO release v0.21.0 credential secret-read approval verification passed."
