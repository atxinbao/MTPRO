import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ProductionCommandDispatchGateRequirement 固定 GH-646 的 command dispatch gate 必备门槛。
///
/// 这些 requirement 只描述 submit / cancel / replace 进入 future production-capable handoff 前的
/// CommandGateway、RiskEngine、ExecutionEngine、OMS 和 Event Store 证据链，不实现真实命令 runtime。
public enum ProductionCommandDispatchGateRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamEndpointConnectionGateRequired = "upstream endpoint connection gate required"
    case dashboardCLIDirectExecutionClientBlocked = "Dashboard / CLI direct ExecutionClient blocked"
    case commandGatewayOperatorApprovalRequired = "CommandGateway operator approval required"
    case riskEngineKillSwitchRequired = "RiskEngine kill switch required"
    case riskEngineNoTradeStateRequired = "RiskEngine no-trade state required"
    case riskEngineLimitChecksRequired = "RiskEngine limit checks required"
    case executionEngineRiskApprovedOnly = "ExecutionEngine accepts Risk-approved commands only"
    case omsLifecycleRecordingRequired = "OMS lifecycle recording required before handoff"
    case eventStoreAuditRequired = "Event Store audit required"
    case failedGateBlocksCommand = "failed gate blocks command"
}

/// ProductionCommandDispatchForbiddenCapability 枚举 GH-646 必须拒绝的 dispatch bypass。
public enum ProductionCommandDispatchForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboardDirectExecutionClient = "Dashboard direct ExecutionClient"
    case cliDirectExecutionClient = "CLI direct ExecutionClient"
    case operatorApprovalBypass = "operator approval bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case killSwitchBypass = "kill switch bypass"
    case noTradeStateBypass = "no-trade state bypass"
    case limitCheckBypass = "limit check bypass"
    case executionEngineAcceptsUnapprovedCommand = "ExecutionEngine accepts unapproved command"
    case omsLifecycleBypass = "OMS lifecycle bypass"
    case eventStoreBypass = "Event Store bypass"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretValueRead = "production secret value read"
    case realBrokerConnection = "real broker connection"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionCommandDispatchSourceKind 描述 command attempt 的来源。
///
/// 当前唯一可进入 gate chain 的来源是 CommandGateway。Dashboard / CLI 只能作为被阻断的 direct access
/// evidence，不得直达 ExecutionClient。
public enum ProductionCommandDispatchSourceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case commandGateway = "CommandGateway"
    case dashboardDirect = "Dashboard direct"
    case cliDirect = "CLI direct"
}

/// ProductionCommandDispatchOutcome 描述 GH-646 command attempt 的 gate 结果。
///
/// `recordedGatedHandoff` 只表示 deterministic handoff evidence 完整，不代表真实 broker order 或
/// production ExecutionClient call。
public enum ProductionCommandDispatchOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blockedDashboardDirectExecutionClient = "blocked: Dashboard direct ExecutionClient"
    case blockedCLIDirectExecutionClient = "blocked: CLI direct ExecutionClient"
    case blockedMissingOperatorApproval = "blocked: missing operator approval"
    case blockedKillSwitchActive = "blocked: kill switch active"
    case blockedNoTradeStateActive = "blocked: no-trade state active"
    case blockedLimitRejected = "blocked: limit rejected"
    case blockedExecutionEngineMissingRiskApproval = "blocked: ExecutionEngine missing Risk-approved command"
    case blockedOMSLifecycleMissing = "blocked: OMS lifecycle missing"
    case recordedGatedHandoff = "recorded: gated handoff evidence"
}

/// ProductionCommandDispatchAttemptEvidence 是 GH-646 的 submit / cancel / replace gate evidence row。
///
/// Evidence row 证明 command attempt 经过或被阻断于正确 gate。它不调用 ExecutionClient，不连接 broker，
/// 不提交 / 撤销 / 替换真实订单。
public struct ProductionCommandDispatchAttemptEvidence: Codable, Equatable, Sendable {
    public let attemptID: Identifier
    public let commandKind: L4LiveRiskPreTradeCommandKind
    public let source: ProductionCommandDispatchSourceKind
    public let outcome: ProductionCommandDispatchOutcome
    public let operatorApprovalPassed: Bool
    public let killSwitchPassed: Bool
    public let noTradeStatePassed: Bool
    public let limitChecksPassed: Bool
    public let riskEngineApproved: Bool
    public let executionEngineAccepted: Bool
    public let omsLifecycleRecorded: Bool
    public let eventStoreAuditRecorded: Bool
    public let commandBlocked: Bool
    public let dashboardDirectExecutionClientAttempt: Bool
    public let cliDirectExecutionClientAttempt: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var evidenceBoundaryHeld: Bool {
        eventStoreAuditRecorded
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && outcomeBoundaryHeld
    }

    private var allCommandGatesPassed: Bool {
        source == .commandGateway
            && operatorApprovalPassed
            && killSwitchPassed
            && noTradeStatePassed
            && limitChecksPassed
            && riskEngineApproved
            && executionEngineAccepted
            && omsLifecycleRecorded
            && dashboardDirectExecutionClientAttempt == false
            && cliDirectExecutionClientAttempt == false
    }

    private var outcomeBoundaryHeld: Bool {
        switch outcome {
        case .blockedDashboardDirectExecutionClient:
            return source == .dashboardDirect
                && dashboardDirectExecutionClientAttempt
                && cliDirectExecutionClientAttempt == false
                && commandBlocked
        case .blockedCLIDirectExecutionClient:
            return source == .cliDirect
                && cliDirectExecutionClientAttempt
                && dashboardDirectExecutionClientAttempt == false
                && commandBlocked
        case .blockedMissingOperatorApproval:
            return source == .commandGateway
                && operatorApprovalPassed == false
                && riskEngineApproved == false
                && executionEngineAccepted == false
                && omsLifecycleRecorded == false
                && commandBlocked
        case .blockedKillSwitchActive:
            return source == .commandGateway
                && operatorApprovalPassed
                && killSwitchPassed == false
                && riskEngineApproved == false
                && executionEngineAccepted == false
                && omsLifecycleRecorded == false
                && commandBlocked
        case .blockedNoTradeStateActive:
            return source == .commandGateway
                && operatorApprovalPassed
                && killSwitchPassed
                && noTradeStatePassed == false
                && riskEngineApproved == false
                && executionEngineAccepted == false
                && omsLifecycleRecorded == false
                && commandBlocked
        case .blockedLimitRejected:
            return source == .commandGateway
                && operatorApprovalPassed
                && killSwitchPassed
                && noTradeStatePassed
                && limitChecksPassed == false
                && riskEngineApproved == false
                && executionEngineAccepted == false
                && omsLifecycleRecorded == false
                && commandBlocked
        case .blockedExecutionEngineMissingRiskApproval:
            return source == .commandGateway
                && operatorApprovalPassed
                && killSwitchPassed
                && noTradeStatePassed
                && limitChecksPassed
                && riskEngineApproved == false
                && executionEngineAccepted == false
                && omsLifecycleRecorded == false
                && commandBlocked
        case .blockedOMSLifecycleMissing:
            return source == .commandGateway
                && operatorApprovalPassed
                && killSwitchPassed
                && noTradeStatePassed
                && limitChecksPassed
                && riskEngineApproved
                && executionEngineAccepted
                && omsLifecycleRecorded == false
                && commandBlocked
        case .recordedGatedHandoff:
            return allCommandGatesPassed
                && commandBlocked == false
        }
    }

    public init(
        attemptID: Identifier,
        commandKind: L4LiveRiskPreTradeCommandKind,
        source: ProductionCommandDispatchSourceKind,
        outcome: ProductionCommandDispatchOutcome,
        operatorApprovalPassed: Bool,
        killSwitchPassed: Bool,
        noTradeStatePassed: Bool,
        limitChecksPassed: Bool,
        riskEngineApproved: Bool,
        executionEngineAccepted: Bool,
        omsLifecycleRecorded: Bool,
        eventStoreAuditRecorded: Bool = true,
        commandBlocked: Bool,
        dashboardDirectExecutionClientAttempt: Bool = false,
        cliDirectExecutionClientAttempt: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard eventStoreAuditRecorded else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "eventStoreAuditRecorded",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.attemptID = attemptID
        self.commandKind = commandKind
        self.source = source
        self.outcome = outcome
        self.operatorApprovalPassed = operatorApprovalPassed
        self.killSwitchPassed = killSwitchPassed
        self.noTradeStatePassed = noTradeStatePassed
        self.limitChecksPassed = limitChecksPassed
        self.riskEngineApproved = riskEngineApproved
        self.executionEngineAccepted = executionEngineAccepted
        self.omsLifecycleRecorded = omsLifecycleRecorded
        self.eventStoreAuditRecorded = eventStoreAuditRecorded
        self.commandBlocked = commandBlocked
        self.dashboardDirectExecutionClientAttempt = dashboardDirectExecutionClientAttempt
        self.cliDirectExecutionClientAttempt = cliDirectExecutionClientAttempt
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder

        guard evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidenceBoundaryHeld",
                expected: "command dispatch attempt matches GH-646 fail-closed gate chain",
                actual: outcome.rawValue
            )
        }
    }
}

/// ProductionCommandDispatchGate 是 GH-646 的 CommandGateway -> RiskEngine -> ExecutionEngine -> OMS gate 合同。
///
/// 合同绑定 GH-645 endpoint connection gate，并固定 Dashboard / CLI 不能直达 ExecutionClient、CommandGateway
/// 必须检查 operator approval、RiskEngine 必须检查 kill switch / no-trade / limits、ExecutionEngine 只能接受
/// Risk-approved command、OMS 必须先记录 lifecycle。它不实现真实订单 dispatch。
public struct ProductionCommandDispatchGate: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamEndpointConnectionGateHeld: Bool
    public let allowedCommandSource: ProductionCommandDispatchSourceKind
    public let requirements: [ProductionCommandDispatchGateRequirement]
    public let forbiddenCapabilities: [ProductionCommandDispatchForbiddenCapability]
    public let attemptEvidence: [ProductionCommandDispatchAttemptEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let dashboardCLIDirectExecutionClientBlocked: Bool
    public let commandGatewayOperatorApprovalRequired: Bool
    public let riskEngineKillSwitchRequired: Bool
    public let riskEngineNoTradeStateRequired: Bool
    public let riskEngineLimitChecksRequired: Bool
    public let executionEngineRiskApprovedOnly: Bool
    public let omsLifecycleRecordingRequiredBeforeHandoff: Bool
    public let eventStoreAuditRequired: Bool
    public let failedGateBlocksCommand: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let realBrokerConnectionEnabled: Bool
    public let realOrderSubmissionEnabled: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-646"
            && upstreamIssueID.rawValue == "GH-645"
            && downstreamIssueID.rawValue == "GH-647"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName
            && upstreamEndpointConnectionGateHeld
            && allowedCommandSource == .commandGateway
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && attemptEvidence == Self.requiredAttemptEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && dashboardCLIDirectExecutionClientBlocked
            && commandGatewayOperatorApprovalRequired
            && riskEngineKillSwitchRequired
            && riskEngineNoTradeStateRequired
            && riskEngineLimitChecksRequired
            && executionEngineRiskApprovedOnly
            && omsLifecycleRecordingRequiredBeforeHandoff
            && eventStoreAuditRequired
            && failedGateBlocksCommand
            && productionDefaultsClosed
            && startsNextMilestone == false
    }

    public var dispatchGateCoverageHeld: Bool {
        Set(attemptEvidence.map(\.outcome)) == Set(ProductionCommandDispatchOutcome.allCases)
            && attemptEvidence.allSatisfy(\.evidenceBoundaryHeld)
            && attemptEvidence.filter(\.commandBlocked).allSatisfy { $0.outcome != .recordedGatedHandoff }
            && attemptEvidence.contains { $0.outcome == .recordedGatedHandoff && $0.commandBlocked == false }
    }

    public var surfaceDirectAccessBlocked: Bool {
        attemptEvidence.contains { $0.outcome == .blockedDashboardDirectExecutionClient }
            && attemptEvidence.contains { $0.outcome == .blockedCLIDirectExecutionClient }
            && attemptEvidence.allSatisfy { $0.callsExecutionClient == false }
    }

    public var productionDefaultsClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && realBrokerConnectionEnabled == false
            && realOrderSubmissionEnabled == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-646-production-command-dispatch-gate"),
        issueID: Identifier = Identifier.constant("GH-646"),
        upstreamIssueID: Identifier = Identifier.constant("GH-645"),
        downstreamIssueID: Identifier = Identifier.constant("GH-647"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = ProductionCutoverRuntimeHardeningContract.requiredProjectName,
        upstreamEndpointConnectionGateHeld: Bool = true,
        allowedCommandSource: ProductionCommandDispatchSourceKind = .commandGateway,
        requirements: [ProductionCommandDispatchGateRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionCommandDispatchForbiddenCapability] = Self.requiredForbiddenCapabilities,
        attemptEvidence: [ProductionCommandDispatchAttemptEvidence] = Self.requiredAttemptEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        dashboardCLIDirectExecutionClientBlocked: Bool = true,
        commandGatewayOperatorApprovalRequired: Bool = true,
        riskEngineKillSwitchRequired: Bool = true,
        riskEngineNoTradeStateRequired: Bool = true,
        riskEngineLimitChecksRequired: Bool = true,
        executionEngineRiskApprovedOnly: Bool = true,
        omsLifecycleRecordingRequiredBeforeHandoff: Bool = true,
        eventStoreAuditRequired: Bool = true,
        failedGateBlocksCommand: Bool = true,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        realBrokerConnectionEnabled: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            allowedCommandSource: allowedCommandSource,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            attemptEvidence: attemptEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamEndpointConnectionGateHeld: upstreamEndpointConnectionGateHeld,
            dashboardCLIDirectExecutionClientBlocked: dashboardCLIDirectExecutionClientBlocked,
            commandGatewayOperatorApprovalRequired: commandGatewayOperatorApprovalRequired,
            riskEngineKillSwitchRequired: riskEngineKillSwitchRequired,
            riskEngineNoTradeStateRequired: riskEngineNoTradeStateRequired,
            riskEngineLimitChecksRequired: riskEngineLimitChecksRequired,
            executionEngineRiskApprovedOnly: executionEngineRiskApprovedOnly,
            omsLifecycleRecordingRequiredBeforeHandoff: omsLifecycleRecordingRequiredBeforeHandoff,
            eventStoreAuditRequired: eventStoreAuditRequired,
            failedGateBlocksCommand: failedGateBlocksCommand
        )
        try Self.validateForbiddenFlags(
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            realBrokerConnectionEnabled: realBrokerConnectionEnabled,
            realOrderSubmissionEnabled: realOrderSubmissionEnabled,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamEndpointConnectionGateHeld = upstreamEndpointConnectionGateHeld
        self.allowedCommandSource = allowedCommandSource
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.attemptEvidence = attemptEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.dashboardCLIDirectExecutionClientBlocked = dashboardCLIDirectExecutionClientBlocked
        self.commandGatewayOperatorApprovalRequired = commandGatewayOperatorApprovalRequired
        self.riskEngineKillSwitchRequired = riskEngineKillSwitchRequired
        self.riskEngineNoTradeStateRequired = riskEngineNoTradeStateRequired
        self.riskEngineLimitChecksRequired = riskEngineLimitChecksRequired
        self.executionEngineRiskApprovedOnly = executionEngineRiskApprovedOnly
        self.omsLifecycleRecordingRequiredBeforeHandoff = omsLifecycleRecordingRequiredBeforeHandoff
        self.eventStoreAuditRequired = eventStoreAuditRequired
        self.failedGateBlocksCommand = failedGateBlocksCommand
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.realBrokerConnectionEnabled = realBrokerConnectionEnabled
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionCommandDispatchGate {
        let upstream = try ProductionEndpointConnectionGate.deterministicFixture()
        return try ProductionCommandDispatchGate(
            upstreamEndpointConnectionGateHeld: upstream.contractHeld
        )
    }

    public static let requiredRequirements = ProductionCommandDispatchGateRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionCommandDispatchForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE",
        "PCHR-04-DASHBOARD-CLI-NO-DIRECT-EXECUTIONCLIENT",
        "PCHR-04-COMMANDGATEWAY-OPERATOR-APPROVAL",
        "PCHR-04-RISKENGINE-KILL-NOTRADE-LIMITS",
        "PCHR-04-EXECUTIONENGINE-RISK-APPROVED-ONLY",
        "PCHR-04-OMS-LIFECYCLE-BEFORE-HANDOFF",
        "PCHR-04-FAILED-GATE-BLOCKS-COMMAND",
        "PCHR-04-NO-PRODUCTION-ORDER-AUTHORIZATION",
        "TVM-PCHR-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH646ProductionCommandDispatchGateRequiresCommandRiskExecutionOMSGates",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredAttemptEvidence: [ProductionCommandDispatchAttemptEvidence] = {
        do {
            return [
                try evidence(
                    suffix: "dashboard-direct",
                    commandKind: .submit,
                    source: .dashboardDirect,
                    outcome: .blockedDashboardDirectExecutionClient,
                    commandBlocked: true,
                    dashboardDirectExecutionClientAttempt: true
                ),
                try evidence(
                    suffix: "cli-direct",
                    commandKind: .cancel,
                    source: .cliDirect,
                    outcome: .blockedCLIDirectExecutionClient,
                    commandBlocked: true,
                    cliDirectExecutionClientAttempt: true
                ),
                try evidence(
                    suffix: "missing-operator-approval",
                    commandKind: .replace,
                    outcome: .blockedMissingOperatorApproval,
                    operatorApprovalPassed: false,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "kill-switch-active",
                    commandKind: .submit,
                    outcome: .blockedKillSwitchActive,
                    killSwitchPassed: false,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "no-trade-active",
                    commandKind: .cancel,
                    outcome: .blockedNoTradeStateActive,
                    noTradeStatePassed: false,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "limit-rejected",
                    commandKind: .replace,
                    outcome: .blockedLimitRejected,
                    limitChecksPassed: false,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "missing-risk-approval",
                    commandKind: .submit,
                    outcome: .blockedExecutionEngineMissingRiskApproval,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "oms-lifecycle-missing",
                    commandKind: .cancel,
                    outcome: .blockedOMSLifecycleMissing,
                    riskEngineApproved: true,
                    executionEngineAccepted: true,
                    omsLifecycleRecorded: false,
                    commandBlocked: true
                ),
                try evidence(
                    suffix: "recorded-gated-handoff",
                    commandKind: .replace,
                    outcome: .recordedGatedHandoff,
                    riskEngineApproved: true,
                    executionEngineAccepted: true,
                    omsLifecycleRecorded: true,
                    commandBlocked: false
                )
            ]
        } catch {
            preconditionFailure("GH-646 command dispatch attempt evidence must be valid: \(error)")
        }
    }()

    private static func evidence(
        suffix: String,
        commandKind: L4LiveRiskPreTradeCommandKind,
        source: ProductionCommandDispatchSourceKind = .commandGateway,
        outcome: ProductionCommandDispatchOutcome,
        operatorApprovalPassed: Bool = true,
        killSwitchPassed: Bool = true,
        noTradeStatePassed: Bool = true,
        limitChecksPassed: Bool = true,
        riskEngineApproved: Bool = false,
        executionEngineAccepted: Bool = false,
        omsLifecycleRecorded: Bool = false,
        commandBlocked: Bool,
        dashboardDirectExecutionClientAttempt: Bool = false,
        cliDirectExecutionClientAttempt: Bool = false
    ) throws -> ProductionCommandDispatchAttemptEvidence {
        try ProductionCommandDispatchAttemptEvidence(
            attemptID: Identifier.constant("gh-646-\(suffix)-attempt"),
            commandKind: commandKind,
            source: source,
            outcome: outcome,
            operatorApprovalPassed: operatorApprovalPassed,
            killSwitchPassed: killSwitchPassed,
            noTradeStatePassed: noTradeStatePassed,
            limitChecksPassed: limitChecksPassed,
            riskEngineApproved: riskEngineApproved,
            executionEngineAccepted: executionEngineAccepted,
            omsLifecycleRecorded: omsLifecycleRecorded,
            commandBlocked: commandBlocked,
            dashboardDirectExecutionClientAttempt: dashboardDirectExecutionClientAttempt,
            cliDirectExecutionClientAttempt: cliDirectExecutionClientAttempt
        )
    }
}

private extension ProductionCommandDispatchGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        allowedCommandSource: ProductionCommandDispatchSourceKind,
        requirements: [ProductionCommandDispatchGateRequirement],
        forbiddenCapabilities: [ProductionCommandDispatchForbiddenCapability],
        attemptEvidence: [ProductionCommandDispatchAttemptEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-643..GH-649", "GH-643..GH-649", canonicalQueueRange),
            (
                "projectName",
                projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                projectName
            ),
            ("allowedCommandSource", allowedCommandSource == .commandGateway, "CommandGateway", allowedCommandSource.rawValue),
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
                "attemptEvidence",
                attemptEvidence == requiredAttemptEvidence,
                requiredAttemptEvidence.map(\.attemptID.rawValue).joined(separator: ","),
                attemptEvidence.map(\.attemptID.rawValue).joined(separator: ",")
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

    static func validateRequiredTrueFlags(
        upstreamEndpointConnectionGateHeld: Bool,
        dashboardCLIDirectExecutionClientBlocked: Bool,
        commandGatewayOperatorApprovalRequired: Bool,
        riskEngineKillSwitchRequired: Bool,
        riskEngineNoTradeStateRequired: Bool,
        riskEngineLimitChecksRequired: Bool,
        executionEngineRiskApprovedOnly: Bool,
        omsLifecycleRecordingRequiredBeforeHandoff: Bool,
        eventStoreAuditRequired: Bool,
        failedGateBlocksCommand: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamEndpointConnectionGateHeld", upstreamEndpointConnectionGateHeld),
            ("dashboardCLIDirectExecutionClientBlocked", dashboardCLIDirectExecutionClientBlocked),
            ("commandGatewayOperatorApprovalRequired", commandGatewayOperatorApprovalRequired),
            ("riskEngineKillSwitchRequired", riskEngineKillSwitchRequired),
            ("riskEngineNoTradeStateRequired", riskEngineNoTradeStateRequired),
            ("riskEngineLimitChecksRequired", riskEngineLimitChecksRequired),
            ("executionEngineRiskApprovedOnly", executionEngineRiskApprovedOnly),
            ("omsLifecycleRecordingRequiredBeforeHandoff", omsLifecycleRecordingRequiredBeforeHandoff),
            ("eventStoreAuditRequired", eventStoreAuditRequired),
            ("failedGateBlocksCommand", failedGateBlocksCommand)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        realBrokerConnectionEnabled: Bool,
        realOrderSubmissionEnabled: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("realBrokerConnectionEnabled", realBrokerConnectionEnabled),
            ("realOrderSubmissionEnabled", realOrderSubmissionEnabled),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
