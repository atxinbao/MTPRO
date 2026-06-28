#!/usr/bin/env bash
set -euo pipefail

# GH-1206-VERIFY-V0190-VENUE-PRODUCT-REGISTRY
# TVM-RELEASE-V0190-VENUE-PRODUCT-REGISTRY
# V0190-001-VENUE-REGISTRY
# V0190-001-PRODUCT-REGISTRY
# V0190-001-TRADING-ENVIRONMENT-ACCOUNT-PROFILE-USAGE
# V0190-001-VALID-TARGET-COMBINATIONS
# V0190-001-V0181-CLOSEOUT-DEPENDENCY
# V0190-001-PRODUCTION-DISABLED-BY-DEFAULT
# V0190-001-NO-PRODUCTION-CUTOVER

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
    printf 'Forbidden v0.19.0 registry text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-venue-product-registry.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1206-VERIFY-V0190-VENUE-PRODUCT-REGISTRY"
  require_contains "$file" "TVM-RELEASE-V0190-VENUE-PRODUCT-REGISTRY"
  require_contains "$file" "V0190-001-VENUE-REGISTRY"
  require_contains "$file" "V0190-001-PRODUCT-REGISTRY"
  require_contains "$file" "V0190-001-TRADING-ENVIRONMENT-ACCOUNT-PROFILE-USAGE"
  require_contains "$file" "V0190-001-VALID-TARGET-COMBINATIONS"
  require_contains "$file" "V0190-001-V0181-CLOSEOUT-DEPENDENCY"
  require_contains "$file" "V0190-001-PRODUCTION-DISABLED-BY-DEFAULT"
  require_contains "$file" "V0190-001-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "public enum ReleaseV0190VenueRegistry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "public enum ReleaseV0190ProductRegistry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "public struct ReleaseV0190VenueProductTarget"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "productionTradingEnabledByDefault = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "okxRuntimeImplemented = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181VenueID"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181ProductKind"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181TradingEnvironment"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181AccountProfileID"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap)"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1206ReleaseV0190VenueProductRegistriesDefineCanonicalTargets"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-venue-product-registry.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-venue-product-registry.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 venue/product registry anchor"
require_contains "docs/validation/latest-verification-summary.md" "v0.19.0 venue/product registry"
require_contains "docs/validation/validation-plan.md" "GH-1206 Release v0.19.0 Venue/Product Registry"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-VENUE-PRODUCT-REGISTRY"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "URLSession"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "https://"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRegistry.swift" "productionCutoverAuthorized=true"

swift test --filter TargetGraphTests/testGH1206ReleaseV0190VenueProductRegistriesDefineCanonicalTargets

printf 'MTPRO v0.19.0 venue/product registry verification passed.\n'
