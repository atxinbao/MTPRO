import DomainModel
import Foundation

/// ReleaseV0140PreTradeRiskOutcome 是 GH-1034 的 OrderIntent 前置风险结果。
///
/// `accepted` 只表示本地 RiskEngine gate 允许继续进入 ExecutionEngine / testnet
/// evidence 链路；它不授权 production trading，也不代表 adapter 已提交订单。
public enum ReleaseV0140PreTradeRiskOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accepted
    case rejected
    case blocked
}

/// ReleaseV0140PreTradeRiskRejectReason 记录 GH-1034 的 fail-closed gate 原因。
public enum ReleaseV0140PreTradeRiskRejectReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none
    case venueNotAllowed
    case productNotAllowed
    case strategyNotAllowed
    case modeGateFailed
    case quantityLimitExceeded
    case notionalLimitExceeded
    case noTradeStateActive
    case killSwitchActive
    case productionTradingRequested
}

/// ReleaseV0140PreTradeRiskPolicyProfile 固定 v0.14.0 testnet closed loop 的前置风险策略。
///
/// Profile 只能覆盖 Binance Spot / USDⓈ-M Perpetual 与 EMA / RSI。它可以用更窄的
/// product / strategy allowlist 做本地风险拒绝，但不能扩展到其他 venue、生产端点或真实订单。
public struct ReleaseV0140PreTradeRiskPolicyProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let releaseVenueID: Identifier
    public let allowedProductTypes: Set<ProductType>
    public let allowedStrategies: Set<OrderIntentStrategyKind>
    public let maxQuantity: Quantity
    public let maxSpotNotional: Double
    public let maxPerpetualNotional: Double
    public let noTradeStateActive: Bool
    public let killSwitchActive: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        profileID: Identifier = Identifier.constant(
            "gh-1034-v0140-pretrade-risk-profile",
            field: "releaseV0140PreTradeRisk.profileID"
        ),
        releaseVenueID: Identifier = OrderIntent.activeVenueID,
        allowedProductTypes: Set<ProductType> = OrderIntent.activeProductTypes,
        allowedStrategies: Set<OrderIntentStrategyKind> = OrderIntent.activeStrategies,
        maxQuantity: Quantity,
        maxSpotNotional: Double,
        maxPerpetualNotional: Double,
        noTradeStateActive: Bool = false,
        killSwitchActive: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        guard releaseVenueID == OrderIntent.activeVenueID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.nonBinanceVenue")
        }
        guard allowedProductTypes.isEmpty == false,
              allowedProductTypes.isSubset(of: OrderIntent.activeProductTypes) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.allowedProductTypes",
                expected: OrderIntent.activeProductTypes.map(\.rawValue).sorted().joined(separator: ","),
                actual: allowedProductTypes.map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard allowedStrategies.isEmpty == false,
              allowedStrategies.isSubset(of: OrderIntent.activeStrategies) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.allowedStrategies",
                expected: OrderIntent.activeStrategies.map(\.rawValue).sorted().joined(separator: ","),
                actual: allowedStrategies.map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard maxQuantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.maxQuantity",
                expected: "positive quantity",
                actual: "\(maxQuantity.rawValue)"
            )
        }
        guard maxSpotNotional.isFinite, maxSpotNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.maxSpotNotional",
                expected: "finite positive notional",
                actual: "\(maxSpotNotional)"
            )
        }
        guard maxPerpetualNotional.isFinite, maxPerpetualNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.maxPerpetualNotional",
                expected: "finite positive notional",
                actual: "\(maxPerpetualNotional)"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.profileID = profileID
        self.releaseVenueID = releaseVenueID
        self.allowedProductTypes = allowedProductTypes
        self.allowedStrategies = allowedStrategies
        self.maxQuantity = maxQuantity
        self.maxSpotNotional = maxSpotNotional
        self.maxPerpetualNotional = maxPerpetualNotional
        self.noTradeStateActive = noTradeStateActive
        self.killSwitchActive = killSwitchActive
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        releaseVenueID == OrderIntent.activeVenueID
            && allowedProductTypes.isEmpty == false
            && allowedProductTypes.isSubset(of: OrderIntent.activeProductTypes)
            && allowedStrategies.isEmpty == false
            && allowedStrategies.isSubset(of: OrderIntent.activeStrategies)
            && maxQuantity.rawValue > 0
            && maxSpotNotional.isFinite
            && maxSpotNotional > 0
            && maxPerpetualNotional.isFinite
            && maxPerpetualNotional > 0
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    public func maxNotional(for productType: ProductType) -> Double {
        switch productType {
        case .spot:
            maxSpotNotional
        case .usdsPerpetual:
            maxPerpetualNotional
        }
    }

    public static func deterministicFixture(
        allowedProductTypes: Set<ProductType> = OrderIntent.activeProductTypes,
        allowedStrategies: Set<OrderIntentStrategyKind> = OrderIntent.activeStrategies,
        noTradeStateActive: Bool = false,
        killSwitchActive: Bool = false
    ) throws -> ReleaseV0140PreTradeRiskPolicyProfile {
        try ReleaseV0140PreTradeRiskPolicyProfile(
            allowedProductTypes: allowedProductTypes,
            allowedStrategies: allowedStrategies,
            maxQuantity: Quantity(1, field: "releaseV0140PreTradeRisk.maxQuantity"),
            maxSpotNotional: 50_000,
            maxPerpetualNotional: 25_000,
            noTradeStateActive: noTradeStateActive,
            killSwitchActive: killSwitchActive
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.profile.\(field)")
        }
    }
}

/// ReleaseV0140PreTradeRiskDecision 是 GH-1034 的本地 risk decision evidence。
///
/// 非 accepted decision 必须保持 `adapterSubmitEligible == false`，用来证明 rejected /
/// blocked OrderIntent 永远不会进入 adapter submit。
public struct ReleaseV0140PreTradeRiskDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let profileID: Identifier
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int
    public let productType: ProductType
    public let strategy: OrderIntentStrategyKind
    public let outcome: ReleaseV0140PreTradeRiskOutcome
    public let rejectReasons: [ReleaseV0140PreTradeRiskRejectReason]
    public let referencePrice: Double
    public let notional: Double
    public let nextLifecycleState: OrderLifecycleState
    public let runsBeforeExecutionEngineSubmit: Bool
    public let forwardsToExecutionEngine: Bool
    public let adapterSubmitEligible: Bool
    public let rejectedIntentReachedAdapterSubmit: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        decisionID: Identifier,
        profileID: Identifier,
        intent: OrderIntent,
        outcome: ReleaseV0140PreTradeRiskOutcome,
        rejectReasons: [ReleaseV0140PreTradeRiskRejectReason],
        referencePrice: Double,
        notional: Double,
        nextLifecycleState: OrderLifecycleState,
        runsBeforeExecutionEngineSubmit: Bool = true,
        forwardsToExecutionEngine: Bool,
        adapterSubmitEligible: Bool,
        rejectedIntentReachedAdapterSubmit: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors
    ) throws {
        guard intent.isPreRiskEngineIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.intent",
                expected: "pre-RiskEngine OrderIntent",
                actual: "boundary mismatch"
            )
        }
        guard referencePrice.isFinite, referencePrice > 0, notional.isFinite, notional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.notional",
                expected: "finite positive reference price and notional",
                actual: "\(referencePrice):\(notional)"
            )
        }
        guard runsBeforeExecutionEngineSubmit else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.executionSubmitBeforeRisk")
        }
        guard rejectedIntentReachedAdapterSubmit == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.rejectedIntentReachedAdapterSubmit")
        }
        guard validationAnchors == ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.validationAnchors",
                expected: ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        switch outcome {
        case .accepted:
            guard rejectReasons == [.none],
                  forwardsToExecutionEngine,
                  adapterSubmitEligible,
                  nextLifecycleState == .riskAccepted else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140PreTradeRisk.acceptedDecision",
                    expected: "accepted forwards to riskAccepted ExecutionEngine handoff",
                    actual: "\(rejectReasons.map(\.rawValue)):\(forwardsToExecutionEngine):\(adapterSubmitEligible):\(nextLifecycleState.rawValue)"
                )
            }
        case .rejected:
            guard rejectReasons.contains(.none) == false,
                  forwardsToExecutionEngine == false,
                  adapterSubmitEligible == false,
                  nextLifecycleState == .riskRejected else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140PreTradeRisk.rejectedDecision",
                    expected: "rejected does not reach adapter submit",
                    actual: "\(rejectReasons.map(\.rawValue)):\(forwardsToExecutionEngine):\(adapterSubmitEligible):\(nextLifecycleState.rawValue)"
                )
            }
        case .blocked:
            guard rejectReasons.contains(.none) == false,
                  forwardsToExecutionEngine == false,
                  adapterSubmitEligible == false,
                  nextLifecycleState == .failedClosed else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140PreTradeRisk.blockedDecision",
                    expected: "blocked fails closed before ExecutionEngine submit",
                    actual: "\(rejectReasons.map(\.rawValue)):\(forwardsToExecutionEngine):\(adapterSubmitEligible):\(nextLifecycleState.rawValue)"
                )
            }
        }
        guard decisionID == Self.deterministicID(
            profileID: profileID,
            intentID: intent.intentID,
            outcome: outcome,
            rejectReasons: rejectReasons
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.decisionID",
                expected: Self.deterministicID(
                    profileID: profileID,
                    intentID: intent.intentID,
                    outcome: outcome,
                    rejectReasons: rejectReasons
                ).rawValue,
                actual: decisionID.rawValue
            )
        }

        self.decisionID = decisionID
        self.profileID = profileID
        self.intentID = intent.intentID
        self.strategyRunID = intent.correlation.strategyRunID
        self.sourceSequence = intent.correlation.sourceSequence
        self.productType = intent.instrument.productType
        self.strategy = intent.strategy
        self.outcome = outcome
        self.rejectReasons = rejectReasons
        self.referencePrice = referencePrice
        self.notional = notional
        self.nextLifecycleState = nextLifecycleState
        self.runsBeforeExecutionEngineSubmit = runsBeforeExecutionEngineSubmit
        self.forwardsToExecutionEngine = forwardsToExecutionEngine
        self.adapterSubmitEligible = adapterSubmitEligible
        self.rejectedIntentReachedAdapterSubmit = rejectedIntentReachedAdapterSubmit
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        runsBeforeExecutionEngineSubmit
            && rejectedIntentReachedAdapterSubmit == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && validationAnchors == ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors
            && (
                (outcome == .accepted
                    && rejectReasons == [.none]
                    && forwardsToExecutionEngine
                    && adapterSubmitEligible
                    && nextLifecycleState == .riskAccepted)
                || (outcome == .rejected
                    && rejectReasons.contains(.none) == false
                    && forwardsToExecutionEngine == false
                    && adapterSubmitEligible == false
                    && nextLifecycleState == .riskRejected)
                || (outcome == .blocked
                    && rejectReasons.contains(.none) == false
                    && forwardsToExecutionEngine == false
                    && adapterSubmitEligible == false
                    && nextLifecycleState == .failedClosed)
            )
    }

    public static func deterministicID(
        profileID: Identifier,
        intentID: Identifier,
        outcome: ReleaseV0140PreTradeRiskOutcome,
        rejectReasons: [ReleaseV0140PreTradeRiskRejectReason]
    ) -> Identifier {
        .constant(
            [
                "gh-1034-v0140-pretrade-risk-decision",
                profileID.rawValue,
                intentID.rawValue,
                outcome.rawValue,
                rejectReasons.map(\.rawValue).joined(separator: "+")
            ].joined(separator: ":"),
            field: "releaseV0140PreTradeRisk.decisionID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.decision.\(field)")
        }
    }
}

/// ReleaseV0140PreTradeRiskGateEvidence 汇总 GH-1034 的 accepted / rejected / blocked evidence。
public struct ReleaseV0140PreTradeRiskGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let profileID: Identifier
    public let decisions: [ReleaseV0140PreTradeRiskDecision]
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        evidenceID: Identifier,
        profileID: Identifier,
        decisions: [ReleaseV0140PreTradeRiskDecision],
        validationAnchors: [String] = ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        guard decisions.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.decisions",
                expected: "non-empty decision evidence",
                actual: "empty"
            )
        }
        guard decisions.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.decisions",
                expected: "all decisions boundary held",
                actual: "boundary drift"
            )
        }
        guard Set(decisions.map(\.outcome)).isSuperset(of: [.accepted, .rejected, .blocked]) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.outcomes",
                expected: "accepted,rejected,blocked",
                actual: decisions.map(\.outcome.rawValue).joined(separator: ",")
            )
        }
        guard decisions.filter({ $0.outcome != .accepted }).allSatisfy({ $0.adapterSubmitEligible == false }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.rejectedDecisionAdapterSubmit")
        }
        guard validationAnchors == ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.evidence.validationAnchors",
                expected: ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.evidenceID = evidenceID
        self.profileID = profileID
        self.decisions = decisions
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        decisions.isEmpty == false
            && decisions.allSatisfy(\.boundaryHeld)
            && Set(decisions.map(\.outcome)).isSuperset(of: [.accepted, .rejected, .blocked])
            && decisions.filter { $0.outcome != .accepted }.allSatisfy { $0.adapterSubmitEligible == false }
            && validationAnchors == ReleaseV0140PreTradeRiskEngineGate.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.evidence.\(field)")
        }
    }
}

/// ReleaseV0140PreTradeRiskEngineGate 是 GH-1034 的 OrderIntent 前置 RiskEngine gate。
///
/// Gate 必须在 ExecutionEngine submit / Binance testnet adapter 之前运行。accepted decision
/// 才能继续进入后续本地 handoff；rejected / blocked decision 必须 fail closed，且不能产生
/// adapter submit eligibility。
public struct ReleaseV0140PreTradeRiskEngineGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let policyProfile: ReleaseV0140PreTradeRiskPolicyProfile
    public let explicitTestnetMode: Bool
    public let runsBeforeExecutionEngineSubmit: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        gateID: Identifier = Identifier.constant(
            "gh-1034-v0140-pretrade-risk-engine-gate",
            field: "releaseV0140PreTradeRisk.gateID"
        ),
        policyProfile: ReleaseV0140PreTradeRiskPolicyProfile,
        explicitTestnetMode: Bool = true,
        runsBeforeExecutionEngineSubmit: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard policyProfile.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.policyProfile",
                expected: "boundary-held policy profile",
                actual: "boundary drift"
            )
        }
        guard explicitTestnetMode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.explicitTestnetMode",
                expected: "true",
                actual: "false"
            )
        }
        guard runsBeforeExecutionEngineSubmit else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.executionSubmitBeforeGate")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.gateID = gateID
        self.policyProfile = policyProfile
        self.explicitTestnetMode = explicitTestnetMode
        self.runsBeforeExecutionEngineSubmit = runsBeforeExecutionEngineSubmit
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        policyProfile.boundaryHeld
            && explicitTestnetMode
            && runsBeforeExecutionEngineSubmit
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public func evaluate(
        intent: OrderIntent,
        referencePrice: Double,
        explicitTestnetMode: Bool = true,
        noTradeStateActive: Bool = false,
        killSwitchActive: Bool = false,
        executionSubmitAlreadyAttempted: Bool = false,
        productionTradingRequested: Bool = false
    ) throws -> ReleaseV0140PreTradeRiskDecision {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.gate",
                expected: "boundary-held gate",
                actual: "boundary drift"
            )
        }
        guard intent.isPreRiskEngineIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.intent",
                expected: "pre-RiskEngine OrderIntent",
                actual: "boundary mismatch"
            )
        }
        guard executionSubmitAlreadyAttempted == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.executionSubmitAlreadyAttempted")
        }
        guard referencePrice.isFinite, referencePrice > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140PreTradeRisk.referencePrice",
                expected: "finite positive reference price",
                actual: "\(referencePrice)"
            )
        }

        let notional = intent.quantity.rawValue * referencePrice
        let outcomeAndReasons = Self.outcomeAndReasons(
            intent: intent,
            referencePrice: referencePrice,
            notional: notional,
            profile: policyProfile,
            explicitTestnetMode: explicitTestnetMode,
            noTradeStateActive: noTradeStateActive,
            killSwitchActive: killSwitchActive,
            productionTradingRequested: productionTradingRequested
        )
        let nextLifecycleState: OrderLifecycleState
        let forwardsToExecutionEngine: Bool
        let adapterSubmitEligible: Bool
        switch outcomeAndReasons.outcome {
        case .accepted:
            nextLifecycleState = .riskAccepted
            forwardsToExecutionEngine = true
            adapterSubmitEligible = true
        case .rejected:
            nextLifecycleState = .riskRejected
            forwardsToExecutionEngine = false
            adapterSubmitEligible = false
        case .blocked:
            nextLifecycleState = .failedClosed
            forwardsToExecutionEngine = false
            adapterSubmitEligible = false
        }

        return try ReleaseV0140PreTradeRiskDecision(
            decisionID: ReleaseV0140PreTradeRiskDecision.deterministicID(
                profileID: policyProfile.profileID,
                intentID: intent.intentID,
                outcome: outcomeAndReasons.outcome,
                rejectReasons: outcomeAndReasons.reasons
            ),
            profileID: policyProfile.profileID,
            intent: intent,
            outcome: outcomeAndReasons.outcome,
            rejectReasons: outcomeAndReasons.reasons,
            referencePrice: referencePrice,
            notional: notional,
            nextLifecycleState: nextLifecycleState,
            forwardsToExecutionEngine: forwardsToExecutionEngine,
            adapterSubmitEligible: adapterSubmitEligible,
            validationAnchors: validationAnchors
        )
    }

    public func deterministicEvidence(
        acceptedIntent: OrderIntent,
        referencePrice: Double
    ) throws -> ReleaseV0140PreTradeRiskGateEvidence {
        let accepted = try evaluate(intent: acceptedIntent, referencePrice: referencePrice)
        let rejectedReferencePrice =
            policyProfile.maxNotional(for: acceptedIntent.instrument.productType) / acceptedIntent.quantity.rawValue + 1
        let rejected = try evaluate(
            intent: acceptedIntent,
            referencePrice: rejectedReferencePrice
        )
        let blocked = try evaluate(
            intent: acceptedIntent,
            referencePrice: referencePrice,
            noTradeStateActive: true
        )

        return try ReleaseV0140PreTradeRiskGateEvidence(
            evidenceID: Identifier.constant(
                "gh-1034-v0140-pretrade-risk-evidence:\(acceptedIntent.intentID.rawValue)",
                field: "releaseV0140PreTradeRisk.evidenceID"
            ),
            profileID: policyProfile.profileID,
            decisions: [accepted, rejected, blocked],
            validationAnchors: validationAnchors
        )
    }

    public static func deterministicFixture() throws -> ReleaseV0140PreTradeRiskEngineGate {
        try ReleaseV0140PreTradeRiskEngineGate(
            policyProfile: .deterministicFixture()
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1034-PRETRADE-RISKENGINE-GATE",
        "GH-1034-REJECTED-INTENT-NO-ADAPTER-SUBMIT",
        "GH-1034-KILL-SWITCH-NO-TRADE-MODE-GATES",
        "TVM-RELEASE-V0140-PRETRADE-RISK-GATE"
    ]

    private static func outcomeAndReasons(
        intent: OrderIntent,
        referencePrice: Double,
        notional: Double,
        profile: ReleaseV0140PreTradeRiskPolicyProfile,
        explicitTestnetMode: Bool,
        noTradeStateActive: Bool,
        killSwitchActive: Bool,
        productionTradingRequested: Bool
    ) -> (outcome: ReleaseV0140PreTradeRiskOutcome, reasons: [ReleaseV0140PreTradeRiskRejectReason]) {
        if productionTradingRequested {
            return (.blocked, [.productionTradingRequested])
        }
        if explicitTestnetMode == false {
            return (.blocked, [.modeGateFailed])
        }
        if killSwitchActive || profile.killSwitchActive {
            return (.blocked, [.killSwitchActive])
        }
        if noTradeStateActive || profile.noTradeStateActive {
            return (.blocked, [.noTradeStateActive])
        }
        if intent.instrument.venue != profile.releaseVenueID {
            return (.rejected, [.venueNotAllowed])
        }
        if profile.allowedProductTypes.contains(intent.instrument.productType) == false {
            return (.rejected, [.productNotAllowed])
        }
        if profile.allowedStrategies.contains(intent.strategy) == false {
            return (.rejected, [.strategyNotAllowed])
        }
        if intent.quantity.rawValue > profile.maxQuantity.rawValue {
            return (.rejected, [.quantityLimitExceeded])
        }
        if notional > profile.maxNotional(for: intent.instrument.productType) {
            return (.rejected, [.notionalLimitExceeded])
        }
        return (.accepted, [.none])
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140PreTradeRisk.gate.\(field)")
        }
    }
}
