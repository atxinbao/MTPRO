#!/usr/bin/env bash
set -euo pipefail

# GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE
# TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE
# V0200-002-BINANCE-SPOT-PRODUCTION-SHADOW-PROFILE
# V0200-002-CREDENTIAL-REFERENCE-NO-SECRET-VALUE
# V0200-002-ENDPOINT-INTENT-NO-CONNECTION
# V0200-002-OPERATOR-READINESS-STATE
# V0200-002-READ-ONLY-FAIL-CLOSED
# V0200-002-FUTURES-OKX-OUT-OF-SCOPE
# V0200-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 production-shadow environment profile guard failed: %s\n' "$1" >&2
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
    printf 'release v0.20.0 production-shadow environment profile guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0200ProductionShadowEnvironmentProfile.swift"
CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-environment-profile.md"
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

swift test --filter TargetGraphTests/testGH1240ReleaseV0200ProductionShadowEnvironmentProfile

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE" \
    "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE" \
    "V0200-002-BINANCE-SPOT-PRODUCTION-SHADOW-PROFILE" \
    "V0200-002-CREDENTIAL-REFERENCE-NO-SECRET-VALUE" \
    "V0200-002-ENDPOINT-INTENT-NO-CONNECTION" \
    "V0200-002-OPERATOR-READINESS-STATE" \
    "V0200-002-READ-ONLY-FAIL-CLOSED" \
    "V0200-002-FUTURES-OKX-OUT-OF-SCOPE" \
    "V0200-002-NO-PRODUCTION-CUTOVER"; do
    require_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0200ProductionShadowEnvironmentProfile" \
  "ReleaseV0200ProductionShadowEndpointIntent" \
  "ReleaseV0200ProductionShadowOperatorReadinessState" \
  "ReleaseV0181VenueID.binance" \
  "ReleaseV0181ProductKind.spot" \
  "ReleaseV0181TradingEnvironment.productionShadow" \
  "requiredCredentialProfileID = \"binance-spot-productionShadow-credential-profile-ref\"" \
  "requiredCredentialRedactedEvidenceReference = \"redacted-credential-profile:binance:spot:productionShadow\"" \
  "endpointIntent == Self.requiredEndpointIntent" \
  "operatorReadinessState == Self.requiredOperatorReadinessState" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretValueRead == false" \
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

require_contains "$CONTRACT" "#1240 / GH-1240"
require_contains "$CONTRACT" "#1239 / GH-1239"
require_contains "$CONTRACT" "#1241 / GH-1241"
require_contains "$CONTRACT" "不连接 production endpoint / broker endpoint"
require_contains "$CONTRACT" "不读取 production secret value"
require_contains "$CONTRACT" '不创建 `v0.20.0` tag / GitHub Release'
require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0-production-shadow-environment-profile.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0-production-shadow-environment-profile.sh"
require_contains "$TESTS" "testGH1240ReleaseV0200ProductionShadowEnvironmentProfile"
require_contains "$README" "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE"
require_contains "$GOAL" "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE"
require_contains "$BLUEPRINT" "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE"
require_contains "$ROADMAP" "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE"
require_contains "$READINESS" "Release v0.20.0 production-shadow environment profile anchor"
require_contains "$LATEST" "v0.20.0 production-shadow environment profile"
require_contains "$PLAN" "GH-1240 Release v0.20.0 Production-shadow Environment Profile"
require_contains "$MATRIX" "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "productionSecretValueStored=true"
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

printf 'MTPRO release v0.20.0 production-shadow environment profile verification passed.\n'
