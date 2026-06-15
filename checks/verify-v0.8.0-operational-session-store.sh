#!/usr/bin/env bash
set -euo pipefail

# GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE
# TVM-RELEASE-V080-OPERATIONAL-SESSION-STORE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 operational session store verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 operational session store verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV080OperationalRunSessionStore.swift"

swift test --filter TargetGraphTests/testGH811OperationalRunSessionStorePersistsLifecycleAndRejectsInvalidTransitions

require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionDocument"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionEvent"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStatusDocument"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStoreContract"
require_file_contains "$SOURCE" "GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE"
require_file_contains "$SOURCE" "V080-005-SESSION-JSON"
require_file_contains "$SOURCE" "V080-005-SESSION-EVENTS-JSONL"
require_file_contains "$SOURCE" "V080-005-SESSION-STATUS-JSON"
require_file_contains "$SOURCE" "V080-005-INVALID-TRANSITION-FAILS-CLOSED"
require_file_contains "$SOURCE" "V080-005-RECOVERY-PRESERVES-HISTORY"
require_file_contains "$SOURCE" "session.json"
require_file_contains "$SOURCE" "session_events.jsonl"
require_file_contains "$SOURCE" "session_status.json"
require_file_contains "$SOURCE" "invalidTransition"
require_file_contains "$SOURCE" "recoveryPreservesHistory"
require_file_contains "Package.swift" "\"ReleaseV080OperationalRunSessionStore.swift\""
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-operational-session-store.sh"
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "V080-005-OPERATIONAL-RUN-SESSION-STORE"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 OperationalRunSessionStore anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-811 Release v0.8.0 OperationalRunSessionStore Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-OPERATIONAL-SESSION-STORE"
require_file_contains "checks/automation-readiness.sh" "GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH811OperationalRunSessionStorePersistsLifecycleAndRejectsInvalidTransitions"

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

echo "MTPRO release v0.8.0 OperationalRunSessionStore verification passed."
