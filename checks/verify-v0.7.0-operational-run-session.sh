#!/usr/bin/env bash
set -euo pipefail

# GH-783-VERIFY-V070-OPERATIONAL-RUN-SESSION
# TVM-RELEASE-V070-OPERATIONAL-RUN-SESSION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 operational run session verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 operational run session verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV070OperationalRunSession.swift"

swift test --filter TargetGraphTests/testGH783OperationalRunSessionLifecycleIsDeterministicNoOrderAndRejectsInvalidTransitions

require_file_contains "$SOURCE" "ReleaseV070OperationalRunSession"
require_file_contains "$SOURCE" "ReleaseV070OperationalRunSessionState"
require_file_contains "$SOURCE" "case created"
require_file_contains "$SOURCE" "case starting"
require_file_contains "$SOURCE" "case running"
require_file_contains "$SOURCE" "case stopping"
require_file_contains "$SOURCE" "case stopped"
require_file_contains "$SOURCE" "case failed"
require_file_contains "$SOURCE" "case completed"
require_file_contains "$SOURCE" "case recovered"
require_file_contains "$SOURCE" "ReleaseV070OperationalRunSessionCommand"
require_file_contains "$SOURCE" "case start"
require_file_contains "$SOURCE" "case stop"
require_file_contains "$SOURCE" "case complete"
require_file_contains "$SOURCE" "case fail"
require_file_contains "$SOURCE" "case recover"
require_file_contains "$SOURCE" "ReleaseV070OperationalRunSessionEvidenceEnvelope"
require_file_contains "$SOURCE" "productionTradingEnabledByDefault == false"
require_file_contains "$SOURCE" "productionSecretRead == false"
require_file_contains "$SOURCE" "productionEndpointConnected == false"
require_file_contains "$SOURCE" "productionBrokerConnected == false"
require_file_contains "$SOURCE" "productionOrderSubmitted == false"
require_file_contains "$SOURCE" "productionCutoverAuthorized == false"
require_file_contains "$SOURCE" "testnetOrderSubmissionAllowed == false"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-operational-run-session.sh"
require_file_contains "docs/validation/validation-plan.md" "GH-783 Release v0.7.0 Operational Run Session Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-OPERATIONAL-RUN-SESSION"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 operational run session lifecycle anchor"
require_file_contains "checks/automation-readiness.sh" "GH-783-VERIFY-V070-OPERATIONAL-RUN-SESSION"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"

echo "MTPRO release v0.7.0 operational run session verification passed."
