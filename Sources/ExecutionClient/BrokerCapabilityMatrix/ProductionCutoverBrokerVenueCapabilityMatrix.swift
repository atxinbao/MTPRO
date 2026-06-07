import DomainModel
import Foundation

/// ProductionCutoverBrokerCapabilityDomain 固定 GH-505 broker / venue matrix 需要覆盖的能力域。
///
/// 这些 domain 只是 readiness matrix 字段；它们不创建 broker adapter、不调用 endpoint、
/// 不解析 production report，也不实现 real order lifecycle。
public enum ProductionCutoverBrokerCapabilityDomain: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicData = "public data"
    case signedTrading = "signed trading"
    case accountRead = "account read"
    case privateStream = "private stream"
    case orderLifecycle = "order lifecycle"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case reconciliation = "reconciliation"
}

/// ProductionCutoverBrokerCapabilityState 是 GH-505 的 matrix state taxonomy。
public enum ProductionCutoverBrokerCapabilityState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case unsupported = "unsupported"
    case blocked = "blocked"
    case dryRunOnly = "dry-run-only"
    case futureGated = "future-gated"
}

/// ProductionCutoverBrokerVenueForbiddenCapability 枚举 matrix 不能触发的实现能力。
public enum ProductionCutoverBrokerVenueForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case brokerSelectionAsExecutionAuthorization = "broker selection as execution authorization"
    case brokerAdapterImplementation = "broker adapter implementation"
    case brokerConnection = "broker connection"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case privateWebSocketOpen = "private WebSocket open"
    case realOrderLifecycle = "real order lifecycle"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case executionReportParser = "execution report parser"
    case brokerFillParser = "broker fill parser"
    case reconciliationRuntime = "reconciliation runtime"
}

/// ProductionCutoverBrokerVenueCapabilityRow 是 GH-505 的单行 broker / venue readiness evidence。
///
/// Row 必须绑定 GH-503 credential policy gate 和 GH-504 environment isolation gate。任何 adapter、
/// endpoint、broker connection 或真实订单能力都会被拒绝。
public struct ProductionCutoverBrokerVenueCapabilityRow: Codable, Equatable, Sendable {
    public let domain: ProductionCutoverBrokerCapabilityDomain
    public let state: ProductionCutoverBrokerCapabilityState
    public let evidence: String
    public let requiresCredentialPolicyGate: Bool
    public let requiresEnvironmentIsolationGate: Bool
    public let implementsAdapter: Bool
    public let connectsBroker: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let submitsRealOrder: Bool

    public init(
        domain: ProductionCutoverBrokerCapabilityDomain,
        state: ProductionCutoverBrokerCapabilityState,
        evidence: String,
        requiresCredentialPolicyGate: Bool = true,
        requiresEnvironmentIsolationGate: Bool = true,
        implementsAdapter: Bool = false,
        connectsBroker: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard evidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidence",
                expected: "non-empty broker venue capability evidence",
                actual: "empty"
            )
        }
        guard requiresCredentialPolicyGate else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiresCredentialPolicyGate",
                expected: "true",
                actual: "false"
            )
        }
        guard requiresEnvironmentIsolationGate else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiresEnvironmentIsolationGate",
                expected: "true",
                actual: "false"
            )
        }
        for (field, value) in [
            ("implementsAdapter", implementsAdapter),
            ("connectsBroker", connectsBroker),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("submitsRealOrder", submitsRealOrder)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }

        self.domain = domain
        self.state = state
        self.evidence = evidence
        self.requiresCredentialPolicyGate = requiresCredentialPolicyGate
        self.requiresEnvironmentIsolationGate = requiresEnvironmentIsolationGate
        self.implementsAdapter = implementsAdapter
        self.connectsBroker = connectsBroker
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.submitsRealOrder = submitsRealOrder
    }
}

/// ProductionCutoverBrokerVenueCapabilityMatrix 是 GH-505 的 broker / venue readiness matrix。
///
/// Matrix 表达候选 broker / venue 的 capability、限制和 future gate。它不选择真实生产 broker
/// 作为执行授权，不实现 broker adapter，不连接 exchange / broker，不接 signed/account endpoint。
public struct ProductionCutoverBrokerVenueCapabilityMatrix: Codable, Equatable, Sendable {
    public let matrixID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let projectName: String
    public let canonicalQueueRange: String
    public let rows: [ProductionCutoverBrokerVenueCapabilityRow]
    public let states: [ProductionCutoverBrokerCapabilityState]
    public let forbiddenCapabilities: [ProductionCutoverBrokerVenueForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let brokerSelectionIsExecutionAuthorization: Bool
    public let credentialPolicyGateRequired: Bool
    public let environmentIsolationGateRequired: Bool
    public let readinessMatrixOnly: Bool
    public let implementsBrokerAdapter: Bool
    public let connectsBroker: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let parsesExecutionReport: Bool
    public let parsesBrokerFill: Bool
    public let performsReconciliation: Bool

    public var matrixHeld: Bool {
        issueID.rawValue == "GH-505"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-503", "GH-504"]
            && projectName == ProductionCutoverCredentialSecretPolicyGate.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && rows == Self.requiredRows
            && states == ProductionCutoverBrokerCapabilityState.allCases
            && forbiddenCapabilities == ProductionCutoverBrokerVenueForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands
            && brokerSelectionIsExecutionAuthorization == false
            && credentialPolicyGateRequired
            && environmentIsolationGateRequired
            && readinessMatrixOnly
            && allForbiddenFlagsRemainClosed
    }

    public var domainCoverageHeld: Bool {
        Set(rows.map(\.domain)) == Set(ProductionCutoverBrokerCapabilityDomain.allCases)
            && rows.allSatisfy(\.requiresCredentialPolicyGate)
            && rows.allSatisfy(\.requiresEnvironmentIsolationGate)
            && rows.allSatisfy { $0.implementsAdapter == false }
            && rows.allSatisfy { $0.connectsBroker == false }
            && rows.allSatisfy { $0.submitsRealOrder == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsBrokerAdapter,
            connectsBroker,
            callsSignedEndpoint,
            callsAccountEndpoint,
            createsListenKey,
            opensPrivateWebSocket,
            implementsRealOrderLifecycle,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            parsesExecutionReport,
            parsesBrokerFill,
            performsReconciliation
        ].allSatisfy { $0 == false }
    }

    public init(
        matrixID: Identifier = Identifier.constant("gh-505-production-broker-venue-capability-matrix"),
        issueID: Identifier = Identifier.constant("GH-505"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-503"), Identifier.constant("GH-504")],
        projectName: String = ProductionCutoverCredentialSecretPolicyGate.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        rows: [ProductionCutoverBrokerVenueCapabilityRow] = Self.requiredRows,
        states: [ProductionCutoverBrokerCapabilityState] = ProductionCutoverBrokerCapabilityState.allCases,
        forbiddenCapabilities: [ProductionCutoverBrokerVenueForbiddenCapability] =
            ProductionCutoverBrokerVenueForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
        brokerSelectionIsExecutionAuthorization: Bool = false,
        credentialPolicyGateRequired: Bool = true,
        environmentIsolationGateRequired: Bool = true,
        readinessMatrixOnly: Bool = true,
        implementsBrokerAdapter: Bool = false,
        connectsBroker: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        parsesExecutionReport: Bool = false,
        parsesBrokerFill: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            rows: rows,
            states: states,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            brokerSelectionIsExecutionAuthorization: brokerSelectionIsExecutionAuthorization,
            credentialPolicyGateRequired: credentialPolicyGateRequired,
            environmentIsolationGateRequired: environmentIsolationGateRequired,
            readinessMatrixOnly: readinessMatrixOnly
        )
        try Self.validateForbiddenFlags(
            implementsBrokerAdapter: implementsBrokerAdapter,
            connectsBroker: connectsBroker,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            parsesExecutionReport: parsesExecutionReport,
            parsesBrokerFill: parsesBrokerFill,
            performsReconciliation: performsReconciliation
        )

        self.matrixID = matrixID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.rows = rows
        self.states = states
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.brokerSelectionIsExecutionAuthorization = brokerSelectionIsExecutionAuthorization
        self.credentialPolicyGateRequired = credentialPolicyGateRequired
        self.environmentIsolationGateRequired = environmentIsolationGateRequired
        self.readinessMatrixOnly = readinessMatrixOnly
        self.implementsBrokerAdapter = implementsBrokerAdapter
        self.connectsBroker = connectsBroker
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.parsesExecutionReport = parsesExecutionReport
        self.parsesBrokerFill = parsesBrokerFill
        self.performsReconciliation = performsReconciliation
    }

    public static func deterministicFixture() throws -> ProductionCutoverBrokerVenueCapabilityMatrix {
        try ProductionCutoverBrokerVenueCapabilityMatrix()
    }

    public static let requiredValidationAnchors = [
        "GH-505-BROKER-VENUE-CAPABILITY-MATRIX",
        "GH-505-CAPABILITY-TAXONOMY",
        "GH-505-BROKER-SELECTION-EVIDENCE-BINDS-GH503-GH504",
        "GH-505-NO-BROKER-ADAPTER-IMPLEMENTATION",
        "GH-505-NO-REAL-ENDPOINT-OR-ORDER-CAPABILITY"
    ]

    public static let requiredRows: [ProductionCutoverBrokerVenueCapabilityRow] = {
        do {
            return [
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .publicData,
                    state: .dryRunOnly,
                    evidence: "public data remains dry-run evidence and not broker enablement"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .signedTrading,
                    state: .futureGated,
                    evidence: "signed trading remains future-gated behind credential and environment gates"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .accountRead,
                    state: .futureGated,
                    evidence: "account read remains future-gated and cannot call account endpoint"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .privateStream,
                    state: .futureGated,
                    evidence: "private stream remains future-gated and cannot create listenKey"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .orderLifecycle,
                    state: .blocked,
                    evidence: "real order lifecycle is blocked before production cutover"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .executionReport,
                    state: .futureGated,
                    evidence: "execution report parser remains future-gated"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .brokerFill,
                    state: .futureGated,
                    evidence: "broker fill parser remains future-gated"
                ),
                try ProductionCutoverBrokerVenueCapabilityRow(
                    domain: .reconciliation,
                    state: .futureGated,
                    evidence: "reconciliation runtime remains future-gated"
                )
            ]
        } catch {
            preconditionFailure("GH-505 deterministic broker venue capability rows must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverBrokerVenueCapabilityMatrix {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        rows: [ProductionCutoverBrokerVenueCapabilityRow],
        states: [ProductionCutoverBrokerCapabilityState],
        forbiddenCapabilities: [ProductionCutoverBrokerVenueForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-503", "GH-504"],
                "GH-503,GH-504",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "rows",
                rows == requiredRows,
                "GH-505 required broker venue capability rows",
                rows.map(\.domain.rawValue).joined(separator: ",")
            ),
            (
                "states",
                states == ProductionCutoverBrokerCapabilityState.allCases,
                ProductionCutoverBrokerCapabilityState.allCases.map(\.rawValue).joined(separator: ","),
                states.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ProductionCutoverBrokerVenueForbiddenCapability.allCases,
                ProductionCutoverBrokerVenueForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
                ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredFlags(
        brokerSelectionIsExecutionAuthorization: Bool,
        credentialPolicyGateRequired: Bool,
        environmentIsolationGateRequired: Bool,
        readinessMatrixOnly: Bool
    ) throws {
        guard brokerSelectionIsExecutionAuthorization == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("brokerSelectionIsExecutionAuthorization")
        }
        for (field, value) in [
            ("credentialPolicyGateRequired", credentialPolicyGateRequired),
            ("environmentIsolationGateRequired", environmentIsolationGateRequired),
            ("readinessMatrixOnly", readinessMatrixOnly)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        implementsBrokerAdapter: Bool,
        connectsBroker: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        implementsRealOrderLifecycle: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        parsesExecutionReport: Bool,
        parsesBrokerFill: Bool,
        performsReconciliation: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsBrokerAdapter", implementsBrokerAdapter),
            ("connectsBroker", connectsBroker),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("parsesExecutionReport", parsesExecutionReport),
            ("parsesBrokerFill", parsesBrokerFill),
            ("performsReconciliation", performsReconciliation)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
