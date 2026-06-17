#!/usr/bin/env bash
set -euo pipefail

# V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK
# TVM-RELEASE-V091-PATCH-AUDIT-DOCS-RUNBOOK

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.1 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.1 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.9.1-dashboard-macos-v090-guards.sh
bash checks/verify-v0.9.1-cli-verify-v090-wording.sh
swift test --filter TargetGraphTests/testV091DashboardGuardAndCLIMonitorStoreBindingPatch

AUDIT="docs/audit/mtpro-release-v0.9.1-v090-audit-hardening-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.9.1-v090-audit-hardening-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$AUDIT" "MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch"
require_file_contains "$AUDIT" "V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "TVM-RELEASE-V091-PATCH-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "mtpro verify v0.9.0"
require_file_contains "$AUDIT" "ReleaseV090TestnetReadOnlyMonitorSessionStore"
require_file_contains "$AUDIT" "production cutover 仍未授权"
require_file_contains "$NOTES" "MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch Notes"
require_file_contains "$NOTES" "v0.9.1 不发布 tag"
require_file_contains "$LATEST" "Release v0.9.1 Audit Hardening Patch Snapshot"
require_file_contains "README.md" "v0.9.1 patch evidence"
require_file_contains "README.md" "bash checks/verify-v0.9.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK"
require_file_contains "$TESTS" "testV091DashboardGuardAndCLIMonitorStoreBindingPatch"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.1.sh"

for forbidden in \
  "productionTradingEnabledByDefault == true" \
  "productionCutoverAuthorized=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
done

echo "MTPRO release v0.9.1 aggregate validation passed."
