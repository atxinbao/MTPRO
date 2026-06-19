#!/usr/bin/env bash
set -euo pipefail

# GH-950-VERIFY-V0111-PATCH-AGGREGATE-GUARD
# TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD
# V0111-006-PATCH-AGGREGATE-VERIFY
# V0111-006-RELEASE-FACT-SYNC
# V0111-006-DASHBOARD-MACOS-SHA256-STATE
# V0111-006-ARTIFACT-SYMLINK-PERMISSIONS
# V0111-006-NO-PRODUCTION-CUTOVER
# GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES
# V0111-007-PATCH-AUDIT
# V0111-007-RELEASE-NOTES
# V0111-007-VALIDATION-SUMMARY
# V0111-007-AGGREGATE-VERIFY
# V0111-007-NO-PRODUCTION-CUTOVER
# V0111-007-NO-TAG-OR-RELEASE-MOVE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.11.1 aggregate guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.11.1 aggregate guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

AGGREGATE="$0"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
AUDIT="docs/audit/mtpro-release-v0.11.1-readiness-runtime-guard-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.11.1-readiness-runtime-guard-patch-notes.md"
POLICY="docs/release/release-publication-policy.md"

bash checks/verify-v0.11.1-release-fact-sync.sh
bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh
bash checks/verify-v0.11.1-readiness-artifact-symlink-root.sh
bash checks/verify-v0.11.1-readiness-artifact-permissions.sh
swift test --filter TargetGraphTests/testGH950ReleaseV0111PatchAggregateVerifierAnchors
swift test --filter TargetGraphTests/testGH951ReleaseV0111PatchAuditReleaseNotesCloseout

for anchor in \
  "GH-950-VERIFY-V0111-PATCH-AGGREGATE-GUARD" \
  "TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD" \
  "V0111-006-PATCH-AGGREGATE-VERIFY" \
  "V0111-006-RELEASE-FACT-SYNC" \
  "V0111-006-DASHBOARD-MACOS-SHA256-STATE" \
  "V0111-006-ARTIFACT-SYMLINK-PERMISSIONS" \
  "V0111-006-NO-PRODUCTION-CUTOVER" \
  "GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES" \
  "TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES" \
  "V0111-007-PATCH-AUDIT" \
  "V0111-007-RELEASE-NOTES" \
  "V0111-007-VALIDATION-SUMMARY" \
  "V0111-007-AGGREGATE-VERIFY" \
  "V0111-007-NO-PRODUCTION-CUTOVER" \
  "V0111-007-NO-TAG-OR-RELEASE-MOVE"; do
  require_file_contains "$AGGREGATE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for focused_guard in \
  "bash checks/verify-v0.11.1-release-fact-sync.sh" \
  "bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh" \
  "bash checks/verify-v0.11.1-readiness-artifact-symlink-root.sh" \
  "bash checks/verify-v0.11.1-readiness-artifact-permissions.sh"; do
  require_file_contains "$AGGREGATE" "$focused_guard"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.11.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.11.1.sh"
require_file_contains "$READINESS" "Release v0.11.1 patch aggregate guard anchor"
require_file_contains "$PLAN" "GH-950 Release v0.11.1 Patch Aggregate Guard Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD"
require_file_contains "$LATEST" "v0.11.1 release fact stale wording guard"
require_file_contains "$LATEST" "v0.11.1 readiness artifact symlink root guard"
require_file_contains "$LATEST" "v0.11.1 readiness artifact permission guard"
require_file_contains "$LATEST" "v0.11.1 patch audit / release notes closeout"
require_file_contains "$TESTS" "testGH950ReleaseV0111PatchAggregateVerifierAnchors"
require_file_contains "$TESTS" "testGH951ReleaseV0111PatchAuditReleaseNotesCloseout"
require_file_contains "$AUDIT" "V0111-007-PATCH-AUDIT"
require_file_contains "$AUDIT" "#945"
require_file_contains "$AUDIT" "#951"
require_file_contains "$AUDIT" "PR `#966`"
require_file_contains "$AUDIT" "PR `#971`"
require_file_contains "$AUDIT" "This PR owns final v0.11.1 Stage Code Audit"
require_file_contains "$NOTES" "V0111-007-RELEASE-NOTES"
require_file_contains "$NOTES" "v0.11.1 是 v0.11.0 public GitHub Release 之后的 readiness runtime guard hardening patch"
require_file_contains "$POLICY" "V0111-007-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$POLICY" "GH-951 不是 release publication gate"
require_file_contains "$POLICY" '不创建 `v0.11.1` tag'
require_file_contains "$POLICY" '不移动、不覆盖、不重写 `v0.11.0` tag 或 GitHub Release'

for carried_anchor in \
  "GH-945-VERIFY-V0111-RELEASE-FACT-STALE-WORDING-GUARD" \
  "GH-946-VERIFY-V0111-DASHBOARD-MACOS-V0110-GUARDS" \
  "GH-947-VERIFY-V0111-DASHBOARD-SHA256-STATE-INVARIANTS" \
  "GH-948-VERIFY-V0111-READINESS-ARTIFACT-SYMLINK-ROOT" \
  "GH-949-VERIFY-V0111-READINESS-ARTIFACT-PERMISSIONS"; do
  require_file_contains "$READINESS" "$carried_anchor"
  require_file_contains "$PLAN" "$carried_anchor"
  require_file_contains "$MATRIX" "$carried_anchor"
done

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
  "testnetOrderRoutingAllowed=true"; do
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$PLAN" "$forbidden"
  reject_file_contains "$MATRIX" "$forbidden"
done

echo "MTPRO release v0.11.1 aggregate guard verification passed."
