import Cache
import DomainModel
import ExecutionClient
import Foundation
import MessageBus
import Portfolio

/// ReleaseV020PerpetualPortfolioProjectionStrategyKind 固定 GH-588 允许归因的 release 策略。
///
/// Perpetual Portfolio projection 只能把 deterministic fill attribution 绑定到 release v0.2.0
/// 当前 active 的 EMA / RSI 策略；它不能引入新的 active strategy 或 live command surface。
public enum ReleaseV020PerpetualPortfolioProjectionStrategyKind:
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

/// ReleaseV020PerpetualPortfolioProjectionInput 是 GH-588 的 Perp-only projection 输入。
///
/// 输入消费 GH-586 normalized Perp BrokerFill / position update evidence 和 GH-575 public
/// mark / funding read models。它不读取 production account endpoint、不读取真实 margin、
/// 不同步 broker position，也不执行 leverage / margin action。
public struct ReleaseV020PerpetualPortfolioProjectionInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let issueID: Identifier
    public let parserEvidence: ReleaseV020BinanceExecutionReportParserEvidence
    public let perpParseResults: [ReleaseV020BinanceExecutionReportParseResult]
    public let markPriceReadModel: PerpetualMarkPriceReadModel
    public let fundingReadModel: PerpetualFundingRateReadModel
    public let validationAnchors: [String]
    public let productionAccountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        inputID: Identifier = Identifier.constant("gh-588-perpetual-portfolio-projection-input"),
        issueID: Identifier = Identifier.constant("GH-588"),
        parserEvidence: ReleaseV020BinanceExecutionReportParserEvidence,
        perpParseResults: [ReleaseV020BinanceExecutionReportParseResult]? = nil,
        markPriceReadModel: PerpetualMarkPriceReadModel,
        fundingReadModel: PerpetualFundingRateReadModel,
        validationAnchors: [String] = ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors,
        productionAccountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedResults = perpParseResults
            ?? parserEvidence.parseResults
                .filter { $0.brokerFill.instrument.productType == .usdsPerpetual }
                .sorted { $0.brokerFill.replaySequence < $1.brokerFill.replaySequence }

        guard issueID.rawValue == "GH-588" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.issueID",
                expected: "GH-588",
                actual: issueID.rawValue
            )
        }
        guard parserEvidence.evidenceBoundaryHeld, parserEvidence.issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.parserEvidence",
                expected: "GH-586 evidence boundary held",
                actual: parserEvidence.issueID.rawValue
            )
        }
        guard resolvedResults.isEmpty == false,
              resolvedResults.allSatisfy({
                  $0.resultBoundaryHeld
                      && $0.brokerFill.instrument.productType == .usdsPerpetual
                      && $0.positionUpdate?.positionUpdateBoundaryHeld == true
              }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.perpParseResults",
                expected: "Perp BrokerFill with position update evidence",
                actual: resolvedResults.map { $0.brokerFill.instrument.productType.rawValue }.joined(separator: ",")
            )
        }
        guard resolvedResults.allSatisfy({ $0.brokerFill.sourceAdapterIssueID.rawValue == "GH-585" }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.sourceAdapterIssueID",
                expected: "GH-585",
                actual: resolvedResults.map(\.brokerFill.sourceAdapterIssueID.rawValue).joined(separator: ",")
            )
        }
        let instrument = try Self.singleInstrument(from: resolvedResults)
        guard markPriceReadModel.instrument == instrument,
              fundingReadModel.instrument == instrument,
              markPriceReadModel.freshness.isFresh,
              fundingReadModel.freshness.isFresh else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.marketReadModels",
                expected: "\(instrument.rawValue) fresh mark/funding",
                actual: "\(markPriceReadModel.instrument.rawValue)/\(fundingReadModel.instrument.rawValue)"
            )
        }
        guard validationAnchors == ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.validationAnchors",
                expected: ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerPositionSynced", brokerPositionSynced),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.inputID = inputID
        self.issueID = issueID
        self.parserEvidence = parserEvidence
        self.perpParseResults = resolvedResults
        self.markPriceReadModel = markPriceReadModel
        self.fundingReadModel = fundingReadModel
        self.validationAnchors = validationAnchors
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var inputBoundaryHeld: Bool {
        issueID.rawValue == "GH-588"
            && parserEvidence.evidenceBoundaryHeld
            && perpParseResults.isEmpty == false
            && perpParseResults.allSatisfy {
                $0.resultBoundaryHeld
                    && $0.brokerFill.instrument.productType == .usdsPerpetual
                    && $0.positionUpdate?.positionUpdateBoundaryHeld == true
            }
            && markPriceReadModel.instrument.productType == .usdsPerpetual
            && fundingReadModel.instrument == markPriceReadModel.instrument
            && markPriceReadModel.freshness.isFresh
            && fundingReadModel.freshness.isFresh
            && validationAnchors == ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors
            && productionAccountEndpointRead == false
            && brokerPositionSynced == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }

    private static func singleInstrument(
        from results: [ReleaseV020BinanceExecutionReportParseResult]
    ) throws -> InstrumentIdentity {
        guard let first = results.first?.brokerFill.instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.perpParseResults",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard results.allSatisfy({ $0.brokerFill.instrument == first }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.instrument",
                expected: first.rawValue,
                actual: results.map(\.brokerFill.instrument.rawValue).joined(separator: ",")
            )
        }
        return first
    }
}

/// ReleaseV020PerpetualPortfolioPositionProjection 固定 GH-588 的 Perp position evidence。
public struct ReleaseV020PerpetualPortfolioPositionProjection: Codable, Equatable, Sendable {
    public let positionProjectionID: Identifier
    public let sourceFillIDs: [Identifier]
    public let sourcePositionUpdateIDs: [Identifier]
    public let instrument: InstrumentIdentity
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide
    public let positionAmt: Quantity
    public let entryPrice: Price
    public let markPrice: Price
    public let positionNotional: Double
    public let positionUpdated: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool

    public init(
        positionProjectionID: Identifier = Identifier.constant("gh-588-perpetual-position-projection"),
        sourceFillIDs: [Identifier],
        sourcePositionUpdateIDs: [Identifier],
        instrument: InstrumentIdentity,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        positionAmt: Quantity,
        entryPrice: Price,
        markPrice: Price,
        positionNotional: Double,
        positionUpdated: Bool = true,
        accountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false
    ) throws {
        guard sourceFillIDs.isEmpty == false,
              sourcePositionUpdateIDs.isEmpty == false,
              sourceFillIDs.count == sourcePositionUpdateIDs.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.sourceIDs",
                expected: "paired fill and position update IDs",
                actual: "\(sourceFillIDs.count)/\(sourcePositionUpdateIDs.count)"
            )
        }
        guard instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.instrument",
                expected: ProductType.usdsPerpetual.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard entryPrice.rawValue > 0,
              markPrice.rawValue > 0,
              positionNotional.isFinite,
              positionNotional >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.position",
                expected: "positive prices and finite non-negative notional",
                actual: "invalid"
            )
        }
        guard abs(positionNotional - positionAmt.rawValue * markPrice.rawValue) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.positionNotional",
                expected: "\(positionAmt.rawValue * markPrice.rawValue)",
                actual: "\(positionNotional)"
            )
        }
        guard positionUpdated else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.positionUpdated",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("accountEndpointRead", accountEndpointRead),
            ("brokerPositionSynced", brokerPositionSynced),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.position.\(forbiddenFlag.0)"
            )
        }

        self.positionProjectionID = positionProjectionID
        self.sourceFillIDs = sourceFillIDs
        self.sourcePositionUpdateIDs = sourcePositionUpdateIDs
        self.instrument = instrument
        self.positionSide = positionSide
        self.positionAmt = positionAmt
        self.entryPrice = entryPrice
        self.markPrice = markPrice
        self.positionNotional = positionNotional
        self.positionUpdated = positionUpdated
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
    }

    public var positionBoundaryHeld: Bool {
        sourceFillIDs.isEmpty == false
            && sourceFillIDs.count == sourcePositionUpdateIDs.count
            && instrument.productType == .usdsPerpetual
            && entryPrice.rawValue > 0
            && markPrice.rawValue > 0
            && abs(positionNotional - positionAmt.rawValue * markPrice.rawValue) < 0.000_000_01
            && positionUpdated
            && accountEndpointRead == false
            && brokerPositionSynced == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
    }
}

/// ReleaseV020PerpetualPortfolioMarginProjection 固定 GH-588 的 local margin evidence。
public struct ReleaseV020PerpetualPortfolioMarginProjection: Codable, Equatable, Sendable {
    public let marginProjectionID: Identifier
    public let leverage: Double
    public let positionNotional: Double
    public let marginRequirement: Double
    public let marginAsset: String
    public let marginProjected: Bool
    public let readsAccountMargin: Bool
    public let marginActionExecuted: Bool

    public init(
        marginProjectionID: Identifier = Identifier.constant("gh-588-perpetual-margin-projection"),
        leverage: Double,
        positionNotional: Double,
        marginRequirement: Double,
        marginAsset: String = "USDT",
        marginProjected: Bool = true,
        readsAccountMargin: Bool = false,
        marginActionExecuted: Bool = false
    ) throws {
        let normalizedAsset = marginAsset.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard leverage.isFinite,
              leverage > 0,
              positionNotional.isFinite,
              positionNotional >= 0,
              marginRequirement.isFinite,
              marginRequirement >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.margin",
                expected: "positive leverage and finite non-negative margin values",
                actual: "invalid"
            )
        }
        guard normalizedAsset == "USDT" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.marginAsset",
                expected: "USDT",
                actual: normalizedAsset
            )
        }
        guard abs(marginRequirement - positionNotional / leverage) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.marginRequirement",
                expected: "\(positionNotional / leverage)",
                actual: "\(marginRequirement)"
            )
        }
        guard marginProjected else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.marginProjected",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("readsAccountMargin", readsAccountMargin),
            ("marginActionExecuted", marginActionExecuted)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.margin.\(forbiddenFlag.0)"
            )
        }

        self.marginProjectionID = marginProjectionID
        self.leverage = leverage
        self.positionNotional = positionNotional
        self.marginRequirement = marginRequirement
        self.marginAsset = normalizedAsset
        self.marginProjected = marginProjected
        self.readsAccountMargin = readsAccountMargin
        self.marginActionExecuted = marginActionExecuted
    }

    public var marginBoundaryHeld: Bool {
        leverage > 0
            && positionNotional >= 0
            && marginRequirement >= 0
            && abs(marginRequirement - positionNotional / leverage) < 0.000_000_01
            && marginAsset == "USDT"
            && marginProjected
            && readsAccountMargin == false
            && marginActionExecuted == false
    }
}

/// ReleaseV020PerpetualPortfolioFundingProjection 固定 GH-588 的 funding projection evidence。
public struct ReleaseV020PerpetualPortfolioFundingProjection: Codable, Equatable, Sendable {
    public let fundingProjectionID: Identifier
    public let fundingRate: Double
    public let nextFundingTime: Date
    public let positionNotional: Double
    public let fundingPaymentEstimate: Double
    public let fundingProjected: Bool
    public let fundingSettlementTouched: Bool
    public let brokerStatementRead: Bool

    public init(
        fundingProjectionID: Identifier = Identifier.constant("gh-588-perpetual-funding-projection"),
        fundingRate: Double,
        nextFundingTime: Date,
        positionNotional: Double,
        fundingPaymentEstimate: Double,
        fundingProjected: Bool = true,
        fundingSettlementTouched: Bool = false,
        brokerStatementRead: Bool = false
    ) throws {
        guard fundingRate.isFinite,
              positionNotional.isFinite,
              positionNotional >= 0,
              fundingPaymentEstimate.isFinite else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.funding",
                expected: "finite funding values",
                actual: "invalid"
            )
        }
        guard abs(fundingPaymentEstimate - positionNotional * fundingRate) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.fundingPaymentEstimate",
                expected: "\(positionNotional * fundingRate)",
                actual: "\(fundingPaymentEstimate)"
            )
        }
        guard fundingProjected else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.fundingProjected",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("fundingSettlementTouched", fundingSettlementTouched),
            ("brokerStatementRead", brokerStatementRead)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.funding.\(forbiddenFlag.0)"
            )
        }

        self.fundingProjectionID = fundingProjectionID
        self.fundingRate = fundingRate
        self.nextFundingTime = nextFundingTime
        self.positionNotional = positionNotional
        self.fundingPaymentEstimate = fundingPaymentEstimate
        self.fundingProjected = fundingProjected
        self.fundingSettlementTouched = fundingSettlementTouched
        self.brokerStatementRead = brokerStatementRead
    }

    public var fundingBoundaryHeld: Bool {
        fundingRate.isFinite
            && positionNotional >= 0
            && abs(fundingPaymentEstimate - positionNotional * fundingRate) < 0.000_000_01
            && fundingProjected
            && fundingSettlementTouched == false
            && brokerStatementRead == false
    }
}

/// ReleaseV020PerpetualPortfolioPnLProjection 固定 GH-588 的 Perp PnL evidence。
public struct ReleaseV020PerpetualPortfolioPnLProjection: Codable, Equatable, Sendable {
    public let pnlProjectionID: Identifier
    public let realizedPnL: Double
    public let unrealizedPnL: Double
    public let commissionPaid: Double
    public let fundingPaymentEstimate: Double
    public let netPnL: Double
    public let pnlProjected: Bool
    public let readsRealPnL: Bool
    public let brokerReconciliationPerformed: Bool

    public init(
        pnlProjectionID: Identifier = Identifier.constant("gh-588-perpetual-pnl-projection"),
        realizedPnL: Double,
        unrealizedPnL: Double,
        commissionPaid: Double,
        fundingPaymentEstimate: Double,
        netPnL: Double,
        pnlProjected: Bool = true,
        readsRealPnL: Bool = false,
        brokerReconciliationPerformed: Bool = false
    ) throws {
        for pair in [
            ("realizedPnL", realizedPnL),
            ("unrealizedPnL", unrealizedPnL),
            ("commissionPaid", commissionPaid),
            ("fundingPaymentEstimate", fundingPaymentEstimate),
            ("netPnL", netPnL)
        ] where pair.1.isFinite == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.\(pair.0)",
                expected: "finite value",
                actual: "\(pair.1)"
            )
        }
        guard abs(netPnL - (realizedPnL + unrealizedPnL - commissionPaid - fundingPaymentEstimate)) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.netPnL",
                expected: "\(realizedPnL + unrealizedPnL - commissionPaid - fundingPaymentEstimate)",
                actual: "\(netPnL)"
            )
        }
        guard pnlProjected else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.pnlProjected",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("readsRealPnL", readsRealPnL),
            ("brokerReconciliationPerformed", brokerReconciliationPerformed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.pnl.\(forbiddenFlag.0)"
            )
        }

        self.pnlProjectionID = pnlProjectionID
        self.realizedPnL = realizedPnL
        self.unrealizedPnL = unrealizedPnL
        self.commissionPaid = commissionPaid
        self.fundingPaymentEstimate = fundingPaymentEstimate
        self.netPnL = netPnL
        self.pnlProjected = pnlProjected
        self.readsRealPnL = readsRealPnL
        self.brokerReconciliationPerformed = brokerReconciliationPerformed
    }

    public var pnlBoundaryHeld: Bool {
        realizedPnL.isFinite
            && unrealizedPnL.isFinite
            && commissionPaid.isFinite
            && fundingPaymentEstimate.isFinite
            && netPnL.isFinite
            && abs(netPnL - (realizedPnL + unrealizedPnL - commissionPaid - fundingPaymentEstimate)) < 0.000_000_01
            && pnlProjected
            && readsRealPnL == false
            && brokerReconciliationPerformed == false
    }
}

/// ReleaseV020PerpetualPortfolioStrategyAttribution 记录 Perp fill 到 EMA / RSI 的 attribution。
public struct ReleaseV020PerpetualPortfolioStrategyAttribution: Codable, Equatable, Sendable {
    public let attributionID: Identifier
    public let strategyKind: ReleaseV020PerpetualPortfolioProjectionStrategyKind
    public let sourceFillID: Identifier
    public let attributedQuantity: Quantity
    public let attributedNotional: Double
    public let attributedRealizedPnL: Double
    public let attributionMapped: Bool
    public let nonEMARSIStrategyEnabled: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        attributionID: Identifier,
        strategyKind: ReleaseV020PerpetualPortfolioProjectionStrategyKind,
        sourceFillID: Identifier,
        attributedQuantity: Quantity,
        attributedNotional: Double,
        attributedRealizedPnL: Double,
        attributionMapped: Bool = true,
        nonEMARSIStrategyEnabled: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard attributedQuantity.rawValue > 0,
              attributedNotional.isFinite,
              attributedNotional > 0,
              attributedRealizedPnL.isFinite else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.strategyAttribution",
                expected: "positive quantity/notional and finite realized PnL",
                actual: "invalid"
            )
        }
        guard attributionMapped else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.attributionMapped",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("nonEMARSIStrategyEnabled", nonEMARSIStrategyEnabled),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.attribution.\(forbiddenFlag.0)"
            )
        }

        self.attributionID = attributionID
        self.strategyKind = strategyKind
        self.sourceFillID = sourceFillID
        self.attributedQuantity = attributedQuantity
        self.attributedNotional = attributedNotional
        self.attributedRealizedPnL = attributedRealizedPnL
        self.attributionMapped = attributionMapped
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var attributionBoundaryHeld: Bool {
        ReleaseV020PerpetualPortfolioProjectionStrategyKind.allCases.contains(strategyKind)
            && attributedQuantity.rawValue > 0
            && attributedNotional > 0
            && attributedNotional.isFinite
            && attributedRealizedPnL.isFinite
            && attributionMapped
            && nonEMARSIStrategyEnabled == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020PerpetualPortfolioProjectionEvidence 汇总 GH-588 Perp Portfolio projection evidence。
/// `TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION`
public struct ReleaseV020PerpetualPortfolioProjectionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sourceParserEvidenceID: Identifier
    public let sourceFillIDs: [Identifier]
    public let sourcePositionUpdateIDs: [Identifier]
    public let positionProjection: ReleaseV020PerpetualPortfolioPositionProjection
    public let marginProjection: ReleaseV020PerpetualPortfolioMarginProjection
    public let pnlProjection: ReleaseV020PerpetualPortfolioPnLProjection
    public let fundingProjection: ReleaseV020PerpetualPortfolioFundingProjection
    public let strategyAttributions: [ReleaseV020PerpetualPortfolioStrategyAttribution]
    public let exposureSnapshot: PortfolioExposureSnapshot
    public let financialStateProjection: PortfolioFinancialStateProjection
    public let validationAnchors: [String]
    public let positionUpdated: Bool
    public let marginProjected: Bool
    public let pnlProjected: Bool
    public let fundingProjected: Bool
    public let strategyAttributionComplete: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-588-perpetual-portfolio-projection-evidence"),
        issueID: Identifier = Identifier.constant("GH-588"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-575"),
            Identifier.constant("GH-586")
        ],
        sourceParserEvidenceID: Identifier,
        sourceFillIDs: [Identifier],
        sourcePositionUpdateIDs: [Identifier],
        positionProjection: ReleaseV020PerpetualPortfolioPositionProjection,
        marginProjection: ReleaseV020PerpetualPortfolioMarginProjection,
        pnlProjection: ReleaseV020PerpetualPortfolioPnLProjection,
        fundingProjection: ReleaseV020PerpetualPortfolioFundingProjection,
        strategyAttributions: [ReleaseV020PerpetualPortfolioStrategyAttribution],
        exposureSnapshot: PortfolioExposureSnapshot,
        financialStateProjection: PortfolioFinancialStateProjection,
        validationAnchors: [String] = ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors,
        positionUpdated: Bool = true,
        marginProjected: Bool = true,
        pnlProjected: Bool = true,
        fundingProjected: Bool = true,
        strategyAttributionComplete: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-588" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.evidenceIssueID",
                expected: "GH-588",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-575", "GH-586"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.upstreamIssueIDs",
                expected: "GH-575,GH-586",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceFillIDs == positionProjection.sourceFillIDs,
              sourcePositionUpdateIDs == positionProjection.sourcePositionUpdateIDs else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.sourceIDs",
                expected: positionProjection.sourceFillIDs.map(\.rawValue).joined(separator: ","),
                actual: sourceFillIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard positionProjection.positionBoundaryHeld,
              marginProjection.marginBoundaryHeld,
              pnlProjection.pnlBoundaryHeld,
              fundingProjection.fundingBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.subProjectionBoundary",
                expected: "position, margin, PnL and funding boundaries held",
                actual: "mismatch"
            )
        }
        guard strategyAttributions.isEmpty == false,
              strategyAttributions.allSatisfy(\.attributionBoundaryHeld),
              Set(strategyAttributions.map(\.strategyKind)) == Set(ReleaseV020PerpetualPortfolioProjectionStrategyKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.strategyAttribution",
                expected: "EMA and RSI attribution evidence",
                actual: strategyAttributions.map(\.strategyKind.rawValue).joined(separator: ",")
            )
        }
        guard exposureSnapshot.source == .paperProjection,
              exposureSnapshot.portfolioID == financialStateProjection.portfolioID,
              financialStateProjection.paperOnlyBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.financialStateProjection",
                expected: "Portfolio financial state projection boundary held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.validationAnchors",
                expected: ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("positionUpdated", positionUpdated),
            ("marginProjected", marginProjected),
            ("pnlProjected", pnlProjected),
            ("fundingProjected", fundingProjected),
            ("strategyAttributionComplete", strategyAttributionComplete)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sourceParserEvidenceID = sourceParserEvidenceID
        self.sourceFillIDs = sourceFillIDs
        self.sourcePositionUpdateIDs = sourcePositionUpdateIDs
        self.positionProjection = positionProjection
        self.marginProjection = marginProjection
        self.pnlProjection = pnlProjection
        self.fundingProjection = fundingProjection
        self.strategyAttributions = strategyAttributions
        self.exposureSnapshot = exposureSnapshot
        self.financialStateProjection = financialStateProjection
        self.validationAnchors = validationAnchors
        self.positionUpdated = positionUpdated
        self.marginProjected = marginProjected
        self.pnlProjected = pnlProjected
        self.fundingProjected = fundingProjected
        self.strategyAttributionComplete = strategyAttributionComplete
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-588"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-575", "GH-586"]
            && positionProjection.positionBoundaryHeld
            && marginProjection.marginBoundaryHeld
            && pnlProjection.pnlBoundaryHeld
            && fundingProjection.fundingBoundaryHeld
            && strategyAttributions.allSatisfy(\.attributionBoundaryHeld)
            && Set(strategyAttributions.map(\.strategyKind)) == Set(ReleaseV020PerpetualPortfolioProjectionStrategyKind.allCases)
            && exposureSnapshot.source == .paperProjection
            && financialStateProjection.paperOnlyBoundaryHeld
            && validationAnchors == ReleaseV020PerpetualPortfolioProjection.requiredValidationAnchors
            && positionUpdated
            && marginProjected
            && pnlProjected
            && fundingProjected
            && strategyAttributionComplete
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020PerpetualPortfolioProjection 是 GH-588 的 deterministic Perp Portfolio builder。
///
/// Builder 只消费 GH-586 Perp BrokerFill / position update evidence 和 GH-575 public
/// mark/funding read model，计算 positionAmt、entry / mark price、margin、PnL、funding 和
/// EMA / RSI attribution。它不读取真实账户、不同步 broker position、不执行 reconciliation
/// runtime，也不 mutate production Portfolio runtime。
public struct ReleaseV020PerpetualPortfolioProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let issueID: Identifier
    public let input: ReleaseV020PerpetualPortfolioProjectionInput
    public let portfolioID: Identifier
    public let entryPrice: Price
    public let leverage: Double
    public let projectedAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let brokerPositionSynced: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool
    public let portfolioRuntimeMutated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        projectionID: Identifier = Identifier.constant("gh-588-perpetual-portfolio-projection"),
        issueID: Identifier = Identifier.constant("GH-588"),
        input: ReleaseV020PerpetualPortfolioProjectionInput,
        portfolioID: Identifier = Identifier.constant("gh-588-perpetual-portfolio"),
        entryPrice: Price? = nil,
        leverage: Double = 5,
        projectedAt: Date = Date(timeIntervalSince1970: 1_801_267_200),
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        brokerPositionSynced: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedEntryPrice = try entryPrice
            ?? Price(43_000, field: "releaseV020PerpetualPortfolioProjection.entryPrice")
        guard issueID.rawValue == "GH-588" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.projectionIssueID",
                expected: "GH-588",
                actual: issueID.rawValue
            )
        }
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.inputBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard leverage.isFinite, leverage > 0, resolvedEntryPrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.leverageEntry",
                expected: "positive finite leverage and entry price",
                actual: "\(leverage)/\(resolvedEntryPrice.rawValue)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("brokerPositionSynced", brokerPositionSynced),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualPortfolioProjection.\(forbiddenFlag.0)"
            )
        }

        self.projectionID = projectionID
        self.issueID = issueID
        self.input = input
        self.portfolioID = portfolioID
        self.entryPrice = resolvedEntryPrice
        self.leverage = leverage
        self.projectedAt = projectedAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.brokerPositionSynced = brokerPositionSynced
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var projectionBoundaryHeld: Bool {
        issueID.rawValue == "GH-588"
            && input.inputBoundaryHeld
            && entryPrice.rawValue > 0
            && leverage > 0
            && productionTradingEnabledByDefault == false
            && productionAccountEndpointRead == false
            && brokerGatewayTouched == false
            && brokerPositionSynced == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
            && portfolioRuntimeMutated == false
            && liveCommandSurfaceTouched == false
    }

    /// 生成 GH-588 deterministic Perp Portfolio projection evidence。
    public func deterministicEvidence() throws -> ReleaseV020PerpetualPortfolioProjectionEvidence {
        guard projectionBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.projectionBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        let results = input.perpParseResults.sorted { $0.brokerFill.replaySequence < $1.brokerFill.replaySequence }
        let fills = results.map(\.brokerFill)
        let positionUpdates = try results.map { result in
            try unwrap(result.positionUpdate, field: "releaseV020PerpetualPortfolioProjection.positionUpdate")
        }
        let latestUpdate = try unwrap(positionUpdates.last, field: "releaseV020PerpetualPortfolioProjection.latestPositionUpdate")
        let instrument = try Self.singleInstrument(from: fills)
        let positionAmt = latestUpdate.resultingPositionQuantity
        let markPrice = input.markPriceReadModel.markPrice
        let positionNotional = positionAmt.rawValue * markPrice.rawValue
        let realizedPnL = fills.reduce(0.0) { partial, fill in
            partial + Self.realizedPnL(fill: fill, entryPrice: entryPrice)
        }
        let commissionPaid = fills.reduce(0.0) { $0 + (Double($1.commissionAmount) ?? 0) }
        let unrealizedPnL = (markPrice.rawValue - entryPrice.rawValue) * positionAmt.rawValue
        let fundingPaymentEstimate = positionNotional * input.fundingReadModel.fundingRate
        let netPnL = realizedPnL + unrealizedPnL - commissionPaid - fundingPaymentEstimate

        let position = try ReleaseV020PerpetualPortfolioPositionProjection(
            sourceFillIDs: fills.map(\.fillID),
            sourcePositionUpdateIDs: positionUpdates.map(\.updateID),
            instrument: instrument,
            positionSide: latestUpdate.positionSide,
            positionAmt: positionAmt,
            entryPrice: entryPrice,
            markPrice: markPrice,
            positionNotional: positionNotional
        )
        let margin = try ReleaseV020PerpetualPortfolioMarginProjection(
            leverage: leverage,
            positionNotional: positionNotional,
            marginRequirement: positionNotional / leverage
        )
        let funding = try ReleaseV020PerpetualPortfolioFundingProjection(
            fundingRate: input.fundingReadModel.fundingRate,
            nextFundingTime: input.fundingReadModel.nextFundingTime,
            positionNotional: positionNotional,
            fundingPaymentEstimate: fundingPaymentEstimate
        )
        let pnl = try ReleaseV020PerpetualPortfolioPnLProjection(
            realizedPnL: realizedPnL,
            unrealizedPnL: unrealizedPnL,
            commissionPaid: commissionPaid,
            fundingPaymentEstimate: fundingPaymentEstimate,
            netPnL: netPnL
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: portfolioID,
            symbol: instrument.symbol,
            timeframe: .oneMinute,
            paperQuantity: positionAmt,
            referencePrice: markPrice,
            source: .paperProjection,
            observedAt: projectedAt
        )
        let financialState = try PortfolioFinancialStateProjection(
            projectionID: Identifier.constant("gh-588-perpetual-financial-state-projection"),
            exposure: exposure,
            projectedAt: projectedAt
        )

        return try ReleaseV020PerpetualPortfolioProjectionEvidence(
            sourceParserEvidenceID: input.parserEvidence.evidenceID,
            sourceFillIDs: fills.map(\.fillID),
            sourcePositionUpdateIDs: positionUpdates.map(\.updateID),
            positionProjection: position,
            marginProjection: margin,
            pnlProjection: pnl,
            fundingProjection: funding,
            strategyAttributions: try Self.strategyAttributions(fills: fills, entryPrice: entryPrice),
            exposureSnapshot: exposure,
            financialStateProjection: financialState
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020PerpetualPortfolioProjection {
        let parser = try ReleaseV020BinanceExecutionReportParser.deterministicFixture()
        let parserEvidence = try parser.deterministicParserEvidence()
        let instrument = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: Symbol.constant("BTCUSDT"))
        let observedAt = Date(timeIntervalSince1970: 1_704_067_500)
        let evaluatedAt = observedAt.addingTimeInterval(30)
        let staleAfter: TimeInterval = 60
        let mark = try PerpetualMarkPriceReadModel(
            instrument: instrument,
            markPrice: 43_120.50,
            indexPrice: 43_118.25,
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
        let funding = try PerpetualFundingRateReadModel(
            instrument: instrument,
            fundingRate: 0.0001,
            nextFundingTime: observedAt.addingTimeInterval(8 * 60 * 60),
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
        let input = try ReleaseV020PerpetualPortfolioProjectionInput(
            parserEvidence: parserEvidence,
            markPriceReadModel: mark,
            fundingReadModel: funding
        )
        return try ReleaseV020PerpetualPortfolioProjection(input: input)
    }

    public static let requiredValidationAnchors = [
        "GH-588-PERPETUAL-PORTFOLIO-PROJECTION",
        "GH-588-PERP-POSITIONAMT-ENTRY-MARK",
        "GH-588-PERP-MARGIN-PROJECTION",
        "GH-588-PERP-PNL-PROJECTION",
        "GH-588-PERP-FUNDING-PROJECTION",
        "GH-588-PERP-STRATEGY-ATTRIBUTION",
        "GH-588-NO-PRODUCTION-ACCOUNT-READ",
        "TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION"
    ]

    private static func singleInstrument(
        from fills: [ReleaseV020NormalizedBrokerFill]
    ) throws -> InstrumentIdentity {
        guard let first = fills.first?.instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.fills",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard fills.allSatisfy({ $0.instrument == first }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualPortfolioProjection.instrument",
                expected: first.rawValue,
                actual: fills.map(\.instrument.rawValue).joined(separator: ",")
            )
        }
        return first
    }

    private static func realizedPnL(
        fill: ReleaseV020NormalizedBrokerFill,
        entryPrice: Price
    ) -> Double {
        switch (fill.side, fill.positionSide, fill.reduceOnly) {
        case ("SELL", .some(.long), true):
            (fill.lastExecutedPrice.rawValue - entryPrice.rawValue) * fill.lastExecutedQuantity.rawValue
        case ("BUY", .some(.short), true):
            (entryPrice.rawValue - fill.lastExecutedPrice.rawValue) * fill.lastExecutedQuantity.rawValue
        default:
            0
        }
    }

    private static func strategyAttributions(
        fills: [ReleaseV020NormalizedBrokerFill],
        entryPrice: Price
    ) throws -> [ReleaseV020PerpetualPortfolioStrategyAttribution] {
        try fills.enumerated().map { index, fill in
            let strategyKind: ReleaseV020PerpetualPortfolioProjectionStrategyKind = index.isMultiple(of: 2) ? .ema : .rsi
            let notional = fill.lastExecutedQuantity.rawValue * fill.lastExecutedPrice.rawValue
            return try ReleaseV020PerpetualPortfolioStrategyAttribution(
                attributionID: Identifier.constant(
                    "gh-588-\(strategyKind.rawValue.lowercased())-\(fill.reportKind.rawValue.replacingOccurrences(of: " ", with: "-"))-attribution"
                ),
                strategyKind: strategyKind,
                sourceFillID: fill.fillID,
                attributedQuantity: fill.lastExecutedQuantity,
                attributedNotional: notional,
                attributedRealizedPnL: Self.realizedPnL(
                    fill: fill,
                    entryPrice: entryPrice
                )
            )
        }
    }
}

private func unwrap<T>(_ value: T?, field: String) throws -> T {
    guard let value else {
        throw CoreError.liveTradingBoundaryContractMismatch(
            field: field,
            expected: "non-nil",
            actual: "nil"
        )
    }
    return value
}
