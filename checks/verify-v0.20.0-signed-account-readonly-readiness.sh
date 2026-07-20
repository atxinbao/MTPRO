#!/usr/bin/env bash
set -euo pipefail

# GH-1244-VERIFY-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS
# TVM-RELEASE-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS
# V0200-006-BINANCE-SPOT-PRODUCTION-SHADOW-SIGNED-ACCOUNT-READINESS
# V0200-006-ACCOUNT-ENDPOINT-INTENT-ONLY
# V0200-006-CREDENTIAL-REFERENCE-BOUND
# V0200-006-REDACTED-ACCOUNT-PAYLOAD-EVIDENCE
# V0200-006-NO-SECRET-VALUE-READ
# V0200-006-NO-ORDER-ENDPOINT
# V0200-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 signed account read-only readiness guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 signed account read-only readiness guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-signed-account-readonly-readiness.md"
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

swift test --filter TargetGraphTests/testGH1244ReleaseV0200SignedAccountReadOnlyReadiness

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1244-VERIFY-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS" \
    "TVM-RELEASE-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS" \
    "V0200-006-BINANCE-SPOT-PRODUCTION-SHADOW-SIGNED-ACCOUNT-READINESS" \
    "V0200-006-ACCOUNT-ENDPOINT-INTENT-ONLY" \
    "V0200-006-CREDENTIAL-REFERENCE-BOUND" \
    "V0200-006-REDACTED-ACCOUNT-PAYLOAD-EVIDENCE" \
    "V0200-006-NO-SECRET-VALUE-READ" \
    "V0200-006-NO-ORDER-ENDPOINT" \
    "V0200-006-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness" \
  "ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent" \
  "ReleaseV0200ProductionShadowSignedAccountReadinessEvidence" \
  "ReleaseV0200ProductionShadowCredentialReferenceReadiness.deterministicFixture" \
  "ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe.deterministicFixture" \
  "signed-account-readiness=<redacted>" \
  "endpoint=/api/v3/account" \
  "payload=<not-accessed>" \
  "account-payload=<not-accessed>" \
  "signed-material=<not-generated>" \
  "productionSecretValueRead == false" \
  "rawCredentialMaterialStored == false" \
  "signedRequestMaterialGenerated == false" \
  "rawAccountPayloadStored == false" \
  "accountEndpointTouched == false" \
  "orderEndpointTouched == false" \
  "listenKeyRuntimeEnabled == false" \
  "privateStreamRuntimeEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
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
require_contains "$CONTRACT" "#1245 / GH-1245"
require_contains "$CONTRACT" "不生成 signature"
require_contains "$CONTRACT" '不触达 `/api/v3/account`'
require_contains "$CONTRACT" "不保存 raw account payload"
require_contains "$CONTRACT" "不触达 order endpoint 或 trading endpoint"
require_contains "$CONTRACT" "production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-signed-account-readonly-readiness.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-signed-account-readonly-readiness.sh"
require_contains "$TESTS" "testGH1244ReleaseV0200SignedAccountReadOnlyReadiness"
require_contains "$READINESS" "Release v0.20.0 signed account read-only readiness anchor"
require_contains "$LATEST" "v0.20.0 signed account read-only readiness"
require_contains "$PLAN" "GH-1244 Release v0.20.0 Signed Account Read-only Readiness"
require_contains "$MATRIX" "TVM-RELEASE-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "rawCredentialMaterialStored=true"
  reject_contains "$file" "signedRequestMaterialGenerated=true"
  reject_contains "$file" "rawAccountPayloadStored=true"
  reject_contains "$file" "accountEndpointTouched=true"
  reject_contains "$file" "orderEndpointTouched=true"
  reject_contains "$file" "listenKeyRuntimeEnabled=true"
  reject_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_contains "$file" "productionEndpointConnectionEnabled=true"
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

printf 'MTPRO release v0.20.0 signed account read-only readiness verification passed.\n'
