#!/usr/bin/env bash
set -euo pipefail

# GH-1232-VERIFY-V0191-V0190-RELEASE-FACT-SYNC
# V0191-001-V0190-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0191-V0190-RELEASE-FACT-SYNC
# V0191-001-V0190-TAG-FIXED
# V0191-001-PATCH-QUEUE-NOT-PUBLICATION
# V0191-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.19.1 v0.19.0 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.19.1 v0.19.0 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0190_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0"
V0190_TARGET_COMMIT="53e9b1e81db075ef464b74f8f35c66ebd61ea03c"
V0190_PUBLICATION_TIMESTAMP="2026-06-29T13:42:34Z"

for file in \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1232-VERIFY-V0191-V0190-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0191-001-V0190-RELEASE-FACT-SYNC-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0191-V0190-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0191-001-V0190-TAG-FIXED"
  require_file_contains "$file" "V0191-001-PATCH-QUEUE-NOT-PUBLICATION"
  require_file_contains "$file" "V0191-001-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0190_RELEASE_URL"
  require_file_contains "$file" "$V0190_TARGET_COMMIT"
  require_file_contains "$file" "$V0190_PUBLICATION_TIMESTAMP"
done

require_file_contains "$README" "Latest v0.19.0 release publication fact"
require_file_contains "$BLUEPRINT" "Release v0.19.0 publication anchor"
require_file_contains "$ROADMAP" "v0.19.0 stable GitHub Release fact"
require_file_contains "$LATEST" "v0.19.0 stable GitHub Release"
require_file_contains "$READINESS" "Release v0.19.1 v0.19.0 release fact sync anchor"
require_file_contains "$PLAN" "GH-1232 Release v0.19.1 v0.19.0 Release Fact Sync Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-V0190-RELEASE-FACT-SYNC"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.1-v0190-release-fact-sync.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.1-v0190-release-fact-sync.sh"
require_file_contains "$TESTS" "testGH1232ReleaseV0191V0190ReleaseFactSyncGuard"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.19.0 tag pending"
  require_file_absent "$file" "v0.19.0 release pending"
  require_file_absent "$file" "v0.19.0 GitHub Release not created"
  require_file_absent "$file" "productionCutoverAuthorized=true"
done

swift test --filter TargetGraphTests/testGH1232ReleaseV0191V0190ReleaseFactSyncGuard

echo "MTPRO release v0.19.1 v0.19.0 release fact sync verification passed."
