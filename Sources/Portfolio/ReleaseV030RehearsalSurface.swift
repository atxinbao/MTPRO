import DomainModel
import Foundation

/// ReleaseV030RehearsalSurfaceStatus 固定 Dashboard / CLI 能展示的 rehearsal run 状态。
///
/// 状态只来自本地 deterministic evidence，不代表生产环境连接状态，也不授权真实交易。
public enum ReleaseV030RehearsalSurfaceStatus: String, Codable, Equatable, Sendable {
    case ready
    case blocked
}

/// ReleaseV030RehearsalSurfaceGate 固定 GH-666 必须展示的 gate。
public enum ReleaseV030RehearsalSurfaceGate:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case commandGateway
    case riskEngine
    case executionEngine
    case oms
    case eventStore
    case portfolioProjection
    case killSwitch
    case noTrade
}

/// ReleaseV030RehearsalSurfaceRequirement 固定 GH-666 的验收要求。
public enum ReleaseV030RehearsalSurfaceRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamPortfolioProjectionRequired = "upstream GH-665 Portfolio projection rehearsal evidence required"
    case dashboardStatusVisible = "Dashboard rehearsal run status visible"
    case cliStatusVisible = "CLI rehearsal run status visible"
    case failureReasonsVisible = "failure reasons visible"
    case killSwitchNoTradeVisible = "kill switch and no-trade status visible"
    case commandGatewayRoutingRequired = "Dashboard and CLI commands route through CommandGateway"
}

/// ReleaseV030RehearsalSurfaceForbiddenCapability 枚举 GH-666 必须保持关闭的能力。
public enum ReleaseV030RehearsalSurfaceForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case dashboardBypassesCommandGateway = "Dashboard bypasses CommandGateway"
    case cliBypassesCommandGateway = "CLI bypasses CommandGateway"
    case dashboardTradingButton = "Dashboard trading button"
    case liveCommandSurface = "live command surface"
    case orderForm = "order form"
    case brokerGatewayAccess = "broker gateway access"
    case accountEndpointRead = "account endpoint read"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030RehearsalSurfaceGateEvidence 是 Dashboard / CLI 可展示的单个 gate evidence。
///
/// Gate evidence 只展示状态和 failure reason，不提供可执行 command payload。
public struct ReleaseV030RehearsalSurfaceGateEvidence: Codable, Equatable, Sendable {
    public let gate: ReleaseV030RehearsalSurfaceGate
    public let status: ReleaseV030RehearsalSurfaceStatus
    public let commandGatewayRoute: String
    public let failureReason: String
    public let visibleOnDashboard: Bool
    public let visibleOnCLI: Bool
    public let bypassesCommandGateway: Bool
    public let authorizesTradingExecution: Bool

    public var gateHeld: Bool {
        commandGatewayRoute.hasPrefix("command-gateway/release-v0.3.0/rehearsal/")
            && failureReason.isEmpty == false
            && visibleOnDashboard
            && visibleOnCLI
            && bypassesCommandGateway == false
            && authorizesTradingExecution == false
    }

    public init(
        gate: ReleaseV030RehearsalSurfaceGate,
        status: ReleaseV030RehearsalSurfaceStatus,
        commandGatewayRoute: String? = nil,
        failureReason: String,
        visibleOnDashboard: Bool = true,
        visibleOnCLI: Bool = true,
        bypassesCommandGateway: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        let resolvedRoute = commandGatewayRoute ?? "command-gateway/release-v0.3.0/rehearsal/\(gate.rawValue)"
        guard resolvedRoute.hasPrefix("command-gateway/release-v0.3.0/rehearsal/"),
              failureReason.isEmpty == false,
              visibleOnDashboard,
              visibleOnCLI else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RehearsalSurface.gate",
                expected: "visible Dashboard / CLI gate routed through CommandGateway",
                actual: gate.rawValue
            )
        }
        try Self.forbid(bypassesCommandGateway, "bypassesCommandGateway")
        try Self.forbid(authorizesTradingExecution, "authorizesTradingExecution")

        self.gate = gate
        self.status = status
        self.commandGatewayRoute = resolvedRoute
        self.failureReason = failureReason
        self.visibleOnDashboard = visibleOnDashboard
        self.visibleOnCLI = visibleOnCLI
        self.bypassesCommandGateway = bypassesCommandGateway
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030RehearsalSurface.gate.\(field)")
        }
    }
}

/// ReleaseV030RehearsalSurfaceEvidence 汇总 GH-666 的 Dashboard / CLI rehearsal surface。
public struct ReleaseV030RehearsalSurfaceEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamPortfolioProjectionAnchor: String
    public let runStatus: ReleaseV030RehearsalSurfaceStatus
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV030PortfolioProjectionRehearsalStrategyKind]
    public let gates: [ReleaseV030RehearsalSurfaceGateEvidence]
    public let requirements: [ReleaseV030RehearsalSurfaceRequirement]
    public let forbiddenCapabilities: [ReleaseV030RehearsalSurfaceForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let dashboardStatusVisible: Bool
    public let cliStatusVisible: Bool
    public let failureReasonsVisible: Bool
    public let killSwitchStatusVisible: Bool
    public let noTradeStatusVisible: Bool
    public let commandsRouteThroughCommandGateway: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let dashboardTradingButtonExposed: Bool
    public let liveCommandSurfaceExposed: Bool
    public let orderFormExposed: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let dashboardBypassesCommandGateway: Bool
    public let cliBypassesCommandGateway: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-666"
            && upstreamIssueID.rawValue == "GH-665"
            && downstreamIssueID.rawValue == "GH-667"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamPortfolioProjectionAnchor == Self.requiredUpstreamPortfolioProjectionAnchor
            && runStatus == .blocked
            && Set(productTypes) == Set(ProductType.allCases)
            && Set(strategies) == Set(ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases)
            && gates.map(\.gate) == ReleaseV030RehearsalSurfaceGate.allCases
            && gates.allSatisfy(\.gateHeld)
            && failureReasons.count == gates.count
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && dashboardStatusVisible
            && cliStatusVisible
            && failureReasonsVisible
            && killSwitchStatusVisible
            && noTradeStatusVisible
            && commandsRouteThroughCommandGateway
            && boundaryHeld
    }

    public var failureReasons: [String] {
        gates.map(\.failureReason)
    }

    public var killSwitchStatus: ReleaseV030RehearsalSurfaceStatus {
        gates.first { $0.gate == .killSwitch }?.status ?? .blocked
    }

    public var noTradeStatus: ReleaseV030RehearsalSurfaceStatus {
        gates.first { $0.gate == .noTrade }?.status ?? .blocked
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && dashboardTradingButtonExposed == false
            && liveCommandSurfaceExposed == false
            && orderFormExposed == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && dashboardBypassesCommandGateway == false
            && cliBypassesCommandGateway == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-666-release-v0.3.0-dashboard-cli-rehearsal-surface"),
        issueID: Identifier = Identifier.constant("GH-666"),
        upstreamIssueID: Identifier = Identifier.constant("GH-665"),
        downstreamIssueID: Identifier = Identifier.constant("GH-667"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamPortfolioProjectionAnchor: String = Self.requiredUpstreamPortfolioProjectionAnchor,
        runStatus: ReleaseV030RehearsalSurfaceStatus = .blocked,
        productTypes: [ProductType] = ProductType.allCases,
        strategies: [ReleaseV030PortfolioProjectionRehearsalStrategyKind] =
            ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases,
        gates: [ReleaseV030RehearsalSurfaceGateEvidence],
        requirements: [ReleaseV030RehearsalSurfaceRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030RehearsalSurfaceForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        dashboardStatusVisible: Bool = true,
        cliStatusVisible: Bool = true,
        failureReasonsVisible: Bool = true,
        killSwitchStatusVisible: Bool = true,
        noTradeStatusVisible: Bool = true,
        commandsRouteThroughCommandGateway: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        dashboardTradingButtonExposed: Bool = false,
        liveCommandSurfaceExposed: Bool = false,
        orderFormExposed: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        dashboardBypassesCommandGateway: Bool = false,
        cliBypassesCommandGateway: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        let sortedProducts = productTypes.sorted { $0.rawValue < $1.rawValue }
        let sortedStrategies = strategies.sorted { $0.rawValue < $1.rawValue }
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamPortfolioProjectionAnchor: upstreamPortfolioProjectionAnchor,
            productTypes: sortedProducts,
            strategies: sortedStrategies,
            gates: gates,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateBoundary(
            dashboardStatusVisible: dashboardStatusVisible,
            cliStatusVisible: cliStatusVisible,
            failureReasonsVisible: failureReasonsVisible,
            killSwitchStatusVisible: killSwitchStatusVisible,
            noTradeStatusVisible: noTradeStatusVisible,
            commandsRouteThroughCommandGateway: commandsRouteThroughCommandGateway,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            dashboardTradingButtonExposed: dashboardTradingButtonExposed,
            liveCommandSurfaceExposed: liveCommandSurfaceExposed,
            orderFormExposed: orderFormExposed,
            brokerGatewayTouched: brokerGatewayTouched,
            accountEndpointRead: accountEndpointRead,
            dashboardBypassesCommandGateway: dashboardBypassesCommandGateway,
            cliBypassesCommandGateway: cliBypassesCommandGateway,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamPortfolioProjectionAnchor = upstreamPortfolioProjectionAnchor
        self.runStatus = runStatus
        self.productTypes = sortedProducts
        self.strategies = sortedStrategies
        self.gates = gates
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.dashboardStatusVisible = dashboardStatusVisible
        self.cliStatusVisible = cliStatusVisible
        self.failureReasonsVisible = failureReasonsVisible
        self.killSwitchStatusVisible = killSwitchStatusVisible
        self.noTradeStatusVisible = noTradeStatusVisible
        self.commandsRouteThroughCommandGateway = commandsRouteThroughCommandGateway
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.dashboardTradingButtonExposed = dashboardTradingButtonExposed
        self.liveCommandSurfaceExposed = liveCommandSurfaceExposed
        self.orderFormExposed = orderFormExposed
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.dashboardBypassesCommandGateway = dashboardBypassesCommandGateway
        self.cliBypassesCommandGateway = cliBypassesCommandGateway
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamPortfolioProjectionAnchor =
        "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL"
    public static let requiredRequirements = ReleaseV030RehearsalSurfaceRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030RehearsalSurfaceForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V030-10-DASHBOARD-CLI-REHEARSAL-SURFACE",
        "V030-10-RUN-STATUS-SURFACE",
        "V030-10-GATE-FAILURE-REASONS",
        "V030-10-KILL-SWITCH-NO-TRADE-STATUS",
        "V030-10-COMMANDGATEWAY-ROUTING",
        "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030RehearsalSurface 生成 GH-666 deterministic Dashboard / CLI surface evidence。
public enum ReleaseV030RehearsalSurface {
    public static let cliCommand = "rehearsal-status"

    public static func deterministicEvidence(
        upstreamPortfolioEvidence: ReleaseV030PortfolioProjectionRehearsalEvidence? = nil
    ) throws -> ReleaseV030RehearsalSurfaceEvidence {
        let upstream: ReleaseV030PortfolioProjectionRehearsalEvidence
        if let upstreamPortfolioEvidence {
            upstream = upstreamPortfolioEvidence
        } else {
            upstream = try ReleaseV030PortfolioProjectionRehearsal.deterministicEvidence()
        }
        guard upstream.evidenceHeld,
              upstream.downstreamIssueID.rawValue == "GH-666",
              upstream.validationAnchors.contains(
                  ReleaseV030RehearsalSurfaceEvidence.requiredUpstreamPortfolioProjectionAnchor
              ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RehearsalSurface.upstreamPortfolioEvidence",
                expected: "GH-665 held Portfolio projection rehearsal evidence for GH-666",
                actual: upstream.downstreamIssueID.rawValue
            )
        }
        return try ReleaseV030RehearsalSurfaceEvidence(gates: deterministicGates())
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments == [cliCommand] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.rehearsal.arguments",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        let evidence = try deterministicEvidence()
        let gates = evidence.gates.map { "\($0.gate.rawValue)=\($0.status.rawValue)" }.joined(separator: ",")
        let failureReasons = evidence.failureReasons.joined(separator: " | ")
        let productTypes = evidence.productTypes.map(\.rawValue).joined(separator: ",")
        let strategies = evidence.strategies.map(\.rawValue).joined(separator: ",")
        return [
            "mtpro \(cliCommand) \(evidence.runStatus.rawValue)",
            "issue=\(evidence.issueID.rawValue)",
            "upstream=\(evidence.upstreamIssueID.rawValue)",
            "commandGateway=required",
            "dashboardStatusVisible=\(evidence.dashboardStatusVisible)",
            "cliStatusVisible=\(evidence.cliStatusVisible)",
            "productTypes=\(productTypes)",
            "strategies=\(strategies)",
            "gates=\(gates)",
            "failureReasons=\(failureReasons)",
            "killSwitchStatus=\(evidence.killSwitchStatus.rawValue)",
            "noTradeStatus=\(evidence.noTradeStatus.rawValue)",
            "commandsRouteThroughCommandGateway=\(evidence.commandsRouteThroughCommandGateway)",
            "productionTradingEnabledByDefault=false",
            "productionEndpointAutoConnect=false",
            "productionSecretAutoRead=false",
            "productionOrderSubmission=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=\(evidence.boundaryHeld)"
        ].joined(separator: "\n")
    }

    private static func deterministicGates() throws -> [ReleaseV030RehearsalSurfaceGateEvidence] {
        try ReleaseV030RehearsalSurfaceGate.allCases.map { gate in
            let status: ReleaseV030RehearsalSurfaceStatus = (gate == .killSwitch || gate == .noTrade) ? .blocked : .ready
            return try ReleaseV030RehearsalSurfaceGateEvidence(
                gate: gate,
                status: status,
                failureReason: failureReason(for: gate, status: status)
            )
        }
    }

    private static func failureReason(
        for gate: ReleaseV030RehearsalSurfaceGate,
        status: ReleaseV030RehearsalSurfaceStatus
    ) -> String {
        switch (gate, status) {
        case (.killSwitch, .blocked):
            return "kill switch active; rehearsal command remains blocked"
        case (.noTrade, .blocked):
            return "global no-trade state active; production command remains disabled"
        case (.commandGateway, .ready):
            return "CommandGateway route visible; direct Dashboard / CLI bypass forbidden"
        case (.riskEngine, .ready):
            return "RiskEngine gate evidence visible"
        case (.executionEngine, .ready):
            return "ExecutionEngine gate evidence visible"
        case (.oms, .ready):
            return "OMS gate evidence visible"
        case (.eventStore, .ready):
            return "Event Store replay evidence visible"
        case (.portfolioProjection, .ready):
            return "Portfolio projection rehearsal evidence visible"
        case (_, .ready):
            return "\(gate.rawValue) gate evidence visible"
        case (_, .blocked):
            return "\(gate.rawValue) gate blocks unsafe command"
        }
    }
}

private extension ReleaseV030RehearsalSurfaceEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamPortfolioProjectionAnchor: String,
        productTypes: [ProductType],
        strategies: [ReleaseV030PortfolioProjectionRehearsalStrategyKind],
        gates: [ReleaseV030RehearsalSurfaceGateEvidence],
        requirements: [ReleaseV030RehearsalSurfaceRequirement],
        forbiddenCapabilities: [ReleaseV030RehearsalSurfaceForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamPortfolioProjectionAnchor",
                upstreamPortfolioProjectionAnchor == requiredUpstreamPortfolioProjectionAnchor,
                requiredUpstreamPortfolioProjectionAnchor,
                upstreamPortfolioProjectionAnchor
            ),
            (
                "productTypes",
                Set(productTypes) == Set(ProductType.allCases),
                ProductType.supportedRawValues.joined(separator: ","),
                productTypes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "strategies",
                Set(strategies) == Set(ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases),
                ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases.map(\.rawValue).joined(separator: ","),
                strategies.map(\.rawValue).joined(separator: ",")
            ),
            (
                "gates",
                gates.map(\.gate) == ReleaseV030RehearsalSurfaceGate.allCases && gates.allSatisfy(\.gateHeld),
                ReleaseV030RehearsalSurfaceGate.allCases.map(\.rawValue).joined(separator: ","),
                gates.map(\.gate.rawValue).joined(separator: ",")
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
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
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateBoundary(
        dashboardStatusVisible: Bool,
        cliStatusVisible: Bool,
        failureReasonsVisible: Bool,
        killSwitchStatusVisible: Bool,
        noTradeStatusVisible: Bool,
        commandsRouteThroughCommandGateway: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        dashboardTradingButtonExposed: Bool,
        liveCommandSurfaceExposed: Bool,
        orderFormExposed: Bool,
        brokerGatewayTouched: Bool,
        accountEndpointRead: Bool,
        dashboardBypassesCommandGateway: Bool,
        cliBypassesCommandGateway: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard dashboardStatusVisible,
              cliStatusVisible,
              failureReasonsVisible,
              killSwitchStatusVisible,
              noTradeStatusVisible,
              commandsRouteThroughCommandGateway else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RehearsalSurface.visibleState",
                expected: "Dashboard / CLI state, failure reasons, kill switch, no-trade and CommandGateway route visible",
                actual: "\(dashboardStatusVisible):\(cliStatusVisible):\(failureReasonsVisible)"
            )
        }
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("dashboardTradingButtonExposed", dashboardTradingButtonExposed),
            ("liveCommandSurfaceExposed", liveCommandSurfaceExposed),
            ("orderFormExposed", orderFormExposed),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("dashboardBypassesCommandGateway", dashboardBypassesCommandGateway),
            ("cliBypassesCommandGateway", cliBypassesCommandGateway),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030RehearsalSurface.\(field)")
        }
    }
}
