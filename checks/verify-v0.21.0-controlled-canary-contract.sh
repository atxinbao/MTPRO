#!/usr/bin/env bash
set -euo pipefail

# GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT
# TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT
# V0210-001-V0201-PREFLIGHT-GATE
# V0210-001-BINANCE-SPOT-CONTROLLED-CANARY
# V0210-001-HUMAN-APPROVAL-REQUIRED
# V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS
# V0210-001-RISK-KILL-NO-TRADE-GATES
# V0210-001-QUEUE-ORDER
# V0210-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 controlled canary contract guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 controlled canary contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotControlledProductionCanaryContract.swift"
CONTRACT_DOC="docs/contracts/release-v0.21.0-binance-spot-controlled-production-canary-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1273ReleaseV0210SpotControlledProductionCanaryContract

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT"
  require_file_contains "$file" "V0210-001-V0201-PREFLIGHT-GATE"
  require_file_contains "$file" "V0210-001-BINANCE-SPOT-CONTROLLED-CANARY"
  require_file_contains "$file" "V0210-001-HUMAN-APPROVAL-REQUIRED"
  require_file_contains "$file" "V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS"
  require_file_contains "$file" "V0210-001-RISK-KILL-NO-TRADE-GATES"
  require_file_contains "$file" "V0210-001-QUEUE-ORDER"
  require_file_contains "$file" "V0210-001-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0210SpotControlledProductionCanaryContract"
require_file_contains "$CONTRACT_SOURCE" "GH-1273..GH-1286"
require_file_contains "$CONTRACT_SOURCE" "GH-1272"
require_file_contains "$CONTRACT_SOURCE" "controlledSpotCanaryScopeDefined"
require_file_contains "$CONTRACT_SOURCE" "explicitHumanApprovalRequired"
require_file_contains "$CONTRACT_SOURCE" "symbolAllowlistRequired"
require_file_contains "$CONTRACT_SOURCE" "notionalSizeCapsRequired"
require_file_contains "$CONTRACT_SOURCE" "riskKillSwitchNoTradeGateRequired"
require_file_contains "$CONTRACT_SOURCE" "canarySubmitCancelImplementedByThisIssue == false"
require_file_contains "$CONTRACT_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$CONTRACT_DOC" "GH-1274"
require_file_contains "$CONTRACT_DOC" "GH-1286"
require_file_contains "$CONTRACT_DOC" "Human operator approval"
require_file_contains "$CONTRACT_DOC" "symbol allowlist"
require_file_contains "$CONTRACT_DOC" "notional size cap"
require_file_contains "$CONTRACT_DOC" "RiskEngine pre-trade gate"
require_file_contains "$CONTRACT_DOC" "production cutover authorization"
require_file_contains "$READINESS" "Release v0.21.0 controlled canary contract anchor"
require_file_contains "$PLAN" "GH-1273 Release v0.21.0 Controlled Canary Contract"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT"
require_file_contains "$LATEST" "v0.21.0 controlled canary contract"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-controlled-canary-contract.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-controlled-canary-contract.sh"
require_file_contains "$TESTS" "testGH1273ReleaseV0210SpotControlledProductionCanaryContract"

for file in "$CONTRACT_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "automaticProductionSecretReadEnabled=true"
  reject_file_contains "$file" "productionEndpointAutoConnectEnabled=true"
  reject_file_contains "$file" "canarySubmitCancelImplementedByThisIssue=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 controlled canary contract verification passed."
