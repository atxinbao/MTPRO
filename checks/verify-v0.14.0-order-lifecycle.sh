#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-order-lifecycle failed: $file must contain: $expected" >&2
    exit 1
  fi
}

require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "public enum OrderLifecycleState"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "public enum OrderLifecycleContractError"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "public struct OrderLifecycleStateMachine"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "OrderLifecycleContractError.invalidTransition"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "submittedTestnet"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "submittedDryRun"
require_file_contains "Sources/DomainModel/OrderLifecycle.swift" "productionTradingEnabledByDefault"
require_file_contains "Package.swift" "\"OrderLifecycle.swift\""
require_file_contains "Package.swift" "\"DomainModel/OrderLifecycle.swift\""
require_file_contains "docs/contracts/release-v0.14.0-order-lifecycle-state-machine-contract.md" "GH-1026-ORDER-LIFECYCLE-STATE-MACHINE"
require_file_contains "docs/contracts/release-v0.14.0-order-lifecycle-state-machine-contract.md" "GH-1026-ORDER-LIFECYCLE-INVALID-TRANSITION-FAIL-CLOSED"
require_file_contains "docs/contracts/release-v0.14.0-order-lifecycle-state-machine-contract.md" "GH-1026-ORDER-LIFECYCLE-TESTNET-DRYRUN-BOUNDARY"
require_file_contains "docs/contracts/release-v0.14.0-order-lifecycle-state-machine-contract.md" "TVM-RELEASE-V0140-ORDER-LIFECYCLE-STATE-MACHINE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1026ReleaseV0140OrderLifecycleStateMachineFailsClosedInvalidTransitions"
require_file_contains "checks/run.sh" "bash checks/verify-v0.14.0-order-lifecycle.sh"

swift test --filter TargetGraphTests/testGH1026ReleaseV0140OrderLifecycleStateMachineFailsClosedInvalidTransitions

echo "MTPRO release v0.14.0 OrderLifecycle state machine verification passed."
