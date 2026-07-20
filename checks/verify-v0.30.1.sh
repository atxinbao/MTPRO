#!/usr/bin/env bash
set -euo pipefail

# GH-1478-VERIFY-V0301-V0300-PUBLICATION-FACTS
# GH-1479-VERIFY-V0301-DETERMINISTIC-FIXTURE-FAIL-CLOSED
# GH-1480-VERIFY-V0301-ARTIFACT-INTEGRITY-ACCEPTANCE
# GH-1481-VERIFY-V0301-CLI-EXPLICIT-ARTIFACT-INPUT
# GH-1482-VERIFY-V0301-HUMAN-APPROVED-OBSERVED-BUNDLE
# GH-1483-VERIFY-V0301-PREPUBLICATION-MATRIX-GATE
# GH-1484-VERIFY-V0301-DEDUPE-VALIDATION-ORCHESTRATION
# GH-1485-VERIFY-V0301-BINANCE-ONLY-ROOT-DOCS-MILESTONES
# GH-1486-VERIFY-V0301-STAGE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0301-OBSERVED-SHADOW-INTEGRITY-REPAIR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.30.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.30.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH1468To1475ReleaseV0300ObservedProductionShadowRun

CLI_STATUS="$(swift run mtpro observed-production-shadow status)"
for expected in \
  "release=v0.30.0" \
  "evidenceOrigin=deterministic-fixture" \
  "acceptanceDecision=blocked" \
  "artifactValidationPassed=false" \
  "observedRunAccepted=false" \
  "productionTradingEnabledByDefault=false" \
  "productionCutoverAuthorized=false" \
  "productionSubmitCancelReplaceEnabled=false" \
  "boundaryHeld=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_STATUS"; then
    printf 'release v0.30.1 validation failed: CLI status must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0300ObservedProductionShadowRun.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.30.0.sh" \
  "checks/verify-v0.30.1.sh" \
  "checks/run.sh" \
  "docs/release/mtpro-release-v0.30.1-observed-shadow-integrity-repair-patch-notes.md" \
  "docs/audit/mtpro-release-v0.30.1-observed-shadow-integrity-repair-stage-code-audit.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/verification.md"; do
  for expected in \
    "GH-1478-VERIFY-V0301-V0300-PUBLICATION-FACTS" \
    "GH-1479-VERIFY-V0301-DETERMINISTIC-FIXTURE-FAIL-CLOSED" \
    "GH-1480-VERIFY-V0301-ARTIFACT-INTEGRITY-ACCEPTANCE" \
    "GH-1481-VERIFY-V0301-CLI-EXPLICIT-ARTIFACT-INPUT" \
    "GH-1482-VERIFY-V0301-HUMAN-APPROVED-OBSERVED-BUNDLE" \
    "GH-1483-VERIFY-V0301-PREPUBLICATION-MATRIX-GATE" \
    "GH-1484-VERIFY-V0301-DEDUPE-VALIDATION-ORCHESTRATION" \
    "GH-1485-VERIFY-V0301-BINANCE-ONLY-ROOT-DOCS-MILESTONES" \
    "GH-1486-VERIFY-V0301-STAGE-AUDIT-RELEASE-NOTES" \
    "TVM-RELEASE-V0301-OBSERVED-SHADOW-INTEGRITY-REPAIR"; do
    require_file_contains "$file" "$expected"
  done
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.30.1.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.30.1.sh"
require_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV0300ObservedProductionShadowRun.swift" "loadObservedArtifactBundle"
require_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV0300ObservedProductionShadowRun.swift" "--artifact-root"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "acceptedRun.observedRunAccepted"
reject_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" "observedRunAccepted=true"
reject_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" "observedRunAccepted=true"
reject_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md" "observedRunAccepted=true"
reject_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md" "observedRunAccepted=true"
reject_file_contains "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" "observedRunAccepted=true"

printf 'MTPRO v0.30.1 observed shadow integrity repair checks passed.\n'
