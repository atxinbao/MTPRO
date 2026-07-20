#!/usr/bin/env bash
set -euo pipefail

# GH-1367-VERIFY-V0241-V0240-RELEASE-FACT-SYNC
# TVM-RELEASE-V0241-V0240-RELEASE-FACT-SYNC
# V0241-001-V0240-GITHUB-RELEASE-PUBLISHED
# V0241-001-V0240-TAG-FIXED
# V0241-001-V0240-PUBLISHED-AT-2026-07-06T19-43-49Z
# GH-1368-VERIFY-V0241-MILESTONE-COMPLETION-FACTS
# V0241-002-V0231-V0240-MILESTONES-CLOSED
# GH-1369-VERIFY-V0241-V0240-STALE-WORDING-GUARD
# V0241-003-PUBLISHED-V0240-STALE-WORDING-GUARD
# GH-1370-VERIFY-V0241-SPOT-CANARY-FUTURES-READONLY-SEMANTICS
# V0241-004-SPOT-CANARY-EVIDENCE-NOT-FUTURES-EXECUTION
# V0241-004-FUTURES-READONLY-EVIDENCE-NOT-TRADING-AUTHORIZATION
# GH-1371-VERIFY-V0241-PATCH-AUDIT-RELEASE-NOTES
# V0241-005-PATCH-AUDIT
# V0241-005-V0250-BLOCKED-BY-V0241-COMPLETION
# V0241-005-NO-CAPABILITY-CHANGE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.24.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.24.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.24.1-publication-fact-sync-milestone-semantics-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.24.1-publication-fact-sync-milestone-semantics-patch-notes.md"
V0240_AUDIT="docs/audit/mtpro-release-v0.24.0-spot-futures-unified-readonly-foundation-stage-code-audit.md"
V0240_NOTES="docs/release/mtpro-release-v0.24.0-spot-futures-unified-readonly-foundation-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1367To1371ReleaseV0241PublicationFactSyncMilestoneSemanticsPatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$V0240_AUDIT" \
  "$V0240_NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1367-VERIFY-V0241-V0240-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0241-V0240-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0241-001-V0240-GITHUB-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0241-001-V0240-TAG-FIXED"
  require_file_contains "$file" "V0241-001-V0240-PUBLISHED-AT-2026-07-06T19-43-49Z"
  require_file_contains "$file" "GH-1368-VERIFY-V0241-MILESTONE-COMPLETION-FACTS"
  require_file_contains "$file" "V0241-002-V0231-V0240-MILESTONES-CLOSED"
  require_file_contains "$file" "GH-1369-VERIFY-V0241-V0240-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0241-003-PUBLISHED-V0240-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1370-VERIFY-V0241-SPOT-CANARY-FUTURES-READONLY-SEMANTICS"
  require_file_contains "$file" "V0241-004-SPOT-CANARY-EVIDENCE-NOT-FUTURES-EXECUTION"
  require_file_contains "$file" "V0241-004-FUTURES-READONLY-EVIDENCE-NOT-TRADING-AUTHORIZATION"
  require_file_contains "$file" "GH-1371-VERIFY-V0241-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0241-005-PATCH-AUDIT"
  require_file_contains "$file" "V0241-005-V0250-BLOCKED-BY-V0241-COMPLETION"
  require_file_contains "$file" "V0241-005-NO-CAPABILITY-CHANGE"
done

require_file_contains "$V0240_NOTES" "https://github.com/atxinbao/MTPRO/releases/tag/v0.24.0"
require_file_contains "$V0240_NOTES" "995065ba4ae4f9c80009fc68891176e5c0a56270"
require_file_contains "$V0240_NOTES" "2026-07-06T19:43:49Z"
require_file_contains "$V0240_AUDIT" "https://github.com/atxinbao/MTPRO/releases/tag/v0.24.0"
require_file_contains "$LATEST" "v0.23.1 milestone #38 closed"
require_file_contains "$LATEST" "v0.24.0 milestone #39 closed"

for file in "$V0240_NOTES" "$V0240_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "does not create a v0.24.0 tag"
  reject_file_contains "$file" "does not create a v0.24.0 tag / GitHub Release"
  reject_file_contains "$file" "v0.24.0 tag / GitHub Release unless separately requested"
  reject_file_contains "$file" "v0.24.0 remains pending"
  reject_file_contains "$file" "v0.24.0 has not been published"
  reject_file_contains "$file" "spotCanaryEvidenceImpliesFuturesExecution=true"
  reject_file_contains "$file" "futuresReadOnlyEvidenceImpliesTradingAuthorization=true"
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

printf 'MTPRO v0.24.1 publication fact sync / milestone semantics patch checks passed.\n'

