#!/usr/bin/env bash
set -euo pipefail

# GH-819-VERIFY-V080-VALIDATION-LANES
# TVM-RELEASE-V080-VALIDATION-LANES

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 validation lanes verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 validation lanes verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

RUNBOOK="docs/operators/release-v0.8.0-validation-lanes-runbook.md"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
WORKFLOW=".github/workflows/checks.yml"
SIGNED_SOURCE="Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetSignedAccountProof.swift"
STREAM_SOURCE="Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetPrivateStreamMonitoringProof.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH819ValidationLanesSeparateDeterministicCIAndManualOperatorNetworkProof

require_file_contains "$WORKFLOW" "workflow_dispatch:"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-validation-lanes.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 validation lanes anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-819-VERIFY-V080-VALIDATION-LANES"
require_file_contains "$VALIDATION_PLAN" "GH-819 Release v0.8.0 Validation Lanes Split Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-VALIDATION-LANES"
require_file_contains "$CONTRACT" "V080-013-VALIDATION-LANES"
require_file_contains "$RUNBOOK" "GH-819-RELEASE-V080-VALIDATION-LANES-RUNBOOK"
require_file_contains "$SIGNED_SOURCE" "deterministicCIProof"
require_file_contains "$SIGNED_SOURCE" "ciRequiresNetwork"
require_file_contains "$SIGNED_SOURCE" "ciRequiresSecrets"
require_file_contains "$STREAM_SOURCE" "deterministicCIProof"
require_file_contains "$STREAM_SOURCE" "ciRequiresNetwork"
require_file_contains "$STREAM_SOURCE" "ciRequiresSecrets"

for anchor in \
  "GH-819-VERIFY-V080-VALIDATION-LANES" \
  "TVM-RELEASE-V080-VALIDATION-LANES" \
  "V080-013-VALIDATION-LANES" \
  "V080-013-DETERMINISTIC-CI-PROOF-LANE" \
  "V080-013-MANUAL-OPERATOR-NETWORK-PROOF-LANE" \
  "V080-013-WORKFLOW-DISPATCH-OPERATOR-CONFIRMATION" \
  "V080-013-REDACTED-PROOF-ARTIFACTS" \
  "V080-013-CI-NO-SECRET-NO-NETWORK" \
  "V080-013-MANUAL-NO-ORDER-SUBMISSION" \
  "V080-013-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$RUNBOOK" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for script in \
  "bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh" \
  "bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh" \
  "bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh" \
  "bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh"; do
  require_file_contains "$RUNBOOK" "$script"
  require_file_contains "$VALIDATION_PLAN" "$script"
  require_file_contains "$TRADING_MATRIX" "$script"
done

reject_file_contains "$RUNBOOK" "productionTradingEnabledByDefault=true"
reject_file_contains "$RUNBOOK" "productionSecretRead=true"
reject_file_contains "$RUNBOOK" "productionEndpointConnected=true"
reject_file_contains "$RUNBOOK" "brokerEndpointConnected=true"
reject_file_contains "$RUNBOOK" "ordersSubmitted=true"
reject_file_contains "$RUNBOOK" "testnetOrderRoutingAllowed=true"
reject_file_contains "$RUNBOOK" "productionCutoverAuthorized=true"

echo "MTPRO release v0.8.0 validation lanes verification passed."
