#!/usr/bin/env bash
set -euo pipefail

# GH-889-VERIFY-V0100-INCIDENT-ROLLBACK-RUNBOOK
# TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK

fail() {
  echo "release v0.10.0 incident rollback runbook verification failed: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_file_contains() {
  local path="$1"
  local expected="$2"
  grep -Fq "$expected" "$path" || fail "$path must contain: $expected"
}

require_file_not_contains() {
  local path="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$path"; then
    fail "$path must not contain: $forbidden"
  fi
}

RUNBOOK="docs/operators/release-v0.10.0-production-readiness-runbook.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100IncidentRollbackReadinessRunbook.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"

for path in "$RUNBOOK" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-012-INCIDENT-ROLLBACK-READINESS-RUNBOOK" \
  "V0100-012-PRODUCTION-READINESS-RUNBOOK-MD" \
  "V0100-012-INCIDENT-ROLLBACK-READINESS-JSON" \
  "V0100-012-INCIDENT-CLASSIFICATION" \
  "V0100-012-STOP-PROCEDURE" \
  "V0100-012-ROLLBACK-PROCEDURE" \
  "V0100-012-OPERATOR-CHAIN" \
  "V0100-012-EVIDENCE-EXPORT" \
  "V0100-012-POST-INCIDENT-AUDIT" \
  "V0100-012-KILL-SWITCH-CHECKLIST" \
  "V0100-012-NO-TRADE-CHECKLIST" \
  "V0100-012-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-889-VERIFY-V0100-INCIDENT-ROLLBACK-RUNBOOK" \
  "TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK"; do
  require_file_contains "$RUNBOOK" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for exact in \
  "incident_rollback_readiness.json" \
  "runbookChecksum=sha256:" \
  "evidenceChecksum=sha256:" \
  "incidentClassificationCovered=true" \
  "stopProcedureCovered=true" \
  "rollbackProcedureCovered=true" \
  "operatorChainCovered=true" \
  "evidenceExportCovered=true" \
  "postIncidentAuditCovered=true" \
  "killSwitchChecklistCovered=true" \
  "noTradeChecklistCovered=true" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverAuthorized=false" \
  "orderSubmissionEnabled=false" \
  "productionTradingEnabled=false" \
  "no_secret_value=true" \
  "noSecretValue=true" \
  "no_order_payload=true" \
  "noOrderPayload=true"; do
  require_file_contains "$RUNBOOK" "$exact"
done

for classification in \
  "monitor anomaly" \
  "credential exposure suspected" \
  "endpoint policy drift" \
  "risk limit breach" \
  "command surface regression" \
  "readiness evidence mismatch"; do
  require_file_contains "$RUNBOOK" "$classification"
  require_file_contains "$SOURCE" "$classification"
done

require_file_contains "$SOURCE" "ReleaseV0100IncidentRollbackReadinessRunbook"
require_file_contains "$SOURCE" "ReleaseV0100IncidentRollbackClassification"
require_file_contains "$SOURCE" "ReleaseV0100IncidentRollbackReadinessSection"
require_file_contains "$SOURCE" "ReleaseV0100IncidentRollbackReadinessArtifact"
require_file_contains "$TESTS" "testGH889IncidentRollbackReadinessRunbookKeepsProductionCutoverDisabled"
require_file_contains "$PLAN" "GH-889 Release v0.10.0 Incident / Rollback Readiness Runbook Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK"
require_file_contains "$READINESS" "Release v0.10.0 incident / rollback readiness runbook anchor"
require_file_contains "$LATEST" "\`#889\` 定义 IncidentRollbackReadinessRunbook reference-only runbook"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-incident-rollback-runbook.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-incident-rollback-runbook.sh"

for forbidden in \
  "productionCutoverAuthorized=true" \
  "orderSubmissionEnabled=true" \
  "productionTradingEnabled=true" \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "orderPayloadCreated=true" \
  "brokerCommandCreated=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonVisible=true" \
  "orderFormVisible=true" \
  "liveCommandEnabled=true" \
  "incidentRunbookConvertedToTradingPermission=true" \
  "rollbackBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "containsOrderPayload=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$RUNBOOK" "$forbidden"
done

echo "MTPRO release v0.10.0 incident rollback runbook verification passed."
