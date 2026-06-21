#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140OrderEventSourcing.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.14.0-order-event-sourcing.md"
RUNNER="checks/run.sh"

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-order-event-sourcing failed: $file must contain: $expected" >&2
    exit 1
  fi
}

for anchor in \
  "GH-1032-ORDER-EVENT-SOURCING" \
  "GH-1032-APPEND-ONLY-REPLAY" \
  "GH-1032-CORRELATION-CAUSATION-EVIDENCE" \
  "TVM-RELEASE-V0140-ORDER-EVENT-SOURCING"
do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

require_file_contains "$TESTS" "testGH1032ReleaseV0140OrderEventSourcingAppendsAndReplaysCorrelatedLifecycleEvidence"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-order-event-sourcing.sh"

if grep -Eq "URLSession|URLRequest|CryptoKit|HMAC|API_KEY|SECRET|signature|listenKey|api\\.binance\\.com|fapi\\.binance\\.com|dapi\\.binance\\.com" "$SOURCE"; then
  echo "verify-v0.14.0-order-event-sourcing failed: source must not implement network, signing, credential, listenKey, or production host paths" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1032ReleaseV0140OrderEventSourcingAppendsAndReplaysCorrelatedLifecycleEvidence

echo "MTPRO release v0.14.0 order event sourcing verification passed."
