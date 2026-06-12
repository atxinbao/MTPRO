#!/usr/bin/env bash
set -euo pipefail

# GH-565-V020-BINANCE-SPOT-PERP-EMA-RSI-AUTOMATION-GUARD
# GH-565-NON-BINANCE-ACTIVE-SOURCE-GUARD
# GH-565-ACTIVE-PRODUCT-TYPE-GUARD
# GH-565-ACTIVE-STRATEGY-GUARD
# GH-565-PRODUCTION-AUTO-ENABLE-GUARD
# TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT"

python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path.cwd()
violations = []

allowed_venue_dirs = {"Binance", "TargetGraph"}
data_client_root = root / "Sources" / "DataClient"
if data_client_root.exists():
    for child in sorted(data_client_root.iterdir()):
        if child.is_dir() and child.name not in allowed_venue_dirs:
            violations.append(
                f"{child.relative_to(root)}: non-Binance active DataClient source is forbidden"
            )

allowed_strategy_dirs = {"EMA", "RSI", "TargetGraph"}
strategy_root = root / "Sources" / "Trader" / "Strategies"
if strategy_root.exists():
    for child in sorted(strategy_root.iterdir()):
        if child.is_dir() and child.name not in allowed_strategy_dirs:
            violations.append(
                f"{child.relative_to(root)}: non-EMA/RSI active Trader strategy source is forbidden"
            )

scan_paths = [
    root / "Package.swift",
    root / ".github" / "workflows" / "checks.yml",
    root / "checks" / "run.sh",
    root / "checks" / "automation-readiness.sh",
    root / "checks" / "automation-readiness.d" / "run-domain-guards.sh",
    root / "docs" / "contracts" / "release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md",
    root / "docs" / "validation" / "trading-validation-matrix.md",
    root / "docs" / "validation" / "validation-plan.md",
    root / "docs" / "validation" / "latest-verification-summary.md",
    root / "docs" / "domain" / "context.md",
    root / "docs" / "automation" / "automation-readiness.md",
    root / "README.md",
    root / "architecture.md",
]
scan_paths.extend(sorted((root / "Sources").rglob("*.swift")))

production_true_patterns = [
    "productionTradingEnabledByDefault",
    "productionEndpointEnabledByDefault",
    "productionEndpointConnectionEnabledByDefault",
    "productionSecretReadEnabledByDefault",
    "productionOrderSubmitEnabledByDefault",
    "productionSubmitEnabledByDefault",
    "productionOrderCancelEnabledByDefault",
    "productionCancelEnabledByDefault",
    "productionOrderReplaceEnabledByDefault",
    "productionReplaceEnabledByDefault",
    "productionOMSRuntimeEnabledByDefault",
    "productionDashboardCommandEnabledByDefault",
    "automaticProductionCutoverEnabled",
    "productionCommandEnabled",
    "connectsProductionEndpoint",
    "failureTriggersProductionOrder",
    "authorizesTradingExecution",
    "submitsRealOrder",
    "cancelsRealOrder",
    "replacesRealOrder",
    "bypassesCommandGateway",
    "bypassesRiskEngine",
    "bypassesExecutionEngine",
    "bypassesOMS",
    "bypassesEventStore",
    "bypassesKillSwitch",
    "bypassesNoTradeState",
]

scope_true_patterns = [
    "nonBinanceVenueEnabled",
    "nonBinanceActiveVenueEnabled",
    "thirdVenueEnabled",
    "nonSpotProductEnabled",
    "nonUSDSPerpetualProductEnabled",
    "thirdActiveProductTypeEnabled",
    "coinMPerpetualEnabledByDefault",
    "optionsProductEnabledByDefault",
    "marginProductEnabledByDefault",
    "nonEMARSIStrategyEnabled",
    "thirdActiveStrategyEnabled",
    "nonEMAOrRSIStrategyEnabled",
]

true_patterns = [
    (
        name,
        re.compile(rf"\b{name}\s*[:=]\s*true\b"),
    )
    for name in production_true_patterns + scope_true_patterns
]

active_venue_re = re.compile(r"\bactiveVenue(?:s)?\s*(?:==|=|:)\s*(?P<value>.+)")
active_product_re = re.compile(r"\bactiveProductTypes?\s*(?:==|=|:)\s*(?P<value>.+)")
active_strategy_re = re.compile(r"\bactiveStrategies?\s*(?:==|=|:)\s*(?P<value>.+)")

for path in scan_paths:
    if not path.exists() or path.is_dir():
        continue
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw_line.split("//", 1)[0]
        lower_line = line.lower()

        for name, pattern in true_patterns:
            if pattern.search(line):
                violations.append(
                    f"{path.relative_to(root)}:{line_number}: forbidden true boundary flag {name}: {raw_line.strip()}"
                )

        venue_match = active_venue_re.search(line)
        if venue_match and "Binance" not in venue_match.group("value"):
            violations.append(
                f"{path.relative_to(root)}:{line_number}: activeVenue must be Binance only: {raw_line.strip()}"
            )

        product_match = active_product_re.search(line)
        if product_match:
            value = product_match.group("value").lower()
            has_spot = "spot" in value
            has_usds_perp = "usdsperpetual" in value or "usdⓈ-m perpetual".lower() in value
            forbidden_product = any(
                token in value
                for token in ["coin-m", "coinm", "option", "margin", "third"]
            )
            if not (has_spot and has_usds_perp) or forbidden_product:
                violations.append(
                    f"{path.relative_to(root)}:{line_number}: activeProductTypes must be spot + usdsPerpetual only: {raw_line.strip()}"
                )

        strategy_match = active_strategy_re.search(line)
        if strategy_match:
            value = strategy_match.group("value").lower()
            has_ema = "ema" in value
            has_rsi = "rsi" in value
            forbidden_strategy = any(
                token in value
                for token in ["orderbookimbalance", "momentum", "meanreversion", "third"]
            )
            if not (has_ema and has_rsi) or forbidden_strategy:
                violations.append(
                    f"{path.relative_to(root)}:{line_number}: activeStrategies must be EMA + RSI only: {raw_line.strip()}"
                )

required_evidence = {
    "checks/automation-readiness.d/release-v0.2.0-boundary.sh": [
        "GH-565-V020-BINANCE-SPOT-PERP-EMA-RSI-AUTOMATION-GUARD",
        "GH-565-NON-BINANCE-ACTIVE-SOURCE-GUARD",
        "GH-565-ACTIVE-PRODUCT-TYPE-GUARD",
        "GH-565-ACTIVE-STRATEGY-GUARD",
        "GH-565-PRODUCTION-AUTO-ENABLE-GUARD",
        "TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD",
    ],
    "checks/automation-readiness.d/run-domain-guards.sh": [
        "release-v0.2.0-boundary",
    ],
    "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md": [
        "activeVenue == Binance",
        "activeProductTypes == [spot, usdsPerpetual]",
        "activeStrategies == [ema, rsi]",
        "productionTradingEnabledByDefault == false",
    ],
    "docs/validation/trading-validation-matrix.md": [
        "GH-565",
        "TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD",
        "GH-569",
        "TVM-RELEASE-V020-EMA-TARGET-EXPOSURE-INTENT",
        "GH-570",
        "TVM-RELEASE-V020-RSI-TARGET-EXPOSURE-INTENT",
        "GH-571",
        "TVM-RELEASE-V020-STRATEGY-ACTOR-REGISTRY-BINDING",
        "GH-572",
        "TVM-RELEASE-V020-TYPED-MESSAGEBUS-ENVELOPE",
        "GH-573",
        "TVM-RELEASE-V020-BINANCE-SPOT-DATAENGINE-CACHE-PATH",
        "GH-574",
        "TVM-RELEASE-V020-BINANCE-USDM-PERP-DATAENGINE-CACHE-PATH",
        "GH-575",
        "TVM-RELEASE-V020-PERP-MARK-FUNDING-OI-READ-MODEL",
        "GH-576",
        "TVM-RELEASE-V020-PRODUCT-AWARE-CACHE-STATE",
        "GH-577",
        "TVM-RELEASE-V020-PROPOSAL-ARBITRATOR",
        "GH-578",
        "TVM-RELEASE-V020-RISKENGINE-COMMON-LAYER",
        "GH-579",
        "TVM-RELEASE-V020-SPOT-RISK-CHECKS",
        "GH-580",
        "TVM-RELEASE-V020-PERP-RISK-CHECKS",
        "GH-581",
        "TVM-RELEASE-V020-SPOT-EXECUTION-ALGORITHM",
        "GH-582",
        "TVM-RELEASE-V020-PERP-EXECUTION-ALGORITHM",
        "GH-583",
        "TVM-RELEASE-V020-PRODUCT-AWARE-OMS-STATE-MACHINE",
        "GH-584",
        "TVM-RELEASE-V020-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER",
        "GH-585",
        "TVM-RELEASE-V020-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER",
        "GH-586",
        "TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER",
        "GH-587",
        "TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION",
        "GH-588",
        "TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION",
        "GH-589",
        "TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION",
    ],
    "docs/validation/validation-plan.md": [
        "GH-565 Release v0.2.0 Boundary Automation Guard Validation",
        "GH-569 Release v0.2.0 EMA Target Exposure Intent Validation",
        "GH-570 Release v0.2.0 RSI Target Exposure Intent Validation",
        "GH-571 Release v0.2.0 Strategy Actor Registry Validation",
        "GH-572 Release v0.2.0 Typed MessageBus Envelope Validation",
        "GH-573 Release v0.2.0 Binance Spot DataEngine Cache Path Validation",
        "GH-574 Release v0.2.0 Binance USD-M Perpetual DataEngine Cache Path Validation",
        "GH-575 Release v0.2.0 Perp Mark Funding Open Interest Read Model Validation",
        "GH-576 Release v0.2.0 Product-aware Cache State Validation",
        "GH-577 Release v0.2.0 Proposal Arbitrator Validation",
        "GH-578 Release v0.2.0 RiskEngine Common Layer Validation",
        "GH-579 Release v0.2.0 Spot Risk Checks Validation",
        "GH-580 Release v0.2.0 Perpetual Risk Checks Validation",
        "GH-581 Release v0.2.0 Spot ExecutionAlgorithm Validation",
        "GH-582 Release v0.2.0 Perpetual ExecutionAlgorithm Validation",
        "GH-583 Release v0.2.0 Product-aware OMS State Machine Validation",
        "GH-584 Release v0.2.0 Binance Spot ExecutionClient Adapter Validation",
        "GH-585 Release v0.2.0 Binance USD-M Perpetual ExecutionClient Adapter Validation",
        "GH-586 Release v0.2.0 Execution Report Broker Fill Parser Validation",
        "GH-587 Release v0.2.0 Spot Portfolio Projection Validation",
        "GH-588 Release v0.2.0 Perpetual Portfolio Projection Validation",
        "GH-589 Release v0.2.0 Aggregate Portfolio Attribution Validation",
    ],
    "docs/domain/context.md": [
        "GH-565 Release v0.2.0 Boundary Automation Guard Terms",
        "GH-569 EMA Target Exposure Intent Terms",
        "GH-570 RSI Target Exposure Intent Terms",
        "GH-571 Strategy Actor Registry Terms",
        "GH-572 Typed MessageBus Envelope Terms",
        "GH-573 Binance Spot DataEngine Cache Path Terms",
        "GH-574 Binance USD-M Perpetual DataEngine Cache Path Terms",
        "GH-575 Perp Mark Funding Open Interest Read Model Terms",
        "GH-576 Product-aware Cache State Terms",
        "GH-577 Proposal Arbitrator Terms",
        "GH-578 RiskEngine Common Layer Terms",
        "GH-579 Spot Risk Checks Terms",
        "GH-580 Perpetual Risk Checks Terms",
        "GH-581 Spot ExecutionAlgorithm Terms",
        "GH-582 Perpetual ExecutionAlgorithm Terms",
        "GH-583 Product-aware OMS State Machine Terms",
        "GH-584 Binance Spot ExecutionClient Adapter Terms",
        "GH-585 Binance USD-M Perpetual ExecutionClient Adapter Terms",
        "GH-586 Execution Report Broker Fill Parser Terms",
        "GH-587 Spot Portfolio Projection Terms",
        "GH-588 Perpetual Portfolio Projection Terms",
        "GH-589 Aggregate Portfolio Attribution Terms",
    ],
    "docs/automation/automation-readiness.md": [
        "Release v0.2.0 boundary automation guard anchor",
        "Release v0.2.0 EMA target exposure intent anchor",
        "Release v0.2.0 RSI target exposure intent anchor",
        "Release v0.2.0 strategy actor registry anchor",
        "Release v0.2.0 typed MessageBus envelope anchor",
        "Release v0.2.0 Binance Spot DataEngine Cache path anchor",
        "Release v0.2.0 Binance USD-M Perpetual DataEngine Cache path anchor",
        "Release v0.2.0 Perp mark funding open interest read model anchor",
        "Release v0.2.0 product-aware Cache state anchor",
        "Release v0.2.0 ProposalArbitrator anchor",
        "Release v0.2.0 RiskEngine common layer anchor",
        "Release v0.2.0 Spot risk checks anchor",
        "Release v0.2.0 Perpetual risk checks anchor",
        "Release v0.2.0 Spot ExecutionAlgorithm anchor",
        "Release v0.2.0 Perpetual ExecutionAlgorithm anchor",
        "Release v0.2.0 Product-aware OMS state machine anchor",
        "Release v0.2.0 Binance Spot ExecutionClient adapter anchor",
        "Release v0.2.0 Binance USD-M Perpetual ExecutionClient adapter anchor",
        "Release v0.2.0 execution report broker fill parser anchor",
        "Release v0.2.0 Spot Portfolio projection anchor",
        "Release v0.2.0 Perpetual Portfolio projection anchor",
        "Release v0.2.0 aggregate Portfolio attribution anchor",
    ],
    "Tests/TargetGraphTests/TargetGraphTests.swift": [
        "testGH565ReleaseV020BoundaryGuardBlocksScopeExpansionAndProductionDefaults",
        "testGH569EMATargetExposureIntentSupportsSpotAndPerpWithoutDirectOrderSide",
        "testGH570RSITargetExposureIntentSupportsSpotAndGatedPerpShort",
        "testGH571StrategyRegistryRegistersEMAAndRSIProductBindingsWithoutExecutionDependency",
        "testGH572TypedMessageBusEnvelopeEvidenceIsWiredIntoReleaseGuard",
        "testGH573BinanceSpotMarketDataActivePathEmitsProductAwareEventsIntoCache",
        "testGH574BinanceUSDMPerpetualMarketDataActivePathEmitsProductAwareEventsIntoCache",
        "testGH575PerpMarkFundingOpenInterestReadModelSupportsStaleEvidence",
        "testGH576ProductAwareCacheSeparatesSpotPerpStateAndRebuildsFromReplay",
        "testGH577ProposalArbitratorAllowsAgreementAndBlocksConflictsBeforeRisk",
        "testGH578RiskEngineCommonLayerAppliesAllowlistsLimitsKillSwitchAndNoTrade",
        "testGH579SpotRiskChecksCoverBalancesShortAndExchangeFilters",
        "testGH580PerpetualRiskChecksCoverLeverageLiquidationFundingAndReduceOnly",
        "testGH581SpotExecutionAlgorithmMapsTargetExposureToControlledSpotOrderIntent",
        "testGH582PerpetualExecutionAlgorithmSupportsOpenReduceOnlyAndBlocksOneShotFlip",
        "testGH583ProductAwareOMSStateMachineCoversSpotPerpReplayAndRejectsIllegalTransition",
        "testGH584BinanceSpotExecutionClientAdapterProducesDryRunAndTestnetMapping",
        "testGH585BinanceUSDMPerpExecutionClientAdapterProducesPositionSideReduceOnlyMapping",
        "testGH586BinanceExecutionReportParserMapsSpotPerpBrokerFillAndPositionUpdates",
        "testGH587SpotPortfolioProjectionUpdatesBalancePositionPnLAndStrategyAttribution",
        "testGH588PerpetualPortfolioProjectionUpdatesPositionMarginPnLFundingAndAttribution",
        "testGH589AggregatePortfolioAndStrategyAttributionCombinesSpotPerpEvidence",
    ],
}

missing = []
for relative_path, expected_values in required_evidence.items():
    path = root / relative_path
    if not path.exists():
        missing.append(f"{relative_path}: missing file")
        continue
    text = path.read_text(encoding="utf-8")
    for expected in expected_values:
        if expected not in text:
            missing.append(f"{relative_path}: missing {expected}")

if missing:
    print(
        "automation readiness release v0.2.0 boundary guard failed: evidence chain is incomplete",
        file=sys.stderr,
    )
    print("\n".join(missing), file=sys.stderr)
    sys.exit(1)

if violations:
    print(
        "automation readiness release v0.2.0 boundary guard failed: scope or production default expanded",
        file=sys.stderr,
    )
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)

print("MTPRO release v0.2.0 boundary guard passed.")
PY
