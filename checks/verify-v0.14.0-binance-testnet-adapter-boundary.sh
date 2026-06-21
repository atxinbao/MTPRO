#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-binance-testnet-adapter-boundary failed: $file must contain: $expected" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140BinanceTestnetAdapterBoundary.swift"
DOC="docs/contracts/release-v0.14.0-binance-testnet-adapter-boundary.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetEndpointReference"
require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetAdapterBoundary"
require_file_contains "$SOURCE" "networkSubmitAllowed: Bool = false"
require_file_contains "$SOURCE" "networkCancelReplaceAllowed: Bool = false"
require_file_contains "$SOURCE" "GH-1028-BINANCE-TESTNET-ADAPTER-BOUNDARY"
require_file_contains "$SOURCE" "GH-1028-BINANCE-TESTNET-ENDPOINT-POLICY"
require_file_contains "$SOURCE" "GH-1028-BINANCE-TESTNET-NO-NETWORK-SUBMIT"
require_file_contains "$DOC" "GH-1028-BINANCE-TESTNET-ADAPTER-BOUNDARY"
require_file_contains "$DOC" "GH-1028-BINANCE-TESTNET-ENDPOINT-POLICY"
require_file_contains "$DOC" "GH-1028-BINANCE-TESTNET-NO-NETWORK-SUBMIT"
require_file_contains "$TESTS" "testGH1028ReleaseV0140BinanceTestnetAdapterBoundaryRejectsProductionAndNetworkSubmit"
require_file_contains "checks/run.sh" "bash checks/verify-v0.14.0-binance-testnet-adapter-boundary.sh"

if grep -Eq "URLSession|URLRequest|func submit|func cancel|func replace" "$SOURCE"; then
  echo "verify-v0.14.0-binance-testnet-adapter-boundary failed: boundary source must not implement network request or submit/cancel/replace methods" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1028ReleaseV0140BinanceTestnetAdapterBoundaryRejectsProductionAndNetworkSubmit

echo "MTPRO release v0.14.0 Binance testnet adapter boundary verification passed."
