#!/usr/bin/env bash
set -euo pipefail

# GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT
# TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT
# V0151-007-CODABLE-DECODE-VALIDATION
# V0151-007-CORRUPTED-JSON-FAILS-CLOSED
# V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED
# V0151-007-PRODUCTION-HOST-MUTATION-REJECTED
# V0151-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 codable decode closeout guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 codable decode closeout guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

DECODE_HELPER="Sources/ExecutionClient/FutureGate/ReleaseV0151CodableDecodeBoundary.swift"
SIGNED_REQUEST="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift"
SUBMIT="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift"
CANCEL="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift"
CANCEL_REPLACE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift"
EVENT_LOG="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift"
RECONCILIATION="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetOMSStateReconciliation.swift"
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
AUDIT="docs/audit/mtpro-release-v0.15.1-real-testnet-execution-hardening-patch-stage-code-audit.md"

for anchor in \
  "GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT" \
  "TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT" \
  "V0151-007-CODABLE-DECODE-VALIDATION" \
  "V0151-007-CORRUPTED-JSON-FAILS-CLOSED" \
  "V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED" \
  "V0151-007-PRODUCTION-HOST-MUTATION-REJECTED" \
  "V0151-007-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$DECODE_HELPER" "$anchor"
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
  require_file_contains "$AUDIT" "$anchor"
done

for source in "$SIGNED_REQUEST" "$SUBMIT" "$CANCEL" "$CANCEL_REPLACE" "$EVENT_LOG" "$RECONCILIATION"; do
  require_file_contains "$source" "public init(from decoder: Decoder) throws"
  require_file_contains "$source" "ReleaseV0151CodableDecodeBoundary.requireHeld"
done

require_file_contains "$EVENT_LOG" "Self.canonicalChecksum"
require_file_contains "$EVENT_LOG" "Self.validateAppendOnlyChain"
require_file_contains "$RECONCILIATION" "snapshotEventCoverage"
require_file_contains "$TESTS" "testGH1100ReleaseV0151CodableDecodeValidationFailsClosedOnMutatedArtifacts"
require_file_contains "$TESTS" "production host mutation must fail closed"
require_file_contains "$TESTS" "checksum mismatch must fail closed"
require_file_contains "$TESTS" "corrupted JSON artifact must fail closed"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-codable-decode-closeout.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-codable-decode-closeout.sh"

require_file_contains "$README" "#1100 codable decode closeout closed / done"
require_file_contains "$GOAL" "#1100 codable decode closeout closed / done"
require_file_contains "$LATEST" "v0.15.1 codable decode closeout"
require_file_contains "$AUDIT" "Release v0.15.1 Real Testnet Execution Hardening Patch"
require_file_absent "$README" "current issue \`#1099\`"
require_file_absent "$GOAL" "#1099 deterministic client order identity chain is current WIP=1"
require_file_absent "$README" "#1100 remains backlog"
require_file_absent "$GOAL" "#1100 remains backlog"

swift test --filter TargetGraphTests/testGH1100ReleaseV0151CodableDecodeValidationFailsClosedOnMutatedArtifacts

echo "MTPRO release v0.15.1 Codable decode closeout verification passed."
