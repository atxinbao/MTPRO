#!/usr/bin/env bash
set -euo pipefail

# GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR
# TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR
# V0180-009-DEPENDENCIES-GH1177-GH1181-GH1183-DONE
# V0180-009-VENUE-PRODUCT-ENVIRONMENT-SCOPE
# V0180-009-BINANCE-SPOT-TO-OKX-SWAP-REUSE-REJECTED
# V0180-009-BINANCE-SPOT-TO-USDM-FUTURES-REUSE-REJECTED
# V0180-009-WRONG-ENVIRONMENT-REUSE-REJECTED
# V0180-009-CROSS-PRODUCT-EVIDENCE-REUSE-FAILS-CLOSED
# V0180-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.18.0 beta safety profile drift detector guard failed: %s\n' "$1" >&2
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
    printf 'release v0.18.0 beta safety profile drift detector guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170BetaSafetyPolicyProfileEvidence.swift"
CONTRACT="docs/contracts/release-v0.18.0-beta-safety-profile-drift-detector-contract.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
READINESS_DOC="docs/automation/automation-readiness.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
RELEASE_POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
VERIFIER="checks/verify-v0.18.0-beta-safety-profile-drift-detector.sh"

swift test --filter TargetGraphTests/testGH1184BetaSafetyProfileDriftDetectorRejectsCrossVenueProductReuse

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$READINESS_DOC" \
  "$VALIDATION_PLAN" \
  "$TRADING_MATRIX" \
  "$RELEASE_POLICY" \
  "$TESTS" \
  "$VERIFIER"; do
  for anchor in \
    "GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR" \
    "TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR" \
    "V0180-009-DEPENDENCIES-GH1177-GH1181-GH1183-DONE" \
    "V0180-009-VENUE-PRODUCT-ENVIRONMENT-SCOPE" \
    "V0180-009-BINANCE-SPOT-TO-OKX-SWAP-REUSE-REJECTED" \
    "V0180-009-BINANCE-SPOT-TO-USDM-FUTURES-REUSE-REJECTED" \
    "V0180-009-WRONG-ENVIRONMENT-REUSE-REJECTED" \
    "V0180-009-CROSS-PRODUCT-EVIDENCE-REUSE-FAILS-CLOSED" \
    "V0180-009-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

require_file_contains "$SOURCE" "ReleaseV0180BetaSafetyProfileDriftDetector"
require_file_contains "$SOURCE" "venueProductEnvironmentScopeRecorded=true"
require_file_contains "$SOURCE" "binanceSpotToOKXSwapReuseRejected=true"
require_file_contains "$SOURCE" "binanceSpotToUSDMFuturesReuseRejected=true"
require_file_contains "$SOURCE" "wrongEnvironmentReuseRejected=true"
require_file_contains "$SOURCE" "crossProductEvidenceReuseFailsClosed=true"
require_file_contains "$TESTS" "testGH1184BetaSafetyProfileDriftDetectorRejectsCrossVenueProductReuse"
require_file_contains "$TESTS" "OKX"
require_file_contains "$TESTS" "usdmFutures"
require_file_contains "$TESTS" "unsupported-expected-venue-product"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-beta-safety-profile-drift-detector.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-beta-safety-profile-drift-detector.sh"
require_file_contains "$READINESS_DOC" "Release v0.18.0 beta safety profile drift detector anchor"
require_file_contains "$VALIDATION_PLAN" "GH-1184 Release v0.18.0 Beta Safety Profile Drift Detector"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR"
require_file_contains "$RELEASE_POLICY" "GH-1184 adds beta safety profile drift detection"
require_file_contains "$CONTRACT" "#1184 / GH-1184"
require_file_contains "$CONTRACT" "#1177 closed / done"
require_file_contains "$CONTRACT" "#1181 closed / done"
require_file_contains "$CONTRACT" "#1183 closed / done"
require_file_contains "$CONTRACT" "Binance Spot evidence"
require_file_contains "$CONTRACT" "OKX Swap"
require_file_contains "$CONTRACT" "Binance USDⓈ-M Futures"

for file in "$SOURCE" "$CONTRACT" "$VERIFIER" "$READINESS_DOC" "$VALIDATION_PLAN" "$TRADING_MATRIX" "$RELEASE_POLICY"; do
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
done

printf 'MTPRO release v0.18.0 beta safety profile drift detector verification passed.\n'
