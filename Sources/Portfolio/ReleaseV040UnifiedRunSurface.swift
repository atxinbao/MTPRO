import DomainModel
import Foundation

/// ReleaseV040UnifiedRunSurfaceStatus 固定 GH-705 Dashboard / CLI 可展示的 run 状态。
public enum ReleaseV040UnifiedRunSurfaceStatus: String, Codable, Equatable, Sendable {
    case ready
    case blocked
    case rejected
}

/// ReleaseV040UnifiedRunSurfaceGate 固定 GH-705 必须展示的 run gate。
public enum ReleaseV040UnifiedRunSurfaceGate:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case dataEngine
    case trader
    case riskEngine
    case executionEngine
    case oms
    case executionClient
    case eventStore
    case portfolioProjection
    case killSwitch
    case noTrade
}

/// ReleaseV040UnifiedRunSurfaceRequirement 固定 GH-705 的验收要求。
public enum ReleaseV040UnifiedRunSurfaceRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamPortfolioProjectionRequired = "upstream GH-704 Portfolio replay projection required"
    case dashboardConsumesOneRunIDProjection = "Dashboard consumes one runID projection"
    case cliConsumesOneRunIDProjection = "CLI consumes one runID projection"
    case blockedRejectedStatesExplained = "blocked and rejected states explained"
    case readModelOnlySurfaceRequired = "read-model-only surface required"
}

/// ReleaseV040UnifiedRunSurfaceForbiddenCapability 枚举 GH-705 必须保持关闭的能力。
public enum ReleaseV040UnifiedRunSurfaceForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case tradingButton = "trading button"
    case orderForm = "order form"
    case liveCommandSurface = "live command surface"
    case productionCommandSurface = "production command surface"
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointConnection = "production endpoint connection"
    case productionSecretRead = "production secret read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case brokerGatewayAccess = "broker gateway access"
    case executionClientCommandAccess = "ExecutionClient command access"
    case accountEndpointRead = "account endpoint read"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV040UnifiedRunSurfaceGateRecord 是 Dashboard / CLI 共用的只读 gate 记录。
public struct ReleaseV040UnifiedRunSurfaceGateRecord: Codable, Equatable, Sendable {
    public let gate: ReleaseV040UnifiedRunSurfaceGate
    public let status: ReleaseV040UnifiedRunSurfaceStatus
    public let sourceEvidenceID: Identifier
    public let explanation: String
    public let visibleOnDashboard: Bool
    public let visibleOnCLI: Bool
    public let authorizesCommand: Bool
    public let exposesOrderForm: Bool

    public var gateHeld: Bool {
        explanation.isEmpty == false
            && visibleOnDashboard
            && visibleOnCLI
            && authorizesCommand == false
            && exposesOrderForm == false
    }

    public init(
        gate: ReleaseV040UnifiedRunSurfaceGate,
        status: ReleaseV040UnifiedRunSurfaceStatus,
        sourceEvidenceID: Identifier,
        explanation: String,
        visibleOnDashboard: Bool = true,
        visibleOnCLI: Bool = true,
        authorizesCommand: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        guard explanation.isEmpty == false,
              visibleOnDashboard,
              visibleOnCLI else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040UnifiedRunSurface.gate",
                expected: "visible Dashboard / CLI gate explanation",
                actual: gate.rawValue
            )
        }
        try Self.forbid(authorizesCommand, "authorizesCommand")
        try Self.forbid(exposesOrderForm, "exposesOrderForm")

        self.gate = gate
        self.status = status
        self.sourceEvidenceID = sourceEvidenceID
        self.explanation = explanation
        self.visibleOnDashboard = visibleOnDashboard
        self.visibleOnCLI = visibleOnCLI
        self.authorizesCommand = authorizesCommand
        self.exposesOrderForm = exposesOrderForm
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040UnifiedRunSurface.gate.\(field)")
        }
    }
}

/// ReleaseV040UnifiedRunSurfaceEvidence 汇总 GH-705 的 Dashboard / CLI unified run surface。
public struct ReleaseV040UnifiedRunSurfaceEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let upstreamProjectionEvidenceID: Identifier
    public let upstreamProjectionState: ReleaseV040PortfolioReplayProjectionState
    public let validationAnchor: String
    public let gates: [ReleaseV040UnifiedRunSurfaceGateRecord]
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV040RehearsalStrategyKind]
    public let adapterEvidenceVisible: Bool
    public let portfolioProjectionVisible: Bool
    public let blockedStatesExplained: Bool
    public let rejectedStatesExplained: Bool
    public let dashboardConsumesProjectionByRunID: Bool
    public let cliConsumesProjectionByRunID: Bool
    public let requirements: [ReleaseV040UnifiedRunSurfaceRequirement]
    public let forbiddenCapabilities: [ReleaseV040UnifiedRunSurfaceForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let tradingButtonExposed: Bool
    public let orderFormExposed: Bool
    public let liveCommandSurfaceExposed: Bool
    public let productionCommandSurfaceExposed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let brokerGatewayTouched: Bool
    public let executionClientCommandTouched: Bool
    public let accountEndpointRead: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-705"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-703", "GH-704"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-707", "GH-708"]
            && releaseVersion == "v0.4.0"
            && upstreamProjectionState.stateHeld
            && upstreamProjectionState.runID == runID
            && validationAnchor == Self.validationAnchor
            && gates.map(\.gate) == ReleaseV040UnifiedRunSurfaceGate.allCases
            && gates.allSatisfy(\.gateHeld)
            && gates.contains { $0.status == .blocked }
            && gates.contains { $0.status == .rejected }
            && productTypes == Self.requiredProductTypes
            && strategies == Self.requiredStrategies
            && adapterEvidenceVisible
            && portfolioProjectionVisible
            && blockedStatesExplained
            && rejectedStatesExplained
            && dashboardConsumesProjectionByRunID
            && cliConsumesProjectionByRunID
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        tradingButtonExposed == false
            && orderFormExposed == false
            && liveCommandSurfaceExposed == false
            && productionCommandSurfaceExposed == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && brokerGatewayTouched == false
            && executionClientCommandTouched == false
            && accountEndpointRead == false
            && startsNextMilestone == false
    }

    public var failureReasons: [String] {
        gates.map(\.explanation)
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-705-v040-dashboard-cli-unified-run-surface"),
        issueID: Identifier = Identifier.constant("GH-705"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-703"), Identifier.constant("GH-704")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-707"), Identifier.constant("GH-708")],
        releaseVersion: String = "v0.4.0",
        runID: Identifier,
        upstreamProjectionEvidenceID: Identifier,
        upstreamProjectionState: ReleaseV040PortfolioReplayProjectionState,
        validationAnchor: String = Self.validationAnchor,
        gates: [ReleaseV040UnifiedRunSurfaceGateRecord],
        productTypes: [ProductType] = Self.requiredProductTypes,
        strategies: [ReleaseV040RehearsalStrategyKind] = Self.requiredStrategies,
        adapterEvidenceVisible: Bool = true,
        portfolioProjectionVisible: Bool = true,
        blockedStatesExplained: Bool = true,
        rejectedStatesExplained: Bool = true,
        dashboardConsumesProjectionByRunID: Bool = true,
        cliConsumesProjectionByRunID: Bool = true,
        requirements: [ReleaseV040UnifiedRunSurfaceRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV040UnifiedRunSurfaceForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        tradingButtonExposed: Bool = false,
        orderFormExposed: Bool = false,
        liveCommandSurfaceExposed: Bool = false,
        productionCommandSurfaceExposed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        brokerGatewayTouched: Bool = false,
        executionClientCommandTouched: Bool = false,
        accountEndpointRead: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateBoundary(
            adapterEvidenceVisible: adapterEvidenceVisible,
            portfolioProjectionVisible: portfolioProjectionVisible,
            blockedStatesExplained: blockedStatesExplained,
            rejectedStatesExplained: rejectedStatesExplained,
            dashboardConsumesProjectionByRunID: dashboardConsumesProjectionByRunID,
            cliConsumesProjectionByRunID: cliConsumesProjectionByRunID,
            tradingButtonExposed: tradingButtonExposed,
            orderFormExposed: orderFormExposed,
            liveCommandSurfaceExposed: liveCommandSurfaceExposed,
            productionCommandSurfaceExposed: productionCommandSurfaceExposed,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretRead: productionSecretRead,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            brokerGatewayTouched: brokerGatewayTouched,
            executionClientCommandTouched: executionClientCommandTouched,
            accountEndpointRead: accountEndpointRead,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.upstreamProjectionEvidenceID = upstreamProjectionEvidenceID
        self.upstreamProjectionState = upstreamProjectionState
        self.validationAnchor = validationAnchor
        self.gates = gates
        self.productTypes = productTypes
        self.strategies = strategies
        self.adapterEvidenceVisible = adapterEvidenceVisible
        self.portfolioProjectionVisible = portfolioProjectionVisible
        self.blockedStatesExplained = blockedStatesExplained
        self.rejectedStatesExplained = rejectedStatesExplained
        self.dashboardConsumesProjectionByRunID = dashboardConsumesProjectionByRunID
        self.cliConsumesProjectionByRunID = cliConsumesProjectionByRunID
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.tradingButtonExposed = tradingButtonExposed
        self.orderFormExposed = orderFormExposed
        self.liveCommandSurfaceExposed = liveCommandSurfaceExposed
        self.productionCommandSurfaceExposed = productionCommandSurfaceExposed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.brokerGatewayTouched = brokerGatewayTouched
        self.executionClientCommandTouched = executionClientCommandTouched
        self.accountEndpointRead = accountEndpointRead
        self.startsNextMilestone = startsNextMilestone

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040UnifiedRunSurface.evidenceHeld",
                expected: "held GH-705 evidence",
                actual: "false"
            )
        }
    }

    public static let validationAnchor = "TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE"
    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredStrategies: [ReleaseV040RehearsalStrategyKind] = [.ema, .rsi]
    public static let requiredRequirements = ReleaseV040UnifiedRunSurfaceRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV040UnifiedRunSurfaceForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V040-12-DASHBOARD-CLI-UNIFIED-RUN-SURFACE",
        "V040-12-ONE-RUNID-PROJECTION-CONSUMPTION",
        "V040-12-BLOCKED-REJECTED-STATE-EXPLANATIONS",
        "V040-12-ADAPTER-PORTFOLIO-PROJECTION-VISIBLE",
        "V040-12-NO-LIVE-COMMAND-SURFACE",
        validationAnchor
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH705DashboardCLIUnifiedRunSurfaceConsumesPortfolioProjectionByRunID",
        "swift run mtpro unified-run-status",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV040UnifiedRunSurface 生成 GH-705 的 deterministic Dashboard / CLI surface。
public enum ReleaseV040UnifiedRunSurface {
    public static let cliCommand = "unified-run-status"

    public static func deterministicEvidence(
        upstreamProjectionEvidence: ReleaseV040PortfolioReplayProjectionEvidence? = nil
    ) throws -> ReleaseV040UnifiedRunSurfaceEvidence {
        let upstream = try upstreamProjectionEvidence ?? ReleaseV040PortfolioReplayProjection.deterministicEvidence()
        guard upstream.evidenceHeld,
              upstream.issueID.rawValue == "GH-704",
              upstream.projectionState.stateHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040UnifiedRunSurface.upstreamProjection",
                expected: "held GH-704 Portfolio replay projection",
                actual: upstream.issueID.rawValue
            )
        }
        let gates = try deterministicGates(from: upstream)
        return try ReleaseV040UnifiedRunSurfaceEvidence(
            runID: upstream.projectionState.runID,
            upstreamProjectionEvidenceID: upstream.evidenceID,
            upstreamProjectionState: upstream.projectionState,
            gates: gates
        )
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.unifiedRunStatus.arguments",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        let evidence = try deterministicEvidence()
        if arguments.count == 2, arguments[1] != evidence.runID.rawValue {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.unifiedRunStatus.runID",
                expected: evidence.runID.rawValue,
                actual: arguments[1]
            )
        }
        guard arguments.count == 1 || arguments.count == 2 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.unifiedRunStatus.arguments",
                expected: "\(cliCommand) [runID]",
                actual: arguments.joined(separator: " ")
            )
        }

        let gates = evidence.gates.map { "\($0.gate.rawValue)=\($0.status.rawValue)" }.joined(separator: ",")
        let explanations = evidence.failureReasons.joined(separator: " | ")
        let products = evidence.productTypes.map(\.rawValue).joined(separator: ",")
        let strategies = evidence.strategies.map(\.rawValue).joined(separator: ",")
        return [
            "mtpro \(cliCommand) blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.runID.rawValue)",
            "upstreamProjection=\(evidence.upstreamProjectionEvidenceID.rawValue)",
            "validationAnchor=\(evidence.validationAnchor)",
            "productTypes=\(products)",
            "strategies=\(strategies)",
            "gates=\(gates)",
            "adapterEvidenceVisible=\(evidence.adapterEvidenceVisible)",
            "portfolioProjectionVisible=\(evidence.portfolioProjectionVisible)",
            "blockedStatesExplained=\(evidence.blockedStatesExplained)",
            "rejectedStatesExplained=\(evidence.rejectedStatesExplained)",
            "dashboardConsumesProjectionByRunID=\(evidence.dashboardConsumesProjectionByRunID)",
            "cliConsumesProjectionByRunID=\(evidence.cliConsumesProjectionByRunID)",
            "productionTradingEnabledByDefault=\(evidence.productionTradingEnabledByDefault)",
            "productionEndpointConnected=\(evidence.productionEndpointConnected)",
            "productionSecretRead=\(evidence.productionSecretRead)",
            "productionOrderSubmitted=\(evidence.productionOrderSubmitted)",
            "productionCutoverAuthorized=\(evidence.productionCutoverAuthorized)",
            "boundaryHeld=\(evidence.boundaryHeld)",
            "explanations=\(explanations)"
        ].joined(separator: "\n")
    }

    public static func commandSurfaceRejected() throws -> Bool {
        let evidence = try deterministicEvidence()
        do {
            _ = try ReleaseV040UnifiedRunSurfaceEvidence(
                runID: evidence.runID,
                upstreamProjectionEvidenceID: evidence.upstreamProjectionEvidenceID,
                upstreamProjectionState: evidence.upstreamProjectionState,
                gates: evidence.gates,
                liveCommandSurfaceExposed: true
            )
            return false
        } catch CoreError.liveTradingBoundaryForbiddenCapability(
            "releaseV040UnifiedRunSurface.liveCommandSurfaceExposed"
        ) {
            return true
        }
    }

    private static func deterministicGates(
        from upstream: ReleaseV040PortfolioReplayProjectionEvidence
    ) throws -> [ReleaseV040UnifiedRunSurfaceGateRecord] {
        let evidenceID = upstream.evidenceID
        let specs: [(ReleaseV040UnifiedRunSurfaceGate, ReleaseV040UnifiedRunSurfaceStatus, String)] = [
            (.dataEngine, .ready, "DataEngine run-scoped market evidence is visible for this runID"),
            (.trader, .ready, "Trader EMA / RSI intent evidence is visible for this runID"),
            (.riskEngine, .rejected, "RiskEngine rejected-path evidence remains visible without authorizing execution"),
            (.executionEngine, .ready, "ExecutionEngine dry-run lifecycle evidence is visible"),
            (.oms, .ready, "OMS dry-run state replay evidence is visible"),
            (.executionClient, .ready, "Binance dry-run adapter evidence is visible without network calls"),
            (.eventStore, .ready, "Event Store run journal replay is visible by runID"),
            (.portfolioProjection, .ready, "Portfolio replay projection is visible by runID"),
            (.killSwitch, .blocked, "Kill switch state blocks command execution"),
            (.noTrade, .blocked, "No-trade state keeps live command surface disabled")
        ]
        return try specs.map { spec in
            try ReleaseV040UnifiedRunSurfaceGateRecord(
                gate: spec.0,
                status: spec.1,
                sourceEvidenceID: evidenceID,
                explanation: spec.2
            )
        }
    }
}

private extension ReleaseV040UnifiedRunSurfaceEvidence {
    static func validateBoundary(
        adapterEvidenceVisible: Bool,
        portfolioProjectionVisible: Bool,
        blockedStatesExplained: Bool,
        rejectedStatesExplained: Bool,
        dashboardConsumesProjectionByRunID: Bool,
        cliConsumesProjectionByRunID: Bool,
        tradingButtonExposed: Bool,
        orderFormExposed: Bool,
        liveCommandSurfaceExposed: Bool,
        productionCommandSurfaceExposed: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretRead: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        brokerGatewayTouched: Bool,
        executionClientCommandTouched: Bool,
        accountEndpointRead: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard adapterEvidenceVisible,
              portfolioProjectionVisible,
              blockedStatesExplained,
              rejectedStatesExplained,
              dashboardConsumesProjectionByRunID,
              cliConsumesProjectionByRunID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040UnifiedRunSurface.acceptance",
                expected: "Dashboard / CLI projection by runID with adapter, portfolio, blocked and rejected evidence",
                actual: "\(adapterEvidenceVisible):\(portfolioProjectionVisible):\(blockedStatesExplained)"
            )
        }
        let forbiddenFlags = [
            ("tradingButtonExposed", tradingButtonExposed),
            ("orderFormExposed", orderFormExposed),
            ("liveCommandSurfaceExposed", liveCommandSurfaceExposed),
            ("productionCommandSurfaceExposed", productionCommandSurfaceExposed),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretRead", productionSecretRead),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("executionClientCommandTouched", executionClientCommandTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040UnifiedRunSurface.\(field)")
        }
    }
}
