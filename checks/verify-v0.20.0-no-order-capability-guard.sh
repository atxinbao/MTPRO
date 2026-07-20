#!/usr/bin/env bash
set -euo pipefail

# GH-1246-VERIFY-V0200-NO-ORDER-CAPABILITY-GUARD
# TVM-RELEASE-V0200-NO-ORDER-CAPABILITY-GUARD
# V0200-008-BINANCE-SPOT-PRODUCTION-SHADOW-NO-ORDER-CAPABILITY-GUARD
# V0200-008-SUBMIT-BLOCKED
# V0200-008-CANCEL-BLOCKED
# V0200-008-REPLACE-BLOCKED
# V0200-008-DASHBOARD-CLI-CANNOT-BYPASS
# V0200-008-NO-REAL-ORDER-INTENT
# V0200-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 no-order capability guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 no-order capability guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowNoOrderCapabilityGuard.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-no-order-capability-guard.md"
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

swift test --filter TargetGraphTests/testGH1246ReleaseV0200NoOrderCapabilityGuard

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1246-VERIFY-V0200-NO-ORDER-CAPABILITY-GUARD" \
    "TVM-RELEASE-V0200-NO-ORDER-CAPABILITY-GUARD" \
    "V0200-008-BINANCE-SPOT-PRODUCTION-SHADOW-NO-ORDER-CAPABILITY-GUARD" \
    "V0200-008-SUBMIT-BLOCKED" \
    "V0200-008-CANCEL-BLOCKED" \
    "V0200-008-REPLACE-BLOCKED" \
    "V0200-008-DASHBOARD-CLI-CANNOT-BYPASS" \
    "V0200-008-NO-REAL-ORDER-INTENT" \
    "V0200-008-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowNoOrderCapabilityGuard" \
  "ReleaseV0200ProductionShadowNoOrderAttemptEvidence" \
  "ReleaseV0200ProductionShadowOrderCapability" \
  "ReleaseV0200ProductionShadowOrderCommandSurface" \
  "ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.deterministicFixture" \
  "ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist.deterministicFixture" \
  "order-capability=<blocked>" \
  "real-order-intent=<not-created>" \
  "transport=<not-invoked>" \
  "order-payload=<not-persisted>" \
  "realOrderIntentCreated == false" \
  "signedOrderMaterialGenerated == false" \
  "orderEndpointTouched == false" \
  "transportInvoked == false" \
  "orderPayloadPersisted == false" \
  "submitCapabilityEnabled == false" \
  "cancelCapabilityEnabled == false" \
  "replaceCapabilityEnabled == false" \
  "dashboardBypassAllowed == false" \
  "cliBypassAllowed == false" \
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

require_contains "$CONTRACT" "#1239 / GH-1239"
require_contains "$CONTRACT" "#1241 / GH-1241"
require_contains "$CONTRACT" "#1246 / GH-1246"
require_contains "$CONTRACT" "Blocked Capability Matrix"
require_contains "$CONTRACT" "Dashboard / CLI Bypass Policy"
require_contains "$CONTRACT" "不创建真实 order intent"
require_contains "$CONTRACT" '不触达 `/api/v3/order`'
require_contains "$CONTRACT" "不提交 / 取消 / 替换订单"
require_contains "$CONTRACT" "Production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-no-order-capability-guard.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-no-order-capability-guard.sh"
require_contains "$TESTS" "testGH1246ReleaseV0200NoOrderCapabilityGuard"
require_contains "$READINESS" "Release v0.20.0 no-order capability guard anchor"
require_contains "$LATEST" "v0.20.0 no-order capability guard"
require_contains "$PLAN" "GH-1246 Release v0.20.0 No-order Capability Guard"
require_contains "$MATRIX" "TVM-RELEASE-V0200-NO-ORDER-CAPABILITY-GUARD"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "signedOrderMaterialGenerated=true"
  reject_contains "$file" "accountEndpointTouched=true"
  reject_contains "$file" "orderEndpointTouched=true"
  reject_contains "$file" "endpointConnectionOpened=true"
  reject_contains "$file" "realOrderIntentCreated=true"
  reject_contains "$file" "orderPayloadPersisted=true"
  reject_contains "$file" "submitCapabilityEnabled=true"
  reject_contains "$file" "cancelCapabilityEnabled=true"
  reject_contains "$file" "replaceCapabilityEnabled=true"
  reject_contains "$file" "dashboardBypassAllowed=true"
  reject_contains "$file" "cliBypassAllowed=true"
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

printf 'MTPRO release v0.20.0 no-order capability guard verification passed.\n'
