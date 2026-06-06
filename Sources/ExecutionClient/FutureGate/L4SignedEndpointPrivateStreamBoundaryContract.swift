import DomainModel
import Foundation

/// L4SignedPrivateRuntimeKind 区分 GH-454 必须分开的三类未来能力。
///
/// signed read-only、private stream 和 command runtime 不能混成同一条捷径。当前 GH-454
/// 只定义分类边界，不实现签名、listenKey、WebSocket、账户读取或真实订单命令。
public enum L4SignedPrivateRuntimeKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedReadOnly = "signed read-only"
    case privateStream = "private stream"
    case commandRuntime = "command runtime"
}

/// L4SignedRequestCapabilityTaxonomy 固定 signed request 语义的分类。
///
/// 这些 case 只用于 boundary evidence。它们不是 request builder，不生成 HMAC，不添加
/// API-key header，也不调用 Binance 或其他 venue 的 signed endpoint。
public enum L4SignedRequestCapabilityTaxonomy: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialReference = "credential reference"
    case timestampIdentity = "timestamp identity"
    case recvWindowIdentity = "recvWindow identity"
    case apiKeyHeaderIdentity = "API-key header identity"
    case requestSignatureIdentity = "request signature identity"
    case signedAccountReadOnly = "signed account read-only"
    case listenKeyLifecycle = "listenKey lifecycle"
    case privateEventSource = "private event source"
    case commandRuntimeBoundary = "command runtime boundary"
}

/// L4PrivateStreamLifecycleGate 描述 listenKey / private WebSocket 的未来生命周期 gate。
///
/// Gate 只说明后续实现必须拆分 create / keepalive / open / close / event identity；
/// 当前 GH-454 不创建 listenKey，不启动 WebSocket，也不消费真实 private event。
public enum L4PrivateStreamLifecycleGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialEnvironmentGate = "credential / environment gate"
    case signedEndpointBoundary = "signed endpoint boundary"
    case listenKeyCreateFutureGate = "listenKey create future gate"
    case listenKeyKeepAliveFutureGate = "listenKey keep-alive future gate"
    case privateWebSocketOpenFutureGate = "private WebSocket open future gate"
    case privateWebSocketCloseFutureGate = "private WebSocket close future gate"
    case accountSnapshotSourceIdentity = "account snapshot source identity"
    case privateEventSourceIdentity = "private event source identity"
    case commandRuntimeIsolation = "command runtime isolation"
}

/// L4AccountPrivateEventSourceIdentity 固定账户快照和 private event 的来源身份。
///
/// Source identity 只能描述未来 evidence 来源，不能包含 real account payload、listenKey value、
/// signed request payload、broker payload、execution report payload 或订单命令。
public enum L4AccountPrivateEventSourceIdentity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedAccountSnapshot = "signed account snapshot source"
    case balanceUpdate = "private balance update source"
    case positionUpdate = "private position update source"
    case marginState = "private margin state source"
    case executionReport = "private execution report source"
    case listenKeySession = "listenKey session source"
}

/// L4SignedPrivateForbiddenCapability 枚举 GH-454 必须保持禁止的 endpoint / runtime path。
///
/// 这些值必须进入 deterministic tests 和 PR evidence，防止 boundary 定义阶段顺手打开
/// signed endpoint、private stream、command runtime、broker action 或 production trading。
public enum L4SignedPrivateForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialValueRead = "credential value read"
    case apiKeyHeaderConstruction = "API-key header construction"
    case requestSignatureGeneration = "request signature generation"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case listenKeyKeepAlive = "listenKey keep-alive"
    case listenKeyClose = "listenKey close"
    case privateWebSocketOpen = "private WebSocket open"
    case privateWebSocketReconnect = "private WebSocket reconnect"
    case realAccountSnapshotRead = "real account snapshot read"
    case realPrivateEventConsumption = "real private event consumption"
    case commandRuntime = "command runtime"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4SignedPrivateBoundaryEntry 是 GH-454 acceptance matrix 的单行。
///
/// 每行必须绑定 runtime kind、capability taxonomy、lifecycle gates、source identities、
/// 后续 issue anchor 和当前 forbidden capabilities。该结构不保存 payload，不访问网络。
public struct L4SignedPrivateBoundaryEntry: Codable, Equatable, Sendable {
    public let runtimeKind: L4SignedPrivateRuntimeKind
    public let capabilities: [L4SignedRequestCapabilityTaxonomy]
    public let lifecycleGates: [L4PrivateStreamLifecycleGate]
    public let sourceIdentities: [L4AccountPrivateEventSourceIdentity]
    public let issueAnchors: [String]
    public let forbiddenCapabilities: [L4SignedPrivateForbiddenCapability]

    public init(
        runtimeKind: L4SignedPrivateRuntimeKind,
        capabilities: [L4SignedRequestCapabilityTaxonomy],
        lifecycleGates: [L4PrivateStreamLifecycleGate],
        sourceIdentities: [L4AccountPrivateEventSourceIdentity],
        issueAnchors: [String],
        forbiddenCapabilities: [L4SignedPrivateForbiddenCapability]
    ) throws {
        guard capabilities.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "capabilities",
                expected: "non-empty signed/private capability taxonomy",
                actual: "empty"
            )
        }
        guard lifecycleGates.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lifecycleGates",
                expected: "non-empty private stream lifecycle gates",
                actual: "empty"
            )
        }
        guard issueAnchors.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueAnchors",
                expected: "non-empty GitHub issue anchors",
                actual: "empty"
            )
        }
        guard forbiddenCapabilities.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: "non-empty forbidden endpoint list",
                actual: "empty"
            )
        }

        self.runtimeKind = runtimeKind
        self.capabilities = capabilities
        self.lifecycleGates = lifecycleGates
        self.sourceIdentities = sourceIdentities
        self.issueAnchors = issueAnchors
        self.forbiddenCapabilities = forbiddenCapabilities
    }
}

/// L4SignedEndpointPrivateStreamBoundaryContract 是 GH-454 的 signed/private 边界合同。
///
/// 合同定义 signed request capability taxonomy、listenKey / private WebSocket future lifecycle、
/// account snapshot / private event source identity，以及 forbidden endpoint path。它依赖
/// GH-452 command contract 和 GH-453 credential environment gate，但不实现任何连接或 runtime。
public struct L4SignedEndpointPrivateStreamBoundaryContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let maturitySlice: String
    public let runtimeKinds: [L4SignedPrivateRuntimeKind]
    public let capabilityTaxonomy: [L4SignedRequestCapabilityTaxonomy]
    public let lifecycleGates: [L4PrivateStreamLifecycleGate]
    public let sourceIdentities: [L4AccountPrivateEventSourceIdentity]
    public let boundaryEntries: [L4SignedPrivateBoundaryEntry]
    public let forbiddenCapabilities: [L4SignedPrivateForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated: Bool
    public let futureImplementationContractRequired: Bool
    public let accountSnapshotSourceIdentityRequired: Bool
    public let privateEventSourceIdentityRequired: Bool
    public let credentialEnvironmentGateRequired: Bool
    public let productionDisabledByDefault: Bool
    public let readsCredentialValue: Bool
    public let constructsAPIKeyHeader: Bool
    public let generatesRequestSignature: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let keepsListenKeyAlive: Bool
    public let closesListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let reconnectsPrivateWebSocket: Bool
    public let readsRealAccountSnapshot: Bool
    public let consumesRealPrivateEvent: Bool
    public let implementsCommandRuntime: Bool
    public let implementsExecutionClientAdapter: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let productionTradingEnabledByDefault: Bool
    public let exposesLiveProConsoleCommandSurface: Bool
    public let exposesOrderForm: Bool

    public var contractHeld: Bool {
        upstreamIssueIDs.map(\.rawValue) == ["GH-452", "GH-453"]
            && runtimeKinds == Self.requiredRuntimeKinds
            && capabilityTaxonomy == Self.requiredCapabilityTaxonomy
            && lifecycleGates == Self.requiredLifecycleGates
            && sourceIdentities == Self.requiredSourceIdentities
            && boundaryEntries == Self.requiredBoundaryEntries
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated
            && futureImplementationContractRequired
            && accountSnapshotSourceIdentityRequired
            && privateEventSourceIdentityRequired
            && credentialEnvironmentGateRequired
            && productionDisabledByDefault
            && allForbiddenFlagsRemainClosed
    }

    public var boundaryCoverageHeld: Bool {
        Set(boundaryEntries.map(\.runtimeKind)) == Set(L4SignedPrivateRuntimeKind.allCases)
            && Set(boundaryEntries.flatMap(\.capabilities)) == Set(L4SignedRequestCapabilityTaxonomy.allCases)
            && Set(boundaryEntries.flatMap(\.lifecycleGates)) == Set(L4PrivateStreamLifecycleGate.allCases)
            && Set(boundaryEntries.flatMap(\.sourceIdentities)) == Set(L4AccountPrivateEventSourceIdentity.allCases)
            && boundaryEntries.allSatisfy { $0.forbiddenCapabilities.isEmpty == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            readsCredentialValue,
            constructsAPIKeyHeader,
            generatesRequestSignature,
            callsSignedEndpoint,
            callsAccountEndpoint,
            createsListenKey,
            keepsListenKeyAlive,
            closesListenKey,
            opensPrivateWebSocket,
            reconnectsPrivateWebSocket,
            readsRealAccountSnapshot,
            consumesRealPrivateEvent,
            implementsCommandRuntime,
            implementsExecutionClientAdapter,
            implementsOMS,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            productionTradingEnabledByDefault,
            exposesLiveProConsoleCommandSurface,
            exposesOrderForm
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-454-l4-signed-endpoint-private-stream-boundary"),
        issueID: Identifier = Identifier.constant("GH-454"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-452"),
            Identifier.constant("GH-453")
        ],
        canonicalQueueRange: String = "GH-452..GH-472",
        maturitySlice: String = "MTPRO L4 Live Production / Trading Commands v1",
        runtimeKinds: [L4SignedPrivateRuntimeKind] = Self.requiredRuntimeKinds,
        capabilityTaxonomy: [L4SignedRequestCapabilityTaxonomy] = Self.requiredCapabilityTaxonomy,
        lifecycleGates: [L4PrivateStreamLifecycleGate] = Self.requiredLifecycleGates,
        sourceIdentities: [L4AccountPrivateEventSourceIdentity] = Self.requiredSourceIdentities,
        boundaryEntries: [L4SignedPrivateBoundaryEntry] = Self.requiredBoundaryEntries,
        forbiddenCapabilities: [L4SignedPrivateForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated: Bool = true,
        futureImplementationContractRequired: Bool = true,
        accountSnapshotSourceIdentityRequired: Bool = true,
        privateEventSourceIdentityRequired: Bool = true,
        credentialEnvironmentGateRequired: Bool = true,
        productionDisabledByDefault: Bool = true,
        readsCredentialValue: Bool = false,
        constructsAPIKeyHeader: Bool = false,
        generatesRequestSignature: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        keepsListenKeyAlive: Bool = false,
        closesListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        reconnectsPrivateWebSocket: Bool = false,
        readsRealAccountSnapshot: Bool = false,
        consumesRealPrivateEvent: Bool = false,
        implementsCommandRuntime: Bool = false,
        implementsExecutionClientAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        exposesLiveProConsoleCommandSurface: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        try Self.validate(
            runtimeKinds: runtimeKinds,
            capabilityTaxonomy: capabilityTaxonomy,
            lifecycleGates: lifecycleGates,
            sourceIdentities: sourceIdentities,
            boundaryEntries: boundaryEntries,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredGates(
            signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated: signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated,
            futureImplementationContractRequired: futureImplementationContractRequired,
            accountSnapshotSourceIdentityRequired: accountSnapshotSourceIdentityRequired,
            privateEventSourceIdentityRequired: privateEventSourceIdentityRequired,
            credentialEnvironmentGateRequired: credentialEnvironmentGateRequired,
            productionDisabledByDefault: productionDisabledByDefault
        )
        try Self.validateForbiddenFlags(
            readsCredentialValue: readsCredentialValue,
            constructsAPIKeyHeader: constructsAPIKeyHeader,
            generatesRequestSignature: generatesRequestSignature,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            keepsListenKeyAlive: keepsListenKeyAlive,
            closesListenKey: closesListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            reconnectsPrivateWebSocket: reconnectsPrivateWebSocket,
            readsRealAccountSnapshot: readsRealAccountSnapshot,
            consumesRealPrivateEvent: consumesRealPrivateEvent,
            implementsCommandRuntime: implementsCommandRuntime,
            implementsExecutionClientAdapter: implementsExecutionClientAdapter,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            exposesLiveProConsoleCommandSurface: exposesLiveProConsoleCommandSurface,
            exposesOrderForm: exposesOrderForm
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.maturitySlice = maturitySlice
        self.runtimeKinds = runtimeKinds
        self.capabilityTaxonomy = capabilityTaxonomy
        self.lifecycleGates = lifecycleGates
        self.sourceIdentities = sourceIdentities
        self.boundaryEntries = boundaryEntries
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated =
            signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated
        self.futureImplementationContractRequired = futureImplementationContractRequired
        self.accountSnapshotSourceIdentityRequired = accountSnapshotSourceIdentityRequired
        self.privateEventSourceIdentityRequired = privateEventSourceIdentityRequired
        self.credentialEnvironmentGateRequired = credentialEnvironmentGateRequired
        self.productionDisabledByDefault = productionDisabledByDefault
        self.readsCredentialValue = readsCredentialValue
        self.constructsAPIKeyHeader = constructsAPIKeyHeader
        self.generatesRequestSignature = generatesRequestSignature
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.keepsListenKeyAlive = keepsListenKeyAlive
        self.closesListenKey = closesListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.reconnectsPrivateWebSocket = reconnectsPrivateWebSocket
        self.readsRealAccountSnapshot = readsRealAccountSnapshot
        self.consumesRealPrivateEvent = consumesRealPrivateEvent
        self.implementsCommandRuntime = implementsCommandRuntime
        self.implementsExecutionClientAdapter = implementsExecutionClientAdapter
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.exposesLiveProConsoleCommandSurface = exposesLiveProConsoleCommandSurface
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> L4SignedEndpointPrivateStreamBoundaryContract {
        try L4SignedEndpointPrivateStreamBoundaryContract()
    }

    public static let requiredRuntimeKinds: [L4SignedPrivateRuntimeKind] =
        L4SignedPrivateRuntimeKind.allCases

    public static let requiredCapabilityTaxonomy: [L4SignedRequestCapabilityTaxonomy] =
        L4SignedRequestCapabilityTaxonomy.allCases

    public static let requiredLifecycleGates: [L4PrivateStreamLifecycleGate] =
        L4PrivateStreamLifecycleGate.allCases

    public static let requiredSourceIdentities: [L4AccountPrivateEventSourceIdentity] =
        L4AccountPrivateEventSourceIdentity.allCases

    public static let requiredForbiddenCapabilities: [L4SignedPrivateForbiddenCapability] =
        L4SignedPrivateForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY",
        "GH-454-SIGNED-REQUEST-CAPABILITY-TAXONOMY",
        "GH-454-LISTENKEY-PRIVATE-WEBSOCKET-FUTURE-CONTRACT",
        "GH-454-ACCOUNT-SNAPSHOT-PRIVATE-EVENT-SOURCE-IDENTITY",
        "GH-454-FORBIDDEN-ENDPOINT-PATHS",
        "GH-454-NON-AUTHORIZATION",
        "TVM-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY"
    ]

    public static let requiredValidationCommands: [String] = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredBoundaryEntries: [L4SignedPrivateBoundaryEntry] = {
        do {
            return try [
                L4SignedPrivateBoundaryEntry(
                    runtimeKind: .signedReadOnly,
                    capabilities: [
                        .credentialReference,
                        .timestampIdentity,
                        .recvWindowIdentity,
                        .apiKeyHeaderIdentity,
                        .requestSignatureIdentity,
                        .signedAccountReadOnly
                    ],
                    lifecycleGates: [.credentialEnvironmentGate, .signedEndpointBoundary],
                    sourceIdentities: [.signedAccountSnapshot],
                    issueAnchors: ["GH-454", "GH-455", "GH-457"],
                    forbiddenCapabilities: [
                        .credentialValueRead,
                        .apiKeyHeaderConstruction,
                        .requestSignatureGeneration,
                        .signedEndpointCall,
                        .accountEndpointCall,
                        .realAccountSnapshotRead
                    ]
                ),
                L4SignedPrivateBoundaryEntry(
                    runtimeKind: .privateStream,
                    capabilities: [
                        .listenKeyLifecycle,
                        .privateEventSource
                    ],
                    lifecycleGates: [
                        .credentialEnvironmentGate,
                        .signedEndpointBoundary,
                        .listenKeyCreateFutureGate,
                        .listenKeyKeepAliveFutureGate,
                        .privateWebSocketOpenFutureGate,
                        .privateWebSocketCloseFutureGate,
                        .accountSnapshotSourceIdentity,
                        .privateEventSourceIdentity
                    ],
                    sourceIdentities: [
                        .balanceUpdate,
                        .positionUpdate,
                        .marginState,
                        .executionReport,
                        .listenKeySession
                    ],
                    issueAnchors: ["GH-454", "GH-456", "GH-457"],
                    forbiddenCapabilities: [
                        .listenKeyCreation,
                        .listenKeyKeepAlive,
                        .listenKeyClose,
                        .privateWebSocketOpen,
                        .privateWebSocketReconnect,
                        .realPrivateEventConsumption
                    ]
                ),
                L4SignedPrivateBoundaryEntry(
                    runtimeKind: .commandRuntime,
                    capabilities: [.commandRuntimeBoundary],
                    lifecycleGates: [.commandRuntimeIsolation],
                    sourceIdentities: [],
                    issueAnchors: ["GH-458", "GH-459", "GH-461", "GH-463", "GH-469"],
                    forbiddenCapabilities: [
                        .commandRuntime,
                        .executionClientAdapterImplementation,
                        .omsImplementation,
                        .realSubmitCancelReplace,
                        .productionTradingEnabledByDefault,
                        .liveProConsoleCommandSurface,
                        .orderForm
                    ]
                )
            ]
        } catch {
            preconditionFailure("GH-454 signed/private boundary entries must be valid: \(error)")
        }
    }()

    private static func validate(
        runtimeKinds: [L4SignedPrivateRuntimeKind],
        capabilityTaxonomy: [L4SignedRequestCapabilityTaxonomy],
        lifecycleGates: [L4PrivateStreamLifecycleGate],
        sourceIdentities: [L4AccountPrivateEventSourceIdentity],
        boundaryEntries: [L4SignedPrivateBoundaryEntry],
        forbiddenCapabilities: [L4SignedPrivateForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard runtimeKinds == Self.requiredRuntimeKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runtimeKinds",
                expected: Self.requiredRuntimeKinds.map(\.rawValue).joined(separator: ","),
                actual: runtimeKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard capabilityTaxonomy == Self.requiredCapabilityTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "capabilityTaxonomy",
                expected: Self.requiredCapabilityTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: capabilityTaxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard lifecycleGates == Self.requiredLifecycleGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lifecycleGates",
                expected: Self.requiredLifecycleGates.map(\.rawValue).joined(separator: ","),
                actual: lifecycleGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceIdentities == Self.requiredSourceIdentities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentities",
                expected: Self.requiredSourceIdentities.map(\.rawValue).joined(separator: ","),
                actual: sourceIdentities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard boundaryEntries == Self.requiredBoundaryEntries else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "boundaryEntries",
                expected: "GH-454 required signed/private boundary entries",
                actual: "\(boundaryEntries.map(\.runtimeKind.rawValue))"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
    }

    private static func validateRequiredGates(
        signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated: Bool,
        futureImplementationContractRequired: Bool,
        accountSnapshotSourceIdentityRequired: Bool,
        privateEventSourceIdentityRequired: Bool,
        credentialEnvironmentGateRequired: Bool,
        productionDisabledByDefault: Bool
    ) throws {
        for requiredGate in [
            (
                "signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated",
                signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated
            ),
            ("futureImplementationContractRequired", futureImplementationContractRequired),
            ("accountSnapshotSourceIdentityRequired", accountSnapshotSourceIdentityRequired),
            ("privateEventSourceIdentityRequired", privateEventSourceIdentityRequired),
            ("credentialEnvironmentGateRequired", credentialEnvironmentGateRequired),
            ("productionDisabledByDefault", productionDisabledByDefault)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredGate.0,
                expected: "true",
                actual: "false"
            )
        }
    }

    private static func validateForbiddenFlags(
        readsCredentialValue: Bool,
        constructsAPIKeyHeader: Bool,
        generatesRequestSignature: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        keepsListenKeyAlive: Bool,
        closesListenKey: Bool,
        opensPrivateWebSocket: Bool,
        reconnectsPrivateWebSocket: Bool,
        readsRealAccountSnapshot: Bool,
        consumesRealPrivateEvent: Bool,
        implementsCommandRuntime: Bool,
        implementsExecutionClientAdapter: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        productionTradingEnabledByDefault: Bool,
        exposesLiveProConsoleCommandSurface: Bool,
        exposesOrderForm: Bool
    ) throws {
        for forbiddenFlag in [
            ("readsCredentialValue", readsCredentialValue),
            ("constructsAPIKeyHeader", constructsAPIKeyHeader),
            ("generatesRequestSignature", generatesRequestSignature),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("keepsListenKeyAlive", keepsListenKeyAlive),
            ("closesListenKey", closesListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("reconnectsPrivateWebSocket", reconnectsPrivateWebSocket),
            ("readsRealAccountSnapshot", readsRealAccountSnapshot),
            ("consumesRealPrivateEvent", consumesRealPrivateEvent),
            ("implementsCommandRuntime", implementsCommandRuntime),
            ("implementsExecutionClientAdapter", implementsExecutionClientAdapter),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("exposesLiveProConsoleCommandSurface", exposesLiveProConsoleCommandSurface),
            ("exposesOrderForm", exposesOrderForm)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }
    }
}
