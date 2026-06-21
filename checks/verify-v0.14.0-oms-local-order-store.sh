#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140OMSLocalOrderStore.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.14.0-oms-local-order-store.md"
RUNNER="checks/run.sh"

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-oms-local-order-store failed: $file must contain: $expected" >&2
    exit 1
  fi
}

for anchor in \
  "GH-1031-OMS-LOCAL-ORDER-STORE" \
  "GH-1031-OMS-APPEND-UPDATE-REPLAY" \
  "GH-1031-OMS-NO-REAL-ACCOUNT-OR-PRODUCTION-POSITION" \
  "TVM-RELEASE-V0140-OMS-LOCAL-ORDER-STORE"
do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

require_file_contains "$TESTS" "testGH1031ReleaseV0140OMSLocalOrderStoreAppendsUpdatesAndReplaysLifecycleEvidence"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-oms-local-order-store.sh"

if grep -Eq "URLSession|URLRequest|CryptoKit|HMAC|API_KEY|SECRET|signature|listenKey|api\\.binance\\.com|fapi\\.binance\\.com|dapi\\.binance\\.com" "$SOURCE"; then
  echo "verify-v0.14.0-oms-local-order-store failed: store source must not implement network, signing, credential, listenKey, or production host paths" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1031ReleaseV0140OMSLocalOrderStoreAppendsUpdatesAndReplaysLifecycleEvidence

echo "MTPRO release v0.14.0 OMS local order store verification passed."
