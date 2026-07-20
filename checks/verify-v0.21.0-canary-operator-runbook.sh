#!/usr/bin/env bash
set -euo pipefail

# GH-1284-VERIFY-V0210-CANARY-OPERATOR-RUNBOOK
# TVM-RELEASE-V0210-CANARY-OPERATOR-RUNBOOK
# V0210-012-CANARY-OPERATOR-RUNBOOK
# V0210-012-START-OBSERVE-CANCEL-ROLLBACK
# V0210-012-INCIDENT-STOP-CONDITIONS
# V0210-012-EVIDENCE-COLLECTION
# V0210-012-NO-PRODUCTION-CUTOVER
# V0210-012-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 canary operator runbook failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 canary operator runbook failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

RUNBOOK="docs/operators/release-v0.21.0-binance-spot-controlled-canary-runbook.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="verification.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$RUNBOOK" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1284-VERIFY-V0210-CANARY-OPERATOR-RUNBOOK"
  require_file_contains "$file" "TVM-RELEASE-V0210-CANARY-OPERATOR-RUNBOOK"
  require_file_contains "$file" "V0210-012-CANARY-OPERATOR-RUNBOOK"
  require_file_contains "$file" "V0210-012-START-OBSERVE-CANCEL-ROLLBACK"
  require_file_contains "$file" "V0210-012-INCIDENT-STOP-CONDITIONS"
  require_file_contains "$file" "V0210-012-EVIDENCE-COLLECTION"
  require_file_contains "$file" "V0210-012-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0210-012-NO-TAG-OR-RELEASE-PUBLICATION"
done

for expected in \
  "Operator Start Procedure" \
  "Observe Procedure" \
  "Cancel Procedure" \
  "Rollback Procedure" \
  "Incident Stop Conditions" \
  "Evidence Collection" \
  "swift run mtpro canary-status status" \
  "swift run mtpro canary-status events" \
  "swift run mtpro canary-status reconciliation" \
  "productionTradingEnabledByDefault=false" \
  "productionCutoverAuthorized=false" \
  "submitCancelReplaceEnabled=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "rawOrderIDVisible=false" \
  "rawBrokerPayloadVisible=false" \
  "realOrderSent=false" \
  "boundaryHeld=true"; do
  require_file_contains "$RUNBOOK" "$expected"
done

require_file_contains "$READINESS" "Release v0.21.0 canary operator runbook anchor"
require_file_contains "$PLAN" "GH-1284 Release v0.21.0 Canary Operator Runbook"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-CANARY-OPERATOR-RUNBOOK"
require_file_contains "$LATEST" "v0.21.0 canary operator runbook"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-canary-operator-runbook.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-canary-operator-runbook.sh"

for file in "$RUNBOOK" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "dashboardTradingButtonVisible=true"
  reject_file_contains "$file" "tradingButtonVisible=true"
  reject_file_contains "$file" "orderFormVisible=true"
  reject_file_contains "$file" "liveCommandVisible=true"
  reject_file_contains "$file" "rawOrderIDVisible=true"
  reject_file_contains "$file" "rawBrokerPayloadVisible=true"
  reject_file_contains "$file" "realOrderSent=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 canary operator runbook verification passed."
