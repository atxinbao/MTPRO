#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || {
    echo "verify-v0.32.0 failed: $file must contain: $expected" >&2
    exit 1
  }
}

# GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT
# GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE
# GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE
# GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL
# GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
# GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK
# GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP
# GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS
# GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE
# GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS
# V0320-001-CANARY-OPERATIONS-CONTRACT
# V0320-002-HUMAN-APPROVED-ENABLEMENT-BUNDLE
# V0320-003-STRICT-SIZE-CAP-FINAL-GATE
# V0320-004-SPOT-CANARY-SUBMIT-STATUS-CANCEL
# V0320-005-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
# V0320-006-OMS-RECONCILIATION-ROLLBACK
# V0320-007-KILL-NOTRADE-INCIDENT-STOP
# V0320-008-DASHBOARD-CLI-CANARY-STATUS
# V0320-009-AGGREGATE-VALIDATION-SUITE
# V0320-010-STAGE-AUDIT-RELEASE-DOCS

swift test --filter TargetGraphTests/testGH1508To1517ReleaseV0320ControlledProductionCanaryOperations

swift run mtpro controlled-production-canary status | grep -F "boundaryHeld=true"
swift run mtpro controlled-production-canary contract | grep -F "defaultProductionTradingEnabled=false"
swift run mtpro controlled-production-canary spot | grep -F "action:submit"
swift run mtpro controlled-production-canary futures | grep -F "product:usdsPerpetual"
swift run mtpro controlled-production-canary incident | grep -F "submitBlockedWhenSafetyFails=true"

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0320ControlledProductionCanaryOperations.swift \
  Sources/Dashboard/Report/ReleaseV0320DashboardCLICanaryStatusSurface.swift \
  Sources/MTPROCLI/main.swift \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  docs/audit/mtpro-release-v0.32.0-binance-controlled-production-canary-operations-stage-code-audit.md \
  docs/release/mtpro-release-v0.32.0-binance-controlled-production-canary-operations-notes.md \
  docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md \
  docs/validation/trading-validation-matrix.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/README.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md \
  docs/history/validation-pre-canonicalization-2026-07-20/verification.md; do
  require_contains "$file" "GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT"
  require_contains "$file" "GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE"
  require_contains "$file" "GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE"
  require_contains "$file" "GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL"
  require_contains "$file" "GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL"
  require_contains "$file" "GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK"
  require_contains "$file" "GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP"
  require_contains "$file" "GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS"
  require_contains "$file" "GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE"
  require_contains "$file" "GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS"
  require_contains "$file" "TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS"
done

echo "verify-v0.32.0 passed"
