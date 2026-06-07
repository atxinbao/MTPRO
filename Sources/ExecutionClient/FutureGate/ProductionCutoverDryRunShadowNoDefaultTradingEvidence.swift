import DomainModel
import Foundation

/// ProductionCutoverDryRunProofMode 固定 GH-509 允许证明的执行模式。
///
/// 这些 mode 只用于 no-default-trading evidence。它们不连接 broker、不读取 secret、不创建
/// signed/account endpoint request，也不把 sandbox / dry-run / shadow 升级为 production command。
public enum ProductionCutoverDryRunProofMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandbox
    case dryRun = "dry-run"
    case shadow
    case productionBlocked = "production blocked"
}

/// ProductionCutoverDryRunEvidenceSurface 固定 GH-509 可以展示 evidence 的只读 surface。
public enum ProductionCutoverDryRunEvidenceSurface: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case report = "Report"
    case dashboard = "Dashboard"
    case events = "Events"
}

/// ProductionCutoverDryRunForbiddenCapability 枚举 GH-509 必须继续关闭的能力。
public enum ProductionCutoverDryRunForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionExecution = "production execution"
    case realBrokerShadowTrading = "real broker shadow trading"
    case brokerConnection = "broker connection"
    case secretRead = "secret read"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case privateWebSocketOpen = "private WebSocket open"
    case sandboxCommandPromotesProductionCommand = "sandbox command promotes production command"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveCommandSurface = "live command surface"
    case tradingButton = "trading button"
    case orderForm = "order form"
}

/// ProductionCutoverDryRunProofEvidence 是 GH-509 的 dry-run / shadow proof row。
///
/// Row 只能证明 sandbox、dry-run、shadow 和 production-blocked 的隔离。任何 broker connection、
/// secret read、endpoint call、真实订单或 UI command surface 都会被拒绝。
public struct ProductionCutoverDryRunProofEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let mode: ProductionCutoverDryRunProofMode
    public let expectedEvidence: String
    public let blockedReason: String
    public let noDefaultTradingHeld: Bool
    public let readModelOnlySurface: Bool
    public let connectsBroker: Bool
    public let readsSecretValue: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let submitsRealOrder: Bool
    public let promotesSandboxCommandToProduction: Bool

    public init(
        evidenceID: Identifier,
        mode: ProductionCutoverDryRunProofMode,
        expectedEvidence: String,
        blockedReason: String,
        noDefaultTradingHeld: Bool = true,
        readModelOnlySurface: Bool = true,
        connectsBroker: Bool = false,
        readsSecretValue: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        submitsRealOrder: Bool = false,
        promotesSandboxCommandToProduction: Bool = false
    ) throws {
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty dry-run proof evidence",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty dry-run proof blocked reason",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("noDefaultTradingHeld", noDefaultTradingHeld),
            ("readModelOnlySurface", readModelOnlySurface)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("connectsBroker", connectsBroker),
            ("readsSecretValue", readsSecretValue),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("submitsRealOrder", submitsRealOrder),
            ("promotesSandboxCommandToProduction", promotesSandboxCommandToProduction)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.mode = mode
        self.expectedEvidence = expectedEvidence
        self.blockedReason = blockedReason
        self.noDefaultTradingHeld = noDefaultTradingHeld
        self.readModelOnlySurface = readModelOnlySurface
        self.connectsBroker = connectsBroker
        self.readsSecretValue = readsSecretValue
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.submitsRealOrder = submitsRealOrder
        self.promotesSandboxCommandToProduction = promotesSandboxCommandToProduction
    }
}

/// ProductionCutoverDryRunShadowNoDefaultTradingEvidence 是 GH-509 的 no-default-trading proof。
///
/// Gate 只证明 production cutover 前默认路径仍然 blocked / dry-run。Report、Dashboard 和 Events
/// 只能消费 read-model-only evidence；它不实现 production execution、真实 broker shadow trading 或 UI command。
public struct ProductionCutoverDryRunShadowNoDefaultTradingEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let projectName: String
    public let canonicalQueueRange: String
    public let modes: [ProductionCutoverDryRunProofMode]
    public let surfaces: [ProductionCutoverDryRunEvidenceSurface]
    public let forbiddenCapabilities: [ProductionCutoverDryRunForbiddenCapability]
    public let proofEvidence: [ProductionCutoverDryRunProofEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let manualApprovalGateRequired: Bool
    public let incidentRollbackNoTradeGateRequired: Bool
    public let capitalRiskLimitGateRequired: Bool
    public let noDefaultTradingRequired: Bool
    public let reportSurfaceReadModelOnly: Bool
    public let dashboardSurfaceReadModelOnly: Bool
    public let eventsSurfaceReadModelOnly: Bool
    public let implementsProductionExecution: Bool
    public let implementsRealBrokerShadowTrading: Bool
    public let connectsBroker: Bool
    public let readsSecretValue: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let sandboxCommandPromotesProductionCommand: Bool
    public let productionTradingEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let exposesLiveCommandSurface: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-509"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-506", "GH-507", "GH-508"]
            && projectName == ProductionCutoverCredentialSecretPolicyGate.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && modes == ProductionCutoverDryRunProofMode.allCases
            && surfaces == ProductionCutoverDryRunEvidenceSurface.allCases
            && forbiddenCapabilities == ProductionCutoverDryRunForbiddenCapability.allCases
            && proofEvidence == Self.requiredProofEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands
            && manualApprovalGateRequired
            && incidentRollbackNoTradeGateRequired
            && capitalRiskLimitGateRequired
            && noDefaultTradingRequired
            && reportSurfaceReadModelOnly
            && dashboardSurfaceReadModelOnly
            && eventsSurfaceReadModelOnly
            && allForbiddenFlagsRemainClosed
    }

    public var proofCoverageHeld: Bool {
        Set(proofEvidence.map(\.mode)) == Set(ProductionCutoverDryRunProofMode.allCases)
            && proofEvidence.allSatisfy(\.noDefaultTradingHeld)
            && proofEvidence.allSatisfy(\.readModelOnlySurface)
            && proofEvidence.allSatisfy { $0.promotesSandboxCommandToProduction == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsProductionExecution,
            implementsRealBrokerShadowTrading,
            connectsBroker,
            readsSecretValue,
            callsSignedEndpoint,
            callsAccountEndpoint,
            createsListenKey,
            opensPrivateWebSocket,
            sandboxCommandPromotesProductionCommand,
            productionTradingEnabledByDefault,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            exposesLiveCommandSurface,
            exposesTradingButton,
            exposesOrderForm
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-509-production-cutover-dry-run-shadow-no-default-trading"),
        issueID: Identifier = Identifier.constant("GH-509"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-506"),
            Identifier.constant("GH-507"),
            Identifier.constant("GH-508")
        ],
        projectName: String = ProductionCutoverCredentialSecretPolicyGate.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        modes: [ProductionCutoverDryRunProofMode] = ProductionCutoverDryRunProofMode.allCases,
        surfaces: [ProductionCutoverDryRunEvidenceSurface] = ProductionCutoverDryRunEvidenceSurface.allCases,
        forbiddenCapabilities: [ProductionCutoverDryRunForbiddenCapability] =
            ProductionCutoverDryRunForbiddenCapability.allCases,
        proofEvidence: [ProductionCutoverDryRunProofEvidence] = Self.requiredProofEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
        manualApprovalGateRequired: Bool = true,
        incidentRollbackNoTradeGateRequired: Bool = true,
        capitalRiskLimitGateRequired: Bool = true,
        noDefaultTradingRequired: Bool = true,
        reportSurfaceReadModelOnly: Bool = true,
        dashboardSurfaceReadModelOnly: Bool = true,
        eventsSurfaceReadModelOnly: Bool = true,
        implementsProductionExecution: Bool = false,
        implementsRealBrokerShadowTrading: Bool = false,
        connectsBroker: Bool = false,
        readsSecretValue: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        sandboxCommandPromotesProductionCommand: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            modes: modes,
            surfaces: surfaces,
            forbiddenCapabilities: forbiddenCapabilities,
            proofEvidence: proofEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            manualApprovalGateRequired: manualApprovalGateRequired,
            incidentRollbackNoTradeGateRequired: incidentRollbackNoTradeGateRequired,
            capitalRiskLimitGateRequired: capitalRiskLimitGateRequired,
            noDefaultTradingRequired: noDefaultTradingRequired,
            reportSurfaceReadModelOnly: reportSurfaceReadModelOnly,
            dashboardSurfaceReadModelOnly: dashboardSurfaceReadModelOnly,
            eventsSurfaceReadModelOnly: eventsSurfaceReadModelOnly
        )
        try Self.validateForbiddenFlags(
            implementsProductionExecution: implementsProductionExecution,
            implementsRealBrokerShadowTrading: implementsRealBrokerShadowTrading,
            connectsBroker: connectsBroker,
            readsSecretValue: readsSecretValue,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            sandboxCommandPromotesProductionCommand: sandboxCommandPromotesProductionCommand,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.modes = modes
        self.surfaces = surfaces
        self.forbiddenCapabilities = forbiddenCapabilities
        self.proofEvidence = proofEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.manualApprovalGateRequired = manualApprovalGateRequired
        self.incidentRollbackNoTradeGateRequired = incidentRollbackNoTradeGateRequired
        self.capitalRiskLimitGateRequired = capitalRiskLimitGateRequired
        self.noDefaultTradingRequired = noDefaultTradingRequired
        self.reportSurfaceReadModelOnly = reportSurfaceReadModelOnly
        self.dashboardSurfaceReadModelOnly = dashboardSurfaceReadModelOnly
        self.eventsSurfaceReadModelOnly = eventsSurfaceReadModelOnly
        self.implementsProductionExecution = implementsProductionExecution
        self.implementsRealBrokerShadowTrading = implementsRealBrokerShadowTrading
        self.connectsBroker = connectsBroker
        self.readsSecretValue = readsSecretValue
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.sandboxCommandPromotesProductionCommand = sandboxCommandPromotesProductionCommand
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> ProductionCutoverDryRunShadowNoDefaultTradingEvidence {
        try ProductionCutoverDryRunShadowNoDefaultTradingEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-509-DRY-RUN-PROOF-SHADOW-NO-DEFAULT-TRADING-EVIDENCE",
        "GH-509-SANDBOX-DRY-RUN-SHADOW-PRODUCTION-COMMAND-ISOLATION",
        "GH-509-REPORT-DASHBOARD-EVENTS-READ-MODEL-ONLY",
        "GH-509-NO-BROKER-SECRET-REAL-ORDER",
        "GH-509-NO-SANDBOX-TO-PRODUCTION-PROMOTION"
    ]

    public static let requiredProofEvidence: [ProductionCutoverDryRunProofEvidence] = {
        do {
            return [
                try ProductionCutoverDryRunProofEvidence(
                    evidenceID: Identifier.constant("gh-509-sandbox-proof-evidence"),
                    mode: .sandbox,
                    expectedEvidence: "sandbox evidence remains isolated from production command",
                    blockedReason: "sandbox command cannot promote to production command"
                ),
                try ProductionCutoverDryRunProofEvidence(
                    evidenceID: Identifier.constant("gh-509-dry-run-proof-evidence"),
                    mode: .dryRun,
                    expectedEvidence: "dry-run proof remains no-default-trading evidence",
                    blockedReason: "dry-run cannot submit real order"
                ),
                try ProductionCutoverDryRunProofEvidence(
                    evidenceID: Identifier.constant("gh-509-shadow-proof-evidence"),
                    mode: .shadow,
                    expectedEvidence: "shadow mode remains read-model-only proof",
                    blockedReason: "shadow mode cannot connect broker or read secret"
                ),
                try ProductionCutoverDryRunProofEvidence(
                    evidenceID: Identifier.constant("gh-509-production-blocked-proof-evidence"),
                    mode: .productionBlocked,
                    expectedEvidence: "production path remains blocked by default",
                    blockedReason: "production no-default-trading remains active before cutover"
                )
            ]
        } catch {
            preconditionFailure("GH-509 deterministic dry-run proof evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverDryRunShadowNoDefaultTradingEvidence {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        modes: [ProductionCutoverDryRunProofMode],
        surfaces: [ProductionCutoverDryRunEvidenceSurface],
        forbiddenCapabilities: [ProductionCutoverDryRunForbiddenCapability],
        proofEvidence: [ProductionCutoverDryRunProofEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-506", "GH-507", "GH-508"],
                "GH-506,GH-507,GH-508",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "modes",
                modes == ProductionCutoverDryRunProofMode.allCases,
                ProductionCutoverDryRunProofMode.allCases.map(\.rawValue).joined(separator: ","),
                modes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "surfaces",
                surfaces == ProductionCutoverDryRunEvidenceSurface.allCases,
                ProductionCutoverDryRunEvidenceSurface.allCases.map(\.rawValue).joined(separator: ","),
                surfaces.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ProductionCutoverDryRunForbiddenCapability.allCases,
                ProductionCutoverDryRunForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "proofEvidence",
                proofEvidence == requiredProofEvidence,
                "GH-509 required dry-run proof evidence",
                proofEvidence.map(\.mode.rawValue).joined(separator: ",")
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
        manualApprovalGateRequired: Bool,
        incidentRollbackNoTradeGateRequired: Bool,
        capitalRiskLimitGateRequired: Bool,
        noDefaultTradingRequired: Bool,
        reportSurfaceReadModelOnly: Bool,
        dashboardSurfaceReadModelOnly: Bool,
        eventsSurfaceReadModelOnly: Bool
    ) throws {
        for (field, value) in [
            ("manualApprovalGateRequired", manualApprovalGateRequired),
            ("incidentRollbackNoTradeGateRequired", incidentRollbackNoTradeGateRequired),
            ("capitalRiskLimitGateRequired", capitalRiskLimitGateRequired),
            ("noDefaultTradingRequired", noDefaultTradingRequired),
            ("reportSurfaceReadModelOnly", reportSurfaceReadModelOnly),
            ("dashboardSurfaceReadModelOnly", dashboardSurfaceReadModelOnly),
            ("eventsSurfaceReadModelOnly", eventsSurfaceReadModelOnly)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        implementsProductionExecution: Bool,
        implementsRealBrokerShadowTrading: Bool,
        connectsBroker: Bool,
        readsSecretValue: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        sandboxCommandPromotesProductionCommand: Bool,
        productionTradingEnabledByDefault: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        exposesLiveCommandSurface: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsProductionExecution", implementsProductionExecution),
            ("implementsRealBrokerShadowTrading", implementsRealBrokerShadowTrading),
            ("connectsBroker", connectsBroker),
            ("readsSecretValue", readsSecretValue),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("sandboxCommandPromotesProductionCommand", sandboxCommandPromotesProductionCommand),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
