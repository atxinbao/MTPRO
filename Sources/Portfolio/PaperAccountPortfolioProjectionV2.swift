import DomainModel
import Foundation

/// MTP-187 将 paper account / portfolio projection evidence 放入 `Sources/Portfolio/`。
/// Portfolio 仍只持有 paper / simulated financial read-model state，不读取 broker account 或 real PnL。
/// PaperPortfolioPnLSummary 汇总 MTP-101 paper-only PnL 证据。
///
/// 该摘要只从 replayed simulated fill 的 gross notional、fee、slippage 和本地 mark price
/// 推导，不读取真实账户余额、broker position、margin、leverage 或 real PnL。`netPaperPnL`
/// 只是本地 sandbox 账本结果，不能被解释为真实账户盈亏。
public struct PaperPortfolioPnLSummary: Codable, Equatable, Sendable {
    public let grossExposureNotional: Double
    public let costBasisNotional: Double
    public let totalFeeAmount: Double
    public let totalSlippageAmount: Double
    public let totalCostImpactAmount: Double
    public let realizedPaperPnL: Double
    public let unrealizedPaperPnL: Double
    public let netPaperPnL: Double
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let representsRealPnL: Bool

    public var paperOnlyBoundaryHeld: Bool {
        usesMargin == false
            && usesLeverage == false
            && representsRealPnL == false
    }

    public init(
        grossExposureNotional: Double,
        costBasisNotional: Double,
        totalFeeAmount: Double,
        totalSlippageAmount: Double,
        totalCostImpactAmount: Double,
        realizedPaperPnL: Double,
        unrealizedPaperPnL: Double,
        netPaperPnL: Double,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        representsRealPnL: Bool = false
    ) throws {
        try Self.validateFiniteNonNegative(grossExposureNotional, field: "grossExposureNotional")
        try Self.validateFiniteNonNegative(costBasisNotional, field: "costBasisNotional")
        try Self.validateFiniteNonNegative(totalFeeAmount, field: "totalFeeAmount")
        try Self.validateFiniteNonNegative(totalSlippageAmount, field: "totalSlippageAmount")
        try Self.validateFiniteNonNegative(totalCostImpactAmount, field: "totalCostImpactAmount")
        try Self.validateFinite(realizedPaperPnL, field: "realizedPaperPnL")
        try Self.validateFinite(unrealizedPaperPnL, field: "unrealizedPaperPnL")
        try Self.validateFinite(netPaperPnL, field: "netPaperPnL")
        try Self.validateForbiddenCapabilities(
            usesMargin: usesMargin,
            usesLeverage: usesLeverage,
            representsRealPnL: representsRealPnL
        )

        self.grossExposureNotional = grossExposureNotional
        self.costBasisNotional = costBasisNotional
        self.totalFeeAmount = totalFeeAmount
        self.totalSlippageAmount = totalSlippageAmount
        self.totalCostImpactAmount = totalCostImpactAmount
        self.realizedPaperPnL = realizedPaperPnL
        self.unrealizedPaperPnL = unrealizedPaperPnL
        self.netPaperPnL = netPaperPnL
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.representsRealPnL = representsRealPnL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            grossExposureNotional: try container.decode(Double.self, forKey: .grossExposureNotional),
            costBasisNotional: try container.decode(Double.self, forKey: .costBasisNotional),
            totalFeeAmount: try container.decode(Double.self, forKey: .totalFeeAmount),
            totalSlippageAmount: try container.decode(Double.self, forKey: .totalSlippageAmount),
            totalCostImpactAmount: try container.decode(Double.self, forKey: .totalCostImpactAmount),
            realizedPaperPnL: try container.decode(Double.self, forKey: .realizedPaperPnL),
            unrealizedPaperPnL: try container.decode(Double.self, forKey: .unrealizedPaperPnL),
            netPaperPnL: try container.decode(Double.self, forKey: .netPaperPnL),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage),
            representsRealPnL: try container.decode(Bool.self, forKey: .representsRealPnL)
        )
    }

    private static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite && value >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }

    private static func validateFinite(_ value: Double, field: String) throws {
        guard value.isFinite else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite value",
                actual: "\(value)"
            )
        }
    }

    private static func validateForbiddenCapabilities(
        usesMargin: Bool,
        usesLeverage: Bool,
        representsRealPnL: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("representsRealPnL", representsRealPnL)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(forbidden.0)
        }
    }
}

/// PaperAccountProjectionSnapshot 是 MTP-101 的本地 sandbox account projection。
///
/// account cash、equity 和 available paper balance 都从 replayed simulated fill 的 notional
/// 与 cost impact 推导。它不是真实 account state，不读取 account endpoint，不同步 broker
/// position，也不启用 margin / leverage。
public struct PaperAccountProjectionSnapshot: Codable, Equatable, Sendable {
    public let accountID: Identifier
    public let sessionID: Identifier
    public let currency: String
    public let startingCashBalance: Double
    public let cashBalance: Double
    public let availablePaperBalance: Double
    public let positionMarketValue: Double
    public let equity: Double
    public let pnlSummary: PaperPortfolioPnLSummary
    public let sourceFillIDs: [Identifier]
    public let sourceSequences: [Int]
    public let projectedAt: Date
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let representsRealAccountState: Bool

    public var paperOnlyBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
            && representsRealAccountState == false
            && pnlSummary.paperOnlyBoundaryHeld
    }

    public init(
        accountID: Identifier,
        sessionID: Identifier,
        currency: String = "USDT",
        startingCashBalance: Double,
        cashBalance: Double,
        availablePaperBalance: Double,
        positionMarketValue: Double,
        equity: Double,
        pnlSummary: PaperPortfolioPnLSummary,
        sourceFillIDs: [Identifier],
        sourceSequences: [Int],
        projectedAt: Date,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        representsRealAccountState: Bool = false
    ) throws {
        guard currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "currency",
                expected: "non-empty paper account currency",
                actual: "empty"
            )
        }
        try Self.validateFiniteNonNegative(startingCashBalance, field: "startingCashBalance")
        try Self.validateFiniteNonNegative(cashBalance, field: "cashBalance")
        try Self.validateFiniteNonNegative(availablePaperBalance, field: "availablePaperBalance")
        try Self.validateFiniteNonNegative(positionMarketValue, field: "positionMarketValue")
        try Self.validateFiniteNonNegative(equity, field: "equity")
        try Self.validateSourceEvidence(sourceFillIDs: sourceFillIDs, sourceSequences: sourceSequences)
        try Self.validateForbiddenCapabilities(
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            usesMargin: usesMargin,
            usesLeverage: usesLeverage,
            representsRealAccountState: representsRealAccountState
        )

        self.accountID = accountID
        self.sessionID = sessionID
        self.currency = currency
        self.startingCashBalance = startingCashBalance
        self.cashBalance = cashBalance
        self.availablePaperBalance = availablePaperBalance
        self.positionMarketValue = positionMarketValue
        self.equity = equity
        self.pnlSummary = pnlSummary
        self.sourceFillIDs = sourceFillIDs
        self.sourceSequences = sourceSequences
        self.projectedAt = projectedAt
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.representsRealAccountState = representsRealAccountState
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            accountID: try container.decode(Identifier.self, forKey: .accountID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            currency: try container.decode(String.self, forKey: .currency),
            startingCashBalance: try container.decode(Double.self, forKey: .startingCashBalance),
            cashBalance: try container.decode(Double.self, forKey: .cashBalance),
            availablePaperBalance: try container.decode(Double.self, forKey: .availablePaperBalance),
            positionMarketValue: try container.decode(Double.self, forKey: .positionMarketValue),
            equity: try container.decode(Double.self, forKey: .equity),
            pnlSummary: try container.decode(PaperPortfolioPnLSummary.self, forKey: .pnlSummary),
            sourceFillIDs: try container.decode([Identifier].self, forKey: .sourceFillIDs),
            sourceSequences: try container.decode([Int].self, forKey: .sourceSequences),
            projectedAt: try container.decode(Date.self, forKey: .projectedAt),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage),
            representsRealAccountState: try container.decode(Bool.self, forKey: .representsRealAccountState)
        )
    }
}

/// PaperPositionProjectionSnapshot 描述单个 symbol / timeframe 的 paper-only position。
///
/// position 只由 replayed simulated fill 聚合得到：数量、均价、market value、cost basis 和
/// unrealized paper PnL 都是本地 projection，不是 broker position、margin position 或真实持仓。
public struct PaperPositionProjectionSnapshot: Codable, Equatable, Sendable {
    public let positionID: Identifier
    public let portfolioID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let netQuantity: Quantity
    public let averageEntryPrice: Price
    public let lastFillPrice: Price
    public let marketValue: Double
    public let costBasisNotional: Double
    public let totalFeeAmount: Double
    public let totalSlippageAmount: Double
    public let totalCostImpactAmount: Double
    public let realizedPaperPnL: Double
    public let unrealizedPaperPnL: Double
    public let sourceFillIDs: [Identifier]
    public let sourceSequences: [Int]
    public let projectedAt: Date
    public let source: PortfolioExposureSource
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let representsBrokerPosition: Bool

    public var paperOnlyBoundaryHeld: Bool {
        source == .paperProjection
            && syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
            && representsBrokerPosition == false
    }

    public init(
        positionID: Identifier,
        portfolioID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        netQuantity: Quantity,
        averageEntryPrice: Price,
        lastFillPrice: Price,
        marketValue: Double,
        costBasisNotional: Double,
        totalFeeAmount: Double,
        totalSlippageAmount: Double,
        totalCostImpactAmount: Double,
        realizedPaperPnL: Double,
        unrealizedPaperPnL: Double,
        sourceFillIDs: [Identifier],
        sourceSequences: [Int],
        projectedAt: Date,
        source: PortfolioExposureSource = .paperProjection,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        representsBrokerPosition: Bool = false
    ) throws {
        try Self.validateFiniteNonNegative(marketValue, field: "marketValue")
        try Self.validateFiniteNonNegative(costBasisNotional, field: "costBasisNotional")
        try Self.validateFiniteNonNegative(totalFeeAmount, field: "totalFeeAmount")
        try Self.validateFiniteNonNegative(totalSlippageAmount, field: "totalSlippageAmount")
        try Self.validateFiniteNonNegative(totalCostImpactAmount, field: "totalCostImpactAmount")
        try Self.validateFinite(realizedPaperPnL, field: "realizedPaperPnL")
        try Self.validateFinite(unrealizedPaperPnL, field: "unrealizedPaperPnL")
        try Self.validateSourceEvidence(sourceFillIDs: sourceFillIDs, sourceSequences: sourceSequences)
        guard source == .paperProjection else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: source.rawValue
            )
        }
        try Self.validateForbiddenCapabilities(
            syncsBrokerPosition: syncsBrokerPosition,
            usesMargin: usesMargin,
            usesLeverage: usesLeverage,
            representsBrokerPosition: representsBrokerPosition
        )

        self.positionID = positionID
        self.portfolioID = portfolioID
        self.symbol = symbol
        self.timeframe = timeframe
        self.netQuantity = netQuantity
        self.averageEntryPrice = averageEntryPrice
        self.lastFillPrice = lastFillPrice
        self.marketValue = marketValue
        self.costBasisNotional = costBasisNotional
        self.totalFeeAmount = totalFeeAmount
        self.totalSlippageAmount = totalSlippageAmount
        self.totalCostImpactAmount = totalCostImpactAmount
        self.realizedPaperPnL = realizedPaperPnL
        self.unrealizedPaperPnL = unrealizedPaperPnL
        self.sourceFillIDs = sourceFillIDs
        self.sourceSequences = sourceSequences
        self.projectedAt = projectedAt
        self.source = source
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.representsBrokerPosition = representsBrokerPosition
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            positionID: try container.decode(Identifier.self, forKey: .positionID),
            portfolioID: try container.decode(Identifier.self, forKey: .portfolioID),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            netQuantity: try container.decode(Quantity.self, forKey: .netQuantity),
            averageEntryPrice: try container.decode(Price.self, forKey: .averageEntryPrice),
            lastFillPrice: try container.decode(Price.self, forKey: .lastFillPrice),
            marketValue: try container.decode(Double.self, forKey: .marketValue),
            costBasisNotional: try container.decode(Double.self, forKey: .costBasisNotional),
            totalFeeAmount: try container.decode(Double.self, forKey: .totalFeeAmount),
            totalSlippageAmount: try container.decode(Double.self, forKey: .totalSlippageAmount),
            totalCostImpactAmount: try container.decode(Double.self, forKey: .totalCostImpactAmount),
            realizedPaperPnL: try container.decode(Double.self, forKey: .realizedPaperPnL),
            unrealizedPaperPnL: try container.decode(Double.self, forKey: .unrealizedPaperPnL),
            sourceFillIDs: try container.decode([Identifier].self, forKey: .sourceFillIDs),
            sourceSequences: try container.decode([Int].self, forKey: .sourceSequences),
            projectedAt: try container.decode(Date.self, forKey: .projectedAt),
            source: try container.decode(PortfolioExposureSource.self, forKey: .source),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage),
            representsBrokerPosition: try container.decode(Bool.self, forKey: .representsBrokerPosition)
        )
    }
}

/// PaperAccountPortfolioProjectionV2Snapshot 是 MTP-101 的稳定 read model source。
///
/// 该 snapshot 代表 replay -> projection 的结果：account、positions、exposures 和 PnL summary
/// 必须全部来自 replayed simulated fill evidence。它可以进入 Persistence / App read model，但不能
/// 变成真实账户状态、broker position sync、margin / leverage 或 live risk runtime 输入。
public struct PaperAccountPortfolioProjectionV2Snapshot: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let portfolioID: Identifier
    public let account: PaperAccountProjectionSnapshot
    public let positions: [PaperPositionProjectionSnapshot]
    public let exposures: [PortfolioExposureSnapshot]
    public let pnlSummary: PaperPortfolioPnLSummary
    public let sourceFillIDs: [Identifier]
    public let sourceSequences: [Int]
    public let projectedAt: Date
    public let usesReplayedSimulatedFillEvidence: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let representsRealAccountState: Bool
    public let updatesLiveRiskRuntime: Bool

    public var paperOnlyBoundaryHeld: Bool {
        usesReplayedSimulatedFillEvidence
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
            && representsRealAccountState == false
            && updatesLiveRiskRuntime == false
            && account.paperOnlyBoundaryHeld
            && positions.allSatisfy(\.paperOnlyBoundaryHeld)
            && pnlSummary.paperOnlyBoundaryHeld
            && exposures.allSatisfy { $0.source == .paperProjection }
    }

    public init(
        snapshotID: Identifier,
        portfolioID: Identifier,
        account: PaperAccountProjectionSnapshot,
        positions: [PaperPositionProjectionSnapshot],
        exposures: [PortfolioExposureSnapshot],
        pnlSummary: PaperPortfolioPnLSummary,
        sourceFillIDs: [Identifier],
        sourceSequences: [Int],
        projectedAt: Date,
        usesReplayedSimulatedFillEvidence: Bool = true,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        representsRealAccountState: Bool = false,
        updatesLiveRiskRuntime: Bool = false
    ) throws {
        guard positions.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "positions",
                expected: "at least one paper position",
                actual: "empty"
            )
        }
        guard exposures.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "exposures",
                expected: "at least one paper exposure",
                actual: "empty"
            )
        }
        guard account.accountID.rawValue.isEmpty == false else {
            throw CoreError.emptyIdentifier("accountID")
        }
        try Self.validateSourceEvidence(sourceFillIDs: sourceFillIDs, sourceSequences: sourceSequences)
        guard usesReplayedSimulatedFillEvidence else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "usesReplayedSimulatedFillEvidence",
                expected: "true",
                actual: "false"
            )
        }
        try Self.validateForbiddenCapabilities(
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            usesMargin: usesMargin,
            usesLeverage: usesLeverage,
            representsRealAccountState: representsRealAccountState,
            updatesLiveRiskRuntime: updatesLiveRiskRuntime
        )
        guard account.sourceFillIDs == sourceFillIDs else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "account.sourceFillIDs",
                expected: sourceFillIDs.map(\.rawValue).joined(separator: ","),
                actual: account.sourceFillIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard positions.allSatisfy({ $0.portfolioID == portfolioID }) else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "positions.portfolioID",
                expected: portfolioID.rawValue,
                actual: positions.map(\.portfolioID.rawValue).joined(separator: ",")
            )
        }

        self.snapshotID = snapshotID
        self.portfolioID = portfolioID
        self.account = account
        self.positions = positions.sortedByPaperPosition()
        self.exposures = exposures.sortedByPortfolioExposureSnapshot()
        self.pnlSummary = pnlSummary
        self.sourceFillIDs = sourceFillIDs
        self.sourceSequences = sourceSequences
        self.projectedAt = projectedAt
        self.usesReplayedSimulatedFillEvidence = usesReplayedSimulatedFillEvidence
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.representsRealAccountState = representsRealAccountState
        self.updatesLiveRiskRuntime = updatesLiveRiskRuntime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            snapshotID: try container.decode(Identifier.self, forKey: .snapshotID),
            portfolioID: try container.decode(Identifier.self, forKey: .portfolioID),
            account: try container.decode(PaperAccountProjectionSnapshot.self, forKey: .account),
            positions: try container.decode([PaperPositionProjectionSnapshot].self, forKey: .positions),
            exposures: try container.decode([PortfolioExposureSnapshot].self, forKey: .exposures),
            pnlSummary: try container.decode(PaperPortfolioPnLSummary.self, forKey: .pnlSummary),
            sourceFillIDs: try container.decode([Identifier].self, forKey: .sourceFillIDs),
            sourceSequences: try container.decode([Int].self, forKey: .sourceSequences),
            projectedAt: try container.decode(Date.self, forKey: .projectedAt),
            usesReplayedSimulatedFillEvidence: try container.decode(
                Bool.self,
                forKey: .usesReplayedSimulatedFillEvidence
            ),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage),
            representsRealAccountState: try container.decode(Bool.self, forKey: .representsRealAccountState),
            updatesLiveRiskRuntime: try container.decode(Bool.self, forKey: .updatesLiveRiskRuntime)
        )
    }
}

/// PaperAccountPortfolioProjectionV2Path 从 replayed simulated fills 构建 MTP-101 projection。
///
/// 入口只接受 `EventReplayResult`，并且只消费 `.paper.simulatedFillRecorded` facts；这保证 projection
/// 依赖 replay 后的 evidence，而不是直接读取 risk decision、Runtime object、SQLite schema、真实账户
/// 或 broker state。
public enum PaperAccountPortfolioProjectionV2Path {
    public static func project(
        from replay: EventReplayResult,
        snapshotID: Identifier,
        accountID: Identifier,
        portfolioID: Identifier,
        startingCashBalance: Double,
        currency: String = "USDT",
        projectedAt: Date
    ) throws -> PaperAccountPortfolioProjectionV2Snapshot {
        let replayedFillEnvelopes = try simulatedFillEnvelopeEvidence(from: replay)
        let fills = replayedFillEnvelopes.map(\.fill)
        let sourceSequences = replayedFillEnvelopes.map(\.sequence)
        let sourceFillIDs = fills.map(\.fillID)
        let positions = try makePositions(
            from: replayedFillEnvelopes,
            portfolioID: portfolioID,
            projectedAt: projectedAt
        )
        let exposures = positions.map { position in
            PortfolioExposureSnapshot(
                portfolioID: portfolioID,
                symbol: position.symbol,
                timeframe: position.timeframe,
                paperQuantity: position.netQuantity,
                referencePrice: position.lastFillPrice,
                source: .paperProjection,
                observedAt: projectedAt
            )
        }
        let pnlSummary = try makePnLSummary(positions: positions)
        let positionMarketValue = positions.reduce(0) { $0 + $1.marketValue }
        let cashBalance = startingCashBalance
            - pnlSummary.costBasisNotional
            - pnlSummary.totalCostImpactAmount
        let account = try PaperAccountProjectionSnapshot(
            accountID: accountID,
            sessionID: try sessionID(from: fills),
            currency: currency,
            startingCashBalance: startingCashBalance,
            cashBalance: cashBalance,
            availablePaperBalance: cashBalance,
            positionMarketValue: positionMarketValue,
            equity: cashBalance + positionMarketValue,
            pnlSummary: pnlSummary,
            sourceFillIDs: sourceFillIDs,
            sourceSequences: sourceSequences,
            projectedAt: projectedAt
        )

        return try PaperAccountPortfolioProjectionV2Snapshot(
            snapshotID: snapshotID,
            portfolioID: portfolioID,
            account: account,
            positions: positions,
            exposures: exposures,
            pnlSummary: pnlSummary,
            sourceFillIDs: sourceFillIDs,
            sourceSequences: sourceSequences,
            projectedAt: projectedAt
        )
    }

    private struct SimulatedFillEnvelopeEvidence: Equatable, Sendable {
        let sequence: Int
        let fill: PaperSimulatedFillEvidence
    }

    private static func simulatedFillEnvelopeEvidence(
        from replay: EventReplayResult
    ) throws -> [SimulatedFillEnvelopeEvidence] {
        try validateReplayOrder(replay.envelopes)
        let envelopes = replay.envelopes.compactMap { envelope -> SimulatedFillEnvelopeEvidence? in
            guard case let .paper(.simulatedFillRecorded(fill)) = envelope.event else {
                return nil
            }
            return SimulatedFillEnvelopeEvidence(sequence: envelope.sequence, fill: fill)
        }
        guard envelopes.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "replayedSimulatedFills",
                expected: "at least one replayed simulated fill",
                actual: "empty"
            )
        }
        guard envelopes.allSatisfy({ $0.fill.paperOnlyBoundaryHeld }) else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "simulatedFill.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        return envelopes
    }

    private static func makePositions(
        from envelopes: [SimulatedFillEnvelopeEvidence],
        portfolioID: Identifier,
        projectedAt: Date
    ) throws -> [PaperPositionProjectionSnapshot] {
        let grouped = Dictionary(grouping: envelopes) { evidence in
            PositionKey(symbol: evidence.fill.symbol, timeframe: evidence.fill.timeframe)
        }
        return try grouped.keys.sorted().map { key in
            let positionFills = grouped[key, default: []].sorted { $0.sequence < $1.sequence }
            return try makePosition(
                from: positionFills,
                key: key,
                portfolioID: portfolioID,
                projectedAt: projectedAt
            )
        }
    }

    private static func makePosition(
        from envelopes: [SimulatedFillEnvelopeEvidence],
        key: PositionKey,
        portfolioID: Identifier,
        projectedAt: Date
    ) throws -> PaperPositionProjectionSnapshot {
        let fills = envelopes.map(\.fill)
        let netQuantity = fills.reduce(0) { partial, fill in
            partial + signedQuantity(for: fill)
        }
        guard let lastFill = envelopes.last?.fill else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "position.fills",
                expected: "at least one fill",
                actual: "empty"
            )
        }
        let costBasisNotional = fills.reduce(0) { $0 + $1.grossNotional }
        let totalFeeAmount = fills.reduce(0) { $0 + $1.costEstimate.feeAmount }
        let totalSlippageAmount = fills.reduce(0) { $0 + $1.costEstimate.slippageAmount }
        let totalCostImpactAmount = fills.reduce(0) { $0 + $1.costImpactAmount }
        let marketValue = netQuantity * lastFill.fillPrice.rawValue
        let averageEntryPrice = netQuantity > 0
            ? costBasisNotional / netQuantity
            : lastFill.fillPrice.rawValue
        let unrealizedPaperPnL = marketValue - costBasisNotional - totalCostImpactAmount
        return try PaperPositionProjectionSnapshot(
            positionID: try Identifier(
                "\(portfolioID.rawValue)-\(key.symbol.rawValue)-\(key.timeframe.rawValue)-paper-position"
            ),
            portfolioID: portfolioID,
            symbol: key.symbol,
            timeframe: key.timeframe,
            netQuantity: try Quantity(netQuantity, field: "paperPosition.netQuantity"),
            averageEntryPrice: try Price(averageEntryPrice, field: "paperPosition.averageEntryPrice"),
            lastFillPrice: lastFill.fillPrice,
            marketValue: marketValue,
            costBasisNotional: costBasisNotional,
            totalFeeAmount: totalFeeAmount,
            totalSlippageAmount: totalSlippageAmount,
            totalCostImpactAmount: totalCostImpactAmount,
            realizedPaperPnL: 0,
            unrealizedPaperPnL: unrealizedPaperPnL,
            sourceFillIDs: fills.map(\.fillID),
            sourceSequences: envelopes.map(\.sequence),
            projectedAt: projectedAt
        )
    }

    private static func makePnLSummary(
        positions: [PaperPositionProjectionSnapshot]
    ) throws -> PaperPortfolioPnLSummary {
        let grossExposureNotional = positions.reduce(0) { $0 + $1.marketValue }
        let costBasisNotional = positions.reduce(0) { $0 + $1.costBasisNotional }
        let totalFeeAmount = positions.reduce(0) { $0 + $1.totalFeeAmount }
        let totalSlippageAmount = positions.reduce(0) { $0 + $1.totalSlippageAmount }
        let totalCostImpactAmount = positions.reduce(0) { $0 + $1.totalCostImpactAmount }
        let realizedPaperPnL = positions.reduce(0) { $0 + $1.realizedPaperPnL }
        let unrealizedPaperPnL = positions.reduce(0) { $0 + $1.unrealizedPaperPnL }
        return try PaperPortfolioPnLSummary(
            grossExposureNotional: grossExposureNotional,
            costBasisNotional: costBasisNotional,
            totalFeeAmount: totalFeeAmount,
            totalSlippageAmount: totalSlippageAmount,
            totalCostImpactAmount: totalCostImpactAmount,
            realizedPaperPnL: realizedPaperPnL,
            unrealizedPaperPnL: unrealizedPaperPnL,
            netPaperPnL: realizedPaperPnL + unrealizedPaperPnL
        )
    }

    private static func signedQuantity(for fill: PaperSimulatedFillEvidence) -> Double {
        switch fill.side {
        case .buy:
            fill.filledQuantity.rawValue
        case .hold:
            0
        }
    }

    private static func sessionID(from fills: [PaperSimulatedFillEvidence]) throws -> Identifier {
        guard let sessionID = fills.first?.sessionID else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "sessionID",
                expected: "at least one fill session",
                actual: "empty"
            )
        }
        guard fills.allSatisfy({ $0.sessionID == sessionID }) else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "sessionID",
                expected: sessionID.rawValue,
                actual: fills.map(\.sessionID.rawValue).joined(separator: ",")
            )
        }
        return sessionID
    }

    private static func validateReplayOrder(_ envelopes: [EventEnvelope]) throws {
        let sequences = envelopes.map(\.sequence)
        let sortedUnique = Array(Set(sequences)).sorted()
        guard sequences == sortedUnique else {
            throw CoreError.invalidSequenceRange
        }
    }

    private struct PositionKey: Hashable, Comparable {
        let symbol: Symbol
        let timeframe: Timeframe

        static func < (lhs: PositionKey, rhs: PositionKey) -> Bool {
            if lhs.symbol.rawValue != rhs.symbol.rawValue {
                return lhs.symbol.rawValue < rhs.symbol.rawValue
            }
            return lhs.timeframe.rawValue < rhs.timeframe.rawValue
        }
    }
}

/// PaperAccountPortfolioProjectionV2Fixture 提供 MTP-101 deterministic tracer bullet。
///
/// Fixture 复用 MTP-100 partial / full replay facts，然后通过 MTP-101 projection path 生成 account、
/// position、exposure 和 PnL snapshot；它不代表真实资金、真实仓位或 broker sync。
public enum PaperAccountPortfolioProjectionV2Fixture {
    public static let validationAnchors: [String] = [
        "TVM-PAPER-RUNTIME-KERNEL",
        "MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION",
        "MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION",
        "MTP-101-PAPER-PNL-SNAPSHOT",
        "MTP-101-READ-MODEL-CONSUMPTION",
        "MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE",
        "MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION"
    ]

    public static func deterministicSnapshot() throws -> PaperAccountPortfolioProjectionV2Snapshot {
        let (messageBus, _) = try PaperSimulatedFillFixture.publishedPartialAndFullFills()
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: messageBus.envelopes.count),
                streams: [.paper]
            )
        )
        return try PaperAccountPortfolioProjectionV2Path.project(
            from: replay,
            snapshotID: try Identifier("mtp-101-paper-account-portfolio-snapshot"),
            accountID: try Identifier("mtp-101-paper-account"),
            portfolioID: try Identifier("mtp-101-paper-portfolio"),
            startingCashBalance: 10_000,
            projectedAt: Date(timeIntervalSince1970: 6_100)
        )
    }
}

private extension PaperAccountProjectionSnapshot {
    static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite && value >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }

    static func validateSourceEvidence(sourceFillIDs: [Identifier], sourceSequences: [Int]) throws {
        guard sourceFillIDs.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "sourceFillIDs",
                expected: "at least one replayed simulated fill ID",
                actual: "empty"
            )
        }
        guard sourceFillIDs.count == sourceSequences.count else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "sourceSequences.count",
                expected: "\(sourceFillIDs.count)",
                actual: "\(sourceSequences.count)"
            )
        }
        guard sourceSequences.allSatisfy({ $0 > 0 }) else {
            throw CoreError.invalidEventSequence(sourceSequences.first(where: { $0 <= 0 }) ?? 0)
        }
    }

    static func validateForbiddenCapabilities(
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        usesMargin: Bool,
        usesLeverage: Bool,
        representsRealAccountState: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("representsRealAccountState", representsRealAccountState)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(forbidden.0)
        }
    }
}

private extension PaperPositionProjectionSnapshot {
    static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite && value >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }

    static func validateFinite(_ value: Double, field: String) throws {
        guard value.isFinite else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite value",
                actual: "\(value)"
            )
        }
    }

    static func validateSourceEvidence(sourceFillIDs: [Identifier], sourceSequences: [Int]) throws {
        try PaperAccountProjectionSnapshot.validateSourceEvidence(
            sourceFillIDs: sourceFillIDs,
            sourceSequences: sourceSequences
        )
    }

    static func validateForbiddenCapabilities(
        syncsBrokerPosition: Bool,
        usesMargin: Bool,
        usesLeverage: Bool,
        representsBrokerPosition: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("representsBrokerPosition", representsBrokerPosition)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(forbidden.0)
        }
    }
}

private extension PaperAccountPortfolioProjectionV2Snapshot {
    static func validateSourceEvidence(sourceFillIDs: [Identifier], sourceSequences: [Int]) throws {
        try PaperAccountProjectionSnapshot.validateSourceEvidence(
            sourceFillIDs: sourceFillIDs,
            sourceSequences: sourceSequences
        )
    }

    static func validateForbiddenCapabilities(
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        usesMargin: Bool,
        usesLeverage: Bool,
        representsRealAccountState: Bool,
        updatesLiveRiskRuntime: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("representsRealAccountState", representsRealAccountState),
            ("updatesLiveRiskRuntime", updatesLiveRiskRuntime)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(forbidden.0)
        }
    }
}

private extension Array where Element == PaperPositionProjectionSnapshot {
    func sortedByPaperPosition() -> [PaperPositionProjectionSnapshot] {
        sorted { lhs, rhs in
            if lhs.symbol != rhs.symbol {
                return lhs.symbol.rawValue < rhs.symbol.rawValue
            }
            return lhs.timeframe.rawValue < rhs.timeframe.rawValue
        }
    }
}

private extension Array where Element == PortfolioExposureSnapshot {
    func sortedByPortfolioExposureSnapshot() -> [PortfolioExposureSnapshot] {
        sorted { lhs, rhs in
            if lhs.portfolioID != rhs.portfolioID {
                return lhs.portfolioID.rawValue < rhs.portfolioID.rawValue
            }
            if lhs.symbol != rhs.symbol {
                return lhs.symbol.rawValue < rhs.symbol.rawValue
            }
            return lhs.timeframe.rawValue < rhs.timeframe.rawValue
        }
    }
}
