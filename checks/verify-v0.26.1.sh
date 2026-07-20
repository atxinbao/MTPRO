#!/usr/bin/env bash
set -euo pipefail

# GH-1406-VERIFY-V0261-V0260-RELEASE-FACT-SYNC
# TVM-RELEASE-V0261-V0260-RELEASE-FACT-SYNC
# V0261-001-V0260-GITHUB-RELEASE-PUBLISHED
# V0261-001-V0260-TAG-FIXED
# V0261-001-V0260-PUBLISHED-AT-2026-07-08T13-00-01Z
# GH-1407-VERIFY-V0261-V0260-MILESTONE-COMPLETION
# V0261-002-V0260-MILESTONE-CLOSED
# V0261-002-V0260-ISSUES-1394-1403-DONE
# GH-1408-VERIFY-V0261-V0260-STALE-WORDING-GUARD
# V0261-003-PUBLISHED-V0260-STALE-WORDING-GUARD
# GH-1409-VERIFY-V0261-V0260-BASELINE-WORDING
# V0261-004-V0260-CURRENT-PUBLISHED-BASELINE
# V0261-004-FUTURES-TESTNET-CONTROLLED-EXECUTION-FOUNDATION
# GH-1410-VERIFY-V0261-PATCH-AUDIT-RELEASE-NOTES
# V0261-005-PATCH-AUDIT
# V0261-005-V0270-BLOCKED-BY-V0261-COMPLETION
# V0261-005-NO-CAPABILITY-CHANGE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.26.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.26.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.26.1-v026-publication-fact-sync-milestone-closure-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.26.1-v026-publication-fact-sync-milestone-closure-patch-notes.md"
V0260_AUDIT="docs/audit/mtpro-release-v0.26.0-binance-usdm-futures-testnet-controlled-execution-foundation-stage-code-audit.md"
V0260_NOTES="docs/release/mtpro-release-v0.26.0-binance-usdm-futures-testnet-controlled-execution-foundation-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1406To1410ReleaseV0261PublicationFactSyncMilestoneClosurePatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$V0260_AUDIT" \
  "$V0260_NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$ROADMAP" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1406-VERIFY-V0261-V0260-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0261-V0260-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0261-001-V0260-GITHUB-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0261-001-V0260-TAG-FIXED"
  require_file_contains "$file" "V0261-001-V0260-PUBLISHED-AT-2026-07-08T13-00-01Z"
  require_file_contains "$file" "GH-1407-VERIFY-V0261-V0260-MILESTONE-COMPLETION"
  require_file_contains "$file" "V0261-002-V0260-MILESTONE-CLOSED"
  require_file_contains "$file" "V0261-002-V0260-ISSUES-1394-1403-DONE"
  require_file_contains "$file" "GH-1408-VERIFY-V0261-V0260-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0261-003-PUBLISHED-V0260-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1409-VERIFY-V0261-V0260-BASELINE-WORDING"
  require_file_contains "$file" "V0261-004-V0260-CURRENT-PUBLISHED-BASELINE"
  require_file_contains "$file" "V0261-004-FUTURES-TESTNET-CONTROLLED-EXECUTION-FOUNDATION"
  require_file_contains "$file" "GH-1410-VERIFY-V0261-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0261-005-PATCH-AUDIT"
  require_file_contains "$file" "V0261-005-V0270-BLOCKED-BY-V0261-COMPLETION"
  require_file_contains "$file" "V0261-005-NO-CAPABILITY-CHANGE"
done

for file in "$V0260_NOTES" "$V0260_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$ROADMAP" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.26.0"
  require_file_contains "$file" "e3b65f2337c5275eaa7ce5c5f224b69475a7c9bb"
  require_file_contains "$file" "2026-07-08T13:00:01Z"
  require_file_contains "$file" "Binance USD-M Futures testnet controlled execution foundation"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$NOTES" "v0.26.0 milestone #43: closed with 0 open / 10 closed issues"
require_file_contains "$AUDIT" "v0.26.0 milestone #43 is closed with 0 open / 10 closed issues"
require_file_contains "$LATEST" "v0.26.0 milestone #43 closed"
require_file_contains "$ROADMAP" "v0.27.0 remains blocked until v0.26.1 completion"

for file in "$V0260_NOTES" "$V0260_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$ROADMAP" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  reject_file_contains "$file" "v0.26.0 remains pending"
  reject_file_contains "$file" "v0.26.0 has not been published"
  reject_file_contains "$file" "v0.26.0 publication remains a separate release gate"
  reject_file_contains "$file" "Publication is a separate release action after the v0.26.0 queue closes"
  reject_file_contains "$file" "does not authorize production cutover=true"
  reject_file_contains "$file" "productionFuturesOrderExecutionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "unrestrictedLiveTradingAuthorized=true"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.26.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.26.1.sh"

printf 'MTPRO v0.26.1 publication fact sync / milestone closure patch checks passed.\n'
