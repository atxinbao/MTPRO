import DomainModel
import Foundation

// GH-1070 static contract boundary:
// nativeCancelReplaceSupported=false
// nativeReplaceRejectedFailClosed=true
// cancelThenNewSubmitEmulationUsed=true
// testnetNetworkCancelPerformed=true
// testnetNetworkSubmitPerformed=true
// appendOnlyCancelReplaceEvidenceCreated=true
// omsStateTransitionIntegrated=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate records explicit approval for cancel+new submit emulation.
///
/// Binance Spot Testnet native cancel-replace is deliberately not enabled in the v0.15.0 MVP. This gate
/// proves the operator approved the safer emulation path: cancel the existing Spot Testnet order and submit
/// a new Spot Testnet replacement intent. The gate does not authorize production trading or any production
/// endpoint.
public struct ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let operatorConfirmationID: Identifier
    public let strategyRunID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let sourceIntentID: Identifier
    public let replacementIntentID: Identifier
    public let replaceMappingID: Identifier
    public let credentialReferenceID: Identifier
    public let explicitTestnetMode: Bool
    public let operatorConfirmedTestnetCancelReplace: Bool
    public let acknowledgesNoProductionTrading: Bool
    public let nativeCancelReplaceSupported: Bool
    public let nativeReplaceRejectedFailClosed: Bool
    public let cancelThenNewSubmitEmulationAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        gateID: Identifier,
        operatorConfirmationID: Identifier,
        strategyRunID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier,
        sourceIntentID: Identifier,
        replacementIntentID: Identifier,
        replaceMappingID: Identifier,
        credentialReferenceID: Identifier,
        explicitTestnetMode: Bool = true,
        operatorConfirmedTestnetCancelReplace: Bool = true,
        acknowledgesNoProductionTrading: Bool = true,
        nativeCancelReplaceSupported: Bool = false,
        nativeReplaceRejectedFailClosed: Bool = true,
        cancelThenNewSubmitEmulationAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard gateID == Self.deterministicID(
            strategyRunID: strategyRunID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            sourceIntentID: sourceIntentID,
            replacementIntentID: replacementIntentID,
            replaceMappingID: replaceMappingID,
            operatorConfirmationID: operatorConfirmationID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.operatorGate.gateID",
                expected: Self.deterministicID(
                    strategyRunID: strategyRunID,
                    sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
                    sourceIntentID: sourceIntentID,
                    replacementIntentID: replacementIntentID,
                    replaceMappingID: replaceMappingID,
                    operatorConfirmationID: operatorConfirmationID
                ).rawValue,
                actual: gateID.rawValue
            )
        }
        guard explicitTestnetMode,
              operatorConfirmedTestnetCancelReplace,
              acknowledgesNoProductionTrading,
              nativeCancelReplaceSupported == false,
              nativeReplaceRejectedFailClosed,
              cancelThenNewSubmitEmulationAllowed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.operatorGate.unconfirmedOrNativeReplace")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.gateID = gateID
        self.operatorConfirmationID = operatorConfirmationID
        self.strategyRunID = strategyRunID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitRuntimeEvidenceID
        self.sourceIntentID = sourceIntentID
        self.replacementIntentID = replacementIntentID
        self.replaceMappingID = replaceMappingID
        self.credentialReferenceID = credentialReferenceID
        self.explicitTestnetMode = explicitTestnetMode
        self.operatorConfirmedTestnetCancelReplace = operatorConfirmedTestnetCancelReplace
        self.acknowledgesNoProductionTrading = acknowledgesNoProductionTrading
        self.nativeCancelReplaceSupported = nativeCancelReplaceSupported
        self.nativeReplaceRejectedFailClosed = nativeReplaceRejectedFailClosed
        self.cancelThenNewSubmitEmulationAllowed = cancelThenNewSubmitEmulationAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && operatorConfirmedTestnetCancelReplace
            && acknowledgesNoProductionTrading
            && nativeCancelReplaceSupported == false
            && nativeReplaceRejectedFailClosed
            && cancelThenNewSubmitEmulationAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        strategyRunID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier,
        sourceIntentID: Identifier,
        replacementIntentID: Identifier,
        replaceMappingID: Identifier,
        operatorConfirmationID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1070-spot-testnet-cancel-replace-gate",
                strategyRunID.rawValue,
                sourceSubmitRuntimeEvidenceID.rawValue,
                sourceIntentID.rawValue,
                replacementIntentID.rawValue,
                replaceMappingID.rawValue,
                operatorConfirmationID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0150SpotTestnetCancelReplace.operatorGate.gateID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.operatorGate.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence captures the local replace transition.
///
/// The network side is intentionally implemented as cancel + new submit emulation, but the local OMS evidence
/// still records the user-visible replace lifecycle: accepted or partially filled order moves to
/// replaceRequested and then replaced. It records no broker fill or reconciliation runtime.
public struct ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence: Codable, Equatable, Sendable {
    public let transitionEvidenceID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let cancelRuntimeEvidenceID: Identifier
    public let replacementSubmitRuntimeEvidenceID: Identifier
    public let replaceMappingID: Identifier
    public let sourceIntentID: Identifier
    public let replacementIntentID: Identifier
    public let localOrderID: Identifier
    public let fromLifecycleState: OrderLifecycleState
    public let requestLifecycleState: OrderLifecycleState
    public let finalLifecycleState: OrderLifecycleState
    public let requestTransition: OrderLifecycleTransition
    public let finalTransition: OrderLifecycleTransition
    public let stateMachineValidated: Bool
    public let appendOnlyOMSStateTransitionEvidence: Bool
    public let cancelThenNewSubmitEmulationUsed: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case transitionEvidenceID
        case sourceSubmitRuntimeEvidenceID
        case cancelRuntimeEvidenceID
        case replacementSubmitRuntimeEvidenceID
        case replaceMappingID
        case sourceIntentID
        case replacementIntentID
        case localOrderID
        case fromLifecycleState
        case requestLifecycleState
        case finalLifecycleState
        case requestTransition
        case finalTransition
        case stateMachineValidated
        case appendOnlyOMSStateTransitionEvidence
        case cancelThenNewSubmitEmulationUsed
        case brokerFillIncluded
        case reconciliationIncluded
        case productionTradingEnabledByDefault
        case productionSecretAutoRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }

    public init(
        transitionEvidenceID: Identifier,
        sourceIntent: OrderIntent,
        replacementIntent: OrderIntent,
        replaceMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        cancelEvidence: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence,
        replacementSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        stateMachineValidated: Bool = true,
        appendOnlyOMSStateTransitionEvidence: Bool = true,
        cancelThenNewSubmitEmulationUsed: Bool = true,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard sourceIntent.intentID == sourceSubmitEvidence.intentID,
              replacementIntent.intentID == replacementSubmitEvidence.intentID,
              sourceIntent.instrument == replacementIntent.instrument,
              sourceIntent.instrument.productType == .spot,
              replaceMapping.boundaryHeld,
              replaceMapping.intentID == sourceIntent.intentID,
              replaceMapping.operation == .replace,
              replaceMapping.mode == .binanceTestnet,
              replaceMapping.targetLifecycleState == .replaceRequested else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.omsTransition.mapping",
                expected: "Binance Spot Testnet replace mapping for source intent and replacement intent",
                actual: "\(replaceMapping.operation.rawValue):\(replaceMapping.lifecycleState.rawValue)"
            )
        }
        guard sourceSubmitEvidence.boundaryHeld,
              cancelEvidence.boundaryHeld,
              replacementSubmitEvidence.boundaryHeld,
              cancelEvidence.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              replacementSubmitEvidence.productType == .spot,
              replacementSubmitEvidence.credentialReferenceID == sourceSubmitEvidence.credentialReferenceID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.omsTransition.unlinkedEvidence")
        }
        guard OrderLifecycleStateMachine.canTransition(from: replaceMapping.lifecycleState, to: .replaceRequested),
              OrderLifecycleStateMachine.canTransition(from: .replaceRequested, to: .replaced) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.omsTransition.stateMachine",
                expected: "valid replace request and replaced transitions",
                actual: "\(replaceMapping.lifecycleState.rawValue)->replaceRequested->replaced"
            )
        }
        let requestTransition = try OrderLifecycleTransition(
            from: replaceMapping.lifecycleState,
            to: .replaceRequested,
            reason: "GH-1070 Spot Testnet cancel-replace emulation requested locally"
        )
        let finalTransition = try OrderLifecycleTransition(
            from: .replaceRequested,
            to: .replaced,
            reason: "GH-1070 Spot Testnet cancel completed and replacement submit accepted"
        )
        let localOrderID = Self.localOrderID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID
        )
        guard transitionEvidenceID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
            replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
            replaceMappingID: replaceMapping.mappingID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.omsTransition.transitionEvidenceID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                    cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
                    replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
                    replaceMappingID: replaceMapping.mappingID
                ).rawValue,
                actual: transitionEvidenceID.rawValue
            )
        }
        guard stateMachineValidated,
              appendOnlyOMSStateTransitionEvidence,
              cancelThenNewSubmitEmulationUsed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.omsTransition.unheldLocalState")
        }
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.transitionEvidenceID = transitionEvidenceID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.cancelRuntimeEvidenceID = cancelEvidence.runtimeEvidenceID
        self.replacementSubmitRuntimeEvidenceID = replacementSubmitEvidence.runtimeEvidenceID
        self.replaceMappingID = replaceMapping.mappingID
        self.sourceIntentID = sourceIntent.intentID
        self.replacementIntentID = replacementIntent.intentID
        self.localOrderID = localOrderID
        self.fromLifecycleState = replaceMapping.lifecycleState
        self.requestLifecycleState = .replaceRequested
        self.finalLifecycleState = .replaced
        self.requestTransition = requestTransition
        self.finalTransition = finalTransition
        self.stateMachineValidated = stateMachineValidated
        self.appendOnlyOMSStateTransitionEvidence = appendOnlyOMSStateTransitionEvidence
        self.cancelThenNewSubmitEmulationUsed = cancelThenNewSubmitEmulationUsed
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transitionEvidenceID = try container.decode(Identifier.self, forKey: .transitionEvidenceID)
        self.sourceSubmitRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .sourceSubmitRuntimeEvidenceID)
        self.cancelRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .cancelRuntimeEvidenceID)
        self.replacementSubmitRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .replacementSubmitRuntimeEvidenceID)
        self.replaceMappingID = try container.decode(Identifier.self, forKey: .replaceMappingID)
        self.sourceIntentID = try container.decode(Identifier.self, forKey: .sourceIntentID)
        self.replacementIntentID = try container.decode(Identifier.self, forKey: .replacementIntentID)
        self.localOrderID = try container.decode(Identifier.self, forKey: .localOrderID)
        self.fromLifecycleState = try container.decode(OrderLifecycleState.self, forKey: .fromLifecycleState)
        self.requestLifecycleState = try container.decode(OrderLifecycleState.self, forKey: .requestLifecycleState)
        self.finalLifecycleState = try container.decode(OrderLifecycleState.self, forKey: .finalLifecycleState)
        self.requestTransition = try container.decode(OrderLifecycleTransition.self, forKey: .requestTransition)
        self.finalTransition = try container.decode(OrderLifecycleTransition.self, forKey: .finalTransition)
        self.stateMachineValidated = try container.decode(Bool.self, forKey: .stateMachineValidated)
        self.appendOnlyOMSStateTransitionEvidence = try container.decode(Bool.self, forKey: .appendOnlyOMSStateTransitionEvidence)
        self.cancelThenNewSubmitEmulationUsed = try container.decode(Bool.self, forKey: .cancelThenNewSubmitEmulationUsed)
        self.brokerFillIncluded = try container.decode(Bool.self, forKey: .brokerFillIncluded)
        self.reconciliationIncluded = try container.decode(Bool.self, forKey: .reconciliationIncluded)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretAutoRead = try container.decode(Bool.self, forKey: .productionSecretAutoRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)

        let expectedTransitionID = Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            cancelRuntimeEvidenceID: cancelRuntimeEvidenceID,
            replacementSubmitRuntimeEvidenceID: replacementSubmitRuntimeEvidenceID,
            replaceMappingID: replaceMappingID
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            transitionEvidenceID == expectedTransitionID,
            field: "releaseV0150SpotTestnetCancelReplace.omsTransition.transitionEvidenceID",
            expected: expectedTransitionID.rawValue,
            actual: transitionEvidenceID.rawValue
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SpotTestnetCancelReplace.omsTransition.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        (fromLifecycleState == .accepted || fromLifecycleState == .partiallyFilled || fromLifecycleState == .replaced)
            && requestLifecycleState == .replaceRequested
            && finalLifecycleState == .replaced
            && requestTransition.boundaryHeld
            && finalTransition.boundaryHeld
            && stateMachineValidated
            && appendOnlyOMSStateTransitionEvidence
            && cancelThenNewSubmitEmulationUsed
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func localOrderID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        replacementSubmitRuntimeEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1070-spot-testnet-cancel-replace-local-order:\(sourceSubmitRuntimeEvidenceID.rawValue):\(replacementSubmitRuntimeEvidenceID.rawValue)",
            field: "releaseV0150SpotTestnetCancelReplace.omsTransition.localOrderID"
        )
    }

    public static func deterministicID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        cancelRuntimeEvidenceID: Identifier,
        replacementSubmitRuntimeEvidenceID: Identifier,
        replaceMappingID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1070-spot-testnet-cancel-replace-oms-transition",
                sourceSubmitRuntimeEvidenceID.rawValue,
                cancelRuntimeEvidenceID.rawValue,
                replacementSubmitRuntimeEvidenceID.rawValue,
                replaceMappingID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0150SpotTestnetCancelReplace.omsTransition.transitionEvidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.omsTransition.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence links cancel, replacement submit and OMS evidence.
///
/// The evidence represents the complete #1070 action. It proves native replace remained unsupported and
/// fail-closed, while the replacement was completed through a deterministic Spot Testnet cancel+submit
/// emulation path with append-only event evidence.
public struct ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence: Codable, Equatable, Sendable {
    public let runtimeEvidenceID: Identifier
    public let intentID: Identifier
    public let replacementIntentID: Identifier
    public let replaceMappingID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let cancelRuntimeEvidenceID: Identifier
    public let replacementSubmitRuntimeEvidenceID: Identifier
    public let signedReplacementRequestID: Identifier
    public let operatorGateID: Identifier
    public let transportResultID: Identifier
    public let omsTransitionEvidenceID: Identifier
    public let credentialReferenceID: Identifier
    public let productType: ProductType
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let orderLifecycleState: OrderLifecycleState
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let operatorConfirmedTestnetCancelReplace: Bool
    public let nativeCancelReplaceSupported: Bool
    public let nativeReplaceRejectedFailClosed: Bool
    public let cancelThenNewSubmitEmulationUsed: Bool
    public let requestBodyRedacted: Bool
    public let responseBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let orderIdentityMaterialRedacted: Bool
    public let appendOnlyCancelReplaceEvidenceCreated: Bool
    public let omsStateTransitionIntegrated: Bool
    public let testnetNetworkCancelPerformed: Bool
    public let testnetNetworkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    private enum CodingKeys: String, CodingKey {
        case runtimeEvidenceID
        case intentID
        case replacementIntentID
        case replaceMappingID
        case sourceSubmitRuntimeEvidenceID
        case cancelRuntimeEvidenceID
        case replacementSubmitRuntimeEvidenceID
        case signedReplacementRequestID
        case operatorGateID
        case transportResultID
        case omsTransitionEvidenceID
        case credentialReferenceID
        case productType
        case endpointHost
        case endpointPath
        case httpStatusCode
        case orderLifecycleState
        case explicitTestnetMode
        case spotTestnetOnly
        case operatorConfirmedTestnetCancelReplace
        case nativeCancelReplaceSupported
        case nativeReplaceRejectedFailClosed
        case cancelThenNewSubmitEmulationUsed
        case requestBodyRedacted
        case responseBodyRedacted
        case credentialMaterialRedacted
        case orderIdentityMaterialRedacted
        case appendOnlyCancelReplaceEvidenceCreated
        case omsStateTransitionIntegrated
        case testnetNetworkCancelPerformed
        case testnetNetworkSubmitPerformed
        case productionTradingEnabledByDefault
        case productionSecretAutoRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case validationAnchors
    }

    public init(
        runtimeEvidenceID: Identifier,
        sourceIntent: OrderIntent,
        replacementIntent: OrderIntent,
        replaceMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        cancelEvidence: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence,
        replacementSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        operatorGate: ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate,
        omsTransition: ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence,
        orderLifecycleState: OrderLifecycleState = .replaced,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        requestBodyRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        orderIdentityMaterialRedacted: Bool = true,
        appendOnlyCancelReplaceEvidenceCreated: Bool = true,
        omsStateTransitionIntegrated: Bool = true,
        testnetNetworkCancelPerformed: Bool = true,
        testnetNetworkSubmitPerformed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceIntent.isPreRiskEngineIntent,
              replacementIntent.isPreRiskEngineIntent,
              sourceIntent.instrument == replacementIntent.instrument,
              sourceIntent.instrument.productType == .spot,
              replaceMapping.boundaryHeld,
              replaceMapping.intentID == sourceIntent.intentID,
              replaceMapping.operation == .replace,
              replaceMapping.mode == .binanceTestnet,
              replaceMapping.targetLifecycleState == .replaceRequested else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.intentMapping")
        }
        guard sourceSubmitEvidence.boundaryHeld,
              cancelEvidence.boundaryHeld,
              replacementSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.intentID == sourceIntent.intentID,
              cancelEvidence.intentID == sourceIntent.intentID,
              cancelEvidence.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              replacementSubmitEvidence.intentID == replacementIntent.intentID,
              replacementSubmitEvidence.credentialReferenceID == sourceSubmitEvidence.credentialReferenceID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.unlinkedRuntimeEvidence")
        }
        guard operatorGate.boundaryHeld,
              operatorGate.strategyRunID == sourceIntent.correlation.strategyRunID,
              operatorGate.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              operatorGate.sourceIntentID == sourceIntent.intentID,
              operatorGate.replacementIntentID == replacementIntent.intentID,
              operatorGate.replaceMappingID == replaceMapping.mappingID,
              operatorGate.credentialReferenceID == sourceSubmitEvidence.credentialReferenceID,
              omsTransition.boundaryHeld,
              omsTransition.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              omsTransition.cancelRuntimeEvidenceID == cancelEvidence.runtimeEvidenceID,
              omsTransition.replacementSubmitRuntimeEvidenceID == replacementSubmitEvidence.runtimeEvidenceID,
              omsTransition.replaceMappingID == replaceMapping.mappingID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.unlinkedGateOrOMS")
        }
        guard orderLifecycleState == .replaced,
              explicitTestnetMode,
              spotTestnetOnly,
              operatorGate.operatorConfirmedTestnetCancelReplace,
              operatorGate.nativeCancelReplaceSupported == false,
              operatorGate.nativeReplaceRejectedFailClosed,
              operatorGate.cancelThenNewSubmitEmulationAllowed,
              requestBodyRedacted,
              responseBodyRedacted,
              credentialMaterialRedacted,
              orderIdentityMaterialRedacted,
              appendOnlyCancelReplaceEvidenceCreated,
              omsStateTransitionIntegrated,
              testnetNetworkCancelPerformed,
              testnetNetworkSubmitPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.unheldRuntimeEvidence")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard runtimeEvidenceID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
            replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
            omsTransitionEvidenceID: omsTransition.transitionEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.runtimeEvidenceID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                    cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
                    replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
                    omsTransitionEvidenceID: omsTransition.transitionEvidenceID
                ).rawValue,
                actual: runtimeEvidenceID.rawValue
            )
        }

        self.runtimeEvidenceID = runtimeEvidenceID
        self.intentID = sourceIntent.intentID
        self.replacementIntentID = replacementIntent.intentID
        self.replaceMappingID = replaceMapping.mappingID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.cancelRuntimeEvidenceID = cancelEvidence.runtimeEvidenceID
        self.replacementSubmitRuntimeEvidenceID = replacementSubmitEvidence.runtimeEvidenceID
        self.signedReplacementRequestID = replacementSubmitEvidence.signedRequestID
        self.operatorGateID = operatorGate.gateID
        self.transportResultID = replacementSubmitEvidence.transportResultID
        self.omsTransitionEvidenceID = omsTransition.transitionEvidenceID
        self.credentialReferenceID = sourceSubmitEvidence.credentialReferenceID
        self.productType = .spot
        self.endpointHost = replacementSubmitEvidence.endpointHost
        self.endpointPath = replacementSubmitEvidence.endpointPath
        self.httpStatusCode = replacementSubmitEvidence.httpStatusCode
        self.orderLifecycleState = orderLifecycleState
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.operatorConfirmedTestnetCancelReplace = operatorGate.operatorConfirmedTestnetCancelReplace
        self.nativeCancelReplaceSupported = operatorGate.nativeCancelReplaceSupported
        self.nativeReplaceRejectedFailClosed = operatorGate.nativeReplaceRejectedFailClosed
        self.cancelThenNewSubmitEmulationUsed = operatorGate.cancelThenNewSubmitEmulationAllowed
        self.requestBodyRedacted = requestBodyRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.orderIdentityMaterialRedacted = orderIdentityMaterialRedacted
        self.appendOnlyCancelReplaceEvidenceCreated = appendOnlyCancelReplaceEvidenceCreated
        self.omsStateTransitionIntegrated = omsStateTransitionIntegrated
        self.testnetNetworkCancelPerformed = testnetNetworkCancelPerformed
        self.testnetNetworkSubmitPerformed = testnetNetworkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.runtimeEvidenceID = try container.decode(Identifier.self, forKey: .runtimeEvidenceID)
        self.intentID = try container.decode(Identifier.self, forKey: .intentID)
        self.replacementIntentID = try container.decode(Identifier.self, forKey: .replacementIntentID)
        self.replaceMappingID = try container.decode(Identifier.self, forKey: .replaceMappingID)
        self.sourceSubmitRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .sourceSubmitRuntimeEvidenceID)
        self.cancelRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .cancelRuntimeEvidenceID)
        self.replacementSubmitRuntimeEvidenceID = try container.decode(Identifier.self, forKey: .replacementSubmitRuntimeEvidenceID)
        self.signedReplacementRequestID = try container.decode(Identifier.self, forKey: .signedReplacementRequestID)
        self.operatorGateID = try container.decode(Identifier.self, forKey: .operatorGateID)
        self.transportResultID = try container.decode(Identifier.self, forKey: .transportResultID)
        self.omsTransitionEvidenceID = try container.decode(Identifier.self, forKey: .omsTransitionEvidenceID)
        self.credentialReferenceID = try container.decode(Identifier.self, forKey: .credentialReferenceID)
        self.productType = try container.decode(ProductType.self, forKey: .productType)
        self.endpointHost = try container.decode(String.self, forKey: .endpointHost)
        self.endpointPath = try container.decode(String.self, forKey: .endpointPath)
        self.httpStatusCode = try container.decode(Int.self, forKey: .httpStatusCode)
        self.orderLifecycleState = try container.decode(OrderLifecycleState.self, forKey: .orderLifecycleState)
        self.explicitTestnetMode = try container.decode(Bool.self, forKey: .explicitTestnetMode)
        self.spotTestnetOnly = try container.decode(Bool.self, forKey: .spotTestnetOnly)
        self.operatorConfirmedTestnetCancelReplace = try container.decode(Bool.self, forKey: .operatorConfirmedTestnetCancelReplace)
        self.nativeCancelReplaceSupported = try container.decode(Bool.self, forKey: .nativeCancelReplaceSupported)
        self.nativeReplaceRejectedFailClosed = try container.decode(Bool.self, forKey: .nativeReplaceRejectedFailClosed)
        self.cancelThenNewSubmitEmulationUsed = try container.decode(Bool.self, forKey: .cancelThenNewSubmitEmulationUsed)
        self.requestBodyRedacted = try container.decode(Bool.self, forKey: .requestBodyRedacted)
        self.responseBodyRedacted = try container.decode(Bool.self, forKey: .responseBodyRedacted)
        self.credentialMaterialRedacted = try container.decode(Bool.self, forKey: .credentialMaterialRedacted)
        self.orderIdentityMaterialRedacted = try container.decode(Bool.self, forKey: .orderIdentityMaterialRedacted)
        self.appendOnlyCancelReplaceEvidenceCreated = try container.decode(Bool.self, forKey: .appendOnlyCancelReplaceEvidenceCreated)
        self.omsStateTransitionIntegrated = try container.decode(Bool.self, forKey: .omsStateTransitionIntegrated)
        self.testnetNetworkCancelPerformed = try container.decode(Bool.self, forKey: .testnetNetworkCancelPerformed)
        self.testnetNetworkSubmitPerformed = try container.decode(Bool.self, forKey: .testnetNetworkSubmitPerformed)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretAutoRead = try container.decode(Bool.self, forKey: .productionSecretAutoRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        self.validationAnchors = try container.decode([String].self, forKey: .validationAnchors)

        let expectedID = Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            cancelRuntimeEvidenceID: cancelRuntimeEvidenceID,
            replacementSubmitRuntimeEvidenceID: replacementSubmitRuntimeEvidenceID,
            omsTransitionEvidenceID: omsTransitionEvidenceID
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            runtimeEvidenceID == expectedID,
            field: "releaseV0150SpotTestnetCancelReplace.runtimeEvidenceID",
            expected: expectedID.rawValue,
            actual: runtimeEvidenceID.rawValue
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SpotTestnetCancelReplace.runtimeEvidence.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
            && orderLifecycleState == .replaced
            && explicitTestnetMode
            && spotTestnetOnly
            && operatorConfirmedTestnetCancelReplace
            && nativeCancelReplaceSupported == false
            && nativeReplaceRejectedFailClosed
            && cancelThenNewSubmitEmulationUsed
            && requestBodyRedacted
            && responseBodyRedacted
            && credentialMaterialRedacted
            && orderIdentityMaterialRedacted
            && appendOnlyCancelReplaceEvidenceCreated
            && omsStateTransitionIntegrated
            && testnetNetworkCancelPerformed
            && testnetNetworkSubmitPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME",
        "TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE",
        "V0150-005-CANCEL-REPLACE-EMULATION",
        "V0150-005-CANCEL-THEN-NEW-SUBMIT",
        "V0150-005-OMS-REPLACE-STATE-TRANSITION",
        "V0150-005-APPEND-ONLY-CANCEL-REPLACE-EVENT",
        "V0150-005-UNSUPPORTED-NATIVE-REPLACE-FAIL-CLOSED",
        "V0150-005-PRODUCTION-ENDPOINT-BLOCKED",
        "V0150-005-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        cancelRuntimeEvidenceID: Identifier,
        replacementSubmitRuntimeEvidenceID: Identifier,
        omsTransitionEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1070-spot-testnet-cancel-replace-runtime",
                sourceSubmitRuntimeEvidenceID.rawValue,
                cancelRuntimeEvidenceID.rawValue,
                replacementSubmitRuntimeEvidenceID.rawValue,
                omsTransitionEvidenceID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0150SpotTestnetCancelReplace.runtimeEvidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.runtimeEvidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeResult bundles cancel-replace evidence and appended log.
///
/// The result proves that cancel, replacement submit and aggregate cancelReplace events were appended in
/// order. The final event is the aggregate `.cancelReplace` artifact and keeps production trading disabled.
public struct ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let cancelReplaceEvidence: ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence
    public let cancelResult: ReleaseV0150BinanceSpotTestnetCancelRuntimeResult
    public let replacementSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence
    public let appendedNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    public let appendedCancelReplaceEventID: Identifier
    public let appendedCancelReplaceArtifactChecksum: String

    private enum CodingKeys: String, CodingKey {
        case resultID
        case cancelReplaceEvidence
        case cancelResult
        case replacementSubmitEvidence
        case appendedNetworkEventLog
        case appendedCancelReplaceEventID
        case appendedCancelReplaceArtifactChecksum
    }

    public init(
        resultID: Identifier,
        cancelReplaceEvidence: ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence,
        cancelResult: ReleaseV0150BinanceSpotTestnetCancelRuntimeResult,
        replacementSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        appendedNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    ) throws {
        guard cancelReplaceEvidence.boundaryHeld,
              cancelResult.boundaryHeld,
              replacementSubmitEvidence.boundaryHeld,
              appendedNetworkEventLog.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.runtimeResult.unheldEvidence")
        }
        guard let lastEvent = appendedNetworkEventLog.eventArtifacts.last,
              lastEvent.actionKind == .cancelReplace,
              lastEvent.actionEvidenceID == cancelReplaceEvidence.runtimeEvidenceID,
              lastEvent.orderLifecycleState == .replaced else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.lastNetworkEvent",
                expected: "last event is cancelReplace artifact for cancel-replace runtime evidence",
                actual: appendedNetworkEventLog.eventArtifacts.last?.actionKind.rawValue ?? "missing"
            )
        }
        guard resultID == Self.deterministicID(
            cancelReplaceRuntimeEvidenceID: cancelReplaceEvidence.runtimeEvidenceID,
            latestArtifactChecksum: appendedNetworkEventLog.latestArtifactChecksum
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.resultID",
                expected: Self.deterministicID(
                    cancelReplaceRuntimeEvidenceID: cancelReplaceEvidence.runtimeEvidenceID,
                    latestArtifactChecksum: appendedNetworkEventLog.latestArtifactChecksum
                ).rawValue,
                actual: resultID.rawValue
            )
        }

        self.resultID = resultID
        self.cancelReplaceEvidence = cancelReplaceEvidence
        self.cancelResult = cancelResult
        self.replacementSubmitEvidence = replacementSubmitEvidence
        self.appendedNetworkEventLog = appendedNetworkEventLog
        self.appendedCancelReplaceEventID = lastEvent.eventArtifactID
        self.appendedCancelReplaceArtifactChecksum = lastEvent.artifactChecksum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultID = try container.decode(Identifier.self, forKey: .resultID)
        self.cancelReplaceEvidence = try container.decode(ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence.self, forKey: .cancelReplaceEvidence)
        self.cancelResult = try container.decode(ReleaseV0150BinanceSpotTestnetCancelRuntimeResult.self, forKey: .cancelResult)
        self.replacementSubmitEvidence = try container.decode(ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence.self, forKey: .replacementSubmitEvidence)
        self.appendedNetworkEventLog = try container.decode(ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.self, forKey: .appendedNetworkEventLog)
        self.appendedCancelReplaceEventID = try container.decode(Identifier.self, forKey: .appendedCancelReplaceEventID)
        self.appendedCancelReplaceArtifactChecksum = try container.decode(String.self, forKey: .appendedCancelReplaceArtifactChecksum)

        let expectedID = Self.deterministicID(
            cancelReplaceRuntimeEvidenceID: cancelReplaceEvidence.runtimeEvidenceID,
            latestArtifactChecksum: appendedNetworkEventLog.latestArtifactChecksum
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            resultID == expectedID,
            field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.resultID",
            expected: expectedID.rawValue,
            actual: resultID.rawValue
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            appendedCancelReplaceArtifactChecksum == appendedNetworkEventLog.latestArtifactChecksum,
            field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.appendedCancelReplaceArtifactChecksum",
            expected: appendedNetworkEventLog.latestArtifactChecksum,
            actual: appendedCancelReplaceArtifactChecksum
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        cancelReplaceEvidence.boundaryHeld
            && cancelResult.boundaryHeld
            && replacementSubmitEvidence.boundaryHeld
            && appendedNetworkEventLog.boundaryHeld
            && appendedNetworkEventLog.eventArtifacts.last?.actionKind == .cancelReplace
            && appendedNetworkEventLog.eventArtifacts.last?.actionEvidenceID == cancelReplaceEvidence.runtimeEvidenceID
    }

    public static func deterministicID(
        cancelReplaceRuntimeEvidenceID: Identifier,
        latestArtifactChecksum: String
    ) -> Identifier {
        .constant(
            "gh-1070-spot-testnet-cancel-replace-result:\(cancelReplaceRuntimeEvidenceID.rawValue):\(latestArtifactChecksum)",
            field: "releaseV0150SpotTestnetCancelReplace.runtimeResult.resultID"
        )
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime executes guarded cancel + new submit emulation.
///
/// The runtime requires prior #1068 submit evidence, #1069 cancel identity, an existing append-only network
/// event log, and a replacement Spot Testnet OrderIntent. It does not attempt native `/api/v3/order/cancelReplace`;
/// that native path remains explicitly unsupported and fail-closed in v0.15.0.
public struct ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime: Sendable {
    public let requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder
    private let cancelTransport: any ReleaseV0150BinanceSpotTestnetCancelTransport
    private let submitTransport: any ReleaseV0150BinanceSpotTestnetSubmitTransport

    public init(
        requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder,
        cancelTransport: any ReleaseV0150BinanceSpotTestnetCancelTransport,
        submitTransport: any ReleaseV0150BinanceSpotTestnetSubmitTransport
    ) {
        self.requestBuilder = requestBuilder
        self.cancelTransport = cancelTransport
        self.submitTransport = submitTransport
    }

    public func cancelReplaceSpotTestnetOrder(
        sourceIntent: OrderIntent,
        replacementIntent: OrderIntent,
        replaceMapping: ExecutionContractRequestMapping,
        cancelMapping: ExecutionContractRequestMapping,
        replacementSubmitMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        existingNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        cancelOrderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        operatorConfirmationID: Identifier,
        runtimeGate: ReleaseV0151BinanceSpotTestnetRuntimeInternalGate,
        cancelTimestamp: Date,
        replacementSubmitTimestamp: Date,
        cancelObservedAtMilliseconds: Int64,
        replacementSubmitObservedAtMilliseconds: Int64,
        cancelReplaceObservedAtMilliseconds: Int64,
        receiveWindowMilliseconds: Int = 5_000
    ) async throws -> ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeResult {
        guard requestBuilder.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.requestBuilder")
        }
        guard sourceIntent.isPreRiskEngineIntent,
              replacementIntent.isPreRiskEngineIntent,
              sourceIntent.instrument == replacementIntent.instrument,
              sourceIntent.instrument.productType == .spot,
              replaceMapping.boundaryHeld,
              replaceMapping.intentID == sourceIntent.intentID,
              replaceMapping.operation == .replace,
              replaceMapping.mode == .binanceTestnet,
              replaceMapping.targetLifecycleState == .replaceRequested,
              cancelMapping.boundaryHeld,
              cancelMapping.intentID == sourceIntent.intentID,
              cancelMapping.operation == .cancel,
              cancelMapping.mode == .binanceTestnet,
              replacementSubmitMapping.boundaryHeld,
              replacementSubmitMapping.intentID == replacementIntent.intentID,
              replacementSubmitMapping.operation == .submit,
              replacementSubmitMapping.mode == .binanceTestnet,
              sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.intentID == sourceIntent.intentID,
              sourceSubmitEvidence.credentialReferenceID == credential.reference.referenceID,
              cancelOrderIdentity.reference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              existingNetworkEventLog.boundaryHeld,
	              existingNetworkEventLog.eventArtifacts.contains(where: {
	                  $0.actionKind == .submit && $0.actionEvidenceID == sourceSubmitEvidence.runtimeEvidenceID
	              }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancelReplace.runtimeInputs")
        }
        try runtimeGate.requireTransportAllowed(
            action: .cancelReplace,
            intentIDs: [sourceIntent.intentID, replacementIntent.intentID],
            mappingIDs: [replaceMapping.mappingID, cancelMapping.mappingID, replacementSubmitMapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
        )

        let operatorGate = try ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate(
            gateID: ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate.deterministicID(
                strategyRunID: sourceIntent.correlation.strategyRunID,
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                sourceIntentID: sourceIntent.intentID,
                replacementIntentID: replacementIntent.intentID,
                replaceMappingID: replaceMapping.mappingID,
                operatorConfirmationID: operatorConfirmationID
            ),
            operatorConfirmationID: operatorConfirmationID,
            strategyRunID: sourceIntent.correlation.strategyRunID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            sourceIntentID: sourceIntent.intentID,
            replacementIntentID: replacementIntent.intentID,
            replaceMappingID: replaceMapping.mappingID,
            credentialReferenceID: credential.reference.referenceID
        )
        let cancelRuntime = ReleaseV0150BinanceSpotTestnetCancelRuntime(
            requestBuilder: requestBuilder,
            transport: cancelTransport
        )
        let cancelRuntimeGate = try runtimeGate.derivedAllowedGate(
            action: .cancel,
            intentIDs: [sourceIntent.intentID],
            mappingIDs: [cancelMapping.mappingID],
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
        )
        let cancelResult = try await cancelRuntime.cancelSpotTestnetOrder(
            intent: sourceIntent,
            cancelMapping: cancelMapping,
            sourceSubmitEvidence: sourceSubmitEvidence,
            existingNetworkEventLog: existingNetworkEventLog,
            credential: credential,
            cancelOrderIdentity: cancelOrderIdentity,
            operatorConfirmationID: operatorConfirmationID,
            runtimeGate: cancelRuntimeGate,
            timestamp: cancelTimestamp,
            observedAtMilliseconds: cancelObservedAtMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let submitRuntime = ReleaseV0150BinanceSpotTestnetSubmitRuntime(
            requestBuilder: requestBuilder,
            transport: submitTransport
        )
        let replacementSubmitRuntimeGate = try runtimeGate.derivedAllowedGate(
            action: .submit,
            intentIDs: [replacementIntent.intentID],
            mappingIDs: [replacementSubmitMapping.mappingID]
        )
        let replacementSubmitEvidence = try await submitRuntime.submitMarketOrder(
            intent: replacementIntent,
            mapping: replacementSubmitMapping,
            credential: credential,
            operatorConfirmationID: operatorConfirmationID,
            runtimeGate: replacementSubmitRuntimeGate,
            timestamp: replacementSubmitTimestamp,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let replacementSubmitEvent = try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.fromSubmitRuntimeEvidence(
            replacementSubmitEvidence,
            sequenceNumber: cancelResult.appendedNetworkEventLog.eventArtifacts.count + 1,
            observedAtMilliseconds: replacementSubmitObservedAtMilliseconds,
            previousArtifactChecksum: cancelResult.appendedNetworkEventLog.latestArtifactChecksum
        )
        let logWithReplacementSubmit = try cancelResult.appendedNetworkEventLog.appending(replacementSubmitEvent)
        let omsTransition = try ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence(
            transitionEvidenceID: ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence.deterministicID(
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                cancelRuntimeEvidenceID: cancelResult.cancelEvidence.runtimeEvidenceID,
                replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
                replaceMappingID: replaceMapping.mappingID
            ),
            sourceIntent: sourceIntent,
            replacementIntent: replacementIntent,
            replaceMapping: replaceMapping,
            sourceSubmitEvidence: sourceSubmitEvidence,
            cancelEvidence: cancelResult.cancelEvidence,
            replacementSubmitEvidence: replacementSubmitEvidence
        )
        let cancelReplaceEvidence = try ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence(
            runtimeEvidenceID: ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence.deterministicID(
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                cancelRuntimeEvidenceID: cancelResult.cancelEvidence.runtimeEvidenceID,
                replacementSubmitRuntimeEvidenceID: replacementSubmitEvidence.runtimeEvidenceID,
                omsTransitionEvidenceID: omsTransition.transitionEvidenceID
            ),
            sourceIntent: sourceIntent,
            replacementIntent: replacementIntent,
            replaceMapping: replaceMapping,
            sourceSubmitEvidence: sourceSubmitEvidence,
            cancelEvidence: cancelResult.cancelEvidence,
            replacementSubmitEvidence: replacementSubmitEvidence,
            operatorGate: operatorGate,
            omsTransition: omsTransition
        )
        let cancelReplaceEvent = try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.fromCancelReplaceRuntimeEvidence(
            cancelReplaceEvidence,
            sequenceNumber: logWithReplacementSubmit.eventArtifacts.count + 1,
            observedAtMilliseconds: cancelReplaceObservedAtMilliseconds,
            previousArtifactChecksum: logWithReplacementSubmit.latestArtifactChecksum
        )
        let appendedLog = try logWithReplacementSubmit.appending(cancelReplaceEvent)
        return try ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeResult(
            resultID: ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeResult.deterministicID(
                cancelReplaceRuntimeEvidenceID: cancelReplaceEvidence.runtimeEvidenceID,
                latestArtifactChecksum: appendedLog.latestArtifactChecksum
            ),
            cancelReplaceEvidence: cancelReplaceEvidence,
            cancelResult: cancelResult,
            replacementSubmitEvidence: replacementSubmitEvidence,
            appendedNetworkEventLog: appendedLog
        )
    }
}
