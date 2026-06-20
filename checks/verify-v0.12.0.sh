#!/usr/bin/env bash
set -euo pipefail

# GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
# TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
# V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT
# V0120-001-EVIDENCE-PROVENANCE-MODEL
# V0120-001-MULTI-ASSESSMENT-HISTORY
# V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES
# V0120-001-NO-PRODUCTION-CUTOVER
# GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS
# TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS
# V0120-002-V0110-PUBLICATION-FACT
# V0120-002-V0111-PATCH-FACT
# V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION
# V0120-002-NO-PRODUCTION-CUTOVER
# GH-954-VERIFY-V0120-READINESS-ASSESSMENT-REGISTRY-STORE
# TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE
# V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE
# V0120-003-REGISTRY-JSON-PATH
# V0120-003-ASSESSMENT-DIRECTORY-PATH
# V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER
# V0120-003-COMPARE-READY-METADATA
# V0120-003-NO-PRODUCTION-CUTOVER
# GH-955-VERIFY-V0120-ASSESSMENT-TRANSACTION-LOCK
# TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK
# V0120-004-ASSESSMENT-TRANSACTION-LOCK
# V0120-004-TRANSACTION-ID-GENERATION-ID
# V0120-004-STAGING-DIRECTORY-COMMIT-MARKER
# V0120-004-COMPARE-AND-SWAP-MANIFEST
# V0120-004-CRASH-RECOVERY-SEMANTICS
# V0120-004-NO-PRODUCTION-CUTOVER
# GH-956-VERIFY-V0120-READINESS-MANIFEST-V2
# TVM-RELEASE-V0120-READINESS-MANIFEST-V2
# V0120-005-READINESS-MANIFEST-V2
# V0120-005-ASSESSMENT-GENERATION-PROVENANCE
# V0120-005-SOURCE-RUN-COMMIT-PROVENANCE
# V0120-005-CANONICAL-ARTIFACT-METADATA
# V0120-005-PRODUCER-VERSION-SCHEMA
# V0120-005-NO-PRODUCTION-CUTOVER
# GH-957-VERIFY-V0120-ARTIFACT-CONTENT-POLICY-REDACTION
# TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION
# V0120-006-ARTIFACT-CONTENT-POLICY
# V0120-006-JSON-SCHEMA-ALLOWLIST
# V0120-006-FORBIDDEN-FIELD-REJECTION
# V0120-006-RAW-SECRET-LISTENKEY-REJECTION
# V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION
# V0120-006-CONTENT-VALIDATION-CHECKSUM
# V0120-006-NO-PRODUCTION-CUTOVER
# GH-958-VERIFY-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
# TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
# V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
# V0120-007-READINESS-BUNDLE-V2-JSON
# V0120-007-READINESS-BUNDLE-V2-MANIFEST-JSON
# V0120-007-REVIEW-SNAPSHOT-IMMUTABLE
# V0120-007-NEW-GENERATION-ON-CHANGE
# V0120-007-BUNDLE-MANIFEST-CHECKSUM
# V0120-007-NO-PRODUCTION-CUTOVER
# GH-959-VERIFY-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
# TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
# V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
# V0120-008-OBSERVED-EXPIRES-REVIEWED-SOURCE-EVIDENCE
# V0120-008-DERIVED-FRESHNESS-AND-REVIEW-STATE
# V0120-008-STALE-UNREVIEWED-MISMATCH-FAIL-CLOSED
# V0120-008-APPROVAL-REQUEST-ONLY-NO-CUTOVER
# V0120-008-NO-PRODUCTION-CUTOVER
# GH-960-VERIFY-V0120-APPROVAL-ROLE-QUORUM-SEPARATION
# TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION
# V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION
# V0120-009-REQUESTER-REVIEWER-APPROVER-ROLE-POLICY
# V0120-009-QUORUM-SEPARATION-OF-DUTIES
# V0120-009-APPROVAL-EXPIRY-REVOCATION-FAIL-CLOSED
# V0120-009-BUNDLE-CHECKSUM-BINDING
# V0120-009-TRANSITION-CHECKSUM-CHAIN
# V0120-009-NO-PRODUCTION-CUTOVER
# GH-961-VERIFY-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT
# TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT
# V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT
# V0120-010-SOURCE-RUN-MANIFEST-CHECKSUM
# V0120-010-EVENT-ID-SET-BINDING
# V0120-010-RISK-DECISION-ID-BINDING
# V0120-010-OMS-DRY-RUN-LIFECYCLE-ID-BINDING
# V0120-010-PORTFOLIO-PROJECTION-CHECKSUM-BINDING
# V0120-010-RECONCILIATION-CHECKSUM-BINDING
# V0120-010-NO-PRODUCTION-CUTOVER
# GH-962-VERIFY-V0120-READINESS-ASSESSMENT-DIFF-COMPARE
# TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE
# V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE
# V0120-011-POLICY-ARTIFACT-RISK-KILL-APPROVAL-SECTIONS
# V0120-011-SOURCE-RUN-EVIDENCE-COMPARISON
# V0120-011-NON-MUTATING-COMPARE
# V0120-011-NO-PRODUCTION-CUTOVER
# GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE
# TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE
# V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE
# V0120-012-CREATE-BUILD-STATUS-VALIDATE-EXPORT-ARCHIVE
# V0120-012-COMPARE-LOCAL-ASSESSMENTS
# V0120-012-INVALID-ASSESSMENT-ID-FAIL-CLOSED
# V0120-012-LOCAL-REGISTRY-STORE-ONLY
# V0120-012-NO-PRODUCTION-CUTOVER
# GH-964-VERIFY-V0120-DASHBOARD-ASSESSMENT-HISTORY
# TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY
# V0120-013-DASHBOARD-ASSESSMENT-HISTORY
# V0120-013-ASSESSMENT-LIST-DETAIL-GENERATION-HISTORY
# V0120-013-PROVENANCE-VALIDATION-APPROVAL-COMPARISON
# V0120-013-ADVERSARIAL-CI-GUARD
# V0120-013-NO-PRODUCTION-CUTOVER
# GH-965-VERIFY-V0120-FINAL-AUDIT-DOCS-RUNBOOK
# GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK
# TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK
# V0120-014-STAGE-CODE-AUDIT
# V0120-014-RELEASE-NOTES
# V0120-014-OPERATOR-RUNBOOK
# V0120-014-ASSESSMENT-REGISTRY-SCHEMA
# V0120-014-MANIFEST-V2-SCHEMA
# V0120-014-PROVENANCE-CONTRACT
# V0120-014-ADVERSARIAL-VALIDATION-SUMMARY
# V0120-014-ROOT-DOCS-REFRESH
# V0120-014-AGGREGATE-VERIFY
# V0120-014-NO-PRODUCTION-CUTOVER
# V0120-014-NO-TAG-OR-RELEASE-MOVE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

bash checks/verify-v0.12.1-release-fact-sync.sh

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.12.0 assessment-session contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.12.0 assessment-session contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.12.0-readiness-assessment-session-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="README.md"
RELEASE_POLICY="docs/release/release-publication-policy.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
WORKFLOW=".github/workflows/checks.yml"
DASHBOARD_SOURCE="Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift"
DASHBOARD_SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
DASHBOARD_GUARD="checks/verify-v0.12.0-dashboard-macos-guards.sh"
AUDIT="docs/audit/mtpro-release-v0.12.0-readiness-assessment-sessions-stage-code-audit.md"
RELEASE_NOTES="docs/release/mtpro-release-v0.12.0-readiness-assessment-sessions-notes.md"
RUNBOOK="docs/operators/release-v0.12.0-readiness-assessment-sessions-runbook.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
REGISTRY_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0120ReadinessAssessmentRegistryStore.swift"
KILL_SWITCH_NO_TRADE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100KillSwitchNoTradeReadinessGate.swift"
APPROVAL_WORKFLOW_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110AuditableApprovalWorkflow.swift"
SHADOW_PARITY_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift"
MTPRO_CLI_SOURCE="Sources/MTPROCLI/main.swift"

swift test --filter TargetGraphTests/testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract
swift test --filter TargetGraphTests/testGH953ReleaseV0120CarriesForwardV011XPublicationAndPatchFacts
swift test --filter TargetGraphTests/testGH954ReadinessAssessmentRegistryStorePersistsLifecycleAndCompareReadyMetadata
swift test --filter TargetGraphTests/testGH955AssessmentTransactionLockControlsGenerationAndCrashRecovery
swift test --filter TargetGraphTests/testGH956ReadinessManifestV2RecordsAssessmentGenerationAndProvenance
swift test --filter TargetGraphTests/testGH957ArtifactContentPolicyRejectsSecretsListenKeysOrdersAndEndpointResponses
swift test --filter TargetGraphTests/testGH958ImmutableReadinessBundleSnapshotRequiresNewGenerationOnChange
swift test --filter TargetGraphTests/testGH959KillSwitchNoTradeTrustworthyObservationsFailClosed
swift test --filter TargetGraphTests/testGH960ApprovalRolesQuorumAndBundleBindingFailClosed
swift test --filter TargetGraphTests/testGH961ShadowParityBindsImmutableSourceRunSnapshot
swift test --filter TargetGraphTests/testGH962ReadinessAssessmentDiffCompareIsLocalAndNonMutating
swift test --filter TargetGraphTests/testGH963ReadinessAssessmentCLILifecycleUsesLocalRegistryOnly
swift test --filter AppTests/testGH964DashboardAssessmentHistoryShowsLocalEvidenceAndAdversarialCoverageWithoutCommands
swift test --filter TargetGraphTests/testGH964DashboardAssessmentHistoryAndAdversarialCIGuardsAreAnchored
swift test --filter TargetGraphTests/testGH965ReleaseV0120FinalAuditDocsRunbookCloseCompletedFactsOnly

for anchor in \
  "GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "V0120-001-EVIDENCE-PROVENANCE-MODEL" \
  "V0120-001-MULTI-ASSESSMENT-HISTORY" \
  "V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES" \
  "V0120-001-NO-PRODUCTION-CUTOVER" \
  "GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS" \
  "TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS" \
  "V0120-002-V0110-PUBLICATION-FACT" \
  "V0120-002-V0111-PATCH-FACT" \
  "V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION" \
  "V0120-002-NO-PRODUCTION-CUTOVER" \
  "GH-954-VERIFY-V0120-READINESS-ASSESSMENT-REGISTRY-STORE" \
  "TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE" \
  "V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE" \
  "V0120-003-REGISTRY-JSON-PATH" \
  "V0120-003-ASSESSMENT-DIRECTORY-PATH" \
  "V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER" \
  "V0120-003-COMPARE-READY-METADATA" \
  "V0120-003-NO-PRODUCTION-CUTOVER" \
  "GH-955-VERIFY-V0120-ASSESSMENT-TRANSACTION-LOCK" \
  "TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK" \
  "V0120-004-ASSESSMENT-TRANSACTION-LOCK" \
  "V0120-004-TRANSACTION-ID-GENERATION-ID" \
  "V0120-004-STAGING-DIRECTORY-COMMIT-MARKER" \
  "V0120-004-COMPARE-AND-SWAP-MANIFEST" \
  "V0120-004-CRASH-RECOVERY-SEMANTICS" \
  "V0120-004-NO-PRODUCTION-CUTOVER" \
  "GH-956-VERIFY-V0120-READINESS-MANIFEST-V2" \
  "TVM-RELEASE-V0120-READINESS-MANIFEST-V2" \
  "V0120-005-READINESS-MANIFEST-V2" \
  "V0120-005-ASSESSMENT-GENERATION-PROVENANCE" \
  "V0120-005-SOURCE-RUN-COMMIT-PROVENANCE" \
  "V0120-005-CANONICAL-ARTIFACT-METADATA" \
  "V0120-005-PRODUCER-VERSION-SCHEMA" \
  "V0120-005-NO-PRODUCTION-CUTOVER" \
  "GH-957-VERIFY-V0120-ARTIFACT-CONTENT-POLICY-REDACTION" \
  "TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION" \
  "V0120-006-ARTIFACT-CONTENT-POLICY" \
  "V0120-006-JSON-SCHEMA-ALLOWLIST" \
  "V0120-006-FORBIDDEN-FIELD-REJECTION" \
  "V0120-006-RAW-SECRET-LISTENKEY-REJECTION" \
  "V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION" \
  "V0120-006-CONTENT-VALIDATION-CHECKSUM" \
  "V0120-006-NO-PRODUCTION-CUTOVER" \
  "GH-958-VERIFY-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT" \
  "TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT" \
  "V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT" \
  "V0120-007-READINESS-BUNDLE-V2-JSON" \
  "V0120-007-READINESS-BUNDLE-V2-MANIFEST-JSON" \
  "V0120-007-REVIEW-SNAPSHOT-IMMUTABLE" \
  "V0120-007-NEW-GENERATION-ON-CHANGE" \
  "V0120-007-BUNDLE-MANIFEST-CHECKSUM" \
  "V0120-007-NO-PRODUCTION-CUTOVER" \
  "GH-959-VERIFY-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS" \
  "TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS" \
  "V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS" \
  "V0120-008-OBSERVED-EXPIRES-REVIEWED-SOURCE-EVIDENCE" \
  "V0120-008-DERIVED-FRESHNESS-AND-REVIEW-STATE" \
  "V0120-008-STALE-UNREVIEWED-MISMATCH-FAIL-CLOSED" \
  "V0120-008-APPROVAL-REQUEST-ONLY-NO-CUTOVER" \
  "V0120-008-NO-PRODUCTION-CUTOVER" \
  "GH-960-VERIFY-V0120-APPROVAL-ROLE-QUORUM-SEPARATION" \
  "TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION" \
  "V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION" \
  "V0120-009-REQUESTER-REVIEWER-APPROVER-ROLE-POLICY" \
  "V0120-009-QUORUM-SEPARATION-OF-DUTIES" \
  "V0120-009-APPROVAL-EXPIRY-REVOCATION-FAIL-CLOSED" \
  "V0120-009-BUNDLE-CHECKSUM-BINDING" \
  "V0120-009-TRANSITION-CHECKSUM-CHAIN" \
  "V0120-009-NO-PRODUCTION-CUTOVER" \
  "GH-961-VERIFY-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT" \
  "TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT" \
  "V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT" \
  "V0120-010-SOURCE-RUN-MANIFEST-CHECKSUM" \
  "V0120-010-EVENT-ID-SET-BINDING" \
  "V0120-010-RISK-DECISION-ID-BINDING" \
  "V0120-010-OMS-DRY-RUN-LIFECYCLE-ID-BINDING" \
  "V0120-010-PORTFOLIO-PROJECTION-CHECKSUM-BINDING" \
  "V0120-010-RECONCILIATION-CHECKSUM-BINDING" \
  "V0120-010-NO-PRODUCTION-CUTOVER" \
  "GH-962-VERIFY-V0120-READINESS-ASSESSMENT-DIFF-COMPARE" \
  "TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE" \
  "V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE" \
  "V0120-011-POLICY-ARTIFACT-RISK-KILL-APPROVAL-SECTIONS" \
  "V0120-011-SOURCE-RUN-EVIDENCE-COMPARISON" \
  "V0120-011-NON-MUTATING-COMPARE" \
  "V0120-011-NO-PRODUCTION-CUTOVER" \
  "GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE" \
  "TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE" \
  "V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE" \
  "V0120-012-CREATE-BUILD-STATUS-VALIDATE-EXPORT-ARCHIVE" \
  "V0120-012-COMPARE-LOCAL-ASSESSMENTS" \
  "V0120-012-INVALID-ASSESSMENT-ID-FAIL-CLOSED" \
  "V0120-012-LOCAL-REGISTRY-STORE-ONLY" \
  "V0120-012-NO-PRODUCTION-CUTOVER" \
  "GH-964-VERIFY-V0120-DASHBOARD-ASSESSMENT-HISTORY" \
  "TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY" \
  "V0120-013-DASHBOARD-ASSESSMENT-HISTORY" \
  "V0120-013-ASSESSMENT-LIST-DETAIL-GENERATION-HISTORY" \
  "V0120-013-PROVENANCE-VALIDATION-APPROVAL-COMPARISON" \
  "V0120-013-ADVERSARIAL-CI-GUARD" \
  "V0120-013-NO-PRODUCTION-CUTOVER" \
  "GH-965-VERIFY-V0120-FINAL-AUDIT-DOCS-RUNBOOK" \
  "GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK" \
  "TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK" \
  "V0120-014-STAGE-CODE-AUDIT" \
  "V0120-014-RELEASE-NOTES" \
  "V0120-014-OPERATOR-RUNBOOK" \
  "V0120-014-ASSESSMENT-REGISTRY-SCHEMA" \
  "V0120-014-MANIFEST-V2-SCHEMA" \
  "V0120-014-PROVENANCE-CONTRACT" \
  "V0120-014-ADVERSARIAL-VALIDATION-SUMMARY" \
  "V0120-014-ROOT-DOCS-REFRESH" \
  "V0120-014-AGGREGATE-VERIFY" \
  "V0120-014-NO-PRODUCTION-CUTOVER" \
  "V0120-014-NO-TAG-OR-RELEASE-MOVE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  if [[ "$anchor" == GH-954-* || "$anchor" == GH-955-* || "$anchor" == GH-956-* || "$anchor" == GH-957-* || "$anchor" == GH-958-* || "$anchor" == GH-962-* || "$anchor" == TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE || "$anchor" == TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK || "$anchor" == TVM-RELEASE-V0120-READINESS-MANIFEST-V2 || "$anchor" == TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION || "$anchor" == TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT || "$anchor" == TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE || "$anchor" == V0120-003-* || "$anchor" == V0120-004-* || "$anchor" == V0120-005-* || "$anchor" == V0120-006-* || "$anchor" == V0120-007-* || "$anchor" == V0120-011-* ]]; then
    require_file_contains "$REGISTRY_SOURCE" "$anchor"
  fi
  if [[ "$anchor" == GH-959-* || "$anchor" == TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS || "$anchor" == V0120-008-* ]]; then
    require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "$anchor"
  fi
  if [[ "$anchor" == GH-960-* || "$anchor" == TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION || "$anchor" == V0120-009-* ]]; then
    require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "$anchor"
  fi
  if [[ "$anchor" == GH-961-* || "$anchor" == TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT || "$anchor" == V0120-010-* ]]; then
    require_file_contains "$SHADOW_PARITY_SOURCE" "$anchor"
  fi
  if [[ "$anchor" == GH-963-* || "$anchor" == TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE || "$anchor" == V0120-012-* ]]; then
    require_file_contains "$MTPRO_CLI_SOURCE" "$anchor"
  fi
  if [[ "$anchor" == GH-964-* || "$anchor" == TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY || "$anchor" == V0120-013-* ]]; then
    require_file_contains "$DASHBOARD_SOURCE" "$anchor"
    require_file_contains "$DASHBOARD_GUARD" "$anchor"
  fi
  if [[ "$anchor" == GH-965-* || "$anchor" == TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK || "$anchor" == V0120-014-* ]]; then
    require_file_contains "$AUDIT" "$anchor"
    require_file_contains "$RELEASE_NOTES" "$anchor"
    require_file_contains "$RUNBOOK" "$anchor"
  fi
done

require_file_contains "$AUDIT" "MTPRO Release v0.12.0 Readiness Assessment Sessions Stage Code Audit"
require_file_contains "$RELEASE_NOTES" "MTPRO Release v0.12.0 Readiness Assessment Sessions Notes"
require_file_contains "$RUNBOOK" "MTPRO Release v0.12.0 Readiness Assessment Sessions Operator Runbook"
require_file_contains "$AUDIT" "#952 through #964 were closed / done before #965 preflight"
require_file_contains "$AUDIT" 'PR #973 through PR #985 were merged with required `checks` SUCCESS'
require_file_contains "$RELEASE_NOTES" "This is a construction closeout note"
require_file_contains "$RUNBOOK" "This runbook tells an operator how to review v0.12.0 readiness assessment evidence locally"
require_file_contains "$README" "MTPRO Release v0.12.0 Readiness Assessment Sessions"
require_file_contains "$GOAL" "MTPRO Release v0.12.0 Readiness Assessment Sessions"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.12.0 Readiness Assessment Sessions"
require_file_contains "$ROADMAP" "Project Closure Count: 45 / 45 (100%)"
require_file_contains "$ROADMAP" 'Latest Completed Project：`MTPRO Release v0.12.0 Readiness Assessment Sessions`'
require_file_contains "$READINESS" "Release v0.12.0 final audit / docs / runbook anchor"
require_file_contains "$PLAN" "GH-965 Release v0.12.0 Final Audit / Docs / Runbook Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$LATEST" "Release v0.12.0 Final Audit / Docs / Runbook Snapshot"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.12.0.sh"

require_file_contains "$CONTRACT" "assessmentSessionAllowed=true"
require_file_contains "$CONTRACT" "assessmentSessionLocalOnly=true"
require_file_contains "$CONTRACT" "assessmentSessionRequiresExplicitInput=true"
require_file_contains "$CONTRACT" "assessmentSessionMayReadLocalReadinessArtifacts=true"
require_file_contains "$CONTRACT" "assessmentSessionMayBuildDerivedReadModels=true"
require_file_contains "$CONTRACT" "assessmentSessionMayRecordHistory=true"
require_file_contains "$CONTRACT" "assessmentSessionMayComparePreviousAssessments=true"
require_file_contains "$CONTRACT" "assessmentSessionMayExportRedactedEvidence=true"
require_file_contains "$CONTRACT" "source issue / PR / check evidence reference"
require_file_contains "$CONTRACT" "canonical checksum / content hash reference"
require_file_contains "$CONTRACT" "baseline assessment"
require_file_contains "$CONTRACT" "follow-up assessment"
require_file_contains "$CONTRACT" "superseded assessment"
require_file_contains "$CONTRACT" "blocked assessment"
require_file_contains "$CONTRACT" "invalid assessment"
require_file_contains "$CONTRACT" "Production cutover 仍是独立 human-approved gate"
require_file_contains "$CONTRACT" "v0.11.0 public GitHub Release 已通过独立 Release Publication Gate 完成"
require_file_contains "$CONTRACT" "https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0"
require_file_contains "$CONTRACT" "13f592d0710de91351286e5c5490bfacb63c19b0"
require_file_contains "$CONTRACT" "2026-06-19T01:20:58Z"
require_file_contains "$CONTRACT" "v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public GitHub Release 之后的 guard hardening closeout"
require_file_contains "$CONTRACT" "v0.11.1 patch closeout 不创建"
require_file_contains "$CONTRACT" "construction closeout、public release publication、release fact sync / stale wording guard、v0.11.1 patch closeout 和 production cutover 必须继续保持独立 gate"
require_file_contains "$CONTRACT" "GH-952 V0120-001 Define v0.12.0 readiness assessment session no-authorization contract"
require_file_contains "$CONTRACT" "GH-965 V0120-014 Close v0.12.0 final audit docs and runbook"
require_file_contains "$READINESS" "Release v0.12.0 readiness assessment session no-authorization contract anchor"
require_file_contains "$READINESS" "Release v0.12.0 v0.11.x publication / patch fact baseline anchor"
require_file_contains "$PLAN" "GH-952 Release v0.12.0 Readiness Assessment Session No-authorization Contract Validation"
require_file_contains "$PLAN" "GH-953 Release v0.12.0 v0.11.x Publication / Patch Fact Baseline Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS"
require_file_contains "$LATEST" "Release v0.12.0 Readiness Assessment Session Contract Snapshot"
require_file_contains "$LATEST" "Release v0.12.0 v0.11.x Publication / Patch Fact Baseline Snapshot"
require_file_contains "$READINESS" "Release v0.12.0 readiness assessment registry store anchor"
require_file_contains "$PLAN" "GH-954 Release v0.12.0 Readiness Assessment Registry Store Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE"
require_file_contains "$LATEST" "Release v0.12.0 Readiness Assessment Registry Store Snapshot"
require_file_contains "$CONTRACT" ".local/mtpro/readiness/registry.json"
require_file_contains "$CONTRACT" ".local/mtpro/readiness/assessments/<assessmentID>/"
require_file_contains "$CONTRACT" "create / list / inspect / archive / recover"
require_file_contains "$CONTRACT" "compare-ready"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentRegistryStore"
require_file_contains "$REGISTRY_SOURCE" ".local/mtpro/readiness/registry.json"
require_file_contains "$REGISTRY_SOURCE" ".local/mtpro/readiness/assessments"
require_file_contains "$REGISTRY_SOURCE" "compareReadyAssessments"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentComparisonSnapshot"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentComparisonReport"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentComparisonDelta"
require_file_contains "$REGISTRY_SOURCE" "compareAssessments"
require_file_contains "$REGISTRY_SOURCE" "policyChecksum"
require_file_contains "$REGISTRY_SOURCE" "artifactBundleChecksum"
require_file_contains "$REGISTRY_SOURCE" "riskLimitChecksum"
require_file_contains "$REGISTRY_SOURCE" "killSwitchStateChecksum"
require_file_contains "$REGISTRY_SOURCE" "approvalStateChecksum"
require_file_contains "$REGISTRY_SOURCE" "sourceRunSnapshot"
require_file_contains "$REGISTRY_SOURCE" "compareDoesNotMutateAssessments"
require_file_contains "$REGISTRY_SOURCE" "operatorReviewOnly"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentTransactionControl"
require_file_contains "$REGISTRY_SOURCE" "createWithTransaction"
require_file_contains "$REGISTRY_SOURCE" "stageAssessmentTransaction"
require_file_contains "$REGISTRY_SOURCE" "abortAssessmentTransaction"
require_file_contains "$REGISTRY_SOURCE" "recoverInterruptedTransactions"
require_file_contains "$REGISTRY_SOURCE" "compare-and-swap-manifest.json"
require_file_contains "$REGISTRY_SOURCE" "commit-marker.json"
require_file_contains "$REGISTRY_SOURCE" ".local/mtpro/readiness/staging"
require_file_contains "$REGISTRY_SOURCE" "concurrentModification"
require_file_contains "$REGISTRY_SOURCE" "generationMismatch"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentManifestV2"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentManifestV2ArtifactContentType"
require_file_contains "$REGISTRY_SOURCE" "v0.12.0.readiness-assessment-manifest.v2"
require_file_contains "$REGISTRY_SOURCE" "canonical-json-sha256"
require_file_contains "$REGISTRY_SOURCE" "manifest-v2.json"
require_file_contains "$REGISTRY_SOURCE" "writeManifestV2"
require_file_contains "$REGISTRY_SOURCE" "readManifestV2"
require_file_contains "$REGISTRY_SOURCE" "sourceRunIDs"
require_file_contains "$REGISTRY_SOURCE" "sourceCommit"
require_file_contains "$REGISTRY_SOURCE" "artifactContentType"
require_file_contains "$REGISTRY_SOURCE" "artifactSHA256"
require_file_contains "$REGISTRY_SOURCE" "artifactBytes"
require_file_contains "$REGISTRY_SOURCE" "producerVersion"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentArtifactContentPolicy"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentArtifactContentValidationResult"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentArtifactContentValidationState"
require_file_contains "$REGISTRY_SOURCE" "v0.12.0.artifact-content-policy.v1"
require_file_contains "$REGISTRY_SOURCE" "allowedJSONFields"
require_file_contains "$REGISTRY_SOURCE" "requiredJSONFields"
require_file_contains "$REGISTRY_SOURCE" "forbiddenJSONFields"
require_file_contains "$REGISTRY_SOURCE" "forbiddenRawMarkers"
require_file_contains "$REGISTRY_SOURCE" "validateArtifactContent"
require_file_contains "$REGISTRY_SOURCE" "contentValidationChecksum"
require_file_contains "$REGISTRY_SOURCE" "raw-secret"
require_file_contains "$REGISTRY_SOURCE" "raw-listen-key"
require_file_contains "$REGISTRY_SOURCE" "/api/v3/order"
require_file_contains "$REGISTRY_SOURCE" "api.binance.com"
require_file_contains "$REGISTRY_SOURCE" "artifactContentPolicy:rejectedContent"
require_file_contains "$REGISTRY_SOURCE" "productionCutoverAuthorized == false"
require_file_contains "$CONTRACT" "V0120-006-ARTIFACT-CONTENT-POLICY"
require_file_contains "$CONTRACT" "allowedJSONFields"
require_file_contains "$CONTRACT" "forbiddenJSONFields"
require_file_contains "$CONTRACT" "forbiddenRawMarkers"
require_file_contains "$CONTRACT" "raw secret"
require_file_contains "$CONTRACT" "raw listenKey"
require_file_contains "$READINESS" "Release v0.12.0 artifact content-policy / redaction validator anchor"
require_file_contains "$PLAN" "GH-957 Release v0.12.0 Artifact Content-policy / Redaction Validator Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION"
require_file_contains "$LATEST" "Release v0.12.0 Artifact Content-policy / Redaction Validator Snapshot"
require_file_contains "$TESTS" "testGH957ArtifactContentPolicyRejectsSecretsListenKeysOrdersAndEndpointResponses"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentBundleV2"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentBundleV2Manifest"
require_file_contains "$REGISTRY_SOURCE" "ReadinessAssessmentBundleV2ArtifactSnapshot"
require_file_contains "$REGISTRY_SOURCE" "writeReadinessBundleV2ReviewSnapshot"
require_file_contains "$REGISTRY_SOURCE" "readiness-bundle-v2.json"
require_file_contains "$REGISTRY_SOURCE" "readiness-bundle-v2.manifest.json"
require_file_contains "$REGISTRY_SOURCE" "readinessBundleV2:generationImmutable"
require_file_contains "$REGISTRY_SOURCE" "changeRequiresNewGeneration"
require_file_contains "$CONTRACT" "V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT"
require_file_contains "$CONTRACT" "readiness-bundle-v2.json"
require_file_contains "$CONTRACT" "readiness-bundle-v2.manifest.json"
require_file_contains "$CONTRACT" "同一 generation"
require_file_contains "$READINESS" "Release v0.12.0 immutable readiness bundle snapshot anchor"
require_file_contains "$PLAN" "GH-958 Release v0.12.0 Immutable Readiness Bundle Snapshot Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT"
require_file_contains "$LATEST" "Release v0.12.0 Immutable Readiness Bundle Snapshot"
require_file_contains "$TESTS" "testGH958ImmutableReadinessBundleSnapshotRequiresNewGenerationOnChange"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "ReleaseV0120KillSwitchNoTradeTrustworthyObservationAnchors"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "observedAt"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "expiresAt"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "reviewedAt"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "reviewedBy"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "sourceArtifact"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "sourceChecksum"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "sourceRunID"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "expectedSourceArtifact"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "expectedSourceChecksum"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "expectedSourceRunID"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "deriveFreshnessState"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "deriveReviewState"
require_file_contains "$CONTRACT" "V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS"
require_file_contains "$CONTRACT" "observedAt"
require_file_contains "$CONTRACT" "sourceChecksum"
require_file_contains "$READINESS" "Release v0.12.0 kill switch / no-trade trustworthy observations anchor"
require_file_contains "$PLAN" "GH-959 Release v0.12.0 Kill Switch / No-trade Trustworthy Observations Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS"
require_file_contains "$LATEST" "Release v0.12.0 Kill Switch / No-trade Trustworthy Observations Snapshot"
require_file_contains "$TESTS" "testGH959KillSwitchNoTradeTrustworthyObservationsFailClosed"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "ReleaseV0120ApprovalRoleQuorumSeparationAnchors"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "ReleaseV0120ApprovalWorkflowRolePolicy"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "ReleaseV0120ApprovalWorkflowQuorumPolicy"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "rolePolicySatisfied"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "reviewerQuorumSatisfied"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "approverQuorumSatisfied"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "bundleChecksumBindingHeld"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "transitionChecksumChainHeld"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "boundBundleChecksum"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "expectedBundleChecksum"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "transitionChecksumChain"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "stableTransitionChecksum"
require_file_contains "$CONTRACT" "V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION"
require_file_contains "$CONTRACT" "boundBundleChecksum"
require_file_contains "$CONTRACT" "transitionChecksumChain"
require_file_contains "$READINESS" "Release v0.12.0 approval role / quorum separation anchor"
require_file_contains "$PLAN" "GH-960 Release v0.12.0 Approval Role / Quorum Separation Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION"
require_file_contains "$LATEST" "Release v0.12.0 Approval Role / Quorum Separation Snapshot"
require_file_contains "$TESTS" "testGH960ApprovalRolesQuorumAndBundleBindingFailClosed"
require_file_contains "$SHADOW_PARITY_SOURCE" "ReleaseV0120ShadowParitySourceSnapshotAnchors"
require_file_contains "$SHADOW_PARITY_SOURCE" "ReleaseV0120ShadowParitySourceRunSnapshot"
require_file_contains "$SHADOW_PARITY_SOURCE" "sourceRunManifestChecksum"
require_file_contains "$SHADOW_PARITY_SOURCE" "eventIDs"
require_file_contains "$SHADOW_PARITY_SOURCE" "riskDecisionIDs"
require_file_contains "$SHADOW_PARITY_SOURCE" "omsDryRunLifecycleIDs"
require_file_contains "$SHADOW_PARITY_SOURCE" "portfolioProjectionChecksum"
require_file_contains "$SHADOW_PARITY_SOURCE" "reconciliationChecksum"
require_file_contains "$SHADOW_PARITY_SOURCE" "sourceSnapshotBindingHeld"
require_file_contains "$SHADOW_PARITY_SOURCE" "sourceSnapshotMismatch"
require_file_contains "$CONTRACT" "V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT"
require_file_contains "$CONTRACT" "sourceRunManifestChecksum"
require_file_contains "$CONTRACT" "sourceSnapshotBindingHeld"
require_file_contains "$READINESS" "Release v0.12.0 shadow parity source snapshot anchor"
require_file_contains "$PLAN" "GH-961 Release v0.12.0 Shadow Parity Source Snapshot Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT"
require_file_contains "$LATEST" "Release v0.12.0 Shadow Parity Source Snapshot"
require_file_contains "$TESTS" "testGH961ShadowParityBindsImmutableSourceRunSnapshot"
require_file_contains "$RELEASE_POLICY" "V0120-002-V011X-RELEASE-PATCH-FACT-BASELINE"
require_file_contains "$RELEASE_POLICY" "v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public Release 后的 guard hardening closeout"
require_file_contains "$README" "v0.11.1 patch closeout 不创建"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.12.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.12.0.sh"
require_file_contains "$TESTS" "testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract"
require_file_contains "$TESTS" "testGH953ReleaseV0120CarriesForwardV011XPublicationAndPatchFacts"
require_file_contains "$TESTS" "testGH954ReadinessAssessmentRegistryStorePersistsLifecycleAndCompareReadyMetadata"
require_file_contains "$TESTS" "testGH955AssessmentTransactionLockControlsGenerationAndCrashRecovery"
require_file_contains "$TESTS" "testGH956ReadinessManifestV2RecordsAssessmentGenerationAndProvenance"
require_file_contains "$MTPRO_CLI_SOURCE" "ReleaseV0120ReadinessAssessmentCLI"
require_file_contains "$MTPRO_CLI_SOURCE" "readinessAssessmentActions"
require_file_contains "$MTPRO_CLI_SOURCE" "MTPRO_READINESS_ROOT"
require_file_contains "$MTPRO_CLI_SOURCE" "ReadinessAssessmentRegistryStore"
require_file_contains "$MTPRO_CLI_SOURCE" "writeManifestV2"
require_file_contains "$MTPRO_CLI_SOURCE" "writeReadinessBundleV2ReviewSnapshot"
require_file_contains "$MTPRO_CLI_SOURCE" "compareAssessments"
require_file_contains "$MTPRO_CLI_SOURCE" "invalidAssessmentIDsFailClosed=true"
require_file_contains "$CONTRACT" "mtpro readiness create"
require_file_contains "$CONTRACT" "mtpro readiness compare"
require_file_contains "$READINESS" "Release v0.12.0 assessment-scoped CLI lifecycle anchor"
require_file_contains "$PLAN" "GH-963 Release v0.12.0 Assessment-scoped CLI Lifecycle Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE"
require_file_contains "$LATEST" "Release v0.12.0 Assessment-scoped CLI Lifecycle"
require_file_contains "$TESTS" "testGH963ReadinessAssessmentCLILifecycleUsesLocalRegistryOnly"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0120DashboardAssessmentHistorySurfaceViewModel"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0120DashboardAssessmentHistorySurfaceKind"
require_file_contains "$DASHBOARD_SOURCE" "ReleaseV0120DashboardAssessmentHistoryRow"
require_file_contains "$DASHBOARD_SOURCE" "assessment-list"
require_file_contains "$DASHBOARD_SOURCE" "assessment-detail"
require_file_contains "$DASHBOARD_SOURCE" "generation-history"
require_file_contains "$DASHBOARD_SOURCE" "provenance"
require_file_contains "$DASHBOARD_SOURCE" "validation-status"
require_file_contains "$DASHBOARD_SOURCE" "approval-status"
require_file_contains "$DASHBOARD_SOURCE" "comparison"
require_file_contains "$DASHBOARD_SOURCE" "symlink-attack"
require_file_contains "$DASHBOARD_SOURCE" "concurrent-build"
require_file_contains "$DASHBOARD_SOURCE" "crash-recovery"
require_file_contains "$DASHBOARD_SOURCE" "checksum-toctou"
require_file_contains "$DASHBOARD_SOURCE" "file-permissions"
require_file_contains "$DASHBOARD_SOURCE" "tamper-after-validation"
require_file_contains "$DASHBOARD_SOURCE" "macos-dashboard-focused-guard"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "releaseV0120AssessmentHistorySurface"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "DashboardReleaseV0120AssessmentHistoryPanel"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "releaseV0120AssessmentHistoryRows"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "releaseV0120AssessmentHistoryGenerations"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "releaseV0120AssessmentHistoryAdversarialCases"
require_file_contains "$DASHBOARD_SHELL_SOURCE" "releaseV0120AssessmentHistoryBoundary"
require_file_contains "$DASHBOARD_GUARD" "bash checks/verify-v0.12.0.sh"
require_file_contains "$DASHBOARD_GUARD" "DASHBOARD_SMOKE=1 swift run Dashboard"
require_file_contains "$DASHBOARD_GUARD" "releaseV0120AssessmentHistoryRows=7"
require_file_contains "$DASHBOARD_GUARD" "releaseV0120AssessmentHistoryGenerations=3"
require_file_contains "$DASHBOARD_GUARD" "releaseV0120AssessmentHistoryAdversarialCases=7"
require_file_contains "$DASHBOARD_GUARD" "releaseV0120AssessmentHistoryBoundary=confirmed"
require_file_contains "$WORKFLOW" "Verify v0.12.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.12.0-dashboard-macos-guards.sh"
require_file_contains "$APP_TESTS" "testGH964DashboardAssessmentHistoryShowsLocalEvidenceAndAdversarialCoverageWithoutCommands"
require_file_contains "$TESTS" "testGH964DashboardAssessmentHistoryAndAdversarialCIGuardsAreAnchored"
require_file_contains "$CONTRACT" "V0120-013-DASHBOARD-ASSESSMENT-HISTORY"
require_file_contains "$CONTRACT" "assessment list / detail / generation history"
require_file_contains "$CONTRACT" "adversarial CI guard"
require_file_contains "$READINESS" "Release v0.12.0 Dashboard assessment history / adversarial CI anchor"
require_file_contains "$PLAN" "GH-964 Release v0.12.0 Dashboard Assessment History / Adversarial CI Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY"
require_file_contains "$LATEST" "Release v0.12.0 Dashboard Assessment History / Adversarial CI"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.12.0-dashboard-macos-guards.sh"

READINESS_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-gh963-readiness.XXXXXX")"
trap 'rm -rf "$READINESS_ROOT"' EXIT
ASSESSMENT_A="gh-963-cli-a-$$"
ASSESSMENT_B="gh-963-cli-b-$$"

require_cli_output_contains() {
  local action="$1"
  local output="$2"
  local expected="$3"

  if ! grep -Fq "$expected" <<<"$output"; then
    printf 'release v0.12.0 assessment-scoped CLI lifecycle verification failed: %s output must contain: %s\n' "$action" "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

run_readiness_cli() {
  MTPRO_READINESS_ROOT="$READINESS_ROOT" swift run mtpro readiness "$@"
}

# GH-963 command coverage:
# swift run mtpro readiness create <assessmentID>
# swift run mtpro readiness build <assessmentID>
# swift run mtpro readiness status <assessmentID>
# swift run mtpro readiness validate <assessmentID>
# swift run mtpro readiness export <assessmentID>
# swift run mtpro readiness archive <assessmentID>
# swift run mtpro readiness compare <baselineAssessmentID> <followUpAssessmentID>
assert_common_cli_boundary() {
  local action="$1"
  local output="$2"

  for expected in \
    "issue=GH-963" \
    "validationAnchor=TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE" \
    "verificationAnchor=GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE" \
    "assessmentSessionContract=v0.12.0" \
    "invalidAssessmentIDsFailClosed=true" \
    "productionTradingEnabledByDefault=false" \
    "productionSecretRead=false" \
    "productionEndpointConnected=false" \
    "brokerEndpointConnected=false" \
    "productionOrderSubmitted=false" \
    "testnetOrderSubmissionAllowed=false" \
    "testnetOrderRoutingAllowed=false" \
    "productionCutoverAuthorized=false" \
    "localRegistryStoreOnly=true" \
    "boundaryHeld=true"; do
    require_cli_output_contains "$action" "$output" "$expected"
  done
}

CREATE_A_OUTPUT="$(run_readiness_cli create "$ASSESSMENT_A")"
assert_common_cli_boundary "create" "$CREATE_A_OUTPUT"
require_cli_output_contains "create" "$CREATE_A_OUTPUT" "assessmentID=$ASSESSMENT_A"
require_cli_output_contains "create" "$CREATE_A_OUTPUT" "created=true"

BUILD_A_OUTPUT="$(run_readiness_cli build "$ASSESSMENT_A")"
assert_common_cli_boundary "build" "$BUILD_A_OUTPUT"
require_cli_output_contains "build" "$BUILD_A_OUTPUT" "artifactWritten=true"
require_cli_output_contains "build" "$BUILD_A_OUTPUT" "readinessBundleWritten=true"

STATUS_A_OUTPUT="$(run_readiness_cli status "$ASSESSMENT_A")"
assert_common_cli_boundary "status" "$STATUS_A_OUTPUT"
require_cli_output_contains "status" "$STATUS_A_OUTPUT" "manifestV2Present=true"

VALIDATE_A_OUTPUT="$(run_readiness_cli validate "$ASSESSMENT_A")"
assert_common_cli_boundary "validate" "$VALIDATE_A_OUTPUT"
require_cli_output_contains "validate" "$VALIDATE_A_OUTPUT" "validationState=valid"

EXPORT_A_OUTPUT="$(run_readiness_cli export "$ASSESSMENT_A")"
assert_common_cli_boundary "export" "$EXPORT_A_OUTPUT"
require_cli_output_contains "export" "$EXPORT_A_OUTPUT" "exportSnapshotOnly=true"
require_cli_output_contains "export" "$EXPORT_A_OUTPUT" "redactedEvidenceOnly=true"

CREATE_B_OUTPUT="$(run_readiness_cli create "$ASSESSMENT_B")"
assert_common_cli_boundary "create" "$CREATE_B_OUTPUT"
BUILD_B_OUTPUT="$(run_readiness_cli build "$ASSESSMENT_B")"
assert_common_cli_boundary "build" "$BUILD_B_OUTPUT"

COMPARE_OUTPUT="$(run_readiness_cli compare "$ASSESSMENT_A" "$ASSESSMENT_B")"
assert_common_cli_boundary "compare" "$COMPARE_OUTPUT"
require_cli_output_contains "compare" "$COMPARE_OUTPUT" "baselineAssessmentID=$ASSESSMENT_A"
require_cli_output_contains "compare" "$COMPARE_OUTPUT" "followUpAssessmentID=$ASSESSMENT_B"
require_cli_output_contains "compare" "$COMPARE_OUTPUT" "compareDoesNotMutateAssessments=true"
require_cli_output_contains "compare" "$COMPARE_OUTPUT" "operatorReviewOnly=true"

ARCHIVE_B_OUTPUT="$(run_readiness_cli archive "$ASSESSMENT_B")"
assert_common_cli_boundary "archive" "$ARCHIVE_B_OUTPUT"
require_cli_output_contains "archive" "$ARCHIVE_B_OUTPUT" "archived=true"

if MTPRO_READINESS_ROOT="$READINESS_ROOT" swift run mtpro readiness status "../bad" >/tmp/mtpro-gh963-invalid-status.out 2>&1; then
  printf 'release v0.12.0 assessment-scoped CLI lifecycle verification failed: invalid status assessmentID must fail closed\n' >&2
  exit 1
fi
require_file_contains "/tmp/mtpro-gh963-invalid-status.out" "mtpro.readiness.arguments"

if MTPRO_READINESS_ROOT="$READINESS_ROOT" swift run mtpro readiness compare "$ASSESSMENT_A" "./bad" >/tmp/mtpro-gh963-invalid-compare.out 2>&1; then
  printf 'release v0.12.0 assessment-scoped CLI lifecycle verification failed: invalid compare assessmentID must fail closed\n' >&2
  exit 1
fi
require_file_contains "/tmp/mtpro-gh963-invalid-compare.out" "mtpro.readiness.arguments"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "realOrderSubmissionEnabled=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "productionOMSImplemented=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$PLAN" "$forbidden"
  reject_file_contains "$MATRIX" "$forbidden"
done

echo "MTPRO release v0.12.0 readiness assessment session contract verification passed."
