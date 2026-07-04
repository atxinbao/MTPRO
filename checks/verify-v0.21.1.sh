#!/usr/bin/env bash
set -euo pipefail

# GH-1308-VERIFY-V0211-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0211-PATCH-AUDIT-RELEASE-NOTES
# V0211-004-AGGREGATE-GUARD
# V0211-004-PATCH-AUDIT
# V0211-004-RELEASE-NOTES
# V0211-004-VALIDATION-MATRIX
# V0211-004-NO-CAPABILITY-CHANGE
# V0211-004-V0220-DOWNSTREAM-LIVE-TRANSPORT-HANDOFF
# V0211-004-NO-PRODUCTION-CUTOVER
# V0211-004-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.1 patch audit / release notes guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.1 patch audit / release notes guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.21.1-publication-fact-and-canary-semantics-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.21.1-publication-fact-and-canary-semantics-patch-notes.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0210_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0"
V0210_TARGET_COMMIT="bca492ed48324a8057c5dc7223d740426a54c3b1"
V0210_PUBLICATION_TIMESTAMP="2026-07-04T10:08:42Z"

bash checks/verify-v0.21.1-v0210-stale-wording-guard.sh
bash checks/verify-v0.21.1-v0210-canary-evidence-wording.sh
swift test --filter TargetGraphTests/testGH1308ReleaseV0211PatchAuditReleaseNotesCloseout

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
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
  require_file_contains "$file" "GH-1308-VERIFY-V0211-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0211-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0211-004-AGGREGATE-GUARD"
  require_file_contains "$file" "V0211-004-PATCH-AUDIT"
  require_file_contains "$file" "V0211-004-RELEASE-NOTES"
  require_file_contains "$file" "V0211-004-VALIDATION-MATRIX"
  require_file_contains "$file" "V0211-004-NO-CAPABILITY-CHANGE"
  require_file_contains "$file" "V0211-004-V0220-DOWNSTREAM-LIVE-TRANSPORT-HANDOFF"
  require_file_contains "$file" "V0211-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0211-004-NO-TAG-OR-RELEASE-PUBLICATION"
done

for file in "$AUDIT" "$NOTES" "$LATEST" "$POLICY" "$VERIFICATION"; do
  require_file_contains "$file" "#1305"
  require_file_contains "$file" "#1306"
  require_file_contains "$file" "#1307"
  require_file_contains "$file" "#1308"
  require_file_contains "$file" "#1321"
  require_file_contains "$file" "#1322"
  require_file_contains "$file" "#1323"
  require_file_contains "$file" "$V0210_RELEASE_URL"
  require_file_contains "$file" "$V0210_TARGET_COMMIT"
  require_file_contains "$file" "$V0210_PUBLICATION_TIMESTAMP"
  require_file_contains "$file" "controlled canary evidence"
  require_file_contains "$file" "not live network execution"
  require_file_contains "$file" "live Spot canary transport is future work"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$AUDIT" "Issue Completion Evidence"
require_file_contains "$AUDIT" "Boundary Audit"
require_file_contains "$AUDIT" "Validation Summary"
require_file_contains "$AUDIT" "Residual Risk"
require_file_contains "$AUDIT" "Next Handoff"
require_file_contains "$NOTES" "v0.22.0 Spot live canary transport is downstream only"
require_file_contains "$READINESS" "Release v0.21.1 patch audit / release notes anchor"
require_file_contains "$PLAN" "GH-1308 Release v0.21.1 Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0211-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1308 closes the v0.21.1 patch audit"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.1.sh"
require_file_contains "$TESTS" "testGH1308ReleaseV0211PatchAuditReleaseNotesCloseout"

for file in "$AUDIT" "$NOTES" "$POLICY" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
  reject_file_contains "$file" "v0.22.0 live transport started"
done

echo "MTPRO release v0.21.1 patch audit / release notes verification passed."
