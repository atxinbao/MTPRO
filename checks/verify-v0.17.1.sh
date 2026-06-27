#!/usr/bin/env bash
set -euo pipefail

# GH-1171-VERIFY-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES
# V0171-006-AGGREGATE-GUARD
# V0171-006-PATCH-AUDIT
# V0171-006-RELEASE-NOTES
# V0171-006-VALIDATION-MATRIX
# V0171-006-V0180-HANDOFF
# V0171-006-NO-PRODUCTION-CUTOVER
# V0171-006-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.17.1 aggregate guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.17.1 aggregate guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.17.1-operator-beta-artifact-validation-fail-closed-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.17.1-operator-beta-artifact-validation-fail-closed-patch-notes.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

bash checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh
bash checks/verify-v0.17.1-manual-workflow-fail-closed.sh
bash checks/verify-v0.17.1-artifact-negative-regressions.sh
bash checks/verify-v0.17.1-release-fact-sync.sh
swift test --filter TargetGraphTests/testGH1171ReleaseV0171AggregatePatchAuditReleaseNotesCloseout

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
  require_file_contains "$file" "GH-1171-VERIFY-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0171-006-AGGREGATE-GUARD"
  require_file_contains "$file" "V0171-006-PATCH-AUDIT"
  require_file_contains "$file" "V0171-006-RELEASE-NOTES"
  require_file_contains "$file" "V0171-006-VALIDATION-MATRIX"
  require_file_contains "$file" "V0171-006-V0180-HANDOFF"
  require_file_contains "$file" "V0171-006-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0171-006-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$NOTES" "#1166"
require_file_contains "$NOTES" "#1171"
require_file_contains "$NOTES" "Venue/Product-aware lifecycle recovery"
require_file_contains "$NOTES" "Binance"
require_file_contains "$NOTES" "OKX"
require_file_contains "$NOTES" "Bybit"
require_file_contains "$READINESS" "Release v0.17.1 aggregate patch audit / release notes anchor"
require_file_contains "$PLAN" "GH-1171 Release v0.17.1 Aggregate Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1171 closes the v0.17.1 patch audit"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1.sh"
require_file_contains "$TESTS" "testGH1171ReleaseV0171AggregatePatchAuditReleaseNotesCloseout"

for file in "$AUDIT" "$NOTES" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

echo "MTPRO release v0.17.1 aggregate patch audit / release notes verification passed."
