#!/usr/bin/env bash
set -euo pipefail

# GH-1272-VERIFY-V0201-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0201-PATCH-AUDIT-RELEASE-NOTES
# V0201-004-AGGREGATE-GUARD
# V0201-004-PATCH-AUDIT
# V0201-004-RELEASE-NOTES
# V0201-004-VALIDATION-MATRIX
# V0201-004-NO-CAPABILITY-CHANGE
# V0201-004-V0210-DOWNSTREAM-CANARY-HANDOFF
# V0201-004-NO-PRODUCTION-CUTOVER
# V0201-004-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.20.1 patch audit / release notes guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.20.1 patch audit / release notes guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.20.1-publication-fact-sync-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.20.1-publication-fact-sync-patch-notes.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0200_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.20.0"
V0200_TARGET_COMMIT="7f84999e8e4071fb71fdc802f895de81303bbcfd"
V0200_PUBLICATION_TIMESTAMP="2026-06-30T16:55:24Z"

bash checks/verify-v0.20.1-v0200-stale-wording-guard.sh
bash checks/verify-v0.20.1-v0200-probe-classification-evidence.sh
swift test --filter TargetGraphTests/testGH1272ReleaseV0201PatchAuditReleaseNotesCloseout

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1272-VERIFY-V0201-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0201-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0201-004-AGGREGATE-GUARD"
  require_file_contains "$file" "V0201-004-PATCH-AUDIT"
  require_file_contains "$file" "V0201-004-RELEASE-NOTES"
  require_file_contains "$file" "V0201-004-VALIDATION-MATRIX"
  require_file_contains "$file" "V0201-004-NO-CAPABILITY-CHANGE"
  require_file_contains "$file" "V0201-004-V0210-DOWNSTREAM-CANARY-HANDOFF"
  require_file_contains "$file" "V0201-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0201-004-NO-TAG-OR-RELEASE-PUBLICATION"
done

for file in "$AUDIT" "$NOTES" "$LATEST" "$POLICY"; do
  require_file_contains "$file" "#1269"
  require_file_contains "$file" "#1270"
  require_file_contains "$file" "#1271"
  require_file_contains "$file" "#1272"
  require_file_contains "$file" "#1287"
  require_file_contains "$file" "#1288"
  require_file_contains "$file" "#1289"
  require_file_contains "$file" "$V0200_RELEASE_URL"
  require_file_contains "$file" "$V0200_TARGET_COMMIT"
  require_file_contains "$file" "$V0200_PUBLICATION_TIMESTAMP"
  require_file_contains "$file" "classification evidence"
  require_file_contains "$file" "live transport proof"
  require_file_contains "$file" "account access proof"
  require_file_contains "$file" "account payload retrieval"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$NOTES" "v0.21.0 Spot canary is downstream only"
require_file_contains "$READINESS" "Release v0.20.1 patch audit / release notes anchor"
require_file_contains "$PLAN" "GH-1272 Release v0.20.1 Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0201-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1272 closes the v0.20.1 patch audit"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.1.sh"
require_file_contains "$TESTS" "testGH1272ReleaseV0201PatchAuditReleaseNotesCloseout"

for file in "$AUDIT" "$NOTES" "$POLICY"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
  reject_file_contains "$file" "v0.21.0 canary started"
done

echo "MTPRO release v0.20.1 patch audit / release notes verification passed."
