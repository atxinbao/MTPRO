#!/usr/bin/env bash
set -euo pipefail

# GH-784-VERIFY-V070-EVENT-LOG-WRITER-RECOVERY
# TVM-RELEASE-V070-EVENT-LOG-WRITER-RECOVERY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 event log writer recovery verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 event log writer recovery verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV060LocalRunJournalWriter.swift"

swift test --filter TargetGraphTests/testGH784RuntimeEventLogWriterAppendsValidatesAndRecoversPartialLines

require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogWritePolicy"
require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogEvent"
require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogRecord"
require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogAppendResult"
require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogValidation"
require_file_contains "$SOURCE" "appendRuntimeEvents"
require_file_contains "$SOURCE" "validateRuntimeEventLog"
require_file_contains "$SOURCE" "local-lock-directory-per-run"
require_file_contains "$SOURCE" ".events.jsonl.lock"
require_file_contains "$SOURCE" "synchronizeFile()"
require_file_contains "$SOURCE" "truncate-to-last-complete-newline-before-append"
require_file_contains "$SOURCE" "duplicateEventIDRejected"
require_file_contains "$SOURCE" "eventChecksumAlgorithm == \"sha256(payloadJSON)\""
require_file_contains "$SOURCE" "lineChecksumAlgorithm == \"sha256(runID|sequence|eventID|previousLineChecksum|eventChecksum|payloadJSON|createdAt)\""
require_file_contains "$SOURCE" "productionTradingEnabledByDefault == false"
require_file_contains "$SOURCE" "productionSecretResolutionEnabled == false"
require_file_contains "$SOURCE" "productionEndpointConnectionEnabled == false"
require_file_contains "$SOURCE" "realOrderAuthorizationEnabled == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-event-log-writer-recovery.sh"
require_file_contains "docs/validation/validation-plan.md" "GH-784 Release v0.7.0 Event Log Writer Recovery Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-EVENT-LOG-WRITER-RECOVERY"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 event log writer recovery anchor"
require_file_contains "checks/automation-readiness.sh" "GH-784-VERIFY-V070-EVENT-LOG-WRITER-RECOVERY"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"

echo "MTPRO release v0.7.0 event log writer recovery verification passed."
