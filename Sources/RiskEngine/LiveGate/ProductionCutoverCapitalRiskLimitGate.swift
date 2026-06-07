import DomainModel
import Foundation

/// ProductionCutoverCapitalRiskLimitKind 固定 GH-508 必须覆盖的 limit 维度。
///
/// 这些 kind 只用于 production cutover readiness evidence；它们不读取真实账户、不消费 broker
/// position / margin / leverage / PnL，也不实现 live pre-trade allow / reject runtime。
public enum ProductionCutoverCapitalRiskLimitKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case capital = "capital"
    case risk = "risk"
    case orderNotional = "order notional"
    case exposure = "exposure"
}

/// ProductionCutoverCapitalRiskLimitState 固定 GH-508 limit gate 的状态。
public enum ProductionCutoverCapitalRiskLimitState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blocked
    case dryRunOnly = "dry-run-only"
    case noTrade = "no-trade"
    case futureGated = "future-gated"
}

/// ProductionCutoverCapitalRiskForbiddenCapability 枚举 GH-508 必须继续关闭的能力。
public enum ProductionCutoverCapitalRiskForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case liveRiskEngine = "live risk engine"
    case realPreTradeAllowRejectRuntime = "real pre-trade allow / reject runtime"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionRead = "broker position read"
    case marginLeverageRead = "margin / leverage read"
    case realPnLRead = "real PnL read"
    case capitalAllocationRuntime = "capital allocation runtime"
    case brokerConnection = "broker connection"
    case omsImplementation = "OMS implementation"
    case brokerGatewayImplementation = "broker gateway implementation"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// ProductionCutoverCapitalRiskLimitEvidence 是 GH-508 的 limit readiness evidence row。
///
/// Row 只能说明 capital / risk / notional / exposure limit 的 blocked evidence，并绑定 GH-505 broker /
/// venue matrix 和 GH-506 manual approval gate。任何真实账户读取、broker state、live risk runtime 或
/// real order action 都会被拒绝。
public struct ProductionCutoverCapitalRiskLimitEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let kind: ProductionCutoverCapitalRiskLimitKind
    public let state: ProductionCutoverCapitalRiskLimitState
    public let expectedEvidence: String
    public let blockedReason: String
    public let requiresBrokerVenueCapabilityMatrix: Bool
    public let requiresManualApprovalGate: Bool
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMarginOrLeverage: Bool
    public let evaluatesRealPreTradeDecision: Bool
    public let submitsRealOrder: Bool

    public init(
        evidenceID: Identifier,
        kind: ProductionCutoverCapitalRiskLimitKind,
        state: ProductionCutoverCapitalRiskLimitState,
        expectedEvidence: String,
        blockedReason: String,
        requiresBrokerVenueCapabilityMatrix: Bool = true,
        requiresManualApprovalGate: Bool = true,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMarginOrLeverage: Bool = false,
        evaluatesRealPreTradeDecision: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty capital risk limit evidence",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty capital risk limit blocked reason",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("requiresBrokerVenueCapabilityMatrix", requiresBrokerVenueCapabilityMatrix),
            ("requiresManualApprovalGate", requiresManualApprovalGate)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("readsBrokerPosition", readsBrokerPosition),
            ("readsMarginOrLeverage", readsMarginOrLeverage),
            ("evaluatesRealPreTradeDecision", evaluatesRealPreTradeDecision),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.kind = kind
        self.state = state
        self.expectedEvidence = expectedEvidence
        self.blockedReason = blockedReason
        self.requiresBrokerVenueCapabilityMatrix = requiresBrokerVenueCapabilityMatrix
        self.requiresManualApprovalGate = requiresManualApprovalGate
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMarginOrLeverage = readsMarginOrLeverage
        self.evaluatesRealPreTradeDecision = evaluatesRealPreTradeDecision
        self.submitsRealOrder = submitsRealOrder
    }
}

/// ProductionCutoverCapitalRiskLimitGate 是 GH-508 的 capital / risk / notional / exposure limit gate。
///
/// Gate 只表达 cutover 前的资金、风险、订单名义金额和敞口限制 readiness evidence。它不实现真实
/// live risk engine、不读取真实账户 / broker / margin / leverage / PnL，也不授权真实订单。
public struct ProductionCutoverCapitalRiskLimitGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let projectName: String
    public let canonicalQueueRange: String
    public let limitKinds: [ProductionCutoverCapitalRiskLimitKind]
    public let states: [ProductionCutoverCapitalRiskLimitState]
    public let forbiddenCapabilities: [ProductionCutoverCapitalRiskForbiddenCapability]
    public let limitEvidence: [ProductionCutoverCapitalRiskLimitEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let brokerVenueCapabilityMatrixRequired: Bool
    public let manualApprovalGateRequired: Bool
    public let productionNoDefaultTradingRequired: Bool
    public let blockedDryRunNoTradeDefault: Bool
    public let implementsLiveRiskEngine: Bool
    public let evaluatesRealPreTradeAllowReject: Bool
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMarginOrLeverage: Bool
    public let readsRealPnL: Bool
    public let implementsCapitalAllocationRuntime: Bool
    public let connectsBroker: Bool
    public let implementsOMS: Bool
    public let implementsBrokerGateway: Bool
    public let productionTradingEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-508"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-505", "GH-506"]
            && projectName == Self.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && limitKinds == ProductionCutoverCapitalRiskLimitKind.allCases
            && states == ProductionCutoverCapitalRiskLimitState.allCases
            && forbiddenCapabilities == ProductionCutoverCapitalRiskForbiddenCapability.allCases
            && limitEvidence == Self.requiredLimitEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && brokerVenueCapabilityMatrixRequired
            && manualApprovalGateRequired
            && productionNoDefaultTradingRequired
            && blockedDryRunNoTradeDefault
            && allForbiddenFlagsRemainClosed
    }

    public var limitEvidenceCoverageHeld: Bool {
        Set(limitEvidence.map(\.kind)) == Set(ProductionCutoverCapitalRiskLimitKind.allCases)
            && Set(limitEvidence.map(\.state)) == Set(ProductionCutoverCapitalRiskLimitState.allCases)
            && limitEvidence.allSatisfy(\.requiresBrokerVenueCapabilityMatrix)
            && limitEvidence.allSatisfy(\.requiresManualApprovalGate)
            && limitEvidence.allSatisfy { $0.evaluatesRealPreTradeDecision == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsLiveRiskEngine,
            evaluatesRealPreTradeAllowReject,
            readsRealAccountBalance,
            readsBrokerPosition,
            readsMarginOrLeverage,
            readsRealPnL,
            implementsCapitalAllocationRuntime,
            connectsBroker,
            implementsOMS,
            implementsBrokerGateway,
            productionTradingEnabledByDefault,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder
        ].allSatisfy { $0 == false }
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-508-production-cutover-capital-risk-limit-gate"),
        issueID: Identifier = Identifier.constant("GH-508"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-505"), Identifier.constant("GH-506")],
        projectName: String = Self.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        limitKinds: [ProductionCutoverCapitalRiskLimitKind] = ProductionCutoverCapitalRiskLimitKind.allCases,
        states: [ProductionCutoverCapitalRiskLimitState] = ProductionCutoverCapitalRiskLimitState.allCases,
        forbiddenCapabilities: [ProductionCutoverCapitalRiskForbiddenCapability] =
            ProductionCutoverCapitalRiskForbiddenCapability.allCases,
        limitEvidence: [ProductionCutoverCapitalRiskLimitEvidence] = Self.requiredLimitEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        brokerVenueCapabilityMatrixRequired: Bool = true,
        manualApprovalGateRequired: Bool = true,
        productionNoDefaultTradingRequired: Bool = true,
        blockedDryRunNoTradeDefault: Bool = true,
        implementsLiveRiskEngine: Bool = false,
        evaluatesRealPreTradeAllowReject: Bool = false,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMarginOrLeverage: Bool = false,
        readsRealPnL: Bool = false,
        implementsCapitalAllocationRuntime: Bool = false,
        connectsBroker: Bool = false,
        implementsOMS: Bool = false,
        implementsBrokerGateway: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            limitKinds: limitKinds,
            states: states,
            forbiddenCapabilities: forbiddenCapabilities,
            limitEvidence: limitEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            brokerVenueCapabilityMatrixRequired: brokerVenueCapabilityMatrixRequired,
            manualApprovalGateRequired: manualApprovalGateRequired,
            productionNoDefaultTradingRequired: productionNoDefaultTradingRequired,
            blockedDryRunNoTradeDefault: blockedDryRunNoTradeDefault
        )
        try Self.validateForbiddenFlags(
            implementsLiveRiskEngine: implementsLiveRiskEngine,
            evaluatesRealPreTradeAllowReject: evaluatesRealPreTradeAllowReject,
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMarginOrLeverage: readsMarginOrLeverage,
            readsRealPnL: readsRealPnL,
            implementsCapitalAllocationRuntime: implementsCapitalAllocationRuntime,
            connectsBroker: connectsBroker,
            implementsOMS: implementsOMS,
            implementsBrokerGateway: implementsBrokerGateway,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.limitKinds = limitKinds
        self.states = states
        self.forbiddenCapabilities = forbiddenCapabilities
        self.limitEvidence = limitEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.brokerVenueCapabilityMatrixRequired = brokerVenueCapabilityMatrixRequired
        self.manualApprovalGateRequired = manualApprovalGateRequired
        self.productionNoDefaultTradingRequired = productionNoDefaultTradingRequired
        self.blockedDryRunNoTradeDefault = blockedDryRunNoTradeDefault
        self.implementsLiveRiskEngine = implementsLiveRiskEngine
        self.evaluatesRealPreTradeAllowReject = evaluatesRealPreTradeAllowReject
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMarginOrLeverage = readsMarginOrLeverage
        self.readsRealPnL = readsRealPnL
        self.implementsCapitalAllocationRuntime = implementsCapitalAllocationRuntime
        self.connectsBroker = connectsBroker
        self.implementsOMS = implementsOMS
        self.implementsBrokerGateway = implementsBrokerGateway
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public static func deterministicFixture() throws -> ProductionCutoverCapitalRiskLimitGate {
        try ProductionCutoverCapitalRiskLimitGate()
    }

    public static let requiredProjectName = "MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1"

    public static let requiredValidationCommands = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredValidationAnchors = [
        "GH-508-CAPITAL-RISK-NOTIONAL-EXPOSURE-LIMIT-GATE",
        "GH-508-BINDS-GH505-GH506",
        "GH-508-DRY-RUN-BLOCKED-NO-TRADE-LIMIT-EVIDENCE",
        "GH-508-NO-LIVE-RISK-PRETRADE-RUNTIME",
        "GH-508-NO-REAL-ACCOUNT-BROKER-MARGIN-READ"
    ]

    public static let requiredLimitEvidence: [ProductionCutoverCapitalRiskLimitEvidence] = {
        do {
            return [
                try ProductionCutoverCapitalRiskLimitEvidence(
                    evidenceID: Identifier.constant("gh-508-capital-limit-evidence"),
                    kind: .capital,
                    state: .blocked,
                    expectedEvidence: "capital limit remains blocked evidence before production cutover",
                    blockedReason: "real capital allocation runtime is out of scope"
                ),
                try ProductionCutoverCapitalRiskLimitEvidence(
                    evidenceID: Identifier.constant("gh-508-risk-limit-evidence"),
                    kind: .risk,
                    state: .dryRunOnly,
                    expectedEvidence: "risk limit remains dry-run readiness evidence",
                    blockedReason: "real pre-trade allow / reject runtime is out of scope"
                ),
                try ProductionCutoverCapitalRiskLimitEvidence(
                    evidenceID: Identifier.constant("gh-508-order-notional-limit-evidence"),
                    kind: .orderNotional,
                    state: .noTrade,
                    expectedEvidence: "order notional limit remains no-trade evidence",
                    blockedReason: "no-trade default blocks production notional evaluation"
                ),
                try ProductionCutoverCapitalRiskLimitEvidence(
                    evidenceID: Identifier.constant("gh-508-exposure-limit-evidence"),
                    kind: .exposure,
                    state: .futureGated,
                    expectedEvidence: "exposure limit remains future-gated behind account and broker evidence",
                    blockedReason: "real broker position / margin / leverage reads are out of scope"
                )
            ]
        } catch {
            preconditionFailure("GH-508 deterministic capital risk limit evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverCapitalRiskLimitGate {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        limitKinds: [ProductionCutoverCapitalRiskLimitKind],
        states: [ProductionCutoverCapitalRiskLimitState],
        forbiddenCapabilities: [ProductionCutoverCapitalRiskForbiddenCapability],
        limitEvidence: [ProductionCutoverCapitalRiskLimitEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-505", "GH-506"],
                "GH-505,GH-506",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "limitKinds",
                limitKinds == ProductionCutoverCapitalRiskLimitKind.allCases,
                ProductionCutoverCapitalRiskLimitKind.allCases.map(\.rawValue).joined(separator: ","),
                limitKinds.map(\.rawValue).joined(separator: ",")
            ),
            (
                "states",
                states == ProductionCutoverCapitalRiskLimitState.allCases,
                ProductionCutoverCapitalRiskLimitState.allCases.map(\.rawValue).joined(separator: ","),
                states.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ProductionCutoverCapitalRiskForbiddenCapability.allCases,
                ProductionCutoverCapitalRiskForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "limitEvidence",
                limitEvidence == requiredLimitEvidence,
                "GH-508 required capital risk limit evidence",
                limitEvidence.map(\.kind.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == ProductionCutoverCapitalRiskLimitGate.requiredValidationCommands,
                ProductionCutoverCapitalRiskLimitGate.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredFlags(
        brokerVenueCapabilityMatrixRequired: Bool,
        manualApprovalGateRequired: Bool,
        productionNoDefaultTradingRequired: Bool,
        blockedDryRunNoTradeDefault: Bool
    ) throws {
        for (field, value) in [
            ("brokerVenueCapabilityMatrixRequired", brokerVenueCapabilityMatrixRequired),
            ("manualApprovalGateRequired", manualApprovalGateRequired),
            ("productionNoDefaultTradingRequired", productionNoDefaultTradingRequired),
            ("blockedDryRunNoTradeDefault", blockedDryRunNoTradeDefault)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        implementsLiveRiskEngine: Bool,
        evaluatesRealPreTradeAllowReject: Bool,
        readsRealAccountBalance: Bool,
        readsBrokerPosition: Bool,
        readsMarginOrLeverage: Bool,
        readsRealPnL: Bool,
        implementsCapitalAllocationRuntime: Bool,
        connectsBroker: Bool,
        implementsOMS: Bool,
        implementsBrokerGateway: Bool,
        productionTradingEnabledByDefault: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsLiveRiskEngine", implementsLiveRiskEngine),
            ("evaluatesRealPreTradeAllowReject", evaluatesRealPreTradeAllowReject),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("readsBrokerPosition", readsBrokerPosition),
            ("readsMarginOrLeverage", readsMarginOrLeverage),
            ("readsRealPnL", readsRealPnL),
            ("implementsCapitalAllocationRuntime", implementsCapitalAllocationRuntime),
            ("connectsBroker", connectsBroker),
            ("implementsOMS", implementsOMS),
            ("implementsBrokerGateway", implementsBrokerGateway),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
