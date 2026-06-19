#!/usr/bin/env bash
set -euo pipefail

# GH-950-VERIFY-V0111-PATCH-AGGREGATE-GUARD
# TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD
# V0111-006-PATCH-AGGREGATE-VERIFY
# V0111-006-RELEASE-FACT-SYNC
# V0111-006-DASHBOARD-MACOS-SHA256-STATE
# V0111-006-ARTIFACT-SYMLINK-PERMISSIONS
# V0111-006-NO-PRODUCTION-CUTOVER

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

bash checks/verify-v0.11.1-release-fact-sync.sh
bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh
bash checks/verify-v0.11.1-readiness-artifact-symlink-root.sh
bash checks/verify-v0.11.1-readiness-artifact-permissions.sh
swift test --filter TargetGraphTests/testGH950ReleaseV0111PatchAggregateVerifierAnchors

for anchor in \
  "GH-950-VERIFY-V0111-PATCH-AGGREGATE-GUARD" \
  "TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD" \
  "V0111-006-PATCH-AGGREGATE-VERIFY" \
  "V0111-006-RELEASE-FACT-SYNC" \
  "V0111-006-DASHBOARD-MACOS-SHA256-STATE" \
  "V0111-006-ARTIFACT-SYMLINK-PERMISSIONS" \
  "V0111-006-NO-PRODUCTION-CUTOVER"; do
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
require_file_contains "$TESTS" "testGH950ReleaseV0111PatchAggregateVerifierAnchors"

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
