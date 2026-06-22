#!/usr/bin/env bash
set -euo pipefail

# GH-1060-VERIFY-V0141-CODABLE-DECODE-VALIDATION
# TVM-RELEASE-V0141-CODABLE-DECODE-VALIDATION
# V0141-002-CODABLE-DECODE-VALIDATION
# V0141-002-BOUNDARYHELD-COMPUTED
# V0141-002-CORRUPTED-JSON-FAILS-CLOSED
# V0141-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.14.1 Codable decode validation guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.14.1 Codable decode validation guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

DASHBOARD_SOURCE="Sources/Dashboard/Report/ReleaseV0140ReadOnlyExecutionDashboardSurface.swift"
SUBMIT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140BinanceTestnetSubmitPath.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"

for anchor in \
  "GH-1060-VERIFY-V0141-CODABLE-DECODE-VALIDATION" \
  "TVM-RELEASE-V0141-CODABLE-DECODE-VALIDATION" \
  "V0141-002-CODABLE-DECODE-VALIDATION" \
  "V0141-002-BOUNDARYHELD-COMPUTED" \
  "V0141-002-CORRUPTED-JSON-FAILS-CLOSED" \
  "V0141-002-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

require_file_contains "$DASHBOARD_SOURCE" "public var boundaryHeld: Bool"
require_file_contains "$DASHBOARD_SOURCE" "decodeIfPresent(Bool.self, forKey: .boundaryHeld)"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel decode validation failed"
require_file_contains "$SUBMIT_SOURCE" "releaseV0140BinanceTestnetSubmit.requestEvidence.decode"
require_file_contains "$SUBMIT_SOURCE" "releaseV0140BinanceTestnetSubmit.responseEvidence.decode"
require_file_contains "$SUBMIT_SOURCE" "releaseV0140BinanceTestnetSubmit.path.decode"
require_file_contains "$TARGET_TESTS" "testGH1060ReleaseV0141CodableDecodeValidationRejectsCorruptedV0140Evidence"
require_file_contains "$TARGET_TESTS" "networkSubmitPerformed"
require_file_contains "$TARGET_TESTS" "boundaryHeld"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.1-codable-decode-validation.sh"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "productionSubmitCancelReplace=true" \
  "productionCutoverAuthorized=true" \
  "swift run mtpro submit" \
  "swift run mtpro cancel" \
  "swift run mtpro replace"; do
  reject_file_contains "$DASHBOARD_SOURCE" "$forbidden"
  reject_file_contains "$SUBMIT_SOURCE" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$PLAN" "$forbidden"
  reject_file_contains "$MATRIX" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1060ReleaseV0141CodableDecodeValidationRejectsCorruptedV0140Evidence

echo "MTPRO release v0.14.1 Codable decode validation verification passed."
