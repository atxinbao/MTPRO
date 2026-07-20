#!/usr/bin/env bash
set -euo pipefail

# GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED
# V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN
# V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED
# V0130-001-NO-SYNTHETIC-READINESS-DATA
# V0130-001-NO-PRODUCTION-CUTOVER
# GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL
# TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL
# V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT
# V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS
# V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS
# V0130-002-MISSING-MALFORMED-FAILS-CLOSED
# V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER
# V0130-002-READ-ONLY-INTAKE
# GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION
# TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION
# V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE
# V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA
# V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED
# V0130-003-FIXTURE-ONLY-ISOLATION
# V0130-003-NO-PRODUCTION-CUTOVER
# GH-997-VERIFY-V0130-BUILD-PIPELINE
# TVM-RELEASE-V0130-BUILD-PIPELINE
# V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW
# V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE
# V0130-004-PROVENANCE-VALIDATION-REPORT
# V0130-004-BUILD-FAILS-CLOSED
# V0130-004-NO-PRODUCTION-CUTOVER
# GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE
# TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE
# V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY
# V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE
# V0130-005-EXPORT-COMPARISON-IDENTITY
# V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED
# V0130-005-NO-PRODUCTION-CUTOVER
# GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE
# TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE
# V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE
# V0130-006-COMPLETE-AUDIT-PACKAGE
# V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE
# V0130-006-MISSING-EVIDENCE-FAILS-CLOSED
# V0130-006-NO-SECRET-PRODUCTION-CUTOVER
# GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF
# TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF
# V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE
# V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS
# V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER
# V0130-007-COMPARISON-EXPORT-VALIDATION
# V0130-007-NO-PRODUCTION-CUTOVER
# GH-1001-VERIFY-V0130-TRANSACTION-RECOVERY-SNAPSHOT
# TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT
# V0130-008-TRANSACTION-RECOVERY-SNAPSHOT
# V0130-008-STAGING-STATE-INTENDED-COMPLETED-WRITES
# V0130-008-CLEANUP-AUDIT-TRACE
# V0130-008-PARTIAL-WRITES-FAIL-CLOSED
# V0130-008-NO-PRODUCTION-CUTOVER
# GH-1002-VERIFY-V0130-GENERATION-ID-COLLISION-PROOFING
# TVM-RELEASE-V0130-GENERATION-ID-COLLISION-PROOFING
# V0130-009-GENERATION-ID-COLLISION-PROOFING
# V0130-009-SAME-SECOND-GENERATION-IDS
# V0130-009-REGISTRY-LOOKUP-STABILITY
# V0130-009-AUDITABLE-DETERMINISTIC-PREFIX
# V0130-009-NO-PRODUCTION-CUTOVER
# GH-1003-VERIFY-V0130-ORDERED-READINESS-CLI-LIFECYCLE
# TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE
# V0130-010-CREATE-BUILD-VALIDATE-EXPORT-COMPARE-ARCHIVE
# V0130-010-VALIDATION-EXPORT-MARKERS
# V0130-010-BYPASS-MANUAL-FILES-REJECTED
# V0130-010-NO-PRODUCTION-CUTOVER
# GH-1004-VERIFY-V0130-LOCAL-EVIDENCE-FIXTURES
# TVM-RELEASE-V0130-LOCAL-EVIDENCE-FIXTURES
# V0130-011-MINIMAL-VALID-LOCAL-EVIDENCE-FIXTURE
# V0130-011-INVALID-TAMPERED-MISSING-FIXTURE-CASES
# V0130-011-BUILD-VALIDATE-EXPORT-COMPARE-RECOVERY-REGRESSION
# V0130-011-FIXTURE-RUNTIME-PATH-SEPARATION
# V0130-011-NO-PRODUCTION-CUTOVER
# GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0130-STAGE-AUDIT-RELEASE-DOCS
# V0130-012-STAGE-CODE-AUDIT
# V0130-012-RELEASE-NOTES
# V0130-012-ROOT-DOCS-REFRESH
# V0130-012-VALIDATION-SUMMARY
# V0130-012-NO-PRODUCTION-CUTOVER
# V0130-012-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.13.0 local evidence readiness engine contract guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.13.0 local evidence readiness engine contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.13.0-local-evidence-driven-readiness-engine-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0130LocalEvidenceIntakeModel.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
AUDIT="docs/audit/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-stage-code-audit.md"
RELEASE_NOTES="docs/release/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-notes.md"

swift test --filter TargetGraphTests/testGH994ReleaseV0130LocalEvidenceReadinessEngineContract
swift test --filter TargetGraphTests/testGH995ReleaseV0130LocalEvidenceIntakeModelDiscoversValidRootAndFailsClosed
swift test --filter TargetGraphTests/testGH996ReleaseV0130ProvenanceBuildRejectsSyntheticAndFixtureEvidence
swift test --filter TargetGraphTests/testGH997ReleaseV0130BuildPipelineWritesManifestBundleRegistryAndPolicyReport
swift test --filter TargetGraphTests/testGH998ReleaseV0130ValidateRejectsBrokenEvidenceChain
swift test --filter TargetGraphTests/testGH999ReleaseV0130ExportWritesCompleteRedactedAuditPackage
swift test --filter TargetGraphTests/testGH1000ReleaseV0130CompareBuildsEvidenceLevelDiffAndBlocksBrokenLinks
swift test --filter TargetGraphTests/testGH1001ReleaseV0130TransactionRecoverySnapshotExplainsInterruptedAndStaleStaging
swift test --filter TargetGraphTests/testGH1002ReleaseV0130GenerationIDCollisionProofingKeepsRegistryLookupStable
swift test --filter TargetGraphTests/testGH1003ReleaseV0130OrderedReadinessCLILifecycleRequiresMarkersAndNextActions
swift test --filter TargetGraphTests/testGH1004ReleaseV0130LocalEvidenceFixturesAndRegressionSuiteCoversFailClosedFlow
swift test --filter TargetGraphTests/testGH1005ReleaseV0130StageAuditReleaseDocsCloseout

for anchor in \
  "GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED" \
  "V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN" \
  "V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED" \
  "V0130-001-NO-SYNTHETIC-READINESS-DATA" \
  "V0130-001-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL" \
  "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL" \
  "V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT" \
  "V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS" \
  "V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS" \
  "V0130-002-MISSING-MALFORMED-FAILS-CLOSED" \
  "V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER" \
  "V0130-002-READ-ONLY-INTAKE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION" \
  "TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION" \
  "V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE" \
  "V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA" \
  "V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED" \
  "V0130-003-FIXTURE-ONLY-ISOLATION" \
  "V0130-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-997-VERIFY-V0130-BUILD-PIPELINE" \
  "TVM-RELEASE-V0130-BUILD-PIPELINE" \
  "V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW" \
  "V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE" \
  "V0130-004-PROVENANCE-VALIDATION-REPORT" \
  "V0130-004-BUILD-FAILS-CLOSED" \
  "V0130-004-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE" \
  "TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE" \
  "V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY" \
  "V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE" \
  "V0130-005-EXPORT-COMPARISON-IDENTITY" \
  "V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED" \
  "V0130-005-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE" \
  "TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE" \
  "V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE" \
  "V0130-006-COMPLETE-AUDIT-PACKAGE" \
  "V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE" \
  "V0130-006-MISSING-EVIDENCE-FAILS-CLOSED" \
  "V0130-006-NO-SECRET-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF" \
  "TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF" \
  "V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE" \
  "V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS" \
  "V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER" \
  "V0130-007-COMPARISON-EXPORT-VALIDATION" \
  "V0130-007-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1001-VERIFY-V0130-TRANSACTION-RECOVERY-SNAPSHOT" \
  "TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT" \
  "V0130-008-TRANSACTION-RECOVERY-SNAPSHOT" \
  "V0130-008-STAGING-STATE-INTENDED-COMPLETED-WRITES" \
  "V0130-008-CLEANUP-AUDIT-TRACE" \
  "V0130-008-PARTIAL-WRITES-FAIL-CLOSED" \
  "V0130-008-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1002-VERIFY-V0130-GENERATION-ID-COLLISION-PROOFING" \
  "TVM-RELEASE-V0130-GENERATION-ID-COLLISION-PROOFING" \
  "V0130-009-GENERATION-ID-COLLISION-PROOFING" \
  "V0130-009-SAME-SECOND-GENERATION-IDS" \
  "V0130-009-REGISTRY-LOOKUP-STABILITY" \
  "V0130-009-AUDITABLE-DETERMINISTIC-PREFIX" \
  "V0130-009-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1003-VERIFY-V0130-ORDERED-READINESS-CLI-LIFECYCLE" \
  "TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE" \
  "V0130-010-CREATE-BUILD-VALIDATE-EXPORT-COMPARE-ARCHIVE" \
  "V0130-010-VALIDATION-EXPORT-MARKERS" \
  "V0130-010-BYPASS-MANUAL-FILES-REJECTED" \
  "V0130-010-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1004-VERIFY-V0130-LOCAL-EVIDENCE-FIXTURES" \
  "TVM-RELEASE-V0130-LOCAL-EVIDENCE-FIXTURES" \
  "V0130-011-MINIMAL-VALID-LOCAL-EVIDENCE-FIXTURE" \
  "V0130-011-INVALID-TAMPERED-MISSING-FIXTURE-CASES" \
  "V0130-011-BUILD-VALIDATE-EXPORT-COMPARE-RECOVERY-REGRESSION" \
  "V0130-011-FIXTURE-RUNTIME-PATH-SEPARATION" \
  "V0130-011-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS" \
  "TVM-RELEASE-V0130-STAGE-AUDIT-RELEASE-DOCS" \
  "V0130-012-STAGE-CODE-AUDIT" \
  "V0130-012-RELEASE-NOTES" \
  "V0130-012-ROOT-DOCS-REFRESH" \
  "V0130-012-VALIDATION-SUMMARY" \
  "V0130-012-NO-PRODUCTION-CUTOVER" \
  "V0130-012-NO-TAG-OR-RELEASE-PUBLICATION"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$RELEASE_NOTES" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$AUDIT" "#994"
require_file_contains "$AUDIT" "#1005"
require_file_contains "$AUDIT" "#1023"
require_file_contains "$AUDIT" "a386694234aefac640a7f12d8cbe84875903df5a"
require_file_contains "$AUDIT" 'checks`, `linux-checks`, `dashboard-macos` SUCCESS'
require_file_contains "$RELEASE_NOTES" "v0.13.0 是 local evidence-driven readiness engine construction closeout"
require_file_contains "$RELEASE_NOTES" "不是 testnet order execution"
require_file_contains "$RELEASE_NOTES" "不是 production cutover"
require_file_contains "$README" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$GOAL" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine complete"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$ROADMAP" "GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS"

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.13.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.13.0.sh"
require_file_contains "$READINESS" "Release v0.13.0 local evidence-driven readiness engine contract anchor"
require_file_contains "$READINESS" "Release v0.13.0 local evidence intake model anchor"
require_file_contains "$READINESS" "Release v0.13.0 synthetic provenance rejection anchor"
require_file_contains "$READINESS" "Release v0.13.0 build pipeline anchor"
require_file_contains "$READINESS" "Release v0.13.0 evidence-chain validate anchor"
require_file_contains "$READINESS" "Release v0.13.0 redacted audit export package anchor"
require_file_contains "$READINESS" "Release v0.13.0 evidence-level diff anchor"
require_file_contains "$READINESS" "Release v0.13.0 transaction recovery forensic snapshot anchor"
require_file_contains "$READINESS" "Release v0.13.0 generation ID collision-proofing anchor"
require_file_contains "$READINESS" "Release v0.13.0 ordered CLI execution lifecycle anchor"
require_file_contains "$READINESS" "Release v0.13.0 local evidence fixtures and regression suite anchor"
require_file_contains "$PLAN" "GH-994 Release v0.13.0 Local Evidence-driven Readiness Engine Contract Validation"
require_file_contains "$PLAN" "GH-995 Release v0.13.0 Local Evidence Intake Model Validation"
require_file_contains "$PLAN" "GH-996 Release v0.13.0 Synthetic Provenance Rejection Validation"
require_file_contains "$PLAN" "GH-997 Release v0.13.0 Build Pipeline Validation"
require_file_contains "$PLAN" "GH-998 Release v0.13.0 Evidence-chain Validate Validation"
require_file_contains "$PLAN" "GH-999 Release v0.13.0 Redacted Audit Export Package Validation"
require_file_contains "$PLAN" "GH-1000 Release v0.13.0 Evidence-level Diff Validation"
require_file_contains "$PLAN" "GH-1001 Release v0.13.0 Transaction Recovery Forensic Snapshot Validation"
require_file_contains "$PLAN" "GH-1002 Release v0.13.0 Generation ID Collision-proofing Validation"
require_file_contains "$PLAN" "GH-1003 Release v0.13.0 Ordered Readiness CLI Lifecycle Validation"
require_file_contains "$PLAN" "GH-1004 Release v0.13.0 Local Evidence Fixtures and Regression Suite Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-BUILD-PIPELINE"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-GENERATION-ID-COLLISION-PROOFING"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-FIXTURES"
require_file_contains "$LATEST" "v0.13.0 local evidence-driven readiness engine contract"
require_file_contains "$LATEST" "v0.13.0 local evidence intake model"
require_file_contains "$LATEST" "v0.13.0 synthetic provenance rejection"
require_file_contains "$LATEST" "v0.13.0 build pipeline"
require_file_contains "$LATEST" "v0.13.0 evidence-chain validate"
require_file_contains "$LATEST" "v0.13.0 redacted audit export package"
require_file_contains "$LATEST" "v0.13.0 evidence-level diff"
require_file_contains "$LATEST" "v0.13.0 transaction recovery forensic snapshot"
require_file_contains "$LATEST" "v0.13.0 generation ID collision-proofing"
require_file_contains "$LATEST" "v0.13.0 ordered CLI execution lifecycle"
require_file_contains "$LATEST" "v0.13.0 local evidence fixtures and regression suite"
require_file_contains "$ROADMAP" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$GOAL" "release/v0.13.0"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$README" "release/v0.13.0"
require_file_contains "Tests/Fixtures/ReleaseV0130LocalEvidence/valid/run-logs/run-journal.jsonl" "run-gh1004-fixture-baseline"
require_file_contains "Tests/Fixtures/ReleaseV0130LocalEvidence/valid/artifacts/artifact-index.json" "artifact-gh1004-readiness-summary"
require_file_contains "Tests/Fixtures/ReleaseV0130LocalEvidence/valid/artifacts/readiness-summary.json" "productionTradingEnabledByDefault\":false"
require_file_contains "$TESTS" "source-run-aaaaaaaaaaaaaaaa"
require_file_contains "$TESTS" "artifactSnapshots:artifact-bytes-missing-or-checksum-mismatch"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceIntakeModel"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceIntakeReport"
require_file_contains "$SOURCE" "run-logs/run-journal.jsonl"
require_file_contains "$SOURCE" "event-stream/events.jsonl"
require_file_contains "$SOURCE" "artifacts/artifact-index.json"
require_file_contains "$SOURCE" "registry/registry.json"
require_file_contains "$SOURCE" "prior-assessments/assessments-index.json"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceBuildProvenance"
require_file_contains "$SOURCE" "buildProvenance(evidenceRootURL:"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceBuildPipelineResult"
require_file_contains "$SOURCE" "buildPipeline("
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceChainValidationReport"
require_file_contains "$SOURCE" "validateEvidenceChain("
require_file_contains "$SOURCE" "ReleaseV0130RedactedAuditExportPackageReport"
require_file_contains "$SOURCE" "writeRedactedAuditExportPackage("
require_file_contains "$SOURCE" "ReleaseV0130EvidenceLevelComparisonReport"
require_file_contains "$SOURCE" "compareEvidenceLevelAssessments("
require_file_contains "$SOURCE" "ReleaseV0130TransactionRecoveryForensicSnapshot"
require_file_contains "$SOURCE" "writeTransactionRecoverySnapshot("
require_file_contains "$SOURCE" "transaction-recovery-snapshot.json"
require_file_contains "$SOURCE" "ReleaseV0130GenerationIDFactory"
require_file_contains "$SOURCE" "makeGenerationID("
require_file_contains "$SOURCE" "collisionProofingHeld("
require_file_contains "$SOURCE" "syntheticSourceRunID"
require_file_contains "$SOURCE" "fixtureOnlyEvidence"
require_file_contains "$CLI_SOURCE" "readiness intake <evidenceRoot>"
require_file_contains "$CLI_SOURCE" "readiness build-v013 <assessmentID> <evidenceRoot>"
require_file_contains "$CLI_SOURCE" "intakeValid="
require_file_contains "$CLI_SOURCE" "failClosed="
require_file_contains "$CLI_SOURCE" "syntheticProvenanceRejected="
require_file_contains "$CLI_SOURCE" "fixtureOnlyEvidenceRejected=true"
require_file_contains "$CLI_SOURCE" "validationReportChecksum="
require_file_contains "$CLI_SOURCE" "readinessBundleWritten=true"
require_file_contains "$CLI_SOURCE" "registryEntryConfirmed=true"
require_file_contains "$CLI_SOURCE" "evidenceChainCoherent="
require_file_contains "$CLI_SOURCE" "failureReasons="
require_file_contains "$CLI_SOURCE" "packageComplete="
require_file_contains "$CLI_SOURCE" "exportedChecksumsMatchSource="
require_file_contains "$CLI_SOURCE" "comparisonFormat=evidence-level-readiness-diff"
require_file_contains "$CLI_SOURCE" "comparisonState="
require_file_contains "$CLI_SOURCE" "blockedSections="
require_file_contains "$CLI_SOURCE" "comparisonMetadataJSONPath="
require_file_contains "$CLI_SOURCE" "ReleaseV0130GenerationIDFactory.makeGenerationID("
reject_file_contains "$CLI_SOURCE" '-generation-\(Int(now.timeIntervalSince1970))'

for required_contract_string in \
  "artifact -> policy -> manifest -> bundle -> registry -> diff" \
  "local evidence root" \
  "real local evidence intake" \
  "sourceRunID" \
  "sourceCommit" \
  "generationID" \
  "compare-before-build" \
  "export-before-validate" \
  "synthetic readiness data" \
  "#1004 在 fresh WIP=1 preflight 后作为唯一 active" \
  "#1005 继续 blocked"; do
  require_file_contains "$CONTRACT" "$required_contract_string"
done

for required_generation_string in \
  "generation ID collision-proofing" \
  "same-second generation IDs" \
  "collision-resistant deterministic suffix" \
  "registry lookup remains stable" \
  "auditable deterministic prefix"; do
  require_file_contains "$CONTRACT" "$required_generation_string"
done

for required_intake_string in \
  "run logs / event stream / artifacts / registry / prior assessments" \
  "readiness intake <evidenceRoot>" \
  "missing local evidence root" \
  "malformed JSON / JSONL" \
  "read-only local intake diagnostics" \
  "不写 registry、不生成 bundle、不执行 diff"; do
  require_file_contains "$CONTRACT" "$required_intake_string"
done

for required_validate_string in \
  "readiness validate <assessmentID>" \
  "registry / manifest / bundle / artifact / policy / checksum / provenance" \
  "missing、stale、tampered、inconsistent evidence" \
  "export / comparison identity" \
  "完整 evidence chain"; do
  require_file_contains "$CONTRACT" "$required_validate_string"
done

fixture_root="$(mktemp -d)"
gh996_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root" "$gh996_root"' EXIT
mkdir -p \
  "$fixture_root/run-logs" \
  "$fixture_root/event-stream" \
  "$fixture_root/artifacts" \
  "$fixture_root/registry" \
  "$fixture_root/prior-assessments"

printf '%s\n' '{"sourceRunID":"run-gh995","sourceCommit":"8c3f87168d04f22d4cf21364963648f39f4aaf8e","eventType":"run.completed","createdAt":"2026-06-20T00:00:00Z"}' \
  >"$fixture_root/run-logs/run-journal.jsonl"
printf '%s\n' '{"eventID":"event-gh995","sourceRunID":"run-gh995","eventType":"risk.accepted","occurredAt":"2026-06-20T00:00:01Z"}' \
  >"$fixture_root/event-stream/events.jsonl"
printf '%s\n' '{"sourceRunID":"run-gh995","sourceCommit":"8c3f87168d04f22d4cf21364963648f39f4aaf8e","artifacts":[{"id":"artifact-gh995","path":"artifacts/readiness-summary.json"}]}' \
  >"$fixture_root/artifacts/artifact-index.json"
printf '%s\n' '{"registryVersion":"v0.13.0.local-evidence-intake","assessments":[{"assessmentID":"assessment-gh995"}]}' \
  >"$fixture_root/registry/registry.json"
printf '%s\n' '{"assessmentIDs":["baseline-gh995","followup-gh995"],"sourceRunIDs":["run-gh995"]}' \
  >"$fixture_root/prior-assessments/assessments-index.json"

cli_output="$(swift run mtpro readiness intake "$fixture_root")"
printf '%s\n' "$cli_output" | grep -Fq "issue=GH-995" || fail "CLI intake output must link GH-995"
printf '%s\n' "$cli_output" | grep -Fq "intakeValid=true" || fail "CLI intake output must validate complete local evidence root"
printf '%s\n' "$cli_output" | grep -Fq "failClosed=false" || fail "CLI intake output must not fail closed for valid fixture"
printf '%s\n' "$cli_output" | grep -Fq "localReadOnly=true" || fail "CLI intake output must remain read-only"
printf '%s\n' "$cli_output" | grep -Fq "assessmentOutputWritten=false" || fail "CLI intake output must not write assessment output"
printf '%s\n' "$cli_output" | grep -Fq "registryWritten=false" || fail "CLI intake output must not write registry"
printf '%s\n' "$cli_output" | grep -Fq "productionEndpointConnected=false" || fail "CLI intake output must not connect production endpoint"

rm "$fixture_root/registry/registry.json"
missing_output="$(swift run mtpro readiness intake "$fixture_root")"
printf '%s\n' "$missing_output" | grep -Fq "intakeValid=false" || fail "CLI intake output must fail invalid missing evidence"
printf '%s\n' "$missing_output" | grep -Fq "failClosed=true" || fail "CLI intake output must fail closed on missing evidence"
printf '%s\n' "$missing_output" | grep -Fq "missingDiagnosticCount=1" || fail "CLI intake output must expose missing evidence diagnostic"

write_gh996_evidence_root() {
  local root="$1"
  local source_run_id="$2"
  local source_commit="$3"
  local artifact_extra="${4:-}"
  local extra_json=""

  if [[ -n "$artifact_extra" ]]; then
    extra_json=",$artifact_extra"
  fi

  mkdir -p \
    "$root/run-logs" \
    "$root/event-stream" \
    "$root/artifacts" \
    "$root/registry" \
    "$root/prior-assessments"

  printf '%s\n' "{\"sourceRunID\":\"$source_run_id\",\"sourceCommit\":\"$source_commit\",\"eventType\":\"run.completed\",\"createdAt\":\"2026-06-20T00:00:00Z\"}" \
    >"$root/run-logs/run-journal.jsonl"
  printf '%s\n' "{\"eventID\":\"event-gh996\",\"sourceRunID\":\"$source_run_id\",\"eventType\":\"risk.accepted\",\"occurredAt\":\"2026-06-20T00:00:01Z\"}" \
    >"$root/event-stream/events.jsonl"
  printf '%s\n' "{\"summaryID\":\"artifact-gh996-summary\",\"sourceRunID\":\"$source_run_id\",\"sourceCommit\":\"$source_commit\",\"redactedEvidenceOnly\":true,\"productionTradingEnabledByDefault\":false,\"productionCutoverAuthorized\":false}" \
    >"$root/artifacts/readiness-summary.json"
  printf '%s\n' "{\"sourceRunID\":\"$source_run_id\",\"sourceCommit\":\"$source_commit\",\"artifacts\":[{\"id\":\"artifact-gh996\",\"path\":\"artifacts/readiness-summary.json\"}]$extra_json}" \
    >"$root/artifacts/artifact-index.json"
  printf '%s\n' '{"registryVersion":"v0.13.0.local-evidence-intake","assessments":[{"assessmentID":"assessment-gh996"}]}' \
    >"$root/registry/registry.json"
  printf '%s\n' "{\"assessmentIDs\":[\"baseline-gh996\",\"followup-gh996\"],\"sourceRunIDs\":[\"$source_run_id\"]}" \
    >"$root/prior-assessments/assessments-index.json"
}

gh996_valid_root="$gh996_root/valid"
gh996_store="$gh996_root/store"
gh996_commit="807211695eadba817408ca9e6b8f0bf3a1d080cd"
write_gh996_evidence_root "$gh996_valid_root" "run-gh996" "$gh996_commit"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness create gh-996-assessment >/dev/null
build_output="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-996-assessment "$gh996_valid_root")"
printf '%s\n' "$build_output" | grep -Fq "issue=GH-997" || fail "build-v013 output must link GH-997"
printf '%s\n' "$build_output" | grep -Fq "provenanceIssue=GH-996" || fail "build-v013 output must keep GH-996 provenance link"
printf '%s\n' "$build_output" | grep -Fq "schemaValidated=true" || fail "build-v013 must validate local evidence schema"
printf '%s\n' "$build_output" | grep -Fq "checksumValidated=true" || fail "build-v013 must validate local evidence checksums"
printf '%s\n' "$build_output" | grep -Fq "contentPolicyValidated=true" || fail "build-v013 must run artifact content policy"
printf '%s\n' "$build_output" | grep -Fq "validationReportChecksum=sha256:" || fail "build-v013 must emit validation report checksum"
printf '%s\n' "$build_output" | grep -Fq "manifestWritten=true" || fail "build-v013 must write normal manifest"
printf '%s\n' "$build_output" | grep -Fq "readinessBundleWritten=true" || fail "build-v013 must write readiness bundle"
printf '%s\n' "$build_output" | grep -Fq "registryEntryConfirmed=true" || fail "build-v013 must confirm registry entry"
printf '%s\n' "$build_output" | grep -Fq "registryLifecycleWritten=true" || fail "build-v013 must execute registry lifecycle"
printf '%s\n' "$build_output" | grep -Fq "normalManifestEligible=true" || fail "build-v013 must derive eligible normal manifest provenance"
printf '%s\n' "$build_output" | grep -Fq "sourceCommit=$gh996_commit" || fail "build-v013 must use local evidence source commit"
printf '%s\n' "$build_output" | grep -Fq "sourceRunIDs=run-gh996" || fail "build-v013 must use local evidence sourceRunID"
printf '%s\n' "$build_output" | grep -Fq "artifactRelativePaths=artifacts/readiness-summary.json" || fail "build-v013 must use local evidence artifact path"
printf '%s\n' "$build_output" | grep -Fq "syntheticProvenanceRejected=true" || fail "build-v013 must reject synthetic provenance by contract"
printf '%s\n' "$build_output" | grep -Fq "fixtureOnly=false" || fail "build-v013 normal manifest must not be fixture-only"
printf '%s\n' "$build_output" | grep -Fq "productionCutoverAuthorized=false" || fail "build-v013 must not authorize production cutover"
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness export gh-996-assessment >/tmp/gh1003-export-before-validate.out 2>&1; then
  fail "readiness export must fail closed before readiness validate writes lifecycle marker"
fi
grep -Fq "nextRequiredAction=readiness validate gh-996-assessment" /tmp/gh1003-export-before-validate.out \
  || fail "export-before-validate failure must state next required action"
grep -Fq "reason=validationMarkerMissing" /tmp/gh1003-export-before-validate.out \
  || fail "export-before-validate failure must explain missing validation marker"

validate_output="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness validate gh-996-assessment)"
printf '%s\n' "$validate_output" | grep -Fq "issue=GH-998" || fail "readiness validate output must link GH-998"
printf '%s\n' "$validate_output" | grep -Fq "lifecycleIssue=GH-1003" || fail "readiness validate output must link GH-1003 lifecycle order"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleAnchor=GH-1003-VERIFY-V0130-ORDERED-READINESS-CLI-LIFECYCLE" || fail "readiness validate output must expose GH-1003 lifecycle anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleMatrixAnchor=TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE" || fail "readiness validate output must expose GH-1003 matrix anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleOrderAnchor=V0130-010-CREATE-BUILD-VALIDATE-EXPORT-COMPARE-ARCHIVE" || fail "readiness validate output must expose ordered lifecycle anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleMarkerAnchor=V0130-010-VALIDATION-EXPORT-MARKERS" || fail "readiness validate output must expose marker anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleBypassAnchor=V0130-010-BYPASS-MANUAL-FILES-REJECTED" || fail "readiness validate output must expose bypass rejection anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013LifecycleNoCutoverAnchor=V0130-010-NO-PRODUCTION-CUTOVER" || fail "readiness validate output must expose no cutover anchor"
printf '%s\n' "$validate_output" | grep -Fq "v013ValidationAnchor=GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE" || fail "readiness validate output must expose GH-998 anchor"
printf '%s\n' "$validate_output" | grep -Fq "registryDocumentHeld=true" || fail "readiness validate must confirm registry document"
printf '%s\n' "$validate_output" | grep -Fq "bundleV2Present=true" || fail "readiness validate must confirm Bundle V2 presence"
printf '%s\n' "$validate_output" | grep -Fq "bundleManifestPresent=true" || fail "readiness validate must confirm bundle manifest presence"
printf '%s\n' "$validate_output" | grep -Fq "bundleBytesMatchManifest=true" || fail "readiness validate must confirm bundle bytes"
printf '%s\n' "$validate_output" | grep -Fq "manifestBundleIdentityMatches=true" || fail "readiness validate must confirm manifest/bundle identity"
printf '%s\n' "$validate_output" | grep -Fq "manifestBundleProvenanceMatches=true" || fail "readiness validate must confirm provenance"
printf '%s\n' "$validate_output" | grep -Fq "artifactSnapshotsMatchManifest=true" || fail "readiness validate must confirm artifact snapshots"
printf '%s\n' "$validate_output" | grep -Fq "contentValidationChecksumsPresent=true" || fail "readiness validate must confirm content checksums"
printf '%s\n' "$validate_output" | grep -Fq "exportComparisonIdentityConsistent=true" || fail "readiness validate must confirm optional export/comparison identity"
printf '%s\n' "$validate_output" | grep -Fq "evidenceChainCoherent=true" || fail "readiness validate must pass only coherent evidence chain"
printf '%s\n' "$validate_output" | grep -Fq "failureReasons=none" || fail "readiness validate valid chain must report no failures"
printf '%s\n' "$validate_output" | grep -Fq "validationState=valid" || fail "readiness validate valid chain must be valid"
printf '%s\n' "$validate_output" | grep -Fq "validationMarkerWritten=true" || fail "readiness validate must write lifecycle validation marker"
printf '%s\n' "$validate_output" | grep -Fq "validationMarkerHeld=true" || fail "readiness validate marker must be held"
printf '%s\n' "$validate_output" | grep -Fq "nextRequiredAction=readiness export gh-996-assessment" || fail "readiness validate must state next required action"
[[ -s "$gh996_store/assessments/gh-996-assessment/validation-state.json" ]] || fail "readiness validate must write validation-state.json"

export_output="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness export gh-996-assessment)"
printf '%s\n' "$export_output" | grep -Fq "issue=GH-999" || fail "readiness export output must link GH-999"
printf '%s\n' "$export_output" | grep -Fq "lifecycleIssue=GH-1003" || fail "readiness export output must link GH-1003 lifecycle order"
printf '%s\n' "$export_output" | grep -Fq "v013ValidationAnchor=GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE" || fail "readiness export must expose GH-999 anchor"
printf '%s\n' "$export_output" | grep -Fq "exportFormat=redacted-audit-export-package" || fail "readiness export must write redacted audit package"
printf '%s\n' "$export_output" | grep -Fq "packageComplete=true" || fail "readiness export package must be complete"
printf '%s\n' "$export_output" | grep -Fq "exportedChecksumsMatchSource=true" || fail "readiness export must match source checksums"
printf '%s\n' "$export_output" | grep -Fq "evidenceChainCoherent=true" || fail "readiness export must require coherent evidence chain"
printf '%s\n' "$export_output" | grep -Fq "missingEvidenceFailsClosed=true" || fail "readiness export must fail closed on missing evidence"
printf '%s\n' "$export_output" | grep -Fq "redactedEvidenceOnly=true" || fail "readiness export must remain redacted-only"
printf '%s\n' "$export_output" | grep -Fq "noSecretValue=true" || fail "readiness export must not write secret values"
printf '%s\n' "$export_output" | grep -Fq "noEndpointPayload=true" || fail "readiness export must not write endpoint payloads"
printf '%s\n' "$export_output" | grep -Fq "noOrderPayload=true" || fail "readiness export must not write order payloads"
printf '%s\n' "$export_output" | grep -Fq "productionCutoverAuthorized=false" || fail "readiness export must not authorize production cutover"
printf '%s\n' "$export_output" | grep -Fq "validationMarkerHeld=true" || fail "readiness export must require validation marker"
printf '%s\n' "$export_output" | grep -Fq "exportMarkerWritten=true" || fail "readiness export must write export marker"
printf '%s\n' "$export_output" | grep -Fq "exportMarkerHeld=true" || fail "readiness export marker must be held"
printf '%s\n' "$export_output" | grep -Fq "nextRequiredAction=readiness compare/archive" || fail "readiness export must state compare/archive next action"
[[ -s "$gh996_store/assessments/gh-996-assessment/export-state.json" ]] || fail "readiness export must write export-state.json"
gh999_export_dir="$gh996_store/assessments/gh-996-assessment/redacted-export"
for export_file in \
  "assessment-summary.json" \
  "manifest-v2.json" \
  "bundle-v2.json" \
  "validation-report.json" \
  "provenance.json" \
  "comparison.json"; do
  [[ -s "$gh999_export_dir/$export_file" ]] || fail "readiness export must write $export_file"
  grep -Fq "gh-996-assessment" "$gh999_export_dir/$export_file" || fail "$export_file must bind assessmentID"
done
cmp -s "$gh996_store/assessments/gh-996-assessment/manifest-v2.json" "$gh999_export_dir/manifest-v2.json" \
  || fail "exported manifest-v2.json must match source bytes"
gh999_source_bundle="$(find "$gh996_store/assessments/gh-996-assessment/generations" -name readiness-bundle-v2.json -print -quit)"
[[ -n "$gh999_source_bundle" ]] || fail "readiness export smoke must find source bundle"
cmp -s "$gh999_source_bundle" "$gh999_export_dir/bundle-v2.json" \
  || fail "exported bundle-v2.json must match source bytes"
post_export_validate="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness validate gh-996-assessment)"
printf '%s\n' "$post_export_validate" | grep -Fq "exportComparisonIdentityConsistent=true" || fail "readiness validate must accept export/comparison identity after export"
printf '%s\n' "$post_export_validate" | grep -Fq "evidenceChainCoherent=true" || fail "readiness validate must remain coherent after export"

gh1000_followup_root="$gh996_root/gh1000-followup"
write_gh996_evidence_root "$gh1000_followup_root" "run-gh1000-followup" "$gh996_commit"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-1000-followup "$gh1000_followup_root" >/dev/null
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness compare gh-996-assessment gh-1000-followup >/tmp/gh1003-compare-before-followup-validate.out 2>&1; then
  fail "readiness compare must fail closed before follow-up validate writes lifecycle marker"
fi
grep -Fq "nextRequiredAction=readiness validate gh-1000-followup" /tmp/gh1003-compare-before-followup-validate.out \
  || fail "compare-before-follow-up-validate failure must state next required action"
grep -Fq "reason=validationMarkerMissing" /tmp/gh1003-compare-before-followup-validate.out \
  || fail "compare-before-follow-up-validate failure must explain missing marker"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness validate gh-1000-followup >/dev/null
compare_output="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness compare gh-996-assessment gh-1000-followup)"
printf '%s\n' "$compare_output" | grep -Fq "issue=GH-1000" || fail "readiness compare output must link GH-1000"
printf '%s\n' "$compare_output" | grep -Fq "lifecycleIssue=GH-1003" || fail "readiness compare output must link GH-1003 lifecycle order"
printf '%s\n' "$compare_output" | grep -Fq "v013ValidationAnchor=GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF" || fail "readiness compare must expose GH-1000 anchor"
printf '%s\n' "$compare_output" | grep -Fq "comparisonFormat=evidence-level-readiness-diff" || fail "readiness compare must use evidence-level format for v0.13"
printf '%s\n' "$compare_output" | grep -Fq "comparisonState=changed" || fail "readiness compare must report changed evidence"
printf '%s\n' "$compare_output" | grep -Fq "comparedSections=source-data,policy,risk-posture,checksum-chain,provenance,evidence-completeness" || fail "readiness compare must cover all evidence-level sections"
printf '%s\n' "$compare_output" | grep -Fq "blockedSections=" || fail "readiness compare must expose blocked sections field"
printf '%s\n' "$compare_output" | grep -Fq "blockers=none" || fail "readiness compare valid chain must not report blockers"
printf '%s\n' "$compare_output" | grep -Fq "compareDoesNotMutateAssessments=true" || fail "readiness compare must remain non-mutating"
printf '%s\n' "$compare_output" | grep -Fq "operatorReviewOnly=true" || fail "readiness compare must remain operator-review-only"
printf '%s\n' "$compare_output" | grep -Fq "comparisonMetadataJSONPath=.local/mtpro/readiness/assessments/gh-1000-followup/comparison-metadata.json" || fail "readiness compare must write comparison metadata"
printf '%s\n' "$compare_output" | grep -Fq "baselineExportMarkerHeld=true" || fail "readiness compare must require baseline export marker"
printf '%s\n' "$compare_output" | grep -Fq "followUpValidationMarkerHeld=true" || fail "readiness compare must require follow-up validation marker"
printf '%s\n' "$compare_output" | grep -Fq "lifecycleOrderHeld=true" || fail "readiness compare must hold lifecycle order"
[[ -s "$gh996_store/assessments/gh-1000-followup/comparison-metadata.json" ]] || fail "readiness compare must write comparison metadata JSON"
grep -Fq "gh-1000-followup" "$gh996_store/assessments/gh-1000-followup/comparison-metadata.json" \
  || fail "comparison metadata must bind follow-up assessmentID"
post_compare_validate="$(MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness validate gh-1000-followup)"
printf '%s\n' "$post_compare_validate" | grep -Fq "exportComparisonIdentityConsistent=true" || fail "validate must accept comparison metadata identity"

gh1000_block_store="$gh996_root/gh1000-block-store"
MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness build-v013 gh-1000-block-baseline "$gh996_valid_root" >/dev/null
MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness validate gh-1000-block-baseline >/dev/null
MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness export gh-1000-block-baseline >/dev/null
gh1000_block_followup_root="$gh996_root/gh1000-block-followup"
write_gh996_evidence_root "$gh1000_block_followup_root" "run-gh1000-block-followup" "$gh996_commit"
MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness build-v013 gh-1000-block-followup "$gh1000_block_followup_root" >/dev/null
MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness validate gh-1000-block-followup >/dev/null
gh1000_block_bundle="$(find "$gh1000_block_store/assessments/gh-1000-block-followup/generations" -name readiness-bundle-v2.json -print -quit)"
[[ -n "$gh1000_block_bundle" ]] || fail "readiness compare blocker smoke must find follow-up bundle"
rm "$gh1000_block_bundle"
blocked_compare_output="$(MTPRO_READINESS_ROOT="$gh1000_block_store" swift run mtpro readiness compare gh-1000-block-baseline gh-1000-block-followup)"
printf '%s\n' "$blocked_compare_output" | grep -Fq "comparisonState=blocked" || fail "readiness compare must block broken evidence links"
printf '%s\n' "$blocked_compare_output" | grep -Fq "blockedSections=source-data,policy,risk-posture,checksum-chain,provenance,evidence-completeness" || fail "readiness compare broken links must block all evidence sections"
printf '%s\n' "$blocked_compare_output" | grep -Fq "follow-up:bundleBytes:missing" || fail "readiness compare blockers must explain missing bundle bytes"
printf '%s\n' "$blocked_compare_output" | grep -Fq "follow-up:bundleV2:missing-or-invalid" || fail "readiness compare blockers must explain broken Bundle V2"

gh998_tamper_store="$gh996_root/gh998-tamper-store"
MTPRO_READINESS_ROOT="$gh998_tamper_store" swift run mtpro readiness build-v013 gh-998-tamper "$gh996_valid_root" >/dev/null
MTPRO_READINESS_ROOT="$gh998_tamper_store" swift run mtpro readiness validate gh-998-tamper >/dev/null
tamper_bundle="$(find "$gh998_tamper_store/assessments/gh-998-tamper/generations" -name readiness-bundle-v2.json -print -quit)"
[[ -n "$tamper_bundle" ]] || fail "readiness validate tamper smoke must find bundle JSON"
printf '\n' >>"$tamper_bundle"
tamper_validate_output="$(MTPRO_READINESS_ROOT="$gh998_tamper_store" swift run mtpro readiness validate gh-998-tamper)"
printf '%s\n' "$tamper_validate_output" | grep -Fq "validationState=blocked" || fail "readiness validate must block tampered evidence"
printf '%s\n' "$tamper_validate_output" | grep -Fq "evidenceChainCoherent=false" || fail "readiness validate must mark tampered chain incoherent"
printf '%s\n' "$tamper_validate_output" | grep -Fq "failureReasons=bundleBytes:checksum-or-byte-count-mismatch" || fail "readiness validate must explain bundle byte tamper"
if MTPRO_READINESS_ROOT="$gh998_tamper_store" swift run mtpro readiness export gh-998-tamper >/tmp/gh999-tampered-export.out 2>&1; then
  fail "readiness export must fail closed when evidence chain is tampered"
fi
grep -Fq "redactedAuditExport:evidenceChainInvalid" /tmp/gh999-tampered-export.out \
  || fail "tampered export failure must explain evidence-chain invalidity"

gh997_auto_store="$gh996_root/gh997-auto-store"
auto_registry_output="$(MTPRO_READINESS_ROOT="$gh997_auto_store" swift run mtpro readiness build-v013 gh-997-auto-assessment "$gh996_valid_root")"
printf '%s\n' "$auto_registry_output" | grep -Fq "registryEntryCreated=true" || fail "build-v013 must create missing local registry entry"
printf '%s\n' "$auto_registry_output" | grep -Fq "readinessBundleWritten=true" || fail "build-v013 missing-registry path must still write bundle"

gh996_placeholder_root="$gh996_root/placeholder"
write_gh996_evidence_root "$gh996_placeholder_root" "run-gh996" "0123456789abcdef0123456789abcdef01234567"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness create gh-996-placeholder >/dev/null
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-996-placeholder "$gh996_placeholder_root" >/tmp/gh996-placeholder.out 2>&1; then
  fail "build-v013 must fail closed for placeholder sourceCommit"
fi
grep -Fq "invalid sourceCommit" /tmp/gh996-placeholder.out || fail "placeholder failure must explain invalid sourceCommit"

gh996_synthetic_root="$gh996_root/synthetic"
write_gh996_evidence_root "$gh996_synthetic_root" "gh-963-source-run" "$gh996_commit"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness create gh-996-synthetic >/dev/null
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-996-synthetic "$gh996_synthetic_root" >/tmp/gh996-synthetic.out 2>&1; then
  fail "build-v013 must fail closed for synthetic sourceRunID"
fi
grep -Fq "synthetic sourceRunID" /tmp/gh996-synthetic.out || fail "synthetic failure must explain sourceRunID rejection"

gh996_fixture_root="$gh996_root/fixture"
write_gh996_evidence_root "$gh996_fixture_root" "run-gh996" "$gh996_commit" '"fixtureOnly":true'
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness create gh-996-fixture >/dev/null
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-996-fixture "$gh996_fixture_root" >/tmp/gh996-fixture.out 2>&1; then
  fail "build-v013 must fail closed for fixture-only evidence"
fi
grep -Fq "fixture-only evidence" /tmp/gh996-fixture.out || fail "fixture failure must explain fixture-only rejection"

gh997_endpoint_root="$gh996_root/endpoint"
write_gh996_evidence_root "$gh997_endpoint_root" "run-gh996" "$gh996_commit"
printf '%s\n' "{\"summaryID\":\"artifact-gh997-endpoint\",\"sourceRunID\":\"run-gh996\",\"sourceCommit\":\"$gh996_commit\",\"redactedEvidenceOnly\":true,\"noSecretValue\":true,\"noOrderPayload\":true,\"diagnostic\":\"https://api.binance.com/api/v3/account\",\"productionTradingEnabledByDefault\":false,\"productionCutoverAuthorized\":false}" \
  >"$gh997_endpoint_root/artifacts/readiness-summary.json"
MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness create gh-997-endpoint >/dev/null
if MTPRO_READINESS_ROOT="$gh996_store" swift run mtpro readiness build-v013 gh-997-endpoint "$gh997_endpoint_root" >/tmp/gh997-endpoint.out 2>&1; then
  fail "build-v013 must fail closed for artifact raw endpoint markers"
fi
grep -Fq "artifactContentPolicy:rejectedContent" /tmp/gh997-endpoint.out || fail "endpoint failure must explain content policy rejection"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

echo "MTPRO release v0.13.0 local evidence-driven readiness engine and intake verification passed."
