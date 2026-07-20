#!/usr/bin/env bash
set -euo pipefail

# GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT
# TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT
# V0210-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT
# V0210-004-CONSUMES-CREDENTIAL-APPROVAL
# V0210-004-REDACTED-ACCOUNT-STATUS-EVIDENCE
# V0210-004-NO-RAW-ACCOUNT-PAYLOAD
# V0210-004-NO-ORDER-ENDPOINT
# V0210-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 signed account read-only preflight guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 signed account read-only preflight guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

PREFLIGHT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight.swift"
PREFLIGHT_DOC="docs/contracts/release-v0.21.0-binance-spot-signed-account-readonly-preflight.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1276ReleaseV0210SignedAccountReadOnlyRuntimePreflight

for file in \
  "$PREFLIGHT_SOURCE" \
  "$PREFLIGHT_DOC" \
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
  require_file_contains "$file" "GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT"
  require_file_contains "$file" "TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT"
  require_file_contains "$file" "V0210-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT"
  require_file_contains "$file" "V0210-004-CONSUMES-CREDENTIAL-APPROVAL"
  require_file_contains "$file" "V0210-004-REDACTED-ACCOUNT-STATUS-EVIDENCE"
  require_file_contains "$file" "V0210-004-NO-RAW-ACCOUNT-PAYLOAD"
  require_file_contains "$file" "V0210-004-NO-ORDER-ENDPOINT"
  require_file_contains "$file" "V0210-004-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$PREFLIGHT_SOURCE" "ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight"
require_file_contains "$PREFLIGHT_SOURCE" "ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation"
require_file_contains "$PREFLIGHT_SOURCE" "GH-1276"
require_file_contains "$PREFLIGHT_SOURCE" "GH-1275"
require_file_contains "$PREFLIGHT_SOURCE" "GH-1277"
require_file_contains "$PREFLIGHT_SOURCE" "GH-1273..GH-1286"
require_file_contains "$PREFLIGHT_SOURCE" "ReleaseV0181TradingEnvironment.productionLive"
require_file_contains "$PREFLIGHT_SOURCE" "/api/v3/account"
require_file_contains "$PREFLIGHT_SOURCE" "credentialApprovalConsumed"
require_file_contains "$PREFLIGHT_SOURCE" "signedAccountReadOnlyPreflightEnabled"
require_file_contains "$PREFLIGHT_SOURCE" "redactedReadinessEvidenceCaptured"
require_file_contains "$PREFLIGHT_SOURCE" "rawAccountPayloadStored == false"
require_file_contains "$PREFLIGHT_SOURCE" "orderEndpointTouched == false"
require_file_contains "$PREFLIGHT_SOURCE" "submitCancelReplaceEnabled == false"
require_file_contains "$PREFLIGHT_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$PREFLIGHT_DOC" "GH-1276"
require_file_contains "$PREFLIGHT_DOC" "GH-1275"
require_file_contains "$PREFLIGHT_DOC" "GH-1277"
require_file_contains "$PREFLIGHT_DOC" "redacted account status evidence"
require_file_contains "$PREFLIGHT_DOC" "does not store raw account payload"
require_file_contains "$PREFLIGHT_DOC" "does not touch order endpoint"
require_file_contains "$PREFLIGHT_DOC" "does not submit / cancel / replace"
require_file_contains "$READINESS" "Release v0.21.0 signed account read-only preflight anchor"
require_file_contains "$PLAN" "GH-1276 Release v0.21.0 Signed Account Read-only Preflight"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT"
require_file_contains "$LATEST" "v0.21.0 signed account read-only preflight"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-signed-account-readonly-preflight.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-signed-account-readonly-preflight.sh"
require_file_contains "$TESTS" "testGH1276ReleaseV0210SignedAccountReadOnlyRuntimePreflight"

for file in "$PREFLIGHT_SOURCE" "$PREFLIGHT_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "credentialSecretValuePersisted=true"
  reject_file_contains "$file" "credentialSecretValueLogged=true"
  reject_file_contains "$file" "rawCredentialMaterialStored=true"
  reject_file_contains "$file" "rawAccountPayloadStored=true"
  reject_file_contains "$file" "orderEndpointTouched=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 signed account read-only preflight verification passed."
