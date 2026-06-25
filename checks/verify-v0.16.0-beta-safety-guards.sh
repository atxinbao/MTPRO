#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160BetaSafetyGuard.swift"
SUBMIT_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift"
CANCEL_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift"
STATUS_FLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift"
CONTRACT="docs/contracts/release-v0.16.0-beta-safety-guards-contract.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1110-VERIFY-V0160-BETA-SAFETY-GUARDS"
  "TVM-RELEASE-V0160-BETA-SAFETY-GUARDS"
  "V0160-010-MAX-QUANTITY-GUARD"
  "V0160-010-MAX-ORDERS-PER-RUN-GUARD"
  "V0160-010-COOLDOWN-GUARD"
  "V0160-010-SYMBOL-ALLOWLIST-GUARD"
  "V0160-010-TESTNET-ONLY-CREDENTIAL-PROFILE"
  "V0160-010-TRANSPORT-PRECHECK-FAILS-CLOSED"
  "V0160-010-REDACTED-SAFETY-EVIDENCE"
  "V0160-010-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$CONTRACT" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "$SOURCE" "betaSafetyGuard=ReleaseV0160BetaSafetyGuard"
require_file_contains "$SOURCE" "maxQuantityGuardEnabled=true"
require_file_contains "$SOURCE" "maxOrdersPerRunGuardEnabled=true"
require_file_contains "$SOURCE" "cooldownGuardEnabled=true"
require_file_contains "$SOURCE" "symbolAllowlistGuardEnabled=true"
require_file_contains "$SOURCE" "testnetOnlyCredentialProfileGuardEnabled=true"
require_file_contains "$SOURCE" "transportPrecheckFailsClosed=true"
require_file_contains "$SOURCE" "redactedSafetyEvidence=true"
require_file_contains "$SOURCE" "productionTradingEnabledByDefault=false"
require_file_contains "$SOURCE" "productionEndpointConnected=false"
require_file_contains "$SOURCE" "productionOrderSubmitted=false"
require_file_contains "$SUBMIT_FLOW" "ReleaseV0160BetaSafetyGuard.validate(command: command)"
require_file_contains "$CANCEL_FLOW" "ReleaseV0160BetaSafetyGuard.validate(command: command)"
require_file_contains "$STATUS_FLOW" "ReleaseV0160BetaSafetyGuard.validate(command: command)"
require_file_contains "$TARGET_TESTS" "testGH1110ReleaseV0160BetaSafetyGuardsFailClosedBeforeTransport"
require_file_contains "README.md" "#1110 beta safety guards closed / done"
require_file_contains "GOAL.md" "#1110 beta safety guards closed / done"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.0-beta-safety-guards.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-beta-safety-guards.sh"

swift test --filter TargetGraphTests/testGH1110ReleaseV0160BetaSafetyGuardsFailClosedBeforeTransport

echo "MTPRO release v0.16.0 beta safety guards verification passed."
