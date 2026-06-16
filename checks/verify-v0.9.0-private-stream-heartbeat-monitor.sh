#!/usr/bin/env bash
set -euo pipefail

# GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS
# TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 private stream heartbeat monitor verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 private stream heartbeat monitor verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"

swift test --filter TargetGraphTests/testGH847PrivateStreamHeartbeatMonitorPersistsStalenessAndRedactedEvidence

require_file_contains "$SOURCE" "ReleaseV090PrivateStreamHeartbeatDocument"
require_file_contains "$SOURCE" "ReleaseV090PrivateStreamHeartbeatStatus"
require_file_contains "$SOURCE" "ReleaseV090PrivateStreamListenKeyAgeBucket"
require_file_contains "$SOURCE" "recordPrivateStreamHeartbeat"
require_file_contains "$SOURCE" "privateStreamHeartbeat"
require_file_contains "$SOURCE" "private-stream-heartbeat.json"
require_file_contains "$SOURCE" "lastEventObservedAt"
require_file_contains "$SOURCE" "heartbeatRecordedAt"
require_file_contains "$SOURCE" "heartbeatIntervalSeconds"
require_file_contains "$SOURCE" "staleThresholdSeconds"
require_file_contains "$SOURCE" "listenKeyExpiresAt"
require_file_contains "$SOURCE" "heartbeatStatus"
require_file_contains "$SOURCE" "streamStale"
require_file_contains "$SOURCE" "streamRecovered"
require_file_contains "$SOURCE" "redactedListenKeyReference"
require_file_contains "$SOURCE" "listenKeyReferenceHash"
require_file_contains "$SOURCE" "rawListenKeyPersisted"
require_file_contains "$SOURCE" "rawPrivatePayloadPersisted"
require_file_contains "$SOURCE" "credentialValuePersisted"
require_file_contains "$SOURCE" "corruptedPrivateStreamHeartbeat"
require_file_contains "$SOURCE" "unsafeListenKeyReference"
require_file_contains "$SOURCE" "GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS"
require_file_contains "$SOURCE" "V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS"
require_file_contains "$SOURCE" "V090-005-PRIVATE-STREAM-HEARTBEAT-JSON"
require_file_contains "$SOURCE" "V090-005-REDACTED-LISTENKEY-REFERENCE"
require_file_contains "$SOURCE" "V090-005-NO-RAW-PRIVATE-PAYLOAD-PERSISTENCE"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh"
require_file_contains "docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md" "V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.9.0 private stream heartbeat staleness monitor anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-847 Release v0.9.0 Private Stream Heartbeat Staleness Monitor Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS"
require_file_contains "checks/automation-readiness.sh" "GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH847PrivateStreamHeartbeatMonitorPersistsStalenessAndRedactedEvidence"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "productionBrokerConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"
reject_file_contains "$SOURCE" "testnetCancelReplaceAllowed=true"

echo "MTPRO release v0.9.0 private stream heartbeat staleness monitor verification passed."
