#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.16.1 patch audit / release notes guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.16.1 patch audit / release notes guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md"
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

swift test --filter TargetGraphTests/testGH1138ReleaseV0161PatchAuditReleaseNotesCloseout

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
  require_file_contains "$file" "GH-1138-VERIFY-V0161-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0161-006-PATCH-AUDIT"
  require_file_contains "$file" "V0161-006-RELEASE-NOTES"
  require_file_contains "$file" "V0161-006-VALIDATION-MATRIX"
  require_file_contains "$file" "V0161-006-PUBLICATION-GUIDANCE"
  require_file_contains "$file" "V0161-006-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0161-006-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$NOTES" "#1138"
require_file_contains "$NOTES" "bash checks/verify-v0.16.1-patch-audit-release-notes.sh"
require_file_contains "$READINESS" "Release v0.16.1 patch audit / release notes closeout anchor"
require_file_contains "$PLAN" "GH-1138 Release v0.16.1 Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1138 closes the v0.16.1 patch audit"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.16.1-patch-audit-release-notes.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.16.1-patch-audit-release-notes.sh"
require_file_contains "$TESTS" "testGH1138ReleaseV0161PatchAuditReleaseNotesCloseout"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "后续 #1138"
  reject_file_contains "$file" "#1138 仍必须"
  reject_file_contains "$file" "不推进 #1138"
  reject_file_contains "$file" "#1138 remains backlog"
done

echo "MTPRO release v0.16.1 patch audit / release notes verification passed."
