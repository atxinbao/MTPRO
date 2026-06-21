#!/usr/bin/env bash
set -euo pipefail

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140OMSStateSyncEngine.swift"
CONTRACT="docs/contracts/release-v0.14.0-oms-state-sync-engine.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

require_file_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq "$pattern" "$file"; then
    echo "Missing required pattern in $file: $pattern" >&2
    exit 1
  fi
}

for anchor in \
  "GH-1033-OMS-STATE-SYNC-ENGINE" \
  "GH-1033-STATE-DERIVED-FROM-EVENTS" \
  "GH-1033-FAIL-CLOSED-MISSING-EVENTS" \
  "TVM-RELEASE-V0140-OMS-STATE-SYNC"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

require_file_contains "$SOURCE" "ReleaseV0140OMSStateSyncEngine"
require_file_contains "$SOURCE" "ReleaseV0140OrderEventSourcingStream.replay"
require_file_contains "$SOURCE" "projection drift from source events"
require_file_contains "$SOURCE" "empty event stream"
require_file_contains "$CONTRACT" "state sync 的唯一来源"
require_file_contains "$TESTS" "testGH1033ReleaseV0140OMSStateSyncEngineDerivesCurrentStateFromEvents"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-oms-state-sync-engine.sh"

if grep -E "URLSession|URLRequest|CryptoKit|HMAC|API_KEY|SECRET|signature|listenKey|api\\.binance\\.com|fapi\\.binance\\.com|dapi\\.binance\\.com" "$SOURCE" >/dev/null; then
  echo "Forbidden production/network/credential surface found in $SOURCE" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1033ReleaseV0140OMSStateSyncEngineDerivesCurrentStateFromEvents

echo "MTPRO release v0.14.0 OMS state sync engine verification passed."
