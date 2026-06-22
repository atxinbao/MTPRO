#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "release v0.14.0 failure simulation suite verification failed: $*" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  grep -Fq "$needle" "$file" || fail "$file missing: $needle"
}

require_file_not_contains_regex() {
  local file="$1"
  local pattern="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  if grep -Eq "$pattern" "$file"; then
    fail "$file contains forbidden pattern: $pattern"
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FailureSimulationSuite.swift"
DOC="docs/contracts/release-v0.14.0-failure-simulation-suite.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

for anchor in \
  "GH-1039-FAILURE-SIMULATION-SUITE" \
  "GH-1039-FAIL-CLOSED-AUDIT-EVIDENCE" \
  "GH-1039-NO-PRODUCTION-FALLBACK" \
  "TVM-RELEASE-V0140-FAILURE-SIMULATION-SUITE"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
done

for needle in \
  "public enum ReleaseV0140FailureSimulationMode" \
  "case adapterRejection" \
  "case riskRejection" \
  "case invalidTransition" \
  "case reconciliationMismatch" \
  "case timeout" \
  "case killSwitch" \
  "public struct ReleaseV0140FailureSimulationEvidence" \
  "public struct ReleaseV0140FailureSimulationSuiteReport" \
  "public struct ReleaseV0140FailureSimulationSuite" \
  "requiredModeCount = 6" \
  "fallbackToProductionEndpoint" \
  "ReleaseV0140ReconciliationEngine" \
  "OrderLifecycleTransition" \
  "adapterSubmitEvidenceCreated" \
  "networkSubmitAttempted" \
  "networkCancelReplaceAttempted" \
  "networkSubmitAllowed: true" \
  "killSwitchActive: true"; do
  require_file_contains "$SOURCE" "$needle"
done

require_file_contains "$TESTS" "testGH1039ReleaseV0140FailureSimulationSuiteCoversSixFailClosedModes"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-failure-simulation-suite.sh"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "CryptoKit" \
  "HMAC" \
  "API_KEY" \
  "SECRET" \
  "signature" \
  "listenKey" \
  "api\\.binance\\.com" \
  "fapi\\.binance\\.com" \
  "dapi\\.binance\\.com"; do
  require_file_not_contains_regex "$SOURCE" "$forbidden"
done
require_file_not_contains_regex "$SOURCE" "adapterSubmitAttempted"

swift test --filter TargetGraphTests/testGH1039ReleaseV0140FailureSimulationSuiteCoversSixFailClosedModes

echo "MTPRO release v0.14.0 failure simulation suite verification passed."
