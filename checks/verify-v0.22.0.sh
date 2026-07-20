#!/usr/bin/env bash
set -euo pipefail

# GH-1319-VERIFY-V0220-AGGREGATE-VALIDATION
# TVM-RELEASE-V0220-AGGREGATE-VALIDATION
# V0220-011-AGGREGATE-VALIDATION-SUITE
# V0220-011-LIVE-CANARY-TRANSPORT-CHAIN
# V0220-011-FOCUSED-GUARDS-COVERED
# V0220-011-RUN-AUTOMATION-WIRING
# V0220-011-FAIL-CLOSED-NEGATIVE-CASES
# V0220-011-NO-FUTURES-OKX
# V0220-011-NO-PRODUCTION-CUTOVER
# V0220-011-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

require_executable() {
  local file="$1"

  if [[ ! -x "$file" ]]; then
    printf 'release v0.22.0 aggregate validation failed: %s must exist and be executable\n' "$file" >&2
    exit 1
  fi
}

FOCUSED_VERIFIERS=(
  "checks/verify-v0.22.0-live-canary-transport-contract.sh"
  "checks/verify-v0.22.0-operator-approval-run-lock.sh"
  "checks/verify-v0.22.0-credential-secret-material-read-redaction.sh"
  "checks/verify-v0.22.0-signed-account-runtime-preflight.sh"
  "checks/verify-v0.22.0-live-order-submit-transport.sh"
  "checks/verify-v0.22.0-status-cancel-transport.sh"
  "checks/verify-v0.22.0-oms-evidence-log.sh"
  "checks/verify-v0.22.0-reconciliation-evidence.sh"
  "checks/verify-v0.22.0-failure-rollback-drill.sh"
  "checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh"
)

for verifier in "${FOCUSED_VERIFIERS[@]}"; do
  require_executable "$verifier"
  bash "$verifier"
done

READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="verification.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1319-VERIFY-V0220-AGGREGATE-VALIDATION"
  require_file_contains "$file" "TVM-RELEASE-V0220-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0220-011-AGGREGATE-VALIDATION-SUITE"
  require_file_contains "$file" "V0220-011-LIVE-CANARY-TRANSPORT-CHAIN"
  require_file_contains "$file" "V0220-011-FOCUSED-GUARDS-COVERED"
  require_file_contains "$file" "V0220-011-RUN-AUTOMATION-WIRING"
  require_file_contains "$file" "V0220-011-FAIL-CLOSED-NEGATIVE-CASES"
  require_file_contains "$file" "V0220-011-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-011-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0220-011-NO-TAG-OR-RELEASE-PUBLICATION"
done

for verifier in "${FOCUSED_VERIFIERS[@]}"; do
  require_file_contains "$0" "$verifier"
  require_file_contains "$AUTOMATION_SCRIPT" "$verifier"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0.sh"
require_file_contains "$READINESS" "Release v0.22.0 aggregate validation suite anchor"
require_file_contains "$PLAN" "GH-1319 Release v0.22.0 Aggregate Validation Suite"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-AGGREGATE-VALIDATION"
require_file_contains "$LATEST" "v0.22.0 aggregate validation suite"
require_file_contains "$VERIFICATION" "MTPRO Release v0.22.0 Aggregate Validation Suite"

for file in "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "futuresEnabled=true"
  reject_file_contains "$file" "okxEnabled=true"
  reject_file_contains "$file" "dashboardTradingButtonVisible=true"
  reject_file_contains "$file" "tradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "rawOrderIDVisible=true"
  reject_file_contains "$file" "rawBrokerPayloadVisible=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.22.0 aggregate validation suite passed."
