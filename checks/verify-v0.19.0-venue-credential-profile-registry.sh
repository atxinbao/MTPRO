#!/usr/bin/env bash
set -euo pipefail

# GH-1209-VERIFY-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY
# TVM-RELEASE-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY
# V0190-004-CREDENTIAL-PROFILE-REGISTRY
# V0190-004-TESTNET-PRODUCTION-SHADOW-PROFILES
# V0190-004-CREDENTIAL-IDENTITY-ONLY
# V0190-004-CROSS-NAMESPACE-REUSE-FAILS-CLOSED
# V0190-004-REDACTED-EVIDENCE-ONLY
# V0190-004-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
# V0190-004-NO-SECRET-READ
# V0190-004-NO-PRODUCTION-CUTOVER

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
    printf 'Forbidden v0.19.0 credential profile text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-venue-credential-profile-registry.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1209-VERIFY-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY"
  require_contains "$file" "TVM-RELEASE-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY"
  require_contains "$file" "V0190-004-CREDENTIAL-PROFILE-REGISTRY"
  require_contains "$file" "V0190-004-TESTNET-PRODUCTION-SHADOW-PROFILES"
  require_contains "$file" "V0190-004-CREDENTIAL-IDENTITY-ONLY"
  require_contains "$file" "V0190-004-CROSS-NAMESPACE-REUSE-FAILS-CLOSED"
  require_contains "$file" "V0190-004-REDACTED-EVIDENCE-ONLY"
  require_contains "$file" "V0190-004-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT"
  require_contains "$file" "V0190-004-NO-SECRET-READ"
  require_contains "$file" "V0190-004-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "public enum ReleaseV0190VenueCredentialProfileState"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "public struct ReleaseV0190VenueCredentialProfileEntry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "public enum ReleaseV0190VenueCredentialProfileRegistry"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "case testnetReference"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "case productionShadow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "case placeholder"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "case forbidden"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "credentialIdentityOnly = true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "redactedEvidenceOnly = true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "productionSecretReadEnabled = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "productionEndpointConnectionEnabled = false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "expectedProfileID"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "namespaceReuse"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "redacted-credential-profile"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1209ReleaseV0190VenueCredentialProfileRegistryFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-venue-credential-profile-registry.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-venue-credential-profile-registry.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 venue credential profile registry anchor"
require_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "v0.19.0 venue credential profile registry"
require_contains "docs/validation/validation-plan.md" "GH-1209 Release v0.19.0 Venue Credential Profile Registry"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "ProcessInfo"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "URLSession"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "Keychain"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "Data(contentsOf:"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" ".resume()"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "productionSecretReadEnabled = true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "productionEndpointConnectionEnabled = true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190VenueCredentialProfileRegistry.swift" "productionCutoverAuthorized=true"

swift test --filter TargetGraphTests/testGH1209ReleaseV0190VenueCredentialProfileRegistryFailsClosed

printf 'MTPRO v0.19.0 venue credential profile registry verification passed.\n'
