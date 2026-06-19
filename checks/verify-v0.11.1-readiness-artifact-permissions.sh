#!/usr/bin/env bash
set -euo pipefail

# GH-949-VERIFY-V0111-READINESS-ARTIFACT-PERMISSIONS
# TVM-RELEASE-V0111-READINESS-ARTIFACT-PERMISSIONS
# V0111-005-OWNER-ONLY-DIRECTORIES
# V0111-005-OWNER-ONLY-FILES
# V0111-005-PERMISSION-REPAIR
# V0111-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.11.1 readiness artifact permission guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"

swift test --filter TargetGraphTests/testGH949ProductionReadinessArtifactStoreEnforcesOwnerOnlyPermissions
swift test --filter TargetGraphTests/testGH949ReadinessArtifactPermissionGuardAnchors

for anchor in \
  "GH-949-VERIFY-V0111-READINESS-ARTIFACT-PERMISSIONS" \
  "TVM-RELEASE-V0111-READINESS-ARTIFACT-PERMISSIONS" \
  "V0111-005-OWNER-ONLY-DIRECTORIES" \
  "V0111-005-OWNER-ONLY-FILES" \
  "V0111-005-PERMISSION-REPAIR" \
  "V0111-005-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
done

require_file_contains "$SOURCE" "ProductionReadinessArtifactPermissionAnchors"
require_file_contains "$SOURCE" "ownerOnlyDirectoryPermissions"
require_file_contains "$SOURCE" "ownerOnlyFilePermissions"
require_file_contains "$SOURCE" "enforceOwnerOnlyDirectoryPermissions"
require_file_contains "$SOURCE" "enforceOwnerOnlyFilePermissions"
require_file_contains "$SOURCE" ".posixPermissions"
require_file_contains "$TESTS" "testGH949ProductionReadinessArtifactStoreEnforcesOwnerOnlyPermissions"
require_file_contains "$TESTS" "testGH949ReadinessArtifactPermissionGuardAnchors"
require_file_contains "$TESTS" "0o700"
require_file_contains "$TESTS" "0o600"
require_file_contains "$READINESS_SCRIPT" "Release v0.11.1 readiness artifact permission guard anchor"
require_file_contains "$READINESS_SCRIPT" "checks/verify-v0.11.1-readiness-artifact-permissions.sh"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.11.1-readiness-artifact-permissions.sh"
require_file_contains "$PLAN" "GH-949 Release v0.11.1 Readiness Artifact Permission Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0111-READINESS-ARTIFACT-PERMISSIONS"

echo "MTPRO release v0.11.1 readiness artifact permission guard verification passed."
