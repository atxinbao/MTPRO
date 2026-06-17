#!/usr/bin/env bash
set -euo pipefail

# GH-850-VERIFY-V090-ALERT-READ-MODEL
# TVM-RELEASE-V090-ALERT-READ-MODEL

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 alert read-model verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 alert read-model verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH850MonitorAlertReadModelBindsFreshnessAndHeartbeatWithoutNotificationSideEffects

require_file_contains "$SOURCE" "ReleaseV090MonitorAlertReadModel"
require_file_contains "$SOURCE" "ReleaseV090MonitorAlert"
require_file_contains "$SOURCE" "ReleaseV090MonitorAlertSeverity"
require_file_contains "$SOURCE" "ReleaseV090MonitorAlertSource"
require_file_contains "$SOURCE" "ReleaseV090MonitorAlertLifecycle"
require_file_contains "$SOURCE" "alert_id"
require_file_contains "$SOURCE" "ack_required"
require_file_contains "$SOURCE" "severity"
require_file_contains "$SOURCE" "reason"
require_file_contains "$SOURCE" "source"
require_file_contains "$SOURCE" "lifecycle"
require_file_contains "$SOURCE" "monitorAlertReadModel"
require_file_contains "$SOURCE" "account-snapshot-freshness.json"
require_file_contains "$SOURCE" "private-stream-heartbeat.json"
require_file_contains "$SOURCE" "monitorSessionChecksum"
require_file_contains "$SOURCE" "sourceChecksum"
require_file_contains "$SOURCE" "notificationSideEffectsEnabled"
require_file_contains "$SOURCE" "smsNotificationSent"
require_file_contains "$SOURCE" "emailNotificationSent"
require_file_contains "$SOURCE" "webhookNotificationSent"
require_file_contains "$SOURCE" "pushNotificationSent"
require_file_contains "$SOURCE" "externalServiceCalled"
require_file_contains "$SOURCE" "automatedTradingReactionEnabled"
require_file_contains "$TARGET_TESTS" "testGH850MonitorAlertReadModelBindsFreshnessAndHeartbeatWithoutNotificationSideEffects"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-alert-read-model.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 alert read-model anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-850-VERIFY-V090-ALERT-READ-MODEL"
require_file_contains "$VALIDATION_PLAN" "GH-850 Release v0.9.0 Alert Read-model Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-ALERT-READ-MODEL"
require_file_contains "$CONTRACT" "V090-008-ALERT-READ-MODEL"

for anchor in \
  "GH-850-VERIFY-V090-ALERT-READ-MODEL" \
  "TVM-RELEASE-V090-ALERT-READ-MODEL" \
  "V090-008-ALERT-READ-MODEL" \
  "V090-008-ALERT-FIELDS" \
  "V090-008-MONITOR-SESSION-EVIDENCE-BINDING" \
  "V090-008-LOCAL-READ-MODEL-ONLY" \
  "V090-008-NO-NOTIFICATION-SIDE-EFFECTS" \
  "V090-008-NO-AUTOMATED-TRADING-REACTION" \
  "V090-008-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

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
reject_file_contains "$SOURCE" "notificationSideEffectsEnabled=true"
reject_file_contains "$SOURCE" "smsNotificationSent=true"
reject_file_contains "$SOURCE" "emailNotificationSent=true"
reject_file_contains "$SOURCE" "webhookNotificationSent=true"
reject_file_contains "$SOURCE" "pushNotificationSent=true"
reject_file_contains "$SOURCE" "externalServiceCalled=true"
reject_file_contains "$SOURCE" "automatedTradingReactionEnabled=true"

echo "MTPRO release v0.9.0 alert read-model verification passed."
