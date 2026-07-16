#!/usr/bin/env bash
set -euo pipefail

# GH-1540-ADD-COMPLETE-V0323-NEGATIVE-MATRIX
# TVM-RELEASE-V0323-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX
# V0323-006-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'verify-v0.32.3-negative-matrix failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "$file must contain: $expected"
}

swift test --filter TargetGraphTests/testGH1536TrustedGitHubProvenanceRejectsManifestSelfReportingAndIdentityDrift
swift test --filter TargetGraphTests/testGH1537PersistentRunLockUsesFilesystemRegistryAndFailsClosed
swift test --filter TargetGraphTests/testGH1538IndependentCanaryArtifactsRequireChecksumsAndReverseReferences
swift test --filter TargetGraphTests/testGH1539EvidenceRootContainmentRejectsSymlinkAndTraversalEscapes
swift test --filter TargetGraphTests/testGH1540CompleteV0323NegativeMatrixGuardAnchors

TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
require_contains "$TESTS" "forged/MTPRO"
require_contains "$TESTS" "selfReportedObservedCanary: true"
require_contains "$TESTS" "concurrentRoot"
require_contains "$TESTS" ".wrongOwner"
require_contains "$TESTS" ".corruptedRegistry"
require_contains "$TESTS" ".replayRejected"
require_contains "$TESTS" "missingRollback"
require_contains "$TESTS" "missingIncident"
require_contains "$TESTS" "checksumMismatch"
require_contains "$TESTS" "wrongProduct"
require_contains "$TESTS" "idsOnly"
require_contains "$TESTS" "finalSymlink"
require_contains "$TESTS" "nestedSymlink"
require_contains "$TESTS" '"../outside.json"'
require_contains "$TESTS" "operationsDirectory"
require_contains "$TESTS" "rootSymlink"

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0323TrustedGitHubProvenance.swift \
  Sources/ExecutionClient/FutureGate/ReleaseV0323PersistentRunLockStore.swift \
  Sources/ExecutionClient/FutureGate/ReleaseV0323IndependentCanaryArtifactGraph.swift \
  Sources/ExecutionClient/FutureGate/ReleaseV0323EvidenceRootContainment.swift \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  checks/verify-v0.32.3-negative-matrix.sh \
  checks/run.sh \
  checks/automation-readiness.sh \
  docs/validation/validation-plan.md \
  docs/validation/trading-validation-matrix.md \
  docs/automation/automation-readiness.md
do
  require_contains "$file" "GH-1540-ADD-COMPLETE-V0323-NEGATIVE-MATRIX"
  require_contains "$file" "TVM-RELEASE-V0323-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX"
  require_contains "$file" "V0323-006-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX"
done

require_contains "docs/contracts/release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-contract.md" "backendClosureDecision=blocked"
require_contains "docs/contracts/release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-contract.md" "productionCutoverAuthorized=false"

echo "MTPRO release v0.32.3 complete negative matrix verification passed."
