#!/usr/bin/env bash
set -euo pipefail

# GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES
# V0141-006-PATCH-AUDIT
# V0141-006-RELEASE-NOTES
# V0141-006-VALIDATION-SUMMARY
# V0141-006-LOCAL-EVIDENCE-WORDING
# V0141-006-NO-PRODUCTION-CUTOVER
# V0141-006-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.14.1 patch audit / release notes guard failed: %s\n' "$1" >&2
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
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.14.1 patch audit / release notes guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-stage-code-audit.md"
RELEASE_NOTES="docs/release/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-notes.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1064ReleaseV0141PatchAuditReleaseNotesCloseout

for anchor in \
  "GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES" \
  "TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES" \
  "V0141-006-PATCH-AUDIT" \
  "V0141-006-RELEASE-NOTES" \
  "V0141-006-VALIDATION-SUMMARY" \
  "V0141-006-LOCAL-EVIDENCE-WORDING" \
  "V0141-006-NO-PRODUCTION-CUTOVER" \
  "V0141-006-NO-TAG-OR-RELEASE-PUBLICATION"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$RELEASE_NOTES" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for carried_anchor in \
  "GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE" \
  "GH-1060-VERIFY-V0141-CODABLE-DECODE-VALIDATION" \
  "GH-1061-VERIFY-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS" \
  "GH-1062-VERIFY-V0141-GOLDEN-JSON-CONTRACTS" \
  "GH-1063-VERIFY-V0141-DASHBOARD-LOCAL-ARTIFACTS"; do
  require_file_contains "$AUDIT" "$carried_anchor"
  require_file_contains "$RELEASE_NOTES" "$carried_anchor"
  require_file_contains "$LATEST" "$carried_anchor"
done

for completed_issue in "#1059" "#1060" "#1061" "#1062" "#1063" "#1064"; do
  require_file_contains "$AUDIT" "$completed_issue"
  require_file_contains "$RELEASE_NOTES" "$completed_issue"
done

for merged_pr in "#1077" "#1078" "#1079" "#1080" "#1081"; do
  require_file_contains "$AUDIT" "$merged_pr"
done

for merge_commit in \
  "ac0300632891f1571c45d0296d853729f12661b2" \
  "7d6ac0f1e97fb3296811a8ffe5e912e4d03e4fa4" \
  "72cc29d6cdca118b9ac05c7f3f0c09a41f3de179" \
  "5ffe5d35eb307f270f4f2be00c978e85e674c0ca" \
  "3a5cf5d8f71bf7faa41fba790c8b06fd8351ae0c"; do
  require_file_contains "$AUDIT" "$merge_commit"
done

require_file_contains "$AUDIT" "local execution evidence chain / testnet evidence only"
require_file_contains "$AUDIT" "not real signed Binance testnet execution release"
require_file_contains "$RELEASE_NOTES" "不是真实 signed Binance testnet execution release"
require_file_contains "$RELEASE_NOTES" "不代表真实 Binance testnet order execution"
require_file_contains "$README" "MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch"
require_file_contains "$GOAL" "MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch"
require_file_contains "$ROADMAP" "GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.1-patch-audit-release-notes.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.14.1-patch-audit-release-notes.sh"
require_file_contains "$READINESS" "Release v0.14.1 patch audit / release notes closeout anchor"
require_file_contains "$LATEST" "v0.14.1 patch audit / release notes closeout"

for file in "$AUDIT" "$RELEASE_NOTES" "$LATEST" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP"; do
  reject_file_contains "$file" "real signed Binance testnet execution complete"
  reject_file_contains "$file" "real Binance testnet order execution complete"
  reject_file_contains "$file" "networkSubmitAttempted=true"
  reject_file_contains "$file" "networkCancelReplaceAttempted=true"
  reject_file_contains "$file" "testnetOrderSubmissionAllowed=true"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

printf 'MTPRO release v0.14.1 patch audit / release notes verification passed.\n'
