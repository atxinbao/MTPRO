#!/usr/bin/env bash
set -euo pipefail

# GH-1212-VERIFY-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY
# TVM-RELEASE-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY
# V0190-007-BINANCE-SPOT-TESTNET-REGISTRATION
# V0190-007-EXISTING-RUNTIME-ANCHORS
# V0190-007-TYPED-REGISTRY-SELECTION
# V0190-007-PLACEHOLDER-PAIRS-FAIL-CLOSED
# V0190-007-NO-BEHAVIOR-CHANGE
# V0190-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'v0.19.0 Binance Spot Testnet runtime registry verification failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-binance-spot-testnet-runtime-registry.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1212-VERIFY-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY"
  require_contains "$file" "TVM-RELEASE-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY"
  require_contains "$file" "V0190-007-BINANCE-SPOT-TESTNET-REGISTRATION"
  require_contains "$file" "V0190-007-EXISTING-RUNTIME-ANCHORS"
  require_contains "$file" "V0190-007-TYPED-REGISTRY-SELECTION"
  require_contains "$file" "V0190-007-PLACEHOLDER-PAIRS-FAIL-CLOSED"
  require_contains "$file" "V0190-007-NO-BEHAVIOR-CHANGE"
  require_contains "$file" "V0190-007-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "public enum ReleaseV0190VenueProductRuntimeRegistry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "public struct ReleaseV0190VenueProductRuntimeRegistration"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "ReleaseV0190VenueProductRuntimeAdapterSelection(target: target)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "ReleaseV0150BinanceSpotTestnetSubmitRuntime.self"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "ReleaseV0150BinanceSpotTestnetCancelRuntime.self"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "ReleaseV0160CLIOrderStatusQueryFlow.self"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "submit,cancel,queryStatus"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "Binance USDⓈ-M Futures runtime is future-gated"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "OKX runtime is placeholder evidence only"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionShadow is reference evidence only"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionEndpointConnectionEnabled = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionOrderSubmitCancelReplaceEnabled = false"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1212ReleaseV0190BinanceSpotTestnetRuntimeRegistryRoutesExistingBehavior"
require_contains "docs/validation/validation-plan.md" "GH-1212 Release v0.19.0 Binance Spot Testnet Runtime Registry"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionSecretRead=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionEndpointConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionBrokerConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeRegistry.swift" "productionOrderSubmitted=true"

swift test --filter TargetGraphTests/testGH1212ReleaseV0190BinanceSpotTestnetRuntimeRegistryRoutesExistingBehavior

printf 'MTPRO v0.19.0 Binance Spot Testnet runtime registry verification passed.\n'
