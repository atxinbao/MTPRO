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

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

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
REGISTRY_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0120ReadinessAssessmentRegistryStore.swift"

swift test --filter TargetGraphTests/testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract
swift test --filter TargetGraphTests/testGH953ReleaseV0120CarriesForwardV011XPublicationAndPatchFacts
swift test --filter TargetGraphTests/testGH954ReadinessAssessmentRegistryStorePersistsLifecycleAndCompareReadyMetadata
swift test --filter TargetGraphTests/testGH955AssessmentTransactionLockControlsGenerationAndCrashRecovery
swift test --filter TargetGraphTests/testGH956ReadinessManifestV2RecordsAssessmentGenerationAndProvenance
swift test --filter TargetGraphTests/testGH957ArtifactContentPolicyRejectsSecretsListenKeysOrdersAndEndpointResponses
swift test --filter TargetGraphTests/testGH958ImmutableReadinessBundleSnapshotRequiresNewGenerationOnChange

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
  "V0120-007-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  if [[ "$anchor" == GH-954-* || "$anchor" == GH-955-* || "$anchor" == GH-956-* || "$anchor" == GH-957-* || "$anchor" == GH-958-* || "$anchor" == TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE || "$anchor" == TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK || "$anchor" == TVM-RELEASE-V0120-READINESS-MANIFEST-V2 || "$anchor" == TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION || "$anchor" == TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT || "$anchor" == V0120-003-* || "$anchor" == V0120-004-* || "$anchor" == V0120-005-* || "$anchor" == V0120-006-* || "$anchor" == V0120-007-* ]]; then
    require_file_contains "$REGISTRY_SOURCE" "$anchor"
  fi
done

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
