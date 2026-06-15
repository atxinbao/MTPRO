#!/usr/bin/env bash
set -euo pipefail

# GH-812-VERIFY-V080-EVENT-LOG-WRITER-CRASH-RECOVERY
# TVM-RELEASE-V080-EVENT-LOG-WRITER-CRASH-RECOVERY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 event log writer crash recovery verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 event log writer crash recovery verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV060LocalRunJournalWriter.swift"

swift test --filter TargetGraphTests/testGH812RuntimeEventLogWriterHardensCrashRecoverySchemaQuarantineAndCompactionPolicy

require_file_contains "$SOURCE" "ReleaseV080RuntimeEventLogCrashRecoveryPolicy"
require_file_contains "$SOURCE" "ReleaseV080RuntimeEventLogQuarantineLine"
require_file_contains "$SOURCE" "ReleaseV080RuntimeEventLogQuarantineResult"
require_file_contains "$SOURCE" "quarantineCorruptedRuntimeEventLogLines"
require_file_contains "$SOURCE" "events.jsonl.quarantine"
require_file_contains "$SOURCE" "v0.8.0.runtime-event-log-record.v1"
require_file_contains "$SOURCE" "append-only-no-compaction-v0.8.0"
require_file_contains "$SOURCE" "quarantine-complete-corrupted-lines-without-silent-loss"
require_file_contains "$SOURCE" "duplicateRunIDRejected"
require_file_contains "$SOURCE" "duplicateEventIDRejected"
require_file_contains "$SOURCE" "GH-812"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-event-log-writer-crash-recovery.sh"
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "V080-006-EVENT-LOG-WRITER-CRASH-RECOVERY"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 EventLogWriter crash recovery anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-812 Release v0.8.0 EventLogWriter Crash Recovery Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-EVENT-LOG-WRITER-CRASH-RECOVERY"
require_file_contains "checks/automation-readiness.sh" "GH-812-VERIFY-V080-EVENT-LOG-WRITER-CRASH-RECOVERY"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH812RuntimeEventLogWriterHardensCrashRecoverySchemaQuarantineAndCompactionPolicy"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretResolutionEnabled=true"
reject_file_contains "$SOURCE" "productionEndpointConnectionEnabled=true"
reject_file_contains "$SOURCE" "realOrderAuthorizationEnabled=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"

echo "MTPRO release v0.8.0 EventLogWriter crash recovery verification passed."
