#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.19.0 stage audit / release docs guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.19.0 stage audit / release docs guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-notes.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1215ReleaseV0190StageAuditReleaseDocsCloseout

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
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0190-010-STAGE-CODE-AUDIT"
  require_file_contains "$file" "V0190-010-RELEASE-NOTES"
  require_file_contains "$file" "V0190-010-VALIDATION-MATRIX"
  require_file_contains "$file" "V0190-010-ROOT-DOCS-REFRESH"
  require_file_contains "$file" "V0190-010-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0190-010-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0190-010-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "PR / Checks / Merge Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$AUDIT" "#1206..#1215"
require_file_contains "$AUDIT" "PR #1222"
require_file_contains "$AUDIT" "PR #1230"
require_file_contains "$NOTES" "#1215"
require_file_contains "$NOTES" "bash checks/verify-v0.19.0-stage-audit-release-docs.sh"
require_file_contains "$READINESS" "Release v0.19.0 stage audit / release docs closeout anchor"
require_file_contains "$LATEST" "v0.19.0 stage audit / release docs closeout"
require_file_contains "$PLAN" "GH-1215 Release v0.19.0 Stage Audit / Release Docs Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS"
require_file_contains "$POLICY" "GH-1215 closes the v0.19.0 stage audit"
require_file_contains "$VERIFICATION" "2026-06-29 - GH-1215 v0.19.0 Stage Audit / Release Docs Closeout"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.0-stage-audit-release-docs.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.0-stage-audit-release-docs.sh"
require_file_contains "$TESTS" "testGH1215ReleaseV0190StageAuditReleaseDocsCloseout"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "Current active v0.19.0 implementation slice"
  reject_file_contains "$file" "Current GitHub fallback queue: \`MTPRO Release v0.19.0"
  reject_file_contains "$file" "Current GitHub fallback queue is \`MTPRO Release v0.19.0"
  reject_file_contains "$file" "Current v0.19.0"
  reject_file_contains "$file" "后续 #1215"
  reject_file_contains "$file" "#1215 仍必须"
  reject_file_contains "$file" "不推进 #1215"
  reject_file_contains "$file" "#1215 remains backlog"
done

for file in "$AUDIT" "$NOTES" "$POLICY"; do
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
done

echo "MTPRO release v0.19.0 stage audit / release docs verification passed."
