#!/usr/bin/env bash
set -euo pipefail

# GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
# TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
# GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
# TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
# GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO
# TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO
# GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM
# TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM
# GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION
# TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION
# GH-918-VERIFY-V0110-SHADOW-DRY-RUN-PARITY-RUNNER
# TVM-RELEASE-V0110-SHADOW-DRY-RUN-PARITY-RUNNER
# GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE
# TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE
# GH-920-VERIFY-V0110-READINESS-CLI-LOCAL-ARTIFACTS
# TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS
# GH-921-VERIFY-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY
# TVM-RELEASE-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY
# GH-922-VERIFY-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL
# TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL
# GH-923-VERIFY-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS
# TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS
# GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0110-FINAL-AUDIT-RELEASE-DOCS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.11.0 contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.11.0 contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
ARTIFACT_STORE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift"
DASHBOARD_READINESS_SOURCE="Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift"
MTPRO_CLI_SOURCE="Sources/MTPROCLI/main.swift"
CAPITAL_EXPOSURE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100CapitalExposureLimitReadinessGate.swift"
KILL_SWITCH_NO_TRADE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100KillSwitchNoTradeReadinessGate.swift"
APPROVAL_WORKFLOW_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110AuditableApprovalWorkflow.swift"
PACKAGE_SOURCE="Package.swift"
AUDIT="docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md"
RELEASE_NOTES="docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md"
README_DOC="README.md"
GOAL_DOC="GOAL.md"
BLUEPRINT_DOC="BLUEPRINT.md"
ROADMAP_DOC="docs/roadmap.md"

for anchor in \
  "GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT" \
  "TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT" \
  "V0110-001-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT" \
  "V0110-001-LOCAL-READINESS-ARTIFACT-RUNTIME" \
  "V0110-001-READINESS-ARTIFACT-LIFECYCLE" \
  "V0110-001-RUNTIME-STATES" \
  "V0110-001-MANIFEST-CHECKSUM-RULES" \
  "V0110-001-ALLOWED-LOCAL-COMMANDS" \
  "V0110-001-FORBIDDEN-PRODUCTION-CAPABILITIES" \
  "V0110-001-DASHBOARD-CLI-POLICY-KILL-SWITCH-APPROVAL-SHADOW-PARITY-BOUNDARIES" \
  "V0110-001-DOWNSTREAM-QUEUE-ORDER" \
  "V0110-001-RELEASE-VALIDATION-MATRIX"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$CONTRACT" "release version 固定为 \`v0.11.0\`"
require_file_contains "$CONTRACT" "GH-913..GH-924"
require_file_contains "$CONTRACT" "readinessArtifactRuntimeAllowed=true"
require_file_contains "$CONTRACT" "productionReadinessArtifactStoreAllowed=true"
require_file_contains "$CONTRACT" "localArtifactStoreAllowed=true"
require_file_contains "$CONTRACT" "manifestValidationAllowed=true"
require_file_contains "$CONTRACT" "canonicalJSONSHA256Allowed=true"
require_file_contains "$CONTRACT" "dashboardReadModelBindingAllowed=true"
require_file_contains "$CONTRACT" "readinessCLIAllowed=true"
require_file_contains "$CONTRACT" "approvalWorkflowEvidenceAllowed=true"
require_file_contains "$CONTRACT" "shadowDryRunParityEvidenceAllowed=true"
require_file_contains "$CONTRACT" "manifest 必须在所有 artifact 写入和 checksum 计算后最后写入"
require_file_contains "$CONTRACT" "mtpro readiness build"
require_file_contains "$CONTRACT" "mtpro readiness status"
require_file_contains "$CONTRACT" "mtpro readiness validate"
require_file_contains "$CONTRACT" "mtpro readiness export"
require_file_contains "$CONTRACT" "mtpro readiness approval-status"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "$CONTRACT" "productionSecretRead=false"
require_file_contains "$CONTRACT" "productionEndpointConnected=false"
require_file_contains "$CONTRACT" "brokerEndpointConnected=false"
require_file_contains "$CONTRACT" "productionBrokerConnected=false"
require_file_contains "$CONTRACT" "productionOrderSubmitted=false"
require_file_contains "$CONTRACT" "realOrderSubmissionEnabled=false"
require_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=false"
require_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=false"
require_file_contains "$CONTRACT" "productionOMSImplemented=false"
require_file_contains "$CONTRACT" "tradingButtonEnabled=false"
require_file_contains "$CONTRACT" "orderFormEnabled=false"
require_file_contains "$CONTRACT" "liveCommandEnabled=false"

require_file_contains "$READINESS" "Release v0.11.0 production readiness evidence runtime contract anchor"
require_file_contains "$PLAN" "GH-913 Release v0.11.0 Production Readiness Evidence Runtime Contract Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT"
require_file_contains "$LATEST" "Release v0.11.0 Production Readiness Evidence Runtime Contract Snapshot"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.11.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.11.0.sh"
require_file_contains "$TESTS" "testGH913ReleaseV0110ProductionReadinessEvidenceRuntimeContract"

for anchor in \
  "GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE" \
  "TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE" \
  "V0110-002-PRODUCTION-READINESS-ARTIFACT-STORE" \
  "V0110-002-LOCAL-EVIDENCE-ROOT" \
  "V0110-002-ARTIFACT-STATES" \
  "V0110-002-READ-WRITE-PRIMITIVES" \
  "V0110-002-NO-PRODUCTION-SECRET-ENDPOINT-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessArtifactStore"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public enum ProductionReadinessArtifactState"
require_file_contains "$ARTIFACT_STORE_SOURCE" "case missing"
require_file_contains "$ARTIFACT_STORE_SOURCE" "case invalid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "case stale"
require_file_contains "$ARTIFACT_STORE_SOURCE" "case valid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "defaultRelativeRoot = \".local/mtpro/readiness/v0.11.0\""
require_file_contains "$ARTIFACT_STORE_SOURCE" "public static func isSafeRelativePath"
require_file_contains "$ARTIFACT_STORE_SOURCE" "writeArtifact("
require_file_contains "$ARTIFACT_STORE_SOURCE" "readArtifact("
require_file_contains "$ARTIFACT_STORE_SOURCE" "inspectArtifact("
require_file_contains "$ARTIFACT_STORE_SOURCE" "inspectArtifacts("
require_file_contains "$ARTIFACT_STORE_SOURCE" "productionTradingEnabledByDefault == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "productionSecretRead == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "productionEndpointConnected == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "brokerEndpointConnected == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "productionOrderSubmitted == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "testnetOrderSubmissionAllowed == false"
require_file_contains "$ARTIFACT_STORE_SOURCE" "productionCutoverAuthorized == false"
require_file_contains "$READINESS" "Release v0.11.0 production readiness artifact store anchor"
require_file_contains "$PLAN" "GH-914 Release v0.11.0 Production Readiness Artifact Store Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE"
require_file_contains "$LATEST" "Release v0.11.0 Production Readiness Artifact Store Snapshot"
require_file_contains "$TESTS" "testGH914ProductionReadinessArtifactStoreUsesLocalExplicitStates"

for anchor in \
  "GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO" \
  "TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO" \
  "V0110-003-READINESS-MANIFEST-SCHEMA" \
  "V0110-003-ATOMIC-JSON-ARTIFACT-IO" \
  "V0110-003-MANIFEST-POLICY-VERSION" \
  "V0110-003-MANIFEST-ENTRY-STATE-VALIDATION" \
  "V0110-003-EVIDENCE-EXISTS-IS-NOT-SUFFICIENT"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessManifestEntry"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessManifest"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessManifestReadResult"
require_file_contains "$ARTIFACT_STORE_SOURCE" "writeReadinessManifest("
require_file_contains "$ARTIFACT_STORE_SOURCE" "readReadinessManifest("
require_file_contains "$ARTIFACT_STORE_SOURCE" "validateReadinessManifest("
require_file_contains "$ARTIFACT_STORE_SOURCE" "canonicalJSONSHA256Checksum(for data: Data)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "manifestPolicyMismatch"
require_file_contains "$ARTIFACT_STORE_SOURCE" "manifestEntryRejected"
require_file_contains "$ARTIFACT_STORE_SOURCE" "checksumMismatch"
require_file_contains "$ARTIFACT_STORE_SOURCE" "evidenceExists"
require_file_contains "$ARTIFACT_STORE_SOURCE" "atomicWriteRequired"
require_file_contains "$ARTIFACT_STORE_SOURCE" "entry.policyVersion == requiredPolicyVersion"
require_file_contains "$ARTIFACT_STORE_SOURCE" "record.state == .valid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "data.count == entry.size"
require_file_contains "$ARTIFACT_STORE_SOURCE" "try Self.canonicalJSONSHA256Checksum(for: data) == entry.checksum"
require_file_contains "$READINESS" "Release v0.11.0 readiness manifest atomic IO anchor"
require_file_contains "$PLAN" "GH-915 Release v0.11.0 Readiness Manifest Atomic IO Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO"
require_file_contains "$LATEST" "Release v0.11.0 Readiness Manifest Atomic IO Snapshot"
require_file_contains "$TESTS" "testGH915ReadinessManifestSchemaAndAtomicIORequireRealArtifacts"

for anchor in \
  "GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM" \
  "TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM" \
  "V0110-004-CANONICAL-JSON-SHA256" \
  "V0110-004-CHECKSUM-FORMAT-VALIDATION" \
  "V0110-004-CHECKSUM-MISMATCH-FAILS-CLOSED" \
  "V0110-004-NO-PLACEHOLDER-CHECKSUMS"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "Package.swift" ".product(name: \"Crypto\", package: \"swift-crypto\")"
require_file_contains "$ARTIFACT_STORE_SOURCE" "import Crypto"
require_file_contains "$ARTIFACT_STORE_SOURCE" "SHA256.hash"
require_file_contains "$ARTIFACT_STORE_SOURCE" "canonicalJSONData(for data: Data)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "isValidSHA256Checksum"
require_file_contains "$ARTIFACT_STORE_SOURCE" "invalidChecksumFormat"
require_file_contains "$ARTIFACT_STORE_SOURCE" "sha256:<64 hex>"
require_file_contains "$ARTIFACT_STORE_SOURCE" "Self.isValidSHA256Checksum(entry.checksum)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "try Self.canonicalJSONSHA256Checksum(for: data) == entry.checksum"
require_file_contains "$READINESS" "Release v0.11.0 canonical JSON SHA256 checksum anchor"
require_file_contains "$PLAN" "GH-916 Release v0.11.0 Canonical JSON SHA256 Checksum Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM"
require_file_contains "$LATEST" "Release v0.11.0 Canonical JSON SHA256 Checksum Snapshot"
require_file_contains "$TESTS" "testGH916CanonicalJSONSHA256RejectsPlaceholderAndMismatchChecksums"
require_file_contains "$TESTS" "sha256:gh890-secret-readiness"
require_file_contains "$TESTS" "checksumMismatch"

for anchor in \
  "GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION" \
  "TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION" \
  "V0110-005-READINESS-BUNDLE-VALIDATION" \
  "V0110-005-REQUIRED-ARTIFACT-SET" \
  "V0110-005-BUNDLE-VALIDATION-STATES" \
  "V0110-005-POLICY-VERSION-BLOCKED" \
  "V0110-005-CHECKSUM-MISMATCH-STATE" \
  "V0110-005-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$ARTIFACT_STORE_SOURCE" "public enum ProductionReadinessBundleValidationState"
require_file_contains "$ARTIFACT_STORE_SOURCE" "case notEvaluated = \"not-evaluated\""
require_file_contains "$ARTIFACT_STORE_SOURCE" "case checksumMismatch = \"checksum-mismatch\""
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessBundleValidationResult"
require_file_contains "$ARTIFACT_STORE_SOURCE" "notEvaluatedReadinessBundleValidation("
require_file_contains "$ARTIFACT_STORE_SOURCE" "validateReadinessBundle("
require_file_contains "$ARTIFACT_STORE_SOURCE" "requiredArtifactIDs"
require_file_contains "$ARTIFACT_STORE_SOURCE" "missingRequiredArtifactIDs"
require_file_contains "$ARTIFACT_STORE_SOURCE" "unexpectedArtifactIDs"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .blocked"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .stale"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .missing"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .invalid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .checksumMismatch"
require_file_contains "$ARTIFACT_STORE_SOURCE" "state: .valid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "Self.timestampsMatch(entry.createdAt, record.modifiedAt)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "try Self.canonicalJSONSHA256Checksum(for: data) == entry.checksum"
require_file_contains "$READINESS" "Release v0.11.0 readiness bundle validation anchor"
require_file_contains "$PLAN" "GH-917 Release v0.11.0 Readiness Bundle Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION"
require_file_contains "$LATEST" "Release v0.11.0 Readiness Bundle Validation Snapshot"
require_file_contains "$TESTS" "testGH917ReadinessBundleValidationClassifiesRequiredArtifactsPolicyAndChecksum"
require_file_contains "$TESTS" "ProductionReadinessBundleValidationState.allCases.map(\\.rawValue)"
require_file_contains "$TESTS" "missingRequiredArtifactIDs"
require_file_contains "$TESTS" "checksumMismatch.state"

for anchor in \
  "GH-918-VERIFY-V0110-SHADOW-DRY-RUN-PARITY-RUNNER" \
  "TVM-RELEASE-V0110-SHADOW-DRY-RUN-PARITY-RUNNER" \
  "V0110-006-SHADOW-DRY-RUN-PARITY-RUNNER" \
  "V0110-006-LOCAL-RUN-EVIDENCE" \
  "V0110-006-SHADOW-PARITY-ARTIFACT" \
  "V0110-006-MISSING-INCOMPLETE-BLOCKED" \
  "V0110-006-NO-PRODUCTION-ENDPOINT-SECRET-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$ARTIFACT_STORE_SOURCE" "public enum ProductionReadinessShadowDryRunParityEvidenceKind"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessShadowDryRunParityEvidenceInput"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessShadowDryRunParityArtifact"
require_file_contains "$ARTIFACT_STORE_SOURCE" "public struct ProductionReadinessShadowDryRunParityRunResult"
require_file_contains "$ARTIFACT_STORE_SOURCE" "writeShadowDryRunParityArtifact("
require_file_contains "$ARTIFACT_STORE_SOURCE" "shadow_dry_run_parity.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "events.jsonl"
require_file_contains "$ARTIFACT_STORE_SOURCE" "strategy_intents.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "risk_decisions.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "oms_dry_run_events.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "portfolio_projection.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "reconciliation_timeline.json"
require_file_contains "$ARTIFACT_STORE_SOURCE" "derivedFromLocalRunEvidence"
require_file_contains "$ARTIFACT_STORE_SOURCE" "referenceOnlyStageConstantsUsed"
require_file_contains "$ARTIFACT_STORE_SOURCE" "stateReason = \"missing local run evidence\""
require_file_contains "$ARTIFACT_STORE_SOURCE" "stateReason = \"invalid or incomplete local run evidence\""
require_file_contains "$ARTIFACT_STORE_SOURCE" "try Self.canonicalJSONSHA256Checksum(for: read.data)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "writeReadinessManifest("
require_file_contains "$ARTIFACT_STORE_SOURCE" "validateReadinessBundle("
require_file_contains "$READINESS" "Release v0.11.0 shadow dry-run parity runner anchor"
require_file_contains "$PLAN" "GH-918 Release v0.11.0 Shadow Dry-run Parity Runner Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-SHADOW-DRY-RUN-PARITY-RUNNER"
require_file_contains "$LATEST" "Release v0.11.0 Shadow Dry-run Parity Runner Snapshot"
require_file_contains "$TESTS" "testGH918ShadowDryRunParityRunnerBuildsArtifactFromLocalRunEvidence"
require_file_contains "$TESTS" "derivedFromLocalRunEvidence"
require_file_contains "$TESTS" "referenceOnlyStageConstantsUsed"
require_file_contains "$TESTS" "missingEvidenceKinds"
require_file_contains "$TESTS" "invalidEvidenceKinds"

for anchor in \
  "GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE" \
  "TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE" \
  "V0110-007-DASHBOARD-REAL-ARTIFACT-STATE" \
  "V0110-007-LOCAL-MANIFEST-BUNDLE-STATE" \
  "V0110-007-MISSING-CORRUPT-STALE-CHECKSUM-MISMATCH" \
  "V0110-007-NO-STATIC-EVIDENCE-EXISTS" \
  "V0110-007-READ-ONLY-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$DASHBOARD_READINESS_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$APP_TESTS" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$DASHBOARD_READINESS_SOURCE" "ReleaseV0110DashboardReadinessArtifactState"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "ReleaseV0110DashboardReadinessArtifactStateInput"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "ReleaseV0110DashboardReadinessBundleStateInput"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "artifactStates(fromReadinessManifestJSON data: Data)"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "bundleState(fromBundleValidationJSON data: Data)"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "localArtifactStateFixture("
require_file_contains "$DASHBOARD_READINESS_SOURCE" "checksum-mismatch"
require_file_contains "$DASHBOARD_READINESS_SOURCE" "local-artifact-state-not-evaluated"
require_file_contains "$APP_TESTS" "testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly"
require_file_contains "$TESTS" "testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors"
require_file_contains "$READINESS" "Release v0.11.0 Dashboard real artifact state anchor"
require_file_contains "$PLAN" "GH-919 Release v0.11.0 Dashboard Real Artifact State Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE"
require_file_contains "$LATEST" "Release v0.11.0 Dashboard Real Artifact State Snapshot"

for anchor in \
  "GH-920-VERIFY-V0110-READINESS-CLI-LOCAL-ARTIFACTS" \
  "TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS" \
  "V0110-008-READINESS-CLI-LOCAL-ARTIFACTS" \
  "V0110-008-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS" \
  "V0110-008-LOCAL-ARTIFACT-STORE-BUNDLE-VALIDATION" \
  "V0110-008-MISSING-INVALID-STALE-CHECKSUM-MISMATCH" \
  "V0110-008-NO-PRODUCTION-SECRET-ENDPOINT-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$MTPRO_CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$PACKAGE_SOURCE" "\"MTPROCLI\""
require_file_contains "$PACKAGE_SOURCE" "\"ExecutionClient\""
require_file_contains "$MTPRO_CLI_SOURCE" "ReleaseV0110ReadinessCLI"
require_file_contains "$MTPRO_CLI_SOURCE" "ProductionReadinessArtifactStore"
require_file_contains "$MTPRO_CLI_SOURCE" "readinessPlaceholderContract=retired-by-v0.11.0"
require_file_contains "$MTPRO_CLI_SOURCE" "readinessArtifactRuntimeImplemented=true"
require_file_contains "$MTPRO_CLI_SOURCE" "productionReadinessArtifactStoreImplemented=true"
require_file_contains "$MTPRO_CLI_SOURCE" "policy-v0.11.0-readiness-cli-local"
require_file_contains "$MTPRO_CLI_SOURCE" "production-readiness-overview.json"
require_file_contains "$MTPRO_CLI_SOURCE" "production-readiness-bundle.json"
require_file_contains "$MTPRO_CLI_SOURCE" "missingInvalidStaleChecksumMismatchStates=missing,invalid,stale,checksum-mismatch"
require_file_contains "$MTPRO_CLI_SOURCE" "approvalConvertedToTradingPermission=false"
require_file_contains "$MTPRO_CLI_SOURCE" "productionCutoverRemainsSeparatelyGated=true"
require_file_contains "$READINESS" "Release v0.11.0 readiness CLI local artifact commands anchor"
require_file_contains "$PLAN" "GH-920 Release v0.11.0 Readiness CLI Local Artifact Commands Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS"
require_file_contains "$LATEST" "Release v0.11.0 Readiness CLI Local Artifact Commands Snapshot"
require_file_contains "$TESTS" "testGH920ReadinessCLIOperatesOnLocalArtifactsWithoutProductionCapabilities"

BUILD_OUTPUT="$(swift run mtpro readiness build)"
STATUS_OUTPUT="$(swift run mtpro readiness status)"
VALIDATE_OUTPUT="$(swift run mtpro readiness validate)"
EXPORT_OUTPUT="$(swift run mtpro readiness export)"
APPROVAL_OUTPUT="$(swift run mtpro readiness approval-status)"

for output in "$BUILD_OUTPUT" "$STATUS_OUTPUT" "$VALIDATE_OUTPUT" "$EXPORT_OUTPUT" "$APPROVAL_OUTPUT"; do
  for required in \
    "issue=GH-920" \
    "readinessPlaceholderContract=retired-by-v0.11.0" \
    "readinessArtifactRuntimeImplemented=true" \
    "productionReadinessArtifactStoreImplemented=true" \
    "productionTradingEnabledByDefault=false" \
    "productionSecretRead=false" \
    "productionEndpointConnected=false" \
    "brokerEndpointConnected=false" \
    "productionOrderSubmitted=false" \
    "testnetOrderSubmissionAllowed=false" \
    "productionCutoverAuthorized=false"; do
    if [[ "$output" != *"$required"* ]]; then
      printf 'release v0.11.0 readiness CLI verification failed: output must contain: %s\n' "$required" >&2
      printf '%s\n' "$output" >&2
      exit 1
    fi
  done
done

for anchor in \
  "GH-921-VERIFY-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY" \
  "TVM-RELEASE-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY" \
  "V0110-009-FIXED-POINT-CAPITAL-EXPOSURE-POLICY" \
  "V0110-009-POLICY-UNITS-SCALE" \
  "V0110-009-NUMERIC-RELATIONSHIP-VALIDATION" \
  "V0110-009-POLICY-HASH-INPUTS" \
  "V0110-009-NO-PRODUCTION-CUTOVER-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "ReleaseV0110FixedPointPolicyValue"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "ReleaseV0110FixedPointPolicyUnit"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "minorUnits"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "scale"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "unit"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "fixedPointPolicyHeld"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "numericRelationshipHeld"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "capitalExposureNumericRelationship"
require_file_contains "$CAPITAL_EXPOSURE_SOURCE" "policyHashInputs"
reject_file_contains "$CAPITAL_EXPOSURE_SOURCE" "let exactStringChecks"
require_file_contains "$READINESS" "Release v0.11.0 fixed-point capital / exposure policy anchor"
require_file_contains "$PLAN" "GH-921 Release v0.11.0 Fixed-point Capital / Exposure Policy Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY"
require_file_contains "$LATEST" "Release v0.11.0 Fixed-point Capital / Exposure Policy Snapshot"
require_file_contains "$LATEST" "#921"
require_file_contains "$TESTS" "testGH921CapitalExposureReadinessUsesFixedPointPolicyValuesAndSafeComparisons"

for anchor in \
  "GH-922-VERIFY-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL" \
  "TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL" \
  "V0110-010-KILL-SWITCH-NO-TRADE-STATE-MODEL" \
  "V0110-010-UNKNOWN-STALE-UNAVAILABLE-FAIL-CLOSED" \
  "V0110-010-INACTIVE-FRESH-REVIEWED-APPROVAL-REQUEST-ELIGIBILITY" \
  "V0110-010-NO-PRODUCTION-CUTOVER-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$ARTIFACT_STORE_SOURCE" "$anchor"
  require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "ReleaseV0110KillSwitchNoTradeReadinessStateModel"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "ReleaseV0110KillSwitchNoTradeReviewState"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "eligibleForApprovalRequest"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "case inactive"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "case unknown"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "case stale"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "case unavailable"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "productionCutoverBlocked"
require_file_contains "$KILL_SWITCH_NO_TRADE_SOURCE" "orderSubmissionEnabled"
require_file_contains "$READINESS" "Release v0.11.0 kill switch / no-trade state model anchor"
require_file_contains "$PLAN" "GH-922 Release v0.11.0 Kill Switch / No-trade State Model Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL"
require_file_contains "$LATEST" "Release v0.11.0 Kill Switch / No-trade State Model Snapshot"
require_file_contains "$LATEST" "#922"
require_file_contains "$TESTS" "testGH922KillSwitchNoTradeStateModelFailsClosedAndOnlyAllowsApprovalRequestEligibility"

for anchor in \
  "GH-923-VERIFY-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS" \
  "TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS" \
  "V0110-011-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS" \
  "V0110-011-REQUEST-REVIEW-APPROVE-REVOKE-EXPIRE" \
  "V0110-011-QUORUM-EXPIRY-REVOCATION-FAIL-CLOSED" \
  "V0110-011-LOCAL-APPROVAL-EVIDENCE-ARTIFACT" \
  "V0110-011-NO-PRODUCTION-CUTOVER-ORDER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "ReleaseV0110AuditableApprovalWorkflowStateModel"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "ReleaseV0110ApprovalWorkflowTransition"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "requestedBy"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "reviewedBy"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "approvedBy"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "quorumRequired"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "expiresAt"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "revokedReason"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "approval_workflow_transitions.json"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "productionCutoverBlocked"
require_file_contains "$APPROVAL_WORKFLOW_SOURCE" "productionCutoverAuthorized == false"
require_file_contains "$READINESS" "Release v0.11.0 auditable approval workflow transitions anchor"
require_file_contains "$PLAN" "GH-923 Release v0.11.0 Auditable Approval Workflow Transitions Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS"
require_file_contains "$LATEST" "Release v0.11.0 Auditable Approval Workflow Transitions Snapshot"
require_file_contains "$LATEST" "#923"
require_file_contains "$TESTS" "testGH923AuditableApprovalWorkflowTransitionsFailClosedAndExportLocalEvidence"

for anchor in \
  "GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS" \
  "TVM-RELEASE-V0110-FINAL-AUDIT-RELEASE-DOCS" \
  "V0110-012-STAGE-CODE-AUDIT" \
  "V0110-012-RELEASE-NOTES" \
  "V0110-012-VALIDATION-SUMMARY" \
  "V0110-012-AGGREGATE-VERIFY" \
  "V0110-012-ROOT-DOCS-REFRESH" \
  "V0110-012-NO-PRODUCTION-CUTOVER" \
  "V0110-012-NO-PUBLIC-RELEASE-PUBLICATION"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$RELEASE_NOTES" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$AUDIT" "MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening"
require_file_contains "$AUDIT" "PR \`#932\`"
require_file_contains "$AUDIT" "PR \`#933\`"
require_file_contains "$AUDIT" "PR \`#934\`"
require_file_contains "$AUDIT" "PR \`#935\`"
require_file_contains "$AUDIT" "PR \`#936\`"
require_file_contains "$AUDIT" "PR \`#937\`"
require_file_contains "$AUDIT" "PR \`#938\`"
require_file_contains "$AUDIT" "PR \`#939\`"
require_file_contains "$AUDIT" "PR \`#940\`"
require_file_contains "$AUDIT" "PR \`#941\`"
require_file_contains "$AUDIT" "PR \`#942\`"
require_file_contains "$AUDIT" "checks\`, \`linux-checks\`, \`dashboard-macos\` SUCCESS"
require_file_contains "$AUDIT" "This PR owns final v0.11.0 Stage Code Audit"
require_file_contains "$AUDIT" "productionTradingEnabledByDefault=false"
require_file_contains "$AUDIT" "productionCutoverAuthorized=false"
require_file_contains "$AUDIT" "readinessApprovalConvertedToTradingPermission=false"
require_file_contains "$AUDIT" "approvalWorkflowBypassEnabled=false"
require_file_contains "$RELEASE_NOTES" "v0.11.0 是 v0.10.0 / v0.10.1 production readiness evidence 之后的本地 evidence runtime 和 integrity hardening construction closeout"
require_file_contains "$RELEASE_NOTES" "#924：收口 final validation suite"
require_file_contains "$RELEASE_NOTES" "不创建 \`v0.11.0\` tag"
require_file_contains "$READINESS" "Release v0.11.0 final audit / release docs closeout anchor"
require_file_contains "$PLAN" "GH-924 Release v0.11.0 Final Audit / Release Docs Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-FINAL-AUDIT-RELEASE-DOCS"
require_file_contains "$LATEST" "Release v0.11.0 Final Audit / Release Docs Snapshot"
require_file_contains "$LATEST" "Latest completed release construction scope | \`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening\`"
require_file_contains "$README_DOC" "Latest completed release construction scope: \`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening\`"
require_file_contains "$GOAL_DOC" "MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized"
require_file_contains "$BLUEPRINT_DOC" "Release line 已推进到 v0.11.0 production readiness evidence runtime + integrity hardening"
require_file_contains "$ROADMAP_DOC" "GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS"
require_file_contains "$TESTS" "testGH924ReleaseV0110FinalAuditReleaseDocsCloseout"
require_file_contains "$TESTS" "$AUDIT"
require_file_contains "$TESTS" "$RELEASE_NOTES"
require_file_contains "$0" "swift test --filter TargetGraphTests/testGH924ReleaseV0110FinalAuditReleaseDocsCloseout"

for required in \
  "mtpro readiness build v0.11.0" \
  "mutationApplied=true" \
  "artifactWritten=true" \
  "readinessBundleWritten=true" \
  "readinessState=valid" \
  "bundleValidationHeld=true"; do
  if [[ "$BUILD_OUTPUT" != *"$required"* ]]; then
    printf 'release v0.11.0 readiness CLI build verification failed: output must contain: %s\n' "$required" >&2
    printf '%s\n' "$BUILD_OUTPUT" >&2
    exit 1
  fi
done

for required in \
  "mtpro readiness approval-status v0.11.0" \
  "operatorApprovalStatus=not-authorized" \
  "approvalConvertedToTradingPermission=false" \
  "approvalCanAuthorizeProductionCutover=false" \
  "productionCutoverRemainsSeparatelyGated=true"; do
  if [[ "$APPROVAL_OUTPUT" != *"$required"* ]]; then
    printf 'release v0.11.0 readiness CLI approval-status verification failed: output must contain: %s\n' "$required" >&2
    printf '%s\n' "$APPROVAL_OUTPUT" >&2
    exit 1
  fi
done

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
  "liveCommandEnabled=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

swift test --filter TargetGraphTests/testGH913ReleaseV0110ProductionReadinessEvidenceRuntimeContract
swift test --filter TargetGraphTests/testGH914ProductionReadinessArtifactStoreUsesLocalExplicitStates
swift test --filter TargetGraphTests/testGH915ReadinessManifestSchemaAndAtomicIORequireRealArtifacts
swift test --filter TargetGraphTests/testGH916CanonicalJSONSHA256RejectsPlaceholderAndMismatchChecksums
swift test --filter TargetGraphTests/testGH917ReadinessBundleValidationClassifiesRequiredArtifactsPolicyAndChecksum
swift test --filter TargetGraphTests/testGH918ShadowDryRunParityRunnerBuildsArtifactFromLocalRunEvidence
swift test --filter AppTests/testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly
swift test --filter TargetGraphTests/testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors
swift test --filter TargetGraphTests/testGH920ReadinessCLIOperatesOnLocalArtifactsWithoutProductionCapabilities
swift test --filter TargetGraphTests/testGH921CapitalExposureReadinessUsesFixedPointPolicyValuesAndSafeComparisons
swift test --filter TargetGraphTests/testGH922KillSwitchNoTradeStateModelFailsClosedAndOnlyAllowsApprovalRequestEligibility
swift test --filter TargetGraphTests/testGH923AuditableApprovalWorkflowTransitionsFailClosedAndExportLocalEvidence
swift test --filter TargetGraphTests/testGH924ReleaseV0110FinalAuditReleaseDocsCloseout

bash checks/verify-v0.11.1-release-fact-sync.sh

echo "MTPRO release v0.11.0 production readiness evidence runtime verification passed."
