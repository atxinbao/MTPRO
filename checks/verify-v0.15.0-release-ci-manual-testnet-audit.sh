#!/usr/bin/env bash
set -euo pipefail

# GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT
# TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT
# V0150-011-STAGE-CODE-AUDIT
# V0150-011-MANUAL-TESTNET-WORKFLOW
# V0150-011-RELEASE-NOTES
# V0150-011-VALIDATION-SUITE
# V0150-011-PRODUCTION-DISABLED-PROOF
# V0150-011-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 final audit / manual workflow guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 final audit / manual workflow guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-stage-code-audit.md"
RELEASE_NOTES="docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md"
RUNBOOK="docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1076ReleaseV0150FinalAuditManualWorkflowCloseout

for anchor in \
  "GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT" \
  "TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT" \
  "V0150-011-STAGE-CODE-AUDIT" \
  "V0150-011-MANUAL-TESTNET-WORKFLOW" \
  "V0150-011-RELEASE-NOTES" \
  "V0150-011-VALIDATION-SUITE" \
  "V0150-011-PRODUCTION-DISABLED-PROOF" \
  "V0150-011-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$RELEASE_NOTES" "$anchor"
  require_file_contains "$RUNBOOK" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for carried_anchor in \
  "GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT" \
  "GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST" \
  "GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME" \
  "GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG" \
  "GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME" \
  "GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME" \
  "GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION" \
  "GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW" \
  "GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS" \
  "GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT"; do
  require_file_contains "$AUDIT" "$carried_anchor"
  require_file_contains "$RELEASE_NOTES" "$carried_anchor"
done

for completed_issue in "#1066" "#1067" "#1068" "#1069" "#1070" "#1071" "#1072" "#1073" "#1074" "#1075" "#1076"; do
  require_file_contains "$AUDIT" "$completed_issue"
  require_file_contains "$RELEASE_NOTES" "$completed_issue"
done

for merged_pr in "#1083" "#1084" "#1085" "#1086" "#1087" "#1088" "#1089" "#1090" "#1091" "#1092"; do
  require_file_contains "$AUDIT" "$merged_pr"
done

for merge_commit in \
  "5f846917e1ae8e347771b8e2061fd0135f67f82f" \
  "a4ac613a28edea9120cdaf11dde3cf854f7fdd62" \
  "41e3f79248e25b4cf541f01ecba4b45657ab94d8" \
  "7baf3ab12a5ee62eee1df7677551dc264f435481" \
  "db538197d1fe4ebdd49714f25797bc614c76b219" \
  "0016a42c9c715953b0da7a4ca6990636767931ca" \
  "288e535da9b947c8d1415095209f621c92ad8a34" \
  "0189d9774fc274bc0b46bef34e2f1d28338f943a" \
  "85d61f1d6ca22c18e00bdf1efdb4f52154fae73b" \
  "79367ddc15b8f66cdd9a3da97e450512944dacd6"; do
  require_file_contains "$AUDIT" "$merge_commit"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh"
require_file_contains "$AUDIT" "v0.15.0 public release publication 需要 Human 显式触发独立 Release Publication Gate"
require_file_contains "$RELEASE_NOTES" "v0.15.0 是 Real Binance Testnet Execution MVP construction closeout"
require_file_contains "$RUNBOOK" "This runbook tells an operator how to review and rehearse the v0.15.0 Binance Spot Testnet execution MVP locally"
require_file_contains "$RUNBOOK" "Stop and do not proceed"
require_file_contains "$LATEST" "v0.15.0 release CI / manual testnet workflow / audit evidence"
require_file_contains "$PLAN" "GH-1076 Release v0.15.0 Release CI + Manual Testnet Workflow + Audit Evidence"
require_file_contains "$MATRIX" "GH-1076 Release v0.15.0 Release CI + Manual Testnet Workflow + Audit Evidence"

for file in "$AUDIT" "$RELEASE_NOTES" "$RUNBOOK" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretAutoRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "dashboardCommandSurfaceEnabled=true"
done

printf 'MTPRO release v0.15.0 final audit / manual workflow verification passed.\n'
