#!/usr/bin/env bash
set -euo pipefail

# GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC
# V0171-004-V0170-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC
# V0171-004-V0170-TAG-FIXED
# V0171-004-PATCH-QUEUE-NOT-PUBLICATION
# V0171-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.17.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.17.1 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-notes.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$AUDIT" \
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
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0171-004-V0170-RELEASE-FACT-SYNC-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0171-004-V0170-TAG-FIXED"
  require_file_contains "$file" "V0171-004-PATCH-QUEUE-NOT-PUBLICATION"
  require_file_contains "$file" "V0171-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0"
  require_file_contains "$file" "c83879f80a525665c3484878d7071b1f5214da20"
  require_file_contains "$file" "2026-06-27T06:37:33Z"
done

require_file_contains "$READINESS" "Release v0.17.1 v0.17.0 release fact sync anchor"
require_file_contains "$PLAN" "GH-1169 Release v0.17.1 v0.17.0 Release Fact Sync Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC"
require_file_contains "$POLICY" "v0.17.1 是 v0.17.0 后的 artifact validation fail-closed patch queue"
require_file_contains "$POLICY" "GH-1169 不移动 \`v0.17.0\` tag"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1-release-fact-sync.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1-release-fact-sync.sh"
require_file_contains "$TESTS" "testGH1169ReleaseV0171V0170ReleaseFactSyncGuard"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$AUDIT" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.17.0 tag pending"
  require_file_absent "$file" "v0.17.0 release pending"
  require_file_absent "$file" "v0.17.0 GitHub Release not created"
done

for file in "$NOTES" "$AUDIT" "$LATEST"; do
  require_file_absent "$file" "A future \`v0.17.0\` publication requires"
  require_file_absent "$file" "publication 必须由后续独立 Release Publication Gate"
done

swift test --filter TargetGraphTests/testGH1169ReleaseV0171V0170ReleaseFactSyncGuard

echo "MTPRO release v0.17.1 v0.17.0 release fact sync verification passed."
