import DomainModel
import Foundation
import RiskEngine

/// ReleaseV020SpotExecutionAlgorithmSide 是 #581 Spot ExecutionAlgorithm 的本地订单方向。
///
/// 它只表达 Binance Spot 的受控 order intent evidence，不是 broker side、不生成 signed request，
/// 也不授权真实 submit / cancel / replace。
public enum ReleaseV020SpotExecutionAlgorithmSide: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case buy = "BUY"
    case sell = "SELL"
}

/// ReleaseV020SpotExecutionAlgorithmStatus 描述 #581 算法输出。
public enum ReleaseV020SpotExecutionAlgorithmStatus: String, Codable, Equatable, Hashable, Sendable {
    case orderIntentCreated
    case noOrder
    case blocked
}

/// ReleaseV020SpotExecutionAlgorithmBlocker 记录 #581 阻断原因。
public enum ReleaseV020SpotExecutionAlgorithmBlocker: String, Codable, Equatable, Hashable, Sendable {
    case riskDecisionNotForwarded
    case sourceIntentMismatch
    case nonSpotInstrument
    case targetShortForbidden
    case insufficientPositionToFlatten
}

/// ReleaseV020SpotExecutionNoOrderReason 记录 #581 无需生成订单的原因。
public enum ReleaseV020SpotExecutionNoOrderReason: String, Codable, Equatable, Hashable, Sendable {
    case holdTargetExposure
    case alreadyLong
    case alreadyFlat
}

/// ReleaseV020SpotExecutionAlgorithmInput 是 #581 Spot ExecutionAlgorithm 的输入合同。
public struct ReleaseV020SpotExecutionAlgorithmInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let targetExposure: TargetExposureIntent
    public let sourceOrderIntent: ProductAwareOrderIntent?
    public let spotRiskDecision: ReleaseV020SpotRiskDecision?
    public let currentBasePositionQuantity: Double
    public let evaluatedAt: Date
    public let sourceSequence: Int
    public let productionTradingRequested: Bool
    public let riskEngineBypassed: Bool
    public let commandGatewayBypassed: Bool
    public let executionClientTouched: Bool
    public let brokerGatewayTouched: Bool
    public let omsBypassed: Bool
    public let eventStoreBypassed: Bool
    public let killSwitchBypassed: Bool
    public let noTradeBypassed: Bool
    public let realOrderRequested: Bool

    public init(
        inputID: Identifier,
        targetExposure: TargetExposureIntent,
        sourceOrderIntent: ProductAwareOrderIntent? = nil,
        spotRiskDecision: ReleaseV020SpotRiskDecision? = nil,
        currentBasePositionQuantity: Double,
        evaluatedAt: Date,
        sourceSequence: Int,
        productionTradingRequested: Bool = false,
        riskEngineBypassed: Bool = false,
        commandGatewayBypassed: Bool = false,
        executionClientTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        omsBypassed: Bool = false,
        eventStoreBypassed: Bool = false,
        killSwitchBypassed: Bool = false,
        noTradeBypassed: Bool = false,
        realOrderRequested: Bool = false
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard currentBasePositionQuantity.isFinite, currentBasePositionQuantity >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotExecutionAlgorithm.currentBasePositionQuantity",
                expected: "finite non-negative value",
                actual: "\(currentBasePositionQuantity)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingRequested", productionTradingRequested),
            ("riskEngineBypassed", riskEngineBypassed),
            ("commandGatewayBypassed", commandGatewayBypassed),
            ("executionClientTouched", executionClientTouched),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("omsBypassed", omsBypassed),
            ("eventStoreBypassed", eventStoreBypassed),
            ("killSwitchBypassed", killSwitchBypassed),
            ("noTradeBypassed", noTradeBypassed),
            ("realOrderRequested", realOrderRequested)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotExecutionAlgorithm.\(forbiddenFlag.0)"
            )
        }

        self.inputID = inputID
        self.targetExposure = targetExposure
        self.sourceOrderIntent = sourceOrderIntent
        self.spotRiskDecision = spotRiskDecision
        self.currentBasePositionQuantity = currentBasePositionQuantity
        self.evaluatedAt = evaluatedAt
        self.sourceSequence = sourceSequence
        self.productionTradingRequested = productionTradingRequested
        self.riskEngineBypassed = riskEngineBypassed
        self.commandGatewayBypassed = commandGatewayBypassed
        self.executionClientTouched = executionClientTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.omsBypassed = omsBypassed
        self.eventStoreBypassed = eventStoreBypassed
        self.killSwitchBypassed = killSwitchBypassed
        self.noTradeBypassed = noTradeBypassed
        self.realOrderRequested = realOrderRequested
    }

    public var inputBoundaryHeld: Bool {
        sourceSequence > 0
            && currentBasePositionQuantity.isFinite
            && currentBasePositionQuantity >= 0
            && productionTradingRequested == false
            && riskEngineBypassed == false
            && commandGatewayBypassed == false
            && executionClientTouched == false
            && brokerGatewayTouched == false
            && omsBypassed == false
            && eventStoreBypassed == false
            && killSwitchBypassed == false
            && noTradeBypassed == false
            && realOrderRequested == false
    }
}

/// ReleaseV020SpotExecutionAlgorithmOrderIntent 是 #581 生成的本地 order intent evidence。
public struct ReleaseV020SpotExecutionAlgorithmOrderIntent: Codable, Equatable, Sendable {
    public let orderIntentID: Identifier
    public let sourceInputID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let sourceProductAwareIntentID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let side: ReleaseV020SpotExecutionAlgorithmSide
    public let quantity: Quantity
    public let referencePrice: Price
    public let notional: Double
    public let currentBasePositionQuantity: Double
    public let createdAt: Date
    public let validationAnchors: [String]
    public let requiresOMSBeforeExecution: Bool
    public let requiresEventStoreBeforeExecution: Bool
    public let requiresKillSwitchBeforeExecution: Bool
    public let requiresNoTradeGateBeforeExecution: Bool
    public let productionTradingEnabledByDefault: Bool
    public let authorizesTradingExecution: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public init(
        orderIntentID: Identifier,
        sourceInputID: Identifier,
        sourceRiskDecisionID: Identifier,
        sourceProductAwareIntentID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        side: ReleaseV020SpotExecutionAlgorithmSide,
        quantity: Quantity,
        referencePrice: Price,
        currentBasePositionQuantity: Double,
        createdAt: Date,
        validationAnchors: [String] = ReleaseV020SpotExecutionAlgorithmDecision.requiredValidationAnchors,
        requiresOMSBeforeExecution: Bool = true,
        requiresEventStoreBeforeExecution: Bool = true,
        requiresKillSwitchBeforeExecution: Bool = true,
        requiresNoTradeGateBeforeExecution: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        authorizesTradingExecution: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard instrument.productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotExecutionAlgorithm.instrument",
                expected: ProductType.spot.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotExecutionAlgorithm.quantity",
                expected: "positive order intent quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard currentBasePositionQuantity.isFinite, currentBasePositionQuantity >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotExecutionAlgorithm.currentBasePositionQuantity",
                expected: "finite non-negative value",
                actual: "\(currentBasePositionQuantity)"
            )
        }
        switch (targetExposure, side) {
        case (.targetLong, .buy), (.targetFlat, .sell):
            break
        default:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotExecutionAlgorithm.side",
                expected: "targetLong -> BUY or targetFlat -> SELL",
                actual: "\(targetExposure.rawValue) -> \(side.rawValue)"
            )
        }
        for requiredGate in [
            ("requiresOMSBeforeExecution", requiresOMSBeforeExecution),
            ("requiresEventStoreBeforeExecution", requiresEventStoreBeforeExecution),
            ("requiresKillSwitchBeforeExecution", requiresKillSwitchBeforeExecution),
            ("requiresNoTradeGateBeforeExecution", requiresNoTradeGateBeforeExecution)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotExecutionAlgorithm.\(requiredGate.0)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotExecutionAlgorithm.\(forbiddenFlag.0)"
            )
        }

        self.orderIntentID = orderIntentID
        self.sourceInputID = sourceInputID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.sourceProductAwareIntentID = sourceProductAwareIntentID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.side = side
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notional = quantity.rawValue * referencePrice.rawValue
        self.currentBasePositionQuantity = currentBasePositionQuantity
        self.createdAt = createdAt
        self.validationAnchors = validationAnchors
        self.requiresOMSBeforeExecution = requiresOMSBeforeExecution
        self.requiresEventStoreBeforeExecution = requiresEventStoreBeforeExecution
        self.requiresKillSwitchBeforeExecution = requiresKillSwitchBeforeExecution
        self.requiresNoTradeGateBeforeExecution = requiresNoTradeGateBeforeExecution
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.authorizesTradingExecution = authorizesTradingExecution
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
    }

    public var boundaryHeld: Bool {
        instrument.productType == .spot
            && quantity.rawValue > 0
            && validationAnchors == ReleaseV020SpotExecutionAlgorithmDecision.requiredValidationAnchors
            && requiresOMSBeforeExecution
            && requiresEventStoreBeforeExecution
            && requiresKillSwitchBeforeExecution
            && requiresNoTradeGateBeforeExecution
            && productionTradingEnabledByDefault == false
            && authorizesTradingExecution == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }
}

/// ReleaseV020SpotExecutionAlgorithmDecision 是 #581 的可审计算法决策。
public struct ReleaseV020SpotExecutionAlgorithmDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let inputID: Identifier
    public let targetExposure: TargetExposureIntent
    public let status: ReleaseV020SpotExecutionAlgorithmStatus
    public let blocker: ReleaseV020SpotExecutionAlgorithmBlocker?
    public let noOrderReason: ReleaseV020SpotExecutionNoOrderReason?
    public let orderIntent: ReleaseV020SpotExecutionAlgorithmOrderIntent?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool
    public let submitsRealOrder: Bool

    public init(
        decisionID: Identifier,
        inputID: Identifier,
        targetExposure: TargetExposureIntent,
        status: ReleaseV020SpotExecutionAlgorithmStatus,
        blocker: ReleaseV020SpotExecutionAlgorithmBlocker?,
        noOrderReason: ReleaseV020SpotExecutionNoOrderReason?,
        orderIntent: ReleaseV020SpotExecutionAlgorithmOrderIntent?,
        evaluatedAt: Date,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeState: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        switch status {
        case .orderIntentCreated:
            guard blocker == nil, noOrderReason == nil, orderIntent != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020SpotExecutionAlgorithm.orderIntentCreated",
                    expected: "order intent present without blocker or no-order reason",
                    actual: "invalid"
                )
            }
        case .noOrder:
            guard blocker == nil, noOrderReason != nil, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020SpotExecutionAlgorithm.noOrder",
                    expected: "no-order reason present without blocker or order intent",
                    actual: "invalid"
                )
            }
        case .blocked:
            guard blocker != nil, noOrderReason == nil, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020SpotExecutionAlgorithm.blocked",
                    expected: "blocker present without no-order reason or order intent",
                    actual: "invalid"
                )
            }
        }
        if let orderIntent {
            guard orderIntent.boundaryHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020SpotExecutionAlgorithm.orderIntentBoundaryHeld",
                    expected: "true",
                    actual: "false"
                )
            }
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("bypassesOMS", bypassesOMS),
            ("bypassesEventStore", bypassesEventStore),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("bypassesNoTradeState", bypassesNoTradeState),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotExecutionAlgorithm.\(forbiddenFlag.0)"
            )
        }

        self.decisionID = decisionID
        self.inputID = inputID
        self.targetExposure = targetExposure
        self.status = status
        self.blocker = blocker
        self.noOrderReason = noOrderReason
        self.orderIntent = orderIntent
        self.evaluatedAt = evaluatedAt
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.bypassesOMS = bypassesOMS
        self.bypassesEventStore = bypassesEventStore
        self.bypassesKillSwitch = bypassesKillSwitch
        self.bypassesNoTradeState = bypassesNoTradeState
        self.submitsRealOrder = submitsRealOrder
    }

    public var orderIntentCreated: Bool {
        status == .orderIntentCreated
            && orderIntent?.boundaryHeld == true
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && bypassesOMS == false
            && bypassesEventStore == false
            && bypassesKillSwitch == false
            && bypassesNoTradeState == false
            && submitsRealOrder == false
    }

    public static let requiredValidationAnchors = [
        "GH-581-SPOT-EXECUTION-ALGORITHM",
        "GH-581-TARGET-LONG-BUY",
        "GH-581-TARGET-FLAT-SELL",
        "GH-581-TARGET-SHORT-BLOCKED",
        "GH-581-HOLD-NO-ORDER",
        "TVM-RELEASE-V020-SPOT-EXECUTION-ALGORITHM"
    ]
}

/// ReleaseV020SpotExecutionAlgorithm 将 Spot target exposure 映射为本地受控 order intent evidence。
public enum ReleaseV020SpotExecutionAlgorithm {
    public static func decide(
        decisionID: Identifier,
        input: ReleaseV020SpotExecutionAlgorithmInput
    ) throws -> ReleaseV020SpotExecutionAlgorithmDecision {
        guard input.inputBoundaryHeld else {
            return try blocked(decisionID: decisionID, input: input, blocker: .riskDecisionNotForwarded)
        }

        switch input.targetExposure {
        case .hold:
            return try noOrder(decisionID: decisionID, input: input, reason: .holdTargetExposure)
        case .targetShort:
            return try blocked(decisionID: decisionID, input: input, blocker: .targetShortForbidden)
        case .targetLong:
            guard input.currentBasePositionQuantity == 0 else {
                return try noOrder(decisionID: decisionID, input: input, reason: .alreadyLong)
            }
            return try orderDecision(decisionID: decisionID, input: input, side: .buy)
        case .targetFlat:
            guard input.currentBasePositionQuantity > 0 else {
                return try noOrder(decisionID: decisionID, input: input, reason: .alreadyFlat)
            }
            guard let sourceOrderIntent = input.sourceOrderIntent,
                  sourceOrderIntent.quantity.rawValue <= input.currentBasePositionQuantity else {
                return try blocked(decisionID: decisionID, input: input, blocker: .insufficientPositionToFlatten)
            }
            return try orderDecision(decisionID: decisionID, input: input, side: .sell)
        }
    }

    private static func orderDecision(
        decisionID: Identifier,
        input: ReleaseV020SpotExecutionAlgorithmInput,
        side: ReleaseV020SpotExecutionAlgorithmSide
    ) throws -> ReleaseV020SpotExecutionAlgorithmDecision {
        guard let riskDecision = input.spotRiskDecision, riskDecision.forwardsToCommandGateway else {
            return try blocked(decisionID: decisionID, input: input, blocker: .riskDecisionNotForwarded)
        }
        guard let sourceOrderIntent = input.sourceOrderIntent,
              sourceOrderIntent.isPreRiskGateIntent,
              sourceOrderIntent.instrument.productType == .spot,
              sourceOrderIntent.instrument == riskDecision.instrument,
              sourceOrderIntent.targetExposure == input.targetExposure,
              riskDecision.targetExposure == input.targetExposure,
              abs(riskDecision.notional - sourceOrderIntent.quantity.rawValue * sourceOrderIntent.referencePrice.rawValue)
                  < 0.000_000_1 else {
            return try blocked(decisionID: decisionID, input: input, blocker: .sourceIntentMismatch)
        }
        guard riskDecision.instrument?.productType == .spot else {
            return try blocked(decisionID: decisionID, input: input, blocker: .nonSpotInstrument)
        }

        let orderIntent = try ReleaseV020SpotExecutionAlgorithmOrderIntent(
            orderIntentID: Identifier.constant("\(decisionID.rawValue)-order-intent"),
            sourceInputID: input.inputID,
            sourceRiskDecisionID: riskDecision.decisionID,
            sourceProductAwareIntentID: sourceOrderIntent.intentID,
            instrument: sourceOrderIntent.instrument,
            targetExposure: input.targetExposure,
            side: side,
            quantity: sourceOrderIntent.quantity,
            referencePrice: sourceOrderIntent.referencePrice,
            currentBasePositionQuantity: input.currentBasePositionQuantity,
            createdAt: input.evaluatedAt
        )
        return try ReleaseV020SpotExecutionAlgorithmDecision(
            decisionID: decisionID,
            inputID: input.inputID,
            targetExposure: input.targetExposure,
            status: .orderIntentCreated,
            blocker: nil,
            noOrderReason: nil,
            orderIntent: orderIntent,
            evaluatedAt: input.evaluatedAt
        )
    }

    private static func noOrder(
        decisionID: Identifier,
        input: ReleaseV020SpotExecutionAlgorithmInput,
        reason: ReleaseV020SpotExecutionNoOrderReason
    ) throws -> ReleaseV020SpotExecutionAlgorithmDecision {
        try ReleaseV020SpotExecutionAlgorithmDecision(
            decisionID: decisionID,
            inputID: input.inputID,
            targetExposure: input.targetExposure,
            status: .noOrder,
            blocker: nil,
            noOrderReason: reason,
            orderIntent: nil,
            evaluatedAt: input.evaluatedAt
        )
    }

    private static func blocked(
        decisionID: Identifier,
        input: ReleaseV020SpotExecutionAlgorithmInput,
        blocker: ReleaseV020SpotExecutionAlgorithmBlocker
    ) throws -> ReleaseV020SpotExecutionAlgorithmDecision {
        try ReleaseV020SpotExecutionAlgorithmDecision(
            decisionID: decisionID,
            inputID: input.inputID,
            targetExposure: input.targetExposure,
            status: .blocked,
            blocker: blocker,
            noOrderReason: nil,
            orderIntent: nil,
            evaluatedAt: input.evaluatedAt
        )
    }
}
