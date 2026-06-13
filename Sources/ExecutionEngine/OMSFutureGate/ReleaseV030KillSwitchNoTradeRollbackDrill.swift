import DomainModel
import Foundation
import Portfolio

/// ReleaseV030ControlDrillCommandKind 固定 GH-667 要证明会被阻断的 rehearsal command。
///
/// 这些 command 只是本地 drill vocabulary，不是 ExecutionClient request、broker payload
/// 或真实 submit / cancel / replace 命令。
public enum ReleaseV030ControlDrillCommandKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case replace
}

/// ReleaseV030ControlDrillScenario 固定 GH-667 的三类阻断 drill。
public enum ReleaseV030ControlDrillScenario:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case killSwitch = "kill-switch"
    case noTrade = "no-trade"
    case rollback
}

/// ReleaseV030ControlDrillRequirement 固定 GH-667 验收要求。
public enum ReleaseV030ControlDrillRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamDashboardCLIRehearsalSurfaceRequired = "upstream GH-666 Dashboard / CLI rehearsal surface required"
    case killSwitchBlocksCommands = "kill switch blocks submit cancel replace"
    case noTradeBlocksCommands = "no-trade blocks submit cancel replace"
    case rollbackEvidenceProduced = "rollback evidence produced"
    case blockedCommandsAudited = "blocked commands audited"
    case commandGatewayRoutingRequired = "blocked commands route through CommandGateway audit path"
}

/// ReleaseV030ControlDrillForbiddenCapability 枚举 GH-667 必须保持关闭的能力。
public enum ReleaseV030ControlDrillForbiddenCapability:
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
    case executionClientCall = "ExecutionClient call"
    case brokerGatewayAccess = "broker gateway access"
    case realSubmit = "real submit"
    case realCancel = "real cancel"
    case realReplace = "real replace"
    case commandGatewayBypass = "CommandGateway bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case eventStoreBypass = "Event Store bypass"
    case killSwitchBypass = "kill switch bypass"
    case noTradeBypass = "no-trade bypass"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030RollbackDrillEvidence 定义 rollback drill 的本地证据。
///
/// Rollback evidence 只说明 rehearsal command 被阻断后如何解释和回退到 no-trade
/// 状态；它不执行 production rollback，不连接 broker，也不改写真实订单。
public struct ReleaseV030RollbackDrillEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let sourceIssueID: Identifier
    public let rollbackReady: Bool
    public let noTradePriorityHeld: Bool
    public let incidentStopActive: Bool
    public let auditSteps: [String]
    public let restoresProductionTrading: Bool
    public let connectsBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-667-release-v0.3.0-rollback-drill"),
        sourceIssueID: Identifier = Identifier.constant("GH-667"),
        rollbackReady: Bool = true,
        noTradePriorityHeld: Bool = true,
        incidentStopActive: Bool = true,
        auditSteps: [String] = Self.requiredAuditSteps,
        restoresProductionTrading: Bool = false,
        connectsBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard sourceIssueID.rawValue == "GH-667",
              rollbackReady,
              noTradePriorityHeld,
              incidentStopActive,
              auditSteps == Self.requiredAuditSteps else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RollbackDrill.evidence",
                expected: "GH-667 rollback-ready no-trade incident evidence",
                actual: sourceIssueID.rawValue
            )
        }
        try Self.forbid(restoresProductionTrading, "restoresProductionTrading")
        try Self.forbid(connectsBrokerGateway, "connectsBrokerGateway")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.evidenceID = evidenceID
        self.sourceIssueID = sourceIssueID
        self.rollbackReady = rollbackReady
        self.noTradePriorityHeld = noTradePriorityHeld
        self.incidentStopActive = incidentStopActive
        self.auditSteps = auditSteps
        self.restoresProductionTrading = restoresProductionTrading
        self.connectsBrokerGateway = connectsBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        sourceIssueID.rawValue == "GH-667"
            && rollbackReady
            && noTradePriorityHeld
            && incidentStopActive
            && auditSteps == Self.requiredAuditSteps
            && restoresProductionTrading == false
            && connectsBrokerGateway == false
            && submitsRealOrder == false
            && productionCutoverAuthorized == false
    }

    public static let requiredAuditSteps = [
        "capture blocked rehearsal command",
        "freeze no-trade state",
        "record rollback reason",
        "keep production trading disabled"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030RollbackDrill.\(field)")
        }
    }
}

/// ReleaseV030BlockedCommandDrillRecord 是 submit / cancel / replace 被阻断的审计记录。
public struct ReleaseV030BlockedCommandDrillRecord: Codable, Equatable, Sendable {
    public let command: ReleaseV030ControlDrillCommandKind
    public let scenario: ReleaseV030ControlDrillScenario
    public let commandGatewayRoute: String
    public let blockReason: String
    public let audited: Bool
    public let blockedBeforeExecutionClient: Bool
    public let blockedBeforeBrokerGateway: Bool
    public let rollbackEvidenceID: Identifier?
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let bypassesCommandGateway: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool

    public init(
        command: ReleaseV030ControlDrillCommandKind,
        scenario: ReleaseV030ControlDrillScenario,
        commandGatewayRoute: String? = nil,
        blockReason: String,
        audited: Bool = true,
        blockedBeforeExecutionClient: Bool = true,
        blockedBeforeBrokerGateway: Bool = true,
        rollbackEvidenceID: Identifier? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        bypassesCommandGateway: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeState: Bool = false
    ) throws {
        let resolvedRoute = commandGatewayRoute
            ?? "command-gateway/release-v0.3.0/drill/\(scenario.rawValue)/\(command.rawValue)"
        guard resolvedRoute.hasPrefix("command-gateway/release-v0.3.0/drill/"),
              blockReason.isEmpty == false,
              audited,
              blockedBeforeExecutionClient,
              blockedBeforeBrokerGateway else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030ControlDrill.blockedCommand",
                expected: "audited blocked command before ExecutionClient and broker gateway",
                actual: "\(scenario.rawValue):\(command.rawValue)"
            )
        }
        if scenario == .rollback, rollbackEvidenceID == nil {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030ControlDrill.rollbackEvidenceID",
                expected: "rollback evidence identity",
                actual: "nil"
            )
        }
        for forbidden in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("bypassesCommandGateway", bypassesCommandGateway),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("bypassesOMS", bypassesOMS),
            ("bypassesEventStore", bypassesEventStore),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("bypassesNoTradeState", bypassesNoTradeState)
        ] where forbidden.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030ControlDrill.\(forbidden.0)")
        }

        self.command = command
        self.scenario = scenario
        self.commandGatewayRoute = resolvedRoute
        self.blockReason = blockReason
        self.audited = audited
        self.blockedBeforeExecutionClient = blockedBeforeExecutionClient
        self.blockedBeforeBrokerGateway = blockedBeforeBrokerGateway
        self.rollbackEvidenceID = rollbackEvidenceID
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.bypassesCommandGateway = bypassesCommandGateway
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesEventStore = bypassesEventStore
        self.bypassesKillSwitch = bypassesKillSwitch
        self.bypassesNoTradeState = bypassesNoTradeState
    }

    public var blockHeld: Bool {
        commandGatewayRoute.hasPrefix("command-gateway/release-v0.3.0/drill/")
            && blockReason.isEmpty == false
            && audited
            && blockedBeforeExecutionClient
            && blockedBeforeBrokerGateway
            && productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && bypassesCommandGateway == false
            && bypassesRiskEngine == false
            && bypassesOMS == false
            && bypassesEventStore == false
            && bypassesKillSwitch == false
            && bypassesNoTradeState == false
    }
}

/// ReleaseV030KillSwitchNoTradeRollbackDrillEvidence 汇总 GH-667 drill。
public struct ReleaseV030KillSwitchNoTradeRollbackDrillEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let upstreamSurfaceAnchor: String
    public let upstreamSurfaceIssueID: Identifier
    public let upstreamSurfaceStatus: ReleaseV030RehearsalSurfaceStatus
    public let requirements: [ReleaseV030ControlDrillRequirement]
    public let forbiddenCapabilities: [ReleaseV030ControlDrillForbiddenCapability]
    public let rollbackEvidence: ReleaseV030RollbackDrillEvidence
    public let blockedCommands: [ReleaseV030BlockedCommandDrillRecord]
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public init(
        issueID: Identifier = Identifier.constant("GH-667"),
        upstreamIssueID: Identifier = Identifier.constant("GH-666"),
        downstreamIssueID: Identifier = Identifier.constant("GH-668"),
        canonicalQueueRange: String = "GH-657..GH-670",
        releaseVersion: String = "v0.3.0",
        upstreamSurfaceAnchor: String = Self.requiredUpstreamSurfaceAnchor,
        upstreamSurfaceIssueID: Identifier = Identifier.constant("GH-666"),
        upstreamSurfaceStatus: ReleaseV030RehearsalSurfaceStatus = .blocked,
        requirements: [ReleaseV030ControlDrillRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030ControlDrillForbiddenCapability] = Self.requiredForbiddenCapabilities,
        rollbackEvidence: ReleaseV030RollbackDrillEvidence,
        blockedCommands: [ReleaseV030BlockedCommandDrillRecord],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-667",
              upstreamIssueID.rawValue == "GH-666",
              downstreamIssueID.rawValue == "GH-668",
              canonicalQueueRange == "GH-657..GH-670",
              releaseVersion == "v0.3.0",
              upstreamSurfaceAnchor == Self.requiredUpstreamSurfaceAnchor,
              upstreamSurfaceIssueID.rawValue == "GH-666",
              upstreamSurfaceStatus == .blocked,
              requirements == Self.requiredRequirements,
              forbiddenCapabilities == Self.requiredForbiddenCapabilities,
              rollbackEvidence.boundaryHeld,
              Set(blockedCommands.map(\.command)) == Set(ReleaseV030ControlDrillCommandKind.allCases),
              Set(blockedCommands.map(\.scenario)) == Set(ReleaseV030ControlDrillScenario.allCases),
              blockedCommands.count == ReleaseV030ControlDrillCommandKind.allCases.count
                * ReleaseV030ControlDrillScenario.allCases.count,
              blockedCommands.allSatisfy(\.blockHeld),
              validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030ControlDrill.evidence",
                expected: "GH-667 complete kill switch no-trade rollback drill evidence",
                actual: "\(blockedCommands.count)"
            )
        }
        for forbidden in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("startsNextMilestone", startsNextMilestone)
        ] where forbidden.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030ControlDrill.\(forbidden.0)")
        }

        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.upstreamSurfaceAnchor = upstreamSurfaceAnchor
        self.upstreamSurfaceIssueID = upstreamSurfaceIssueID
        self.upstreamSurfaceStatus = upstreamSurfaceStatus
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.rollbackEvidence = rollbackEvidence
        self.blockedCommands = blockedCommands
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-667"
            && upstreamIssueID.rawValue == "GH-666"
            && downstreamIssueID.rawValue == "GH-668"
            && upstreamSurfaceAnchor == Self.requiredUpstreamSurfaceAnchor
            && upstreamSurfaceStatus == .blocked
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && rollbackEvidence.boundaryHeld
            && blockedCommands.allSatisfy(\.blockHeld)
            && validationAnchors == Self.requiredValidationAnchors
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && startsNextMilestone == false
    }

    public func records(for scenario: ReleaseV030ControlDrillScenario) -> [ReleaseV030BlockedCommandDrillRecord] {
        blockedCommands.filter { $0.scenario == scenario }
    }

    public static let requiredUpstreamSurfaceAnchor = "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"
    public static let requiredRequirements = ReleaseV030ControlDrillRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030ControlDrillForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V030-11-KILL-SWITCH-NO-TRADE-ROLLBACK-DRILL",
        "V030-11-KILL-SWITCH-BLOCKS-COMMANDS",
        "V030-11-NO-TRADE-BLOCKS-COMMANDS",
        "V030-11-ROLLBACK-EVIDENCE",
        "V030-11-BLOCKED-COMMAND-AUDIT",
        "TVM-RELEASE-V030-KILL-SWITCH-NOTRADE-ROLLBACK-DRILL"
    ]
}

/// ReleaseV030KillSwitchNoTradeRollbackDrill 生成 GH-667 deterministic control drill。
public enum ReleaseV030KillSwitchNoTradeRollbackDrill {
    public static func deterministicEvidence(
        upstreamSurface: ReleaseV030RehearsalSurfaceEvidence? = nil
    ) throws -> ReleaseV030KillSwitchNoTradeRollbackDrillEvidence {
        let upstream = try upstreamSurface ?? ReleaseV030RehearsalSurface.deterministicEvidence()
        guard upstream.evidenceHeld,
              upstream.issueID.rawValue == "GH-666",
              upstream.downstreamIssueID.rawValue == "GH-667",
              upstream.validationAnchors.contains(
                  ReleaseV030KillSwitchNoTradeRollbackDrillEvidence.requiredUpstreamSurfaceAnchor
              ),
              upstream.runStatus == .blocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030ControlDrill.upstreamSurface",
                expected: "GH-666 blocked Dashboard / CLI surface for GH-667",
                actual: upstream.issueID.rawValue
            )
        }
        let rollback = try ReleaseV030RollbackDrillEvidence()
        return try ReleaseV030KillSwitchNoTradeRollbackDrillEvidence(
            rollbackEvidence: rollback,
            blockedCommands: deterministicBlockedCommands(rollbackEvidence: rollback)
        )
    }

    private static func deterministicBlockedCommands(
        rollbackEvidence: ReleaseV030RollbackDrillEvidence
    ) throws -> [ReleaseV030BlockedCommandDrillRecord] {
        try ReleaseV030ControlDrillScenario.allCases.flatMap { scenario in
            try ReleaseV030ControlDrillCommandKind.allCases.map { command in
                try ReleaseV030BlockedCommandDrillRecord(
                    command: command,
                    scenario: scenario,
                    blockReason: blockReason(command: command, scenario: scenario),
                    rollbackEvidenceID: scenario == .rollback ? rollbackEvidence.evidenceID : nil
                )
            }
        }
    }

    private static func blockReason(
        command: ReleaseV030ControlDrillCommandKind,
        scenario: ReleaseV030ControlDrillScenario
    ) -> String {
        switch scenario {
        case .killSwitch:
            "kill switch active blocks rehearsal \(command.rawValue)"
        case .noTrade:
            "no-trade state blocks rehearsal \(command.rawValue)"
        case .rollback:
            "rollback drill blocks rehearsal \(command.rawValue) and records incident evidence"
        }
    }
}
