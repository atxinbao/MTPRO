#!/usr/bin/env bash
set -euo pipefail

# GH-1208-VERIFY-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY
# TVM-RELEASE-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY
# V0190-003-ENDPOINT-FAMILY-REGISTRY
# V0190-003-BINANCE-SPOT-TESTNET-PRODUCTION-SHADOW
# V0190-003-BINANCE-USDM-FUTURES-TESTNET-PRODUCTION-SHADOW
# V0190-003-OKX-SPOT-SWAP-PLACEHOLDER
# V0190-003-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
# V0190-003-NO-ENDPOINT-CONNECTION
# V0190-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    printf 'Missing required text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

reject_contains() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    printf 'Forbidden v0.19.0 endpoint family text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-venue-endpoint-family-registry.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1208-VERIFY-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY"
  require_contains "$file" "TVM-RELEASE-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY"
  require_contains "$file" "V0190-003-ENDPOINT-FAMILY-REGISTRY"
  require_contains "$file" "V0190-003-BINANCE-SPOT-TESTNET-PRODUCTION-SHADOW"
  require_contains "$file" "V0190-003-BINANCE-USDM-FUTURES-TESTNET-PRODUCTION-SHADOW"
  require_contains "$file" "V0190-003-OKX-SPOT-SWAP-PLACEHOLDER"
  require_contains "$file" "V0190-003-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT"
  require_contains "$file" "V0190-003-NO-ENDPOINT-CONNECTION"
  require_contains "$file" "V0190-003-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "public enum ReleaseV0190VenueEndpointHostFamily"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "public struct ReleaseV0190VenueEndpointFamilyEntry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "public enum ReleaseV0190VenueEndpointFamilyRegistry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "case activeReference"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "case productionShadow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "case placeholder"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "case forbidden"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "testnet.binance.vision"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "api.binance.com"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "testnet.binancefuture.com"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "fapi.binance.com"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "www.okx.com"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "productionEndpointConnectionEnabled = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "productionLive forbidden by default"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "no connection is opened"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1208ReleaseV0190VenueEndpointFamilyRegistryFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-venue-endpoint-family-registry.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-venue-endpoint-family-registry.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 venue endpoint family registry anchor"
require_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "v0.19.0 venue endpoint family registry"
require_contains "docs/validation/validation-plan.md" "GH-1208 Release v0.19.0 Venue Endpoint Family Registry"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "URLSession"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "URLRequest"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "Data(contentsOf:"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" ".resume()"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "productionEndpointConnectionEnabled = true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueEndpointFamilyRegistry.swift" "productionCutoverAuthorized=true"

swift test --filter TargetGraphTests/testGH1208ReleaseV0190VenueEndpointFamilyRegistryFailsClosed

printf 'MTPRO v0.19.0 venue endpoint family registry verification passed.\n'
