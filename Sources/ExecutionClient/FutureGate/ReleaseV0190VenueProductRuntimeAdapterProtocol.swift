import DomainModel
import Foundation

// GH-1211 static contract boundary:
// runtimeAdapterOperations=submit,cancel,queryStatus,queryPosition,reconcile,recover
// runtimeAdapterSelectionRequiresTypedNamespace=true
// runtimeAdapterCapabilityMatrixRequired=true
// localEvidenceAdapterOnly=true
// unsupportedCapabilitiesFailClosed=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// productionCutoverAuthorized=false
// GH-1211-VERIFY-V0190-RUNTIME-ADAPTER-PROTOCOL
// TVM-RELEASE-V0190-RUNTIME-ADAPTER-PROTOCOL
// V0190-006-RUNTIME-ADAPTER-PROTOCOL
// V0190-006-CAPABILITY-GATED-OPERATIONS
// V0190-006-TYPED-NAMESPACE-SELECTION
// V0190-006-UNSUPPORTED-FAILS-CLOSED
// V0190-006-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueProductRuntimeAdapterOperation 固定 #1211 runtime adapter 协议的操作面。
///
/// 这些 case 只定义 registry-aware adapter foundation 的调用形状。`recover` 复用
/// `reconcile` capability gate，因为 #1211 不扩大 #1207 的 capability matrix。
public enum ReleaseV0190VenueProductRuntimeAdapterOperation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case queryStatus
    case queryPosition
    case reconcile
    case recover

    public var requiredCapability: ReleaseV0190VenueProductCapability {
        switch self {
        case .submit:
            .submit
        case .cancel:
            .cancel
        case .queryStatus:
            .status
        case .queryPosition:
            .position
        case .reconcile, .recover:
            .reconcile
        }
    }
}

/// ReleaseV0190VenueProductRuntimeAdapterSelection 是 adapter 选择前的 typed namespace 证据。
///
/// Selection 必须同时绑定 venue/product/environment/accountProfile、capability matrix、
/// endpoint family 和 credential profile registry。它不读取 secret、不打开 endpoint，也不把
/// productionShadow / productionLive 升级成可执行 runtime。
public struct ReleaseV0190VenueProductRuntimeAdapterSelection: Equatable, Sendable {
    public let target: ReleaseV0190VenueProductTarget
    public let capabilityProfile: ReleaseV0190VenueProductCapabilityProfile
    public let endpointFamily: ReleaseV0190VenueEndpointFamilyEntry
    public let credentialProfile: ReleaseV0190VenueCredentialProfileEntry
    public let localEvidenceAdapterOnly: Bool
    public let readsSecretValue: Bool
    public let connectsEndpoint: Bool
    public let productionCutoverAuthorized: Bool

    public var namespaceKey: String { target.namespaceKey }

    public var selectionHeld: Bool {
        target.pair == capabilityProfile.pair
            && endpointFamily.pair == target.pair
            && credentialProfile.pair == target.pair
            && endpointFamily.tradingEnvironment == target.tradingEnvironment
            && credentialProfile.tradingEnvironment == target.tradingEnvironment
            && credentialProfile.profileID == target.accountProfileID
            && localEvidenceAdapterOnly
            && readsSecretValue == false
            && connectsEndpoint == false
            && productionCutoverAuthorized == false
    }

    public var localExecutableEvidenceBoundaryHeld: Bool {
        target.tradingEnvironment == .testnet
            && endpointFamily.state == .activeReference
            && credentialProfile.state == .testnetReference
            && selectionHeld
    }

    public init(
        target: ReleaseV0190VenueProductTarget,
        localEvidenceAdapterOnly: Bool = true,
        readsSecretValue: Bool = false,
        connectsEndpoint: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let capabilityProfile = try ReleaseV0190VenueProductCapabilityMatrix.profile(
            venueID: target.venueID,
            productKind: target.productKind
        )
        let endpointFamily = try ReleaseV0190VenueEndpointFamilyRegistry.entry(
            venueID: target.venueID,
            productKind: target.productKind,
            tradingEnvironment: target.tradingEnvironment
        )
        let credentialProfile = try ReleaseV0190VenueCredentialProfileRegistry.entry(
            venueID: target.venueID,
            productKind: target.productKind,
            tradingEnvironment: target.tradingEnvironment
        )

        try Self.validate(
            target: target,
            capabilityProfile: capabilityProfile,
            endpointFamily: endpointFamily,
            credentialProfile: credentialProfile,
            localEvidenceAdapterOnly: localEvidenceAdapterOnly,
            readsSecretValue: readsSecretValue,
            connectsEndpoint: connectsEndpoint,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.target = target
        self.capabilityProfile = capabilityProfile
        self.endpointFamily = endpointFamily
        self.credentialProfile = credentialProfile
        self.localEvidenceAdapterOnly = localEvidenceAdapterOnly
        self.readsSecretValue = readsSecretValue
        self.connectsEndpoint = connectsEndpoint
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func select(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterSelection {
        try ReleaseV0190VenueProductRuntimeAdapterSelection(
            target: ReleaseV0190VenueProductTarget(
                venueID: venueID,
                productKind: productKind,
                tradingEnvironment: tradingEnvironment,
                accountProfileID: accountProfileID
            )
        )
    }

    private static func validate(
        target: ReleaseV0190VenueProductTarget,
        capabilityProfile: ReleaseV0190VenueProductCapabilityProfile,
        endpointFamily: ReleaseV0190VenueEndpointFamilyEntry,
        credentialProfile: ReleaseV0190VenueCredentialProfileEntry,
        localEvidenceAdapterOnly: Bool,
        readsSecretValue: Bool,
        connectsEndpoint: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        guard capabilityProfile.pair == target.pair else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.capabilityProfile",
                expected: target.namespaceKey,
                actual: "\(capabilityProfile.pair.venueID.rawValue)/\(capabilityProfile.pair.productKind.rawValue)"
            )
        }
        guard endpointFamily.pair == target.pair,
              endpointFamily.tradingEnvironment == target.tradingEnvironment else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.endpointFamily",
                expected: target.namespaceKey,
                actual: "\(endpointFamily.pair.venueID.rawValue)/\(endpointFamily.pair.productKind.rawValue)/\(endpointFamily.tradingEnvironment.rawValue)"
            )
        }
        guard credentialProfile.pair == target.pair,
              credentialProfile.tradingEnvironment == target.tradingEnvironment,
              credentialProfile.profileID == target.accountProfileID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.credentialProfile.namespaceReuse",
                expected: target.namespaceKey,
                actual: credentialProfile.namespaceKey
            )
        }
        guard localEvidenceAdapterOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.nonLocalEvidenceAdapter")
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.readsSecretValue")
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.connectsEndpoint")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.productionCutoverAuthorized")
        }
        guard endpointFamily.connectsEndpoint == false,
              credentialProfile.connectsEndpoint == false,
              credentialProfile.readsSecretValue == false,
              credentialProfile.storesSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.registrySideEffect")
        }
    }
}

/// ReleaseV0190VenueProductRuntimeAdapterRequest 是 #1211 local adapter 的 deterministic 输入。
///
/// Request 只携带 typed target、operation 和本地 reason；它不是交易所 API request，
/// 不包含 signature、secret、listen key、account payload、broker payload 或 network URL。
public struct ReleaseV0190VenueProductRuntimeAdapterRequest: Equatable, Sendable {
    public let requestID: Identifier
    public let target: ReleaseV0190VenueProductTarget
    public let operation: ReleaseV0190VenueProductRuntimeAdapterOperation
    public let reason: String
    public let readsSecretValue: Bool
    public let connectsEndpoint: Bool
    public let touchesBrokerGateway: Bool
    public let authorizesProductionCutover: Bool

    public init(
        requestID: Identifier,
        target: ReleaseV0190VenueProductTarget,
        operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        reason: String,
        readsSecretValue: Bool = false,
        connectsEndpoint: Bool = false,
        touchesBrokerGateway: Bool = false,
        authorizesProductionCutover: Bool = false
    ) throws {
        guard reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.reason",
                expected: "non-empty local evidence reason",
                actual: "empty"
            )
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.request.readsSecretValue")
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.request.connectsEndpoint")
        }
        guard touchesBrokerGateway == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.request.touchesBrokerGateway")
        }
        guard authorizesProductionCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.request.productionCutover")
        }

        self.requestID = requestID
        self.target = target
        self.operation = operation
        self.reason = reason
        self.readsSecretValue = readsSecretValue
        self.connectsEndpoint = connectsEndpoint
        self.touchesBrokerGateway = touchesBrokerGateway
        self.authorizesProductionCutover = authorizesProductionCutover
    }
}

/// ReleaseV0190VenueProductRuntimeAdapterEvidence 是 local adapter 返回的审计证据。
///
/// Evidence 只证明 typed selection、capability gate 和 fail-closed boundary 已执行。它不是
/// broker ack、execution report、fill、OMS transition，也不表示真实 submit / cancel 成功。
public struct ReleaseV0190VenueProductRuntimeAdapterEvidence: Equatable, Sendable {
    public let evidenceID: Identifier
    public let requestID: Identifier
    public let namespaceKey: String
    public let operation: ReleaseV0190VenueProductRuntimeAdapterOperation
    public let capabilityDecision: ReleaseV0190VenueProductCapabilityDecision
    public let endpointFamilyState: ReleaseV0190VenueEndpointFamilyState
    public let credentialProfileState: ReleaseV0190VenueCredentialProfileState
    public let localEvidenceAdapterOnly: Bool
    public let readsSecretValue: Bool
    public let connectsEndpoint: Bool
    public let touchesBrokerGateway: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        capabilityDecision.isActive
            && endpointFamilyState == .activeReference
            && credentialProfileState == .testnetReference
            && localEvidenceAdapterOnly
            && readsSecretValue == false
            && connectsEndpoint == false
            && touchesBrokerGateway == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier,
        requestID: Identifier,
        namespaceKey: String,
        operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        capabilityDecision: ReleaseV0190VenueProductCapabilityDecision,
        endpointFamilyState: ReleaseV0190VenueEndpointFamilyState,
        credentialProfileState: ReleaseV0190VenueCredentialProfileState,
        localEvidenceAdapterOnly: Bool = true,
        readsSecretValue: Bool = false,
        connectsEndpoint: Bool = false,
        touchesBrokerGateway: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard localEvidenceAdapterOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.evidence.nonLocal")
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.evidence.readsSecretValue")
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.evidence.connectsEndpoint")
        }
        guard touchesBrokerGateway == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.evidence.touchesBrokerGateway")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeAdapter.evidence.productionCutover")
        }

        self.evidenceID = evidenceID
        self.requestID = requestID
        self.namespaceKey = namespaceKey
        self.operation = operation
        self.capabilityDecision = capabilityDecision
        self.endpointFamilyState = endpointFamilyState
        self.credentialProfileState = credentialProfileState
        self.localEvidenceAdapterOnly = localEvidenceAdapterOnly
        self.readsSecretValue = readsSecretValue
        self.connectsEndpoint = connectsEndpoint
        self.touchesBrokerGateway = touchesBrokerGateway
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0190VenueProductRuntimeAdapter 是 #1211 的 registry-aware adapter 协议。
///
/// 协议方法只定义操作入口；具体实现必须先通过 typed selection、capability matrix、
/// endpoint family 和 credential profile gate。当前仓库只提供 local evidence adapter。
public protocol ReleaseV0190VenueProductRuntimeAdapter: Sendable {
    var selection: ReleaseV0190VenueProductRuntimeAdapterSelection { get }

    func submit(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence

    func cancel(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence

    func queryStatus(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence

    func queryPosition(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence

    func reconcile(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence

    func recover(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence
}

/// ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter 是 #1211 的 fake/local adapter。
///
/// 它只生成 deterministic evidence。所有操作都先检查 capability matrix，再要求 testnet
/// active endpoint reference 和 testnet credential reference；OKX、productionShadow、
/// productionLive、跨 namespace profile 和 unsupported capability 全部 fail closed。
public struct ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter:
    ReleaseV0190VenueProductRuntimeAdapter,
    Equatable,
    Sendable
{
    public let adapterID: Identifier
    public let selection: ReleaseV0190VenueProductRuntimeAdapterSelection

    public init(
        adapterID: Identifier = Identifier.constant("gh-1211-v0190-local-evidence-runtime-adapter"),
        selection: ReleaseV0190VenueProductRuntimeAdapterSelection
    ) {
        self.adapterID = adapterID
        self.selection = selection
    }

    public static func select(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws -> ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter {
        try ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter(
            selection: ReleaseV0190VenueProductRuntimeAdapterSelection.select(
                venueID: venueID,
                productKind: productKind,
                tradingEnvironment: tradingEnvironment,
                accountProfileID: accountProfileID
            )
        )
    }

    public func submit(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.submit, request: request)
    }

    public func cancel(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.cancel, request: request)
    }

    public func queryStatus(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.queryStatus, request: request)
    }

    public func queryPosition(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.queryPosition, request: request)
    }

    public func reconcile(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.reconcile, request: request)
    }

    public func recover(
        _ request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        try perform(.recover, request: request)
    }

    private func perform(
        _ operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        request: ReleaseV0190VenueProductRuntimeAdapterRequest
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        guard request.target == selection.target else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.requestTarget",
                expected: selection.namespaceKey,
                actual: request.target.namespaceKey
            )
        }
        guard request.operation == operation else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.operation",
                expected: operation.rawValue,
                actual: request.operation.rawValue
            )
        }

        let decision = try ReleaseV0190VenueProductCapabilityMatrix.requireActive(
            venueID: selection.target.venueID,
            productKind: selection.target.productKind,
            tradingEnvironment: selection.target.tradingEnvironment,
            capability: operation.requiredCapability
        )

        guard selection.localExecutableEvidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeAdapter.localExecutableBoundary",
                expected: "testnet + active endpoint reference + testnet credential reference",
                actual: "\(selection.target.tradingEnvironment.rawValue)/\(selection.endpointFamily.state.rawValue)/\(selection.credentialProfile.state.rawValue)"
            )
        }

        return try ReleaseV0190VenueProductRuntimeAdapterEvidence(
            evidenceID: Identifier.constant(
                [
                    "gh-1211-runtime-adapter",
                    selection.namespaceKey.replacingOccurrences(of: "/", with: "-"),
                    operation.rawValue,
                    request.requestID.rawValue
                ].joined(separator: ":"),
                field: "releaseV0190.runtimeAdapter.evidenceID"
            ),
            requestID: request.requestID,
            namespaceKey: selection.namespaceKey,
            operation: operation,
            capabilityDecision: decision,
            endpointFamilyState: selection.endpointFamily.state,
            credentialProfileState: selection.credentialProfile.state
        )
    }
}
