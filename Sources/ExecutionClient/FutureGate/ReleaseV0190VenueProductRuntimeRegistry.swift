import DomainModel
import Foundation

// GH-1212 static contract boundary:
// runtimeRegistryTarget=binance/spot/testnet
// runtimeRegistryExistingBehaviorRouted=true
// runtimeRegistryOperations=submit,cancel,queryStatus
// runtimeRegistryUnsupportedOperationsFailClosed=true
// runtimeRegistryRequiresTypedNamespace=true
// runtimeRegistryCapabilityMatrixRequired=true
// runtimeRegistryEndpointFamilyRequired=true
// runtimeRegistryCredentialProfileRequired=true
// runtimeRegistryDoesNotChangeExistingRuntimeBehavior=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// binanceFuturesRuntimeImplementedByThisIssue=false
// productionCutoverAuthorized=false
// GH-1212-VERIFY-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY
// TVM-RELEASE-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY
// V0190-007-BINANCE-SPOT-TESTNET-REGISTRATION
// V0190-007-EXISTING-RUNTIME-ANCHORS
// V0190-007-TYPED-REGISTRY-SELECTION
// V0190-007-PLACEHOLDER-PAIRS-FAIL-CLOSED
// V0190-007-NO-BEHAVIOR-CHANGE
// V0190-007-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueProductRuntimeOperationBinding 记录一个 runtime operation 如何被 registry 路由。
///
/// Binding 只保存现有 runtime 类型锚点和本地审计边界。它不会构造 URLSession transport，
/// 不读取 credential value，也不会把 registry 解析升级为生产交易授权。
public struct ReleaseV0190VenueProductRuntimeOperationBinding: Equatable, Sendable {
    public let operation: ReleaseV0190VenueProductRuntimeAdapterOperation
    public let legacyRuntimeTypeName: String
    public let existingRuntimeAnchor: String
    public let preservesExistingSafetyGates: Bool
    public let registryConnectsEndpoint: Bool
    public let registryReadsSecretValue: Bool
    public let registryTouchesBrokerGateway: Bool
    public let registryAuthorizesProductionCutover: Bool

    public init(
        operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        legacyRuntimeTypeName: String,
        existingRuntimeAnchor: String,
        preservesExistingSafetyGates: Bool = true,
        registryConnectsEndpoint: Bool = false,
        registryReadsSecretValue: Bool = false,
        registryTouchesBrokerGateway: Bool = false,
        registryAuthorizesProductionCutover: Bool = false
    ) throws {
        guard [.submit, .cancel, .queryStatus].contains(operation) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.operation",
                expected: "submit,cancel,queryStatus existing Binance Spot Testnet behavior only",
                actual: operation.rawValue
            )
        }
        guard legacyRuntimeTypeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.legacyRuntimeTypeName",
                expected: "existing runtime type name",
                actual: "empty"
            )
        }
        guard existingRuntimeAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.existingRuntimeAnchor",
                expected: "existing runtime evidence anchor",
                actual: "empty"
            )
        }
        guard preservesExistingSafetyGates else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.safetyGateBypass")
        }
        guard registryReadsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.readsSecretValue")
        }
        guard registryConnectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.connectsEndpoint")
        }
        guard registryTouchesBrokerGateway == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.touchesBrokerGateway")
        }
        guard registryAuthorizesProductionCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.productionCutover")
        }

        self.operation = operation
        self.legacyRuntimeTypeName = legacyRuntimeTypeName
        self.existingRuntimeAnchor = existingRuntimeAnchor
        self.preservesExistingSafetyGates = preservesExistingSafetyGates
        self.registryConnectsEndpoint = registryConnectsEndpoint
        self.registryReadsSecretValue = registryReadsSecretValue
        self.registryTouchesBrokerGateway = registryTouchesBrokerGateway
        self.registryAuthorizesProductionCutover = registryAuthorizesProductionCutover
    }
}

/// ReleaseV0190VenueProductRuntimeRegistration 是 #1212 的 registry row。
///
/// 当前唯一可解析 row 是 Binance Spot Testnet。Registration 必须先完成 #1211 typed
/// selection，再把 submit / cancel / queryStatus 映射到既有 runtime 类型锚点。它只提供
/// route evidence，不改变既有 v0.15 / v0.16 runtime 的 operator confirmation、redaction
/// 或 no-production defaults。
public struct ReleaseV0190VenueProductRuntimeRegistration: Equatable, Sendable {
    public let registrationID: Identifier
    public let selection: ReleaseV0190VenueProductRuntimeAdapterSelection
    public let adapter: ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter
    public let operationBindings: [ReleaseV0190VenueProductRuntimeOperationBinding]
    public let preservesExistingBehavior: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool

    public var target: ReleaseV0190VenueProductTarget { selection.target }
    public var namespaceKey: String { selection.namespaceKey }
    public var registeredOperations: [ReleaseV0190VenueProductRuntimeAdapterOperation] {
        operationBindings.map(\.operation)
    }

    public init(
        registrationID: Identifier,
        selection: ReleaseV0190VenueProductRuntimeAdapterSelection,
        adapter: ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter,
        operationBindings: [ReleaseV0190VenueProductRuntimeOperationBinding],
        preservesExistingBehavior: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard selection.target.venueID == .binance,
              selection.target.productKind == .spot,
              selection.target.tradingEnvironment == .testnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.target",
                expected: "binance/spot/testnet",
                actual: selection.namespaceKey
            )
        }
        guard selection.localExecutableEvidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.selection",
                expected: "testnet + active endpoint reference + testnet credential reference",
                actual: "\(selection.target.tradingEnvironment.rawValue)/\(selection.endpointFamily.state.rawValue)/\(selection.credentialProfile.state.rawValue)"
            )
        }
        guard adapter.selection == selection else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.adapterSelection",
                expected: selection.namespaceKey,
                actual: adapter.selection.namespaceKey
            )
        }
        guard operationBindings.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.operationBindings",
                expected: "submit,cancel,queryStatus",
                actual: "empty"
            )
        }
        let operations = Set(operationBindings.map(\.operation))
        guard operations == Set([.submit, .cancel, .queryStatus]) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.operationBindings",
                expected: "submit,cancel,queryStatus",
                actual: operationBindings.map(\.operation.rawValue).sorted().joined(separator: ",")
            )
        }
        guard operationBindings.allSatisfy(\.preservesExistingSafetyGates) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.safetyGateBypass")
        }
        guard operationBindings.allSatisfy({ $0.registryReadsSecretValue == false }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.readsSecretValue")
        }
        guard operationBindings.allSatisfy({ $0.registryConnectsEndpoint == false }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.connectsEndpoint")
        }
        guard operationBindings.allSatisfy({ $0.registryTouchesBrokerGateway == false }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.touchesBrokerGateway")
        }
        guard operationBindings.allSatisfy({ $0.registryAuthorizesProductionCutover == false }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.productionCutover")
        }
        guard preservesExistingBehavior else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.behaviorChange")
        }
        guard productionTradingEnabledByDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.productionTradingDefault")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.runtimeRegistry.productionCutoverAuthorized")
        }

        self.registrationID = registrationID
        self.selection = selection
        self.adapter = adapter
        self.operationBindings = operationBindings
        self.preservesExistingBehavior = preservesExistingBehavior
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public func binding(
        for operation: ReleaseV0190VenueProductRuntimeAdapterOperation
    ) throws -> ReleaseV0190VenueProductRuntimeOperationBinding {
        guard let binding = operationBindings.first(where: { $0.operation == operation }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.registeredOperation",
                expected: registeredOperations.map(\.rawValue).sorted().joined(separator: ","),
                actual: operation.rawValue
            )
        }
        return binding
    }

    public func localEvidence(
        for operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        requestID: Identifier,
        reason: String
    ) throws -> ReleaseV0190VenueProductRuntimeAdapterEvidence {
        _ = try binding(for: operation)
        let request = try ReleaseV0190VenueProductRuntimeAdapterRequest(
            requestID: requestID,
            target: target,
            operation: operation,
            reason: reason
        )
        switch operation {
        case .submit:
            return try adapter.submit(request)
        case .cancel:
            return try adapter.cancel(request)
        case .queryStatus:
            return try adapter.queryStatus(request)
        case .queryPosition, .reconcile, .recover:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.registeredOperation",
                expected: registeredOperations.map(\.rawValue).sorted().joined(separator: ","),
                actual: operation.rawValue
            )
        }
    }
}

/// ReleaseV0190VenueProductRuntimeRegistry 把 #1212 的唯一可执行路径注册到 typed registry。
///
/// Registry 只支持 Binance Spot Testnet，并且只路由到既有 submit / cancel / queryStatus
/// runtime 类型锚点。OKX、Binance USDⓈ-M Futures、productionShadow、productionLive、
/// 未注册 operation 和跨 profile reuse 都保持 fail closed。
public enum ReleaseV0190VenueProductRuntimeRegistry {
    public static let productionTradingEnabledByDefault = false
    public static let productionSecretReadEnabled = false
    public static let productionEndpointConnectionEnabled = false
    public static let productionBrokerConnectionEnabled = false
    public static let productionOrderSubmitCancelReplaceEnabled = false
    public static let okxRuntimeImplemented = false
    public static let binanceFuturesRuntimeImplementedByThisIssue = false
    public static let productionCutoverAuthorized = false

    public static func registration(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws -> ReleaseV0190VenueProductRuntimeRegistration {
        let target = try ReleaseV0190VenueProductTarget(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            accountProfileID: accountProfileID
        )

        guard target.venueID == .binance,
              target.productKind == .spot,
              target.tradingEnvironment == .testnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.runtimeRegistry.target",
                expected: "binance/spot/testnet existing runtime path",
                actual: unsupportedReason(for: target)
            )
        }

        let selection = try ReleaseV0190VenueProductRuntimeAdapterSelection(target: target)
        let adapter = ReleaseV0190LocalEvidenceVenueProductRuntimeAdapter(
            adapterID: Identifier.constant(
                "gh-1212-v0190-binance-spot-testnet-runtime-registry-adapter",
                field: "releaseV0190.runtimeRegistry.adapterID"
            ),
            selection: selection
        )
        return try ReleaseV0190VenueProductRuntimeRegistration(
            registrationID: Identifier.constant(
                "gh-1212-v0190-binance-spot-testnet-runtime-registry",
                field: "releaseV0190.runtimeRegistry.registrationID"
            ),
            selection: selection,
            adapter: adapter,
            operationBindings: binanceSpotTestnetBindings()
        )
    }

    public static func resolve(
        operation: ReleaseV0190VenueProductRuntimeAdapterOperation,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws -> ReleaseV0190VenueProductRuntimeOperationBinding {
        let registration = try registration(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            accountProfileID: accountProfileID
        )
        return try registration.binding(for: operation)
    }

    public static func canonicalBinanceSpotTestnetProfileID() throws -> ReleaseV0181AccountProfileID {
        try ReleaseV0181AccountProfileID(
            ReleaseV0190VenueCredentialProfileEntry.expectedProfileID(
                pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
                tradingEnvironment: .testnet
            )
        )
    }

    private static func binanceSpotTestnetBindings() throws -> [ReleaseV0190VenueProductRuntimeOperationBinding] {
        [
            try ReleaseV0190VenueProductRuntimeOperationBinding(
                operation: .submit,
                legacyRuntimeTypeName: String(reflecting: ReleaseV0150BinanceSpotTestnetSubmitRuntime.self),
                existingRuntimeAnchor: "GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME"
            ),
            try ReleaseV0190VenueProductRuntimeOperationBinding(
                operation: .cancel,
                legacyRuntimeTypeName: String(reflecting: ReleaseV0150BinanceSpotTestnetCancelRuntime.self),
                existingRuntimeAnchor: "GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME"
            ),
            try ReleaseV0190VenueProductRuntimeOperationBinding(
                operation: .queryStatus,
                legacyRuntimeTypeName: String(reflecting: ReleaseV0160CLIOrderStatusQueryFlow.self),
                existingRuntimeAnchor: "GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY"
            )
        ]
    }

    private static func unsupportedReason(for target: ReleaseV0190VenueProductTarget) -> String {
        switch (target.venueID, target.productKind, target.tradingEnvironment) {
        case (.binance, .usdmFutures, _):
            return "\(target.namespaceKey): Binance USDⓈ-M Futures runtime is future-gated for a later issue"
        case (.okx, _, _):
            return "\(target.namespaceKey): OKX runtime is placeholder evidence only"
        case (_, _, .productionShadow):
            return "\(target.namespaceKey): productionShadow is reference evidence only"
        default:
            return "\(target.namespaceKey): no registered Binance Spot Testnet runtime path"
        }
    }
}
