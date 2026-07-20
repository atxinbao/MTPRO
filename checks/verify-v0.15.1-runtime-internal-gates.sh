#!/usr/bin/env bash
set -euo pipefail

# GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES
# TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES
# V0151-005-RISKENGINE-GATE-IN-RUNTIME
# V0151-005-KILL-SWITCH-GATE-IN-RUNTIME
# V0151-005-NO-TRADE-GATE-IN-RUNTIME
# V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME
# V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED
# V0151-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 runtime internal gate guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 runtime internal gate guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GATE="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetRuntimeInternalGate.swift"
SUBMIT="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift"
CANCEL="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift"
CANCEL_REPLACE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift"
CLI_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"

for anchor in \
  "GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES" \
  "TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES" \
  "V0151-005-RISKENGINE-GATE-IN-RUNTIME" \
  "V0151-005-KILL-SWITCH-GATE-IN-RUNTIME" \
  "V0151-005-NO-TRADE-GATE-IN-RUNTIME" \
  "V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME" \
  "V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED" \
  "V0151-005-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$GATE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$0" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$README" "$anchor"
  require_file_contains "$GOAL" "$anchor"
  require_file_contains "$BLUEPRINT" "$anchor"
  require_file_contains "$ROADMAP" "$anchor"
done

for required in \
  "ReleaseV0151BinanceSpotTestnetRuntimeInternalGate" \
  "ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker" \
  "runtimeInternalGateRequired=true" \
  "riskEngineGateInsideRuntime=true" \
  "killSwitchGateInsideRuntime=true" \
  "noTradeGateInsideRuntime=true" \
  "operatorConfirmationGateInsideRuntime=true" \
  "transportNotInvokedWhenBlocked=true" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$GATE" "$required"
  require_file_contains "$0" "$required"
done

for blocker in \
  "risk-engine-rejected" \
  "kill-switch-active" \
  "no-trade-active" \
  "operator-confirmation-missing"; do
  require_file_contains "$GATE" "$blocker"
  require_file_contains "$TESTS" "$blocker"
done

for source in "$SUBMIT" "$CANCEL" "$CANCEL_REPLACE"; do
  require_file_contains "$source" "runtimeGate.requireTransportAllowed"
  require_file_contains "$source" "ReleaseV0151BinanceSpotTestnetRuntimeInternalGate"
done

require_file_contains "$CLI_FLOW" "ReleaseV0151BinanceSpotTestnetRuntimeInternalGate.allowedSubmit"
require_file_contains "$CLI_FLOW" "ReleaseV0151BinanceSpotTestnetRuntimeInternalGate.allowedCancel"
require_file_contains "$CLI_FLOW" "ReleaseV0151BinanceSpotTestnetRuntimeInternalGate.allowedCancelReplace"
require_file_contains "$CANCEL_REPLACE" "runtimeGate.derivedAllowedGate"
require_file_contains "$TESTS" "testGH1098ReleaseV0151RuntimeInternalGatesBlockTransportBeforeInvocation"
require_file_contains "$TESTS" "blockedRiskGate"
require_file_contains "$TESTS" "missingConfirmationGate"
require_file_contains "$TESTS" "active kill switch must prevent cancel transport invocation"
require_file_contains "$TESTS" "active no-trade state must prevent cancel-replace transport invocation"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-runtime-internal-gates.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-runtime-internal-gates.sh"

require_file_contains "$README" "#1098 runtime internal gate closed / done"
require_file_contains "$README" "#1099 deterministic client order identity chain closed / done"
require_file_contains "$GOAL" "#1098 runtime internal gate closed / done"
require_file_contains "$GOAL" "#1099 deterministic client order identity chain closed / done"
require_file_contains "$BLUEPRINT" "runtime internal gate"
require_file_contains "$ROADMAP" "runtime internal gate"
require_file_absent "$README" "current issue \`#1097\`"
require_file_absent "$GOAL" "#1097 CLI guarded runtime wiring is current WIP=1"
require_file_absent "$README" "current issue \`#1098\`"
require_file_absent "$GOAL" "#1098 runtime internal gate is current WIP=1"
require_file_absent "$README" "current issue \`#1099\`"
require_file_absent "$GOAL" "#1099 deterministic client order identity chain is current WIP=1"
require_file_absent "$BLUEPRINT" "#1097 当前 WIP=1"
require_file_absent "$ROADMAP" "#1097 当前 WIP=1"

swift test --filter TargetGraphTests/testGH1098ReleaseV0151RuntimeInternalGatesBlockTransportBeforeInvocation

echo "MTPRO release v0.15.1 runtime internal gate verification passed."
