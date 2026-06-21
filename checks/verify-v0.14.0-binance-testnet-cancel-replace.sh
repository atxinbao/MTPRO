#!/usr/bin/env bash
set -euo pipefail

# GH-1030-BINANCE-TESTNET-CANCEL-REPLACE-PATH
# GH-1030-LOCAL-OMS-ORDER-IDENTITY-REQUIRED
# GH-1030-TESTNET-ADAPTER-APPROVAL-REDACTED
# TVM-RELEASE-V0140-BINANCE-TESTNET-CANCEL-REPLACE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.14.0 Binance testnet cancel / replace verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -E "$forbidden" "$file" || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.14.0 Binance testnet cancel / replace verification failed: %s must not contain pattern: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140BinanceTestnetCancelReplacePath.swift"
DOC="docs/contracts/release-v0.14.0-binance-testnet-cancel-replace-path.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

for anchor in \
  "GH-1030-BINANCE-TESTNET-CANCEL-REPLACE-PATH" \
  "GH-1030-LOCAL-OMS-ORDER-IDENTITY-REQUIRED" \
  "GH-1030-TESTNET-ADAPTER-APPROVAL-REDACTED" \
  "TVM-RELEASE-V0140-BINANCE-TESTNET-CANCEL-REPLACE"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
  require_file_contains "$0" "$anchor"
done

for required in \
  "ReleaseV0140LocalOMSOrderIdentity" \
  "ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval" \
  "ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence" \
  "ReleaseV0140BinanceTestnetCancelReplaceActionEvidence" \
  "ReleaseV0140BinanceTestnetCancelReplacePath" \
  "ExecutionContractCancel" \
  "ExecutionContractReplace" \
  "existingLocalOMSOrderIdentityRequired" \
  "testnetCancelReplaceEvidenceOnly" \
  "networkCancelReplacePerformed" \
  "productionTradingEnabledByDefault"; do
  require_file_contains "$SOURCE" "$required"
done

require_file_contains "$TESTS" "testGH1030ReleaseV0140BinanceTestnetCancelReplaceRequiresLocalOMSIdentity"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-binance-testnet-cancel-replace.sh"

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
  reject_file_contains "$SOURCE" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1030ReleaseV0140BinanceTestnetCancelReplaceRequiresLocalOMSIdentity

echo "MTPRO release v0.14.0 Binance testnet cancel / replace verification passed."
