#!/usr/bin/env bash
set -euo pipefail

# GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
# TVM-RELEASE-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
# V0250-001-DUAL-PRODUCT-PRODUCTION-READINESS
# V0250-001-NO-DEFAULT-TRADING
# V0250-001-SPOT-CANARY-EVIDENCE-NOT-CUTOVER
# V0250-001-FUTURES-READONLY-EVIDENCE-NOT-EXECUTION
# GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY
# V0250-002-CREDENTIAL-REFERENCE-ONLY
# V0250-002-NO-SECRET-READ
# GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE
# V0250-003-SPOT-CANARY-OPERATOR-CONFIRMATION
# GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE
# V0250-004-NO-FUTURES-ORDER-MUTATION
# GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE
# V0250-005-NO-LIVE-COMMAND-AUTHORIZATION
# GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE
# V0250-006-NO-LIVE-COMMAND-UI
# GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE
# V0250-007-NO-TRADING-BUTTON
# GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
# TVM-RELEASE-V0250-AGGREGATE-VALIDATION
# V0250-008-AGGREGATE-VALIDATION-SUITE
# V0250-008-STAGE-AUDIT-RELEASE-DOCS
# V0250-008-ROOT-DOCS-REFRESH
# V0250-008-RELEASE-PUBLICATION-GATE-HANDOFF
# V0250-008-NO-PRODUCTION-CUTOVER
# V0250-008-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.25.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.25.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.25.0-dual-product-production-readiness-canary-hardening-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.25.0-dual-product-production-readiness-canary-hardening-notes.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1379ReleaseV0250AggregateValidationReleaseCloseout

PRODUCTION_STATUS_OUTPUT="$(swift run mtpro dual-product-production-readiness status)"
PRODUCTION_PRODUCTS_OUTPUT="$(swift run mtpro dual-product-production-readiness products)"
PRODUCTION_BOUNDARIES_OUTPUT="$(swift run mtpro dual-product-production-readiness boundaries)"
OPERATOR_STATUS_OUTPUT="$(swift run mtpro dual-product-operator-readiness status)"
OPERATOR_EVIDENCE_OUTPUT="$(swift run mtpro dual-product-operator-readiness evidence)"
OPERATOR_BOUNDARIES_OUTPUT="$(swift run mtpro dual-product-operator-readiness boundaries)"
LEGACY_V0200_OUTPUT="$(swift run mtpro production-shadow-readiness status)"

printf '%s\n' "$PRODUCTION_STATUS_OUTPUT" | grep -Fq "productionTradingEnabledByDefault=false"
printf '%s\n' "$PRODUCTION_STATUS_OUTPUT" | grep -Fq "productionCutoverAuthorized=false"
printf '%s\n' "$PRODUCTION_PRODUCTS_OUTPUT" | grep -Fq "productType:spot"
printf '%s\n' "$PRODUCTION_PRODUCTS_OUTPUT" | grep -Fq "productType:usdsPerpetual"
printf '%s\n' "$PRODUCTION_PRODUCTS_OUTPUT" | grep -Fq "role:futures-readonly-evidence"
printf '%s\n' "$PRODUCTION_BOUNDARIES_OUTPUT" | grep -Fq "futuresReadOnlyEvidenceNotExecution=true"
printf '%s\n' "$PRODUCTION_BOUNDARIES_OUTPUT" | grep -Fq "productionSecretReadAuthorized=false"
printf '%s\n' "$PRODUCTION_BOUNDARIES_OUTPUT" | grep -Fq "brokerEndpointConnectionAuthorized=false"
printf '%s\n' "$OPERATOR_STATUS_OUTPUT" | grep -Fq "surface=dual-product-operator-readiness-read-only"
printf '%s\n' "$OPERATOR_EVIDENCE_OUTPUT" | grep -Fq "credential=productionSecretRead=false"
printf '%s\n' "$OPERATOR_EVIDENCE_OUTPUT" | grep -Fq "risk=riskCapitalExposureNotionalGate=v0.25.0/V0250-005"
printf '%s\n' "$OPERATOR_EVIDENCE_OUTPUT" | grep -Fq "rollback=incidentRollbackNoTradeKillSwitch=v0.25.0/V0250-006"
printf '%s\n' "$OPERATOR_BOUNDARIES_OUTPUT" | grep -Fq "readOnlySurface=true"
printf '%s\n' "$OPERATOR_BOUNDARIES_OUTPUT" | grep -Fq "tradingButtonVisible=false"
printf '%s\n' "$OPERATOR_BOUNDARIES_OUTPUT" | grep -Fq "orderFormVisible=false"
printf '%s\n' "$OPERATOR_BOUNDARIES_OUTPUT" | grep -Fq "liveCommandVisible=false"
printf '%s\n' "$LEGACY_V0200_OUTPUT" | grep -Fq "mtpro production-shadow-readiness status"
printf '%s\n' "$LEGACY_V0200_OUTPUT" | grep -Fq "issue=GH-1248"
printf '%s\n' "$LEGACY_V0200_OUTPUT" | grep -Fq "productionTradingEnabledByDefault=false"
printf '%s\n' "$LEGACY_V0200_OUTPUT" | grep -Fq "productionEndpointConnected=false"
printf '%s\n' "$LEGACY_V0200_OUTPUT" | grep -Fq "realOrderSent=false"

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$VERIFICATION" \
  "$TESTS" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT"
  require_file_contains "$file" "GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY"
  require_file_contains "$file" "GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE"
  require_file_contains "$file" "GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE"
  require_file_contains "$file" "GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE"
  require_file_contains "$file" "GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE"
  require_file_contains "$file" "GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE"
  require_file_contains "$file" "GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT"
  require_file_contains "$file" "TVM-RELEASE-V0250-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0250-008-AGGREGATE-VALIDATION-SUITE"
  require_file_contains "$file" "V0250-008-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0250-008-ROOT-DOCS-REFRESH"
  require_file_contains "$file" "V0250-008-RELEASE-PUBLICATION-GATE-HANDOFF"
  require_file_contains "$file" "V0250-008-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0250-008-NO-TAG-OR-RELEASE-PUBLICATION"
done

require_file_contains "$POLICY" "GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT"
require_file_contains "$POLICY" "TVM-RELEASE-V0250-AGGREGATE-VALIDATION"
require_file_contains "$POLICY" "V0250-008-RELEASE-PUBLICATION-GATE-HANDOFF"
require_file_contains "$POLICY" "V0250-008-NO-PRODUCTION-CUTOVER"
require_file_contains "$POLICY" "V0250-008-NO-TAG-OR-RELEASE-PUBLICATION"
require_file_contains "$RUN_SCRIPT" "GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.25.0.sh"

for file in \
  "$AUDIT" \
  "$NOTES" \
  "docs/contracts/release-v0.25.0-dual-product-production-readiness-contract.md" \
  "docs/contracts/release-v0.25.0-dashboard-cli-operator-readiness-surface.md"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretReadEnabled=true"
  reject_file_contains "$file" "credentialValueStored=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled=true"
  reject_file_contains "$file" "brokerEndpointConnectionEnabled=true"
  reject_file_contains "$file" "orderSubmitCancelReplaceEnabled=true"
  reject_file_contains "$file" "futuresExecutionEnabled=true"
  reject_file_contains "$file" "futuresSubmitCancelReplaceEnabled=true"
  reject_file_contains "$file" "unrestrictedLiveTradingAuthorized=true"
  reject_file_contains "$file" "dashboardTradingControlsEnabled=true"
  reject_file_contains "$file" "tradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "liveProConsoleEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "okxActiveRuntimeEnabled=true"
done

printf 'MTPRO v0.25.0 dual-product production readiness / canary hardening checks passed.\n'
