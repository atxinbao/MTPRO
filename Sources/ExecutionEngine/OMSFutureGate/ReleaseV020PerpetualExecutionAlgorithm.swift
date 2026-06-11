import DomainModel
import Foundation
import RiskEngine

/// ReleaseV020PerpetualExecutionAlgorithmSide 是 #582 Perp ExecutionAlgorithm 的本地订单方向。
///
/// 该方向只用于本地 deterministic order intent evidence，不是 Binance signed request、
/// broker side、OMS command 或 production trading 授权。
public enum ReleaseV020PerpetualExecutionAlgorithmSide: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case buy = "BUY"
    case sell = "SELL"
}

/// ReleaseV020PerpetualExecutionAlgorithmAction 描述 #582 Perp 算法的受控动作。
public enum ReleaseV020PerpetualExecutionAlgorithmAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case openLong
    case openShort
    case reduceOnlyCloseLong
    case reduceOnlyCloseShort
}

/// ReleaseV020PerpetualExecutionAlgorithmStatus 描述 #582 算法输出。
public enum ReleaseV020PerpetualExecutionAlgorithmStatus: String, Codable, Equatable, Hashable, Sendable {
    case orderIntentCreated
    case noOrder
    case blocked
}

/// ReleaseV020PerpetualExecutionAlgorithmBlocker 记录 #582 阻断原因。
public enum ReleaseV020PerpetualExecutionAlgorithmBlocker: String, Codable, Equatable, Hashable, Sendable {
    case riskDecisionNotForwarded
    case sourceIntentMismatch
    case nonPerpetualInstrument
    case uncontrolledOneShotFlip
    case reduceOnlyCloseInvalid
}

/// ReleaseV020PerpetualExecutionNoOrderReason 记录 #582 无需订单的原因。
public enum ReleaseV020PerpetualExecutionNoOrderReason: String, Codable, Equatable, Hashable, Sendable {
    case holdTargetExposure
    case alreadyLong
    case alreadyShort
    case alreadyFlat
}

/// ReleaseV020PerpetualExecutionAlgorithmInput 是 #582 Perp ExecutionAlgorithm 的输入合同。
public struct ReleaseV020PerpetualExecutionAlgorithmInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let targetExposure: TargetExposureIntent
    public let sourceOrderIntent: ProductAwareOrderIntent?
    public let perpetualRiskDecision: ReleaseV020PerpetualRiskDecision?
    public let currentPositionQuantity: Double
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
    public let leverageActionRequested: Bool
    public let marginActionRequested: Bool
    public let realOrderRequested: Bool

    public init(
        inputID: Identifier,
        targetExposure: TargetExposureIntent,
        sourceOrderIntent: ProductAwareOrderIntent? = nil,
        perpetualRiskDecision: ReleaseV020PerpetualRiskDecision? = nil,
        currentPositionQuantity: Double,
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
        leverageActionRequested: Bool = false,
        marginActionRequested: Bool = false,
        realOrderRequested: Bool = false
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard currentPositionQuantity.isFinite else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualExecutionAlgorithm.currentPositionQuantity",
                expected: "finite signed position quantity",
                actual: "\(currentPositionQuantity)"
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
            ("leverageActionRequested", leverageActionRequested),
            ("marginActionRequested", marginActionRequested),
            ("realOrderRequested", realOrderRequested)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualExecutionAlgorithm.\(forbiddenFlag.0)"
            )
        }

        self.inputID = inputID
        self.targetExposure = targetExposure
        self.sourceOrderIntent = sourceOrderIntent
        self.perpetualRiskDecision = perpetualRiskDecision
        self.currentPositionQuantity = currentPositionQuantity
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
        self.leverageActionRequested = leverageActionRequested
        self.marginActionRequested = marginActionRequested
        self.realOrderRequested = realOrderRequested
    }

    public var inputBoundaryHeld: Bool {
        sourceSequence > 0
            && currentPositionQuantity.isFinite
            && productionTradingRequested == false
            && riskEngineBypassed == false
            && commandGatewayBypassed == false
            && executionClientTouched == false
            && brokerGatewayTouched == false
            && omsBypassed == false
            && eventStoreBypassed == false
            && killSwitchBypassed == false
            && noTradeBypassed == false
            && leverageActionRequested == false
            && marginActionRequested == false
            && realOrderRequested == false
    }
}

/// ReleaseV020PerpetualExecutionAlgorithmOrderIntent 是 #582 生成的本地 Perp order intent evidence。
public struct ReleaseV020PerpetualExecutionAlgorithmOrderIntent: Codable, Equatable, Sendable {
    public let orderIntentID: Identifier
    public let sourceInputID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let sourceProductAwareIntentID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let action: ReleaseV020PerpetualExecutionAlgorithmAction
    public let side: ReleaseV020PerpetualExecutionAlgorithmSide
    public let quantity: Quantity
    public let referencePrice: Price
    public let notional: Double
    public let currentPositionQuantity: Double
    public let reduceOnly: Bool
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
    public let executesLeverageAction: Bool
    public let executesMarginAction: Bool
    public let submitsRealOrder: Bool

    public init(
        orderIntentID: Identifier,
        sourceInputID: Identifier,
        sourceRiskDecisionID: Identifier,
        sourceProductAwareIntentID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        action: ReleaseV020PerpetualExecutionAlgorithmAction,
        side: ReleaseV020PerpetualExecutionAlgorithmSide,
        quantity: Quantity,
        referencePrice: Price,
        currentPositionQuantity: Double,
        reduceOnly: Bool,
        createdAt: Date,
        validationAnchors: [String] = ReleaseV020PerpetualExecutionAlgorithmDecision.requiredValidationAnchors,
        requiresOMSBeforeExecution: Bool = true,
        requiresEventStoreBeforeExecution: Bool = true,
        requiresKillSwitchBeforeExecution: Bool = true,
        requiresNoTradeGateBeforeExecution: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        authorizesTradingExecution: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        executesLeverageAction: Bool = false,
        executesMarginAction: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualExecutionAlgorithm.instrument",
                expected: ProductType.usdsPerpetual.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualExecutionAlgorithm.quantity",
                expected: "positive order intent quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard currentPositionQuantity.isFinite else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualExecutionAlgorithm.currentPositionQuantity",
                expected: "finite signed position quantity",
                actual: "\(currentPositionQuantity)"
            )
        }
        switch (targetExposure, action, side, reduceOnly) {
        case (.targetLong, .openLong, .buy, false),
             (.targetShort, .openShort, .sell, false),
             (.targetFlat, .reduceOnlyCloseLong, .sell, true),
             (.targetFlat, .reduceOnlyCloseShort, .buy, true):
            break
        default:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020PerpetualExecutionAlgorithm.action",
                expected: "open long/short or reduce-only close long/short mapping",
                actual: "\(targetExposure.rawValue) -> \(action.rawValue) -> \(side.rawValue), reduceOnly=\(reduceOnly)"
            )
        }
        for requiredGate in [
            ("requiresOMSBeforeExecution", requiresOMSBeforeExecution),
            ("requiresEventStoreBeforeExecution", requiresEventStoreBeforeExecution),
            ("requiresKillSwitchBeforeExecution", requiresKillSwitchBeforeExecution),
            ("requiresNoTradeGateBeforeExecution", requiresNoTradeGateBeforeExecution)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualExecutionAlgorithm.\(requiredGate.0)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("executesLeverageAction", executesLeverageAction),
            ("executesMarginAction", executesMarginAction),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualExecutionAlgorithm.\(forbiddenFlag.0)"
            )
        }

        self.orderIntentID = orderIntentID
        self.sourceInputID = sourceInputID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.sourceProductAwareIntentID = sourceProductAwareIntentID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.action = action
        self.side = side
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notional = quantity.rawValue * referencePrice.rawValue
        self.currentPositionQuantity = currentPositionQuantity
        self.reduceOnly = reduceOnly
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
        self.executesLeverageAction = executesLeverageAction
        self.executesMarginAction = executesMarginAction
        self.submitsRealOrder = submitsRealOrder
    }

    public var boundaryHeld: Bool {
        instrument.productType == .usdsPerpetual
            && quantity.rawValue > 0
            && validationAnchors == ReleaseV020PerpetualExecutionAlgorithmDecision.requiredValidationAnchors
            && requiresOMSBeforeExecution
            && requiresEventStoreBeforeExecution
            && requiresKillSwitchBeforeExecution
            && requiresNoTradeGateBeforeExecution
            && productionTradingEnabledByDefault == false
            && authorizesTradingExecution == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && executesLeverageAction == false
            && executesMarginAction == false
            && submitsRealOrder == false
    }
}

/// ReleaseV020PerpetualExecutionAlgorithmDecision 是 #582 的可审计算法决策。
public struct ReleaseV020PerpetualExecutionAlgorithmDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let inputID: Identifier
    public let targetExposure: TargetExposureIntent
    public let status: ReleaseV020PerpetualExecutionAlgorithmStatus
    public let blocker: ReleaseV020PerpetualExecutionAlgorithmBlocker?
    public let noOrderReason: ReleaseV020PerpetualExecutionNoOrderReason?
    public let orderIntent: ReleaseV020PerpetualExecutionAlgorithmOrderIntent?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool
    public let executesLeverageAction: Bool
    public let executesMarginAction: Bool
    public let submitsRealOrder: Bool

    public init(
        decisionID: Identifier,
        inputID: Identifier,
        targetExposure: TargetExposureIntent,
        status: ReleaseV020PerpetualExecutionAlgorithmStatus,
        blocker: ReleaseV020PerpetualExecutionAlgorithmBlocker?,
        noOrderReason: ReleaseV020PerpetualExecutionNoOrderReason?,
        orderIntent: ReleaseV020PerpetualExecutionAlgorithmOrderIntent?,
        evaluatedAt: Date,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeState: Bool = false,
        executesLeverageAction: Bool = false,
        executesMarginAction: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        switch status {
        case .orderIntentCreated:
            guard blocker == nil, noOrderReason == nil, orderIntent != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020PerpetualExecutionAlgorithm.orderIntentCreated",
                    expected: "order intent present without blocker or no-order reason",
                    actual: "invalid"
                )
            }
        case .noOrder:
            guard blocker == nil, noOrderReason != nil, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020PerpetualExecutionAlgorithm.noOrder",
                    expected: "no-order reason present without blocker or order intent",
                    actual: "invalid"
                )
            }
        case .blocked:
            guard blocker != nil, noOrderReason == nil, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020PerpetualExecutionAlgorithm.blocked",
                    expected: "blocker present without no-order reason or order intent",
                    actual: "invalid"
                )
            }
        }
        if let orderIntent {
            guard orderIntent.boundaryHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020PerpetualExecutionAlgorithm.orderIntentBoundaryHeld",
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
            ("executesLeverageAction", executesLeverageAction),
            ("executesMarginAction", executesMarginAction),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020PerpetualExecutionAlgorithm.\(forbiddenFlag.0)"
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
        self.executesLeverageAction = executesLeverageAction
        self.executesMarginAction = executesMarginAction
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
            && executesLeverageAction == false
            && executesMarginAction == false
            && submitsRealOrder == false
    }

    public static let requiredValidationAnchors = [
        "GH-582-PERP-EXECUTION-ALGORITHM",
        "GH-582-OPEN-LONG",
        "GH-582-OPEN-SHORT",
        "GH-582-REDUCE-ONLY-CLOSE-LONG",
        "GH-582-REDUCE-ONLY-CLOSE-SHORT",
        "GH-582-NO-UNCONTROLLED-ONE-SHOT-FLIP",
        "TVM-RELEASE-V020-PERP-EXECUTION-ALGORITHM"
    ]
}

/// ReleaseV020PerpetualExecutionAlgorithm 将 Perp target exposure 映射为本地受控 order intent evidence。
public enum ReleaseV020PerpetualExecutionAlgorithm {
    public static func decide(
        decisionID: Identifier,
        input: ReleaseV020PerpetualExecutionAlgorithmInput
    ) throws -> ReleaseV020PerpetualExecutionAlgorithmDecision {
        guard input.inputBoundaryHeld else {
            return try blocked(decisionID: decisionID, input: input, blocker: .riskDecisionNotForwarded)
        }

        switch input.targetExposure {
        case .hold:
            return try noOrder(decisionID: decisionID, input: input, reason: .holdTargetExposure)
        case .targetLong:
            if input.currentPositionQuantity < 0 {
                return try blocked(decisionID: decisionID, input: input, blocker: .uncontrolledOneShotFlip)
            }
            guard input.currentPositionQuantity == 0 else {
                return try noOrder(decisionID: decisionID, input: input, reason: .alreadyLong)
            }
            return try orderDecision(decisionID: decisionID, input: input, action: .openLong, side: .buy, reduceOnly: false)
        case .targetShort:
            if input.currentPositionQuantity > 0 {
                return try blocked(decisionID: decisionID, input: input, blocker: .uncontrolledOneShotFlip)
            }
            guard input.currentPositionQuantity == 0 else {
                return try noOrder(decisionID: decisionID, input: input, reason: .alreadyShort)
            }
            return try orderDecision(decisionID: decisionID, input: input, action: .openShort, side: .sell, reduceOnly: false)
        case .targetFlat:
            if input.currentPositionQuantity > 0 {
                return try reduceOnlyCloseDecision(decisionID: decisionID, input: input, action: .reduceOnlyCloseLong, side: .sell)
            }
            if input.currentPositionQuantity < 0 {
                return try reduceOnlyCloseDecision(decisionID: decisionID, input: input, action: .reduceOnlyCloseShort, side: .buy)
            }
            return try noOrder(decisionID: decisionID, input: input, reason: .alreadyFlat)
        }
    }

    private static func reduceOnlyCloseDecision(
        decisionID: Identifier,
        input: ReleaseV020PerpetualExecutionAlgorithmInput,
        action: ReleaseV020PerpetualExecutionAlgorithmAction,
        side: ReleaseV020PerpetualExecutionAlgorithmSide
    ) throws -> ReleaseV020PerpetualExecutionAlgorithmDecision {
        guard let sourceOrderIntent = input.sourceOrderIntent,
              sourceOrderIntent.quantity.rawValue <= abs(input.currentPositionQuantity) else {
            return try blocked(decisionID: decisionID, input: input, blocker: .reduceOnlyCloseInvalid)
        }
        return try orderDecision(decisionID: decisionID, input: input, action: action, side: side, reduceOnly: true)
    }

    private static func orderDecision(
        decisionID: Identifier,
        input: ReleaseV020PerpetualExecutionAlgorithmInput,
        action: ReleaseV020PerpetualExecutionAlgorithmAction,
        side: ReleaseV020PerpetualExecutionAlgorithmSide,
        reduceOnly: Bool
    ) throws -> ReleaseV020PerpetualExecutionAlgorithmDecision {
        guard let riskDecision = input.perpetualRiskDecision, riskDecision.forwardsToCommandGateway else {
            return try blocked(decisionID: decisionID, input: input, blocker: .riskDecisionNotForwarded)
        }
        guard riskDecision.reduceOnlyClose == reduceOnly else {
            return try blocked(decisionID: decisionID, input: input, blocker: .reduceOnlyCloseInvalid)
        }
        guard let sourceOrderIntent = input.sourceOrderIntent,
              sourceOrderIntent.isPreRiskGateIntent,
              sourceOrderIntent.instrument.productType == .usdsPerpetual,
              sourceOrderIntent.instrument == riskDecision.instrument,
              sourceOrderIntent.targetExposure == input.targetExposure else {
            return try blocked(decisionID: decisionID, input: input, blocker: .sourceIntentMismatch)
        }
        guard riskDecision.instrument?.productType == .usdsPerpetual else {
            return try blocked(decisionID: decisionID, input: input, blocker: .nonPerpetualInstrument)
        }

        let orderIntent = try ReleaseV020PerpetualExecutionAlgorithmOrderIntent(
            orderIntentID: Identifier.constant("\(decisionID.rawValue)-order-intent"),
            sourceInputID: input.inputID,
            sourceRiskDecisionID: riskDecision.decisionID,
            sourceProductAwareIntentID: sourceOrderIntent.intentID,
            instrument: sourceOrderIntent.instrument,
            targetExposure: input.targetExposure,
            action: action,
            side: side,
            quantity: sourceOrderIntent.quantity,
            referencePrice: sourceOrderIntent.referencePrice,
            currentPositionQuantity: input.currentPositionQuantity,
            reduceOnly: reduceOnly,
            createdAt: input.evaluatedAt
        )
        return try ReleaseV020PerpetualExecutionAlgorithmDecision(
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
        input: ReleaseV020PerpetualExecutionAlgorithmInput,
        reason: ReleaseV020PerpetualExecutionNoOrderReason
    ) throws -> ReleaseV020PerpetualExecutionAlgorithmDecision {
        try ReleaseV020PerpetualExecutionAlgorithmDecision(
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
        input: ReleaseV020PerpetualExecutionAlgorithmInput,
        blocker: ReleaseV020PerpetualExecutionAlgorithmBlocker
    ) throws -> ReleaseV020PerpetualExecutionAlgorithmDecision {
        try ReleaseV020PerpetualExecutionAlgorithmDecision(
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
