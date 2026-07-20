#!/usr/bin/env bash
set -euo pipefail

# GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT
# TVM-RELEASE-V0150-CONTRACT-PREFLIGHT
# V0150-001-RELEASE-CONTRACT
# V0150-001-V0141-PREFLIGHT-GATE
# V0150-001-BINANCE-SPOT-TESTNET-ONLY
# V0150-001-SIGNED-TESTNET-BOUNDARY
# V0150-001-PRODUCTION-FAIL-CLOSED
# V0150-001-CHILDREN-BACKLOG-NON-EXECUTABLE
# V0150-001-NO-PRODUCTION-CUTOVER
# V0150-001-NO-DASHBOARD-COMMAND-SURFACE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 contract / preflight guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.15.0 contract / preflight guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.15.0-real-binance-spot-testnet-execution-mvp-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1066ReleaseV0150ContractAndV0141PreflightGate

for anchor in \
  "GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT" \
  "TVM-RELEASE-V0150-CONTRACT-PREFLIGHT" \
  "V0150-001-RELEASE-CONTRACT" \
  "V0150-001-V0141-PREFLIGHT-GATE" \
  "V0150-001-BINANCE-SPOT-TESTNET-ONLY" \
  "V0150-001-SIGNED-TESTNET-BOUNDARY" \
  "V0150-001-PRODUCTION-FAIL-CLOSED" \
  "V0150-001-CHILDREN-BACKLOG-NON-EXECUTABLE" \
  "V0150-001-NO-PRODUCTION-CUTOVER" \
  "V0150-001-NO-DASHBOARD-COMMAND-SURFACE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for carried_fact in \
  "#1059" "#1060" "#1061" "#1062" "#1063" "#1064" \
  "#1077" "#1078" "#1079" "#1080" "#1081" "#1082" \
  "https://github.com/atxinbao/MTPRO/releases/tag/v0.14.1" \
  "92cd3d5cf00e85c43ef99d9f204cca97347c79ff"; do
  require_file_contains "$CONTRACT" "$carried_fact"
  require_file_contains "$LATEST" "$carried_fact"
done

for child_issue in "#1067" "#1068" "#1069" "#1070" "#1071" "#1072" "#1073" "#1074" "#1075" "#1076"; do
  require_file_contains "$CONTRACT" "$child_issue"
done

for required_string in \
  "activeVenue == Binance" \
  "v0150ExecutionProductScope == Binance Spot Testnet only" \
  "productionTradingEnabledByDefault=false" \
  "operatorConfirmationRequired=true" \
  "testnetEndpointAllowlistOnly=true" \
  "productionEndpointConnected=false" \
  "productionSecretRead=false" \
  "productionOrderSubmitted=false" \
  "dashboardCommandSurfaceEnabled=false" \
  "V150 children remain backlog / non-executable"; do
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$README" "MTPRO Release v0.15.0 Real Binance Testnet Execution MVP"
require_file_contains "$GOAL" "MTPRO Release v0.15.0 Real Binance Testnet Execution MVP"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.15.0 Real Binance Testnet Execution MVP"
require_file_contains "$ROADMAP" "GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-contract-preflight.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-contract-preflight.sh"
require_file_contains "$READINESS" "Release v0.15.0 contract / v0.14.1 preflight gate anchor"
require_file_contains "$LATEST" "v0.15.0 contract / v0.14.1 preflight gate"
require_file_contains "$PLAN" "bash checks/verify-v0.15.0-contract-preflight.sh"
require_file_contains "$MATRIX" "bash checks/verify-v0.15.0-contract-preflight.sh"
require_file_contains "$TESTS" "testGH1066ReleaseV0150ContractAndV0141PreflightGate"

for file in "$CONTRACT" "$LATEST" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP"; do
  reject_file_contains "$file" "activeProductType == USDⓈ-M Perpetual"
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "dashboardCommandSurfaceEnabled=true"
  reject_file_contains "$file" "orderFormEnabled=true"
  reject_file_contains "$file" "v0.15.0 production cutover"
done

printf 'MTPRO release v0.15.0 contract / preflight verification passed.\n'
