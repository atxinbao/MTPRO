#!/usr/bin/env bash
set -euo pipefail

# GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS
# TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 snapshot freshness monitor verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 snapshot freshness monitor verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"

swift test --filter TargetGraphTests/testGH846SignedAccountSnapshotFreshnessMonitorPersistsRedactedEvidence

require_file_contains "$SOURCE" "ReleaseV090AccountSnapshotFreshnessDocument"
require_file_contains "$SOURCE" "ReleaseV090AccountSnapshotFreshnessStatus"
require_file_contains "$SOURCE" "ReleaseV090AccountSnapshotAgeBucket"
require_file_contains "$SOURCE" "recordAccountSnapshotFreshness"
require_file_contains "$SOURCE" "accountSnapshotFreshness"
require_file_contains "$SOURCE" "account-snapshot-freshness.json"
require_file_contains "$SOURCE" "snapshotObservedAt"
require_file_contains "$SOURCE" "latencyMilliseconds"
require_file_contains "$SOURCE" "staleThresholdSeconds"
require_file_contains "$SOURCE" "freshnessStatus"
require_file_contains "$SOURCE" "ageBucket"
require_file_contains "$SOURCE" "redactedCredentialReference"
require_file_contains "$SOURCE" "rawPayloadPersisted"
require_file_contains "$SOURCE" "rawAccountPayloadPersisted"
require_file_contains "$SOURCE" "credentialValuePersisted"
require_file_contains "$SOURCE" "corruptedAccountSnapshotFreshness"
require_file_contains "$SOURCE" "unsafeCredentialReference"
require_file_contains "$SOURCE" "GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS"
require_file_contains "$SOURCE" "V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS"
require_file_contains "$SOURCE" "V090-004-ACCOUNT-SNAPSHOT-FRESHNESS-JSON"
require_file_contains "$SOURCE" "V090-004-REDACTED-CREDENTIAL-REFERENCE"
require_file_contains "$SOURCE" "V090-004-NO-RAW-PAYLOAD-PERSISTENCE"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-snapshot-freshness-monitor.sh"
require_file_contains "docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md" "V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.9.0 signed account snapshot freshness monitor anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-846 Release v0.9.0 Signed Account Snapshot Freshness Monitor Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS"
require_file_contains "checks/automation-readiness.sh" "GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH846SignedAccountSnapshotFreshnessMonitorPersistsRedactedEvidence"

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

echo "MTPRO release v0.9.0 signed account snapshot freshness monitor verification passed."
