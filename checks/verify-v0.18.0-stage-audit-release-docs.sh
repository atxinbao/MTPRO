#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 stage audit / release docs guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.18.0 stage audit / release docs guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.18.0-venue-product-aware-operator-lifecycle-recovery-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.18.0-venue-product-aware-operator-lifecycle-recovery-foundation-notes.md"
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

swift test --filter TargetGraphTests/testGH1185ReleaseV0180StageAuditReleaseDocsCloseout

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
  require_file_contains "$file" "GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0180-010-STAGE-CODE-AUDIT"
  require_file_contains "$file" "V0180-010-RELEASE-NOTES"
  require_file_contains "$file" "V0180-010-VALIDATION-MATRIX"
  require_file_contains "$file" "V0180-010-ROOT-DOCS-REFRESH"
  require_file_contains "$file" "V0180-010-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0180-010-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0180-010-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "PR / Checks / Merge Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$AUDIT" "#1176..#1185"
require_file_contains "$AUDIT" "PR #1190"
require_file_contains "$AUDIT" "PR #1198"
require_file_contains "$NOTES" "#1185"
require_file_contains "$NOTES" "bash checks/verify-v0.18.0-stage-audit-release-docs.sh"
require_file_contains "$READINESS" "Release v0.18.0 stage audit / release docs closeout anchor"
require_file_contains "$LATEST" "v0.18.0 stage audit / release docs closeout"
require_file_contains "$PLAN" "GH-1185 Release v0.18.0 Stage Audit / Release Docs Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS"
require_file_contains "$POLICY" "GH-1185 closes the v0.18.0 stage audit"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-stage-audit-release-docs.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-stage-audit-release-docs.sh"
require_file_contains "$TESTS" "testGH1185ReleaseV0180StageAuditReleaseDocsCloseout"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "Current active v0.18.0 implementation slice"
  reject_file_contains "$file" "Current GitHub fallback queue: \`MTPRO Release v0.18.0"
  reject_file_contains "$file" "Current GitHub fallback queue is \`MTPRO Release v0.18.0"
  reject_file_contains "$file" "Current v0.18.0"
  reject_file_contains "$file" "后续 #1185"
  reject_file_contains "$file" "#1185 仍必须"
  reject_file_contains "$file" "不推进 #1185"
  reject_file_contains "$file" "#1185 remains backlog"
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

echo "MTPRO release v0.18.0 stage audit / release docs verification passed."
