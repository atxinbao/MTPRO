#!/usr/bin/env bash
set -euo pipefail

# GH-1062-VERIFY-V0141-GOLDEN-JSON-CONTRACTS
# TVM-RELEASE-V0141-GOLDEN-JSON-CONTRACTS
# V0141-004-GOLDEN-JSON-FIXTURES
# V0141-004-DECODE-VALIDATE-MUTATE-FAIL
# V0141-004-CORRUPTED-PAYLOADS-FAIL-CLOSED
# V0141-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.14.1 golden JSON contract verification failed: %s\n' "$*" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  grep -Fq "$needle" "$file" || fail "$file missing: $needle"
}

reject_file_contains() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  if grep -Fq "$needle" "$file"; then
    fail "$file contains forbidden wording: $needle"
  fi
}

ORDER_LIFECYCLE_SOURCE="Sources/DomainModel/OrderLifecycle.swift"
OMS_STORE_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0140OMSLocalOrderStore.swift"
PIPELINE_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140SignalToExecutionPipeline.swift"
FIXTURE_ROOT="Tests/Fixtures/ReleaseV0141GoldenJSON/valid"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
READINESS="docs/automation/automation-readiness.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"

for anchor in \
  "GH-1062-VERIFY-V0141-GOLDEN-JSON-CONTRACTS" \
  "TVM-RELEASE-V0141-GOLDEN-JSON-CONTRACTS" \
  "V0141-004-GOLDEN-JSON-FIXTURES" \
  "V0141-004-DECODE-VALIDATE-MUTATE-FAIL" \
  "V0141-004-CORRUPTED-PAYLOADS-FAIL-CLOSED" \
  "V0141-004-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

for fixture in \
  "$FIXTURE_ROOT/signal-pipeline-report.json" \
  "$FIXTURE_ROOT/oms-local-order-event.json" \
  "$FIXTURE_ROOT/dashboard-surface.json"; do
  [[ -f "$fixture" ]] || fail "missing golden JSON fixture: $fixture"
done
require_file_contains "$TARGET_TESTS" "Tests/Fixtures/ReleaseV0141GoldenJSON/valid"
require_file_contains "$TARGET_TESTS" "signal-pipeline-report.json"
require_file_contains "$TARGET_TESTS" "oms-local-order-event.json"
require_file_contains "$TARGET_TESTS" "dashboard-surface.json"

require_file_contains "$ORDER_LIFECYCLE_SOURCE" "public init(from decoder: Decoder) throws"
require_file_contains "$OMS_STORE_SOURCE" "ReleaseV0140OMSLocalOrderStoreEvent"
require_file_contains "$OMS_STORE_SOURCE" "transition: try container.decodeIfPresent(OrderLifecycleTransition.self"
require_file_contains "$PIPELINE_SOURCE" "ReleaseV0140SignalToExecutionPipelineReport"
require_file_contains "$PIPELINE_SOURCE" "field: \"releaseV0140SignalPipeline.report.decode.reportID\""
require_file_contains "$TARGET_TESTS" "testGH1062ReleaseV0141GoldenJSONFixturesFailClosedCorruptedV0140Contracts"
require_file_contains "$TARGET_TESTS" "missingEvidenceDashboard"
require_file_contains "$TARGET_TESTS" "wrongStageSignal"
require_file_contains "$TARGET_TESTS" "illegalLifecycleEvent"
require_file_contains "$TARGET_TESTS" "corruptedBoundarySignal"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.1-golden-json-contracts.sh"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "productionSubmitCancelReplace=true" \
  "productionCutoverAuthorized=true" \
  "swift run mtpro submit" \
  "swift run mtpro cancel" \
  "swift run mtpro replace"; do
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$VALIDATION_PLAN" "$forbidden"
  reject_file_contains "$TRADING_MATRIX" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1062ReleaseV0141GoldenJSONFixturesFailClosedCorruptedV0140Contracts

echo "MTPRO release v0.14.1 golden JSON contract verification passed."
