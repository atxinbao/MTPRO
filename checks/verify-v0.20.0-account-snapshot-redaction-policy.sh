#!/usr/bin/env bash
set -euo pipefail

# GH-1245-VERIFY-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY
# TVM-RELEASE-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY
# V0200-007-BINANCE-SPOT-PRODUCTION-SHADOW-ACCOUNT-SNAPSHOT-REDACTION
# V0200-007-ARTIFACT-LOCATION-POLICY
# V0200-007-ALLOWED-FIELD-SCHEMA
# V0200-007-FORBIDDEN-FIELD-SCHEMA
# V0200-007-REDACTED-SNAPSHOT-JSON
# V0200-007-NO-RAW-BALANCE-PERSISTENCE
# V0200-007-NO-ACCOUNT-ID-PERSISTENCE
# V0200-007-NO-SECRET-OR-RAW-PAYLOAD-PERSISTENCE
# V0200-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 account snapshot redaction policy guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 account snapshot redaction policy guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-account-snapshot-redaction-policy.md"
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

swift test --filter TargetGraphTests/testGH1245ReleaseV0200AccountSnapshotRedactionPolicy

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1245-VERIFY-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY" \
    "TVM-RELEASE-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY" \
    "V0200-007-BINANCE-SPOT-PRODUCTION-SHADOW-ACCOUNT-SNAPSHOT-REDACTION" \
    "V0200-007-ARTIFACT-LOCATION-POLICY" \
    "V0200-007-ALLOWED-FIELD-SCHEMA" \
    "V0200-007-FORBIDDEN-FIELD-SCHEMA" \
    "V0200-007-REDACTED-SNAPSHOT-JSON" \
    "V0200-007-NO-RAW-BALANCE-PERSISTENCE" \
    "V0200-007-NO-ACCOUNT-ID-PERSISTENCE" \
    "V0200-007-NO-SECRET-OR-RAW-PAYLOAD-PERSISTENCE" \
    "V0200-007-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy" \
  "ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact" \
  "ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation" \
  "ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.deterministicFixture" \
  "account-snapshot-artifact=<redacted>" \
  "balances=<redacted>" \
  "account-id=<redacted>" \
  "raw-broker-payload=<not-persisted>" \
  "artifacts/release-v0.20.0/account-snapshot/production-shadow/<redacted-snapshot-id>.json" \
  "rawBalancesPersisted == false" \
  "accountIdentifiersPersisted == false" \
  "secretMaterialPersisted == false" \
  "rawBrokerPayloadPersisted == false" \
  "endpointResponseBodyPersisted == false" \
  "orderPayloadPersisted == false" \
  "productionSecretValueRead == false" \
  "signedRequestMaterialGenerated == false" \
  "accountEndpointTouched == false" \
  "endpointConnectionOpened == false" \
  "orderSubmitCancelReplaceEnabled == false" \
  "spotCanaryEnabled == false" \
  "futuresRuntimeEnabled == false" \
  "okxActiveImplementationEnabled == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

require_contains "$CONTRACT" "#1244 / GH-1244"
require_contains "$CONTRACT" "#1245 / GH-1245"
require_contains "$CONTRACT" "Allowed Artifact Fields"
require_contains "$CONTRACT" "Forbidden Artifact Fields"
require_contains "$CONTRACT" "Safe Redacted Artifact Example"
require_contains "$CONTRACT" "不读取 production secret"
require_contains "$CONTRACT" '不触达 `/api/v3/account`'
require_contains "$CONTRACT" "不保存真实 broker response"
require_contains "$CONTRACT" "Production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-account-snapshot-redaction-policy.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-account-snapshot-redaction-policy.sh"
require_contains "$TESTS" "testGH1245ReleaseV0200AccountSnapshotRedactionPolicy"
require_contains "$READINESS" "Release v0.20.0 account snapshot redaction policy anchor"
require_contains "$LATEST" "v0.20.0 account snapshot redaction policy"
require_contains "$PLAN" "GH-1245 Release v0.20.0 Account Snapshot Redaction Policy"
require_contains "$MATRIX" "TVM-RELEASE-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "signedRequestMaterialGenerated=true"
  reject_contains "$file" "accountEndpointTouched=true"
  reject_contains "$file" "endpointConnectionOpened=true"
  reject_contains "$file" "rawBalancesPersisted=true"
  reject_contains "$file" "accountIdentifiersPersisted=true"
  reject_contains "$file" "secretMaterialPersisted=true"
  reject_contains "$file" "rawBrokerPayloadPersisted=true"
  reject_contains "$file" "endpointResponseBodyPersisted=true"
  reject_contains "$file" "orderPayloadPersisted=true"
  reject_contains "$file" "orderSubmitCancelReplaceEnabled=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "futuresRuntimeEnabled=true"
  reject_contains "$file" "okxActiveImplementationEnabled=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 account snapshot redaction policy verification passed.\n'
