#!/usr/bin/env bash
set -euo pipefail

# GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS
# TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS
# V0181-004-RUNS-NAMESPACE-PATH
# V0181-004-V0180-ACTIVE-PATHS-MIGRATED
# V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED
# V0181-004-OLD-VERSION-FIXTURES-PRESERVED
# V0181-004-NO-PRODUCTION-CUTOVER

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
    printf 'Forbidden active v0.18 artifact namespace text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" \
  "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" \
  "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.18.1-artifact-namespace-paths.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md"; do
  require_contains "$file" "GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS"
  require_contains "$file" "TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS"
  require_contains "$file" "V0181-004-RUNS-NAMESPACE-PATH"
  require_contains "$file" "V0181-004-V0180-ACTIVE-PATHS-MIGRATED"
  require_contains "$file" "V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED"
  require_contains "$file" "V0181-004-OLD-VERSION-FIXTURES-PRESERVED"
  require_contains "$file" "V0181-004-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" ".local/mtpro/runs/\\(snapshot.namespace.venue)/\\(snapshot.namespace.product)/\\(snapshot.namespace.environment)/\\(snapshot.namespace.accountProfile)/\\(snapshot.namespace.runID.rawValue)/artifacts/status-query-retry-result-redacted.json"
require_contains "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" ".local/mtpro/runs/binance/usdm-perpetual/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" ".local/mtpro/runs/\\(namespace.venue)/\\(namespace.product)/\\(namespace.environment)/\\(namespace.accountProfile)/\\(namespace.runID.rawValue)/operator-run/"
require_contains "docs/automation/automation-readiness.md" "Release v0.18.1 artifact namespace path anchor"
require_contains "docs/validation/latest-verification-summary.md" "v0.18.1 artifact namespace paths"
require_contains "docs/validation/validation-plan.md" "GH-1203 Release v0.18.1 Artifact Namespace Paths"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS"
require_contains "docs/release/release-publication-policy.md" "GH-1203 fixes active v0.18 artifact namespace paths"
require_contains "checks/run.sh" "bash checks/verify-v0.18.1-artifact-namespace-paths.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.18.1-artifact-namespace-paths.sh"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0180StatusQueryRetryArtifactPersistence.swift" ".local/mtpro/v0.16.0/operator-runs/\\(snapshot.namespace.runID.rawValue)"
reject_contains "Sources/Dashboard/Report/ReleaseV0180DashboardArtifactRecoveryDrilldownSurface.swift" ".local/mtpro/v0.18.0/operator-runs/"

swift test --filter TargetGraphTests/testGH1203ArtifactNamespacePathsUseVenueProductEnvironmentRoot

printf 'MTPRO v0.18.1 artifact namespace path verification passed.\n'
