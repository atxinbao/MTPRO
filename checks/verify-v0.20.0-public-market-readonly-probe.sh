#!/usr/bin/env bash
set -euo pipefail

# GH-1243-VERIFY-V0200-PUBLIC-MARKET-READ-ONLY-PROBE
# TVM-RELEASE-V0200-PUBLIC-MARKET-READ-ONLY-PROBE
# V0200-005-BINANCE-SPOT-PRODUCTION-SHADOW-PUBLIC-MARKET-PROBE
# V0200-005-PUBLIC-MARKET-READ-ONLY-REACHABILITY
# V0200-005-RESPONSE-CLASSIFICATION-EVIDENCE
# V0200-005-NO-CREDENTIAL-REQUIRED
# V0200-005-NO-SIGNED-ACCOUNT-ENDPOINT
# V0200-005-NO-ORDER-ENDPOINT
# V0200-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 public market read-only probe guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 public market read-only probe guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-public-market-readonly-probe.md"
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

swift test --filter TargetGraphTests/testGH1243ReleaseV0200PublicMarketReadOnlyProbe

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1243-VERIFY-V0200-PUBLIC-MARKET-READ-ONLY-PROBE" \
    "TVM-RELEASE-V0200-PUBLIC-MARKET-READ-ONLY-PROBE" \
    "V0200-005-BINANCE-SPOT-PRODUCTION-SHADOW-PUBLIC-MARKET-PROBE" \
    "V0200-005-PUBLIC-MARKET-READ-ONLY-REACHABILITY" \
    "V0200-005-RESPONSE-CLASSIFICATION-EVIDENCE" \
    "V0200-005-NO-CREDENTIAL-REQUIRED" \
    "V0200-005-NO-SIGNED-ACCOUNT-ENDPOINT" \
    "V0200-005-NO-ORDER-ENDPOINT" \
    "V0200-005-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe" \
  "ReleaseV0200ProductionShadowPublicMarketProbeObservation" \
  "ReleaseV0200ProductionShadowPublicMarketProbeClassification" \
  "ReleaseV0200ProductionShadowEndpointShapeEvidence.deterministicFixtures" \
  "ReleaseV0200ProductionShadowCredentialReferenceReadiness.deterministicFixture" \
  "public-market-probe=" \
  "classification=reachable" \
  "payload=<not-persisted>" \
  "credentialRequired == false" \
  "accountPayloadRequired == false" \
  "productionSecretValueRead == false" \
  "signedAccountEndpointRuntimeEnabled == false" \
  "privateStreamRuntimeEnabled == false" \
  "listenKeyRuntimeEnabled == false" \
  "accountEndpointTouched == false" \
  "tradingEndpointTouched == false" \
  "orderSubmitCancelReplaceEnabled == false" \
  "spotCanaryEnabled == false" \
  "futuresRuntimeEnabled == false" \
  "okxActiveImplementationEnabled == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

require_contains "$CONTRACT" "#1242 / GH-1242"
require_contains "$CONTRACT" "#1243 / GH-1243"
require_contains "$CONTRACT" "#1244 / GH-1244"
require_contains "$CONTRACT" "不要求 credential 或 account payload"
require_contains "$CONTRACT" "不触达 signed account endpoint"
require_contains "$CONTRACT" "不触达 order endpoint 或 trading endpoint"
require_contains "$CONTRACT" "production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-public-market-readonly-probe.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-public-market-readonly-probe.sh"
require_contains "$TESTS" "testGH1243ReleaseV0200PublicMarketReadOnlyProbe"
require_contains "$READINESS" "Release v0.20.0 public market read-only probe anchor"
require_contains "$LATEST" "v0.20.0 public market read-only probe"
require_contains "$PLAN" "GH-1243 Release v0.20.0 Public Market Read-only Probe"
require_contains "$MATRIX" "TVM-RELEASE-V0200-PUBLIC-MARKET-READ-ONLY-PROBE"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "credentialRequired=true"
  reject_contains "$file" "accountPayloadRequired=true"
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "signedAccountEndpointRuntimeEnabled=true"
  reject_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_contains "$file" "listenKeyRuntimeEnabled=true"
  reject_contains "$file" "accountEndpointTouched=true"
  reject_contains "$file" "tradingEndpointTouched=true"
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

printf 'MTPRO release v0.20.0 public market read-only probe verification passed.\n'
