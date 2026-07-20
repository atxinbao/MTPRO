#!/usr/bin/env bash
set -euo pipefail

# GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS
# TVM-RELEASE-V0200-CREDENTIAL-REFERENCE-READINESS
# V0200-004-BINANCE-SPOT-PRODUCTION-SHADOW-CREDENTIAL-READINESS
# V0200-004-CREDENTIAL-IDENTITY-ONLY
# V0200-004-MISSING-REFERENCE-FAILS-CLOSED
# V0200-004-REDACTED-AUDIT-EVIDENCE
# V0200-004-NO-SECRET-VALUE-READ
# V0200-004-NO-ENDPOINT-CONNECTION
# V0200-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 credential reference readiness guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 credential reference readiness guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowCredentialReferenceReadiness.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-credential-reference-readiness.md"
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

swift test --filter TargetGraphTests/testGH1242ReleaseV0200CredentialReferenceReadiness

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS" \
    "TVM-RELEASE-V0200-CREDENTIAL-REFERENCE-READINESS" \
    "V0200-004-BINANCE-SPOT-PRODUCTION-SHADOW-CREDENTIAL-READINESS" \
    "V0200-004-CREDENTIAL-IDENTITY-ONLY" \
    "V0200-004-MISSING-REFERENCE-FAILS-CLOSED" \
    "V0200-004-REDACTED-AUDIT-EVIDENCE" \
    "V0200-004-NO-SECRET-VALUE-READ" \
    "V0200-004-NO-ENDPOINT-CONNECTION" \
    "V0200-004-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowCredentialReferenceReadiness" \
  "ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence" \
  "ReleaseV0200ProductionShadowCredentialReferenceFailureClass" \
  "ReleaseV0190VenueCredentialProfileRegistry.entry" \
  "ReleaseV0181VenueID.binance" \
  "ReleaseV0181ProductKind.spot" \
  "ReleaseV0181TradingEnvironment.productionShadow" \
  "binance-spot-productionShadow-credential-profile-ref" \
  "redacted-credential-profile:binance:spot:productionShadow" \
  "credential-reference=<redacted>; state=present; action=identity-only" \
  "credential-reference=<redacted>; state=missing; action=fail-closed" \
  "credential-reference=<redacted>; state=invalid; action=fail-closed" \
  "case requiredReferenceMissing" \
  "case namespaceMismatch" \
  "secretValueRead == false" \
  "rawCredentialMaterialPresent == false" \
  "endpointConnectionOpened == false" \
  "auditTrailAppendOnly" \
  "productionSecretValueRead == false" \
  "rawCredentialMaterialStored == false" \
  "secretProviderAutoReadEnabled == false" \
  "apiKeyLogged == false" \
  "secretKeyLogged == false" \
  "listenKeyLogged == false" \
  "productionEndpointConnectionEnabled == false" \
  "signedAccountEndpointRuntimeEnabled == false" \
  "privateStreamRuntimeEnabled == false" \
  "orderSubmitCancelReplaceEnabled == false" \
  "spotCanaryEnabled == false" \
  "futuresRuntimeEnabled == false" \
  "okxActiveImplementationEnabled == false" \
  "productionCutoverAuthorized == false" \
  "createsTagOrRelease == false"; do
  require_contains "$SOURCE" "$required_string"
done

require_contains "$CONTRACT" "#1241 / GH-1241"
require_contains "$CONTRACT" "#1242 / GH-1242"
require_contains "$CONTRACT" "#1243 / GH-1243"
require_contains "$CONTRACT" "不读取 production secret value"
require_contains "$CONTRACT" "不连接 production endpoint / broker endpoint"
require_contains "$CONTRACT" "production cutover not authorized"
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-credential-reference-readiness.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-credential-reference-readiness.sh"
require_contains "$TESTS" "testGH1242ReleaseV0200CredentialReferenceReadiness"
require_contains "$README" "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS"
require_contains "$GOAL" "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS"
require_contains "$BLUEPRINT" "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS"
require_contains "$ROADMAP" "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS"
require_contains "$READINESS" "Release v0.20.0 credential reference readiness anchor"
require_contains "$LATEST" "v0.20.0 credential reference readiness"
require_contains "$PLAN" "GH-1242 Release v0.20.0 Credential Reference Readiness"
require_contains "$MATRIX" "TVM-RELEASE-V0200-CREDENTIAL-REFERENCE-READINESS"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "rawCredentialMaterialStored=true"
  reject_contains "$file" "secretProviderAutoReadEnabled=true"
  reject_contains "$file" "apiKeyLogged=true"
  reject_contains "$file" "secretKeyLogged=true"
  reject_contains "$file" "listenKeyLogged=true"
  reject_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_contains "$file" "signedAccountEndpointRuntimeEnabled=true"
  reject_contains "$file" "privateStreamRuntimeEnabled=true"
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

printf 'MTPRO release v0.20.0 credential reference readiness verification passed.\n'
