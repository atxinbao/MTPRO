#!/usr/bin/env bash
set -euo pipefail

# GH-1307-VERIFY-V0211-CANARY-EVIDENCE-WORDING
# TVM-RELEASE-V0211-CANARY-EVIDENCE-WORDING
# V0211-003-CONTROLLED-CANARY-EVIDENCE-WORDING
# V0211-003-NOT-LIVE-NETWORK-EXECUTION
# V0211-003-LIVE-SPOT-CANARY-TRANSPORT-FUTURE
# V0211-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.1 canary evidence wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.1 canary evidence wording guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE_SUBMIT="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210ControlledSpotCanarySubmitPath.swift"
SOURCE_CANCEL="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210ControlledCanaryCancelRollbackGuard.swift"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md"
AUDIT="docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$NOTES" \
  "$AUDIT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1307-VERIFY-V0211-CANARY-EVIDENCE-WORDING"
  require_file_contains "$file" "TVM-RELEASE-V0211-CANARY-EVIDENCE-WORDING"
  require_file_contains "$file" "V0211-003-CONTROLLED-CANARY-EVIDENCE-WORDING"
  require_file_contains "$file" "V0211-003-NOT-LIVE-NETWORK-EXECUTION"
  require_file_contains "$file" "V0211-003-LIVE-SPOT-CANARY-TRANSPORT-FUTURE"
  require_file_contains "$file" "V0211-003-NO-PRODUCTION-CUTOVER"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$POLICY" "$NOTES" "$AUDIT" "$VERIFICATION"; do
  require_file_contains "$file" "controlled canary evidence"
  require_file_contains "$file" "not live network execution"
  require_file_contains "$file" "live Spot canary transport is future work"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$SOURCE_SUBMIT" "networkSubmitAttempted == false"
require_file_contains "$SOURCE_CANCEL" "networkCancelAttempted == false"
require_file_contains "$PLAN" "GH-1307 Release v0.21.1 Controlled Canary Evidence Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0211-CANARY-EVIDENCE-WORDING"
require_file_contains "$POLICY" "GH-1307 requires v0.21.0 canary wording"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.1-v0210-canary-evidence-wording.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.1-v0210-canary-evidence-wording.sh"
require_file_contains "$TESTS" "testGH1307ReleaseV0211CanaryEvidenceWordingGuard"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$POLICY" "$NOTES" "$AUDIT" "$VERIFICATION"; do
  reject_file_contains "$file" "v0.21.0 performs live network execution"
  reject_file_contains "$file" "v0.21.0 live network canary execution"
  reject_file_contains "$file" "networkSubmitAttempted=true"
  reject_file_contains "$file" "networkCancelAttempted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

swift test --filter TargetGraphTests/testGH1307ReleaseV0211CanaryEvidenceWordingGuard

echo "MTPRO release v0.21.1 canary evidence wording guard verification passed."
