#!/usr/bin/env bash
set -euo pipefail

# GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE
# TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE
# V0210-007-RISKENGINE-PRETRADE-GATE
# V0210-007-GLOBAL-KILL-SWITCH-GATE
# V0210-007-NO-TRADE-GATE
# V0210-007-APPROVAL-GATE
# V0210-007-HARD-LIMIT-GATE
# V0210-007-AUDIT-EVIDENCE-NO-BYPASS
# V0210-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 pre-trade risk / kill switch / no-trade guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 pre-trade risk / kill switch / no-trade guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGate.swift"
CONTRACT="docs/contracts/release-v0.21.0-pretrade-risk-kill-notrade-gate.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1279ReleaseV0210PreTradeRiskKillNoTradeGate

for file in \
  "$SOURCE" \
  "$CONTRACT" \
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
  require_file_contains "$file" "GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE"
  require_file_contains "$file" "TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE"
  require_file_contains "$file" "V0210-007-RISKENGINE-PRETRADE-GATE"
  require_file_contains "$file" "V0210-007-GLOBAL-KILL-SWITCH-GATE"
  require_file_contains "$file" "V0210-007-NO-TRADE-GATE"
  require_file_contains "$file" "V0210-007-APPROVAL-GATE"
  require_file_contains "$file" "V0210-007-HARD-LIMIT-GATE"
  require_file_contains "$file" "V0210-007-AUDIT-EVIDENCE-NO-BYPASS"
  require_file_contains "$file" "V0210-007-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence"
require_file_contains "$SOURCE" "ReleaseV0210SpotCanaryPreTradePathDecision"
require_file_contains "$SOURCE" "ReleaseV0210SpotCanaryPreTradePathPolicy"
require_file_contains "$SOURCE" "GH-1279"
require_file_contains "$SOURCE" "GH-1278"
require_file_contains "$SOURCE" "GH-1280"
require_file_contains "$SOURCE" "riskEngineGateRequired"
require_file_contains "$SOURCE" "globalKillSwitchGateRequired"
require_file_contains "$SOURCE" "noTradeGateRequired"
require_file_contains "$SOURCE" "approvalGateRequired"
require_file_contains "$SOURCE" "canaryHardLimitGateRequired"
require_file_contains "$SOURCE" "auditEvidenceRequiredForEveryRejection"
require_file_contains "$SOURCE" "networkSubmitAttempted == false"
require_file_contains "$SOURCE" "bypassPathAvailable == false"
require_file_contains "$SOURCE" "dashboardCommandShortcutEnabled == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$CONTRACT" "GH-1279"
require_file_contains "$CONTRACT" "GH-1278"
require_file_contains "$CONTRACT" "GH-1280"
require_file_contains "$CONTRACT" "RiskEngine"
require_file_contains "$CONTRACT" "global kill switch"
require_file_contains "$CONTRACT" "no-trade"
require_file_contains "$CONTRACT" "approval"
require_file_contains "$CONTRACT" "hard-limit"
require_file_contains "$CONTRACT" "no bypass path"
require_file_contains "$CONTRACT" "does not submit / cancel / replace"
require_file_contains "$READINESS" "Release v0.21.0 pre-trade risk / kill switch / no-trade gate anchor"
require_file_contains "$PLAN" "GH-1279 Release v0.21.0 Pre-Trade Risk Kill No-Trade Gate"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE"
require_file_contains "$LATEST" "v0.21.0 pre-trade risk / kill switch / no-trade gate"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-pretrade-risk-kill-notrade.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-pretrade-risk-kill-notrade.sh"
require_file_contains "$TESTS" "testGH1279ReleaseV0210PreTradeRiskKillNoTradeGate"

for file in "$SOURCE" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "networkSubmitAttempted=true"
  reject_file_contains "$file" "bypassPathAvailable=true"
  reject_file_contains "$file" "dashboardCommandShortcutEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 pre-trade risk / kill switch / no-trade verification passed."
