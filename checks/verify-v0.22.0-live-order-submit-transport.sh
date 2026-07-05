#!/usr/bin/env bash
set -euo pipefail

# GH-1313-VERIFY-V0220-LIVE-ORDER-SUBMIT-TRANSPORT
# TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT
# V0220-005-BLOCKED-BY-GH1312
# V0220-005-BINANCE-SPOT-ONE-SHOT-SUBMIT
# V0220-005-ALLOWLISTED-SYMBOL-NOTIONAL-SIDE-TIF
# V0220-005-COMMAND-RISK-KILL-NOTRADE-EXECUTION-OMS-GATES
# V0220-005-REDACTED-EXCHANGE-ACK-EVIDENCE
# V0220-005-SINGLE-APPROVED-ORDER-PER-RUN
# V0220-005-FAIL-CLOSED-LIMIT-RISK-KILL-NOTRADE-TRANSPORT
# V0220-005-NO-FUTURES-OKX
# V0220-005-NO-DASHBOARD-TRADING-CONTROLS
# V0220-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.0 live order submit transport guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.0 live order submit transport guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

CONTRACT_SOURCE="Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryOneShotSubmitTransport.swift"
CONTRACT_DOC="docs/contracts/release-v0.22.0-live-order-submit-transport.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1313ReleaseV0220LiveOrderSubmitTransport

for file in \
  "$CONTRACT_SOURCE" \
  "$CONTRACT_DOC" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1313-VERIFY-V0220-LIVE-ORDER-SUBMIT-TRANSPORT"
  require_file_contains "$file" "TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT"
  require_file_contains "$file" "V0220-005-BLOCKED-BY-GH1312"
  require_file_contains "$file" "V0220-005-BINANCE-SPOT-ONE-SHOT-SUBMIT"
  require_file_contains "$file" "V0220-005-ALLOWLISTED-SYMBOL-NOTIONAL-SIDE-TIF"
  require_file_contains "$file" "V0220-005-COMMAND-RISK-KILL-NOTRADE-EXECUTION-OMS-GATES"
  require_file_contains "$file" "V0220-005-REDACTED-EXCHANGE-ACK-EVIDENCE"
  require_file_contains "$file" "V0220-005-SINGLE-APPROVED-ORDER-PER-RUN"
  require_file_contains "$file" "V0220-005-FAIL-CLOSED-LIMIT-RISK-KILL-NOTRADE-TRANSPORT"
  require_file_contains "$file" "V0220-005-NO-FUTURES-OKX"
  require_file_contains "$file" "V0220-005-NO-DASHBOARD-TRADING-CONTROLS"
  require_file_contains "$file" "V0220-005-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight"
require_file_contains "$CONTRACT_SOURCE" "ReleaseV0210ControlledSpotCanarySubmitPathEvidence"
require_file_contains "$CONTRACT_SOURCE" "requiredSymbol = \"BTCUSDT\""
require_file_contains "$CONTRACT_SOURCE" "requiredSide = \"BUY\""
require_file_contains "$CONTRACT_SOURCE" "requiredOrderType = \"LIMIT\""
require_file_contains "$CONTRACT_SOURCE" "requiredTimeInForce = \"GTC\""
require_file_contains "$CONTRACT_SOURCE" "requiredMaxNotionalMinorUnits = 500"
require_file_contains "$CONTRACT_SOURCE" "requiredMaxQuantityBaseMinorUnits = 50_000"
require_file_contains "$CONTRACT_SOURCE" "signedOrderSubmitTransportCreated"
require_file_contains "$CONTRACT_SOURCE" "redactedExchangeAckEnvelope"
require_file_contains "$CONTRACT_SOURCE" "riskRejectedObservation"
require_file_contains "$CONTRACT_SOURCE" "killSwitchRejectedObservation"
require_file_contains "$CONTRACT_SOURCE" "noTradeRejectedObservation"
require_file_contains "$CONTRACT_SOURCE" "duplicateRejectedObservation"
require_file_contains "$CONTRACT_SOURCE" "transportFailureObservation"
require_file_contains "$CONTRACT_DOC" "one allowlisted Binance Spot live canary submit transport"
require_file_contains "$CONTRACT_DOC" "Redacted request evidence and redacted exchange ack evidence"
require_file_contains "$README" "v0.22.0 live order submit transport"
require_file_contains "$READINESS" "Release v0.22.0 live order submit transport anchor"
require_file_contains "$PLAN" "GH-1313 Release v0.22.0 Live Order Submit Transport"
require_file_contains "$MATRIX" "TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT"
require_file_contains "$VERIFICATION" "GH-1313 v0.22.0 Live Order Submit Transport"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.0-live-order-submit-transport.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.0-live-order-submit-transport.sh"
require_file_contains "$TESTS" "testGH1313ReleaseV0220LiveOrderSubmitTransport"

for file in "$CONTRACT_DOC" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "rawRequestPayloadPersisted=true"
  reject_file_contains "$file" "rawExchangeAckPersisted=true"
  reject_file_contains "$file" "rawCredentialValuePersisted=true"
  reject_file_contains "$file" "signaturePersisted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "Futures live execution started"
  reject_file_contains "$file" "OKX active implementation started"
  reject_file_contains "$file" "Dashboard trading button enabled"
done

echo "MTPRO release v0.22.0 live order submit transport verification passed."
