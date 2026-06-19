#!/usr/bin/env bash
set -euo pipefail

# GH-948-VERIFY-V0111-READINESS-ARTIFACT-SYMLINK-ROOT
# TVM-RELEASE-V0111-READINESS-ARTIFACT-SYMLINK-ROOT
# V0111-004-CANONICAL-EVIDENCE-ROOT
# V0111-004-NO-SYMLINK-PATH-COMPONENTS
# V0111-004-RESOLVED-TARGET-STAYS-IN-ROOT
# V0111-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.11.1 readiness artifact symlink root guard failed: %s must contain: %s\n' "$file" "$expected" >&2
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

swift test --filter TargetGraphTests/testGH948ProductionReadinessArtifactStoreRejectsSymlinkEscapes
swift test --filter TargetGraphTests/testGH948ReadinessArtifactSymlinkRootGuardAnchors

for anchor in \
  "GH-948-VERIFY-V0111-READINESS-ARTIFACT-SYMLINK-ROOT" \
  "TVM-RELEASE-V0111-READINESS-ARTIFACT-SYMLINK-ROOT" \
  "V0111-004-CANONICAL-EVIDENCE-ROOT" \
  "V0111-004-NO-SYMLINK-PATH-COMPONENTS" \
  "V0111-004-RESOLVED-TARGET-STAYS-IN-ROOT" \
  "V0111-004-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
done

require_file_contains "$SOURCE" "ProductionReadinessArtifactSymlinkRootAnchors"
require_file_contains "$SOURCE" "unsafeSymbolicLink"
require_file_contains "$SOURCE" "validateApprovedEvidenceRoot"
require_file_contains "$SOURCE" "validateArtifactPath"
require_file_contains "$SOURCE" "rejectSymbolicLinkComponents"
require_file_contains "$SOURCE" "validateResolvedTargetInsideEvidenceRoot"
require_file_contains "$SOURCE" "destinationOfSymbolicLink"
require_file_contains "$TESTS" "testGH948ProductionReadinessArtifactStoreRejectsSymlinkEscapes"
require_file_contains "$TESTS" "testGH948ReadinessArtifactSymlinkRootGuardAnchors"
require_file_contains "$TESTS" "createSymbolicLink"
require_file_contains "$READINESS_SCRIPT" "Release v0.11.1 readiness artifact symlink root guard anchor"
require_file_contains "$READINESS_SCRIPT" "checks/verify-v0.11.1-readiness-artifact-symlink-root.sh"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.11.1-readiness-artifact-symlink-root.sh"
require_file_contains "$PLAN" "GH-948 Release v0.11.1 Readiness Artifact Symlink Root Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0111-READINESS-ARTIFACT-SYMLINK-ROOT"

echo "MTPRO release v0.11.1 readiness artifact symlink root guard verification passed."
