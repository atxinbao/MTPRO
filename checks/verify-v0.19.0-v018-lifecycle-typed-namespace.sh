#!/usr/bin/env bash
set -euo pipefail

# GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
# TVM-RELEASE-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
# V0190-005-TYPED-LIFECYCLE-NAMESPACE
# V0190-005-JSON-DECODE-MIGRATION
# V0190-005-DASHBOARD-NAMESPACE-CONSISTENCY
# V0190-005-NAMESPACE-MISMATCH-FAILS-CLOSED
# V0190-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local needle="$2"

  if ! grep -Fq "$needle" "$file"; then
    printf 'MTPRO v0.19.0 v0.18 lifecycle typed namespace guard failed: %s must contain: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

reject_contains() {
  local file="$1"
  local needle="$2"

  if grep -Fq "$needle" "$file"; then
    printf 'MTPRO v0.19.0 v0.18 lifecycle typed namespace guard failed: %s must not contain: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" \
  "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" \
  "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-v018-lifecycle-typed-namespace.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE"
  require_contains "$file" "TVM-RELEASE-V0190-V018-LIFECYCLE-TYPED-NAMESPACE"
  require_contains "$file" "V0190-005-TYPED-LIFECYCLE-NAMESPACE"
  require_contains "$file" "V0190-005-JSON-DECODE-MIGRATION"
  require_contains "$file" "V0190-005-DASHBOARD-NAMESPACE-CONSISTENCY"
  require_contains "$file" "V0190-005-NAMESPACE-MISMATCH-FAILS-CLOSED"
  require_contains "$file" "V0190-005-NO-PRODUCTION-CUTOVER"
done

require_contains "Package.swift" "\"ReleaseV0181TypedNamespaceModel.swift\""
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181VenueID"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181ProductKind"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public enum ReleaseV0181TradingEnvironment"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "public struct ReleaseV0181AccountProfileID"
require_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "public let venueID: ReleaseV0181VenueID"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "public let productKind: ReleaseV0181ProductKind"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "public let tradingEnvironment: ReleaseV0181TradingEnvironment"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "public let accountProfileID: ReleaseV0181AccountProfileID"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "ReleaseV0181VenueProductNamespacePolicy.supportsCriticalNamespace"
require_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "public init(from decoder: Decoder) throws"
require_contains "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" "binance/usdmFutures/testnet/operator-beta-redacted"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1210ReleaseV0190MigratesV018LifecycleNamespaceToTypedModel"
require_contains "checks/run.sh" "bash checks/verify-v0.19.0-v018-lifecycle-typed-namespace.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.19.0-v018-lifecycle-typed-namespace.sh"
require_contains "docs/automation/automation-readiness.md" "Release v0.19.0 v0.18 lifecycle typed namespace anchor"
require_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "v0.19.0 v0.18 lifecycle typed namespace"
require_contains "docs/validation/validation-plan.md" "GH-1210 Release v0.19.0 v0.18 Lifecycle Typed Namespace"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0190-V018-LIFECYCLE-TYPED-NAMESPACE"

reject_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "case (\"binance\", \"spot\")"
reject_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "case (\"okx\", \"swap\")"
reject_contains "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" "binance/usdm-perpetual/testnet/operator-beta-redacted"
reject_contains "Sources/DomainModel/ReleaseV0181TypedNamespaceModel.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" "productionCutoverAuthorized=true"

swift test --filter TargetGraphTests/testGH1210ReleaseV0190MigratesV018LifecycleNamespaceToTypedModel

printf 'MTPRO v0.19.0 v0.18 lifecycle typed namespace verification passed.\n'
