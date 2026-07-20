#!/usr/bin/env bash
set -euo pipefail

# GH-1247-VERIFY-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS
# TVM-RELEASE-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS
# V0200-009-BINANCE-SPOT-PRODUCTION-SHADOW-RISK-READINESS
# V0200-009-RISK-GATE-VISIBLE-FAIL-CLOSED
# V0200-009-KILL-SWITCH-BLOCKED-VISIBLE
# V0200-009-NO-TRADE-BLOCKED-VISIBLE
# V0200-009-NO-TRADING-AUTHORIZATION
# V0200-009-NO-ORDER-CAPABILITY-BYPASS
# V0200-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 risk / kill switch / no-trade readiness failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.20.0 risk / kill switch / no-trade readiness failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-risk-kill-switch-no-trade-readiness.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1247ReleaseV0200RiskKillSwitchNoTradeReadiness

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1247-VERIFY-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS" \
    "TVM-RELEASE-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS" \
    "V0200-009-BINANCE-SPOT-PRODUCTION-SHADOW-RISK-READINESS" \
    "V0200-009-RISK-GATE-VISIBLE-FAIL-CLOSED" \
    "V0200-009-KILL-SWITCH-BLOCKED-VISIBLE" \
    "V0200-009-NO-TRADE-BLOCKED-VISIBLE" \
    "V0200-009-NO-TRADING-AUTHORIZATION" \
    "V0200-009-NO-ORDER-CAPABILITY-BYPASS" \
    "V0200-009-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness" \
  "ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence" \
  "ReleaseV0200ProductionShadowRiskReadinessComponent" \
  "ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy.deterministicFixture" \
  "ReleaseV0200ProductionShadowNoOrderCapabilityGuard.deterministicFixture" \
  "risk-readiness=<visible-fail-closed>" \
  "trading-authorization=<withheld>" \
  "orders=<blocked>" \
  "bypass=<blocked>" \
  "tradingAuthorizationGranted == false" \
  "orderIntentCreated == false" \
  "submitCancelReplaceEnabled == false" \
  "riskBypassAllowed == false" \
  "killSwitchBypassAllowed == false" \
  "noTradeBypassAllowed == false" \
  "dashboardTradingButtonEnabled == false" \
  "orderFormEnabled == false" \
  "liveCommandEnabled == false" \
  "spotCanaryEnabled == false" \
  "futuresRuntimeEnabled == false" \
  "okxActiveImplementationEnabled == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

require_contains "$CONTRACT" "#1245 / GH-1245"
require_contains "$CONTRACT" "#1246 / GH-1246"
require_contains "$CONTRACT" "Readiness Evidence Matrix"
require_contains "$CONTRACT" "Production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh"
require_contains "$TESTS" "testGH1247ReleaseV0200RiskKillSwitchNoTradeReadiness"
require_contains "$READINESS" "Release v0.20.0 risk / kill switch / no-trade readiness anchor"
require_contains "$LATEST" "v0.20.0 risk / kill switch / no-trade readiness"
require_contains "$PLAN" "GH-1247 Release v0.20.0 Risk / Kill Switch / No-trade Readiness"
require_contains "$MATRIX" "TVM-RELEASE-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "productionEndpointConnected=true"
  reject_contains "$file" "signedOrderMaterialGenerated=true"
  reject_contains "$file" "orderEndpointTouched=true"
  reject_contains "$file" "endpointConnectionOpened=true"
  reject_contains "$file" "tradingAuthorizationGranted=true"
  reject_contains "$file" "orderIntentCreated=true"
  reject_contains "$file" "submitCancelReplaceEnabled=true"
  reject_contains "$file" "riskBypassAllowed=true"
  reject_contains "$file" "killSwitchBypassAllowed=true"
  reject_contains "$file" "noTradeBypassAllowed=true"
  reject_contains "$file" "dashboardTradingButtonEnabled=true"
  reject_contains "$file" "orderFormEnabled=true"
  reject_contains "$file" "liveCommandEnabled=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "futuresRuntimeEnabled=true"
  reject_contains "$file" "okxActiveImplementationEnabled=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 risk / kill switch / no-trade readiness verification passed.\n'
