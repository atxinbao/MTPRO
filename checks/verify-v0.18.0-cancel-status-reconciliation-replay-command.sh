#!/usr/bin/env bash
set -euo pipefail

# GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND
# TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND
# V0180-005-DEPENDENCIES-GH1178-GH1179-DONE
# V0180-005-LOCAL-ARTIFACT-REPLAY
# V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED
# V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED
# V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED
# V0180-005-READ-ONLY-OPERATOR-ACTION
# V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED
# V0180-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 cancel/status reconciliation replay guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    printf 'release v0.18.0 cancel/status reconciliation replay guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0180CancelStatusReconciliationReplayCommand.swift"
CONTRACT="docs/contracts/release-v0.18.0-cancel-status-reconciliation-replay-command-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1180CancelStatusReconciliationReplayCommandUsesLocalArtifacts

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND"
  require_file_contains "$file" "TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND"
  require_file_contains "$file" "V0180-005-DEPENDENCIES-GH1178-GH1179-DONE"
  require_file_contains "$file" "V0180-005-LOCAL-ARTIFACT-REPLAY"
  require_file_contains "$file" "V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED"
  require_file_contains "$file" "V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED"
  require_file_contains "$file" "V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED"
  require_file_contains "$file" "V0180-005-READ-ONLY-OPERATOR-ACTION"
  require_file_contains "$file" "V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED"
  require_file_contains "$file" "V0180-005-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT" "#1178 closed / done"
require_file_contains "$CONTRACT" "#1179 closed / done"
require_file_contains "$CONTRACT" "mtpro operator-run replay-cancel-status-reconciliation"
require_file_contains "$SOURCE" "cancelStatusReconciliationReplayCommand=ReleaseV0180CancelStatusReconciliationReplayCommand"
require_file_contains "$SOURCE" "ReleaseV0180CancelStatusReconciliationReplayInput"
require_file_contains "$SOURCE" "ReleaseV0180CancelStatusReconciliationReplayResult"
require_file_contains "$SOURCE" "localArtifactReplayRequired=true"
require_file_contains "$SOURCE" "observedExpectedLifecycleStateExplained=true"
require_file_contains "$SOURCE" "missingReconciliationFailsClosed=true"
require_file_contains "$SOURCE" "mismatchReconciliationFailsClosed=true"
require_file_contains "$SOURCE" "readOnlyOperatorAction=true"
require_file_contains "$READINESS" "Release v0.18.0 cancel/status reconciliation replay command anchor"
require_file_contains "$PLAN" "GH-1180 Release v0.18.0 Cancel / Status Reconciliation Replay Command"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND"
require_file_contains "$POLICY" "GH-1180 adds the cancel/status reconciliation replay command"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-cancel-status-reconciliation-replay-command.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-cancel-status-reconciliation-replay-command.sh"
require_file_contains "$TESTS" "testGH1180CancelStatusReconciliationReplayCommandUsesLocalArtifacts"

for file in "$SOURCE" "$CONTRACT"; do
  reject_file_contains "$file" "api.binance.com"
  reject_file_contains "$file" "www.okx.com"
  reject_file_contains "$file" "URLSession"
  reject_file_contains "$file" "URLRequest"
  reject_file_contains "$file" "submitOrder"
  reject_file_contains "$file" "cancelOrder"
  reject_file_contains "$file" "replaceOrder"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled=true"
done

echo "MTPRO release v0.18.0 cancel/status reconciliation replay command verification passed."
