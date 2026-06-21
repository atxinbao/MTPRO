#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-pretrade-risk-engine-gate failed: $file must contain: $expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Eq "$forbidden" "$file"; then
    echo "verify-v0.14.0-pretrade-risk-engine-gate failed: $file must not contain pattern: $forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/RiskEngine/LiveGate/ReleaseV0140PreTradeRiskEngineGate.swift"
DOC="docs/contracts/release-v0.14.0-pretrade-risk-engine-gate.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$SOURCE" "ReleaseV0140PreTradeRiskEngineGate"
require_file_contains "$SOURCE" "adapterSubmitEligible"
require_file_contains "$SOURCE" "rejectedIntentReachedAdapterSubmit"
require_file_contains "$SOURCE" "executionSubmitAlreadyAttempted"
require_file_contains "$SOURCE" "GH-1034-PRETRADE-RISKENGINE-GATE"
require_file_contains "$SOURCE" "GH-1034-REJECTED-INTENT-NO-ADAPTER-SUBMIT"
require_file_contains "$DOC" "GH-1034-PRETRADE-RISKENGINE-GATE"
require_file_contains "$DOC" 'rejected` / `blocked` decision 必须保持 `adapterSubmitEligible == false`'
require_file_contains "$TESTS" "testGH1034ReleaseV0140PreTradeRiskEngineGateBlocksRejectedIntentsBeforeSubmit"
require_file_contains "checks/run.sh" "bash checks/verify-v0.14.0-pretrade-risk-engine-gate.sh"

require_file_absent "$SOURCE" "URLSession|URLRequest|CryptoKit|HMAC|API_KEY|SECRET|signature|listenKey|api\\.binance\\.com|fapi\\.binance\\.com|dapi\\.binance\\.com"

swift test --filter TargetGraphTests/testGH1034ReleaseV0140PreTradeRiskEngineGateBlocksRejectedIntentsBeforeSubmit

echo "MTPRO release v0.14.0 pre-trade RiskEngine gate verification passed."
