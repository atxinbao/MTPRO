#!/usr/bin/env bash
set -euo pipefail

# GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT
# TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT
# V0210-008-CONTROLLED-SPOT-CANARY-SUBMIT
# V0210-008-IDEMPOTENCY-KEY
# V0210-008-AUDIT-EVENT
# V0210-008-REDACTED-REQUEST-EVIDENCE
# V0210-008-STRICT-SYMBOL-SIZE-SCOPE
# V0210-008-SINGLE-APPROVED-ORDER
# V0210-008-NO-REPEATED-AUTOMATION-LOOP
# V0210-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 controlled Spot canary submit guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 controlled Spot canary submit guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210ControlledSpotCanarySubmitPath.swift"
CONTRACT="docs/contracts/release-v0.21.0-controlled-spot-canary-submit-path.md"
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

swift test --filter TargetGraphTests/testGH1280ReleaseV0210ControlledSpotCanarySubmitPath

for file in \
  "$SOURCE" \
  "$CONTRACT" \
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
  require_file_contains "$file" "GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT"
  require_file_contains "$file" "TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT"
  require_file_contains "$file" "V0210-008-CONTROLLED-SPOT-CANARY-SUBMIT"
  require_file_contains "$file" "V0210-008-IDEMPOTENCY-KEY"
  require_file_contains "$file" "V0210-008-AUDIT-EVENT"
  require_file_contains "$file" "V0210-008-REDACTED-REQUEST-EVIDENCE"
  require_file_contains "$file" "V0210-008-STRICT-SYMBOL-SIZE-SCOPE"
  require_file_contains "$file" "V0210-008-SINGLE-APPROVED-ORDER"
  require_file_contains "$file" "V0210-008-NO-REPEATED-AUTOMATION-LOOP"
  require_file_contains "$file" "V0210-008-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0210ControlledSpotCanarySubmitPathEvidence"
require_file_contains "$SOURCE" "ReleaseV0210ControlledSpotCanarySubmitDecision"
require_file_contains "$SOURCE" "ReleaseV0210ControlledSpotCanarySubmitPolicy"
require_file_contains "$SOURCE" "GH-1280"
require_file_contains "$SOURCE" "GH-1279"
require_file_contains "$SOURCE" "GH-1281"
require_file_contains "$SOURCE" "requiredIdempotencyKey"
require_file_contains "$SOURCE" "redactedRequestDigest"
require_file_contains "$SOURCE" "strictSymbolScopeHeld"
require_file_contains "$SOURCE" "strictSizeScopeHeld"
require_file_contains "$SOURCE" "singleApprovedOrderOnly"
require_file_contains "$SOURCE" "networkSubmitAttempted == false"
require_file_contains "$SOURCE" "repeatedAutomatedTradingLoopEnabled == false"
require_file_contains "$SOURCE" "dashboardDefaultTradingButtonEnabled == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$CONTRACT" "GH-1280"
require_file_contains "$CONTRACT" "GH-1279"
require_file_contains "$CONTRACT" "GH-1281"
require_file_contains "$CONTRACT" "idempotency key"
require_file_contains "$CONTRACT" "redacted request evidence"
require_file_contains "$CONTRACT" "single approved order"
require_file_contains "$CONTRACT" "does not perform network submit"
require_file_contains "$READINESS" "Release v0.21.0 controlled Spot canary submit path anchor"
require_file_contains "$PLAN" "GH-1280 Release v0.21.0 Controlled Spot Canary Submit Path"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT"
require_file_contains "$LATEST" "v0.21.0 controlled Spot canary submit path"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-controlled-spot-canary-submit.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-controlled-spot-canary-submit.sh"
require_file_contains "$TESTS" "testGH1280ReleaseV0210ControlledSpotCanarySubmitPath"

for file in "$SOURCE" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "networkSubmitAttempted=true"
  reject_file_contains "$file" "repeatedAutomatedTradingLoopEnabled=true"
  reject_file_contains "$file" "dashboardDefaultTradingButtonEnabled=true"
  reject_file_contains "$file" "futuresRuntimeEnabled=true"
  reject_file_contains "$file" "okxActiveImplementationEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 controlled Spot canary submit verification passed."
