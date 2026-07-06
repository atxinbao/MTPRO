#!/usr/bin/env bash
set -euo pipefail

# GH-1353-VERIFY-V0231-V0230-RELEASE-FACT-SYNC
# TVM-RELEASE-V0231-V0230-RELEASE-FACT-SYNC
# V0231-001-V0230-GITHUB-RELEASE-PUBLISHED
# V0231-001-V0230-TAG-FIXED
# GH-1354-VERIFY-V0231-V0230-STALE-WORDING-GUARD
# V0231-002-PUBLISHED-V0230-STALE-WORDING-GUARD
# GH-1355-VERIFY-V0231-LATEST-VERIFICATION-MILESTONE-FACTS
# V0231-003-V0221-V0230-MILESTONES-COMPLETE
# GH-1356-VERIFY-V0231-FUTURES-READONLY-GUARD-HARDENING
# V0231-004-NO-FUTURES-MUTATION
# V0231-004-NO-LISTENKEY-PRIVATE-STREAM
# V0231-004-NO-OKX-PRODUCTION-CUTOVER
# GH-1357-VERIFY-V0231-PATCH-AUDIT-RELEASE-NOTES
# V0231-005-PATCH-AUDIT
# V0231-005-V0240-BLOCKED-BY-V0231-COMPLETION
# V0231-005-NO-CAPABILITY-CHANGE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.23.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.23.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.23.1-publication-fact-sync-readonly-guard-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.23.1-publication-fact-sync-readonly-guard-patch-notes.md"
V0230_AUDIT="docs/audit/mtpro-release-v0.23.0-binance-usdm-futures-read-only-foundation-stage-code-audit.md"
V0230_NOTES="docs/release/mtpro-release-v0.23.0-binance-usdm-futures-read-only-foundation-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1353To1357ReleaseV0231PublicationFactSyncReadOnlyGuardPatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$V0230_AUDIT" \
  "$V0230_NOTES" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1353-VERIFY-V0231-V0230-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0231-V0230-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0231-001-V0230-GITHUB-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0231-001-V0230-TAG-FIXED"
  require_file_contains "$file" "GH-1354-VERIFY-V0231-V0230-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0231-002-PUBLISHED-V0230-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1355-VERIFY-V0231-LATEST-VERIFICATION-MILESTONE-FACTS"
  require_file_contains "$file" "V0231-003-V0221-V0230-MILESTONES-COMPLETE"
  require_file_contains "$file" "GH-1356-VERIFY-V0231-FUTURES-READONLY-GUARD-HARDENING"
  require_file_contains "$file" "V0231-004-NO-FUTURES-MUTATION"
  require_file_contains "$file" "V0231-004-NO-LISTENKEY-PRIVATE-STREAM"
  require_file_contains "$file" "V0231-004-NO-OKX-PRODUCTION-CUTOVER"
  require_file_contains "$file" "GH-1357-VERIFY-V0231-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0231-005-PATCH-AUDIT"
  require_file_contains "$file" "V0231-005-V0240-BLOCKED-BY-V0231-COMPLETION"
  require_file_contains "$file" "V0231-005-NO-CAPABILITY-CHANGE"
done

require_file_contains "$V0230_NOTES" "https://github.com/atxinbao/MTPRO/releases/tag/v0.23.0"
require_file_contains "$V0230_AUDIT" "abf787792e36dab486a6eb7f6a7477007ed68dee"
require_file_contains "$LATEST" "v0.22.1 issues #1337-#1340 closed"
require_file_contains "$LATEST" "v0.23.0 issues #1341-#1351 closed"

for file in "$V0230_NOTES" "$V0230_AUDIT" "$AUDIT" "$NOTES"; do
  reject_file_contains "$file" "does not create a v0.23.0 tag"
  reject_file_contains "$file" "does not create a v0.23.0 tag / GitHub Release"
  reject_file_contains "$file" "v0.23.0 tag / GitHub Release unless separately requested"
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxEnabled=true"
done

printf 'MTPRO v0.23.1 publication fact sync / read-only guard patch checks passed.\n'
