#!/usr/bin/env bash
set -euo pipefail

# GH-1207-VERIFY-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX
# TVM-RELEASE-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX
# V0190-002-CAPABILITY-MATRIX
# V0190-002-SUBMIT-CANCEL-STATUS-POSITION-RECONCILE
# V0190-002-REDUCE-ONLY-LEVERAGE-MARGIN-TYPE
# V0190-002-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED
# V0190-002-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
# V0190-002-FUTURE-CAPABILITIES-NOT-ACTIVE
# V0190-002-NO-PRODUCTION-CUTOVER

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
    printf 'Forbidden v0.19.0 capability matrix text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-venue-product-capability-matrix.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1207-VERIFY-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX"
  require_contains "$file" "TVM-RELEASE-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX"
  require_contains "$file" "V0190-002-CAPABILITY-MATRIX"
  require_contains "$file" "V0190-002-SUBMIT-CANCEL-STATUS-POSITION-RECONCILE"
  require_contains "$file" "V0190-002-REDUCE-ONLY-LEVERAGE-MARGIN-TYPE"
  require_contains "$file" "V0190-002-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED"
  require_contains "$file" "V0190-002-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT"
  require_contains "$file" "V0190-002-FUTURE-CAPABILITIES-NOT-ACTIVE"
  require_contains "$file" "V0190-002-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "public enum ReleaseV0190VenueProductCapability"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "public enum ReleaseV0190VenueProductCapabilityState"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "public enum ReleaseV0190VenueProductCapabilityMatrix"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "case active"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "case placeholder"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "case forbidden"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "case futureGated"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "productionTradingEnabledByDefault = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "okxRuntimeImplemented = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap)"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "productionLive is disabled by default"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "later explicitly authorized adapter issue"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1207ReleaseV0190VenueProductCapabilityMatrixFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-venue-product-capability-matrix.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-venue-product-capability-matrix.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 venue/product capability matrix anchor"
require_contains "docs/validation/latest-verification-summary.md" "v0.19.0 venue/product capability matrix"
require_contains "docs/validation/validation-plan.md" "GH-1207 Release v0.19.0 Venue/Product Capability Matrix"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "URLSession"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "https://"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductCapabilityMatrix.swift" "productionCutoverAuthorized=true"

swift test --filter TargetGraphTests/testGH1207ReleaseV0190VenueProductCapabilityMatrixFailsClosed

printf 'MTPRO v0.19.0 venue/product capability matrix verification passed.\n'
