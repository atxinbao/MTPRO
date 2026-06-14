#!/usr/bin/env bash
set -euo pipefail

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 Strategy runtime runner verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 Strategy runtime runner verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GH760="GH-760-VERIFY-V060-STRATEGY-RUNTIME-RUNNER"
TVM760="TVM-RELEASE-V060-STRATEGY-RUNTIME-RUNNER"

swift test --filter TargetGraphTests/testGH760StrategyRuntimeRunnerConsumesDataEngineJournalAndEmitsEMARSIIntentEvents

require_file_contains "Package.swift" "\"Runtime/ReleaseV060StrategyRuntimeRunner.swift\""
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "ReleaseV060StrategyRuntimeRunner"
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "EMAProposalRuntime"
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "RSITargetExposureIntentEmitter"
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "StrategyIntentEvent"
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "DataEngineMarketEvent"
require_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "RuntimeMessageBus<ReleaseV050RuntimeEventPayload>"

require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "V060-006-STRATEGY-RUNTIME-RUNNER"
require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "V060-006-EMA-RSI-INTENT-EVENTS"
require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "V060-006-DATAENGINE-CAUSAL-LINK"
require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "V060-006-SAME-RUN-JOURNAL-SEQUENCE"
require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "V060-006-NO-STRATEGY-EXECUTION-PATH"
require_file_contains "docs/contracts/release-v0.6.0-strategy-runtime-runner-contract.md" "$TVM760"
require_file_contains "docs/validation/trading-validation-matrix.md" "$TVM760"
require_file_contains "docs/validation/validation-plan.md" "GH-760 Release v0.6.0 Strategy Runtime Runner Validation"
require_file_contains "docs/validation/validation-plan.md" "$GH760"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 Strategy runtime runner anchor"
require_file_contains "checks/automation-readiness.sh" "$GH760"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-strategy-runtime-runner.sh"

reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "URLSession"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "URLRequest"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "api.binance.com"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "fapi.binance.com"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "/api/v3/account"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "/api/v3/order"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "/api/v3/userDataStream"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "listenKey"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "submitOrder"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "cancelOrder"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "replaceOrder"
reject_file_contains "Sources/Trader/Runtime/ReleaseV060StrategyRuntimeRunner.swift" "HMAC<"

echo "MTPRO release v0.6.0 Strategy runtime runner verification passed."
