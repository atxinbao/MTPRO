#!/usr/bin/env bash
set -euo pipefail

# GH-853-VERIFY-V090-RUN-MONITOR-EXPORT-BUNDLE
# TVM-RELEASE-V090-RUN-MONITOR-EXPORT-BUNDLE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 run monitor export bundle verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 run monitor export bundle verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
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

swift test --filter TargetGraphTests/testGH853RunMonitorExportBundleIsChecksumBackedAndRedacted

require_file_contains "$SOURCE" "ReleaseV090RunMonitorExportBundleReadModel"
require_file_contains "$SOURCE" "ReleaseV090RunMonitorExportBundleEntry"
require_file_contains "$SOURCE" "ReleaseV090RunMonitorExportBundleRole"
require_file_contains "$SOURCE" "run-monitor-export-bundle.json"
require_file_contains "$SOURCE" "runMonitorExportBundleJSONPath"
require_file_contains "$SOURCE" "runBundleChecksum"
require_file_contains "$SOURCE" "monitorBundleChecksum"
require_file_contains "$SOURCE" "riskPolicyBundleChecksum"
require_file_contains "$SOURCE" "reconciliationBundleChecksum"
require_file_contains "$SOURCE" "redactionProofChecksum"
require_file_contains "$SOURCE" "recordRunMonitorExportBundle"
require_file_contains "$SOURCE" "runMonitorExportBundle"
require_file_contains "$TARGET_TESTS" "testGH853RunMonitorExportBundleIsChecksumBackedAndRedacted"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-run-monitor-export-bundle.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 Run and monitor export bundle anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-853-VERIFY-V090-RUN-MONITOR-EXPORT-BUNDLE"
require_file_contains "$VALIDATION_PLAN" "GH-853 Release v0.9.0 Run Monitor Export Bundle Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-RUN-MONITOR-EXPORT-BUNDLE"
require_file_contains "$CONTRACT" "V090-011-RUN-MONITOR-EXPORT-BUNDLE"

for anchor in \
  "GH-853-VERIFY-V090-RUN-MONITOR-EXPORT-BUNDLE" \
  "TVM-RELEASE-V090-RUN-MONITOR-EXPORT-BUNDLE" \
  "V090-011-RUN-MONITOR-EXPORT-BUNDLE" \
  "V090-011-RUN-BUNDLE-CHECKSUM" \
  "V090-011-MONITOR-BUNDLE-CHECKSUM" \
  "V090-011-RISK-POLICY-BUNDLE-CHECKSUM" \
  "V090-011-RECONCILIATION-BUNDLE-CHECKSUM" \
  "V090-011-REDACTION-PROOF" \
  "V090-011-LOCAL-EXPORT-ONLY" \
  "V090-011-NO-UPLOAD-NOTIFICATION-SIDE-EFFECT" \
  "V090-011-NO-RAW-SECRET-LISTENKEY-PRIVATE-PAYLOAD" \
  "V090-011-NO-PRODUCTION-DATA-EXPORT" \
  "V090-011-NO-PRODUCTION-CUTOVER"; do
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
reject_file_contains "$SOURCE" "uploadSideEffectEnabled=true"
reject_file_contains "$SOURCE" "notificationWebhookEnabled=true"
reject_file_contains "$SOURCE" "productionDataExported=true"
reject_file_contains "$SOURCE" "externalSharingEnabled=true"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "brokerEndpointConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"

echo "MTPRO release v0.9.0 run monitor export bundle verification passed."
