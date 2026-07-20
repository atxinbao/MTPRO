#!/usr/bin/env bash
set -euo pipefail

# GH-1249-VERIFY-V0200-RELEASE-VALIDATION-SUITE
# TVM-RELEASE-V0200-RELEASE-VALIDATION-SUITE
# V0200-011-AGGREGATE-VALIDATION-SUITE
# V0200-011-FOCUSED-GUARDS-COVERED
# V0200-011-READINESS-REDACTION-NO-ORDER-COVERED
# V0200-011-RUN-AUTOMATION-WIRING
# V0200-011-NO-PRODUCTION-CUTOVER
# V0200-011-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.20.0 aggregate validation suite failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.20.0 aggregate validation suite failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TARGET_GRAPH_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

bash checks/verify-v0.20.0-production-shadow-readiness-contract.sh
bash checks/verify-v0.20.0-production-shadow-environment-profile.sh
bash checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh
bash checks/verify-v0.20.0-credential-reference-readiness.sh
bash checks/verify-v0.20.0-public-market-readonly-probe.sh
bash checks/verify-v0.20.0-signed-account-readonly-readiness.sh
bash checks/verify-v0.20.0-account-snapshot-redaction-policy.sh
bash checks/verify-v0.20.0-no-order-capability-guard.sh
bash checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh
bash checks/verify-v0.20.0-dashboard-cli-read-only-live-readiness-surface.sh
swift test --filter TargetGraphTests/testGH1249ReleaseV0200AggregateValidationSuite

for file in \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$TARGET_GRAPH_TESTS" \
  "$0"; do
  require_contains "$file" "GH-1249-VERIFY-V0200-RELEASE-VALIDATION-SUITE"
  require_contains "$file" "TVM-RELEASE-V0200-RELEASE-VALIDATION-SUITE"
  require_contains "$file" "V0200-011-AGGREGATE-VALIDATION-SUITE"
  require_contains "$file" "V0200-011-FOCUSED-GUARDS-COVERED"
  require_contains "$file" "V0200-011-READINESS-REDACTION-NO-ORDER-COVERED"
  require_contains "$file" "V0200-011-RUN-AUTOMATION-WIRING"
  require_contains "$file" "V0200-011-NO-PRODUCTION-CUTOVER"
  require_contains "$file" "V0200-011-NO-TAG-OR-RELEASE-PUBLICATION"
done

for verifier in \
  "bash checks/verify-v0.20.0-production-shadow-readiness-contract.sh" \
  "bash checks/verify-v0.20.0-production-shadow-environment-profile.sh" \
  "bash checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh" \
  "bash checks/verify-v0.20.0-credential-reference-readiness.sh" \
  "bash checks/verify-v0.20.0-public-market-readonly-probe.sh" \
  "bash checks/verify-v0.20.0-signed-account-readonly-readiness.sh" \
  "bash checks/verify-v0.20.0-account-snapshot-redaction-policy.sh" \
  "bash checks/verify-v0.20.0-no-order-capability-guard.sh" \
  "bash checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh" \
  "bash checks/verify-v0.20.0-dashboard-cli-read-only-live-readiness-surface.sh"; do
  require_contains "$0" "$verifier"
done

require_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.0.sh"
require_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.0.sh"
require_contains "$READINESS" "Release v0.20.0 aggregate validation suite anchor"
require_contains "$LATEST" "v0.20.0 aggregate validation suite"
require_contains "$PLAN" "GH-1249 Release v0.20.0 Aggregate Validation Suite"
require_contains "$MATRIX" "TVM-RELEASE-V0200-RELEASE-VALIDATION-SUITE"
require_contains "$TARGET_GRAPH_TESTS" "testGH1249ReleaseV0200AggregateValidationSuite"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$0"; do
  reject_contains "$file" "productionTradingEnabledByDefault=true"
  reject_contains "$file" "productionSecretValueRead=true"
  reject_contains "$file" "productionEndpointConnected=true"
  reject_contains "$file" "brokerEndpointConnected=true"
  reject_contains "$file" "signedOrderMaterialGenerated=true"
  reject_contains "$file" "accountEndpointConnected=true"
  reject_contains "$file" "orderEndpointTouched=true"
  reject_contains "$file" "submitCancelReplaceEnabled=true"
  reject_contains "$file" "dashboardTradingButtonVisible=true"
  reject_contains "$file" "orderFormVisible=true"
  reject_contains "$file" "liveCommandVisible=true"
  reject_contains "$file" "spotCanaryEnabled=true"
  reject_contains "$file" "futuresRuntimeEnabled=true"
  reject_contains "$file" "okxActiveImplementationEnabled=true"
  reject_contains "$file" "productionCutoverAuthorized=true"
  reject_contains "$file" "createsTagOrRelease=true"
  reject_contains "$file" "API Key:"
  reject_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.20.0 aggregate validation suite passed.\n'
