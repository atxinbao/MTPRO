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
ARTIFACT_STORE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift"

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

echo "MTPRO release v0.11.0 production readiness evidence runtime verification passed."
