#!/usr/bin/env bash
set -euo pipefail

# GH-735-VERIFY-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE
# TVM-RELEASE-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 ExecutionEngine / OMS verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 ExecutionEngine / OMS verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH735ExecutionOMSDryRunLifecycleConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmitPaths

require_file_contains \
  "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" \
  "ReleaseV050ExecutionOMSDryRunLifecycleRunner"
require_file_contains \
  "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" \
  "RiskDecisionEvent"
require_file_contains \
  "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" \
  "OMSLifecycleEvent"
require_file_contains \
  "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" \
  "ExecutionClientDryRunEvent"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "acceptedByOMS"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "simulatedPartiallyFilled"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "simulatedCancelled"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "V050-10-EXECUTION-OMS-DRY-RUN-LIFECYCLE"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "V050-10-RISK-DECISION-TO-OMS-LIFECYCLE"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "V050-10-DRY-RUN-EXECUTION-EVENTS"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "V050-10-REJECTED-BLOCKED-RISK-NO-SUBMIT"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "V050-10-RUN-JOURNAL-REPLAYABLE-OMS-EXECUTION"
require_file_contains \
  "docs/contracts/release-v0.5.0-execution-oms-dryrun-lifecycle-contract.md" \
  "TVM-RELEASE-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-oms.sh"

reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "URLSession"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "URLRequest"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "api.binance.com"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "fapi.binance.com"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "submitOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "cancelOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "replaceOrder"
reject_file_contains "Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift" "HMAC<"

echo "MTPRO release v0.5.0 ExecutionEngine / OMS dry-run lifecycle verification passed."
