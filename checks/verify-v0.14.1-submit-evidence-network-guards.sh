#!/usr/bin/env bash
set -euo pipefail

# GH-1061-VERIFY-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS
# TVM-RELEASE-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS
# V0141-003-ADAPTER-SUBMIT-EVIDENCE-CREATED
# V0141-003-NETWORK-SUBMIT-ATTEMPTED-FALSE
# V0141-003-NETWORK-CANCEL-REPLACE-ATTEMPTED-FALSE
# V0141-003-EVIDENCE-ONLY-WORDING
# V0141-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'release v0.14.1 submit evidence network guard verification failed: %s\n' "$*" >&2
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

SIGNAL_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140SignalToExecutionPipeline.swift"
FAILURE_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FailureSimulationSuite.swift"
FULL_E2E_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FullE2ETestnetSuite.swift"
SIGNAL_DOC="docs/contracts/release-v0.14.0-signal-to-execution-pipeline.md"
FAILURE_DOC="docs/contracts/release-v0.14.0-failure-simulation-suite.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"
READINESS="docs/automation/automation-readiness.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"

for anchor in \
  "GH-1061-VERIFY-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS" \
  "TVM-RELEASE-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS" \
  "V0141-003-ADAPTER-SUBMIT-EVIDENCE-CREATED" \
  "V0141-003-NETWORK-SUBMIT-ATTEMPTED-FALSE" \
  "V0141-003-NETWORK-CANCEL-REPLACE-ATTEMPTED-FALSE" \
  "V0141-003-EVIDENCE-ONLY-WORDING" \
  "V0141-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
done

for file in "$SIGNAL_SOURCE" "$FAILURE_SOURCE" "$FULL_E2E_SOURCE" "$TESTS"; do
  require_file_contains "$file" "adapterSubmitEvidenceCreated"
  reject_file_contains "$file" "adapterSubmitAttempted"
done

for file in "$SIGNAL_SOURCE" "$FAILURE_SOURCE" "$TESTS"; do
  require_file_contains "$file" "networkSubmitAttempted"
  require_file_contains "$file" "networkCancelReplaceAttempted"
done

for file in "$SIGNAL_DOC" "$FAILURE_DOC"; do
  require_file_contains "$file" "adapter submit evidence"
  require_file_contains "$file" "networkSubmitAttempted"
  require_file_contains "$file" "networkCancelReplaceAttempted"
done

require_file_contains "$RUNNER" "bash checks/verify-v0.14.1-submit-evidence-network-guards.sh"
require_file_contains "$TESTS" "testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal"
require_file_contains "$TESTS" "testGH1039ReleaseV0140FailureSimulationSuiteCoversSixFailClosedModes"

swift test --filter TargetGraphTests/testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal
swift test --filter TargetGraphTests/testGH1039ReleaseV0140FailureSimulationSuiteCoversSixFailClosedModes

echo "MTPRO release v0.14.1 submit evidence network guard verification passed."
