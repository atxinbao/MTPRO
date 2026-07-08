#!/usr/bin/env bash
set -euo pipefail

# GH-1389-VERIFY-V0251-V0250-RELEASE-FACT-SYNC
# TVM-RELEASE-V0251-V0250-RELEASE-FACT-SYNC
# V0251-001-V0250-GITHUB-RELEASE-PUBLISHED
# V0251-001-V0250-TAG-FIXED
# V0251-001-V0250-PUBLISHED-AT-2026-07-07T14-47-50Z
# GH-1390-VERIFY-V0251-MILESTONE-COMPLETION-FACTS
# V0251-002-V0250-MILESTONE-CLOSED
# GH-1391-VERIFY-V0251-V022-V023-MAINLINE-WORDING
# V0251-003-V0220-SPOT-LIVE-CANARY-TRANSPORT
# V0251-003-V0230-FUTURES-READONLY-FOUNDATION
# GH-1392-VERIFY-V0251-V0250-STALE-WORDING-GUARD
# V0251-004-PUBLISHED-V0250-STALE-WORDING-GUARD
# GH-1393-VERIFY-V0251-PATCH-AUDIT-RELEASE-NOTES
# V0251-005-PATCH-AUDIT
# V0251-005-V0260-BLOCKED-BY-V0251-COMPLETION
# V0251-005-NO-CAPABILITY-CHANGE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.25.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.25.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.25.1-v025-publication-fact-sync-roadmap-correction-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.25.1-v025-publication-fact-sync-roadmap-correction-patch-notes.md"
V0250_AUDIT="docs/audit/mtpro-release-v0.25.0-dual-product-production-readiness-canary-hardening-stage-code-audit.md"
V0250_NOTES="docs/release/mtpro-release-v0.25.0-dual-product-production-readiness-canary-hardening-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/roadmap.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1389To1393ReleaseV0251PublicationFactSyncRoadmapCorrectionPatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$V0250_AUDIT" \
  "$V0250_NOTES" \
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
  require_file_contains "$file" "GH-1389-VERIFY-V0251-V0250-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0251-V0250-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0251-001-V0250-GITHUB-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0251-001-V0250-TAG-FIXED"
  require_file_contains "$file" "V0251-001-V0250-PUBLISHED-AT-2026-07-07T14-47-50Z"
  require_file_contains "$file" "GH-1390-VERIFY-V0251-MILESTONE-COMPLETION-FACTS"
  require_file_contains "$file" "V0251-002-V0250-MILESTONE-CLOSED"
  require_file_contains "$file" "GH-1391-VERIFY-V0251-V022-V023-MAINLINE-WORDING"
  require_file_contains "$file" "V0251-003-V0220-SPOT-LIVE-CANARY-TRANSPORT"
  require_file_contains "$file" "V0251-003-V0230-FUTURES-READONLY-FOUNDATION"
  require_file_contains "$file" "GH-1392-VERIFY-V0251-V0250-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0251-004-PUBLISHED-V0250-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1393-VERIFY-V0251-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0251-005-PATCH-AUDIT"
  require_file_contains "$file" "V0251-005-V0260-BLOCKED-BY-V0251-COMPLETION"
  require_file_contains "$file" "V0251-005-NO-CAPABILITY-CHANGE"
done

require_file_contains "$V0250_NOTES" "https://github.com/atxinbao/MTPRO/releases/tag/v0.25.0"
require_file_contains "$V0250_NOTES" "1dad68196b28eca7285a5c8efb3d15ce74c"
require_file_contains "$V0250_NOTES" "2026-07-07T14:47:50Z"
require_file_contains "$V0250_AUDIT" "https://github.com/atxinbao/MTPRO/releases/tag/v0.25.0"
require_file_contains "$LATEST" "v0.25.0 milestone #41 closed"
require_file_contains "$ROADMAP" "v0.22.0 is Binance Spot live canary transport completion"
require_file_contains "$ROADMAP" "v0.23.0 is Binance USD-M Futures read-only foundation"

for file in "$V0250_NOTES" "$V0250_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$ROADMAP" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  reject_file_contains "$file" "does not create or move v0.25.0"
  reject_file_contains "$file" "does not create the GitHub Release"
  reject_file_contains "$file" "does not create the tag"
  reject_file_contains "$file" 'It does not create or move `v0.25.0`'
  reject_file_contains "$file" "It does not create the GitHub Release"
  reject_file_contains "$file" "v0.25.0 remains pending"
  reject_file_contains "$file" "v0.25.0 has not been published"
  reject_file_contains "$file" "v0.25.0 tag / GitHub Release publication is a separate gate"
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

printf 'MTPRO v0.25.1 publication fact sync / roadmap correction patch checks passed.\n'
