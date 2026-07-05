#!/usr/bin/env bash
set -euo pipefail

# GH-1315-VERIFY-V0220-OMS-EVIDENCE-LOG
# TVM-RELEASE-V0220-OMS-EVIDENCE-LOG
# V0220-007-BLOCKED-BY-GH1313-GH1314
# V0220-007-APPEND-ONLY-OMS-EVENT-LOG
# V0220-007-SUBMIT-ACK-STATUS-CANCEL-TERMINAL-EVENTS
# V0220-007-CORRELATION-CAUSATION-IDS
# V0220-007-REDACTED-REPLAYABLE-EVIDENCE
# V0220-007-REJECTS-MISSING-OUT-OF-ORDER-LIFECYCLE
# V0220-007-NO-FUTURES-OKX
# V0220-007-NO-DASHBOARD-TRADING-CONTROLS
# V0220-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 OMS event log guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 OMS event log guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryOMSEventLog.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-oms-evidence-log.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1315ReleaseV0220OMSEventLogPersistsExchangeAckStatusCancelEvidence

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1315-VERIFY-V0220-OMS-EVIDENCE-LOG"
  require_file_contains "$file" "TVM-RELEASE-V0220-OMS-EVIDENCE-LOG"
  require_file_contains "$file" "V0220-007-BLOCKED-BY-GH1313-GH1314"
  require_file_contains "$file" "V0220-007-APPEND-ONLY-OMS-EVENT-LOG"
  require_file_contains "$file" "V0220-007-SUBMIT-ACK-STATUS-CANCEL-TERMINAL-EVENTS"
  require_file_contains "$file" "V0220-007-CORRELATION-CAUSATION-IDS"
  require_file_contains "$file" "V0220-007-REDACTED-REPLAYABLE-EVIDENCE"
  require_file_contains "$file" "V0220-007-REJECTS-MISSING-OUT-OF-ORDER-LIFECYCLE"
  require_file_contains "$file" "V0220-007-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-007-NO-DASHBOARD-TRADING-CONTROLS"
  require_file_contains "$file" "V0220-007-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryOMSEventLogEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence"
require_file_contains "$CONTRACT_SOURCE" "appendOnlyOrderingRequired"
require_file_contains "$CONTRACT_SOURCE" "correlationCausationIDsRequired"
require_file_contains "$CONTRACT_SOURCE" "redactedReplayableEvidenceRequired"
require_file_contains "$CONTRACT_SOURCE" "missingOrOutOfOrderLifecycleFailsClosed"
require_file_contains "$CONTRACT_SOURCE" "acceptedLifecycleEntries"
require_file_contains "$CONTRACT_SOURCE" "causationChainHeld"
require_file_contains "$CONTRACT_SOURCE" "missingStatusFixture"
require_file_contains "$CONTRACT_SOURCE" "missingCancelOutcomeFixture"
require_file_contains "$CONTRACT_SOURCE" "outOfOrderFixture"
require_file_contains "$CONTRACT_SOURCE" "correlationMismatchFixture"
require_file_contains "$CONTRACT_SOURCE" "rawPayloadRejectedFixture"
require_file_contains "$CONTRACT_DOC" "append-only OMS event log evidence"
require_file_contains "$CONTRACT_DOC" "submit ack -> status observation -> cancel request -> cancel ack -> terminal state -> ambiguous state"
require_file_contains "$README" "v0.22.0 OMS event log"
require_file_contains "$READINESS" "Release v0.22.0 OMS event log anchor"
require_file_contains "$PLAN" "GH-1315 Release v0.22.0 OMS Event Log"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-OMS-EVIDENCE-LOG"
require_file_contains "$VERIFICATION" "GH-1315 v0.22.0 OMS Event Log"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-oms-evidence-log.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-oms-evidence-log.sh"
require_file_contains "$TESTS" "testGH1315ReleaseV0220OMSEventLogPersistsExchangeAckStatusCancelEvidence"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "rawPayloadPersisted=true"
  reject_file_contains "$file" "rawCredentialValuePersisted=true"
  reject_file_contains "$file" "signaturePersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "Futures live execution started"
  reject_file_contains "$file" "OKX active implementation started"
  reject_file_contains "$file" "Dashboard trading button enabled"
done

echo "MTPRO release v0.22.0 OMS event log verification passed."
