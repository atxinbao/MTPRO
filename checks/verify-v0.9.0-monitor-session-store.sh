#!/usr/bin/env bash
set -euo pipefail

# GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE
# TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 monitor session store verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 monitor session store verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"

swift test --filter TargetGraphTests/testGH845TestnetReadOnlyMonitorSessionStorePersistsArtifactsAndFailsClosed

require_file_contains "$SOURCE" "ReleaseV090TestnetReadOnlyMonitorSessionStore"
require_file_contains "$SOURCE" "ReleaseV090TestnetReadOnlyMonitorSessionDocument"
require_file_contains "$SOURCE" "ReleaseV090TestnetReadOnlyMonitorEvent"
require_file_contains "$SOURCE" "ReleaseV090TestnetReadOnlyMonitorStatusDocument"
require_file_contains "$SOURCE" "ReleaseV090TestnetReadOnlyMonitorSessionStoreContract"
require_file_contains "$SOURCE" "GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE"
require_file_contains "$SOURCE" "V090-003-MONITOR-SESSION-JSON"
require_file_contains "$SOURCE" "V090-003-MONITOR-EVENTS-JSONL"
require_file_contains "$SOURCE" "V090-003-MONITOR-STATUS-JSON"
require_file_contains "$SOURCE" "V090-003-MONITOR-STATE-TAXONOMY"
require_file_contains "$SOURCE" "V090-003-APPEND-ONLY-MONITOR-EVENTS"
require_file_contains "$SOURCE" "V090-003-CORRUPTED-ARTIFACTS-FAIL-CLOSED"
require_file_contains "$SOURCE" "monitor_session.json"
require_file_contains "$SOURCE" "monitor_events.jsonl"
require_file_contains "$SOURCE" "monitor_status.json"
require_file_contains "$SOURCE" "created"
require_file_contains "$SOURCE" "connecting"
require_file_contains "$SOURCE" "observing"
require_file_contains "$SOURCE" "stale"
require_file_contains "$SOURCE" "disconnected"
require_file_contains "$SOURCE" "recovering"
require_file_contains "$SOURCE" "stopped"
require_file_contains "$SOURCE" "failed"
require_file_contains "Package.swift" "\"ReleaseV090TestnetReadOnlyMonitorSessionStore.swift\""
require_file_contains "Package.swift" "\"Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift\""
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-monitor-session-store.sh"
require_file_contains "docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md" "V090-003-TESTNET-READONLY-MONITOR-SESSION"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.9.0 TestnetReadOnlyMonitorSession store anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-845 Release v0.9.0 TestnetReadOnlyMonitorSession Store Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE"
require_file_contains "checks/automation-readiness.sh" "GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH845TestnetReadOnlyMonitorSessionStorePersistsArtifactsAndFailsClosed"

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

echo "MTPRO release v0.9.0 TestnetReadOnlyMonitorSession store verification passed."
