#!/usr/bin/env bash
set -euo pipefail

# GH-1350-VERIFY-V0230-AGGREGATE-VALIDATION
# GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT
# TVM-RELEASE-V0230-FUTURES-READONLY-CONTRACT
# V0230-001-BINANCE-USDM-FUTURES-READONLY-FOUNDATION
# V0230-001-NO-FUTURES-ORDER-EXECUTION
# GH-1342-VERIFY-V0230-FUTURES-PROFILE-ENDPOINT-ALLOWLIST
# V0230-002-BINANCE-USDM-FUTURES-PROFILE
# V0230-002-READ-ONLY-ENDPOINT-ALLOWLIST
# GH-1343-VERIFY-V0230-FUTURES-CREDENTIAL-REFERENCE-GATE
# V0230-003-CREDENTIAL-REFERENCE-ONLY
# V0230-003-SIGNED-READONLY-APPROVAL-GATE
# GH-1344-VERIFY-V0230-FUTURES-ACCOUNT-SNAPSHOT-REDACTION
# V0230-004-REDACTED-ACCOUNT-SNAPSHOT
# GH-1345-VERIFY-V0230-FUTURES-POSITION-MARGIN-LEVERAGE-READONLY
# V0230-005-POSITION-MARGIN-LEVERAGE-OBSERVED-STATE
# GH-1346-VERIFY-V0230-FUTURES-FUNDING-MARK-LIQUIDATION-READONLY
# V0230-006-FUNDING-MARK-LIQUIDATION-OBSERVATION
# GH-1347-VERIFY-V0230-FUTURES-TRANSPORT-ARTIFACT-FAILURE-CLASSIFICATION
# V0230-007-READONLY-TRANSPORT-ARTIFACT
# V0230-007-FAIL-CLOSED-FAILURE-CLASSIFICATION
# GH-1348-VERIFY-V0230-FUTURES-READONLY-RECONCILIATION
# V0230-008-LOCAL-REGISTRY-RECONCILIATION
# V0230-008-NO-BROKER-RECONCILIATION-RUNTIME
# GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
# TVM-RELEASE-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
# V0230-009-DASHBOARD-CLI-READONLY-FUTURES-READINESS
# V0230-009-NO-TRADING-COMMANDS
# V0230-009-NO-DASHBOARD-TRADING-CONTROLS
# TVM-RELEASE-V0230-AGGREGATE-VALIDATION
# V0230-010-AGGREGATE-VALIDATION-SUITE
# V0230-010-FUTURES-READONLY-FOUNDATION
# V0230-010-NO-FUTURES-ORDER-EXECUTION
# V0230-010-NO-PRODUCTION-CUTOVER
# GH-1351-VERIFY-V0230-STAGE-AUDIT-RELEASE-DOCS
# V0230-011-STAGE-CODE-AUDIT
# V0230-011-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.23.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.23.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.23.0-binance-usdm-futures-read-only-foundation-contract.md"
AUDIT="docs/audit/mtpro-release-v0.23.0-binance-usdm-futures-read-only-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.23.0-binance-usdm-futures-read-only-foundation-notes.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
CLI="Sources/MTPROCLI/main.swift"
EVIDENCE="Sources/ExecutionClient/FutureGate/ReleaseV0230BinanceUSDMFuturesReadOnlyFoundation.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0230DashboardCLIFuturesReadOnlyReadinessSurface.swift"

swift test --filter TargetGraphTests/testGH1341To1351ReleaseV0230BinanceUSDMFuturesReadOnlyFoundation

STATUS_OUTPUT="$(swift run mtpro futures-readonly-readiness status)"
ENDPOINT_OUTPUT="$(swift run mtpro futures-readonly-readiness endpoints)"
FAILURE_OUTPUT="$(swift run mtpro futures-readonly-readiness failures)"
RECON_OUTPUT="$(swift run mtpro futures-readonly-readiness reconciliation)"

printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "venue=binance"
printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "productType=usdsPerpetual"
printf '%s\n' "$STATUS_OUTPUT" | grep -Fq "futuresOrderExecutionEnabled=false"
printf '%s\n' "$ENDPOINT_OUTPUT" | grep -Fq "allowedEndpoint=GET /fapi/v2/account"
printf '%s\n' "$ENDPOINT_OUTPUT" | grep -Fq "forbiddenEndpoint=POST /fapi/v1/order"
printf '%s\n' "$FAILURE_OUTPUT" | grep -Fq "failureClass=signed-order-endpoint-rejected;failClosed=true"
printf '%s\n' "$RECON_OUTPUT" | grep -Fq "brokerReconciliationRuntime=false"

for file in \
  "$CONTRACT" \
  "$AUDIT" \
  "$NOTES" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$CLI" \
  "$EVIDENCE" \
  "$DASHBOARD" \
  "$0"; do
  require_file_contains "$file" "GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0230-FUTURES-READONLY-CONTRACT"
  require_file_contains "$file" "V0230-001-BINANCE-USDM-FUTURES-READONLY-FOUNDATION"
  require_file_contains "$file" "GH-1342-VERIFY-V0230-FUTURES-PROFILE-ENDPOINT-ALLOWLIST"
  require_file_contains "$file" "V0230-002-READ-ONLY-ENDPOINT-ALLOWLIST"
  require_file_contains "$file" "GH-1343-VERIFY-V0230-FUTURES-CREDENTIAL-REFERENCE-GATE"
  require_file_contains "$file" "V0230-003-CREDENTIAL-REFERENCE-ONLY"
  require_file_contains "$file" "GH-1344-VERIFY-V0230-FUTURES-ACCOUNT-SNAPSHOT-REDACTION"
  require_file_contains "$file" "V0230-004-REDACTED-ACCOUNT-SNAPSHOT"
  require_file_contains "$file" "GH-1345-VERIFY-V0230-FUTURES-POSITION-MARGIN-LEVERAGE-READONLY"
  require_file_contains "$file" "V0230-005-POSITION-MARGIN-LEVERAGE-OBSERVED-STATE"
  require_file_contains "$file" "GH-1346-VERIFY-V0230-FUTURES-FUNDING-MARK-LIQUIDATION-READONLY"
  require_file_contains "$file" "V0230-006-FUNDING-MARK-LIQUIDATION-OBSERVATION"
  require_file_contains "$file" "GH-1347-VERIFY-V0230-FUTURES-TRANSPORT-ARTIFACT-FAILURE-CLASSIFICATION"
  require_file_contains "$file" "V0230-007-FAIL-CLOSED-FAILURE-CLASSIFICATION"
  require_file_contains "$file" "GH-1348-VERIFY-V0230-FUTURES-READONLY-RECONCILIATION"
  require_file_contains "$file" "V0230-008-LOCAL-REGISTRY-RECONCILIATION"
  require_file_contains "$file" "GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE"
  require_file_contains "$file" "V0230-009-DASHBOARD-CLI-READONLY-FUTURES-READINESS"
  require_file_contains "$file" "GH-1350-VERIFY-V0230-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0230-010-AGGREGATE-VALIDATION-SUITE"
  require_file_contains "$file" "GH-1351-VERIFY-V0230-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0230-011-STAGE-CODE-AUDIT"
  require_file_contains "$file" "V0230-011-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CLI" "ReleaseV0230FuturesReadOnlyFoundationEvidence.cliCommand"
require_file_contains "$CLI" "ReleaseV0230FuturesReadOnlyFoundationEvidence.commandLineOutput"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.23.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.23.0.sh"
require_file_contains "$READINESS" "Release v0.23.0 Binance USD-M Futures read-only foundation anchor"
require_file_contains "$PLAN" "GH-1350 Release v0.23.0 Aggregate Validation Suite"
require_file_contains "$MATRIX" "TVM-RELEASE-V0230-AGGREGATE-VALIDATION"
require_file_contains "$VERIFICATION" "MTPRO Release v0.23.0 Binance USD-M Futures Read-only Foundation"

for file in "$CONTRACT" "$AUDIT" "$NOTES" "$LATEST" "$VERIFICATION" "$EVIDENCE" "$DASHBOARD"; do
  require_file_contains "$file" "Binance USD-M Futures read-only foundation"
  require_file_contains "$file" "futuresOrderExecutionEnabled=false"
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "signedOrderEndpointEnabled=true"
  reject_file_contains "$file" "orderMutationEndpointEnabled=true"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxEnabled=true"
  reject_file_contains "$file" "tradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.23.0 Binance USD-M Futures read-only foundation verification passed."
