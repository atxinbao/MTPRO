import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0210SpotCanaryPreTradePathOutcome 固定 GH-1279 的 canary submit-intent
/// 前置组合 gate 判定。
///
/// `accepted` 只表示本地 canary submit intent 满足 risk / kill switch / no-trade /
/// approval / hard-limit gate，后续 GH-1280 仍必须单独实现受控 submit path。该结果本身
/// 不触达 adapter、不发送订单，也不授权 production cutover。
public enum ReleaseV0210SpotCanaryPreTradePathOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case accepted = "accepted"
    case rejected = "rejected"
}

/// ReleaseV0210SpotCanaryPreTradePathRejectReason 是 GH-1279 的 fail-closed 拒绝原因。
///
/// 任一风险、kill switch、no-trade、operator approval 或 hard-limit 条件失败，都必须在
/// submit intent 进入 GH-1280 受控 submit path 之前阻断，并写入 audit evidence。
public enum ReleaseV0210SpotCanaryPreTradePathRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case riskRejected = "risk rejected"
    case killSwitchActive = "kill switch active"
    case noTradeStateActive = "no-trade state active"
    case operatorApprovalMissing = "operator approval missing"
    case hardLimitRejected = "hard limit rejected"
}

/// ReleaseV0210SpotCanaryPreTradePathPolicy 固定 GH-1279 的组合 gate policy。
///
/// Policy 只描述 submit-intent 前置 eligibility。它不保存 credential、不连接 Binance
/// endpoint、不持有 raw order payload，也不实现 submit / cancel / replace。
public struct ReleaseV0210SpotCanaryPreTradePathPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let riskApproved: Bool
    public let killSwitchActive: Bool
    public let noTradeStateActive: Bool
    public let operatorApprovalGranted: Bool
    public let riskEvidenceReference: String
    public let killSwitchEvidenceReference: String
    public let noTradeEvidenceReference: String
    public let operatorApprovalEvidenceReference: String

    public var policyHeld: Bool {
        riskEvidenceReference == Self.requiredRiskEvidenceReference
            && killSwitchEvidenceReference == Self.requiredKillSwitchEvidenceReference
            && noTradeEvidenceReference == Self.requiredNoTradeEvidenceReference
            && operatorApprovalEvidenceReference == Self.requiredOperatorApprovalEvidenceReference
    }

    public var allControlGatesPass: Bool {
        riskApproved
            && killSwitchActive == false
            && noTradeStateActive == false
            && operatorApprovalGranted
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1279-v0210-spot-canary-pretrade-path-policy"),
        riskApproved: Bool = true,
        killSwitchActive: Bool = false,
        noTradeStateActive: Bool = false,
        operatorApprovalGranted: Bool = true,
        riskEvidenceReference: String = Self.requiredRiskEvidenceReference,
        killSwitchEvidenceReference: String = Self.requiredKillSwitchEvidenceReference,
        noTradeEvidenceReference: String = Self.requiredNoTradeEvidenceReference,
        operatorApprovalEvidenceReference: String = Self.requiredOperatorApprovalEvidenceReference
    ) throws {
        self.policyID = policyID
        self.riskApproved = riskApproved
        self.killSwitchActive = killSwitchActive
        self.noTradeStateActive = noTradeStateActive
        self.operatorApprovalGranted = operatorApprovalGranted
        self.riskEvidenceReference = riskEvidenceReference
        self.killSwitchEvidenceReference = killSwitchEvidenceReference
        self.noTradeEvidenceReference = noTradeEvidenceReference
        self.operatorApprovalEvidenceReference = operatorApprovalEvidenceReference

        guard policyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.preTradePath.policyEvidence",
                expected: Self.requiredEvidenceSummary,
                actual: evidenceSummary
            )
        }
    }

    public static func deterministicFixture() throws -> ReleaseV0210SpotCanaryPreTradePathPolicy {
        try ReleaseV0210SpotCanaryPreTradePathPolicy()
    }

    public static func riskRejectedFixture() throws -> ReleaseV0210SpotCanaryPreTradePathPolicy {
        try ReleaseV0210SpotCanaryPreTradePathPolicy(riskApproved: false)
    }

    public static func killSwitchFixture() throws -> ReleaseV0210SpotCanaryPreTradePathPolicy {
        try ReleaseV0210SpotCanaryPreTradePathPolicy(killSwitchActive: true)
    }

    public static func noTradeFixture() throws -> ReleaseV0210SpotCanaryPreTradePathPolicy {
        try ReleaseV0210SpotCanaryPreTradePathPolicy(noTradeStateActive: true)
    }

    public static func approvalMissingFixture() throws -> ReleaseV0210SpotCanaryPreTradePathPolicy {
        try ReleaseV0210SpotCanaryPreTradePathPolicy(operatorApprovalGranted: false)
    }

    public static let requiredRiskEvidenceReference = "RiskEngine pre-trade canary risk evidence held"
    public static let requiredKillSwitchEvidenceReference = "global kill switch inactive evidence held"
    public static let requiredNoTradeEvidenceReference = "global no-trade state inactive evidence held"
    public static let requiredOperatorApprovalEvidenceReference = "operator canary approval evidence held"
    public static let requiredEvidenceSummary =
        "risk=RiskEngine pre-trade canary risk evidence held; killSwitch=global kill switch inactive evidence held; noTrade=global no-trade state inactive evidence held; approval=operator canary approval evidence held"

    public var evidenceSummary: String {
        [
            "risk=\(riskEvidenceReference)",
            "killSwitch=\(killSwitchEvidenceReference)",
            "noTrade=\(noTradeEvidenceReference)",
            "approval=\(operatorApprovalEvidenceReference)"
        ].joined(separator: "; ")
    }
}

/// ReleaseV0210SpotCanaryPreTradePathDecision 是 GH-1279 的 submit-intent 前置组合判定。
///
/// Decision 必须先消费 GH-1278 hard-limit decision，再叠加 RiskEngine、global kill switch、
/// no-trade 和 approval gate。任何拒绝都必须保持 `canarySubmitIntentEligible == false`，
/// 并且不允许进入 adapter submit。
public struct ReleaseV0210SpotCanaryPreTradePathDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let policy: ReleaseV0210SpotCanaryPreTradePathPolicy
    public let upstreamHardLimitDecisionID: Identifier
    public let upstreamHardLimitOutcome: ReleaseV0210SpotCanaryHardLimitDecisionOutcome
    public let outcome: ReleaseV0210SpotCanaryPreTradePathOutcome
    public let rejectReasons: [ReleaseV0210SpotCanaryPreTradePathRejectReason]
    public let canarySubmitIntentEligible: Bool
    public let auditEvidenceEmitted: Bool
    public let riskGateEvaluatedBeforeSubmit: Bool
    public let killSwitchEvaluatedBeforeSubmit: Bool
    public let noTradeGateEvaluatedBeforeSubmit: Bool
    public let approvalGateEvaluatedBeforeSubmit: Bool
    public let hardLimitGateEvaluatedBeforeSubmit: Bool
    public let forwardsToControlledSubmitPath: Bool
    public let networkSubmitAttempted: Bool
    public let bypassPathAvailable: Bool
    public let dashboardCommandShortcutEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionHeld: Bool {
        policy.policyHeld
            && rejectReasons == Self.expectedRejectReasons(
                policy: policy,
                hardLimitDecisionOutcome: upstreamHardLimitOutcome
            )
            && acceptedOrRejectedStateHeld
            && auditEvidenceEmitted
            && gateOrderingHeld
            && forbiddenCapabilitiesClosed
    }

    public var acceptedOrRejectedStateHeld: Bool {
        if rejectReasons.isEmpty {
            return outcome == .accepted
                && canarySubmitIntentEligible
                && forwardsToControlledSubmitPath
        }
        return outcome == .rejected
            && canarySubmitIntentEligible == false
            && forwardsToControlledSubmitPath == false
    }

    public var gateOrderingHeld: Bool {
        riskGateEvaluatedBeforeSubmit
            && killSwitchEvaluatedBeforeSubmit
            && noTradeGateEvaluatedBeforeSubmit
            && approvalGateEvaluatedBeforeSubmit
            && hardLimitGateEvaluatedBeforeSubmit
    }

    public var forbiddenCapabilitiesClosed: Bool {
        networkSubmitAttempted == false
            && bypassPathAvailable == false
            && dashboardCommandShortcutEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        decisionID: Identifier? = nil,
        policy: ReleaseV0210SpotCanaryPreTradePathPolicy,
        hardLimitDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        auditEvidenceEmitted: Bool = true,
        riskGateEvaluatedBeforeSubmit: Bool = true,
        killSwitchEvaluatedBeforeSubmit: Bool = true,
        noTradeGateEvaluatedBeforeSubmit: Bool = true,
        approvalGateEvaluatedBeforeSubmit: Bool = true,
        hardLimitGateEvaluatedBeforeSubmit: Bool = true,
        networkSubmitAttempted: Bool = false,
        bypassPathAvailable: Bool = false,
        dashboardCommandShortcutEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        for (field, value) in [
            ("auditEvidenceEmitted", auditEvidenceEmitted),
            ("riskGateEvaluatedBeforeSubmit", riskGateEvaluatedBeforeSubmit),
            ("killSwitchEvaluatedBeforeSubmit", killSwitchEvaluatedBeforeSubmit),
            ("noTradeGateEvaluatedBeforeSubmit", noTradeGateEvaluatedBeforeSubmit),
            ("approvalGateEvaluatedBeforeSubmit", approvalGateEvaluatedBeforeSubmit),
            ("hardLimitGateEvaluatedBeforeSubmit", hardLimitGateEvaluatedBeforeSubmit)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.preTradePath.\(field)",
                expected: "true",
                actual: "false"
            )
        }
        for (field, value) in [
            ("networkSubmitAttempted", networkSubmitAttempted),
            ("bypassPathAvailable", bypassPathAvailable),
            ("dashboardCommandShortcutEnabled", dashboardCommandShortcutEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0210.preTradePath.\(field)")
        }

        let reasons = Self.expectedRejectReasons(
            policy: policy,
            hardLimitDecisionOutcome: hardLimitDecision.outcome
        )
        let resolvedOutcome: ReleaseV0210SpotCanaryPreTradePathOutcome =
            reasons.isEmpty ? .accepted : .rejected

        self.decisionID = decisionID
            ?? Self.deterministicID(
                policy: policy,
                hardLimitDecision: hardLimitDecision,
                outcome: resolvedOutcome
            )
        self.policy = policy
        self.upstreamHardLimitDecisionID = hardLimitDecision.decisionID
        self.upstreamHardLimitOutcome = hardLimitDecision.outcome
        self.outcome = resolvedOutcome
        self.rejectReasons = reasons
        self.canarySubmitIntentEligible = reasons.isEmpty
        self.auditEvidenceEmitted = auditEvidenceEmitted
        self.riskGateEvaluatedBeforeSubmit = riskGateEvaluatedBeforeSubmit
        self.killSwitchEvaluatedBeforeSubmit = killSwitchEvaluatedBeforeSubmit
        self.noTradeGateEvaluatedBeforeSubmit = noTradeGateEvaluatedBeforeSubmit
        self.approvalGateEvaluatedBeforeSubmit = approvalGateEvaluatedBeforeSubmit
        self.hardLimitGateEvaluatedBeforeSubmit = hardLimitGateEvaluatedBeforeSubmit
        self.forwardsToControlledSubmitPath = reasons.isEmpty
        self.networkSubmitAttempted = networkSubmitAttempted
        self.bypassPathAvailable = bypassPathAvailable
        self.dashboardCommandShortcutEnabled = dashboardCommandShortcutEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0210SpotCanaryPreTradePathPolicy,
        hardLimitDecisionOutcome: ReleaseV0210SpotCanaryHardLimitDecisionOutcome
    ) -> [ReleaseV0210SpotCanaryPreTradePathRejectReason] {
        var reasons: [ReleaseV0210SpotCanaryPreTradePathRejectReason] = []
        if policy.riskApproved == false {
            reasons.append(.riskRejected)
        }
        if policy.killSwitchActive {
            reasons.append(.killSwitchActive)
        }
        if policy.noTradeStateActive {
            reasons.append(.noTradeStateActive)
        }
        if policy.operatorApprovalGranted == false {
            reasons.append(.operatorApprovalMissing)
        }
        if hardLimitDecisionOutcome != .accepted {
            reasons.append(.hardLimitRejected)
        }
        return reasons
    }

    public static func deterministicID(
        policy: ReleaseV0210SpotCanaryPreTradePathPolicy,
        hardLimitDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        outcome: ReleaseV0210SpotCanaryPreTradePathOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1279-v0210-pretrade-path-decision",
                policy.policyID.rawValue,
                hardLimitDecision.decisionID.rawValue,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.preTradePath.decisionID"
        )
    }
}

/// ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence 汇总 GH-1279 的
/// RiskEngine / kill switch / no-trade / approval / hard-limit 组合 evidence。
///
/// Evidence 输出给 GH-1280 的受控 submit path，但本 issue 不创建 submit request、不接
/// broker endpoint、不启用 Dashboard command shortcut，也不授权 production cutover。
public struct ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamHardLimitEvidence: ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence
    public let acceptedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let riskRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let killSwitchRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let noTradeRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let approvalRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let hardLimitRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let riskEngineGateRequired: Bool
    public let globalKillSwitchGateRequired: Bool
    public let noTradeGateRequired: Bool
    public let approvalGateRequired: Bool
    public let canaryHardLimitGateRequired: Bool
    public let auditEvidenceRequiredForEveryRejection: Bool
    public let bypassPathAvailable: Bool
    public let dashboardCommandShortcutEnabled: Bool
    public let networkSubmitAttempted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1279"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1278"]
            && downstreamIssueID.rawValue == "GH-1280"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamHardLimitEvidence.evidenceHeld
            && decisionEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiredGatesHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var requiredGatesHeld: Bool {
        riskEngineGateRequired
            && globalKillSwitchGateRequired
            && noTradeGateRequired
            && approvalGateRequired
            && canaryHardLimitGateRequired
            && auditEvidenceRequiredForEveryRejection
    }

    public var decisionEvidenceHeld: Bool {
        acceptedDecision.decisionHeld
            && acceptedDecision.outcome == .accepted
            && acceptedDecision.canarySubmitIntentEligible
            && riskRejectedDecision.rejectReasons == [.riskRejected]
            && killSwitchRejectedDecision.rejectReasons == [.killSwitchActive]
            && noTradeRejectedDecision.rejectReasons == [.noTradeStateActive]
            && approvalRejectedDecision.rejectReasons == [.operatorApprovalMissing]
            && hardLimitRejectedDecision.rejectReasons == [.hardLimitRejected]
            && [
                riskRejectedDecision,
                killSwitchRejectedDecision,
                noTradeRejectedDecision,
                approvalRejectedDecision,
                hardLimitRejectedDecision
            ].allSatisfy { $0.decisionHeld && $0.outcome == .rejected && $0.canarySubmitIntentEligible == false }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        bypassPathAvailable == false
            && dashboardCommandShortcutEnabled == false
            && networkSubmitAttempted == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1279-release-v0.21.0-risk-kill-no-trade-pretrade-gate-evidence"),
        issueID: Identifier = Identifier.constant("GH-1279"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1278")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1280"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamHardLimitEvidence: ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        riskEngineGateRequired: Bool = true,
        globalKillSwitchGateRequired: Bool = true,
        noTradeGateRequired: Bool = true,
        approvalGateRequired: Bool = true,
        canaryHardLimitGateRequired: Bool = true,
        auditEvidenceRequiredForEveryRejection: Bool = true,
        bypassPathAvailable: Bool = false,
        dashboardCommandShortcutEnabled: Bool = false,
        networkSubmitAttempted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedHardLimitEvidence = try upstreamHardLimitEvidence
            ?? ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence.deterministicFixture()

        let accepted = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .deterministicFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.acceptedDecision
        )
        let riskRejected = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .riskRejectedFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.acceptedDecision
        )
        let killRejected = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .killSwitchFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.acceptedDecision
        )
        let noTradeRejected = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .noTradeFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.acceptedDecision
        )
        let approvalRejected = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .approvalMissingFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.acceptedDecision
        )
        let hardLimitRejected = try ReleaseV0210SpotCanaryPreTradePathDecision(
            policy: .deterministicFixture(),
            hardLimitDecision: resolvedHardLimitEvidence.notionalRejectedDecision
        )

        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueIDs: upstreamIssueIDs,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            upstreamHardLimitEvidence: resolvedHardLimitEvidence,
            acceptedDecision: accepted,
            riskRejectedDecision: riskRejected,
            killSwitchRejectedDecision: killRejected,
            noTradeRejectedDecision: noTradeRejected,
            approvalRejectedDecision: approvalRejected,
            hardLimitRejectedDecision: hardLimitRejected,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            riskEngineGateRequired: riskEngineGateRequired,
            globalKillSwitchGateRequired: globalKillSwitchGateRequired,
            noTradeGateRequired: noTradeGateRequired,
            approvalGateRequired: approvalGateRequired,
            canaryHardLimitGateRequired: canaryHardLimitGateRequired,
            auditEvidenceRequiredForEveryRejection: auditEvidenceRequiredForEveryRejection
        )
        try Self.validateForbiddenFlags(
            bypassPathAvailable: bypassPathAvailable,
            dashboardCommandShortcutEnabled: dashboardCommandShortcutEnabled,
            networkSubmitAttempted: networkSubmitAttempted,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamHardLimitEvidence = resolvedHardLimitEvidence
        self.acceptedDecision = accepted
        self.riskRejectedDecision = riskRejected
        self.killSwitchRejectedDecision = killRejected
        self.noTradeRejectedDecision = noTradeRejected
        self.approvalRejectedDecision = approvalRejected
        self.hardLimitRejectedDecision = hardLimitRejected
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.riskEngineGateRequired = riskEngineGateRequired
        self.globalKillSwitchGateRequired = globalKillSwitchGateRequired
        self.noTradeGateRequired = noTradeGateRequired
        self.approvalGateRequired = approvalGateRequired
        self.canaryHardLimitGateRequired = canaryHardLimitGateRequired
        self.auditEvidenceRequiredForEveryRejection = auditEvidenceRequiredForEveryRejection
        self.bypassPathAvailable = bypassPathAvailable
        self.dashboardCommandShortcutEnabled = dashboardCommandShortcutEnabled
        self.networkSubmitAttempted = networkSubmitAttempted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence
    {
        try ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors = [
        "GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE",
        "TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE",
        "V0210-007-RISKENGINE-PRETRADE-GATE",
        "V0210-007-GLOBAL-KILL-SWITCH-GATE",
        "V0210-007-NO-TRADE-GATE",
        "V0210-007-APPROVAL-GATE",
        "V0210-007-HARD-LIMIT-GATE",
        "V0210-007-AUDIT-EVIDENCE-NO-BYPASS",
        "V0210-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1279ReleaseV0210PreTradeRiskKillNoTradeGate",
        "bash checks/verify-v0.21.0-pretrade-risk-kill-notrade.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueIDs: [Identifier],
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        upstreamHardLimitEvidence: ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence,
        acceptedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        riskRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        killSwitchRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        noTradeRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        approvalRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        hardLimitRejectedDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1279", "GH-1279", issueID.rawValue),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-1278"], "GH-1278", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1280", "GH-1280", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            ("tradingEnvironment", tradingEnvironment == .productionLive, ReleaseV0181TradingEnvironment.productionLive.rawValue, tradingEnvironment.rawValue),
            ("upstreamHardLimitEvidence", upstreamHardLimitEvidence.evidenceHeld, "GH-1278 hard-limit evidence held", upstreamHardLimitEvidence.issueID.rawValue),
            ("acceptedDecision", acceptedDecision.decisionHeld && acceptedDecision.outcome == .accepted, "accepted pre-trade decision", acceptedDecision.outcome.rawValue),
            ("riskRejectedDecision", riskRejectedDecision.rejectReasons == [.riskRejected], "risk rejected", riskRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("killSwitchRejectedDecision", killSwitchRejectedDecision.rejectReasons == [.killSwitchActive], "kill switch rejected", killSwitchRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("noTradeRejectedDecision", noTradeRejectedDecision.rejectReasons == [.noTradeStateActive], "no-trade rejected", noTradeRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("approvalRejectedDecision", approvalRejectedDecision.rejectReasons == [.operatorApprovalMissing], "approval rejected", approvalRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("hardLimitRejectedDecision", hardLimitRejectedDecision.rejectReasons == [.hardLimitRejected], "hard-limit rejected", hardLimitRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.preTradePath.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        riskEngineGateRequired: Bool,
        globalKillSwitchGateRequired: Bool,
        noTradeGateRequired: Bool,
        approvalGateRequired: Bool,
        canaryHardLimitGateRequired: Bool,
        auditEvidenceRequiredForEveryRejection: Bool
    ) throws {
        for (field, value) in [
            ("riskEngineGateRequired", riskEngineGateRequired),
            ("globalKillSwitchGateRequired", globalKillSwitchGateRequired),
            ("noTradeGateRequired", noTradeGateRequired),
            ("approvalGateRequired", approvalGateRequired),
            ("canaryHardLimitGateRequired", canaryHardLimitGateRequired),
            ("auditEvidenceRequiredForEveryRejection", auditEvidenceRequiredForEveryRejection)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.preTradePath.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        bypassPathAvailable: Bool,
        dashboardCommandShortcutEnabled: Bool,
        networkSubmitAttempted: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("bypassPathAvailable", bypassPathAvailable),
            ("dashboardCommandShortcutEnabled", dashboardCommandShortcutEnabled),
            ("networkSubmitAttempted", networkSubmitAttempted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0210.preTradePath.\(field)")
        }
    }
}
