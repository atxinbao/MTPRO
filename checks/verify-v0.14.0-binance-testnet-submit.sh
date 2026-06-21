#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-binance-testnet-submit failed: $file must contain: $expected" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140BinanceTestnetSubmitPath.swift"
DOC="docs/contracts/release-v0.14.0-binance-testnet-submit-path.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetSubmitOperatorGate"
require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetSubmitRequestEvidence"
require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetSubmitResponseEvidence"
require_file_contains "$SOURCE" "public struct ReleaseV0140BinanceTestnetSubmitPath"
require_file_contains "$SOURCE" "networkSubmitPerformed: Bool = false"
require_file_contains "$SOURCE" "cancelReplaceIncluded: Bool = false"
require_file_contains "$SOURCE" "GH-1029-BINANCE-TESTNET-SUBMIT-PATH"
require_file_contains "$SOURCE" "GH-1029-BINANCE-TESTNET-OPERATOR-GATE"
require_file_contains "$SOURCE" "GH-1029-BINANCE-TESTNET-REDACTED-REQUEST-RESPONSE"
require_file_contains "$DOC" "GH-1029-BINANCE-TESTNET-SUBMIT-PATH"
require_file_contains "$DOC" "GH-1029-BINANCE-TESTNET-OPERATOR-GATE"
require_file_contains "$DOC" "GH-1029-BINANCE-TESTNET-REDACTED-REQUEST-RESPONSE"
require_file_contains "$TESTS" "testGH1029ReleaseV0140BinanceTestnetSubmitPathIsOperatorGatedAndRedacted"
require_file_contains "checks/run.sh" "bash checks/verify-v0.14.0-binance-testnet-submit.sh"

if grep -Eq "URLSession|URLRequest|CryptoKit|HMAC|API_KEY|SECRET|signature|listenKey|api\\.binance\\.com|fapi\\.binance\\.com|dapi\\.binance\\.com" "$SOURCE"; then
  echo "verify-v0.14.0-binance-testnet-submit failed: submit source must not implement network client, signing, credential storage, listenKey, or production hosts" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1029ReleaseV0140BinanceTestnetSubmitPathIsOperatorGatedAndRedacted

echo "MTPRO release v0.14.0 Binance testnet submit verification passed."
