#!/usr/bin/env bash
set -euo pipefail

# GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
# TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
# GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
# TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
# GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO
# TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO

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
require_file_contains "$ARTIFACT_STORE_SOURCE" "deterministicChecksum(for data: Data)"
require_file_contains "$ARTIFACT_STORE_SOURCE" "manifestPolicyMismatch"
require_file_contains "$ARTIFACT_STORE_SOURCE" "manifestEntryRejected"
require_file_contains "$ARTIFACT_STORE_SOURCE" "checksumMismatch"
require_file_contains "$ARTIFACT_STORE_SOURCE" "evidenceExists"
require_file_contains "$ARTIFACT_STORE_SOURCE" "atomicWriteRequired"
require_file_contains "$ARTIFACT_STORE_SOURCE" "entry.policyVersion == requiredPolicyVersion"
require_file_contains "$ARTIFACT_STORE_SOURCE" "record.state == .valid"
require_file_contains "$ARTIFACT_STORE_SOURCE" "data.count == entry.size"
require_file_contains "$ARTIFACT_STORE_SOURCE" "Self.deterministicChecksum(for: data) == entry.checksum"
require_file_contains "$READINESS" "Release v0.11.0 readiness manifest atomic IO anchor"
require_file_contains "$PLAN" "GH-915 Release v0.11.0 Readiness Manifest Atomic IO Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO"
require_file_contains "$LATEST" "Release v0.11.0 Readiness Manifest Atomic IO Snapshot"
require_file_contains "$TESTS" "testGH915ReadinessManifestSchemaAndAtomicIORequireRealArtifacts"

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

echo "MTPRO release v0.11.0 production readiness evidence runtime verification passed."
