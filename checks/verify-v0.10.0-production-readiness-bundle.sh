#!/usr/bin/env bash
set -euo pipefail

# GH-887-VERIFY-V0100-PRODUCTION-READINESS-BUNDLE
# TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE

fail() {
  echo "release v0.10.0 production readiness audit bundle verification failed: $*" >&2
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

CONTRACT="docs/contracts/release-v0.10.0-production-readiness-audit-bundle-contract.md"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0100ProductionReadinessAuditBundle.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"

for path in "$CONTRACT" "$SOURCE" "$TESTS" "$PLAN" "$MATRIX" "$READINESS" "$LATEST"; do
  require_file "$path"
done

for anchor in \
  "V0100-010-PRODUCTION-READINESS-AUDIT-BUNDLE" \
  "V0100-010-PRODUCTION-READINESS-BUNDLE-JSON" \
  "V0100-010-BUNDLE-SHA256-CHECKSUM" \
  "V0100-010-ENVIRONMENT-SECRET-ENDPOINT-EVIDENCE" \
  "V0100-010-CAPITAL-KILL-SWITCH-NO-TRADE-EVIDENCE" \
  "V0100-010-COMMAND-SURFACE-SHADOW-DRY-RUN-EVIDENCE" \
  "V0100-010-RISK-POLICY-SNAPSHOT" \
  "V0100-010-PORTFOLIO-RECONCILIATION-SNAPSHOT" \
  "V0100-010-REDACTION-PROOF-TRUE" \
  "V0100-010-NO-SECRET-VALUE-TRUE" \
  "V0100-010-NO-ORDER-PAYLOAD-TRUE" \
  "V0100-010-PRODUCTION-CAPABILITIES-DISABLED" \
  "GH-887-VERIFY-V0100-PRODUCTION-READINESS-BUNDLE" \
  "TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$0" "$anchor"
done

for exact in \
  "production_readiness_bundle.json" \
  "bundleChecksum=sha256:" \
  "redaction_proof=true" \
  "redactionProof=true" \
  "no_secret_value=true" \
  "noSecretValue=true" \
  "no_order_payload=true" \
  "noOrderPayload=true" \
  "riskPolicySnapshotIncluded=true" \
  "portfolioReconciliationSnapshotIncluded=true" \
  "production_cutover_blocked=true" \
  "productionCutoverBlocked=true" \
  "productionCutoverUnblocked=false" \
  "cutoverAuthorized=false" \
  "productionEndpointConnectionEnabled=false" \
  "productionBrokerConnectionEnabled=false" \
  "productionSecretValueRead=false" \
  "testnetOrderSubmissionEnabled=false" \
  "productionOrderSubmissionEnabled=false" \
  "orderPayloadCreated=false" \
  "brokerCommandCreated=false" \
  "productionOMSRuntimeEnabled=false" \
  "tradingButtonVisible=false" \
  "orderFormVisible=false" \
  "liveCommandEnabled=false" \
  "productionCommandEnabled=false" \
  "readinessApprovalConvertedToTradingPermission=false" \
  "bundleBypassEnabled=false"; do
  require_file_contains "$CONTRACT" "$exact"
done

for evidence in \
  "production_environment_profile.json" \
  "secret_readiness.json" \
  "endpoint_policy_readiness.json" \
  "capital_exposure_limits.json" \
  "kill_switch_readiness.json" \
  "no_trade_readiness.json" \
  "dashboard_production_surface_disabled.json" \
  "cli_production_surface_disabled.json" \
  "shadow_dry_run_parity.json" \
  "risk_policy_snapshot.json" \
  "portfolio_reconciliation_snapshot.json"; do
  require_file_contains "$CONTRACT" "$evidence"
  require_file_contains "$SOURCE" "$evidence"
done

require_file_contains "$SOURCE" "ReleaseV0100ProductionReadinessAuditBundle"
require_file_contains "$SOURCE" "ReleaseV0100ProductionReadinessBundleArtifact"
require_file_contains "$SOURCE" "ReleaseV0100ProductionReadinessBundleEntry"
require_file_contains "$SOURCE" "ReleaseV0100ProductionReadinessBundleChecksum"
require_file_contains "$TESTS" "testGH887ProductionReadinessAuditBundleAggregatesRedactedNoOrderEvidence"
require_file_contains "$PLAN" "GH-887 Release v0.10.0 Production Readiness Audit Bundle Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE"
require_file_contains "$READINESS" "Release v0.10.0 production readiness audit bundle anchor"
require_file_contains "$LATEST" "\`#887\` 定义 ProductionReadinessAuditBundle reference-only contract"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-production-readiness-bundle.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.0-production-readiness-bundle.sh"

for forbidden in \
  "production_cutover_blocked=false" \
  "productionCutoverBlocked=false" \
  "productionCutoverUnblocked=true" \
  "cutoverAuthorized=true" \
  "redaction_proof=false" \
  "redactionProof=false" \
  "no_secret_value=false" \
  "noSecretValue=false" \
  "no_order_payload=false" \
  "noOrderPayload=false" \
  "testnetOrderSubmissionEnabled=true" \
  "productionOrderSubmissionEnabled=true" \
  "productionEndpointConnectionEnabled=true" \
  "productionBrokerConnectionEnabled=true" \
  "productionSecretValueRead=true" \
  "orderPayloadCreated=true" \
  "brokerCommandCreated=true" \
  "productionOMSRuntimeEnabled=true" \
  "tradingButtonVisible=true" \
  "orderFormVisible=true" \
  "liveCommandEnabled=true" \
  "productionCommandEnabled=true" \
  "readinessApprovalConvertedToTradingPermission=true" \
  "bundleBypassEnabled=true" \
  "containsBrokerOrAccountResponse=true" \
  "producedByEndpointConnection=true" \
  "containsOrderPayload=true" \
  "api.binance.com" \
  "fapi.binance.com"; do
  require_file_not_contains "$CONTRACT" "$forbidden"
done

echo "MTPRO release v0.10.0 production readiness audit bundle verification passed."
