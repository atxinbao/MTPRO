#!/usr/bin/env bash
set -euo pipefail

# GH-1459-SYNC-V0290-PUBLICATION-FACTS
# GH-1460-RECLASSIFY-V0290-DETERMINISTIC-FIXTURE-EVIDENCE
# GH-1461-WIRE-V0290-CLI-DASHBOARD-ACCEPTANCE-SURFACE
# GH-1462-VALIDATE-V0290-ARTIFACT-FILES-SHA-RUN-APPROVAL-FRESHNESS-PROVENANCE
# GH-1463-SEPARATE-FIXTURE-FROM-OBSERVED-RUN-ACCEPTANCE
# GH-1464-ENFORCE-PRE-TAG-WORKFLOW-DISPATCH-RELEASE-BRANCH-GATE
# GH-1465-SYNC-CURRENT-DOCS-CANONICAL-VENUE-PRODUCT-TARGETS
# GH-1466-DEDUPE-NESTED-SWIFT-TEST-ORCHESTRATION
# GH-1467-CLOSE-V0291-STAGE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.29.1 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.29.1 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0291ShadowAcceptanceIntegrity.swift"
V0290_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0290ProductionDryRunShadowAcceptance.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0290DashboardCLIShadowAcceptanceSurface.swift"
CLI="Sources/MTPROCLI/main.swift"
AUDIT="docs/audit/mtpro-release-v0.29.1-shadow-acceptance-integrity-publication-gate-repair-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.29.1-shadow-acceptance-integrity-publication-gate-repair-patch-notes.md"
V0290_NOTES="docs/release/mtpro-release-v0.29.0-binance-production-dry-run-shadow-run-acceptance-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
V0290_VERIFY="checks/verify-v0.29.0.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
AUTOMATION_DOC="docs/automation/automation-readiness.md"

swift test --filter TargetGraphTests/testGH1459To1467ReleaseV0291ShadowAcceptanceIntegrityPatch

CLI_STATUS="$(swift run mtpro production-shadow-acceptance status)"
for expected in \
  "release=v0.29.0" \
  "evidenceOrigin=deterministic-fixture" \
  "acceptanceDecision=blocked" \
  "acceptanceClassification=contract-deterministic-fixture" \
  "observedRunAccepted=false" \
  "boundaryHeld=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_STATUS"; then
    printf 'release v0.29.1 validation failed: CLI status must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

for file in \
  "$SOURCE" \
  "$V0290_SOURCE" \
  "$DASHBOARD" \
  "$CLI" \
  "$AUDIT" \
  "$NOTES" \
  "$V0290_NOTES" \
  "$LATEST" \
  "$ROADMAP" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$V0290_VERIFY" \
  "$AUTOMATION_SCRIPT" \
  "$AUTOMATION_DOC" \
  "$0"; do
  require_file_contains "$file" "TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION" "$NOTES" "$V0290_NOTES"; do
  require_file_contains "$file" "v0.29.0 GitHub Release is published"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0"
  require_file_contains "$file" "2b070ea979adfec5fccf90fcd823512d99ec4c3c"
  require_file_contains "$file" "2026-07-10T14:23:30Z"
  require_file_contains "$file" "evidenceOrigin=deterministic-fixture"
  require_file_contains "$file" "acceptanceDecision=blocked"
  require_file_contains "$file" "observedRunAccepted=false"
  reject_file_contains "$file" "does not create the v0.29.0 tag or GitHub Release"
done

for file in "$SOURCE" "$TESTS" "$AUDIT" "$NOTES"; do
  require_file_contains "$file" "observed-run-artifact"
  require_file_contains "$file" "sha256"
  require_file_contains "$file" "operatorApproval"
  require_file_contains "$file" "redaction"
  require_file_contains "$file" "immutable"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.29.1.sh"
require_file_contains "$RUN_SCRIPT" "MTPRO_SKIP_FOCUSED_SWIFT_TEST=1 bash checks/verify-v0.29.0.sh"
require_file_contains "$V0290_VERIFY" "MTPRO_SKIP_FOCUSED_SWIFT_TEST"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.29.1.sh"
require_file_contains "$AUTOMATION_DOC" "checks/verify-v0.29.1.sh"
require_file_contains "$TESTS" "testGH1459To1467ReleaseV0291ShadowAcceptanceIntegrityPatch"

printf 'MTPRO v0.29.1 shadow acceptance integrity checks passed.\n'
