#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "docs/contracts/l4-live-production-command-contract.md"
require_file "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md"
require_file "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md"
require_file "docs/contracts/l4-production-cutover-no-default-real-trading-policy.md"
require_file "docs/contracts/production-cutover-credential-secret-policy-gate-contract.md"
require_file "docs/contracts/production-cutover-environment-isolation-gate-contract.md"
require_file "docs/contracts/production-cutover-broker-venue-capability-matrix-contract.md"
require_file "docs/contracts/production-cutover-manual-approval-operator-confirmation-gate-contract.md"
require_file "docs/contracts/production-cutover-incident-rollback-no-trade-gate-contract.md"
require_file "docs/contracts/production-cutover-capital-risk-limit-gate-contract.md"
require_file "docs/contracts/production-cutover-dry-run-shadow-no-default-trading-evidence-contract.md"
require_file "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md"
require_file "Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift"
require_file "Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift"
require_file "Sources/ExecutionClient/FutureGate/ProductionCutoverCredentialSecretPolicyGate.swift"
require_file "Sources/ExecutionClient/FutureGate/ProductionCutoverEnvironmentIsolationGate.swift"
require_file "Sources/ExecutionClient/FutureGate/ProductionCutoverManualApprovalGate.swift"
require_file "Sources/ExecutionClient/FutureGate/ProductionCutoverIncidentRollbackNoTradeGate.swift"
require_file "Sources/ExecutionClient/FutureGate/ProductionCutoverDryRunShadowNoDefaultTradingEvidence.swift"
require_file "Sources/ExecutionClient/BrokerCapabilityMatrix/ProductionCutoverBrokerVenueCapabilityMatrix.swift"
require_file "Sources/RiskEngine/LiveGate/ProductionCutoverCapitalRiskLimitGate.swift"
require_contains "docs/contracts/l4-live-production-command-contract.md" "GH-452-NO-DEFAULT-REAL-TRADING-POLICY"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-521-BINANCE-EMA-ACTIVE-SCOPE"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-521-TESTNET-DRY-RUN-FIRST-GATE"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-521-ACCEPTANCE-MATRIX"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-521-NO-DEFAULT-PRODUCTION-TRADING"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "GH-523-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "TVM-RELEASE-V010-BINANCE-EMA-RUNTIME"
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" 'active venue：`Binance`'
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" 'active concrete strategy：`EMA`'
require_contains "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md" "productionTradingEnabledByDefault == false"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V010-BINANCE-EMA-RUNTIME"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "GH-522-RELEASE-OWNERSHIP-AUTHORITY"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "GH-522-COMPATIBILITY-ENVELOPE-MATRIX"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "GH-522-DEFERRED-OWNERSHIP-REGISTER"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "GH-522-NO-PRODUCTION-AUTHORIZATION"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "productionTradingEnabledByDefault == false"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "nonBinanceVenueEnabled == false"
require_contains "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md" "nonEMAStrategyEnabled == false"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE"
require_contains "docs/validation/validation-plan.md" "GH-521 Release v0.1.0 Binance EMA Runtime Contract Validation"
require_contains "docs/validation/validation-plan.md" "GH-522 Release v0.1.0 Ownership Gap Retirement Validation"
require_contains "docs/validation/validation-plan.md" "GH-523 Release v0.1.0 Real Target Smoke Coverage Validation"
require_contains "docs/domain/context.md" "GH-521 Release v0.1.0 Binance EMA Runtime Terms"
require_contains "docs/domain/context.md" "GH-522 Release v0.1.0 Ownership Gap Terms"
require_contains "docs/domain/context.md" "GH-523 Release v0.1.0 Real Target Smoke Terms"
require_contains "docs/automation/automation-readiness.md" "Release v0.1.0 Binance EMA runtime contract anchor"
require_contains "docs/automation/automation-readiness.md" "Release v0.1.0 ownership gap retirement anchor"
require_contains "docs/automation/automation-readiness.md" "Release v0.1.0 real target smoke coverage anchor"
require_contains "docs/contracts/l4-production-cutover-no-default-real-trading-policy.md" "TVM-L4-PRODUCTION-CUTOVER-GATE"
require_contains "docs/contracts/production-cutover-credential-secret-policy-gate-contract.md" "GH-503-PRODUCTION-CUTOVER-CREDENTIAL-SECRET-POLICY-GATE"
require_contains "docs/contracts/production-cutover-credential-secret-policy-gate-contract.md" "GH-503-NO-DEFAULT-SECRET-READ"
require_contains "docs/contracts/production-cutover-environment-isolation-gate-contract.md" "GH-504-PRODUCTION-ENVIRONMENT-ISOLATION-GATE"
require_contains "docs/contracts/production-cutover-environment-isolation-gate-contract.md" "GH-504-PRODUCTION-NO-DEFAULT-TRADING"
require_contains "docs/contracts/production-cutover-broker-venue-capability-matrix-contract.md" "GH-505-BROKER-VENUE-CAPABILITY-MATRIX"
require_contains "docs/contracts/production-cutover-broker-venue-capability-matrix-contract.md" "GH-505-NO-BROKER-ADAPTER-IMPLEMENTATION"
require_contains "docs/contracts/production-cutover-manual-approval-operator-confirmation-gate-contract.md" "GH-506-MANUAL-APPROVAL-OPERATOR-CONFIRMATION-GATE"
require_contains "docs/contracts/production-cutover-manual-approval-operator-confirmation-gate-contract.md" "GH-506-NO-APPROVAL-BYPASS"
require_contains "docs/contracts/production-cutover-incident-rollback-no-trade-gate-contract.md" "GH-507-INCIDENT-STOP-ROLLBACK-NO-TRADE-GATE"
require_contains "docs/contracts/production-cutover-incident-rollback-no-trade-gate-contract.md" "GH-507-NO-PRODUCTION-RUNTIME-COMMAND"
require_contains "docs/contracts/production-cutover-capital-risk-limit-gate-contract.md" "GH-508-CAPITAL-RISK-NOTIONAL-EXPOSURE-LIMIT-GATE"
require_contains "docs/contracts/production-cutover-capital-risk-limit-gate-contract.md" "GH-508-NO-LIVE-RISK-PRETRADE-RUNTIME"
require_contains "docs/contracts/production-cutover-dry-run-shadow-no-default-trading-evidence-contract.md" "GH-509-DRY-RUN-PROOF-SHADOW-NO-DEFAULT-TRADING-EVIDENCE"
require_contains "docs/contracts/production-cutover-dry-run-shadow-no-default-trading-evidence-contract.md" "GH-509-NO-BROKER-SECRET-REAL-ORDER"
require_contains "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md" "GH-510-STAGE-AUDIT-INPUT"
require_contains "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md" "TVM-PRODUCTION-CUTOVER-READINESS-REAL-BROKER-GATE"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-PRODUCTION-CUTOVER-READINESS-REAL-BROKER-GATE"
require_contains "docs/automation/automation-readiness.md" "Production Cutover Readiness stage audit input anchor"
require_contains "Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift" "productionTradingEnabledByDefault"
require_contains "Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift" "automaticProductionCutoverEnabled"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverCredentialSecretPolicyGate.swift" "ProductionCutoverCredentialSecretPolicyGate"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverCredentialSecretPolicyGate.swift" "GH-503-PRODUCTION-CUTOVER-CREDENTIAL-SECRET-POLICY-GATE"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverEnvironmentIsolationGate.swift" "ProductionCutoverEnvironmentIsolationGateContract"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverEnvironmentIsolationGate.swift" "GH-504-PRODUCTION-ENVIRONMENT-ISOLATION-GATE"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverManualApprovalGate.swift" "ProductionCutoverManualApprovalGate"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverManualApprovalGate.swift" "GH-506-MANUAL-APPROVAL-OPERATOR-CONFIRMATION-GATE"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverIncidentRollbackNoTradeGate.swift" "ProductionCutoverIncidentRollbackNoTradeGate"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverIncidentRollbackNoTradeGate.swift" "GH-507-INCIDENT-STOP-ROLLBACK-NO-TRADE-GATE"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverDryRunShadowNoDefaultTradingEvidence.swift" "ProductionCutoverDryRunShadowNoDefaultTradingEvidence"
require_contains "Sources/ExecutionClient/FutureGate/ProductionCutoverDryRunShadowNoDefaultTradingEvidence.swift" "GH-509-DRY-RUN-PROOF-SHADOW-NO-DEFAULT-TRADING-EVIDENCE"
require_contains "Sources/ExecutionClient/BrokerCapabilityMatrix/ProductionCutoverBrokerVenueCapabilityMatrix.swift" "ProductionCutoverBrokerVenueCapabilityMatrix"
require_contains "Sources/ExecutionClient/BrokerCapabilityMatrix/ProductionCutoverBrokerVenueCapabilityMatrix.swift" "GH-505-BROKER-VENUE-CAPABILITY-MATRIX"
require_contains "Sources/RiskEngine/LiveGate/ProductionCutoverCapitalRiskLimitGate.swift" "ProductionCutoverCapitalRiskLimitGate"
require_contains "Sources/RiskEngine/LiveGate/ProductionCutoverCapitalRiskLimitGate.swift" "GH-508-CAPITAL-RISK-NOTIONAL-EXPOSURE-LIMIT-GATE"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH471ProductionCutoverGatePolicyDefinesNoDefaultRealTradingBoundary"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH471ProductionCutoverGatePolicyRejectsAutomaticCutoverAndProductionBypass"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH503ProductionCredentialSecretPolicyGateDefinesNoDefaultSecretReadContract"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH503ProductionCredentialSecretPolicyGateRejectsSecretReadAndProductionPromotion"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH504ProductionEnvironmentIsolationGateDefinesBlockedDryRunDefault"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH504ProductionEnvironmentIsolationGateRejectsAutomaticSwitchAndBrokerBypass"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH505BrokerVenueCapabilityMatrixBindsCredentialAndEnvironmentGates"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH505BrokerVenueCapabilityMatrixRejectsAdapterEndpointAndOrderBypass"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH506ManualApprovalGateBindsUpstreamCutoverReadinessEvidence"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH506ManualApprovalGateRejectsConfigEnvUIAndSandboxBypass"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH507IncidentRollbackNoTradeGateBindsManualApprovalAndNoTradePriority"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH507IncidentRollbackNoTradeGateRejectsRuntimeCommandAndOrderBypass"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH508CapitalRiskLimitGateBindsBrokerMatrixAndManualApproval"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH508CapitalRiskLimitGateRejectsLiveRiskRuntimeAndAccountReads"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH509DryRunShadowNoDefaultTradingEvidenceBindsUpstreamGatesAndReadModelSurfaces"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH509DryRunShadowNoDefaultTradingEvidenceRejectsBrokerSecretAndProductionPromotion"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH510ProductionCutoverReadinessStageAuditInputDocumentsCompleteEvidenceChain"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH510ProductionCutoverReadinessCloseoutRejectsProductionRuntimeAuthorization"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH523ReleaseV010TargetsExposeRealSmokeCoverage"

python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path.cwd()
violations = []
patterns = [
    re.compile(r"productionTradingEnabledByDefault\s*[:=]\s*true"),
    re.compile(r"automaticProductionCutoverEnabled\s*[:=]\s*true"),
]

for source in sorted((root / "Sources").rglob("*.swift")):
    for line_number, line in enumerate(source.read_text().splitlines(), start=1):
        implementation_line = line.split("//", 1)[0]
        if any(pattern.search(implementation_line) for pattern in patterns):
            violations.append(f"{source.relative_to(root)}:{line_number}: {line.strip()}")

if violations:
    print(
        "automation readiness domain check failed: production trading must not be enabled by default",
        file=sys.stderr,
    )
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)
PY
