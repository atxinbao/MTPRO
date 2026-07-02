#!/usr/bin/env bash
set -euo pipefail

# GH-1282-VERIFY-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION
# TVM-RELEASE-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION
# V0210-010-OMS-EVENT-LOG
# V0210-010-CANARY-LIFECYCLE-EVENTS
# V0210-010-STATUS-RESPONSES
# V0210-010-CANCEL-OUTCOMES
# V0210-010-RECONCILIATION-EVIDENCE
# V0210-010-REDACTED-EVIDENCE
# V0210-010-NO-BROAD-OMS-ROLLOUT
# V0210-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 canary OMS event log reconciliation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 canary OMS event log reconciliation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210CanaryOMSEventLogReconciliationEvidence.swift"
CONTRACT="docs/contracts/release-v0.21.0-canary-oms-event-log-reconciliation-evidence.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1282ReleaseV0210CanaryOMSEventLogReconciliationEvidence

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1282-VERIFY-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION"
  require_file_contains "$file" "TVM-RELEASE-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION"
  require_file_contains "$file" "V0210-010-OMS-EVENT-LOG"
  require_file_contains "$file" "V0210-010-CANARY-LIFECYCLE-EVENTS"
  require_file_contains "$file" "V0210-010-STATUS-RESPONSES"
  require_file_contains "$file" "V0210-010-CANCEL-OUTCOMES"
  require_file_contains "$file" "V0210-010-RECONCILIATION-EVIDENCE"
  require_file_contains "$file" "V0210-010-REDACTED-EVIDENCE"
  require_file_contains "$file" "V0210-010-NO-BROAD-OMS-ROLLOUT"
  require_file_contains "$file" "V0210-010-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SOURCE" "ReleaseV0210CanaryOMSEventLogReconciliationEvidence"
require_file_contains "$SOURCE" "ReleaseV0210CanaryOMSReconciliationDecision"
require_file_contains "$SOURCE" "ReleaseV0210CanaryOMSEventLogEntry"
require_file_contains "$SOURCE" "GH-1282"
require_file_contains "$SOURCE" "GH-1280"
require_file_contains "$SOURCE" "GH-1281"
require_file_contains "$SOURCE" "GH-1283"
require_file_contains "$SOURCE" "requiredLifecycleKinds"
require_file_contains "$SOURCE" "canaryLifecycleReconstructable"
require_file_contains "$SOURCE" "reconciliationEvidenceRecorded"
require_file_contains "$SOURCE" "broadProductionOMSRuntimeEnabled == false"
require_file_contains "$SOURCE" "rawBrokerPayloadPersisted == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$CONTRACT" "GH-1282"
require_file_contains "$CONTRACT" "GH-1280"
require_file_contains "$CONTRACT" "GH-1281"
require_file_contains "$CONTRACT" "GH-1283"
require_file_contains "$CONTRACT" "OMS event log"
require_file_contains "$CONTRACT" "reconciliation evidence"
require_file_contains "$CONTRACT" "redacted lifecycle"
require_file_contains "$CONTRACT" "does not enable broad production OMS rollout"
require_file_contains "$READINESS" "Release v0.21.0 canary OMS event log reconciliation anchor"
require_file_contains "$PLAN" "GH-1282 Release v0.21.0 Canary OMS Event Log Reconciliation Evidence"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION"
require_file_contains "$LATEST" "v0.21.0 canary OMS event log reconciliation"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-canary-oms-event-log-reconciliation.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-canary-oms-event-log-reconciliation.sh"
require_file_contains "$TESTS" "testGH1282ReleaseV0210CanaryOMSEventLogReconciliationEvidence"

for file in "$SOURCE" "$CONTRACT" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "broadProductionOMSRuntimeEnabled=true"
  reject_file_contains "$file" "futuresReconciliationEnabled=true"
  reject_file_contains "$file" "okxReconciliationEnabled=true"
  reject_file_contains "$file" "rawBrokerPayloadPersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 canary OMS event log reconciliation verification passed."
