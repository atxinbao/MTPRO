#!/usr/bin/env bash
set -euo pipefail

# GH-1205-VERIFY-V0181-AGGREGATE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0181-AGGREGATE-AUDIT-RELEASE-NOTES
# V0181-006-AGGREGATE-GUARD
# V0181-006-PATCH-AUDIT
# V0181-006-RELEASE-NOTES
# V0181-006-VALIDATION-MATRIX
# V0181-006-PUBLICATION-GUIDANCE
# V0181-006-RELEASE-PUBLICATION-GATE-HANDOFF
# V0181-006-NO-PRODUCTION-CUTOVER
# V0181-006-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.1 aggregate guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.18.1 aggregate guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.18.1-venue-product-lifecycle-recovery-cli-release-fact-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.18.1-venue-product-lifecycle-recovery-cli-release-fact-patch-notes.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

bash checks/verify-v0.18.1-release-fact-sync.sh
bash checks/verify-v0.18.1-release-full-matrix-publication-gate.sh
bash checks/verify-v0.18.1-operator-run-cli-commands.sh
bash checks/verify-v0.18.1-artifact-namespace-paths.sh
bash checks/verify-v0.18.1-typed-namespace-model.sh
swift test --filter TargetGraphTests/testGH1205ReleaseV0181AggregateAuditReleaseNotesCloseout

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1205-VERIFY-V0181-AGGREGATE-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0181-AGGREGATE-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0181-006-AGGREGATE-GUARD"
  require_file_contains "$file" "V0181-006-PATCH-AUDIT"
  require_file_contains "$file" "V0181-006-RELEASE-NOTES"
  require_file_contains "$file" "V0181-006-VALIDATION-MATRIX"
  require_file_contains "$file" "V0181-006-PUBLICATION-GUIDANCE"
  require_file_contains "$file" "V0181-006-RELEASE-PUBLICATION-GATE-HANDOFF"
  require_file_contains "$file" "V0181-006-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0181-006-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$AUDIT" "#1200"
require_file_contains "$AUDIT" "#1205"
require_file_contains "$AUDIT" "PR #1216"
require_file_contains "$AUDIT" "PR #1220"
require_file_contains "$AUDIT" "Release Publication Gate"
require_file_contains "$AUDIT" "v0.19.0 is not started"
require_file_contains "$NOTES" "#1200"
require_file_contains "$NOTES" "#1205"
require_file_contains "$NOTES" "PR #1216"
require_file_contains "$NOTES" "PR #1220"
require_file_contains "$NOTES" "https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0"
require_file_contains "$NOTES" "cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9"
require_file_contains "$NOTES" "2026-06-28T04:55:36Z"
require_file_contains "$NOTES" "Release Publication Gate"
require_file_contains "$NOTES" "v0.19.0 is not started"
require_file_contains "$READINESS" "Release v0.18.1 aggregate audit / release notes anchor"
require_file_contains "$PLAN" "GH-1205 Release v0.18.1 Aggregate Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0181-AGGREGATE-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1205 closes v0.18.1 aggregate audit"
require_file_contains "$POLICY" "Release Publication Gate"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.1.sh"
require_file_contains "$TESTS" "testGH1205ReleaseV0181AggregateAuditReleaseNotesCloseout"

for file in "$AUDIT" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

echo "MTPRO release v0.18.1 aggregate audit / release notes verification passed."
