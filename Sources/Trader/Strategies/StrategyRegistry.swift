import DomainModel
import Foundation

/// StrategyActorKind 固定 release v0.2.0 当前可注册的策略种类。
///
/// 该枚举只允许 EMA 与 RSI，未知策略种类会在 registry / actor 构造前被拒绝。它不引入
/// non-EMA / non-RSI active strategy，不创建 strategy scheduler，也不授权 live command。
public enum StrategyActorKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema
    case rsi

    public init(contractValue: String) throws {
        let normalized = contractValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = Self(rawValue: normalized) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyRegistry.unknownStrategyKind.\(normalized)"
            )
        }
        self = value
    }

    public var canonicalSourceRoot: String {
        switch self {
        case .ema:
            "Sources/Trader/Strategies/EMA"
        case .rsi:
            "Sources/Trader/Strategies/RSI"
        }
    }
}

/// StrategyProductBinding 表达策略 actor 与 Binance product instrument 的运行绑定。
///
/// Binding 只描述 strategy intent 可进入哪个 product 的 pre-risk-gate evidence surface。
/// 它不调用 ExecutionClient，不连接 broker，不创建 OMS command，不读取 signed/account endpoint。
public struct StrategyProductBinding: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let kind: StrategyActorKind
    public let instrument: InstrumentIdentity
    public let emitsTargetExposureIntent: Bool
    public let allowsTargetShort: Bool
    public let requiresRiskEngineBeforeExecution: Bool
    public let callsExecutionClientDirectly: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        strategyID: Identifier,
        kind: StrategyActorKind,
        instrument: InstrumentIdentity,
        emitsTargetExposureIntent: Bool = true,
        allowsTargetShort: Bool = false,
        requiresRiskEngineBeforeExecution: Bool = true,
        callsExecutionClientDirectly: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.nonBinanceInstrument"
            )
        }
        guard emitsTargetExposureIntent else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.missingTargetExposureIntent"
            )
        }
        guard allowsTargetShort == false || instrument.productType == .usdsPerpetual else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "Spot strategy binding must never allow targetShort"
            )
        }
        guard kind == .rsi || allowsTargetShort == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.nonRSITargetShort"
            )
        }
        guard requiresRiskEngineBeforeExecution else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.riskBypass"
            )
        }
        guard callsExecutionClientDirectly == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.executionClientBypass"
            )
        }
        guard productionTradingEnabledByDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyProductBinding.productionTradingEnabledByDefault"
            )
        }

        self.strategyID = strategyID
        self.kind = kind
        self.instrument = instrument
        self.emitsTargetExposureIntent = emitsTargetExposureIntent
        self.allowsTargetShort = allowsTargetShort
        self.requiresRiskEngineBeforeExecution = requiresRiskEngineBeforeExecution
        self.callsExecutionClientDirectly = callsExecutionClientDirectly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    public var isPreRiskOnlyBinding: Bool {
        emitsTargetExposureIntent
            && requiresRiskEngineBeforeExecution
            && callsExecutionClientDirectly == false
            && productionTradingEnabledByDefault == false
    }
}

/// StrategyActorRegistration 是 registry 中保存的策略 actor 描述。
///
/// Registration 只保存 actor identity、strategy kind、source root 和 product bindings。
/// 它不保存 runtime object、broker session、OMS state、account payload 或 command handler。
public struct StrategyActorRegistration: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let kind: StrategyActorKind
    public let displayName: String
    public let sourceRoot: String
    public let productBindings: [StrategyProductBinding]
    public let callsExecutionClientDirectly: Bool
    public let callsBrokerOrOMS: Bool
    public let exposesLiveCommandSurface: Bool

    public init(
        strategyID: Identifier,
        kind: StrategyActorKind,
        displayName: String,
        sourceRoot: String? = nil,
        productBindings: [StrategyProductBinding],
        callsExecutionClientDirectly: Bool = false,
        callsBrokerOrOMS: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard productBindings.isEmpty == false else {
            throw CoreError.traderAccountContextMismatch(
                field: "strategyActor.productBindings",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard productBindings.allSatisfy({ $0.strategyID == strategyID && $0.kind == kind }) else {
            throw CoreError.traderAccountContextMismatch(
                field: "strategyActor.productBindings",
                expected: "\(kind.rawValue):\(strategyID.rawValue)",
                actual: productBindings.map { "\($0.kind.rawValue):\($0.strategyID.rawValue)" }.joined(separator: ",")
            )
        }
        guard callsExecutionClientDirectly == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyActor.executionClientBypass"
            )
        }
        guard callsBrokerOrOMS == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyActor.brokerOrOMSBypass"
            )
        }
        guard exposesLiveCommandSurface == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyActor.liveCommandSurface"
            )
        }

        self.strategyID = strategyID
        self.kind = kind
        self.displayName = displayName
        self.sourceRoot = sourceRoot ?? kind.canonicalSourceRoot
        self.productBindings = productBindings
        self.callsExecutionClientDirectly = callsExecutionClientDirectly
        self.callsBrokerOrOMS = callsBrokerOrOMS
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public var isExecutionIsolated: Bool {
        callsExecutionClientDirectly == false
            && callsBrokerOrOMS == false
            && exposesLiveCommandSurface == false
            && productBindings.allSatisfy(\.isPreRiskOnlyBinding)
    }
}

/// EMAStrategyActor 是 EMA 注册入口的 deterministic actor descriptor。
public struct EMAStrategyActor: Codable, Equatable, Sendable {
    public let registration: StrategyActorRegistration

    public init(
        strategyID: Identifier,
        instruments: [InstrumentIdentity]
    ) throws {
        let bindings = try instruments.map { instrument in
            try StrategyProductBinding(
                strategyID: strategyID,
                kind: .ema,
                instrument: instrument
            )
        }
        self.registration = try StrategyActorRegistration(
            strategyID: strategyID,
            kind: .ema,
            displayName: "EMA",
            productBindings: bindings
        )
    }
}

/// RSIStrategyActor 是 RSI 注册入口的 deterministic actor descriptor。
public struct RSIStrategyActor: Codable, Equatable, Sendable {
    public let registration: StrategyActorRegistration

    public init(
        strategyID: Identifier,
        instruments: [InstrumentIdentity],
        perpetualShortEnabled: Bool = false
    ) throws {
        let bindings = try instruments.map { instrument in
            try StrategyProductBinding(
                strategyID: strategyID,
                kind: .rsi,
                instrument: instrument,
                allowsTargetShort: perpetualShortEnabled && instrument.productType == .usdsPerpetual
            )
        }
        self.registration = try StrategyActorRegistration(
            strategyID: strategyID,
            kind: .rsi,
            displayName: "RSI",
            productBindings: bindings
        )
    }
}

/// StrategyRegistry 管理当前 release 的 strategy actor registration。
///
/// Registry 只做本地 deterministic registration / lookup，不启动 actor loop、不调度策略、
/// 不持有 ExecutionClient，不连接 broker / OMS，也不授权 production trading。
public struct StrategyRegistry: Codable, Equatable, Sendable {
    public private(set) var registrationsByID: [Identifier: StrategyActorRegistration]

    public init(registrations: [StrategyActorRegistration] = []) throws {
        self.registrationsByID = [:]
        for registration in registrations {
            try register(registration)
        }
    }

    public mutating func register(_ registration: StrategyActorRegistration) throws {
        guard registrationsByID[registration.strategyID] == nil else {
            throw CoreError.traderAccountContextMismatch(
                field: "strategyRegistry.duplicateStrategyID",
                expected: "unique",
                actual: registration.strategyID.rawValue
            )
        }
        guard registration.isExecutionIsolated else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "strategyRegistry.executionIsolation"
            )
        }
        registrationsByID[registration.strategyID] = registration
    }

    public func registration(for strategyID: Identifier) throws -> StrategyActorRegistration {
        guard let registration = registrationsByID[strategyID] else {
            throw CoreError.traderAccountContextMismatch(
                field: "strategyRegistry.strategyID",
                expected: "registered",
                actual: strategyID.rawValue
            )
        }
        return registration
    }

    public func registrations(for kind: StrategyActorKind) -> [StrategyActorRegistration] {
        registrationsByID.values
            .filter { $0.kind == kind }
            .sorted { $0.strategyID.rawValue < $1.strategyID.rawValue }
    }

    /// GH-571 deterministic fixture 同时注册 EMA 与 RSI，覆盖 Spot + USDⓈ-M Perpetual binding。
    public static func deterministicReleaseV020(perpetualShortEnabled: Bool = true) throws -> Self {
        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let emaActor = try EMAStrategyActor(
            strategyID: Identifier("gh-571-ema-actor"),
            instruments: [spot, perp]
        )
        let rsiActor = try RSIStrategyActor(
            strategyID: Identifier("gh-571-rsi-actor"),
            instruments: [spot, perp],
            perpetualShortEnabled: perpetualShortEnabled
        )
        return try StrategyRegistry(registrations: [
            emaActor.registration,
            rsiActor.registration
        ])
    }
}
