#!/usr/bin/env bash
set -euo pipefail

# GH-1211-VERIFY-V0190-RUNTIME-ADAPTER-PROTOCOL
# TVM-RELEASE-V0190-RUNTIME-ADAPTER-PROTOCOL
# V0190-006-RUNTIME-ADAPTER-PROTOCOL
# V0190-006-CAPABILITY-GATED-OPERATIONS
# V0190-006-TYPED-NAMESPACE-SELECTION
# V0190-006-UNSUPPORTED-FAILS-CLOSED
# V0190-006-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local needle="$2"

  if ! grep -Fq "$needle" "$file"; then
    printf 'MTPRO v0.19.0 venue/product runtime adapter protocol guard failed: %s must contain: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

reject_contains() {
  local file="$1"
  local needle="$2"

  if grep -Fq "$needle" "$file"; then
    printf 'MTPRO v0.19.0 venue/product runtime adapter protocol guard failed: %s must not contain: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-venue-product-runtime-adapter-protocol.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1211-VERIFY-V0190-RUNTIME-ADAPTER-PROTOCOL"
  require_contains "$file" "TVM-RELEASE-V0190-RUNTIME-ADAPTER-PROTOCOL"
  require_contains "$file" "V0190-006-RUNTIME-ADAPTER-PROTOCOL"
  require_contains "$file" "V0190-006-CAPABILITY-GATED-OPERATIONS"
  require_contains "$file" "V0190-006-TYPED-NAMESPACE-SELECTION"
  require_contains "$file" "V0190-006-UNSUPPORTED-FAILS-CLOSED"
  require_contains "$file" "V0190-006-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "public protocol ReleaseV0190VenueProductRuntimeAdapter"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "public struct ReleaseV0190VenueProductRuntimeAdapterSelection"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "public struct ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "ReleaseV0190VenueProductCapabilityMatrix.requireActive"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "ReleaseV0190VenueEndpointFamilyRegistry.entry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "ReleaseV0190VenueCredentialProfileRegistry.entry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "localExecutableEvidenceBoundaryHeld"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "operation.requiredCapability"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "localEvidenceAdapterOnly=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionSecretReadEnabled=false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionEndpointConnectionEnabled=false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionOrderSubmitCancelReplaceEnabled=false"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1211ReleaseV0190VenueProductRuntimeAdapterProtocolFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-venue-product-runtime-adapter-protocol.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-venue-product-runtime-adapter-protocol.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 venue/product runtime adapter protocol anchor"
require_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "v0.19.0 venue/product runtime adapter protocol"
require_contains "docs/validation/validation-plan.md" "GH-1211 Release v0.19.0 Venue/Product Runtime Adapter Protocol"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-RUNTIME-ADAPTER-PROTOCOL"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionSecretRead=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionEndpointConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionBrokerConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueProductRuntimeAdapterProtocol.swift" "productionOrderSubmitted=true"

swift test --filter TargetGraphTests/testGH1211ReleaseV0190VenueProductRuntimeAdapterProtocolFailsClosed

printf 'MTPRO v0.19.0 venue/product runtime adapter protocol verification passed.\n'
