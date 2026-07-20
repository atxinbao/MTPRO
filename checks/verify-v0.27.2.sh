#!/usr/bin/env bash
set -euo pipefail

# GH-1424-VERIFY-V0272-V0271-RELEASE-FACT-SYNC
# TVM-RELEASE-V0272-V0271-RELEASE-FACT-SYNC
# V0272-001-V0271-GITHUB-RELEASE-PUBLISHED
# V0272-001-V0271-TAG-FIXED
# V0272-001-V0271-PUBLISHED-AT-2026-07-09T15-19-56Z
# GH-1425-VERIFY-V0272-V0270-MILESTONE-COMPLETION
# V0272-002-V0270-MILESTONE-CLOSED
# V0272-002-V0270-ISSUES-1411-1420-DONE
# GH-1426-VERIFY-V0272-V0271-STALE-WORDING-GUARD
# V0272-003-PUBLISHED-V0271-STALE-WORDING-GUARD
# GH-1427-VERIFY-V0272-BINANCE-ONLY-CONTINUATION-SCOPE
# V0272-004-BINANCE-SPOT-USDM-FUTURES-CONTINUATION
# V0272-004-OKX-OUT-OF-CURRENT-TARGET-PATH
# GH-1428-VERIFY-V0272-PATCH-AUDIT-RELEASE-NOTES
# V0272-005-PATCH-AUDIT
# V0272-005-V0280-BLOCKED-BY-V0272-COMPLETION
# V0272-005-NO-CAPABILITY-CHANGE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.27.2 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.27.2 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.27.2-v0271-publication-fact-sync-milestone-closure-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.27.2-v0271-publication-fact-sync-milestone-closure-patch-notes.md"
V0270_AUDIT="docs/audit/mtpro-release-v0.27.0-binance-usdm-futures-testnet-operator-runtime-hardening-stage-code-audit.md"
V0270_NOTES="docs/release/mtpro-release-v0.27.0-binance-usdm-futures-testnet-operator-runtime-hardening-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1424To1428ReleaseV0272PublicationFactSyncMilestoneClosurePatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$V0270_AUDIT" \
  "$V0270_NOTES" \
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
  require_file_contains "$file" "GH-1424-VERIFY-V0272-V0271-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0272-V0271-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0272-001-V0271-GITHUB-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0272-001-V0271-TAG-FIXED"
  require_file_contains "$file" "V0272-001-V0271-PUBLISHED-AT-2026-07-09T15-19-56Z"
  require_file_contains "$file" "GH-1425-VERIFY-V0272-V0270-MILESTONE-COMPLETION"
  require_file_contains "$file" "V0272-002-V0270-MILESTONE-CLOSED"
  require_file_contains "$file" "V0272-002-V0270-ISSUES-1411-1420-DONE"
  require_file_contains "$file" "GH-1426-VERIFY-V0272-V0271-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0272-003-PUBLISHED-V0271-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1427-VERIFY-V0272-BINANCE-ONLY-CONTINUATION-SCOPE"
  require_file_contains "$file" "V0272-004-BINANCE-SPOT-USDM-FUTURES-CONTINUATION"
  require_file_contains "$file" "V0272-004-OKX-OUT-OF-CURRENT-TARGET-PATH"
  require_file_contains "$file" "GH-1428-VERIFY-V0272-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0272-005-PATCH-AUDIT"
  require_file_contains "$file" "V0272-005-V0280-BLOCKED-BY-V0272-COMPLETION"
  require_file_contains "$file" "V0272-005-NO-CAPABILITY-CHANGE"
done

for file in "$V0270_NOTES" "$V0270_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$ROADMAP" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.27.1"
  require_file_contains "$file" "a69eed3b1a83028de14ce64ce42d1e2578eaab96"
  require_file_contains "$file" "2026-07-09T15:19:56Z"
  require_file_contains "$file" "v0.27 Dashboard macOS Type-check Patch"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.27.0"
  require_file_contains "$file" "4ee83ecece5c434cbc97999ae30ee680c1072020"
  require_file_contains "$file" "2026-07-09T14:06:49Z"
  require_file_contains "$file" "Binance Spot + Binance USD-M Futures"
  require_file_contains "$file" "OKX out of current target path"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$NOTES" "v0.27.0 milestone #45: closed with 0 open / 10 closed issues"
require_file_contains "$AUDIT" "v0.27.0 milestone #45 is closed with 0 open / 10 closed issues"
require_file_contains "$LATEST" "v0.27.0 milestone #45 closed"
require_file_contains "$ROADMAP" "v0.28.0 remains blocked until v0.27.2 completion"

for file in "$V0270_NOTES" "$V0270_AUDIT" "$AUDIT" "$NOTES" "$LATEST" "$ROADMAP" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  reject_file_contains "$file" "v0.27.1 remains pending"
  reject_file_contains "$file" "v0.27.1 has not been published"
  reject_file_contains "$file" "v0.27.1 publication remains a separate release gate"
  reject_file_contains "$file" "Creating the v0.27.1 tag"
  reject_file_contains "$file" "productionFuturesOrderExecutionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "unrestrictedLiveTradingAuthorized=true"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.27.2.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.27.2.sh"

printf 'MTPRO v0.27.2 publication fact sync / milestone closure patch checks passed.\n'
