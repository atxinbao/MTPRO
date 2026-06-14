#!/usr/bin/env bash
set -euo pipefail

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 ExecutionEngine / OMS dry-run runner verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 ExecutionEngine / OMS dry-run runner verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GH762="GH-762-VERIFY-V060-EXECUTION-OMS-DRY-RUN-RUNNER"
TVM762="TVM-RELEASE-V060-EXECUTION-OMS-DRY-RUN-RUNNER"

swift test --filter TargetGraphTests/testGH762ExecutionOMSDryRunRunnerConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmit

require_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "ReleaseV060ExecutionOMSDryRunRunner"
require_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "ReleaseV060RiskEngineRuntimeRunnerResult"
require_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "RiskDecisionEvent"
require_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "OMSLifecycleEvent"
require_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "ExecutionClientDryRunEvent"
require_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "simulatedSubmitted"
require_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "simulatedRejected"
require_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "simulatedFilled"

require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-EXECUTION-OMS-DRY-RUN-RUNNER"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-ALLOWED-RISK-TO-OMS-LIFECYCLE"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-REJECTED-BLOCKED-NO-SUBMIT"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-SIMULATED-SUBMIT-NOT-REAL"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-SAME-RUN-JOURNAL-OMS-SEQUENCE"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "V060-008-NO-PRODUCTION-OMS-BROKER-PATH"
require_file_contains "docs/contracts/release-v0.6.0-execution-oms-dry-run-runner-contract.md" "$TVM762"
require_file_contains "docs/validation/trading-validation-matrix.md" "$TVM762"
require_file_contains "docs/validation/validation-plan.md" "GH-762 Release v0.6.0 ExecutionEngine OMS Dry-run Runner Validation"
require_file_contains "docs/validation/validation-plan.md" "$GH762"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 ExecutionEngine OMS dry-run runner anchor"
require_file_contains "checks/automation-readiness.sh" "$GH762"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-execution-oms-dry-run-runner.sh"

reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "URLSession"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "URLRequest"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "api.binance.com"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "fapi.binance.com"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "/api/v3/account"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "/api/v3/order"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "/api/v3/userDataStream"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "listenKey"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "submitOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "cancelOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "replaceOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift" "HMAC<"

echo "MTPRO release v0.6.0 ExecutionEngine / OMS dry-run runner verification passed."
