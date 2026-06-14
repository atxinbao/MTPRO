#!/usr/bin/env bash
set -euo pipefail

# GH-780-VERIFY-V070-TESTNET-ENDPOINT-POLICY
# TVM-RELEASE-V070-TESTNET-ENDPOINT-POLICY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 testnet endpoint policy verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_contains \
  "Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift" \
  "BinanceSignedAccountReadEndpointPolicy"
require_file_contains \
  "Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift" \
  "canonicalTestnetBaseURL"
require_file_contains \
  "Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift" \
  "validateTransportURL(url, expectedPath: Self.accountReadOnlyPath)"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "testGH780BinanceSignedAccountReadConfigurationRejectsNonCanonicalTestnetBaseURLs"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "testGH780BinanceSignedAccountReadTransportRejectsURLPathDrift"
require_file_contains \
  "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-TESTNET-ENDPOINT-POLICY"
require_file_contains \
  "docs/validation/validation-plan.md" \
  "GH-780 Release v0.7.0 Testnet Endpoint Policy Validation"
require_file_contains \
  "docs/automation/automation-readiness.md" \
  "Release v0.7.0 testnet endpoint policy anchor"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.7.0-testnet-endpoint-policy.sh"

swift test --filter TargetGraphTests/testGH780BinanceSignedAccountReadConfigurationRejectsNonCanonicalTestnetBaseURLs
swift test --filter TargetGraphTests/testGH780BinanceSignedAccountReadTransportRejectsURLPathDrift

echo "MTPRO release v0.7.0 testnet endpoint policy verification passed."
