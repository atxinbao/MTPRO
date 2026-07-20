#!/usr/bin/env bash
set -euo pipefail

# GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
# TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING
# V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
# V0270-001-FAIL-CLOSED-SEMANTICS
# GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST
# V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST
# V0270-002-RUN-IDENTITY-EVIDENCE
# GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
# V0270-003-SIGNED-STATUS-RETRY-TIMEOUT
# V0270-003-CLASSIFIED-FAILURE-EVIDENCE
# GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY
# V0270-004-CANCEL-STATUS-RECOVERY
# V0270-004-RECONCILIATION-RECOVERY
# GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# V0270-005-CHECKSUM-FAIL-CLOSED
# GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK
# V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD
# V0270-006-RUN-LOCK-HARDENING
# GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY
# V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN
# V0270-007-NO-DASHBOARD-TRADING-CONTROLS
# GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION
# V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
# V0270-008-REDACTION-EVIDENCE
# GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION
# V0270-009-AGGREGATE-VALIDATION-SUITE
# GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS
# V0270-010-STAGE-CODE-AUDIT
# V0270-010-RELEASE-NOTES
# V0270-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "missing required text in $file: $needle" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    echo "forbidden text present in $file: $needle" >&2
    exit 1
  fi
}

EVIDENCE="Sources/ExecutionClient/FutureGate/ReleaseV0270FuturesTestnetOperatorRuntimeHardening.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0270DashboardCLIFuturesTestnetFailureDrilldownSurface.swift"
CLI="Sources/MTPROCLI/main.swift"
AUDIT="docs/audit/mtpro-release-v0.27.0-binance-usdm-futures-testnet-operator-runtime-hardening-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.27.0-binance-usdm-futures-testnet-operator-runtime-hardening-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
VERIFY_SCRIPT="checks/verify-v0.27.0.sh"

swift test --filter TargetGraphTests/testGH1411To1420ReleaseV0270FuturesTestnetOperatorRuntimeHardening

STATUS_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening status)"
REGISTRY_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening registry)"
FAILURES_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening failures)"
RECOVERY_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening recovery)"
REPLAY_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening replay)"
IDEMPOTENCY_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening idempotency)"
SURFACE_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening surface)"
WORKFLOW_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening workflow)"
BOUNDARIES_OUTPUT="$(swift run mtpro futures-testnet-operator-hardening boundaries)"

for expected in \
  "release=v0.27.0" \
  "runNamespace=binance/usdsPerpetual/testnet/v0.27.0" \
  "boundaryHeld=true"; do
  if [[ "$STATUS_OUTPUT" != *"$expected"* ]]; then
    echo "status output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "runRegistryRecorded=true" \
  "runIdentityEvidenceRecorded=true" \
  "artifactManifestID=v0270-futures-testnet-operator-artifact-manifest"; do
  if [[ "$REGISTRY_OUTPUT" != *"$expected"* ]]; then
    echo "registry output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "signedStatusMaxRetries=3" \
  "statusRetryEvidenceRecorded=true" \
  "failureClass=signed-status-timeout;classified=true;failClosed=true"; do
  if [[ "$FAILURES_OUTPUT" != *"$expected"* ]]; then
    echo "failures output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "cancelStatusRecoveryEnabled=true" \
  "reconciliationRecoveryEnabled=true" \
  "ambiguousStateFailsClosed=true"; do
  if [[ "$RECOVERY_OUTPUT" != *"$expected"* ]]; then
    echo "recovery output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "replayValidatorEnabled=true" \
  "replayChecksumVerified=true" \
  "corruptArtifactFailsClosed=true" \
  "missingArtifactFailsClosed=true"; do
  if [[ "$REPLAY_OUTPUT" != *"$expected"* ]]; then
    echo "replay output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "idempotencyKeyRequired=true" \
  "duplicateSubmitRejected=true" \
  "runLockRequired=true"; do
  if [[ "$IDEMPOTENCY_OUTPUT" != *"$expected"* ]]; then
    echo "idempotency output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "dashboardFailureDrilldownReadOnly=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandVisible=false"; do
  if [[ "$SURFACE_OUTPUT" != *"$expected"* ]]; then
    echo "surface output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "manualWorkflowArtifactValidationEnabled=true" \
  "redactionPolicyApplied=true" \
  "manualWorkflowRejectsProductionHost=true"; do
  if [[ "$WORKFLOW_OUTPUT" != *"$expected"* ]]; then
    echo "workflow output missing: $expected" >&2
    exit 1
  fi
done

for expected in \
  "productionFuturesOrderExecutionEnabled=false" \
  "productionCutoverAuthorized=false" \
  "okxActiveRuntimeEnabled=false" \
  "dashboardTradingControlsEnabled=false" \
  "productionOrderSubmitted=false"; do
  if [[ "$BOUNDARIES_OUTPUT" != *"$expected"* ]]; then
    echo "boundaries output missing: $expected" >&2
    exit 1
  fi
done

ANCHORS=(
  "GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT"
  "TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING"
  "V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT"
  "V0270-001-FAIL-CLOSED-SEMANTICS"
  "GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST"
  "V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST"
  "V0270-002-RUN-IDENTITY-EVIDENCE"
  "GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL"
  "V0270-003-SIGNED-STATUS-RETRY-TIMEOUT"
  "V0270-003-CLASSIFIED-FAILURE-EVIDENCE"
  "GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY"
  "V0270-004-CANCEL-STATUS-RECOVERY"
  "V0270-004-RECONCILIATION-RECOVERY"
  "GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR"
  "V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR"
  "V0270-005-CHECKSUM-FAIL-CLOSED"
  "GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK"
  "V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD"
  "V0270-006-RUN-LOCK-HARDENING"
  "GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY"
  "V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN"
  "V0270-007-NO-DASHBOARD-TRADING-CONTROLS"
  "GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION"
  "V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION"
  "V0270-008-REDACTION-EVIDENCE"
  "GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION"
  "V0270-009-AGGREGATE-VALIDATION-SUITE"
  "GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS"
  "V0270-010-STAGE-CODE-AUDIT"
  "V0270-010-RELEASE-NOTES"
  "V0270-010-NO-PRODUCTION-CUTOVER"
)

for file in \
  "$EVIDENCE" \
  "$DASHBOARD" \
  "$CLI" \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$VERIFY_SCRIPT"; do
  for anchor in "${ANCHORS[@]}"; do
    require_file_contains "$file" "$anchor"
  done
done

for file in "$EVIDENCE" "$DASHBOARD" "$AUDIT" "$NOTES" "$LATEST" "$VERIFICATION"; do
  require_file_contains "$file" "Binance USD-M Futures testnet operator runtime hardening"
  require_file_contains "$file" "productionFuturesOrderExecutionEnabled=false"
  require_file_contains "$file" "production cutover not authorized"
  for forbidden in \
    "productionFuturesOrderExecutionEnabled=true" \
    "productionTradingEnabledByDefault=true" \
    "productionCutoverAuthorized=true" \
    "okxActiveRuntimeEnabled=true" \
    "dashboardTradingControlsEnabled=true" \
    "tradingButtonVisible=true" \
    "orderFormVisible=true" \
    "liveCommandVisible=true" \
    "unrestrictedLiveTradingAuthorized=true" \
    "API Key:" \
    "Secret Key:"; do
    reject_file_contains "$file" "$forbidden"
  done
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.27.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.27.0.sh"

echo "v0.27.0 Futures testnet operator runtime hardening verification passed"
