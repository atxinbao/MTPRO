#!/usr/bin/env bash
set -euo pipefail

# GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS
# V0160-012-STAGE-CODE-AUDIT
# V0160-012-RELEASE-NOTES
# V0160-012-OPERATOR-RUNBOOK
# V0160-012-VALIDATION-MATRIX
# V0160-012-STALE-WORDING-GUARD
# V0160-012-NO-PRODUCTION-CUTOVER
# V0160-012-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.16.0 stage audit / release docs guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.16.0 stage audit / release docs guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.16.0-binance-spot-testnet-operator-execution-beta-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.16.0-binance-spot-testnet-operator-execution-beta-notes.md"
RUNBOOK="docs/operators/release-v0.16.0-binance-spot-testnet-operator-execution-beta-runbook.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
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
  "$RUNBOOK" \
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
  require_file_contains "$file" "GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0160-012-STAGE-CODE-AUDIT"
  require_file_contains "$file" "V0160-012-RELEASE-NOTES"
  require_file_contains "$file" "V0160-012-OPERATOR-RUNBOOK"
  require_file_contains "$file" "V0160-012-VALIDATION-MATRIX"
  require_file_contains "$file" "V0160-012-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0160-012-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0160-012-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$README" "MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta"
require_file_contains "$README" "#1101..#1112 closed / done"
require_file_contains "$README" "#1112 audit / release docs closeout closed / done"
require_file_contains "$GOAL" "#1112 audit / release docs closeout closed / done"
require_file_contains "$LATEST" "v0.16.0 Stage Code Audit / release docs closeout"
require_file_contains "$AUDIT" "Issue Evidence"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$NOTES" "Completed Queue"
require_file_contains "$RUNBOOK" "Operator Evidence Path"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.16.0-stage-audit-release-docs.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.16.0-stage-audit-release-docs.sh"
require_file_contains "$TESTS" "testGH1112ReleaseV0160StageAuditReleaseDocsCloseout"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_absent "$file" "#1111 manual testnet validation workflow is current WIP=1"
  require_file_absent "$file" "#1108 Dashboard artifact-backed execution view is current active issue"
  require_file_absent "$file" "#1104 CLI cancel flow 是当前 WIP=1"
  require_file_contains "$file" "production cutover not authorized"
done

swift test --filter TargetGraphTests/testGH1112ReleaseV0160StageAuditReleaseDocsCloseout

echo "MTPRO release v0.16.0 stage audit / release docs verification passed."
