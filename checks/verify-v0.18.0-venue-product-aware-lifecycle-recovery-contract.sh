#!/usr/bin/env bash
set -euo pipefail

# GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT
# TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT
# V0180-001-DEPENDENCIES-CLOSED-DONE
# V0180-001-NAMESPACE-CONTRACT
# V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE
# V0180-001-ARTIFACT-LIFECYCLE-SCOPE
# V0180-001-STATUS-RESUME-RECONCILIATION
# V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN
# V0180-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 lifecycle recovery contract guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.18.0 lifecycle recovery contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.18.0-venue-product-aware-operator-lifecycle-recovery-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1176ReleaseV0180VenueProductAwareOperatorLifecycleRecoveryContract

for file in \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT"
  require_file_contains "$file" "V0180-001-DEPENDENCIES-CLOSED-DONE"
  require_file_contains "$file" "V0180-001-NAMESPACE-CONTRACT"
  require_file_contains "$file" "V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE"
  require_file_contains "$file" "V0180-001-ARTIFACT-LIFECYCLE-SCOPE"
  require_file_contains "$file" "V0180-001-STATUS-RESUME-RECONCILIATION"
  require_file_contains "$file" "V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN"
  require_file_contains "$file" "V0180-001-NO-PRODUCTION-CUTOVER"
done

for dependency in "#1168" "#1169" "#1170" "#1171"; do
  require_file_contains "$CONTRACT" "$dependency closed / done"
done

for namespace_field in "venue" "product" "environment" "accountProfile" "runID"; do
  require_file_contains "$CONTRACT" "$namespace_field"
done

for surface in \
  "artifact lifecycle" \
  "status query persistence" \
  "resume" \
  "reconciliation replay" \
  "CLI next-action" \
  "Dashboard drilldown"; do
  require_file_contains "$CONTRACT" "$surface"
done

require_file_contains "$CONTRACT" "Binance"
require_file_contains "$CONTRACT" "OKX"
require_file_contains "$CONTRACT" "spot"
require_file_contains "$CONTRACT" "usdmFutures"
require_file_contains "$CONTRACT" "swap"
require_file_contains "$CONTRACT" "No new OKX runtime implementation"
require_file_contains "$CONTRACT" "newOKXRuntimeImplemented=false"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionSecretReadEnabled=false"
require_file_contains "$CONTRACT" "productionEndpointConnectionEnabled=false"
require_file_contains "$CONTRACT" "productionBrokerConnectionEnabled=false"
require_file_contains "$CONTRACT" "productionOrderSubmitCancelReplaceEnabled=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "$CONTRACT" "production cutover not authorized"
require_file_contains "$READINESS" "Release v0.18.0 venue/product-aware lifecycle recovery contract anchor"
require_file_contains "$PLAN" "GH-1176 Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Contract"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT"
require_file_contains "$POLICY" "GH-1176 defines the v0.18.0 venue/product-aware operator lifecycle recovery contract"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-venue-product-aware-lifecycle-recovery-contract.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-venue-product-aware-lifecycle-recovery-contract.sh"
require_file_contains "$TESTS" "testGH1176ReleaseV0180VenueProductAwareOperatorLifecycleRecoveryContract"

for file in "$CONTRACT" "$POLICY" "$READINESS" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

echo "MTPRO release v0.18.0 venue/product-aware lifecycle recovery contract verification passed."
