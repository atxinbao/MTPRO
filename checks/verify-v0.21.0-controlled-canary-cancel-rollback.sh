#!/usr/bin/env bash
set -euo pipefail

# GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK
# TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK
# V0210-009-CONTROLLED-CANARY-CANCEL
# V0210-009-STATUS-ROLLBACK-GUARD
# V0210-009-AUDIT-EVIDENCE
# V0210-009-REDACTED-CANCEL-EVIDENCE
# V0210-009-SINGLE-CANARY-ORDER
# V0210-009-NO-BULK-CANCEL
# V0210-009-NO-FUTURES-CANCEL
# V0210-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 controlled canary cancel rollback guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 controlled canary cancel rollback guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210ControlledCanaryCancelRollbackGuard.swift"
CONTRACT="docs/contracts/release-v0.21.0-controlled-canary-cancel-rollback-guard.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1281ReleaseV0210ControlledCanaryCancelRollbackGuard

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
  require_file_contains "$file" "GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK"
  require_file_contains "$file" "TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK"
  require_file_contains "$file" "V0210-009-CONTROLLED-CANARY-CANCEL"
  require_file_contains "$file" "V0210-009-STATUS-ROLLBACK-GUARD"
  require_file_contains "$file" "V0210-009-AUDIT-EVIDENCE"
  require_file_contains "$file" "V0210-009-REDACTED-CANCEL-EVIDENCE"
  require_file_contains "$file" "V0210-009-SINGLE-CANARY-ORDER"
  require_file_contains "$file" "V0210-009-NO-BULK-CANCEL"
  require_file_contains "$file" "V0210-009-NO-FUTURES-CANCEL"
  require_file_contains "$file" "V0210-009-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence"
require_file_contains "$SOURCE" "ReleaseV0210ControlledCanaryCancelRollbackDecision"
require_file_contains "$SOURCE" "ReleaseV0210ControlledCanaryCancelRollbackPolicy"
require_file_contains "$SOURCE" "GH-1281"
require_file_contains "$SOURCE" "GH-1280"
require_file_contains "$SOURCE" "GH-1282"
require_file_contains "$SOURCE" "requiredCancelIdempotencyKey"
require_file_contains "$SOURCE" "canaryOrderReferenceDigest"
require_file_contains "$SOURCE" "statusRollbackEvidenceDigest"
require_file_contains "$SOURCE" "singleOrderScopeHeld"
require_file_contains "$SOURCE" "networkCancelAttempted == false"
require_file_contains "$SOURCE" "bulkCancelEnabled == false"
require_file_contains "$SOURCE" "futuresCancelEnabled == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$CONTRACT" "GH-1281"
require_file_contains "$CONTRACT" "GH-1280"
require_file_contains "$CONTRACT" "GH-1282"
require_file_contains "$CONTRACT" "redacted canary order reference"
require_file_contains "$CONTRACT" "status rollback guard"
require_file_contains "$CONTRACT" "single canary order"
require_file_contains "$CONTRACT" "does not perform network cancel"
require_file_contains "$READINESS" "Release v0.21.0 controlled canary cancel rollback guard anchor"
require_file_contains "$PLAN" "GH-1281 Release v0.21.0 Controlled Canary Cancel Rollback Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK"
require_file_contains "$LATEST" "v0.21.0 controlled canary cancel rollback guard"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-controlled-canary-cancel-rollback.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-controlled-canary-cancel-rollback.sh"
require_file_contains "$TESTS" "testGH1281ReleaseV0210ControlledCanaryCancelRollbackGuard"

for file in "$SOURCE" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "networkCancelAttempted=true"
  reject_file_contains "$file" "bulkCancelEnabled=true"
  reject_file_contains "$file" "futuresCancelEnabled=true"
  reject_file_contains "$file" "dashboardDefaultTradingButtonEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 controlled canary cancel rollback verification passed."
