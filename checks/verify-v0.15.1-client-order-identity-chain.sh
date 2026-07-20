#!/usr/bin/env bash
set -euo pipefail

# GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN
# TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN
# V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID
# V0151-006-REDACTED-CLIENT-ORDER-REFERENCE
# V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF
# V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED
# V0151-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 client order identity chain guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 client order identity chain guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

BUILDER="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift"
SUBMIT="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift"
CANCEL="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift"
TRANSPORT="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift"
CLI_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"

for anchor in \
  "GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN" \
  "TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN" \
  "V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID" \
  "V0151-006-REDACTED-CLIENT-ORDER-REFERENCE" \
  "V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF" \
  "V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED" \
  "V0151-006-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$BUILDER" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$README" "$anchor"
  require_file_contains "$GOAL" "$anchor"
  require_file_contains "$BLUEPRINT" "$anchor"
  require_file_contains "$ROADMAP" "$anchor"
done

for required in \
  "ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference" \
  "ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial" \
  "deterministicNewClientOrderID" \
  "newClientOrderId=<redacted>" \
  "binanceUnsignedQueryStringForTransport" \
  "binanceSignedQueryStringForTransport" \
  "clientOrderIdentityMaterialStored == false"; do
  require_file_contains "$BUILDER" "$required"
  require_file_contains "$0" "$required"
done

require_file_contains "$SUBMIT" "clientOrderIdentityReferenceID"
require_file_contains "$SUBMIT" "redactedClientOrderIDHash"
require_file_contains "$SUBMIT" "clientOrderIdentityMaterialStored == false"
require_file_contains "$CANCEL" "derivedFromSubmitEvidence"
require_file_contains "$CANCEL" "sourceSubmitSignedRequestID"
require_file_contains "$CANCEL" "originalClientOrderID"
require_file_contains "$CANCEL" "<redacted-mismatch>"
require_file_contains "$TRANSPORT" "binanceSignedQueryStringForTransport"
require_file_contains "$CLI_FLOW" "ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial.derivedFromSubmitEvidence"
require_file_contains "$CLI_FLOW" "<redacted-mismatch>"
require_file_contains "$TESTS" "testGH1099ReleaseV0151ClientOrderIdentityChainDerivesCancelIdentityFromSubmitEvidence"
require_file_contains "$TESTS" "gh-1099-untracked-raw-order-id"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-client-order-identity-chain.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-client-order-identity-chain.sh"

require_file_contains "$README" "#1099 deterministic client order identity chain closed / done"
require_file_contains "$GOAL" "#1099 deterministic client order identity chain closed / done"
require_file_contains "$LATEST" "#1099 deterministic client order identity chain is closed / done"
require_file_contains "$BLUEPRINT" "deterministic client order identity chain"
require_file_contains "$ROADMAP" "deterministic client order identity"
require_file_absent "$README" "current issue \`#1098\`"
require_file_absent "$GOAL" "#1098 runtime internal gate is current WIP=1"
require_file_absent "$README" "current issue \`#1099\`"
require_file_absent "$GOAL" "#1099 deterministic client order identity chain is current WIP=1"

swift test --filter TargetGraphTests/testGH1099ReleaseV0151ClientOrderIdentityChainDerivesCancelIdentityFromSubmitEvidence

echo "MTPRO release v0.15.1 client order identity chain verification passed."
