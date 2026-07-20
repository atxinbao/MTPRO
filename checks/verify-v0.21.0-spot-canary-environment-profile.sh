#!/usr/bin/env bash
set -euo pipefail

# GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE
# TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE
# V0210-002-BINANCE-SPOT-CANARY-PROFILE
# V0210-002-DEFAULT-OFF-FAIL-CLOSED
# V0210-002-OPERATOR-OPT-IN-EVIDENCE
# V0210-002-NO-SECRET-ENDPOINT-ORDER
# V0210-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 spot canary environment profile guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 spot canary environment profile guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

PROFILE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotCanaryEnvironmentProfile.swift"
PROFILE_DOC="docs/contracts/release-v0.21.0-binance-spot-canary-environment-profile.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1274ReleaseV0210SpotCanaryEnvironmentProfile

for file in \
  "$PROFILE_SOURCE" \
  "$PROFILE_DOC" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE"
  require_file_contains "$file" "TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE"
  require_file_contains "$file" "V0210-002-BINANCE-SPOT-CANARY-PROFILE"
  require_file_contains "$file" "V0210-002-DEFAULT-OFF-FAIL-CLOSED"
  require_file_contains "$file" "V0210-002-OPERATOR-OPT-IN-EVIDENCE"
  require_file_contains "$file" "V0210-002-NO-SECRET-ENDPOINT-ORDER"
  require_file_contains "$file" "V0210-002-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$PROFILE_SOURCE" "ReleaseV0210SpotCanaryEnvironmentProfile"
require_file_contains "$PROFILE_SOURCE" "GH-1274"
require_file_contains "$PROFILE_SOURCE" "GH-1273"
require_file_contains "$PROFILE_SOURCE" "GH-1275"
require_file_contains "$PROFILE_SOURCE" "GH-1273..GH-1286"
require_file_contains "$PROFILE_SOURCE" "ReleaseV0181TradingEnvironment.productionLive"
require_file_contains "$PROFILE_SOURCE" "operatorOptInEvidenceRequired"
require_file_contains "$PROFILE_SOURCE" "defaultFailClosed"
require_file_contains "$PROFILE_SOURCE" "canaryActivationEnabled == false"
require_file_contains "$PROFILE_SOURCE" "credentialSecretReadEnabled == false"
require_file_contains "$PROFILE_SOURCE" "productionEndpointConnectionEnabled == false"
require_file_contains "$PROFILE_SOURCE" "orderSubmitCancelReplaceEnabled == false"
require_file_contains "$PROFILE_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$PROFILE_DOC" "GH-1274"
require_file_contains "$PROFILE_DOC" "GH-1275"
require_file_contains "$PROFILE_DOC" "Human operator opt-in evidence"
require_file_contains "$PROFILE_DOC" "default-off fail-closed"
require_file_contains "$PROFILE_DOC" "does not read production secret"
require_file_contains "$PROFILE_DOC" "does not connect"
require_file_contains "$PROFILE_DOC" "does not submit / cancel / replace"
require_file_contains "$READINESS" "Release v0.21.0 spot canary environment profile anchor"
require_file_contains "$PLAN" "GH-1274 Release v0.21.0 Spot Canary Environment Profile"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE"
require_file_contains "$LATEST" "v0.21.0 spot canary environment profile"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-spot-canary-environment-profile.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-spot-canary-environment-profile.sh"
require_file_contains "$TESTS" "testGH1274ReleaseV0210SpotCanaryEnvironmentProfile"

for file in "$PROFILE_SOURCE" "$PROFILE_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "credentialSecretReadEnabled=true"
  reject_file_contains "$file" "productionSecretReadEnabled=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "signedAccountEndpointRuntimeEnabled=true"
  reject_file_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "orderSubmitCancelReplaceEnabled=true"
  reject_file_contains "$file" "canaryActivationEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 spot canary environment profile verification passed."
