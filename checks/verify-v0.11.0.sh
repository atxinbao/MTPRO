#!/usr/bin/env bash
set -euo pipefail

# GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
# TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT

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

echo "MTPRO release v0.11.0 production readiness evidence runtime contract verification passed."
