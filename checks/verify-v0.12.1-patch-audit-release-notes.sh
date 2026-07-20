#!/usr/bin/env bash
set -euo pipefail

# GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES
# V0121-006-PATCH-AUDIT
# V0121-006-RELEASE-NOTES
# V0121-006-VALIDATION-SUMMARY
# V0121-006-NO-PRODUCTION-CUTOVER
# V0121-006-NO-TAG-OR-RELEASE-MOVE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.12.1 patch audit / release notes guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.12.1 patch audit / release notes guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

GUARD="$0"
AUDIT="docs/audit/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-notes.md"
POLICY="docs/release/release-publication-policy.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"

swift test --filter TargetGraphTests/testGH993ReleaseV0121PatchAuditReleaseNotesCloseout

for anchor in \
  "GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES" \
  "TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES" \
  "V0121-006-PATCH-AUDIT" \
  "V0121-006-RELEASE-NOTES" \
  "V0121-006-VALIDATION-SUMMARY" \
  "V0121-006-NO-PRODUCTION-CUTOVER" \
  "V0121-006-NO-TAG-OR-RELEASE-MOVE"; do
  require_file_contains "$GUARD" "$anchor"
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$NOTES" "$anchor"
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for carried_anchor in \
  "GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD" \
  "GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE" \
  "GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA" \
  "GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED" \
  "GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS"; do
  require_file_contains "$AUDIT" "$carried_anchor"
  require_file_contains "$NOTES" "$carried_anchor"
  require_file_contains "$LATEST" "$carried_anchor"
done

for issue in "#988" "#989" "#990" "#991" "#992" "#993"; do
  require_file_contains "$AUDIT" "$issue"
  require_file_contains "$NOTES" "$issue"
done

for pr in "#1006" "#1007" "#1008" "#1009" "#1010"; do
  require_file_contains "$AUDIT" "$pr"
done

for merge_commit in \
  "69591a5e76413dc2e5f6f1acbd2692934b6c478e" \
  "3232b1e93d6d03d5ffb1d5e27a905bb29a4113e6" \
  "3b88d5774bca845c8ef07ae8a8ff5189fdc6342e" \
  "25ea9aab0222a29767a1271f8d4ed41e04baae3c" \
  "7233629a7df8a90d6d4c2fd438892e2393643dfa"; do
  require_file_contains "$AUDIT" "$merge_commit"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.12.1-patch-audit-release-notes.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.12.1-patch-audit-release-notes.sh"
require_file_contains "$READINESS" "Release v0.12.1 patch audit / release notes closeout anchor"
require_file_contains "$LATEST" "v0.12.1 patch audit / release notes closeout"
require_file_contains "$POLICY" "GH-993 is not a release publication gate"
require_file_contains "$POLICY" '不创建 `v0.12.1` tag'
require_file_contains "$POLICY" '不创建 `v0.12.1` GitHub Release'
require_file_contains "$POLICY" '不移动、不覆盖、不重写 `v0.12.0` tag 或 GitHub Release'
require_file_contains "$GOAL" "MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch"
require_file_contains "$ROADMAP" "MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "realOrderSubmissionEnabled=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
  reject_file_contains "$POLICY" "$forbidden"
done

printf 'MTPRO release v0.12.1 patch audit / release notes verification passed.\n'
