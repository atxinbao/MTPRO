#!/usr/bin/env bash
set -euo pipefail

# GH-734-VERIFY-V050-RISKENGINE-RUNTIME-RUNNER
# TVM-RELEASE-V050-RISKENGINE-RUNTIME-RUNNER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 RiskEngine runner verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 RiskEngine runner verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH734RiskEngineRuntimeRunnerConsumesStrategyIntentAndEmitsReplayableDecisions

require_file_contains \
  "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" \
  "ReleaseV050RiskEngineRuntimeRunner"
require_file_contains \
  "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" \
  "StrategyIntentEvent"
require_file_contains \
  "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" \
  "RiskDecisionEvent"
require_file_contains \
  "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" \
  "ReleaseV050RiskEngineRuntimePolicy"
require_file_contains \
  "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" \
  "ReleaseV050RiskEngineRuntimeRunnerContract"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "V050-09-RISKENGINE-RUNTIME-RUNNER"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "V050-09-STRATEGY-INTENT-TO-RISK-DECISION"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "V050-09-NOTIONAL-EXPOSURE-POLICY-EVIDENCE"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "V050-09-KILL-SWITCH-NO-TRADE-BLOCKS"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "V050-09-RUN-JOURNAL-REPLAYABLE-RISK-DECISIONS"
require_file_contains \
  "docs/contracts/release-v0.5.0-riskengine-runtime-runner-contract.md" \
  "TVM-RELEASE-V050-RISKENGINE-RUNTIME-RUNNER"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-riskengine.sh"

reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "URLSession"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "URLRequest"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "api.binance.com"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "fapi.binance.com"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "submitOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "cancelOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "replaceOrder"
reject_file_contains "Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift" "HMAC<"

echo "MTPRO release v0.5.0 RiskEngine runtime runner verification passed."
