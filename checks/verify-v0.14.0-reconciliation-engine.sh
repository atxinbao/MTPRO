#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "release v0.14.0 reconciliation engine verification failed: $*" >&2
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

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140ReconciliationEngine.swift"
DOC="docs/contracts/release-v0.14.0-reconciliation-engine.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

for anchor in \
  "GH-1036-RECONCILIATION-ENGINE" \
  "GH-1036-MISMATCH-FAILURE-SURFACE" \
  "GH-1036-TESTNET-DRYRUN-SCOPED" \
  "TVM-RELEASE-V0140-RECONCILIATION-ENGINE"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
done

for needle in \
  "public struct ReleaseV0140ReconciliationEngine" \
  "public struct ReleaseV0140TestnetExecutionObservation" \
  "public struct ReleaseV0140ReconciliationReport" \
  "ReleaseV0140OMSStateSyncSnapshot" \
  "ReleaseV0140OrderEventSourcingStream" \
  "mismatchesFailClosed" \
  "evidenceCoverageComplete" \
  "observationCoverageMismatch"; do
  require_file_contains "$SOURCE" "$needle"
done

require_file_contains "$TESTS" "testGH1036ReleaseV0140ReconciliationEngineSurfacesMismatchesAsFailures"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-reconciliation-engine.sh"

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

swift test --filter TargetGraphTests/testGH1036ReleaseV0140ReconciliationEngineSurfacesMismatchesAsFailures

echo "MTPRO release v0.14.0 reconciliation engine verification passed."
