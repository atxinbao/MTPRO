#!/usr/bin/env bash
set -euo pipefail

# GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE
# TVM-RELEASE-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE
# V0190-008-DASHBOARD-REGISTRY-READ-ONLY-SURFACE
# V0190-008-BINANCE-SPOT-FUTURES-OKX-SPOT-SWAP-STATES
# V0190-008-ACTIVE-PLACEHOLDER-FUTURE-GATED-FORBIDDEN
# V0190-008-CAPABILITY-UNSUPPORTED-REASONS
# V0190-008-DASHBOARD-READ-ONLY-NO-COMMANDS
# V0190-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'v0.19.0 Dashboard venue/product registry surface verification failed: %s\n' "$1" >&2
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
  "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" \
  "Sources/Dashboard/DashboardShell.swift" \
  "Tests/AppTests/AppTests.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-dashboard-venue-product-registry-surface.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE"
  require_contains "$file" "TVM-RELEASE-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE"
  require_contains "$file" "V0190-008-DASHBOARD-REGISTRY-READ-ONLY-SURFACE"
  require_contains "$file" "V0190-008-BINANCE-SPOT-FUTURES-OKX-SPOT-SWAP-STATES"
  require_contains "$file" "V0190-008-ACTIVE-PLACEHOLDER-FUTURE-GATED-FORBIDDEN"
  require_contains "$file" "V0190-008-CAPABILITY-UNSUPPORTED-REASONS"
  require_contains "$file" "V0190-008-DASHBOARD-READ-ONLY-NO-COMMANDS"
  require_contains "$file" "V0190-008-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "public enum ReleaseV0190DashboardVenueProductRegistrySupportState"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "public struct ReleaseV0190DashboardVenueProductRegistryRow"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "public struct ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "ReleaseV0190VenueProductCapabilityMatrix.profile"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "ReleaseV0190VenueProductRuntimeRegistry.registration"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "binance/spot/testnet/binance-spot-testnet-credential-profile-ref"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "binance/usdmFutures/testnet/binance-usdmFutures-testnet-credential-profile-ref"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "okx/spot/testnet/okx-spot-testnet-credential-profile-ref"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "okx/swap/testnet/okx-swap-testnet-credential-profile-ref"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "Dashboard command surface: none"
require_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "Production cutover: none"
require_contains "Sources/Dashboard/DashboardShell.swift" "releaseV0190DashboardVenueProductRegistrySurface"
require_contains "Sources/Dashboard/DashboardShell.swift" "DashboardReleaseV0190VenueProductRegistryPanel"
require_contains "Sources/Dashboard/DashboardShell.swift" "releaseV0190RegistryRows"
require_contains "Tests/AppTests/AppTests.swift" "testGH1213DashboardVenueProductRegistrySurfaceShowsReadOnlySupportStatus"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1213DashboardVenueProductRegistrySurfaceIsAnchoredInV0190Guards"
require_contains "docs/validation/validation-plan.md" "GH-1213 Release v0.19.0 Dashboard Venue/Product Registry Surface"

reject_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "productionSecretRead=true"
reject_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "productionEndpointConnected=true"
reject_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "brokerEndpointConnected=true"
reject_contains "Sources/Dashboard/Report/ReleaseV0190DashboardVenueProductRegistrySurface.swift" "submitCancelReplaceEnabled=true"

swift test --filter AppTests/testGH1213DashboardVenueProductRegistrySurfaceShowsReadOnlySupportStatus
swift test --filter TargetGraphTests/testGH1213DashboardVenueProductRegistrySurfaceIsAnchoredInV0190Guards

printf 'MTPRO v0.19.0 Dashboard venue/product registry surface verification passed.\n'
