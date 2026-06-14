#!/usr/bin/env bash
set -euo pipefail

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 RiskEngine runtime runner verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 RiskEngine runtime runner verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GH761="GH-761-VERIFY-V060-RISKENGINE-RUNTIME-RUNNER"
TVM761="TVM-RELEASE-V060-RISKENGINE-RUNTIME-RUNNER"

swift test --filter TargetGraphTests/testGH761RiskEngineRuntimeRunnerConsumesStrategyIntentsAndEmitsAllowRejectBlockedDecisions

require_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "ReleaseV060RiskEngineRuntimeRunner"
require_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "ReleaseV050RiskEngineRuntimePolicy"
require_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "StrategyIntentEvent"
require_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "RiskDecisionEvent"
require_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "RuntimeMessageBus<ReleaseV050RuntimeEventPayload>"

require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-RISKENGINE-RUNTIME-RUNNER"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-STRATEGY-INTENT-TO-RISK-DECISION"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-ALLOW-REJECT-BLOCKED-POLICY-EVIDENCE"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-KILL-SWITCH-NO-TRADE-BLOCKS-OMS"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-SAME-RUN-JOURNAL-RISK-SEQUENCE"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "V060-007-NO-RISK-EXECUTION-PATH"
require_file_contains "docs/contracts/release-v0.6.0-riskengine-runtime-runner-contract.md" "$TVM761"
require_file_contains "docs/validation/trading-validation-matrix.md" "$TVM761"
require_file_contains "docs/validation/validation-plan.md" "GH-761 Release v0.6.0 RiskEngine Runtime Runner Validation"
require_file_contains "docs/validation/validation-plan.md" "$GH761"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 RiskEngine runtime runner anchor"
require_file_contains "checks/automation-readiness.sh" "$GH761"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-riskengine-runtime-runner.sh"

reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "URLSession"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "URLRequest"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "api.binance.com"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "fapi.binance.com"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "/api/v3/account"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "/api/v3/order"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "/api/v3/userDataStream"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "listenKey"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "submitOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "cancelOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "replaceOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift" "HMAC<"

echo "MTPRO release v0.6.0 RiskEngine runtime runner verification passed."
