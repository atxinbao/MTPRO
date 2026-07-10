#!/usr/bin/env bash
set -euo pipefail

# GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC
# GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE
# GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD
# GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES
# V0281-004-EVALUATION-MODE-CONTRACT-ONLY
# V0281-004-READINESS-STATUS-NOT-EVALUATED
# V0281-004-CUTOVER-DECISION-BLOCKED
# GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE
# V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES
# GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE
# GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE
# GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.28.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.28.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0280ProductionCutoverReadinessGate.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0280DashboardCLIProductionReadinessSurface.swift"
V0280_AUDIT="docs/audit/mtpro-release-v0.28.0-binance-production-cutover-readiness-gate-stage-code-audit.md"
V0280_NOTES="docs/release/mtpro-release-v0.28.0-binance-production-cutover-readiness-gate-notes.md"
V0281_AUDIT="docs/audit/mtpro-release-v0.28.1-v028-publication-fact-readiness-semantics-validation-patch-stage-code-audit.md"
V0281_NOTES="docs/release/mtpro-release-v0.28.1-v028-publication-fact-readiness-semantics-validation-patch-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/roadmap.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1439To1446ReleaseV0281ReadinessSemanticsPatch

for file in \
  "$SOURCE" \
  "$DASHBOARD" \
  "$V0280_AUDIT" \
  "$V0280_NOTES" \
  "$V0281_AUDIT" \
  "$V0281_NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$ROADMAP" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC"
  require_file_contains "$file" "GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE"
  require_file_contains "$file" "GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES"
  require_file_contains "$file" "V0281-004-EVALUATION-MODE-CONTRACT-ONLY"
  require_file_contains "$file" "V0281-004-READINESS-STATUS-NOT-EVALUATED"
  require_file_contains "$file" "V0281-004-CUTOVER-DECISION-BLOCKED"
  require_file_contains "$file" "GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE"
  require_file_contains "$file" "V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES"
  require_file_contains "$file" "GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE"
  require_file_contains "$file" "GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE"
  require_file_contains "$file" "GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES"
done

for file in "$V0280_AUDIT" "$V0280_NOTES" "$V0281_AUDIT" "$V0281_NOTES" "$LATEST" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$VERIFICATION"; do
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.28.0"
  require_file_contains "$file" "4411bf8536c3bae55e365d832627873b6042e4d1"
  require_file_contains "$file" "2026-07-09T20:10:10Z"
  require_file_contains "$file" "PR #1438"
done

for file in "$SOURCE" "$DASHBOARD" "$V0281_AUDIT" "$V0281_NOTES" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$ROADMAP" "$README" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  require_file_contains "$file" "evaluationMode=contract-only"
  require_file_contains "$file" "readinessStatus=not-evaluated"
  require_file_contains "$file" "cutoverDecision=blocked"
  require_file_contains "$file" "readinessGateEvidenceComplete=true"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "v0.28.0 release remains pending"
  reject_file_contains "$file" "v0.28.0 has not been published"
  reject_file_contains "$file" "v0.28.0 tag/release remains to be created"
  reject_file_contains "$file" "OKX active runtime enabled"
  reject_file_contains "$file" "production cutover authorized"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.28.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.28.1.sh"
require_file_contains "$TESTS" "testGH1439To1446ReleaseV0281ReadinessSemanticsPatch"
require_file_contains "$V0281_AUDIT" "Linux checks and macOS Dashboard smoke are pre-publication requirements"
require_file_contains "$V0281_AUDIT" "release verifier duplication is narrowed to one focused v0.28.1 XCTest plus the final aggregate XCTest"
require_file_contains "$V0281_NOTES" "v0.29.0 remains blocked until v0.28.1 is complete"

printf 'MTPRO v0.28.1 publication fact, readiness semantics and validation patch checks passed.\n'
