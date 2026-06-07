import DomainModel
import Foundation
import TraderStrategies

/// GH-527 将 release v0.1.0 的 Trader runtime lifecycle 收敛到 Trader target 内。
///
/// 该 lifecycle 只负责把 account context、唯一 active EMA strategy instance 和
/// Coordination/RiskBinding handoff 组织成可验证的本地运行证据。它不是 ExecutionClient
/// gateway、broker command router、OMS、production trading switch 或 Dashboard command surface。
/// `GH-527-TRADER-RUNTIME-LIFECYCLE`
/// `TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE`

/// Trader runtime lifecycle event kind 固定启动、绑定、注册、handoff 和关闭步骤。
public enum TraderRuntimeLifecycleEventKind: String, Codable, CaseIterable, Equatable, Sendable {
    case configured
    case started
    case accountContextBound = "account_context_bound"
    case emaStrategyRegistered = "ema_strategy_registered"
    case coordinationRiskHandoffPrepared = "coordination_risk_handoff_prepared"
    case shutdown
}

/// Trader runtime lifecycle event 是本地 deterministic event record。
///
/// 事件只描述 Trader 自身 lifecycle，不携带 signed payload、listenKey、broker report、
/// order command 或 production endpoint 信息。
public struct TraderRuntimeLifecycleEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let kind: TraderRuntimeLifecycleEventKind
    public let occurredAt: Date
    public let sourceIdentity: String

    public init(
        eventID: Identifier,
        kind: TraderRuntimeLifecycleEventKind,
        occurredAt: Date,
        sourceIdentity: String
    ) throws {
        self.eventID = eventID
        self.kind = kind
        self.occurredAt = occurredAt
        self.sourceIdentity = try Self.validatedSourceIdentity(sourceIdentity)
    }

    private static func validatedSourceIdentity(_ value: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CoreError.emptyIdentifier("traderRuntimeLifecycle.event.sourceIdentity")
        }
        let normalized = trimmed
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "/", with: "")
        for token in forbiddenSourceIdentityTokens where normalized.contains(token) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "traderRuntimeLifecycle.event.sourceIdentity.\(token)"
            )
        }
        return trimmed
    }

    private static let forbiddenSourceIdentityTokens = [
        "executionclient",
        "broker",
        "omscommand",
        "signedendpoint",
        "accountendpoint",
        "listenkey",
        "privatestream",
        "ordercommand",
        "livecommand",
        "productionendpoint",
        "productiontrading"
    ]
}

/// Trader runtime lifecycle report 是 GH-527 的验收证据。
///
/// Report 证明 Trader 可以启动、绑定 account context、注册 EMA instance、准备 risk handoff
/// 并关闭，同时继续保持 no direct order submission / no production trading。
public struct TraderRuntimeLifecycleReport: Codable, Equatable, Sendable {
    public let lifecycleID: Identifier
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let accountContextID: Identifier
    public let accountIdentity: Identifier
    public let emaStrategyID: Identifier
    public let coordinationRoot: String
    public let events: [TraderRuntimeLifecycleEvent]
    public let validationAnchors: [String]
    public let riskEngineHandoffRequired: Bool
    public let directExecutionClientEnabled: Bool
    public let brokerCommandEnabled: Bool
    public let omsBypassEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        lifecycleID: Identifier,
        releaseVenue: String,
        activeConcreteStrategy: String,
        accountContextID: Identifier,
        accountIdentity: Identifier,
        emaStrategyID: Identifier,
        coordinationRoot: String,
        events: [TraderRuntimeLifecycleEvent],
        validationAnchors: [String] = TraderRuntimeLifecycle.requiredValidationAnchors,
        riskEngineHandoffRequired: Bool = true,
        directExecutionClientEnabled: Bool = false,
        brokerCommandEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.lifecycleID = lifecycleID
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.accountContextID = accountContextID
        self.accountIdentity = accountIdentity
        self.emaStrategyID = emaStrategyID
        self.coordinationRoot = coordinationRoot
        self.events = events
        self.validationAnchors = validationAnchors
        self.riskEngineHandoffRequired = riskEngineHandoffRequired
        self.directExecutionClientEnabled = directExecutionClientEnabled
        self.brokerCommandEnabled = brokerCommandEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    /// 证明 lifecycle 按固定顺序完成配置、启动、绑定、注册、handoff 和关闭。
    public var lifecycleSequenceHeld: Bool {
        events.map(\.kind) == TraderRuntimeLifecycle.requiredEventKinds
    }

    /// 证明 Trader 同时管理 account context 和 EMA strategy instance。
    public var managesAccountAndEMAInstance: Bool {
        releaseVenue == TraderRuntimeLifecycle.requiredReleaseVenue
            && activeConcreteStrategy == TraderRuntimeLifecycle.requiredActiveConcreteStrategy
            && accountContextID.rawValue.isEmpty == false
            && accountIdentity.rawValue.isEmpty == false
            && emaStrategyID.rawValue.isEmpty == false
    }

    /// 证明 Trader lifecycle 没有 direct order submission、broker command 或 production trading。
    public var noDirectOrderSubmissionBoundaryHeld: Bool {
        directExecutionClientEnabled == false
            && brokerCommandEnabled == false
            && omsBypassEnabled == false
            && productionTradingEnabledByDefault == false
            && nonBinanceVenueEnabled == false
            && nonEMAStrategyEnabled == false
    }

    /// GH-527 总边界：lifecycle 成立，且风险 handoff 与 no-command flags 均成立。
    public var boundaryHeld: Bool {
        lifecycleSequenceHeld
            && managesAccountAndEMAInstance
            && validationAnchors == TraderRuntimeLifecycle.requiredValidationAnchors
            && riskEngineHandoffRequired
            && coordinationRoot == TraderCoordinationRiskBindingBoundaryFixture.deterministic.coordinationRiskBindingRoot
            && noDirectOrderSubmissionBoundaryHeld
    }

    private func validate() throws {
        guard releaseVenue == TraderRuntimeLifecycle.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.nonBinanceVenue")
        }
        guard activeConcreteStrategy == TraderRuntimeLifecycle.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.nonEMAStrategy")
        }
        guard validationAnchors == TraderRuntimeLifecycle.requiredValidationAnchors else {
            throw CoreError.traderAccountContextMismatch(
                field: "traderRuntimeLifecycle.validationAnchors",
                expected: TraderRuntimeLifecycle.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard events.map(\.kind) == TraderRuntimeLifecycle.requiredEventKinds else {
            throw CoreError.traderAccountContextMismatch(
                field: "traderRuntimeLifecycle.events",
                expected: TraderRuntimeLifecycle.requiredEventKinds.map(\.rawValue).joined(separator: ","),
                actual: events.map(\.kind.rawValue).joined(separator: ",")
            )
        }
        try forbid(riskEngineHandoffRequired == false, "riskEngineHandoffRequired")
        try forbid(directExecutionClientEnabled, "directExecutionClientEnabled")
        try forbid(brokerCommandEnabled, "brokerCommandEnabled")
        try forbid(omsBypassEnabled, "omsBypassEnabled")
        try forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try forbid(nonBinanceVenueEnabled, "nonBinanceVenueEnabled")
        try forbid(nonEMAStrategyEnabled, "nonEMAStrategyEnabled")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.\(field)")
        }
    }
}

/// TraderRuntimeLifecycle 组织 release v0.1.0 Trader 的 account + EMA + coordination lifecycle。
///
/// 它只生成本地 report，不提交订单、不调用 ExecutionClient、不连接 broker、不读取 production secret。
public struct TraderRuntimeLifecycle: Codable, Equatable, Sendable {
    public let lifecycleID: Identifier
    public let accountContext: TraderAccountContext
    public let emaStrategyConfiguration: EMACrossStrategyConfiguration
    public let coordinationBoundary: TraderCoordinationRiskBindingBoundaryEvidence
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
        lifecycleID: Identifier,
        accountContext: TraderAccountContext,
        emaStrategyConfiguration: EMACrossStrategyConfiguration,
        coordinationBoundary: TraderCoordinationRiskBindingBoundaryEvidence =
            TraderCoordinationRiskBindingBoundaryFixture.deterministic,
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
        self.lifecycleID = lifecycleID
        self.accountContext = accountContext
        self.emaStrategyConfiguration = emaStrategyConfiguration
        self.coordinationBoundary = coordinationBoundary
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

    /// 运行 deterministic startup -> shutdown lifecycle 并输出 GH-527 report。
    public func runDeterministicLifecycle(startedAt: Date, shutdownAt: Date) throws -> TraderRuntimeLifecycleReport {
        guard shutdownAt >= startedAt else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.shutdownBeforeStart")
        }
        let events = try [
            event(.configured, at: startedAt.addingTimeInterval(-1)),
            event(.started, at: startedAt),
            event(.accountContextBound, at: startedAt.addingTimeInterval(1)),
            event(.emaStrategyRegistered, at: startedAt.addingTimeInterval(2)),
            event(.coordinationRiskHandoffPrepared, at: startedAt.addingTimeInterval(3)),
            event(.shutdown, at: shutdownAt)
        ]
        return try TraderRuntimeLifecycleReport(
            lifecycleID: lifecycleID,
            releaseVenue: releaseVenue,
            activeConcreteStrategy: activeConcreteStrategy,
            accountContextID: accountContext.contextID,
            accountIdentity: accountContext.accountIdentity,
            emaStrategyID: emaStrategyConfiguration.strategyID,
            coordinationRoot: coordinationBoundary.coordinationRiskBindingRoot,
            events: events,
            validationAnchors: validationAnchors,
            riskEngineHandoffRequired: true,
            directExecutionClientEnabled: directExecutionClientEnabled,
            brokerCommandEnabled: brokerCommandEnabled,
            omsBypassEnabled: omsBypassEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            nonEMAStrategyEnabled: nonEMAStrategyEnabled
        )
    }

    /// deterministic fixture 只服务本地测试和 PR evidence，不连接真实账户或交易所。
    public static func deterministicFixture() throws -> TraderRuntimeLifecycle {
        try TraderRuntimeLifecycle(
            lifecycleID: Identifier("gh-527-trader-runtime-lifecycle"),
            accountContext: .deterministicFixture,
            emaStrategyConfiguration: EMACrossStrategyConfiguration(
                strategyID: Identifier("gh-527-ema-instance"),
                symbol: Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                shortPeriod: 2,
                longPeriod: 3
            )
        )
    }

    /// GH-527 lifecycle 的 required validation anchors。
    public static let requiredValidationAnchors = [
        "GH-527-TRADER-RUNTIME-LIFECYCLE",
        "GH-527-TRADER-ACCOUNTS-EMA-COORDINATION-LIFECYCLE",
        "GH-527-NO-DIRECT-ORDER-SUBMISSION",
        "TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE"
    ]

    public static let requiredReleaseVenue = "Binance"
    public static let requiredActiveConcreteStrategy = "EMA"
    public static let requiredEventKinds: [TraderRuntimeLifecycleEventKind] = [
        .configured,
        .started,
        .accountContextBound,
        .emaStrategyRegistered,
        .coordinationRiskHandoffPrepared,
        .shutdown
    ]

    private func validate() throws {
        guard accountContext.accountContextBoundaryHeld else {
            throw CoreError.traderAccountContextForbiddenCapability("traderRuntimeLifecycle.accountContext")
        }
        guard emaStrategyConfiguration.strategyID.rawValue.isEmpty == false else {
            throw CoreError.emptyIdentifier("traderRuntimeLifecycle.emaStrategyID")
        }
        guard coordinationBoundary.isGenericBindingProtocolAndAdapterOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.coordinationBoundary")
        }
        guard coordinationBoundary.concreteStrategiesRemainTraderOwned else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.strategyOwnership")
        }
        guard coordinationBoundary.forbidsExecutionAndLiveCommandPaths else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.executionCommandPath")
        }
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.nonBinanceVenue")
        }
        guard activeConcreteStrategy == Self.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.nonEMAStrategy")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.traderAccountContextMismatch(
                field: "traderRuntimeLifecycle.validationAnchors",
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

    private func event(_ kind: TraderRuntimeLifecycleEventKind, at occurredAt: Date) throws -> TraderRuntimeLifecycleEvent {
        try TraderRuntimeLifecycleEvent(
            eventID: Identifier("gh-527-\(kind.rawValue)"),
            kind: kind,
            occurredAt: occurredAt,
            sourceIdentity: "gh-527-trader-lifecycle-\(kind.rawValue)"
        )
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.\(field)")
        }
    }
}
