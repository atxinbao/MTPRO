import DomainModel
import ExecutionClient
import Foundation
import MessageBus
import Portfolio

/// ReleaseV020SpotPortfolioProjectionStrategyKind 固定 GH-587 允许归因的 release 策略。
///
/// Spot Portfolio projection 只能把 deterministic fill attribution 绑定到 release v0.2.0
/// 当前 active 的 EMA / RSI 策略；它不能引入新的 active strategy 或交易命令入口。
public enum ReleaseV020SpotPortfolioProjectionStrategyKind:
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

/// ReleaseV020SpotPortfolioProjectionInput 是 GH-587 的 Spot-only BrokerFill 输入。
///
/// 该输入消费 GH-586 normalized BrokerFill evidence，仅允许 Spot fill 进入 Portfolio
/// projection。Perp fill、raw payload、production payload、account endpoint 和 broker
/// position sync 都会在 projection 前被拒绝。
public struct ReleaseV020SpotPortfolioProjectionInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let issueID: Identifier
    public let parserEvidence: ReleaseV020BinanceExecutionReportParserEvidence
    public let spotBrokerFills: [ReleaseV020NormalizedBrokerFill]
    public let validationAnchors: [String]
    public let rawPayloadExposedToPortfolio: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        inputID: Identifier = Identifier.constant("gh-587-spot-portfolio-projection-input"),
        issueID: Identifier = Identifier.constant("GH-587"),
        parserEvidence: ReleaseV020BinanceExecutionReportParserEvidence,
        spotBrokerFills: [ReleaseV020NormalizedBrokerFill]? = nil,
        validationAnchors: [String] = ReleaseV020SpotPortfolioProjection.requiredValidationAnchors,
        rawPayloadExposedToPortfolio: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedFills = spotBrokerFills
            ?? parserEvidence.parseResults
                .map(\.brokerFill)
                .filter { $0.instrument.productType == .spot }
                .sorted { $0.replaySequence < $1.replaySequence }

        guard issueID.rawValue == "GH-587" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.issueID",
                expected: "GH-587",
                actual: issueID.rawValue
            )
        }
        guard parserEvidence.evidenceBoundaryHeld, parserEvidence.issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.parserEvidence",
                expected: "GH-586 evidence boundary held",
                actual: parserEvidence.issueID.rawValue
            )
        }
        guard resolvedFills.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.spotBrokerFills",
                expected: "non-empty Spot BrokerFill evidence",
                actual: "empty"
            )
        }
        guard resolvedFills.allSatisfy({ $0.fillBoundaryHeld && $0.instrument.productType == .spot }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.spotBrokerFills",
                expected: "Spot-only GH-586 BrokerFill evidence",
                actual: resolvedFills.map { $0.instrument.productType.rawValue }.joined(separator: ",")
            )
        }
        guard resolvedFills.allSatisfy({ $0.sourceAdapterIssueID.rawValue == "GH-584" }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.sourceAdapterIssueID",
                expected: "GH-584",
                actual: resolvedFills.map(\.sourceAdapterIssueID.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == ReleaseV020SpotPortfolioProjection.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.validationAnchors",
                expected: ReleaseV020SpotPortfolioProjection.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("rawPayloadExposedToPortfolio", rawPayloadExposedToPortfolio),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerPositionSynced", brokerPositionSynced),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.inputID = inputID
        self.issueID = issueID
        self.parserEvidence = parserEvidence
        self.spotBrokerFills = resolvedFills
        self.validationAnchors = validationAnchors
        self.rawPayloadExposedToPortfolio = rawPayloadExposedToPortfolio
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var inputBoundaryHeld: Bool {
        issueID.rawValue == "GH-587"
            && parserEvidence.evidenceBoundaryHeld
            && parserEvidence.issueID.rawValue == "GH-586"
            && spotBrokerFills.isEmpty == false
            && spotBrokerFills.allSatisfy { $0.fillBoundaryHeld && $0.instrument.productType == .spot }
            && spotBrokerFills.allSatisfy { $0.sourceAdapterIssueID.rawValue == "GH-584" }
            && validationAnchors == ReleaseV020SpotPortfolioProjection.requiredValidationAnchors
            && rawPayloadExposedToPortfolio == false
            && productionAccountEndpointRead == false
            && brokerPositionSynced == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020SpotPortfolioBalanceProjection 固定 GH-587 的 quote balance 更新 evidence。
public struct ReleaseV020SpotPortfolioBalanceProjection: Codable, Equatable, Sendable {
    public let balanceProjectionID: Identifier
    public let quoteAsset: String
    public let startingFreeBalance: Double
    public let quoteSpent: Double
    public let commissionPaid: Double
    public let endingFreeBalance: Double
    public let balanceUpdated: Bool
    public let readsRealBalance: Bool
    public let accountEndpointRead: Bool

    public init(
        balanceProjectionID: Identifier = Identifier.constant("gh-587-spot-balance-projection"),
        quoteAsset: String = "USDT",
        startingFreeBalance: Double,
        quoteSpent: Double,
        commissionPaid: Double,
        endingFreeBalance: Double,
        balanceUpdated: Bool = true,
        readsRealBalance: Bool = false,
        accountEndpointRead: Bool = false
    ) throws {
        let normalizedAsset = quoteAsset.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        try Self.validateFiniteNonNegative(startingFreeBalance, field: "startingFreeBalance")
        try Self.validateFiniteNonNegative(quoteSpent, field: "quoteSpent")
        try Self.validateFiniteNonNegative(commissionPaid, field: "commissionPaid")
        try Self.validateFiniteNonNegative(endingFreeBalance, field: "endingFreeBalance")
        guard normalizedAsset == "USDT" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.quoteAsset",
                expected: "USDT",
                actual: normalizedAsset
            )
        }
        guard abs(endingFreeBalance - (startingFreeBalance - quoteSpent - commissionPaid)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.endingFreeBalance",
                expected: "\(startingFreeBalance - quoteSpent - commissionPaid)",
                actual: "\(endingFreeBalance)"
            )
        }
        guard balanceUpdated else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.balanceUpdated",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("readsRealBalance", readsRealBalance),
            ("accountEndpointRead", accountEndpointRead)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.balance.\(forbiddenFlag.0)"
            )
        }

        self.balanceProjectionID = balanceProjectionID
        self.quoteAsset = normalizedAsset
        self.startingFreeBalance = startingFreeBalance
        self.quoteSpent = quoteSpent
        self.commissionPaid = commissionPaid
        self.endingFreeBalance = endingFreeBalance
        self.balanceUpdated = balanceUpdated
        self.readsRealBalance = readsRealBalance
        self.accountEndpointRead = accountEndpointRead
    }

    public var balanceBoundaryHeld: Bool {
        quoteAsset == "USDT"
            && startingFreeBalance.isFinite
            && quoteSpent.isFinite
            && commissionPaid.isFinite
            && endingFreeBalance.isFinite
            && abs(endingFreeBalance - (startingFreeBalance - quoteSpent - commissionPaid)) < 0.000_000_01
            && balanceUpdated
            && readsRealBalance == false
            && accountEndpointRead == false
    }

    private static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite, value >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.\(field)",
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }
}

/// ReleaseV020SpotPortfolioPositionProjection 固定 GH-587 的 Spot position 更新 evidence。
public struct ReleaseV020SpotPortfolioPositionProjection: Codable, Equatable, Sendable {
    public let positionProjectionID: Identifier
    public let sourceFillIDs: [Identifier]
    public let instrument: InstrumentIdentity
    public let baseAsset: String
    public let positionQuantity: Quantity
    public let averageCost: Price
    public let markPrice: Price
    public let grossPositionNotional: Double
    public let positionUpdated: Bool
    public let brokerPositionSynced: Bool
    public let marginOrLeverageTouched: Bool

    public init(
        positionProjectionID: Identifier = Identifier.constant("gh-587-spot-position-projection"),
        sourceFillIDs: [Identifier],
        instrument: InstrumentIdentity,
        baseAsset: String = "BTC",
        positionQuantity: Quantity,
        averageCost: Price,
        markPrice: Price,
        grossPositionNotional: Double,
        positionUpdated: Bool = true,
        brokerPositionSynced: Bool = false,
        marginOrLeverageTouched: Bool = false
    ) throws {
        let normalizedBaseAsset = baseAsset.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard sourceFillIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.sourceFillIDs",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard instrument.productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.instrument",
                expected: ProductType.spot.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard normalizedBaseAsset == "BTC" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.baseAsset",
                expected: "BTC",
                actual: normalizedBaseAsset
            )
        }
        guard positionQuantity.rawValue > 0, averageCost.rawValue > 0, markPrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.position",
                expected: "positive quantity, cost and mark price",
                actual: "invalid"
            )
        }
        guard abs(grossPositionNotional - positionQuantity.rawValue * markPrice.rawValue) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.grossPositionNotional",
                expected: "\(positionQuantity.rawValue * markPrice.rawValue)",
                actual: "\(grossPositionNotional)"
            )
        }
        guard positionUpdated else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.positionUpdated",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("brokerPositionSynced", brokerPositionSynced),
            ("marginOrLeverageTouched", marginOrLeverageTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.position.\(forbiddenFlag.0)"
            )
        }

        self.positionProjectionID = positionProjectionID
        self.sourceFillIDs = sourceFillIDs
        self.instrument = instrument
        self.baseAsset = normalizedBaseAsset
        self.positionQuantity = positionQuantity
        self.averageCost = averageCost
        self.markPrice = markPrice
        self.grossPositionNotional = grossPositionNotional
        self.positionUpdated = positionUpdated
        self.brokerPositionSynced = brokerPositionSynced
        self.marginOrLeverageTouched = marginOrLeverageTouched
    }

    public var positionBoundaryHeld: Bool {
        sourceFillIDs.isEmpty == false
            && instrument.productType == .spot
            && baseAsset == "BTC"
            && positionQuantity.rawValue > 0
            && averageCost.rawValue > 0
            && markPrice.rawValue > 0
            && abs(grossPositionNotional - positionQuantity.rawValue * markPrice.rawValue) < 0.000_000_01
            && positionUpdated
            && brokerPositionSynced == false
            && marginOrLeverageTouched == false
    }
}

/// ReleaseV020SpotPortfolioPnLProjection 固定 GH-587 的本地 PnL projection evidence。
public struct ReleaseV020SpotPortfolioPnLProjection: Codable, Equatable, Sendable {
    public let pnlProjectionID: Identifier
    public let realizedPnL: Double
    public let unrealizedPnL: Double
    public let commissionPaid: Double
    public let netPnL: Double
    public let pnlProjected: Bool
    public let readsRealPnL: Bool
    public let brokerReconciliationPerformed: Bool

    public init(
        pnlProjectionID: Identifier = Identifier.constant("gh-587-spot-pnl-projection"),
        realizedPnL: Double,
        unrealizedPnL: Double,
        commissionPaid: Double,
        netPnL: Double,
        pnlProjected: Bool = true,
        readsRealPnL: Bool = false,
        brokerReconciliationPerformed: Bool = false
    ) throws {
        for pair in [
            ("realizedPnL", realizedPnL),
            ("unrealizedPnL", unrealizedPnL),
            ("commissionPaid", commissionPaid),
            ("netPnL", netPnL)
        ] where pair.1.isFinite == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.\(pair.0)",
                expected: "finite value",
                actual: "\(pair.1)"
            )
        }
        guard abs(netPnL - (realizedPnL + unrealizedPnL - commissionPaid)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.netPnL",
                expected: "\(realizedPnL + unrealizedPnL - commissionPaid)",
                actual: "\(netPnL)"
            )
        }
        guard pnlProjected else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.pnlProjected",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("readsRealPnL", readsRealPnL),
            ("brokerReconciliationPerformed", brokerReconciliationPerformed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.pnl.\(forbiddenFlag.0)"
            )
        }

        self.pnlProjectionID = pnlProjectionID
        self.realizedPnL = realizedPnL
        self.unrealizedPnL = unrealizedPnL
        self.commissionPaid = commissionPaid
        self.netPnL = netPnL
        self.pnlProjected = pnlProjected
        self.readsRealPnL = readsRealPnL
        self.brokerReconciliationPerformed = brokerReconciliationPerformed
    }

    public var pnlBoundaryHeld: Bool {
        realizedPnL.isFinite
            && unrealizedPnL.isFinite
            && commissionPaid.isFinite
            && netPnL.isFinite
            && abs(netPnL - (realizedPnL + unrealizedPnL - commissionPaid)) < 0.000_000_01
            && pnlProjected
            && readsRealPnL == false
            && brokerReconciliationPerformed == false
    }
}

/// ReleaseV020SpotPortfolioStrategyAttribution 记录 Spot fill 到 EMA / RSI 的 attribution。
public struct ReleaseV020SpotPortfolioStrategyAttribution: Codable, Equatable, Sendable {
    public let attributionID: Identifier
    public let strategyKind: ReleaseV020SpotPortfolioProjectionStrategyKind
    public let sourceFillID: Identifier
    public let attributedQuantity: Quantity
    public let attributedNotional: Double
    public let attributedNetPnL: Double
    public let attributionMapped: Bool
    public let nonEMARSIStrategyEnabled: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        attributionID: Identifier,
        strategyKind: ReleaseV020SpotPortfolioProjectionStrategyKind,
        sourceFillID: Identifier,
        attributedQuantity: Quantity,
        attributedNotional: Double,
        attributedNetPnL: Double,
        attributionMapped: Bool = true,
        nonEMARSIStrategyEnabled: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard attributedQuantity.rawValue > 0,
              attributedNotional.isFinite,
              attributedNotional > 0,
              attributedNetPnL.isFinite else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.strategyAttribution",
                expected: "positive quantity/notional and finite PnL",
                actual: "invalid"
            )
        }
        guard attributionMapped else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.attributionMapped",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("nonEMARSIStrategyEnabled", nonEMARSIStrategyEnabled),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.attribution.\(forbiddenFlag.0)"
            )
        }

        self.attributionID = attributionID
        self.strategyKind = strategyKind
        self.sourceFillID = sourceFillID
        self.attributedQuantity = attributedQuantity
        self.attributedNotional = attributedNotional
        self.attributedNetPnL = attributedNetPnL
        self.attributionMapped = attributionMapped
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var attributionBoundaryHeld: Bool {
        ReleaseV020SpotPortfolioProjectionStrategyKind.allCases.contains(strategyKind)
            && attributedQuantity.rawValue > 0
            && attributedNotional > 0
            && attributedNotional.isFinite
            && attributedNetPnL.isFinite
            && attributionMapped
            && nonEMARSIStrategyEnabled == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020SpotPortfolioProjectionEvidence 汇总 GH-587 Spot Portfolio projection evidence。
/// `TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION`
public struct ReleaseV020SpotPortfolioProjectionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sourceParserEvidenceID: Identifier
    public let sourceFillIDs: [Identifier]
    public let balanceProjection: ReleaseV020SpotPortfolioBalanceProjection
    public let positionProjection: ReleaseV020SpotPortfolioPositionProjection
    public let pnlProjection: ReleaseV020SpotPortfolioPnLProjection
    public let strategyAttributions: [ReleaseV020SpotPortfolioStrategyAttribution]
    public let exposureSnapshot: PortfolioExposureSnapshot
    public let financialStateProjection: PortfolioFinancialStateProjection
    public let validationAnchors: [String]
    public let balancesUpdated: Bool
    public let positionUpdated: Bool
    public let pnlProjected: Bool
    public let strategyAttributionComplete: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-587-spot-portfolio-projection-evidence"),
        issueID: Identifier = Identifier.constant("GH-587"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-586")],
        sourceParserEvidenceID: Identifier,
        sourceFillIDs: [Identifier],
        balanceProjection: ReleaseV020SpotPortfolioBalanceProjection,
        positionProjection: ReleaseV020SpotPortfolioPositionProjection,
        pnlProjection: ReleaseV020SpotPortfolioPnLProjection,
        strategyAttributions: [ReleaseV020SpotPortfolioStrategyAttribution],
        exposureSnapshot: PortfolioExposureSnapshot,
        financialStateProjection: PortfolioFinancialStateProjection,
        validationAnchors: [String] = ReleaseV020SpotPortfolioProjection.requiredValidationAnchors,
        balancesUpdated: Bool = true,
        positionUpdated: Bool = true,
        pnlProjected: Bool = true,
        strategyAttributionComplete: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-587" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.evidenceIssueID",
                expected: "GH-587",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-586"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.upstreamIssueIDs",
                expected: "GH-586",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceFillIDs.isEmpty == false, sourceFillIDs == positionProjection.sourceFillIDs else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.sourceFillIDs",
                expected: positionProjection.sourceFillIDs.map(\.rawValue).joined(separator: ","),
                actual: sourceFillIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard balanceProjection.balanceBoundaryHeld,
              positionProjection.positionBoundaryHeld,
              pnlProjection.pnlBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.subProjectionBoundary",
                expected: "balance, position and PnL boundaries held",
                actual: "mismatch"
            )
        }
        guard strategyAttributions.isEmpty == false,
              strategyAttributions.allSatisfy(\.attributionBoundaryHeld),
              Set(strategyAttributions.map(\.strategyKind)) == Set(ReleaseV020SpotPortfolioProjectionStrategyKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.strategyAttribution",
                expected: "EMA and RSI attribution evidence",
                actual: strategyAttributions.map(\.strategyKind.rawValue).joined(separator: ",")
            )
        }
        guard exposureSnapshot.source == .paperProjection,
              exposureSnapshot.portfolioID == financialStateProjection.portfolioID,
              financialStateProjection.paperOnlyBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.financialStateProjection",
                expected: "Portfolio financial state projection boundary held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020SpotPortfolioProjection.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.validationAnchors",
                expected: ReleaseV020SpotPortfolioProjection.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("balancesUpdated", balancesUpdated),
            ("positionUpdated", positionUpdated),
            ("pnlProjected", pnlProjected),
            ("strategyAttributionComplete", strategyAttributionComplete)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sourceParserEvidenceID = sourceParserEvidenceID
        self.sourceFillIDs = sourceFillIDs
        self.balanceProjection = balanceProjection
        self.positionProjection = positionProjection
        self.pnlProjection = pnlProjection
        self.strategyAttributions = strategyAttributions
        self.exposureSnapshot = exposureSnapshot
        self.financialStateProjection = financialStateProjection
        self.validationAnchors = validationAnchors
        self.balancesUpdated = balancesUpdated
        self.positionUpdated = positionUpdated
        self.pnlProjected = pnlProjected
        self.strategyAttributionComplete = strategyAttributionComplete
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-587"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-586"]
            && sourceFillIDs.isEmpty == false
            && balanceProjection.balanceBoundaryHeld
            && positionProjection.positionBoundaryHeld
            && pnlProjection.pnlBoundaryHeld
            && strategyAttributions.allSatisfy(\.attributionBoundaryHeld)
            && Set(strategyAttributions.map(\.strategyKind)) == Set(ReleaseV020SpotPortfolioProjectionStrategyKind.allCases)
            && exposureSnapshot.source == .paperProjection
            && financialStateProjection.paperOnlyBoundaryHeld
            && validationAnchors == ReleaseV020SpotPortfolioProjection.requiredValidationAnchors
            && balancesUpdated
            && positionUpdated
            && pnlProjected
            && strategyAttributionComplete
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020SpotPortfolioProjection 是 GH-587 的 deterministic Spot Portfolio projection builder。
///
/// Builder 只消费 GH-586 normalized Spot BrokerFill，计算 quote balance、base position、
/// local PnL projection 与 EMA / RSI attribution evidence。它不读取真实账户、不同步 broker
/// position、不执行 reconciliation runtime，也不 mutate production Portfolio runtime。
public struct ReleaseV020SpotPortfolioProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let issueID: Identifier
    public let input: ReleaseV020SpotPortfolioProjectionInput
    public let portfolioID: Identifier
    public let startingQuoteBalance: Double
    public let markPrice: Price
    public let projectedAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        projectionID: Identifier = Identifier.constant("gh-587-spot-portfolio-projection"),
        issueID: Identifier = Identifier.constant("GH-587"),
        input: ReleaseV020SpotPortfolioProjectionInput,
        portfolioID: Identifier = Identifier.constant("gh-587-spot-portfolio"),
        startingQuoteBalance: Double = 100_000,
        markPrice: Price? = nil,
        projectedAt: Date = Date(timeIntervalSince1970: 1_801_180_800),
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMarkPrice = try markPrice
            ?? Price(42_250.70, field: "releaseV020SpotPortfolioProjection.markPrice")
        guard issueID.rawValue == "GH-587" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.projectionIssueID",
                expected: "GH-587",
                actual: issueID.rawValue
            )
        }
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.inputBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard startingQuoteBalance.isFinite, startingQuoteBalance > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.startingQuoteBalance",
                expected: "positive finite balance",
                actual: "\(startingQuoteBalance)"
            )
        }
        guard resolvedMarkPrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.markPrice",
                expected: "positive mark price",
                actual: "\(resolvedMarkPrice.rawValue)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.projectionID = projectionID
        self.issueID = issueID
        self.input = input
        self.portfolioID = portfolioID
        self.startingQuoteBalance = startingQuoteBalance
        self.markPrice = resolvedMarkPrice
        self.projectedAt = projectedAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var projectionBoundaryHeld: Bool {
        issueID.rawValue == "GH-587"
            && input.inputBoundaryHeld
            && startingQuoteBalance > 0
            && markPrice.rawValue > 0
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }

    /// 生成 GH-587 deterministic Spot Portfolio projection evidence。
    public func deterministicEvidence() throws -> ReleaseV020SpotPortfolioProjectionEvidence {
        guard projectionBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.projectionBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        let fills = input.spotBrokerFills.sorted { $0.replaySequence < $1.replaySequence }
        let sourceFillIDs = fills.map(\.fillID)
        let totalQuantity = fills.reduce(0.0) { $0 + $1.lastExecutedQuantity.rawValue }
        let quoteSpent = fills.reduce(0.0) { $0 + ($1.lastExecutedQuantity.rawValue * $1.lastExecutedPrice.rawValue) }
        let commissionPaid = fills.reduce(0.0) { $0 + (Double($1.commissionAmount) ?? 0) }
        let averageCost = quoteSpent / totalQuantity
        let unrealizedPnL = totalQuantity * (markPrice.rawValue - averageCost)
        let netPnL = unrealizedPnL - commissionPaid

        let balance = try ReleaseV020SpotPortfolioBalanceProjection(
            startingFreeBalance: startingQuoteBalance,
            quoteSpent: quoteSpent,
            commissionPaid: commissionPaid,
            endingFreeBalance: startingQuoteBalance - quoteSpent - commissionPaid
        )
        let position = try ReleaseV020SpotPortfolioPositionProjection(
            sourceFillIDs: sourceFillIDs,
            instrument: try Self.singleInstrument(from: fills),
            positionQuantity: try Quantity(totalQuantity, field: "releaseV020SpotPortfolioProjection.positionQuantity"),
            averageCost: try Price(averageCost, field: "releaseV020SpotPortfolioProjection.averageCost"),
            markPrice: markPrice,
            grossPositionNotional: totalQuantity * markPrice.rawValue
        )
        let pnl = try ReleaseV020SpotPortfolioPnLProjection(
            realizedPnL: 0,
            unrealizedPnL: unrealizedPnL,
            commissionPaid: commissionPaid,
            netPnL: netPnL
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: portfolioID,
            symbol: position.instrument.symbol,
            timeframe: .oneMinute,
            paperQuantity: position.positionQuantity,
            referencePrice: markPrice,
            source: .paperProjection,
            observedAt: projectedAt
        )
        let financialState = try PortfolioFinancialStateProjection(
            projectionID: Identifier.constant("gh-587-spot-financial-state-projection"),
            exposure: exposure,
            projectedAt: projectedAt
        )

        return try ReleaseV020SpotPortfolioProjectionEvidence(
            sourceParserEvidenceID: input.parserEvidence.evidenceID,
            sourceFillIDs: sourceFillIDs,
            balanceProjection: balance,
            positionProjection: position,
            pnlProjection: pnl,
            strategyAttributions: try Self.strategyAttributions(fills: fills, netPnL: netPnL),
            exposureSnapshot: exposure,
            financialStateProjection: financialState
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020SpotPortfolioProjection {
        let parser = try ReleaseV020BinanceExecutionReportParser.deterministicFixture()
        let parserEvidence = try parser.deterministicParserEvidence()
        let input = try ReleaseV020SpotPortfolioProjectionInput(parserEvidence: parserEvidence)
        return try ReleaseV020SpotPortfolioProjection(input: input)
    }

    public static let requiredValidationAnchors = [
        "GH-587-SPOT-PORTFOLIO-PROJECTION",
        "GH-587-SPOT-BALANCE-UPDATE",
        "GH-587-SPOT-POSITION-UPDATE",
        "GH-587-SPOT-PNL-PROJECTION",
        "GH-587-STRATEGY-ATTRIBUTION",
        "GH-587-NO-PRODUCTION-ACCOUNT-READ",
        "TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION"
    ]

    private static func singleInstrument(
        from fills: [ReleaseV020NormalizedBrokerFill]
    ) throws -> InstrumentIdentity {
        guard let first = fills.first else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.fills",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard fills.allSatisfy({ $0.instrument == first.instrument }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPortfolioProjection.instrument",
                expected: first.instrument.rawValue,
                actual: fills.map(\.instrument.rawValue).joined(separator: ",")
            )
        }
        return first.instrument
    }

    private static func strategyAttributions(
        fills: [ReleaseV020NormalizedBrokerFill],
        netPnL: Double
    ) throws -> [ReleaseV020SpotPortfolioStrategyAttribution] {
        try fills.enumerated().map { index, fill in
            let strategyKind: ReleaseV020SpotPortfolioProjectionStrategyKind = index.isMultiple(of: 2) ? .ema : .rsi
            let notional = fill.lastExecutedQuantity.rawValue * fill.lastExecutedPrice.rawValue
            let pnlShare = netPnL * (notional / fills.totalNotional)
            return try ReleaseV020SpotPortfolioStrategyAttribution(
                attributionID: Identifier.constant(
                    "gh-587-\(strategyKind.rawValue.lowercased())-\(fill.reportKind.rawValue.replacingOccurrences(of: " ", with: "-"))-attribution"
                ),
                strategyKind: strategyKind,
                sourceFillID: fill.fillID,
                attributedQuantity: fill.lastExecutedQuantity,
                attributedNotional: notional,
                attributedNetPnL: pnlShare
            )
        }
    }
}

private extension Array where Element == ReleaseV020NormalizedBrokerFill {
    var totalNotional: Double {
        reduce(0.0) { $0 + ($1.lastExecutedQuantity.rawValue * $1.lastExecutedPrice.rawValue) }
    }
}
