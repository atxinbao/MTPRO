#!/usr/bin/env bash
set -euo pipefail

# GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC
# V0161-001-V0160-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC
# V0161-001-V0160-TAG-FIXED
# V0161-001-PATCH-QUEUE-NOT-PUBLICATION
# V0161-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.16.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.16.1 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

NOTES="docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$NOTES" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$0"; do
  require_file_contains "$file" "GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0161-001-V0160-RELEASE-FACT-SYNC-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0161-001-V0160-TAG-FIXED"
  require_file_contains "$file" "V0161-001-PATCH-QUEUE-NOT-PUBLICATION"
  require_file_contains "$file" "V0161-001-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0"
  require_file_contains "$file" "28779236262bd7ffaf71e286b27b95854c5cd3e1"
  require_file_contains "$file" "2026-06-26T01:29:21Z"
done

require_file_contains "$READINESS" "Release v0.16.1 v0.16.0 release fact sync anchor"
require_file_contains "$PLAN" "GH-1133 Release v0.16.1 v0.16.0 Release Fact Sync Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC"
require_file_contains "$POLICY" "v0.16.1 是 v0.16.0 后的 evidence hardening patch queue"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.16.1-release-fact-sync.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.16.1-release-fact-sync.sh"
require_file_contains "$TESTS" "testGH1133ReleaseV0161V0160ReleaseFactSyncGuard"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.16.0 tag pending"
  require_file_absent "$file" "v0.16.0 release pending"
  require_file_absent "$file" "v0.16.0 GitHub Release not created"
done

swift test --filter TargetGraphTests/testGH1133ReleaseV0161V0160ReleaseFactSyncGuard

echo "MTPRO release v0.16.1 v0.16.0 release fact sync verification passed."

