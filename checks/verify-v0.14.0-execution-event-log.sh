#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140ExecutionEventLog.swift"
CONTRACT="docs/contracts/release-v0.14.0-execution-event-log.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-execution-event-log failed: $file must contain: $expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    echo "verify-v0.14.0-execution-event-log failed: $file must not contain: $forbidden" >&2
    exit 1
  fi
}

for required in \
  "public enum ReleaseV0140ExecutionEventLogEntryKind" \
  "public struct ReleaseV0140ExecutionEventLogEntry" \
  "public struct ReleaseV0140ExecutionEventLogReport" \
  "public struct ReleaseV0140ExecutionEventLog" \
  "ReleaseV0140SignalToExecutionPipelineReport" \
  "sourceOrderEventStreamID" \
  "sourceReconciliationReportID" \
  "redactedEvidenceOnly" \
  "independentlyInspectable" \
  "productionSubmitCancelReplace"; do
  require_file_contains "$SOURCE" "$required"
done

for anchor in \
  "GH-1040-EXECUTION-EVENT-LOG" \
  "GH-1040-RUN-ORDER-INTENT-LINKAGE" \
  "GH-1040-REDACTED-READONLY-SURFACE" \
  "TVM-RELEASE-V0140-EXECUTION-EVENT-LOG"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

require_file_contains "$TESTS" "testGH1040ReleaseV0140ExecutionEventLogLinksRunOrderIntentAndReconciliationEvidence"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.0-execution-event-log.sh"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "CryptoKit" \
  "HMAC" \
  "API_KEY" \
  "SECRET" \
  "signature" \
  "listenKey" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com"; do
  require_file_absent "$SOURCE" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1040ReleaseV0140ExecutionEventLogLinksRunOrderIntentAndReconciliationEvidence

echo "MTPRO release v0.14.0 execution event log verification passed."
