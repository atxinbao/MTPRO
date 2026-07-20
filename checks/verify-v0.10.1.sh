#!/usr/bin/env bash
set -euo pipefail

# GH-912-VERIFY-V0101-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0101-PATCH-AUDIT-RELEASE-NOTES
# V0101-007-PATCH-AUDIT
# V0101-007-RELEASE-NOTES
# V0101-007-VALIDATION-SUMMARY
# V0101-007-AGGREGATE-VERIFY
# V0101-007-NO-PRODUCTION-CUTOVER
# V0101-007-V0110-RUNTIME-OWNERSHIP

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.1 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.1 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.10.1-release-fact-sync.sh
bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh
bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh
bash checks/verify-v0.10.1-readiness-cli-help.sh
swift test --filter TargetGraphTests/testGH912ReleaseV0101PatchAuditReleaseNotesCloseout

AUDIT="docs/audit/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

for anchor in \
  "GH-912-VERIFY-V0101-PATCH-AUDIT-RELEASE-NOTES" \
  "TVM-RELEASE-V0101-PATCH-AUDIT-RELEASE-NOTES" \
  "V0101-007-PATCH-AUDIT" \
  "V0101-007-RELEASE-NOTES" \
  "V0101-007-VALIDATION-SUMMARY" \
  "V0101-007-AGGREGATE-VERIFY" \
  "V0101-007-NO-PRODUCTION-CUTOVER" \
  "V0101-007-V0110-RUNTIME-OWNERSHIP"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$NOTES" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$AUDIT" "MTPRO Release v0.10.1 Production Readiness Audit Hardening Patch"
require_file_contains "$AUDIT" "PR \`#926\`"
require_file_contains "$AUDIT" "PR \`#927\`"
require_file_contains "$AUDIT" "PR \`#928\`"
require_file_contains "$AUDIT" "PR \`#929\`"
require_file_contains "$AUDIT" "PR \`#930\`"
require_file_contains "$AUDIT" "v0.11.0 remains the target for Production Readiness Evidence Runtime + Integrity Hardening"
require_file_contains "$NOTES" "v0.10.1 是 v0.10.0 stable release 后的 production readiness audit hardening patch"
require_file_contains "$NOTES" "v0.11.0 才拥有 Production Readiness Evidence Runtime + Integrity Hardening"
require_file_contains "$LATEST" "Release v0.10.1 Production Readiness Audit Hardening Patch Snapshot"
require_file_contains "$READINESS" "Release v0.10.1 patch audit / release notes closeout anchor"
require_file_contains "$PLAN" "GH-912 Release v0.10.1 Patch Audit / Release Notes Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0101-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.10.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.10.1.sh"
require_file_contains "$TESTS" "testGH912ReleaseV0101PatchAuditReleaseNotesCloseout"

for issue_anchor in \
  "GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD" \
  "GH-908-VERIFY-V0101-DASHBOARD-MACOS-V0100-GUARDS" \
  "GH-909-VERIFY-V0101-CLI-V0100-WORDING" \
  "GH-910-VERIFY-V0101-READINESS-CLI-HELP" \
  "GH-912-VERIFY-V0101-PATCH-AUDIT-RELEASE-NOTES"; do
  require_file_contains "$AUDIT" "$issue_anchor"
  require_file_contains "$NOTES" "$issue_anchor"
  require_file_contains "$LATEST" "$issue_anchor"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
done

echo "MTPRO release v0.10.1 aggregate validation passed."
