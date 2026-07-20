#!/usr/bin/env bash
set -euo pipefail

# GH-1309-VERIFY-V0220-LIVE-CANARY-TRANSPORT-CONTRACT
# TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT
# V0220-001-V0211-PREFLIGHT-GATE
# V0220-001-BINANCE-SPOT-LIVE-CANARY-TRANSPORT
# V0220-001-OPERATOR-APPROVAL-REQUIRED
# V0220-001-ONE-SHOT-RUN-LOCK
# V0220-001-RISK-KILL-NO-TRADE-OMS-RECONCILIATION
# V0220-001-QUEUE-ORDER
# V0220-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 live canary transport contract guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 live canary transport contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0220SpotLiveCanaryTransportCompletionContract.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-binance-spot-live-canary-transport-completion-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1309ReleaseV0220SpotLiveCanaryTransportCompletionContract

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1309-VERIFY-V0220-LIVE-CANARY-TRANSPORT-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT"
  require_file_contains "$file" "V0220-001-V0211-PREFLIGHT-GATE"
  require_file_contains "$file" "V0220-001-BINANCE-SPOT-LIVE-CANARY-TRANSPORT"
  require_file_contains "$file" "V0220-001-OPERATOR-APPROVAL-REQUIRED"
  require_file_contains "$file" "V0220-001-ONE-SHOT-RUN-LOCK"
  require_file_contains "$file" "V0220-001-RISK-KILL-NO-TRADE-OMS-RECONCILIATION"
  require_file_contains "$file" "V0220-001-QUEUE-ORDER"
  require_file_contains "$file" "V0220-001-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryTransportCompletionContract"
require_file_contains "$CONTRACT_SOURCE" "GH-1309"
require_file_contains "$CONTRACT_SOURCE" "GH-1308"
require_file_contains "$CONTRACT_SOURCE" "GH-1309..GH-1320"
require_file_contains "$CONTRACT_SOURCE" "Binance"
require_file_contains "$CONTRACT_SOURCE" "\"spot\""
require_file_contains "$CONTRACT_SOURCE" "credentialSecretReadImplementedByThisIssue: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "liveOrderSubmitImplementedByThisIssue: Bool = false"
require_file_contains "$CONTRACT_SOURCE" "productionCutoverAuthorized: Bool = false"
require_file_contains "$CONTRACT_DOC" "operator approval"
require_file_contains "$CONTRACT_DOC" "credential secret material read"
require_file_contains "$CONTRACT_DOC" "signed account preflight"
require_file_contains "$CONTRACT_DOC" "one-shot submit transport"
require_file_contains "$CONTRACT_DOC" "status / cancel transport"
require_file_contains "$CONTRACT_DOC" "OMS event log"
require_file_contains "$CONTRACT_DOC" "reconciliation evidence"
require_file_contains "$README" "v0.22.0 Binance Spot live canary transport completion"
require_file_contains "$READINESS" "Release v0.22.0 live canary transport contract anchor"
require_file_contains "$PLAN" "GH-1309 Release v0.22.0 Live Canary Transport Contract"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT"
require_file_contains "$VERIFICATION" "GH-1309 v0.22.0 Live Canary Transport Contract"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-live-canary-transport-contract.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-live-canary-transport-contract.sh"
require_file_contains "$TESTS" "testGH1309ReleaseV0220SpotLiveCanaryTransportCompletionContract"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
  reject_file_contains "$file" "Futures live execution started"
  reject_file_contains "$file" "OKX active implementation started"
done

echo "MTPRO release v0.22.0 live canary transport contract verification passed."
