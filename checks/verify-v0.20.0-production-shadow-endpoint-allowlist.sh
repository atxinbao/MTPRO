#!/usr/bin/env bash
set -euo pipefail

# GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
# TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
# V0200-003-BINANCE-SPOT-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
# V0200-003-HTTPS-API-BINANCE-COM-ONLY
# V0200-003-READ-ONLY-PATH-ALLOWLIST
# V0200-003-QUERY-SHAPE-ALLOWLIST
# V0200-003-SIGNED-TRADING-ENDPOINTS-FORBIDDEN
# V0200-003-NO-ENDPOINT-CONNECTION
# V0200-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 production-shadow endpoint allowlist guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 production-shadow endpoint allowlist guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-endpoint-allowlist.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1241ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST" \
    "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST" \
    "V0200-003-BINANCE-SPOT-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST" \
    "V0200-003-HTTPS-API-BINANCE-COM-ONLY" \
    "V0200-003-READ-ONLY-PATH-ALLOWLIST" \
    "V0200-003-QUERY-SHAPE-ALLOWLIST" \
    "V0200-003-SIGNED-TRADING-ENDPOINTS-FORBIDDEN" \
    "V0200-003-NO-ENDPOINT-CONNECTION" \
    "V0200-003-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist" \
  "ReleaseV0200ProductionShadowReadOnlyEndpointKind" \
  "ReleaseV0200ProductionShadowEndpointShapeEvidence" \
  "ReleaseV0190VenueEndpointFamilyRegistry.entry" \
  "ReleaseV0181VenueID.binance" \
  "ReleaseV0181ProductKind.spot" \
  "ReleaseV0181TradingEnvironment.productionShadow" \
  "requiredHost = \"api.binance.com\"" \
  "\"/api/v3/time\"" \
  "\"/api/v3/exchangeInfo\"" \
  "\"/api/v3/ticker/price\"" \
  "\"/api/v3/depth\"" \
  "case account = \"/api/v3/account\"" \
  "case order = \"/api/v3/order\"" \
  "case userDataStream = \"/api/v3/userDataStream\"" \
  "case signature" \
  "case listenKey" \
  "case orderId" \
  "productionEndpointConnectionEnabled == false" \
  "productionSecretValueRead == false" \
  "signedAccountEndpointRuntimeEnabled == false" \
  "privateStreamRuntimeEnabled == false" \
  "listenKeyRuntimeEnabled == false" \
  "orderSubmitCancelReplaceEnabled == false" \
  "spotCanaryEnabled == false" \
  "futuresRuntimeEnabled == false" \
  "okxActiveImplementationEnabled == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

require_contains "$CONTRACT" "#1240 / GH-1240"
require_contains "$CONTRACT" "#1241 / GH-1241"
require_contains "$CONTRACT" "#1242 / GH-1242"
require_contains "$CONTRACT" "https://api.binance.com"
require_contains "$CONTRACT" "/api/v3/account"
require_contains "$CONTRACT" "/api/v3/order"
require_contains "$CONTRACT" "/api/v3/userDataStream"
require_contains "$CONTRACT" "不连接 production endpoint / broker endpoint"
require_contains "$CONTRACT" "不读取 production secret value"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh"
require_contains "$TESTS" "testGH1241ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist"
require_contains "$README" "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST"
require_contains "$GOAL" "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST"
require_contains "$BLUEPRINT" "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST"
require_contains "$ROADMAP" "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST"
require_contains "$READINESS" "Release v0.20.0 production-shadow endpoint allowlist anchor"
require_contains "$LATEST" "v0.20.0 production-shadow endpoint allowlist"
require_contains "$PLAN" "GH-1241 Release v0.20.0 Production-shadow Endpoint Allowlist"
require_contains "$MATRIX" "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "signedAccountEndpointRuntimeEnabled=true"
  reject_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_contains "$file" "listenKeyRuntimeEnabled=true"
  reject_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_contains "$file" "orderSubmitCancelReplaceEnabled=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "futuresRuntimeEnabled=true"
  reject_contains "$file" "okxActiveImplementationEnabled=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 production-shadow endpoint allowlist verification passed.\n'
