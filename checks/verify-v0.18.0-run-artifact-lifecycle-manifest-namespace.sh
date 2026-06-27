#!/usr/bin/env bash
set -euo pipefail

# GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
# TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
# V0180-002-DEPENDENCY-GH1176-DONE
# V0180-002-LIFECYCLE-MANIFEST-SCHEMA
# V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
# V0180-002-ACCOUNT-RUNID-BINDING
# V0180-002-BOUNDARY-REUSE-REJECTION
# V0180-002-LOCAL-EVIDENCE-ONLY
# V0180-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.0 lifecycle manifest namespace guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.18.0 lifecycle manifest namespace guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV060LocalRunJournalWriter.swift"
CONTRACT="docs/contracts/release-v0.18.0-run-artifact-lifecycle-manifest-namespace-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1177RunArtifactLifecycleManifestRecordsNamespaceAndRejectsReuse

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE"
  require_file_contains "$file" "TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE"
  require_file_contains "$file" "V0180-002-DEPENDENCY-GH1176-DONE"
  require_file_contains "$file" "V0180-002-LIFECYCLE-MANIFEST-SCHEMA"
  require_file_contains "$file" "V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE"
  require_file_contains "$file" "V0180-002-ACCOUNT-RUNID-BINDING"
  require_file_contains "$file" "V0180-002-BOUNDARY-REUSE-REJECTION"
  require_file_contains "$file" "V0180-002-LOCAL-EVIDENCE-ONLY"
  require_file_contains "$file" "V0180-002-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT" "#1176 closed / done"
require_file_contains "$SOURCE" "ReleaseV0180RunArtifactLifecycleNamespace"
require_file_contains "$SOURCE" "ReleaseV0180RunArtifactLifecycleManifest"
require_file_contains "$SOURCE" "ReleaseV0180RunArtifactLifecycleManifestValidation"
require_file_contains "$SOURCE" "writeVenueProductAwareLifecycleManifest"
require_file_contains "$SOURCE" "validateVenueProductAwareLifecycleManifest"
require_file_contains "$SOURCE" "lifecycle-manifest-v0.18.0.json"
require_file_contains "$SOURCE" "venueProductPairSupported"
require_file_contains "$SOURCE" "namespaceMatched"
require_file_contains "$SOURCE" "venueProductEnvironmentMatched"
require_file_contains "$CONTRACT" "same runID reused as a different product"
require_file_contains "$CONTRACT" "same runID reused as a different environment"
require_file_contains "$READINESS" "Release v0.18.0 run artifact lifecycle manifest namespace anchor"
require_file_contains "$PLAN" "GH-1177 Release v0.18.0 Run Artifact Lifecycle Manifest Namespace"
require_file_contains "$MATRIX" "TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE"
require_file_contains "$POLICY" "GH-1177 adds the v0.18.0 run artifact lifecycle manifest namespace guard"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.0-run-artifact-lifecycle-manifest-namespace.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.0-run-artifact-lifecycle-manifest-namespace.sh"
require_file_contains "$TESTS" "testGH1177RunArtifactLifecycleManifestRecordsNamespaceAndRejectsReuse"

for file in "$SOURCE" "$CONTRACT" "$POLICY" "$READINESS" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

echo "MTPRO release v0.18.0 run artifact lifecycle manifest namespace verification passed."
