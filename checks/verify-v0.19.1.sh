#!/usr/bin/env bash
set -euo pipefail

# GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR
# TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR
# V0191-005-AGGREGATE-GUARD
# V0191-005-FOCUSED-GUARDS-COVERED
# V0191-005-PUBLICATION-FACTS-COVERED
# V0191-005-RUN-AUTOMATION-WIRING
# V0191-005-NO-PRODUCTION-CUTOVER
# V0191-005-NO-TAG-OR-RELEASE-PUBLICATION
# GH-1237-VERIFY-V0191-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0191-PATCH-AUDIT-RELEASE-NOTES
# V0191-006-PATCH-AUDIT
# V0191-006-RELEASE-NOTES
# V0191-006-ISSUE-EVIDENCE
# V0191-006-VALIDATION-MATRIX
# V0191-006-RELEASE-PUBLICATION-GATE-HANDOFF
# V0191-006-NO-PRODUCTION-CUTOVER
# V0191-006-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.19.1 aggregate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.19.1 aggregate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

NOTES="docs/release/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-notes.md"
AUDIT="docs/audit/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-stage-code-audit.md"
PATCH_NOTES="docs/release/mtpro-release-v0.19.1-v0190-release-fact-stale-wording-patch-notes.md"
PATCH_AUDIT="docs/audit/mtpro-release-v0.19.1-v0190-release-fact-stale-wording-patch-stage-code-audit.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

bash checks/verify-v0.19.1-v0190-release-fact-sync.sh
bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh
bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh
swift test --filter TargetGraphTests/testGH1236ReleaseV0191AggregateVerificationAnchor
swift test --filter TargetGraphTests/testGH1237ReleaseV0191PatchAuditReleaseNotesCloseout

for file in \
  "$NOTES" \
  "$AUDIT" \
  "$READINESS" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR"
  require_file_contains "$file" "TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR"
  require_file_contains "$file" "V0191-005-AGGREGATE-GUARD"
  require_file_contains "$file" "V0191-005-FOCUSED-GUARDS-COVERED"
  require_file_contains "$file" "V0191-005-PUBLICATION-FACTS-COVERED"
  require_file_contains "$file" "V0191-005-RUN-AUTOMATION-WIRING"
  require_file_contains "$file" "V0191-005-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0191-005-NO-TAG-OR-RELEASE-PUBLICATION"
done

for verifier in \
  "bash checks/verify-v0.19.1-v0190-release-fact-sync.sh" \
  "bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh" \
  "bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh" \
  "testGH1236ReleaseV0191AggregateVerificationAnchor" \
  "testGH1237ReleaseV0191PatchAuditReleaseNotesCloseout"; do
  require_file_contains "$0" "$verifier"
done

for file in \
  "$PATCH_NOTES" \
  "$PATCH_AUDIT" \
  "$READINESS" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1237-VERIFY-V0191-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "TVM-RELEASE-V0191-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0191-006-PATCH-AUDIT"
  require_file_contains "$file" "V0191-006-RELEASE-NOTES"
  require_file_contains "$file" "V0191-006-ISSUE-EVIDENCE"
  require_file_contains "$file" "V0191-006-VALIDATION-MATRIX"
  require_file_contains "$file" "V0191-006-RELEASE-PUBLICATION-GATE-HANDOFF"
  require_file_contains "$file" "V0191-006-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0191-006-NO-TAG-OR-RELEASE-PUBLICATION"
done

for file in "$NOTES" "$AUDIT"; do
  require_file_contains "$file" "V0191-004-V0190-RELEASE-NOTES-PUBLICATION-FACTS"
  require_file_contains "$file" "V0191-004-V0190-STAGE-AUDIT-PUBLICATION-FACTS"
  require_file_contains "$file" "V0191-004-V0190-STABLE-RELEASE-FACT"
  require_file_contains "$file" "V0191-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0"
  require_file_contains "$file" "53e9b1e81db075ef464b74f8f35c66ebd61ea03c"
  require_file_contains "$file" "2026-06-29T13:42:34Z"
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.1.sh"
require_file_contains "$READINESS" "Release v0.19.1 aggregate verification anchor"
require_file_contains "$LATEST" "v0.19.1 aggregate verification anchor"
require_file_contains "$PLAN" "GH-1236 Release v0.19.1 Aggregate Verification Anchor"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR"
require_file_contains "$TESTS" "testGH1236ReleaseV0191AggregateVerificationAnchor"

for file in "$PATCH_NOTES" "$PATCH_AUDIT"; do
  require_file_contains "$file" "#1232"
  require_file_contains "$file" "#1233"
  require_file_contains "$file" "#1234"
  require_file_contains "$file" "#1235"
  require_file_contains "$file" "#1236"
  require_file_contains "$file" "#1237"
  require_file_contains "$file" "PR #1251"
  require_file_contains "$file" "PR #1252"
  require_file_contains "$file" "PR #1253"
  require_file_contains "$file" "PR #1254"
  require_file_contains "$file" "PR #1255"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0"
  require_file_contains "$file" "53e9b1e81db075ef464b74f8f35c66ebd61ea03c"
  require_file_contains "$file" "2026-06-29T13:42:34Z"
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

require_file_contains "$RUN_SCRIPT" "GH-1237-VERIFY-V0191-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$AUTOMATION_SCRIPT" "GH-1237-VERIFY-V0191-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$READINESS" "Release v0.19.1 patch audit / release notes anchor"
require_file_contains "$LATEST" "v0.19.1 patch audit / release notes closeout"
require_file_contains "$PLAN" "GH-1237 Release v0.19.1 Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-1237 closes v0.19.1 patch audit"
require_file_contains "$TESTS" "testGH1237ReleaseV0191PatchAuditReleaseNotesCloseout"

echo "MTPRO release v0.19.1 patch audit / release notes verification passed."
