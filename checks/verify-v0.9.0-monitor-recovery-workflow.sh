#!/usr/bin/env bash
set -euo pipefail

# GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW
# TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 monitor recovery workflow verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 monitor recovery workflow verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"

swift test --filter TargetGraphTests/testGH848MonitorRecoveryWorkflowPreservesHistoryAndRedactedEvidence

require_file_contains "$SOURCE" "ReleaseV090MonitorRecoveryDocument"
require_file_contains "$SOURCE" "ReleaseV090MonitorRecoveryAction"
require_file_contains "$SOURCE" "monitor-recovery.json"
require_file_contains "$SOURCE" "recordMonitorRecovery"
require_file_contains "$SOURCE" "monitorRecovery"
require_file_contains "$SOURCE" "eventHistoryPreserved"
require_file_contains "$SOURCE" "previousEventChecksums"
require_file_contains "$SOURCE" "recoveredEventChecksums"
require_file_contains "$SOURCE" "reopenedListenKeyEvidence"
require_file_contains "$SOURCE" "rebuiltReadModelEvidenceChecksum"
require_file_contains "$SOURCE" "manualLocalRecovery"
require_file_contains "$SOURCE" "automaticReconnectCommand"
require_file_contains "$SOURCE" "corruptedMonitorRecovery"
require_file_contains "$SOURCE" "GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "$SOURCE" "TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "$SOURCE" "V090-006-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "$SOURCE" "V090-006-MONITOR-RECOVERY-JSON"
require_file_contains "$SOURCE" "V090-006-PRESERVE-MONITOR-EVENT-HISTORY"
require_file_contains "$SOURCE" "V090-006-LOCAL-MANUAL-RECOVERY-ONLY"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-monitor-recovery-workflow.sh"
require_file_contains "docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md" "V090-006-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.9.0 monitor recovery workflow anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-848 Release v0.9.0 Monitor Recovery Workflow Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "checks/automation-readiness.sh" "GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH848MonitorRecoveryWorkflowPreservesHistoryAndRedactedEvidence"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "productionBrokerConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"
reject_file_contains "$SOURCE" "testnetCancelReplaceAllowed=true"

echo "MTPRO release v0.9.0 monitor recovery workflow verification passed."
