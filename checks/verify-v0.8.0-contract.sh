#!/usr/bin/env bash
set -euo pipefail

# GH-807-VERIFY-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT
# TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"

require_file_contains "$CONTRACT" "V080-001-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT"
require_file_contains "$CONTRACT" "V080-001-ALLOWED-MODES"
require_file_contains "$CONTRACT" "V080-001-PERSISTENT-LOCAL-ARTIFACTS"
require_file_contains "$CONTRACT" "V080-001-TESTNET-READONLY-MONITORING"
require_file_contains "$CONTRACT" "V080-001-SAFE-OPERATOR-CONTROLS"
require_file_contains "$CONTRACT" "V080-001-DOWNSTREAM-QUEUE-ORDER"
require_file_contains "$CONTRACT" "V080-001-FORBIDDEN-CAPABILITIES"
require_file_contains "$CONTRACT" "V080-001-EVIDENCE-ENVELOPE"
require_file_contains "$CONTRACT" "TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT"
require_file_contains "$CONTRACT" "local-persistent-operator-runtime"
require_file_contains "$CONTRACT" "testnet-read-only-monitoring"
require_file_contains "$CONTRACT" "manual-network-proof"
require_file_contains "$CONTRACT" "recovery-review"
require_file_contains "$CONTRACT" "production-blocked"
require_file_contains "$CONTRACT" "run-registry.json"
require_file_contains "$CONTRACT" "operator-session-store.json"
require_file_contains "$CONTRACT" "reconciliation-review.json"
require_file_contains "$CONTRACT" "risk-policy-profile.json"
require_file_contains "$CONTRACT" "start-local-session"
require_file_contains "$CONTRACT" "stop-local-session"
require_file_contains "$CONTRACT" "refresh-readonly-monitor"
require_file_contains "$CONTRACT" "GH-807..GH-820"
require_file_contains "$CONTRACT" "GH-808"
require_file_contains "$CONTRACT" "GH-820"
require_file_contains "$CONTRACT" "venue=Binance"
require_file_contains "$CONTRACT" "productTypes=spot,usdsPerpetual"
require_file_contains "$CONTRACT" "strategies=EMA,RSI"
require_file_contains "$CONTRACT" "noOrder=true"
require_file_contains "$CONTRACT" "persistentLocalRuntime=true"
require_file_contains "$CONTRACT" "testnetReadOnlyMonitoringAllowed=true"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionSecretRead=false"
require_file_contains "$CONTRACT" "productionEndpointConnected=false"
require_file_contains "$CONTRACT" "productionBrokerConnected=false"
require_file_contains "$CONTRACT" "productionOrderSubmitted=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=false"
require_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=false"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-contract.sh"
require_file_contains "checks/automation-readiness.sh" "GH-807-VERIFY-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 persistent operator runtime no-order contract anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-807 Release v0.8.0 Persistent Operator Runtime No-order Contract Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH807ReleaseV080PersistentOperatorRuntimeNoOrderContractDefinesAllowedModesAndForbiddenCapabilities"

reject_file_contains "$CONTRACT" "productionTradingEnabledByDefault=true"
reject_file_contains "$CONTRACT" "productionSecretRead=true"
reject_file_contains "$CONTRACT" "productionEndpointConnected=true"
reject_file_contains "$CONTRACT" "productionBrokerConnected=true"
reject_file_contains "$CONTRACT" "productionOrderSubmitted=true"
reject_file_contains "$CONTRACT" "productionCutoverAuthorized=true"
reject_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=true"
reject_file_contains "$CONTRACT" "testnetCancelReplaceAllowed=true"
reject_file_contains "$CONTRACT" "api.binance.com"
reject_file_contains "$CONTRACT" "fapi.binance.com"

echo "MTPRO release v0.8.0 persistent operator runtime no-order contract verification passed."
