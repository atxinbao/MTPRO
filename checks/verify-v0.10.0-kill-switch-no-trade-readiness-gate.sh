#!/usr/bin/env bash
set -euo pipefail

# GH-884-VERIFY-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE
# TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE

fail() {
  echo "release v0.10.0 kill switch / no-trade readiness gate verification failed: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_file_contains() {
  local path="$1"
  local expected="$2"
  grep -Fq "$expected" "$path" || fail "$path must contain: $expected"
}

require_file_not_contains() {
  local path="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$path"; then
    fail "$path must not contain: $forbidden"
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-kill-switch-no-trade-readiness-gate-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100KillSwitchNoTradeReadinessGate.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"

for path in "$CONTRACT" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-007-KILL-SWITCH-NO-TRADE-READINESS-GATE" \
  "V0100-007-KILL-SWITCH-STATE" \
  "V0100-007-NO-TRADE-STATE" \
  "V0100-007-LAST-OPERATOR-REVIEW" \
  "V0100-007-RISK-APPROVAL-REQUIRED" \
  "V0100-007-CUTOVER-BLOCKED-IF-KILL-SWITCH-ACTIVE" \
  "V0100-007-CUTOVER-BLOCKED-IF-NO-TRADE-ACTIVE" \
  "V0100-007-KILL-SWITCH-READINESS-JSON" \
  "V0100-007-NO-TRADE-READINESS-JSON" \
  "V0100-007-PRODUCTION-CUTOVER-BLOCKED" \
  "V0100-007-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-884-VERIFY-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE" \
  "TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for exact in \
  "kill_switch_readiness.json" \
  "no_trade_readiness.json" \
  "killSwitchState=active" \
  "noTradeState=active" \
  "lastOperatorReview=manual-operator-review-required-before-production-cutover" \
  "riskApprovalRequired=true" \
  "cutoverBlockedIfKillSwitchActive=true" \
  "cutoverBlockedIfNoTradeActive=true" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverUnblocked=false" \
  "cutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonEnabled=false" \
  "orderFormEnabled=false" \
  "liveCommandEnabled=false" \
  "killSwitchBypassEnabled=false" \
  "noTradeBypassEnabled=false"; do
  require_file_contains "$CONTRACT" "$exact"
done

require_file_contains "$SOURCE" "ReleaseV0100KillSwitchNoTradeReadinessGate"
require_file_contains "$SOURCE" "ReleaseV0100KillSwitchNoTradeOperatorReview"
require_file_contains "$SOURCE" "requiredLastOperatorReview = \"manual-operator-review-required-before-production-cutover\""
require_file_contains "$TESTS" "testGH884KillSwitchNoTradeReadinessGateBlocksCutoverAndOrders"
require_file_contains "$PLAN" "GH-884 Release v0.10.0 Kill Switch / No-trade Readiness Gate Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE"
require_file_contains "$READINESS" "Release v0.10.0 kill switch / no-trade readiness gate anchor"
require_file_contains "$LATEST" "\`#884\` 定义 KillSwitchNoTradeReadinessGate reference-only contract"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh"

for forbidden in \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "productionCutoverUnblocked=true" \
  "riskApprovalRequired=false" \
  "cutoverBlockedIfKillSwitchActive=false" \
  "cutoverBlockedIfNoTradeActive=false" \
  "cutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true" \
  "killSwitchBypassEnabled=true" \
  "noTradeBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 kill switch / no-trade readiness gate verification passed."
