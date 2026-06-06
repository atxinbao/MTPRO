import DomainModel
import Foundation

/// L4ExecutionClientVenueAdapterOperation 固定 GH-458 venue adapter 合同需要覆盖的操作族。
///
/// 这些 case 只定义 ExecutionClient/<venue> 未来要承接的外部交易所适配语义。当前 issue 不实现
/// submit / cancel / replace，不解析真实 execution report，也不记录 broker fill。
public enum L4ExecutionClientVenueAdapterOperation: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit = "submit"
    case cancel = "cancel"
    case replace = "replace"
    case statusQuery = "status / report query"
    case executionReportParsing = "execution report parsing"
    case brokerFillParsing = "broker fill parsing"
}

/// L4ExecutionClientVenueAdapterGate 描述 ExecutionClient venue contract 进入实现前的门禁。
///
/// Gate 只表达执行顺序和职责边界；sandbox submit / cancel / replace 只能由 GH-459 继续授权，
/// production venue 仍必须等 GH-471 cutover gate，不能由本合同默认打开。
public enum L4ExecutionClientVenueAdapterGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case githubFallbackQueueWIP1 = "GitHub fallback queue WIP=1"
    case l4CommandContractComplete = "GH-452 L4 command contract complete"
    case liveAccountReadModelComplete = "GH-457 live account read-model complete"
    case executionEngineHandoffRequired = "ExecutionEngine handoff required"
    case sandboxVenueGateRequired = "sandbox venue gate required"
    case productionVenueDisabledByDefault = "production venue disabled by default"
    case productionCutoverBlockedUntilGH471 = "production cutover blocked until GH-471"
    case noDirectTraderOrStrategyAccess = "no direct Trader / Strategy to ExecutionClient"
    case reportParsingContractOnly = "status / report parsing contract only"
}

/// L4ExecutionClientVenueAdapterForbiddenCapability 枚举 GH-458 仍必须保持关闭的能力。
///
/// 这些值可以作为后续 issue 的验收锚点，但当前不能变成 broker gateway、signed request、
/// real order lifecycle、OMS、Live PRO Console 或任何 production trading shortcut。
public enum L4ExecutionClientVenueAdapterForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case directStrategyToExecutionClient = "direct Strategy to ExecutionClient"
    case directTraderToExecutionClient = "direct Trader to ExecutionClient"
    case brokerGatewayImplementation = "broker gateway implementation"
    case signedRequestRuntime = "signed request runtime"
    case accountEndpointRuntime = "account endpoint runtime"
    case listenKeyRuntime = "listenKey runtime"
    case privateWebSocketRuntime = "private WebSocket runtime"
    case sandboxSubmitCancelReplaceRuntime = "sandbox submit / cancel / replace runtime"
    case productionVenueEnabled = "production venue enabled"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case executionReportRuntimeParser = "execution report runtime parser"
    case brokerFillRuntimeParser = "broker fill runtime parser"
    case omsImplementation = "OMS implementation"
    case reconciliationRuntime = "reconciliation runtime"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4ExecutionClientVenueOperationContract 是 GH-458 单个 venue operation 的职责拆分行。
///
/// `executionClientResponsibility` 只能描述外部 venue adapter contract；`executionEngineResponsibility`
/// 只能描述内部 lifecycle / handoff 协调。该行不包含任何 API request、broker payload 或可执行命令。
public struct L4ExecutionClientVenueOperationContract: Codable, Equatable, Sendable {
    public let operation: L4ExecutionClientVenueAdapterOperation
    public let executionClientResponsibility: String
    public let executionEngineResponsibility: String
    public let requiresExecutionEngineHandoff: Bool
    public let sandboxGateRequired: Bool
    public let productionGateRequired: Bool
    public let implementsRuntime: Bool

    public init(
        operation: L4ExecutionClientVenueAdapterOperation,
        executionClientResponsibility: String,
        executionEngineResponsibility: String,
        requiresExecutionEngineHandoff: Bool = true,
        sandboxGateRequired: Bool = true,
        productionGateRequired: Bool = true,
        implementsRuntime: Bool = false
    ) throws {
        guard executionClientResponsibility.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionClientResponsibility",
                expected: "non-empty ExecutionClient venue adapter responsibility",
                actual: "empty"
            )
        }
        guard executionEngineResponsibility.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionEngineResponsibility",
                expected: "non-empty ExecutionEngine lifecycle responsibility",
                actual: "empty"
            )
        }
        guard requiresExecutionEngineHandoff else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("requiresExecutionEngineHandoff")
        }
        guard sandboxGateRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("sandboxGateRequired")
        }
        guard productionGateRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionGateRequired")
        }
        guard implementsRuntime == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("implementsRuntime")
        }

        self.operation = operation
        self.executionClientResponsibility = executionClientResponsibility
        self.executionEngineResponsibility = executionEngineResponsibility
        self.requiresExecutionEngineHandoff = requiresExecutionEngineHandoff
        self.sandboxGateRequired = sandboxGateRequired
        self.productionGateRequired = productionGateRequired
        self.implementsRuntime = implementsRuntime
    }

    fileprivate init(
        trustedOperation operation: L4ExecutionClientVenueAdapterOperation,
        executionClientResponsibility: String,
        executionEngineResponsibility: String
    ) {
        self.operation = operation
        self.executionClientResponsibility = executionClientResponsibility
        self.executionEngineResponsibility = executionEngineResponsibility
        self.requiresExecutionEngineHandoff = true
        self.sandboxGateRequired = true
        self.productionGateRequired = true
        self.implementsRuntime = false
    }
}

/// L4ExecutionClientVenueAdapterContract 是 GH-458 的 ExecutionClient/<venue> contract。
///
/// 合同只定义“ExecutionClient 是外部 venue adapter，ExecutionEngine 是内部 lifecycle 协调者”的边界，
/// 并固定 sandbox venue / production venue gate、status/report parsing contract 和 Trader / Strategy
/// 不得直连 ExecutionClient 的规则。它不实现 broker gateway、真实订单、OMS 或 Live command surface。
public struct L4ExecutionClientVenueAdapterContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let maturitySlice: String
    public let operationContracts: [L4ExecutionClientVenueOperationContract]
    public let gates: [L4ExecutionClientVenueAdapterGate]
    public let forbiddenCapabilities: [L4ExecutionClientVenueAdapterForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let executionClientIsExternalVenueAdapter: Bool
    public let executionEngineIsInternalLifecycleCoordinator: Bool
    public let traderStrategyDirectAccessAllowed: Bool
    public let sandboxVenueGateRequired: Bool
    public let productionVenueGateRequired: Bool
    public let productionVenueEnabled: Bool
    public let implementsBrokerGateway: Bool
    public let implementsSignedRequestRuntime: Bool
    public let implementsAccountEndpointRuntime: Bool
    public let implementsListenKeyOrPrivateWebSocket: Bool
    public let implementsSandboxSubmitCancelReplace: Bool
    public let implementsRealSubmitCancelReplace: Bool
    public let implementsExecutionReportParser: Bool
    public let implementsBrokerFillParser: Bool
    public let implementsOMS: Bool
    public let performsReconciliation: Bool
    public let exposesLiveProConsoleCommandSurface: Bool
    public let exposesOrderForm: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-458"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-452", "GH-457"]
            && canonicalQueueRange == "GH-452..GH-472"
            && operationContracts == Self.requiredOperationContracts
            && gates == Self.requiredGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && executionClientIsExternalVenueAdapter
            && executionEngineIsInternalLifecycleCoordinator
            && traderStrategyDirectAccessAllowed == false
            && sandboxVenueGateRequired
            && productionVenueGateRequired
            && allForbiddenFlagsRemainClosed
    }

    public var operationCoverageHeld: Bool {
        Set(operationContracts.map(\.operation)) == Set(L4ExecutionClientVenueAdapterOperation.allCases)
            && operationContracts.allSatisfy(\.requiresExecutionEngineHandoff)
            && operationContracts.allSatisfy(\.sandboxGateRequired)
            && operationContracts.allSatisfy(\.productionGateRequired)
            && operationContracts.allSatisfy { $0.implementsRuntime == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionVenueEnabled,
            implementsBrokerGateway,
            implementsSignedRequestRuntime,
            implementsAccountEndpointRuntime,
            implementsListenKeyOrPrivateWebSocket,
            implementsSandboxSubmitCancelReplace,
            implementsRealSubmitCancelReplace,
            implementsExecutionReportParser,
            implementsBrokerFillParser,
            implementsOMS,
            performsReconciliation,
            exposesLiveProConsoleCommandSurface,
            exposesOrderForm
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-458-executionclient-venue-adapter-contract"),
        issueID: Identifier = Identifier.constant("GH-458"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-452"),
            Identifier.constant("GH-457")
        ],
        canonicalQueueRange: String = "GH-452..GH-472",
        maturitySlice: String = "MTPRO L4 Live Production / Trading Commands v1",
        operationContracts: [L4ExecutionClientVenueOperationContract] = Self.requiredOperationContracts,
        gates: [L4ExecutionClientVenueAdapterGate] = Self.requiredGates,
        forbiddenCapabilities: [L4ExecutionClientVenueAdapterForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        executionClientIsExternalVenueAdapter: Bool = true,
        executionEngineIsInternalLifecycleCoordinator: Bool = true,
        traderStrategyDirectAccessAllowed: Bool = false,
        sandboxVenueGateRequired: Bool = true,
        productionVenueGateRequired: Bool = true,
        productionVenueEnabled: Bool = false,
        implementsBrokerGateway: Bool = false,
        implementsSignedRequestRuntime: Bool = false,
        implementsAccountEndpointRuntime: Bool = false,
        implementsListenKeyOrPrivateWebSocket: Bool = false,
        implementsSandboxSubmitCancelReplace: Bool = false,
        implementsRealSubmitCancelReplace: Bool = false,
        implementsExecutionReportParser: Bool = false,
        implementsBrokerFillParser: Bool = false,
        implementsOMS: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveProConsoleCommandSurface: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-458" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-458",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-452", "GH-457"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-452,GH-457",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard operationContracts == Self.requiredOperationContracts else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "operationContracts",
                expected: L4ExecutionClientVenueAdapterOperation.allCases.map(\.rawValue).joined(separator: ","),
                actual: operationContracts.map { $0.operation.rawValue }.joined(separator: ",")
            )
        }
        guard gates == Self.requiredGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gates",
                expected: Self.requiredGates.map(\.rawValue).joined(separator: ","),
                actual: gates.map(\.rawValue).joined(separator: ",")
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
        guard executionClientIsExternalVenueAdapter else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("executionClientIsExternalVenueAdapter")
        }
        guard executionEngineIsInternalLifecycleCoordinator else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("executionEngineIsInternalLifecycleCoordinator")
        }
        guard traderStrategyDirectAccessAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("traderStrategyDirectAccessAllowed")
        }
        guard sandboxVenueGateRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("sandboxVenueGateRequired")
        }
        guard productionVenueGateRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionVenueGateRequired")
        }
        for forbiddenFlag in [
            ("productionVenueEnabled", productionVenueEnabled),
            ("implementsBrokerGateway", implementsBrokerGateway),
            ("implementsSignedRequestRuntime", implementsSignedRequestRuntime),
            ("implementsAccountEndpointRuntime", implementsAccountEndpointRuntime),
            ("implementsListenKeyOrPrivateWebSocket", implementsListenKeyOrPrivateWebSocket),
            ("implementsSandboxSubmitCancelReplace", implementsSandboxSubmitCancelReplace),
            ("implementsRealSubmitCancelReplace", implementsRealSubmitCancelReplace),
            ("implementsExecutionReportParser", implementsExecutionReportParser),
            ("implementsBrokerFillParser", implementsBrokerFillParser),
            ("implementsOMS", implementsOMS),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveProConsoleCommandSurface", exposesLiveProConsoleCommandSurface),
            ("exposesOrderForm", exposesOrderForm)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.maturitySlice = maturitySlice
        self.operationContracts = operationContracts
        self.gates = gates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.executionClientIsExternalVenueAdapter = executionClientIsExternalVenueAdapter
        self.executionEngineIsInternalLifecycleCoordinator = executionEngineIsInternalLifecycleCoordinator
        self.traderStrategyDirectAccessAllowed = traderStrategyDirectAccessAllowed
        self.sandboxVenueGateRequired = sandboxVenueGateRequired
        self.productionVenueGateRequired = productionVenueGateRequired
        self.productionVenueEnabled = productionVenueEnabled
        self.implementsBrokerGateway = implementsBrokerGateway
        self.implementsSignedRequestRuntime = implementsSignedRequestRuntime
        self.implementsAccountEndpointRuntime = implementsAccountEndpointRuntime
        self.implementsListenKeyOrPrivateWebSocket = implementsListenKeyOrPrivateWebSocket
        self.implementsSandboxSubmitCancelReplace = implementsSandboxSubmitCancelReplace
        self.implementsRealSubmitCancelReplace = implementsRealSubmitCancelReplace
        self.implementsExecutionReportParser = implementsExecutionReportParser
        self.implementsBrokerFillParser = implementsBrokerFillParser
        self.implementsOMS = implementsOMS
        self.performsReconciliation = performsReconciliation
        self.exposesLiveProConsoleCommandSurface = exposesLiveProConsoleCommandSurface
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> L4ExecutionClientVenueAdapterContract {
        try L4ExecutionClientVenueAdapterContract()
    }

    public static let requiredOperationContracts: [L4ExecutionClientVenueOperationContract] = [
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .submit,
            executionClientResponsibility: "map authorized ExecutionEngine order intent to sandbox venue submit request shape",
            executionEngineResponsibility: "own order lifecycle identity, risk-approved handoff, and local state coordination"
        ),
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .cancel,
            executionClientResponsibility: "map authorized ExecutionEngine cancel intent to sandbox venue cancel request shape",
            executionEngineResponsibility: "own cancel eligibility, local lifecycle transition, and audit evidence"
        ),
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .replace,
            executionClientResponsibility: "map authorized ExecutionEngine replace intent to sandbox venue replace request shape",
            executionEngineResponsibility: "own replace eligibility, local lifecycle transition, and audit evidence"
        ),
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .statusQuery,
            executionClientResponsibility: "map venue status/report query output into contract evidence",
            executionEngineResponsibility: "own internal lifecycle reconciliation input boundary without broker truth"
        ),
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .executionReportParsing,
            executionClientResponsibility: "define execution report parsing contract for sandbox venue evidence",
            executionEngineResponsibility: "consume parsed evidence only after OMS lifecycle gate"
        ),
        L4ExecutionClientVenueOperationContract(
            trustedOperation: .brokerFillParsing,
            executionClientResponsibility: "define broker fill parsing contract for sandbox venue evidence",
            executionEngineResponsibility: "consume broker fill evidence only through local lifecycle coordination"
        )
    ]

    public static let requiredGates = L4ExecutionClientVenueAdapterGate.allCases

    public static let requiredForbiddenCapabilities = L4ExecutionClientVenueAdapterForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT",
        "GH-458-EXECUTIONENGINE-INTERNAL-LIFECYCLE-BOUNDARY",
        "GH-458-SANDBOX-PRODUCTION-VENUE-GATE",
        "GH-458-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT",
        "TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT"
    ]

    public static let requiredValidationCommands = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
