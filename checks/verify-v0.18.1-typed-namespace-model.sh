#!/usr/bin/env bash
set -euo pipefail

# GH-1204-VERIFY-V0181-TYPED-NAMESPACE-MODEL
# TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL
# V0181-005-TYPED-VENUE-PRODUCT-ENVIRONMENT
# V0181-005-ACCOUNT-PROFILE-ID
# V0181-005-ALLOWED-PAIRS-FAIL-CLOSED
# V0181-005-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
# V0181-005-JSON-CODEC-MIGRATION
# V0181-005-NO-PRODUCTION-CUTOVER

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
    printf 'Forbidden typed namespace text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" \
  "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.18.1-typed-namespace-model.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md"; do
  require_contains "$file" "GH-1204-VERIFY-V0181-TYPED-NAMESPACE-MODEL"
  require_contains "$file" "TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL"
  require_contains "$file" "V0181-005-TYPED-VENUE-PRODUCT-ENVIRONMENT"
  require_contains "$file" "V0181-005-ACCOUNT-PROFILE-ID"
  require_contains "$file" "V0181-005-ALLOWED-PAIRS-FAIL-CLOSED"
  require_contains "$file" "V0181-005-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT"
  require_contains "$file" "V0181-005-JSON-CODEC-MIGRATION"
  require_contains "$file" "V0181-005-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181VenueID"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181ProductKind"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181TradingEnvironment"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public struct ReleaseV0181AccountProfileID"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "credentialLikeMarkers"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "productionLiveForbiddenByDefault=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" "ReleaseV0181VenueID"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" "ReleaseV0181VenueProductNamespacePolicy.supportsCriticalNamespace"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0170BetaSafetyPolicyProfileEvidence.swift" "ReleaseV0181VenueProductNamespacePolicy.supportsRawPair"
require_contains "checks/run.sh" "bash checks/verify-v0.18.1-typed-namespace-model.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.18.1-typed-namespace-model.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.18.1 typed namespace model anchor"
require_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "v0.18.1 typed namespace model"
require_contains "docs/validation/validation-plan.md" "GH-1204 Release v0.18.1 Typed Namespace Model"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL"
require_contains "docs/release/release-publication-policy.md" "GH-1204 replaces critical v0.18 namespace raw string switches"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1204TypedVenueProductNamespaceModelValidatesCriticalV018Recovery"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" "case (\"binance\", \"spot\")"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" "case (\"okx\", \"swap\")"

swift test --filter TargetGraphTests/testGH1204TypedVenueProductNamespaceModelValidatesCriticalV018Recovery

printf 'MTPRO v0.18.1 typed namespace model verification passed.\n'
