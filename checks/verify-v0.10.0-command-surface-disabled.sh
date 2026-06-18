#!/usr/bin/env bash
set -euo pipefail

# GH-885-VERIFY-V0100-COMMAND-SURFACE-DISABLED
# TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED

fail() {
  echo "release v0.10.0 command surface disabled proof verification failed: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_file_contains() {
  local path="$1"
  local expected="$2"
  grep -Fq "$expected" "$path" || fail "$path must contain: $expected"
}

require_file_not_contains() {
  local path="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$path"; then
    fail "$path must not contain: $forbidden"
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-command-surface-disabled-proof-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100ProductionCommandSurfaceDisabledProof.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"

for path in "$CONTRACT" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-008-PRODUCTION-COMMAND-SURFACE-DISABLED-PROOF" \
  "V0100-008-DASHBOARD-PRODUCTION-SURFACE-DISABLED-JSON" \
  "V0100-008-CLI-PRODUCTION-SURFACE-DISABLED-JSON" \
  "V0100-008-TRADING-BUTTON-VISIBLE-FALSE" \
  "V0100-008-ORDER-FORM-VISIBLE-FALSE" \
  "V0100-008-LIVE-COMMAND-ENABLED-FALSE" \
  "V0100-008-SUBMIT-CANCEL-REPLACE-COMMANDS-DISABLED" \
  "V0100-008-PRODUCTION-COMMAND-ENABLED-FALSE" \
  "V0100-008-PRODUCTION-CUTOVER-BLOCKED" \
  "V0100-008-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-885-VERIFY-V0100-COMMAND-SURFACE-DISABLED" \
  "TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for exact in \
  "dashboard_production_surface_disabled.json" \
  "cli_production_surface_disabled.json" \
  "dashboardProductionSurfaceDisabled=true" \
  "cliProductionSurfaceDisabled=true" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandEnabled=false" \
  "submitCommandEnabled=false" \
  "cancelCommandEnabled=false" \
  "replaceCommandEnabled=false" \
  "productionCommandEnabled=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionOrderSubmissionEnabled=false" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverUnblocked=false" \
  "cutoverAuthorized=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "productionOMSRuntimeEnabled=false" \
  "commandBypassEnabled=false"; do
  require_file_contains "$CONTRACT" "$exact"
done

require_file_contains "$SOURCE" "ReleaseV0100ProductionCommandSurfaceDisabledProof"
require_file_contains "$SOURCE" "ReleaseV0100ProductionCommandSurfaceDisabledArtifact"
require_file_contains "$TESTS" "testGH885ProductionCommandSurfaceDisabledProofKeepsDashboardAndCLIReadOnly"
require_file_contains "$PLAN" "GH-885 Release v0.10.0 Production Command Surface Disabled Proof Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED"
require_file_contains "$READINESS" "Release v0.10.0 production command surface disabled proof anchor"
require_file_contains "$LATEST" "\`#885\` 定义 ProductionCommandSurfaceDisabledProof reference-only contract"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-command-surface-disabled.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-command-surface-disabled.sh"

for forbidden in \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "productionCutoverUnblocked=true" \
  "cutoverAuthorized=true" \
  "tradingButtonVisible=true" \
  "orderFormVisible=true" \
  "liveCommandEnabled=true" \
  "submitCommandEnabled=true" \
  "cancelCommandEnabled=true" \
  "replaceCommandEnabled=true" \
  "productionCommandEnabled=true" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "productionOMSRuntimeEnabled=true" \
  "commandBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "containsOrderPayload=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 command surface disabled proof verification passed."
