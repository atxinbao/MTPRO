import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV020AggregatePortfolioStrategyKind 固定 GH-589 允许汇总的 release 策略。
///
/// Aggregate Portfolio attribution 只能汇总 release v0.2.0 当前 active 的 EMA / RSI
/// strategy attribution evidence；它不能新增第三种 active strategy，也不能生成 live command。
public enum ReleaseV020AggregatePortfolioStrategyKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case ema = "EMA"
    case rsi = "RSI"
}

/// ReleaseV020AggregatePortfolioAttributionInput 是 GH-589 的 Spot + Perp 汇总输入。
///
/// 输入只消费 GH-587 Spot Portfolio projection 和 GH-588 Perpetual Portfolio projection。
/// 它不读取 production account endpoint，不同步 broker position，不执行 reconciliation runtime，
/// 也不 mutate Portfolio runtime。
public struct ReleaseV020AggregatePortfolioAttributionInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let issueID: Identifier
    public let spotEvidence: ReleaseV020SpotPortfolioProjectionEvidence
    public let perpetualEvidence: ReleaseV020PerpetualPortfolioProjectionEvidence
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        inputID: Identifier = Identifier.constant("gh-589-aggregate-portfolio-attribution-input"),
        issueID: Identifier = Identifier.constant("GH-589"),
        spotEvidence: ReleaseV020SpotPortfolioProjectionEvidence,
        perpetualEvidence: ReleaseV020PerpetualPortfolioProjectionEvidence,
        validationAnchors: [String] = ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-589" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.issueID",
                expected: "GH-589",
                actual: issueID.rawValue
            )
        }
        guard spotEvidence.issueID.rawValue == "GH-587",
              spotEvidence.evidenceBoundaryHeld,
              spotEvidence.positionProjection.instrument.productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.spotEvidence",
                expected: "GH-587 Spot Portfolio projection boundary held",
                actual: spotEvidence.issueID.rawValue
            )
        }
        guard perpetualEvidence.issueID.rawValue == "GH-588",
              perpetualEvidence.evidenceBoundaryHeld,
              perpetualEvidence.positionProjection.instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.perpetualEvidence",
                expected: "GH-588 Perpetual Portfolio projection boundary held",
                actual: perpetualEvidence.issueID.rawValue
            )
        }
        guard Set(spotEvidence.strategyAttributions.map { Self.strategyKind(from: $0.strategyKind) })
            == Set(ReleaseV020AggregatePortfolioStrategyKind.allCases),
            Set(perpetualEvidence.strategyAttributions.map { Self.strategyKind(from: $0.strategyKind) })
            == Set(ReleaseV020AggregatePortfolioStrategyKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.strategyCoverage",
                expected: "EMA and RSI in Spot and Perp evidence",
                actual: "missing"
            )
        }
        guard validationAnchors == ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.validationAnchors",
                expected: ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("reconciliationRuntimeExecuted", reconciliationRuntimeExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.\(forbiddenFlag.0)"
            )
        }

        self.inputID = inputID
        self.issueID = issueID
        self.spotEvidence = spotEvidence
        self.perpetualEvidence = perpetualEvidence
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var inputBoundaryHeld: Bool {
        issueID.rawValue == "GH-589"
            && spotEvidence.issueID.rawValue == "GH-587"
            && spotEvidence.evidenceBoundaryHeld
            && spotEvidence.positionProjection.instrument.productType == .spot
            && perpetualEvidence.issueID.rawValue == "GH-588"
            && perpetualEvidence.evidenceBoundaryHeld
            && perpetualEvidence.positionProjection.instrument.productType == .usdsPerpetual
            && validationAnchors == ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && reconciliationRuntimeExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }

    private static func strategyKind(
        from kind: ReleaseV020SpotPortfolioProjectionStrategyKind
    ) -> ReleaseV020AggregatePortfolioStrategyKind {
        switch kind {
        case .ema:
            return .ema
        case .rsi:
            return .rsi
        }
    }

    private static func strategyKind(
        from kind: ReleaseV020PerpetualPortfolioProjectionStrategyKind
    ) -> ReleaseV020AggregatePortfolioStrategyKind {
        switch kind {
        case .ema:
            return .ema
        case .rsi:
            return .rsi
        }
    }
}

/// ReleaseV020AggregatePortfolioExposureSummary 记录 Spot + Perp aggregate exposure evidence。
public struct ReleaseV020AggregatePortfolioExposureSummary: Codable, Equatable, Sendable {
    public let exposureSummaryID: Identifier
    public let spotInstrument: InstrumentIdentity
    public let perpetualInstrument: InstrumentIdentity
    public let spotGrossExposureNotional: Double
    public let perpetualGrossExposureNotional: Double
    public let aggregateGrossExposureNotional: Double
    public let spotNetPnL: Double
    public let perpetualNetPnL: Double
    public let aggregateNetPnL: Double
    public let marginRequirement: Double
    public let fundingPaymentEstimate: Double
    public let aggregateExposureCalculated: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let portfolioRuntimeMutated: Bool

    public init(
        exposureSummaryID: Identifier = Identifier.constant("gh-589-aggregate-exposure-summary"),
        spotInstrument: InstrumentIdentity,
        perpetualInstrument: InstrumentIdentity,
        spotGrossExposureNotional: Double,
        perpetualGrossExposureNotional: Double,
        aggregateGrossExposureNotional: Double,
        spotNetPnL: Double,
        perpetualNetPnL: Double,
        aggregateNetPnL: Double,
        marginRequirement: Double,
        fundingPaymentEstimate: Double,
        aggregateExposureCalculated: Bool = true,
        productionAccountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        portfolioRuntimeMutated: Bool = false
    ) throws {
        for pair in [
            ("spotGrossExposureNotional", spotGrossExposureNotional),
            ("perpetualGrossExposureNotional", perpetualGrossExposureNotional),
            ("aggregateGrossExposureNotional", aggregateGrossExposureNotional),
            ("spotNetPnL", spotNetPnL),
            ("perpetualNetPnL", perpetualNetPnL),
            ("aggregateNetPnL", aggregateNetPnL),
            ("marginRequirement", marginRequirement),
            ("fundingPaymentEstimate", fundingPaymentEstimate)
        ] where pair.1.isFinite == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.\(pair.0)",
                expected: "finite value",
                actual: "\(pair.1)"
            )
        }
        guard spotInstrument.productType == .spot,
              perpetualInstrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.productTypes",
                expected: "spot,usdsPerpetual",
                actual: "\(spotInstrument.productType.rawValue),\(perpetualInstrument.productType.rawValue)"
            )
        }
        guard abs(aggregateGrossExposureNotional - (spotGrossExposureNotional + perpetualGrossExposureNotional)) < 0.000_000_01,
              abs(aggregateNetPnL - (spotNetPnL + perpetualNetPnL)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.aggregateExposure",
                expected: "Spot + Perp aggregate exposure and PnL",
                actual: "mismatch"
            )
        }
        guard aggregateExposureCalculated else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.aggregateExposureCalculated",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerPositionSynced", brokerPositionSynced),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.exposure.\(forbiddenFlag.0)"
            )
        }

        self.exposureSummaryID = exposureSummaryID
        self.spotInstrument = spotInstrument
        self.perpetualInstrument = perpetualInstrument
        self.spotGrossExposureNotional = spotGrossExposureNotional
        self.perpetualGrossExposureNotional = perpetualGrossExposureNotional
        self.aggregateGrossExposureNotional = aggregateGrossExposureNotional
        self.spotNetPnL = spotNetPnL
        self.perpetualNetPnL = perpetualNetPnL
        self.aggregateNetPnL = aggregateNetPnL
        self.marginRequirement = marginRequirement
        self.fundingPaymentEstimate = fundingPaymentEstimate
        self.aggregateExposureCalculated = aggregateExposureCalculated
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
    }

    public var exposureBoundaryHeld: Bool {
        spotInstrument.productType == .spot
            && perpetualInstrument.productType == .usdsPerpetual
            && spotGrossExposureNotional >= 0
            && perpetualGrossExposureNotional >= 0
            && aggregateGrossExposureNotional >= 0
            && abs(aggregateGrossExposureNotional - (spotGrossExposureNotional + perpetualGrossExposureNotional)) < 0.000_000_01
            && abs(aggregateNetPnL - (spotNetPnL + perpetualNetPnL)) < 0.000_000_01
            && marginRequirement >= 0
            && fundingPaymentEstimate.isFinite
            && aggregateExposureCalculated
            && productionAccountEndpointRead == false
            && brokerPositionSynced == false
            && portfolioRuntimeMutated == false
    }
}

/// ReleaseV020AggregatePortfolioStrategyAttributionSummary 汇总 EMA / RSI attribution evidence。
public struct ReleaseV020AggregatePortfolioStrategyAttributionSummary: Codable, Equatable, Sendable {
    public let attributionSummaryID: Identifier
    public let strategyKind: ReleaseV020AggregatePortfolioStrategyKind
    public let sourceSpotAttributionIDs: [Identifier]
    public let sourcePerpetualAttributionIDs: [Identifier]
    public let spotAttributedNotional: Double
    public let perpetualAttributedNotional: Double
    public let aggregateAttributedNotional: Double
    public let spotAttributedPnL: Double
    public let perpetualAttributedPnL: Double
    public let aggregateAttributedPnL: Double
    public let strategyAttributionSeparated: Bool
    public let nonEMARSIStrategyEnabled: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        attributionSummaryID: Identifier,
        strategyKind: ReleaseV020AggregatePortfolioStrategyKind,
        sourceSpotAttributionIDs: [Identifier],
        sourcePerpetualAttributionIDs: [Identifier],
        spotAttributedNotional: Double,
        perpetualAttributedNotional: Double,
        aggregateAttributedNotional: Double,
        spotAttributedPnL: Double,
        perpetualAttributedPnL: Double,
        aggregateAttributedPnL: Double,
        strategyAttributionSeparated: Bool = true,
        nonEMARSIStrategyEnabled: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard sourceSpotAttributionIDs.isEmpty == false,
              sourcePerpetualAttributionIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.sourceAttributions",
                expected: "Spot and Perp attribution IDs",
                actual: "\(sourceSpotAttributionIDs.count)/\(sourcePerpetualAttributionIDs.count)"
            )
        }
        for pair in [
            ("spotAttributedNotional", spotAttributedNotional),
            ("perpetualAttributedNotional", perpetualAttributedNotional),
            ("aggregateAttributedNotional", aggregateAttributedNotional),
            ("spotAttributedPnL", spotAttributedPnL),
            ("perpetualAttributedPnL", perpetualAttributedPnL),
            ("aggregateAttributedPnL", aggregateAttributedPnL)
        ] where pair.1.isFinite == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.\(pair.0)",
                expected: "finite value",
                actual: "\(pair.1)"
            )
        }
        guard ReleaseV020AggregatePortfolioStrategyKind.allCases.contains(strategyKind),
              abs(aggregateAttributedNotional - (spotAttributedNotional + perpetualAttributedNotional)) < 0.000_000_01,
              abs(aggregateAttributedPnL - (spotAttributedPnL + perpetualAttributedPnL)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.strategyAggregate",
                expected: "strategy-specific Spot + Perp aggregate",
                actual: "mismatch"
            )
        }
        guard strategyAttributionSeparated else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.strategyAttributionSeparated",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("nonEMARSIStrategyEnabled", nonEMARSIStrategyEnabled),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.strategy.\(forbiddenFlag.0)"
            )
        }

        self.attributionSummaryID = attributionSummaryID
        self.strategyKind = strategyKind
        self.sourceSpotAttributionIDs = sourceSpotAttributionIDs
        self.sourcePerpetualAttributionIDs = sourcePerpetualAttributionIDs
        self.spotAttributedNotional = spotAttributedNotional
        self.perpetualAttributedNotional = perpetualAttributedNotional
        self.aggregateAttributedNotional = aggregateAttributedNotional
        self.spotAttributedPnL = spotAttributedPnL
        self.perpetualAttributedPnL = perpetualAttributedPnL
        self.aggregateAttributedPnL = aggregateAttributedPnL
        self.strategyAttributionSeparated = strategyAttributionSeparated
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var attributionBoundaryHeld: Bool {
        ReleaseV020AggregatePortfolioStrategyKind.allCases.contains(strategyKind)
            && sourceSpotAttributionIDs.isEmpty == false
            && sourcePerpetualAttributionIDs.isEmpty == false
            && aggregateAttributedNotional >= 0
            && abs(aggregateAttributedNotional - (spotAttributedNotional + perpetualAttributedNotional)) < 0.000_000_01
            && abs(aggregateAttributedPnL - (spotAttributedPnL + perpetualAttributedPnL)) < 0.000_000_01
            && strategyAttributionSeparated
            && nonEMARSIStrategyEnabled == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020AggregatePortfolioFundingLiquidationSummary 暴露 funding / liquidation 摘要。
///
/// liquidation reference 是 deterministic local estimate，只用于 release evidence surface，
/// 不是 broker liquidation price、不是 margin call，也不授权 leverage / margin action。
public struct ReleaseV020AggregatePortfolioFundingLiquidationSummary: Codable, Equatable, Sendable {
    public let summaryID: Identifier
    public let instrument: InstrumentIdentity
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide
    public let leverage: Double
    public let entryPrice: Price
    public let markPrice: Price
    public let fundingRate: Double
    public let fundingPaymentEstimate: Double
    public let nextFundingTime: Date
    public let deterministicLiquidationReferencePrice: Price
    public let liquidationDistance: Double
    public let liquidationDistanceRatio: Double
    public let fundingSummaryVisible: Bool
    public let liquidationSummaryVisible: Bool
    public let readsBrokerMargin: Bool
    public let brokerStatementRead: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool

    public init(
        summaryID: Identifier = Identifier.constant("gh-589-funding-liquidation-summary"),
        instrument: InstrumentIdentity,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        leverage: Double,
        entryPrice: Price,
        markPrice: Price,
        fundingRate: Double,
        fundingPaymentEstimate: Double,
        nextFundingTime: Date,
        deterministicLiquidationReferencePrice: Price,
        liquidationDistance: Double,
        liquidationDistanceRatio: Double,
        fundingSummaryVisible: Bool = true,
        liquidationSummaryVisible: Bool = true,
        readsBrokerMargin: Bool = false,
        brokerStatementRead: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false
    ) throws {
        let expectedLiquidationReferencePrice = Self.expectedLiquidationReferencePrice(
            positionSide: positionSide,
            entryPrice: entryPrice,
            leverage: leverage
        )
        let expectedDistance = Self.expectedLiquidationDistance(
            positionSide: positionSide,
            markPrice: markPrice,
            liquidationReferencePrice: deterministicLiquidationReferencePrice
        )
        guard instrument.productType == .usdsPerpetual,
              leverage.isFinite,
              leverage > 0,
              entryPrice.rawValue > 0,
              markPrice.rawValue > 0,
              fundingRate.isFinite,
              fundingPaymentEstimate.isFinite,
              liquidationDistance.isFinite,
              liquidationDistance >= 0,
              liquidationDistanceRatio.isFinite,
              liquidationDistanceRatio >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.fundingLiquidation",
                expected: "finite Perp funding and liquidation summary",
                actual: "invalid"
            )
        }
        guard abs(deterministicLiquidationReferencePrice.rawValue - expectedLiquidationReferencePrice) < 0.000_000_01,
              abs(liquidationDistance - expectedDistance) < 0.000_000_01,
              abs(liquidationDistanceRatio - (liquidationDistance / markPrice.rawValue)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.liquidationSummary",
                expected: "deterministic local liquidation reference",
                actual: "mismatch"
            )
        }
        guard fundingSummaryVisible, liquidationSummaryVisible else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.summaryVisible",
                expected: "funding and liquidation visible",
                actual: "\(fundingSummaryVisible)/\(liquidationSummaryVisible)"
            )
        }
        for forbiddenFlag in [
            ("readsBrokerMargin", readsBrokerMargin),
            ("brokerStatementRead", brokerStatementRead),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.fundingLiquidation.\(forbiddenFlag.0)"
            )
        }

        self.summaryID = summaryID
        self.instrument = instrument
        self.positionSide = positionSide
        self.leverage = leverage
        self.entryPrice = entryPrice
        self.markPrice = markPrice
        self.fundingRate = fundingRate
        self.fundingPaymentEstimate = fundingPaymentEstimate
        self.nextFundingTime = nextFundingTime
        self.deterministicLiquidationReferencePrice = deterministicLiquidationReferencePrice
        self.liquidationDistance = liquidationDistance
        self.liquidationDistanceRatio = liquidationDistanceRatio
        self.fundingSummaryVisible = fundingSummaryVisible
        self.liquidationSummaryVisible = liquidationSummaryVisible
        self.readsBrokerMargin = readsBrokerMargin
        self.brokerStatementRead = brokerStatementRead
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
    }

    public var summaryBoundaryHeld: Bool {
        instrument.productType == .usdsPerpetual
            && leverage > 0
            && entryPrice.rawValue > 0
            && markPrice.rawValue > 0
            && fundingRate.isFinite
            && fundingPaymentEstimate.isFinite
            && liquidationDistance >= 0
            && liquidationDistanceRatio >= 0
            && fundingSummaryVisible
            && liquidationSummaryVisible
            && readsBrokerMargin == false
            && brokerStatementRead == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
    }

    public static func expectedLiquidationReferencePrice(
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        entryPrice: Price,
        leverage: Double
    ) -> Double {
        switch positionSide {
        case .long:
            entryPrice.rawValue * (1 - (1 / leverage))
        case .short:
            entryPrice.rawValue * (1 + (1 / leverage))
        }
    }

    public static func expectedLiquidationDistance(
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        markPrice: Price,
        liquidationReferencePrice: Price
    ) -> Double {
        switch positionSide {
        case .long:
            max(markPrice.rawValue - liquidationReferencePrice.rawValue, 0)
        case .short:
            max(liquidationReferencePrice.rawValue - markPrice.rawValue, 0)
        }
    }
}

/// ReleaseV020AggregatePortfolioAttributionEvidence 汇总 GH-589 aggregate evidence。
/// `TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION`
public struct ReleaseV020AggregatePortfolioAttributionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sourceSpotEvidenceID: Identifier
    public let sourcePerpetualEvidenceID: Identifier
    public let exposureSummary: ReleaseV020AggregatePortfolioExposureSummary
    public let strategyAttributionSummaries: [ReleaseV020AggregatePortfolioStrategyAttributionSummary]
    public let fundingLiquidationSummary: ReleaseV020AggregatePortfolioFundingLiquidationSummary
    public let validationAnchors: [String]
    public let aggregateExposureCalculated: Bool
    public let strategyAttributionSeparated: Bool
    public let fundingAndLiquidationSummaryVisible: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-589-aggregate-portfolio-attribution-evidence"),
        issueID: Identifier = Identifier.constant("GH-589"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-587"),
            Identifier.constant("GH-588")
        ],
        sourceSpotEvidenceID: Identifier,
        sourcePerpetualEvidenceID: Identifier,
        exposureSummary: ReleaseV020AggregatePortfolioExposureSummary,
        strategyAttributionSummaries: [ReleaseV020AggregatePortfolioStrategyAttributionSummary],
        fundingLiquidationSummary: ReleaseV020AggregatePortfolioFundingLiquidationSummary,
        validationAnchors: [String] = ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors,
        aggregateExposureCalculated: Bool = true,
        strategyAttributionSeparated: Bool = true,
        fundingAndLiquidationSummaryVisible: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-589" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.evidenceIssueID",
                expected: "GH-589",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-587", "GH-588"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.upstreamIssueIDs",
                expected: "GH-587,GH-588",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard exposureSummary.exposureBoundaryHeld,
              strategyAttributionSummaries.count == ReleaseV020AggregatePortfolioStrategyKind.allCases.count,
              strategyAttributionSummaries.allSatisfy(\.attributionBoundaryHeld),
              Set(strategyAttributionSummaries.map(\.strategyKind)) == Set(ReleaseV020AggregatePortfolioStrategyKind.allCases),
              fundingLiquidationSummary.summaryBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.subSummaryBoundary",
                expected: "aggregate exposure, EMA/RSI attribution and funding/liquidation summaries",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.validationAnchors",
                expected: ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("aggregateExposureCalculated", aggregateExposureCalculated),
            ("strategyAttributionSeparated", strategyAttributionSeparated),
            ("fundingAndLiquidationSummaryVisible", fundingAndLiquidationSummaryVisible)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("reconciliationRuntimeExecuted", reconciliationRuntimeExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sourceSpotEvidenceID = sourceSpotEvidenceID
        self.sourcePerpetualEvidenceID = sourcePerpetualEvidenceID
        self.exposureSummary = exposureSummary
        self.strategyAttributionSummaries = strategyAttributionSummaries
        self.fundingLiquidationSummary = fundingLiquidationSummary
        self.validationAnchors = validationAnchors
        self.aggregateExposureCalculated = aggregateExposureCalculated
        self.strategyAttributionSeparated = strategyAttributionSeparated
        self.fundingAndLiquidationSummaryVisible = fundingAndLiquidationSummaryVisible
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-589"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-587", "GH-588"]
            && exposureSummary.exposureBoundaryHeld
            && strategyAttributionSummaries.allSatisfy(\.attributionBoundaryHeld)
            && Set(strategyAttributionSummaries.map(\.strategyKind)) == Set(ReleaseV020AggregatePortfolioStrategyKind.allCases)
            && fundingLiquidationSummary.summaryBoundaryHeld
            && validationAnchors == ReleaseV020AggregatePortfolioAttribution.requiredValidationAnchors
            && aggregateExposureCalculated
            && strategyAttributionSeparated
            && fundingAndLiquidationSummaryVisible
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && reconciliationRuntimeExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020AggregatePortfolioAttribution 是 GH-589 的 deterministic aggregate builder。
///
/// Builder 只把 GH-587 Spot evidence 和 GH-588 Perp evidence 聚合成 release evidence
/// surface；它不读取真实账户、不调用 broker gateway、不做 reconciliation runtime，也不写
/// production Portfolio state。
public struct ReleaseV020AggregatePortfolioAttribution: Codable, Equatable, Sendable {
    public let aggregateID: Identifier
    public let issueID: Identifier
    public let input: ReleaseV020AggregatePortfolioAttributionInput
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        aggregateID: Identifier = Identifier.constant("gh-589-aggregate-portfolio-attribution"),
        issueID: Identifier = Identifier.constant("GH-589"),
        input: ReleaseV020AggregatePortfolioAttributionInput,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-589" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.aggregateIssueID",
                expected: "GH-589",
                actual: issueID.rawValue
            )
        }
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.inputBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("reconciliationRuntimeExecuted", reconciliationRuntimeExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020AggregatePortfolioAttribution.\(forbiddenFlag.0)"
            )
        }

        self.aggregateID = aggregateID
        self.issueID = issueID
        self.input = input
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var aggregateBoundaryHeld: Bool {
        issueID.rawValue == "GH-589"
            && input.inputBoundaryHeld
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && reconciliationRuntimeExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }

    /// 生成 GH-589 deterministic aggregate Portfolio / strategy attribution evidence。
    public func deterministicEvidence() throws -> ReleaseV020AggregatePortfolioAttributionEvidence {
        guard aggregateBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020AggregatePortfolioAttribution.aggregateBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        let spot = input.spotEvidence
        let perp = input.perpetualEvidence
        let exposureSummary = try ReleaseV020AggregatePortfolioExposureSummary(
            spotInstrument: spot.positionProjection.instrument,
            perpetualInstrument: perp.positionProjection.instrument,
            spotGrossExposureNotional: spot.exposureSnapshot.grossExposureNotional,
            perpetualGrossExposureNotional: perp.exposureSnapshot.grossExposureNotional,
            aggregateGrossExposureNotional: spot.exposureSnapshot.grossExposureNotional
                + perp.exposureSnapshot.grossExposureNotional,
            spotNetPnL: spot.pnlProjection.netPnL,
            perpetualNetPnL: perp.pnlProjection.netPnL,
            aggregateNetPnL: spot.pnlProjection.netPnL + perp.pnlProjection.netPnL,
            marginRequirement: perp.marginProjection.marginRequirement,
            fundingPaymentEstimate: perp.fundingProjection.fundingPaymentEstimate
        )
        let fundingLiquidationSummary = try Self.fundingLiquidationSummary(from: perp)

        return try ReleaseV020AggregatePortfolioAttributionEvidence(
            sourceSpotEvidenceID: spot.evidenceID,
            sourcePerpetualEvidenceID: perp.evidenceID,
            exposureSummary: exposureSummary,
            strategyAttributionSummaries: try Self.strategyAttributionSummaries(spot: spot, perp: perp),
            fundingLiquidationSummary: fundingLiquidationSummary
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020AggregatePortfolioAttribution {
        let spotEvidence = try ReleaseV020SpotPortfolioProjection.deterministicFixture().deterministicEvidence()
        let perpetualEvidence = try ReleaseV020PerpetualPortfolioProjection.deterministicFixture().deterministicEvidence()
        let input = try ReleaseV020AggregatePortfolioAttributionInput(
            spotEvidence: spotEvidence,
            perpetualEvidence: perpetualEvidence
        )
        return try ReleaseV020AggregatePortfolioAttribution(input: input)
    }

    public static let requiredValidationAnchors = [
        "GH-589-AGGREGATE-PORTFOLIO-ATTRIBUTION",
        "GH-589-SPOT-PERP-EXPOSURE-SUMMARY",
        "GH-589-EMA-RSI-ATTRIBUTION-SEPARATED",
        "GH-589-FUNDING-LIQUIDATION-SUMMARY",
        "GH-589-NO-PRODUCTION-PORTFOLIO-RUNTIME",
        "TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION"
    ]

    private static func strategyAttributionSummaries(
        spot: ReleaseV020SpotPortfolioProjectionEvidence,
        perp: ReleaseV020PerpetualPortfolioProjectionEvidence
    ) throws -> [ReleaseV020AggregatePortfolioStrategyAttributionSummary] {
        try ReleaseV020AggregatePortfolioStrategyKind.allCases.map { strategyKind in
            let spotAttributions = spot.strategyAttributions.filter {
                aggregateStrategyKind(from: $0.strategyKind) == strategyKind
            }
            let perpAttributions = perp.strategyAttributions.filter {
                aggregateStrategyKind(from: $0.strategyKind) == strategyKind
            }
            let spotNotional = spotAttributions.reduce(0.0) { $0 + $1.attributedNotional }
            let perpNotional = perpAttributions.reduce(0.0) { $0 + $1.attributedNotional }
            let spotPnL = spotAttributions.reduce(0.0) { $0 + $1.attributedNetPnL }
            let perpPnL = perpAttributions.reduce(0.0) { $0 + $1.attributedRealizedPnL }
            return try ReleaseV020AggregatePortfolioStrategyAttributionSummary(
                attributionSummaryID: Identifier.constant(
                    "gh-589-\(strategyKind.rawValue.lowercased())-aggregate-attribution"
                ),
                strategyKind: strategyKind,
                sourceSpotAttributionIDs: spotAttributions.map(\.attributionID),
                sourcePerpetualAttributionIDs: perpAttributions.map(\.attributionID),
                spotAttributedNotional: spotNotional,
                perpetualAttributedNotional: perpNotional,
                aggregateAttributedNotional: spotNotional + perpNotional,
                spotAttributedPnL: spotPnL,
                perpetualAttributedPnL: perpPnL,
                aggregateAttributedPnL: spotPnL + perpPnL
            )
        }
    }

    private static func fundingLiquidationSummary(
        from perp: ReleaseV020PerpetualPortfolioProjectionEvidence
    ) throws -> ReleaseV020AggregatePortfolioFundingLiquidationSummary {
        let liquidationReference = try Price(
            ReleaseV020AggregatePortfolioFundingLiquidationSummary.expectedLiquidationReferencePrice(
                positionSide: perp.positionProjection.positionSide,
                entryPrice: perp.positionProjection.entryPrice,
                leverage: perp.marginProjection.leverage
            ),
            field: "releaseV020AggregatePortfolioAttribution.liquidationReferencePrice"
        )
        let liquidationDistance = ReleaseV020AggregatePortfolioFundingLiquidationSummary.expectedLiquidationDistance(
            positionSide: perp.positionProjection.positionSide,
            markPrice: perp.positionProjection.markPrice,
            liquidationReferencePrice: liquidationReference
        )
        return try ReleaseV020AggregatePortfolioFundingLiquidationSummary(
            instrument: perp.positionProjection.instrument,
            positionSide: perp.positionProjection.positionSide,
            leverage: perp.marginProjection.leverage,
            entryPrice: perp.positionProjection.entryPrice,
            markPrice: perp.positionProjection.markPrice,
            fundingRate: perp.fundingProjection.fundingRate,
            fundingPaymentEstimate: perp.fundingProjection.fundingPaymentEstimate,
            nextFundingTime: perp.fundingProjection.nextFundingTime,
            deterministicLiquidationReferencePrice: liquidationReference,
            liquidationDistance: liquidationDistance,
            liquidationDistanceRatio: liquidationDistance / perp.positionProjection.markPrice.rawValue
        )
    }

    private static func aggregateStrategyKind(
        from kind: ReleaseV020SpotPortfolioProjectionStrategyKind
    ) -> ReleaseV020AggregatePortfolioStrategyKind {
        switch kind {
        case .ema:
            return .ema
        case .rsi:
            return .rsi
        }
    }

    private static func aggregateStrategyKind(
        from kind: ReleaseV020PerpetualPortfolioProjectionStrategyKind
    ) -> ReleaseV020AggregatePortfolioStrategyKind {
        switch kind {
        case .ema:
            return .ema
        case .rsi:
            return .rsi
        }
    }
}
