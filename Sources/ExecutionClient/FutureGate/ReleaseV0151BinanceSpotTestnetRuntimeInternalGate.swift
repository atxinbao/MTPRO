import DomainModel
import Foundation

// GH-1098 static contract boundary:
// runtimeInternalGateRequired=true
// riskEngineGateInsideRuntime=true
// killSwitchGateInsideRuntime=true
// noTradeGateInsideRuntime=true
// operatorConfirmationGateInsideRuntime=true
// transportNotInvokedWhenBlocked=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker 固定 #1098 runtime 内部阻断原因。
///
/// 它只表达 testnet execution runtime 在触达 transport 前看到的本地 gate 状态。该枚举不携带
/// secret、order raw identity、broker payload 或 production endpoint。
public enum ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker: String, Codable, CaseIterable, Equatable, Sendable {
    case none = "none"
    case riskEngineRejected = "risk-engine-rejected"
    case killSwitchActive = "kill-switch-active"
    case noTradeActive = "no-trade-active"
    case operatorConfirmationMissing = "operator-confirmation-missing"
}

/// ReleaseV0151BinanceSpotTestnetRuntimeInternalGate 是 v0.15.1 的 runtime-internal pre-transport gate。
///
/// #1098 的关键变化是：submit / cancel / cancel-replace 不再只信任外部传入的 `riskAccepted`
/// mapping。每条真实 Spot Testnet transport 调用前，runtime 必须在内部重新确认 RiskEngine allow、
/// kill switch inactive、no-trade inactive 和显式 operator confirmation。失败时必须在 transport
/// 之前抛错，避免调用方用预先接受的 mapping 绕过 gate。
public struct ReleaseV0151BinanceSpotTestnetRuntimeInternalGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction
    public let intentIDs: [Identifier]
    public let mappingIDs: [Identifier]
    public let operatorConfirmationID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier?
    public let derivedFromGateID: Identifier?
    public let blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker
    public let runtimeInternalGateRequired: Bool
    public let riskEngineAllowed: Bool
    public let killSwitchInactive: Bool
    public let noTradeInactive: Bool
    public let operatorConfirmationAccepted: Bool
    public let transportInvocationAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        gateID: Identifier,
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentIDs: [Identifier],
        mappingIDs: [Identifier],
        operatorConfirmationID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier? = nil,
        derivedFromGateID: Identifier? = nil,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker = .none,
        runtimeInternalGateRequired: Bool = true,
        riskEngineAllowed: Bool = true,
        killSwitchInactive: Bool = true,
        noTradeInactive: Bool = true,
        operatorConfirmationAccepted: Bool = true,
        transportInvocationAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard intentIDs.isEmpty == false, mappingIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetRuntimeInternalGate.identity",
                expected: "non-empty intent and mapping identity",
                actual: "\(intentIDs.count):\(mappingIDs.count)"
            )
        }
        guard gateID == Self.deterministicID(
            action: action,
            intentIDs: intentIDs,
            mappingIDs: mappingIDs,
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            derivedFromGateID: derivedFromGateID,
            blocker: blocker
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetRuntimeInternalGate.gateID",
                expected: Self.deterministicID(
                    action: action,
                    intentIDs: intentIDs,
                    mappingIDs: mappingIDs,
                    operatorConfirmationID: operatorConfirmationID,
                    sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
                    derivedFromGateID: derivedFromGateID,
                    blocker: blocker
                ).rawValue,
                actual: gateID.rawValue
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetRuntimeInternalGate.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.gateID = gateID
        self.action = action
        self.intentIDs = intentIDs
        self.mappingIDs = mappingIDs
        self.operatorConfirmationID = operatorConfirmationID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitRuntimeEvidenceID
        self.derivedFromGateID = derivedFromGateID
        self.blocker = blocker
        self.runtimeInternalGateRequired = runtimeInternalGateRequired
        self.riskEngineAllowed = riskEngineAllowed
        self.killSwitchInactive = killSwitchInactive
        self.noTradeInactive = noTradeInactive
        self.operatorConfirmationAccepted = operatorConfirmationAccepted
        self.transportInvocationAllowed = transportInvocationAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        runtimeInternalGateRequired
            && blocker == .none
            && riskEngineAllowed
            && killSwitchInactive
            && noTradeInactive
            && operatorConfirmationAccepted
            && transportInvocationAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static func allowedSubmit(
        intent: OrderIntent,
        mapping: ExecutionContractRequestMapping,
        operatorConfirmationID: Identifier
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .submit,
            intentIDs: [intent.intentID],
            mappingIDs: [mapping.mappingID],
            operatorConfirmationID: operatorConfirmationID
        )
    }

    public static func allowedCancel(
        intent: OrderIntent,
        cancelMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        operatorConfirmationID: Identifier
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .cancel,
            intentIDs: [intent.intentID],
            mappingIDs: [cancelMapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
        )
    }

    public static func allowedCancelReplace(
        sourceIntent: OrderIntent,
        replacementIntent: OrderIntent,
        replaceMapping: ExecutionContractRequestMapping,
        cancelMapping: ExecutionContractRequestMapping,
        replacementSubmitMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        operatorConfirmationID: Identifier
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .cancelReplace,
            intentIDs: [sourceIntent.intentID, replacementIntent.intentID],
            mappingIDs: [replaceMapping.mappingID, cancelMapping.mappingID, replacementSubmitMapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
        )
    }

    public static func blockedSubmit(
        intent: OrderIntent,
        mapping: ExecutionContractRequestMapping,
        operatorConfirmationID: Identifier,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .submit,
            intentIDs: [intent.intentID],
            mappingIDs: [mapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            blocker: blocker
        )
    }

    public static func blockedCancel(
        intent: OrderIntent,
        cancelMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        operatorConfirmationID: Identifier,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .cancel,
            intentIDs: [intent.intentID],
            mappingIDs: [cancelMapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            blocker: blocker
        )
    }

    public static func blockedCancelReplace(
        sourceIntent: OrderIntent,
        replacementIntent: OrderIntent,
        replaceMapping: ExecutionContractRequestMapping,
        cancelMapping: ExecutionContractRequestMapping,
        replacementSubmitMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        operatorConfirmationID: Identifier,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try make(
            action: .cancelReplace,
            intentIDs: [sourceIntent.intentID, replacementIntent.intentID],
            mappingIDs: [replaceMapping.mappingID, cancelMapping.mappingID, replacementSubmitMapping.mappingID],
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            blocker: blocker
        )
    }

    public func derivedAllowedGate(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentIDs: [Identifier],
        mappingIDs: [Identifier],
        sourceSubmitRuntimeEvidenceID: Identifier? = nil
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try Self.make(
            action: action,
            intentIDs: intentIDs,
            mappingIDs: mappingIDs,
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            derivedFromGateID: gateID
        )
    }

    public func requireTransportAllowed(
        action expectedAction: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentIDs expectedIntentIDs: [Identifier],
        mappingIDs expectedMappingIDs: [Identifier],
        operatorConfirmationID expectedOperatorConfirmationID: Identifier,
        sourceSubmitRuntimeEvidenceID expectedSourceSubmitRuntimeEvidenceID: Identifier? = nil
    ) throws {
        guard action == expectedAction,
              intentIDs == expectedIntentIDs,
              mappingIDs == expectedMappingIDs,
              operatorConfirmationID == expectedOperatorConfirmationID,
              sourceSubmitRuntimeEvidenceID == expectedSourceSubmitRuntimeEvidenceID else {
            let expectedIdentity = [
                expectedAction.rawValue,
                expectedIntentIDs.map(\.rawValue).joined(separator: "+"),
                expectedMappingIDs.map(\.rawValue).joined(separator: "+")
            ].joined(separator: ":")
            let actualIdentity = [
                action.rawValue,
                intentIDs.map(\.rawValue).joined(separator: "+"),
                mappingIDs.map(\.rawValue).joined(separator: "+")
            ].joined(separator: ":")
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetRuntimeInternalGate.identity",
                expected: expectedIdentity,
                actual: actualIdentity
            )
        }
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0151SpotTestnetRuntimeInternalGate.\(blocker.rawValue)"
            )
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES",
        "TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES",
        "V0151-005-RISKENGINE-GATE-IN-RUNTIME",
        "V0151-005-KILL-SWITCH-GATE-IN-RUNTIME",
        "V0151-005-NO-TRADE-GATE-IN-RUNTIME",
        "V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME",
        "V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED",
        "V0151-005-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentIDs: [Identifier],
        mappingIDs: [Identifier],
        operatorConfirmationID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier? = nil,
        derivedFromGateID: Identifier? = nil,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker = .none
    ) -> Identifier {
        .constant(
            [
                "gh-1098-v0151-runtime-internal-gate",
                action.rawValue,
                intentIDs.map(\.rawValue).joined(separator: "+"),
                mappingIDs.map(\.rawValue).joined(separator: "+"),
                operatorConfirmationID.rawValue,
                sourceSubmitRuntimeEvidenceID?.rawValue ?? "no-source-submit",
                derivedFromGateID?.rawValue ?? "root-gate",
                blocker.rawValue
            ].joined(separator: ":"),
            field: "releaseV0151SpotTestnetRuntimeInternalGate.gateID"
        )
    }

    private static func make(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentIDs: [Identifier],
        mappingIDs: [Identifier],
        operatorConfirmationID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier? = nil,
        derivedFromGateID: Identifier? = nil,
        blocker: ReleaseV0151BinanceSpotTestnetRuntimeInternalGateBlocker = .none
    ) throws -> ReleaseV0151BinanceSpotTestnetRuntimeInternalGate {
        try ReleaseV0151BinanceSpotTestnetRuntimeInternalGate(
            gateID: deterministicID(
                action: action,
                intentIDs: intentIDs,
                mappingIDs: mappingIDs,
                operatorConfirmationID: operatorConfirmationID,
                sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
                derivedFromGateID: derivedFromGateID,
                blocker: blocker
            ),
            action: action,
            intentIDs: intentIDs,
            mappingIDs: mappingIDs,
            operatorConfirmationID: operatorConfirmationID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            derivedFromGateID: derivedFromGateID,
            blocker: blocker,
            riskEngineAllowed: blocker != .riskEngineRejected,
            killSwitchInactive: blocker != .killSwitchActive,
            noTradeInactive: blocker != .noTradeActive,
            operatorConfirmationAccepted: blocker != .operatorConfirmationMissing,
            transportInvocationAllowed: blocker == .none
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetRuntimeInternalGate.\(field)")
        }
    }
}
