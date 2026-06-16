#!/usr/bin/env bash
set -euo pipefail

# GH-843-VERIFY-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT
# TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"

require_file_contains "$CONTRACT" "V090-001-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT"
require_file_contains "$CONTRACT" "V090-001-ALLOWED-MONITOR-MODES"
require_file_contains "$CONTRACT" "V090-001-ARTIFACT-BOUNDARY"
require_file_contains "$CONTRACT" "V090-001-FRESHNESS-STALENESS-SEMANTICS"
require_file_contains "$CONTRACT" "V090-001-CI-MANUAL-LANE-SPLIT"
require_file_contains "$CONTRACT" "V090-001-RECONCILIATION-HARDENING-SCOPE"
require_file_contains "$CONTRACT" "V090-001-DOWNSTREAM-QUEUE-ORDER"
require_file_contains "$CONTRACT" "V090-001-FORBIDDEN-CAPABILITIES"
require_file_contains "$CONTRACT" "V090-001-RELEASE-VALIDATION-MATRIX"
require_file_contains "$CONTRACT" "TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT"
require_file_contains "$CONTRACT" "testnet-read-only-observe"
require_file_contains "$CONTRACT" "snapshot-freshness-monitor"
require_file_contains "$CONTRACT" "private-stream-heartbeat-monitor"
require_file_contains "$CONTRACT" "reconciliation-review"
require_file_contains "$CONTRACT" "alert-read-model-only"
require_file_contains "$CONTRACT" "recovery-observe"
require_file_contains "$CONTRACT" "production-blocked"
require_file_contains "$CONTRACT" "testnet-monitor-session.json"
require_file_contains "$CONTRACT" "account-snapshot-freshness.json"
require_file_contains "$CONTRACT" "private-stream-heartbeat.json"
require_file_contains "$CONTRACT" "monitor-recovery.json"
require_file_contains "$CONTRACT" "dashboard-observability-timeline.json"
require_file_contains "$CONTRACT" "alert-read-model.json"
require_file_contains "$CONTRACT" "reconciliation-timeline.json"
require_file_contains "$CONTRACT" "risk-policy-application-audit.json"
require_file_contains "$CONTRACT" "run-monitor-export-bundle.json"
require_file_contains "$CONTRACT" "validation-lanes.json"
require_file_contains "$CONTRACT" "fresh"
require_file_contains "$CONTRACT" "stale"
require_file_contains "$CONTRACT" "disconnected"
require_file_contains "$CONTRACT" "recovering"
require_file_contains "$CONTRACT" "recovered"
require_file_contains "$CONTRACT" "ciNetworkRequired=false"
require_file_contains "$CONTRACT" "manualOperatorConfirmationRequired=true"
require_file_contains "$CONTRACT" "manualProofRedacted=true"
require_file_contains "$CONTRACT" "matched"
require_file_contains "$CONTRACT" "delta"
require_file_contains "$CONTRACT" "missing"
require_file_contains "$CONTRACT" "GH-843..GH-856"
require_file_contains "$CONTRACT" "GH-844"
require_file_contains "$CONTRACT" "GH-856"
require_file_contains "$CONTRACT" "venue=Binance"
require_file_contains "$CONTRACT" "productTypes=spot,usdsPerpetual"
require_file_contains "$CONTRACT" "strategies=EMA,RSI"
require_file_contains "$CONTRACT" "noOrder=true"
require_file_contains "$CONTRACT" "testnetReadOnlyObservabilityAllowed=true"
require_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=false"
require_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=false"
require_file_contains "$CONTRACT" "testnetCancelReplaceAllowed=false"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionSecretRead=false"
require_file_contains "$CONTRACT" "productionEndpointConnected=false"
require_file_contains "$CONTRACT" "productionBrokerConnected=false"
require_file_contains "$CONTRACT" "productionOrderSubmitted=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-contract.sh"
require_file_contains "checks/automation-readiness.sh" "GH-843-VERIFY-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.9.0 testnet no-order observability contract anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-843 Release v0.9.0 Testnet No-order Observability Contract Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH843ReleaseV090TestnetNoOrderObservabilityContractDefinesMonitorModesAndForbiddenCapabilities"

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
reject_file_contains "$CONTRACT" "orderFormEnabled=true"
reject_file_contains "$CONTRACT" "tradingButtonEnabled=true"

echo "MTPRO release v0.9.0 testnet no-order observability contract verification passed."
