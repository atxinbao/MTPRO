#!/usr/bin/env bash
set -euo pipefail

# GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT
# GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE
# GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST
# GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES
# GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK
# GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES
# GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION
# GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE
# GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE
# GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE
# V0310-001-NO-DEFAULT-TRADING-CONTRACT
# V0310-002-CREDENTIAL-APPROVAL-GATE
# V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST
# V0310-004-CAPITAL-RISK-STALE-INPUT-GATES
# V0310-005-MANUAL-APPROVAL-RUN-LOCK
# V0310-006-KILL-NOTRADE-ROLLBACK-GATES
# V0310-007-SIGNED-READONLY-NO-MUTATION
# V0310-008-IMMUTABLE-AUDIT-BUNDLE
# V0310-009-READONLY-STATUS-SURFACE
# V0310-010-STAGE-AUDIT-RELEASE-DOCS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.31.0 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.31.0 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH1487To1496ReleaseV0310ControlledProductionEnablementGate

CLI_STATUS="$(swift run mtpro controlled-production-enablement status)"
for expected in \
  "release=v0.31.0" \
  "decision=blocked" \
  "products=spot,usdsPerpetual" \
  "productionTradingEnabledByDefault=false" \
  "productionCutoverAuthorized=false" \
  "submitCancelReplaceEnabled=false" \
  "boundaryHeld=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_STATUS"; then
    printf 'release v0.31.0 validation failed: CLI status must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

CLI_GATES="$(swift run mtpro controlled-production-enablement gates)"
for expected in \
  "credentialGateHeld=true" \
  "endpointAllowlistHeld=true" \
  "capitalRiskGateHeld=true" \
  "manualApprovalRunLockHeld=true" \
  "safetyGateHeld=true" \
  "signedReadOnlyPreflightHeld=true" \
  "auditBundleHeld=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_GATES"; then
    printf 'release v0.31.0 validation failed: CLI gates must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

CLI_PREFLIGHT="$(swift run mtpro controlled-production-enablement preflight)"
for expected in \
  "endpoint=product:spot;family:spot-signed-read-only;scheme:https;host:api.binance.com;path:/api/v3/account" \
  "endpoint=product:usdsPerpetual;family:futures-signed-read-only;scheme:https;host:fapi.binance.com;path:/fapi/v3/account" \
  "rawPayloadPersisted:false" \
  "mutationEndpointTouched:false" \
  "submitCancelReplaceAttempted:false" \
  "brokerSideEffectObserved:false"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_PREFLIGHT"; then
    printf 'release v0.31.0 validation failed: CLI preflight must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

CLI_AUDIT="$(swift run mtpro controlled-production-enablement audit)"
for expected in \
  "bundleID=v0310-audit-bundle-controlled-production-enablement-readiness" \
  "artifactCount=8" \
  "sha256Manifest=sha256:v0310-controlled-production-enablement-readiness" \
  "immutable=true" \
  "replayable=true" \
  "redactionChecked=true" \
  "decisionRecorded=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_AUDIT"; then
    printf 'release v0.31.0 validation failed: CLI audit must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

CLI_BOUNDARIES="$(swift run mtpro controlled-production-enablement boundaries)"
for expected in \
  "automaticSecretReadEnabled=false" \
  "automaticBrokerConnectionEnabled=false" \
  "productionSubmitCancelReplaceEnabled=false" \
  "dashboardTradingControlsEnabled=false" \
  "orderFormEnabled=false" \
  "liveCommandEnabled=false" \
  "orderMutationAuthorized=false" \
  "productionCutoverAuthorized=false"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_BOUNDARIES"; then
    printf 'release v0.31.0 validation failed: CLI boundaries must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0310ControlledProductionEnablementGate.swift" \
  "Sources/Dashboard/Report/ReleaseV0310DashboardCLIProductionEnablementStatusSurface.swift" \
  "Sources/MTPROCLI/main.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.31.0.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/audit/mtpro-release-v0.31.0-controlled-production-enablement-gate-stage-code-audit.md" \
  "docs/release/mtpro-release-v0.31.0-controlled-production-enablement-gate-notes.md" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/verification.md"; do
  for expected in \
    "GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT" \
    "GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE" \
    "GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST" \
    "GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES" \
    "GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK" \
    "GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES" \
    "GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION" \
    "GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE" \
    "GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE" \
    "GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS" \
    "TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE" \
    "V0310-001-NO-DEFAULT-TRADING-CONTRACT" \
    "V0310-002-CREDENTIAL-APPROVAL-GATE" \
    "V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST" \
    "V0310-004-CAPITAL-RISK-STALE-INPUT-GATES" \
    "V0310-005-MANUAL-APPROVAL-RUN-LOCK" \
    "V0310-006-KILL-NOTRADE-ROLLBACK-GATES" \
    "V0310-007-SIGNED-READONLY-NO-MUTATION" \
    "V0310-008-IMMUTABLE-AUDIT-BUNDLE" \
    "V0310-009-READONLY-STATUS-SURFACE" \
    "V0310-010-STAGE-AUDIT-RELEASE-DOCS"; do
    require_file_contains "$file" "$expected"
  done
done

for file in \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md" \
  "docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/verification.md" \
  "docs/release/mtpro-release-v0.31.0-controlled-production-enablement-gate-notes.md"; do
  for expected in \
    "decision=blocked" \
    "productionTradingEnabledByDefault=false" \
    "productionCutoverAuthorized=false" \
    "automaticSecretReadEnabled=false" \
    "automaticBrokerConnectionEnabled=false" \
    "productionSubmitCancelReplaceEnabled=false"; do
    require_file_contains "$file" "$expected"
  done
  for forbidden in \
    "production trading enabled by default" \
    "production cutover authorized" \
    "automatic broker connection enabled" \
    "real order mutation enabled"; do
    reject_file_contains "$file" "$forbidden"
  done
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.31.0.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.31.0.sh"
require_file_contains "Sources/MTPROCLI/main.swift" "ReleaseV0310ControlledProductionEnablementGate.cliCommand"
require_file_contains "Sources/MTPROCLI/main.swift" "ReleaseV0310ControlledProductionEnablementGate.commandLineOutput"

printf 'MTPRO v0.31.0 controlled production enablement gate checks passed.\n'
