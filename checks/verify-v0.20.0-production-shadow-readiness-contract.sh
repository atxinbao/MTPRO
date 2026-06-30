#!/usr/bin/env bash
set -euo pipefail

# GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT
# TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT
# V0200-001-V0191-PREFLIGHT-GATE
# V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW
# V0200-001-READ-ONLY-LIVE-READINESS
# V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE
# V0200-001-SPOT-CANARY-DEFERRED-TO-V0210
# V0200-001-QUEUE-ORDER
# V0200-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 production-shadow readiness contract guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 production-shadow readiness contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-contract.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1239ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT" \
    "TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT" \
    "V0200-001-V0191-PREFLIGHT-GATE" \
    "V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW" \
    "V0200-001-READ-ONLY-LIVE-READINESS" \
    "V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE" \
    "V0200-001-SPOT-CANARY-DEFERRED-TO-V0210" \
    "V0200-001-QUEUE-ORDER" \
    "V0200-001-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract" \
  "ReleaseV0200ProductionShadowReadinessMode" \
  "ReleaseV0200ProductionShadowPreflightRequirement" \
  "ReleaseV0200ProductionShadowForbiddenCapability" \
  "GH-1239..GH-1250" \
  "GH-1232" \
  "GH-1237" \
  "MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness" \
  'requiredAllowedProductTypes = ["spot"]' \
  "productionShadowReadOnlyOnly" \
  "failClosedReadinessEvidenceRequired" \
  "spotCanaryDeferredToV0210" \
  "credentialSecretValueReadEnabledByThisIssue == false" \
  "productionEndpointConnectionEnabledByThisIssue == false" \
  "signedAccountEndpointRuntimeImplementedByThisIssue == false" \
  "privateStreamRuntimeImplementedByThisIssue == false" \
  "orderSubmitCancelReplaceImplementedByThisIssue == false" \
  "productionTradingEnabledByDefault == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

for child_issue in "#1240" "#1241" "#1242" "#1243" "#1244" "#1245" "#1246" "#1247" "#1248" "#1249" "#1250"; do
  require_contains "$CONTRACT" "$child_issue"
done

require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-production-shadow-readiness-contract.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-production-shadow-readiness-contract.sh"
require_contains "$TESTS" "testGH1239ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract"
require_contains "$README" "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT"
require_contains "$GOAL" "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT"
require_contains "$BLUEPRINT" "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT"
require_contains "$ROADMAP" "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT"
require_contains "$READINESS" "Release v0.20.0 production-shadow readiness contract anchor"
require_contains "$LATEST" "v0.20.0 production-shadow / read-only live readiness contract"
require_contains "$PLAN" "GH-1239 Release v0.20.0 Production-shadow Read-only Live Readiness Contract"
require_contains "$MATRIX" "TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "credentialSecretValueReadEnabledByThisIssue=true"
  reject_contains "$file" "productionEndpointConnectionEnabledByThisIssue=true"
  reject_contains "$file" "signedAccountEndpointRuntimeImplementedByThisIssue=true"
  reject_contains "$file" "privateStreamRuntimeImplementedByThisIssue=true"
  reject_contains "$file" "orderSubmitCancelReplaceImplementedByThisIssue=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 production-shadow readiness contract verification passed.\n'
