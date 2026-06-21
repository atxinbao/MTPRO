#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "release v0.14.0 full E2E testnet suite verification failed: $*" >&2
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

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FullE2ETestnetSuite.swift"
DOC="docs/contracts/release-v0.14.0-full-e2e-testnet-suite.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

for anchor in \
  "GH-1038-FULL-E2E-TESTNET-SUITE" \
  "GH-1038-SPOT-PERP-EMA-RSI-MATRIX" \
  "GH-1038-PRODUCTION-GUARDS" \
  "TVM-RELEASE-V0140-FULL-E2E-TESTNET-SUITE"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
done

for needle in \
  "public struct ReleaseV0140FullE2ETestnetSuite" \
  "public struct ReleaseV0140FullE2ETestnetSuiteReport" \
  "public struct ReleaseV0140FullE2ETestnetSuiteMatrixCase" \
  "ReleaseV0140SignalToExecutionPipeline" \
  "ReleaseV0140PreTradeRiskEngineGate" \
  "requiredMatrixCaseCount = 4" \
  "requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]" \
  "requiredStrategies: [OrderIntentStrategyKind] = [.ema, .rsi]" \
  "productionTradingRequested: true" \
  "productionGuardStoppedBeforeAdapter"; do
  require_file_contains "$SOURCE" "$needle"
done

require_file_contains "$TESTS" "testGH1038ReleaseV0140FullE2ETestnetSuiteCoversSpotPerpEMAAndRSIWithProductionGuard"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-full-e2e-testnet-suite.sh"

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

swift test --filter TargetGraphTests/testGH1038ReleaseV0140FullE2ETestnetSuiteCoversSpotPerpEMAAndRSIWithProductionGuard

echo "MTPRO release v0.14.0 full E2E testnet suite verification passed."
