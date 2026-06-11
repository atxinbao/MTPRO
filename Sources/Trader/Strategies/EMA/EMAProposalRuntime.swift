import DomainModel
import Foundation
import MessageBus

/// GH-528 将 EMA strategy proposal runtime 放在 Trader-owned EMA strategy root 下。
///
/// 该 runtime 只把 EMA signal sample 转成 paper-only `PaperActionProposal` 和 RiskEngine 可消费的
/// `RiskEvaluationQuery` evidence。它不提交订单、不调用 ExecutionClient、不连接 broker 或 OMS、
/// 不读取 production secret，也不授权 production trading。
/// `GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME`
/// `TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME`
public struct EMAProposalRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let configuration: EMACrossStrategyConfiguration
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let validationAnchors: [String]
    public let directExecutionClientEnabled: Bool
    public let brokerCommandEnabled: Bool
    public let omsBypassEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        runtimeID: Identifier,
        configuration: EMACrossStrategyConfiguration,
        releaseVenue: String = Self.requiredReleaseVenue,
        activeConcreteStrategy: String = Self.requiredActiveConcreteStrategy,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        directExecutionClientEnabled: Bool = false,
        brokerCommandEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.runtimeID = runtimeID
        self.configuration = configuration
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.validationAnchors = validationAnchors
        self.directExecutionClientEnabled = directExecutionClientEnabled
        self.brokerCommandEnabled = brokerCommandEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    /// 从 release market bars 生成最后一个 EMA signal 对应的 proposal evidence。
    ///
    /// bars 可以来自 live-read compatible market data path，但输出仍是 paper-only proposal，不触发交易。
    public func generateProposal(
        from bars: [MarketBar],
        sessionID: Identifier,
        riskProfileID: Identifier,
        sourceSequence: Int,
        proposedAt: Date,
        paperQuantity: Quantity,
        liquidityRole: ExecutionCostLiquidityRole = .maker
    ) throws -> EMAProposalRuntimeEvidence {
        let samples = try EMACrossStrategyContract(configuration: configuration).evaluate(bars)
        guard let latestSample = samples.last else {
            throw CoreError.insufficientMarketData(required: configuration.longPeriod, actual: bars.count)
        }
        let sizingAssumption = try PaperActionProposalSizingAssumption(
            assumptionID: Identifier("\(runtimeID.rawValue)-sizing-\(sourceSequence)"),
            quantity: paperQuantity,
            referencePrice: latestSample.close,
            liquidityRole: liquidityRole
        )
        return try generateProposal(
            from: latestSample,
            sessionID: sessionID,
            riskProfileID: riskProfileID,
            sourceSequence: sourceSequence,
            sizingAssumption: sizingAssumption,
            proposedAt: proposedAt
        )
    }

    /// 从已计算出的 EMA signal sample 生成 proposal evidence。
    ///
    /// 该入口便于把 DataEngine / Cache 形成的 live-read signal sample 接入 Trader proposal surface。
    public func generateProposal(
        from sample: EMACrossSignalSample,
        sessionID: Identifier,
        riskProfileID: Identifier,
        sourceSequence: Int,
        sizingAssumption: PaperActionProposalSizingAssumption,
        proposedAt: Date
    ) throws -> EMAProposalRuntimeEvidence {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        try validate(sample: sample, sizingAssumption: sizingAssumption)
        let proposal = try PaperActionProposal(
            proposalID: Identifier("\(runtimeID.rawValue)-proposal-\(sourceSequence)"),
            sessionID: sessionID,
            signal: sample.signal,
            sizingAssumption: sizingAssumption,
            proposedAt: proposedAt
        )
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: proposal.proposalID,
            symbol: proposal.symbol,
            timeframe: proposal.timeframe,
            proposedQuantity: proposal.quantity,
            riskProfileID: riskProfileID,
            executionMode: proposal.executionMode
        )
        return try EMAProposalRuntimeEvidence(
            runtimeID: runtimeID,
            proposal: proposal,
            riskQuery: riskQuery,
            sourceSequence: sourceSequence,
            signalSample: sample,
            releaseVenue: releaseVenue,
            activeConcreteStrategy: activeConcreteStrategy,
            validationAnchors: validationAnchors,
            liveReadPathCompatible: true,
            directExecutionClientEnabled: directExecutionClientEnabled,
            brokerCommandEnabled: brokerCommandEnabled,
            omsBypassEnabled: omsBypassEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            nonEMAStrategyEnabled: nonEMAStrategyEnabled
        )
    }

    /// 从 EMA signal sample 生成 target exposure intent message。
    ///
    /// 该入口是 GH-569 的策略输出层：EMA 只发布 `TargetExposureIntent`，并按 instrument
    /// product type 生成 pre-risk-gate `ProductAwareOrderIntent` evidence。它不生成 broker
    /// command、不调用 RiskEngine / ExecutionEngine / OMS，也不授权 production trading。
    public func generateTargetExposureIntent(
        from sample: EMACrossSignalSample,
        instrument: InstrumentIdentity,
        sourceSequence: Int,
        quantity: Quantity,
        emittedAt: Date
    ) throws -> StrategyIntentMessage {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        try validate(sample: sample)
        try validate(instrument: instrument)

        let productAwareOrderIntent: ProductAwareOrderIntent?
        if sample.targetExposure.requiresOrderIntent {
            productAwareOrderIntent = try ProductAwareOrderIntent(
                intentID: Identifier(
                    "\(runtimeID.rawValue)-product-aware-intent-\(sourceSequence)-\(instrument.productType.rawValue)"
                ),
                instrument: instrument,
                targetExposure: sample.targetExposure,
                quantity: quantity,
                referencePrice: sample.close,
                createdAt: emittedAt
            )
        } else {
            productAwareOrderIntent = nil
        }

        return try StrategyIntentMessage(
            messageID: Identifier(
                "\(runtimeID.rawValue)-target-exposure-\(sourceSequence)-\(instrument.productType.rawValue)"
            ),
            strategyID: configuration.strategyID,
            instrument: instrument,
            targetExposure: sample.targetExposure,
            productAwareOrderIntent: productAwareOrderIntent,
            emittedAt: emittedAt
        )
    }

    /// 从 bars 生成最后一个 EMA sample 的 target exposure intent message。
    public func generateTargetExposureIntent(
        from bars: [MarketBar],
        instrument: InstrumentIdentity,
        sourceSequence: Int,
        quantity: Quantity,
        emittedAt: Date
    ) throws -> StrategyIntentMessage {
        let samples = try EMACrossStrategyContract(configuration: configuration).evaluate(bars)
        guard let latestSample = samples.last else {
            throw CoreError.insufficientMarketData(required: configuration.longPeriod, actual: bars.count)
        }
        return try generateTargetExposureIntent(
            from: latestSample,
            instrument: instrument,
            sourceSequence: sourceSequence,
            quantity: quantity,
            emittedAt: emittedAt
        )
    }

    /// GH-528 deterministic fixture 只服务本地测试和 PR evidence。
    public static func deterministicFixture() throws -> EMAProposalRuntime {
        try EMAProposalRuntime(
            runtimeID: Identifier("gh-528-ema-proposal-runtime"),
            configuration: EMACrossStrategyConfiguration(
                strategyID: Identifier("gh-528-ema-instance"),
                symbol: Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                shortPeriod: 2,
                longPeriod: 3
            )
        )
    }

    /// GH-528 deterministic bars 固定为产生 long EMA signal 的本地行情输入。
    public static func deterministicBars() throws -> [MarketBar] {
        try [100.0, 101.0, 103.0, 106.0, 110.0].enumerated().map { index, close in
            let start = Date(timeIntervalSince1970: Double(index * 60))
            return try MarketBar(
                symbol: Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                interval: DateRange(start: start, end: start.addingTimeInterval(60)),
                open: close - 0.5,
                high: close + 1,
                low: close - 1,
                close: close,
                volume: 1 + Double(index)
            )
        }
    }

    public static let requiredReleaseVenue = "Binance"
    public static let requiredActiveConcreteStrategy = "EMA"
    public static let requiredValidationAnchors = [
        "GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME",
        "GH-528-EMA-SIGNAL-TO-PAPER-PROPOSAL",
        "GH-528-RISKENGINE-CONSUMABLE-PROPOSAL",
        "TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME"
    ]

    private func validate(sample: EMACrossSignalSample, sizingAssumption: PaperActionProposalSizingAssumption) throws {
        try validate(sample: sample)
        guard sizingAssumption.referencePrice == sample.close else {
            throw CoreError.paperActionProposalCostEvidenceMismatch(
                field: "emaProposalRuntime.referencePrice",
                expected: "\(sample.close.rawValue)",
                actual: "\(sizingAssumption.referencePrice.rawValue)"
            )
        }
    }

    private func validate(sample: EMACrossSignalSample) throws {
        guard sample.signal.strategyID == configuration.strategyID else {
            throw CoreError.traderAccountContextMismatch(
                field: "emaProposalRuntime.strategyID",
                expected: configuration.strategyID.rawValue,
                actual: sample.signal.strategyID.rawValue
            )
        }
        guard sample.signal.symbol == configuration.symbol else {
            throw CoreError.marketDataMismatch(
                field: "emaProposalRuntime.symbol",
                expected: configuration.symbol.rawValue,
                actual: sample.signal.symbol.rawValue
            )
        }
        guard sample.signal.timeframe == configuration.timeframe else {
            throw CoreError.marketDataMismatch(
                field: "emaProposalRuntime.timeframe",
                expected: configuration.timeframe.rawValue,
                actual: sample.signal.timeframe.rawValue
            )
        }
        guard sample.targetExposure != .targetShort else {
            throw DomainModelContractError.invalidTargetExposureIntent(
                "EMA target exposure must not be targetShort"
            )
        }
    }

    private func validate(instrument: InstrumentIdentity) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.nonBinanceInstrument")
        }
        guard instrument.symbol == configuration.symbol else {
            throw CoreError.marketDataMismatch(
                field: "emaProposalRuntime.instrument.symbol",
                expected: configuration.symbol.rawValue,
                actual: instrument.symbol.rawValue
            )
        }
    }

    private func validate() throws {
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.nonBinanceVenue")
        }
        guard activeConcreteStrategy == Self.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.nonEMAStrategy")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.traderAccountContextMismatch(
                field: "emaProposalRuntime.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try forbid(directExecutionClientEnabled, "directExecutionClientEnabled")
        try forbid(brokerCommandEnabled, "brokerCommandEnabled")
        try forbid(omsBypassEnabled, "omsBypassEnabled")
        try forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try forbid(nonBinanceVenueEnabled, "nonBinanceVenueEnabled")
        try forbid(nonEMAStrategyEnabled, "nonEMAStrategyEnabled")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.\(field)")
        }
    }
}

/// EMAProposalRuntimeEvidence 是 GH-528 的验收证据。
///
/// Evidence 证明 EMA strategy runtime 只产出 RiskEngine 可消费 proposal，不生成订单或执行命令。
public struct EMAProposalRuntimeEvidence: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let proposal: PaperActionProposal
    public let riskQuery: RiskEvaluationQuery
    public let sourceSequence: Int
    public let signalSample: EMACrossSignalSample
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let validationAnchors: [String]
    public let liveReadPathCompatible: Bool
    public let directExecutionClientEnabled: Bool
    public let brokerCommandEnabled: Bool
    public let omsBypassEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        runtimeID: Identifier,
        proposal: PaperActionProposal,
        riskQuery: RiskEvaluationQuery,
        sourceSequence: Int,
        signalSample: EMACrossSignalSample,
        releaseVenue: String,
        activeConcreteStrategy: String,
        validationAnchors: [String] = EMAProposalRuntime.requiredValidationAnchors,
        liveReadPathCompatible: Bool = true,
        directExecutionClientEnabled: Bool = false,
        brokerCommandEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.runtimeID = runtimeID
        self.proposal = proposal
        self.riskQuery = riskQuery
        self.sourceSequence = sourceSequence
        self.signalSample = signalSample
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.validationAnchors = validationAnchors
        self.liveReadPathCompatible = liveReadPathCompatible
        self.directExecutionClientEnabled = directExecutionClientEnabled
        self.brokerCommandEnabled = brokerCommandEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    /// RiskEngine 可以直接消费该 proposal 和 query，并用 sourceSequence 追踪本地事件来源。
    public var riskEngineConsumable: Bool {
        riskQuery.paperOrderID == proposal.proposalID
            && riskQuery.symbol == proposal.symbol
            && riskQuery.timeframe == proposal.timeframe
            && riskQuery.proposedQuantity == proposal.quantity
            && riskQuery.executionMode == .paper
            && sourceSequence > 0
    }

    /// Proposal 只能作为 paper intent，不能升级成真实订单或 broker action。
    public var paperOnlyProposalBoundaryHeld: Bool {
        proposal.executionMode == .paper
            && proposal.executionAuthorization == .paperIntentOnly
            && proposal.executionAuthorization.allowsRealOrder == false
            && proposal.executionAuthorization.allowsBrokerAction == false
            && proposal.isExecutableAsRealOrder == false
    }

    /// RiskEngine / MessageBus 可以把该 query 当作只读风险评估请求消费。
    public var riskEvents: [RiskEvent] {
        [.evaluationRequested(riskQuery)]
    }

    /// GH-528 总边界：EMA-only、Binance-only、RiskEngine consumable、no execution path。
    public var boundaryHeld: Bool {
        releaseVenue == EMAProposalRuntime.requiredReleaseVenue
            && activeConcreteStrategy == EMAProposalRuntime.requiredActiveConcreteStrategy
            && validationAnchors == EMAProposalRuntime.requiredValidationAnchors
            && liveReadPathCompatible
            && riskEngineConsumable
            && paperOnlyProposalBoundaryHeld
            && noCommandBoundaryHeld
    }

    public var noCommandBoundaryHeld: Bool {
        directExecutionClientEnabled == false
            && brokerCommandEnabled == false
            && omsBypassEnabled == false
            && productionTradingEnabledByDefault == false
            && nonBinanceVenueEnabled == false
            && nonEMAStrategyEnabled == false
    }

    private func validate() throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard signalSample.signal == proposal.signal else {
            throw CoreError.paperActionProposalSignalMismatch(
                field: "emaProposalRuntime.signal",
                expected: signalSample.signal.strategyID.rawValue,
                actual: proposal.signal.strategyID.rawValue
            )
        }
        guard riskEngineConsumable else {
            throw CoreError.paperActionRiskDecisionMismatch(
                field: "riskQuery",
                expected: "proposal-compatible paper risk query",
                actual: "mismatched"
            )
        }
        guard releaseVenue == EMAProposalRuntime.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.evidence.nonBinanceVenue")
        }
        guard activeConcreteStrategy == EMAProposalRuntime.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.evidence.nonEMAStrategy")
        }
        guard validationAnchors == EMAProposalRuntime.requiredValidationAnchors else {
            throw CoreError.traderAccountContextMismatch(
                field: "emaProposalRuntime.evidence.validationAnchors",
                expected: EMAProposalRuntime.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try forbid(liveReadPathCompatible == false, "liveReadPathCompatible")
        try forbid(paperOnlyProposalBoundaryHeld == false, "paperOnlyProposalBoundaryHeld")
        try forbid(directExecutionClientEnabled, "directExecutionClientEnabled")
        try forbid(brokerCommandEnabled, "brokerCommandEnabled")
        try forbid(omsBypassEnabled, "omsBypassEnabled")
        try forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try forbid(nonBinanceVenueEnabled, "nonBinanceVenueEnabled")
        try forbid(nonEMAStrategyEnabled, "nonEMAStrategyEnabled")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("emaProposalRuntime.evidence.\(field)")
        }
    }
}
