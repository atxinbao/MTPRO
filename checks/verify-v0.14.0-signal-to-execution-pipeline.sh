#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "release v0.14.0 signal-to-execution pipeline verification failed: $*" >&2
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

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140SignalToExecutionPipeline.swift"
DOC="docs/contracts/release-v0.14.0-signal-to-execution-pipeline.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"
STRATEGY_REGISTRY="Sources/Trader/Strategies/StrategyRegistry.swift"

for anchor in \
  "GH-1037-SIGNAL-TO-EXECUTION-PIPELINE" \
  "GH-1037-STRATEGY-NO-DIRECT-EXECUTIONCLIENT" \
  "GH-1037-RISK-TO-RECONCILIATION-EVIDENCE" \
  "TVM-RELEASE-V0140-SIGNAL-EXECUTION-PIPELINE"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
done

for needle in \
  "public struct ReleaseV0140StrategySignalEnvelope" \
  "public struct ReleaseV0140SignalToExecutionPipeline" \
  "public struct ReleaseV0140SignalToExecutionPipelineReport" \
  "ReleaseV0140PreTradeRiskEngineGate" \
  "ExecutionContractRequestMapping" \
  "ReleaseV0140BinanceTestnetSubmitPath" \
  "ReleaseV0140OMSLocalOrderStore" \
  "ReleaseV0140OrderEventSourcingStream" \
  "ReleaseV0140OMSStateSyncEngine" \
  "ReleaseV0140ReconciliationEngine" \
  "adapterSubmitEvidenceCreated" \
  "networkSubmitAttempted" \
  "networkCancelReplaceAttempted" \
  "failedClosed"; do
  require_file_contains "$SOURCE" "$needle"
done

require_file_contains "$TESTS" "testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-signal-to-execution-pipeline.sh"

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

require_file_not_contains_regex "$STRATEGY_REGISTRY" "import ExecutionClient"
require_file_not_contains_regex "$STRATEGY_REGISTRY" "ExecutionClient\\."
require_file_not_contains_regex "$SOURCE" "adapterSubmitAttempted"

swift test --filter TargetGraphTests/testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal

echo "MTPRO release v0.14.0 signal-to-execution pipeline verification passed."
