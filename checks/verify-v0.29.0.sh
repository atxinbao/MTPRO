#!/usr/bin/env bash
set -euo pipefail

# GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT
# TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
# V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
# V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT
# V0290-001-NO-DEFAULT-TRADING
# V0290-001-NO-SUBMIT
# GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL
# V0290-002-PRODUCTION-SHADOW-CONFIGURATION
# V0290-002-NO-SECRET-CONFIGURATION
# V0290-002-MISMATCH-FAILS-CLOSED
# GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION
# V0290-003-CREDENTIAL-REFERENCE-ONLY
# V0290-003-OPERATOR-APPROVAL-REQUIRED
# V0290-003-SECRET-VALUE-NOT-PERSISTED
# GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT
# V0290-004-ENDPOINT-ALLOWLIST-READONLY
# V0290-004-MUTATION-ENDPOINTS-BLOCKED
# GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
# V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
# V0290-005-STALE-MISSING-INPUTS-BLOCKED
# GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE
# V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE
# V0290-006-NO-BROKER-FILL-INTERPRETATION
# GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
# V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
# V0290-007-NO-BROKER-SIDE-EFFECT
# GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE
# V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE
# V0290-008-NO-TRADING-CONTROLS
# GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION
# V0290-009-AGGREGATE-VALIDATION
# V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX
# GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS
# V0290-010-STAGE-AUDIT-RELEASE-DOCS
# V0290-010-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.29.0 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.29.0 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0290ProductionDryRunShadowAcceptance.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0290DashboardCLIShadowAcceptanceSurface.swift"
AUDIT="docs/audit/mtpro-release-v0.29.0-binance-production-dry-run-shadow-run-acceptance-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.29.0-binance-production-dry-run-shadow-run-acceptance-notes.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
ROADMAP="docs/roadmap.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1447To1456ReleaseV0290ProductionDryRunShadowAcceptance

for file in \
  "$SOURCE" \
  "$DASHBOARD" \
  "$AUDIT" \
  "$NOTES" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$ROADMAP" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT"
  require_file_contains "$file" "TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE"
  require_file_contains "$file" "V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE"
  require_file_contains "$file" "V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT"
  require_file_contains "$file" "V0290-001-NO-DEFAULT-TRADING"
  require_file_contains "$file" "V0290-001-NO-SUBMIT"
  require_file_contains "$file" "GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL"
  require_file_contains "$file" "V0290-002-PRODUCTION-SHADOW-CONFIGURATION"
  require_file_contains "$file" "V0290-002-NO-SECRET-CONFIGURATION"
  require_file_contains "$file" "V0290-002-MISMATCH-FAILS-CLOSED"
  require_file_contains "$file" "GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION"
  require_file_contains "$file" "V0290-003-CREDENTIAL-REFERENCE-ONLY"
  require_file_contains "$file" "V0290-003-OPERATOR-APPROVAL-REQUIRED"
  require_file_contains "$file" "V0290-003-SECRET-VALUE-NOT-PERSISTED"
  require_file_contains "$file" "GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT"
  require_file_contains "$file" "V0290-004-ENDPOINT-ALLOWLIST-READONLY"
  require_file_contains "$file" "V0290-004-MUTATION-ENDPOINTS-BLOCKED"
  require_file_contains "$file" "GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES"
  require_file_contains "$file" "V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES"
  require_file_contains "$file" "V0290-005-STALE-MISSING-INPUTS-BLOCKED"
  require_file_contains "$file" "GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE"
  require_file_contains "$file" "V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE"
  require_file_contains "$file" "V0290-006-NO-BROKER-FILL-INTERPRETATION"
  require_file_contains "$file" "GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL"
  require_file_contains "$file" "V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL"
  require_file_contains "$file" "V0290-007-NO-BROKER-SIDE-EFFECT"
  require_file_contains "$file" "GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE"
  require_file_contains "$file" "V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE"
  require_file_contains "$file" "V0290-008-NO-TRADING-CONTROLS"
  require_file_contains "$file" "GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0290-009-AGGREGATE-VALIDATION"
  require_file_contains "$file" "V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX"
  require_file_contains "$file" "GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0290-010-STAGE-AUDIT-RELEASE-DOCS"
  require_file_contains "$file" "V0290-010-NO-PRODUCTION-CUTOVER"
done

for file in "$SOURCE" "$DASHBOARD" "$AUDIT" "$NOTES" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$ROADMAP" "$README" "$GOAL" "$BLUEPRINT" "$VERIFICATION"; do
  require_file_contains "$file" "productionTradingEnabledByDefault=false"
  require_file_contains "$file" "productionCutoverAuthorized=false"
  require_file_contains "$file" "productionSecretAutoReadEnabled=false"
  require_file_contains "$file" "automaticBrokerConnectionEnabled=false"
  require_file_contains "$file" "productionSubmitCancelReplaceEnabled=false"
  require_file_contains "$file" "noSubmitTransportMode=true"
  require_file_contains "$file" "shadowOnly=true"
  require_file_contains "$file" "evidenceComplete=true"
  require_file_contains "$file" "boundaryHeld=true"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION" "$NOTES"; do
  reject_file_contains "$file" "v0.29.0 production cutover authorized"
  reject_file_contains "$file" "production trading enabled by default"
  reject_file_contains "$file" "automatic broker connection enabled"
  reject_file_contains "$file" "OKX active runtime enabled"
  reject_file_contains "$file" "Dashboard trading controls enabled"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.29.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.29.0.sh"
require_file_contains "$TESTS" "testGH1447To1456ReleaseV0290ProductionDryRunShadowAcceptance"
require_file_contains "$AUDIT" "Linux checks and macOS Dashboard smoke are pre-publication requirements"
require_file_contains "$NOTES" "The construction closeout PR itself does not create the v0.29.0 tag or GitHub Release"

printf 'MTPRO v0.29.0 production dry-run shadow acceptance checks passed.\n'
