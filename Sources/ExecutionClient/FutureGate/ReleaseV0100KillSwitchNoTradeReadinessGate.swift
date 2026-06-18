import DomainModel
import Foundation

/// ReleaseV0100KillSwitchNoTradeReadinessEvidenceArtifactKind 固定 GH-884 的 readiness evidence 文件名。
public enum ReleaseV0100KillSwitchNoTradeReadinessEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case killSwitchReadiness = "kill_switch_readiness.json"
    case noTradeReadiness = "no_trade_readiness.json"
}

/// ReleaseV0100KillSwitchNoTradeReadinessRequirement 固定 GH-884 的 kill switch / no-trade readiness 要求。
public enum ReleaseV0100KillSwitchNoTradeReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamNoAuthorizationContractRequired = "upstream no-authorization contract required"
    case previousCapitalExposureReadinessRequired = "previous capital exposure readiness required"
    case killSwitchStateRequired = "killSwitchState required"
    case noTradeStateRequired = "noTradeState required"
    case lastOperatorReviewRequired = "lastOperatorReview required"
    case riskApprovalRequired = "riskApprovalRequired required"
    case cutoverBlockedIfKillSwitchActive = "cutover blocked if kill switch active"
    case cutoverBlockedIfNoTradeActive = "cutover blocked if no-trade active"
    case killSwitchReadinessEvidenceExists = "kill_switch_readiness.json evidence exists"
    case noTradeReadinessEvidenceExists = "no_trade_readiness.json evidence exists"
    case productionCutoverBlocked = "production cutover blocked"
}

/// ReleaseV0100KillSwitchNoTradeForbiddenCapability 枚举 GH-884 必须保持关闭的能力。
public enum ReleaseV0100KillSwitchNoTradeForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionCutoverUnblocked = "production cutover unblocked"
    case orderSubmissionEnabled = "order submission enabled"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionSecretValueRead = "production secret value read"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonEnabled = "trading button enabled"
    case orderFormEnabled = "order form enabled"
    case liveCommandEnabled = "live command enabled"
    case killSwitchBypassEnabled = "kill switch bypass enabled"
    case noTradeBypassEnabled = "no-trade bypass enabled"
}

/// ReleaseV0100KillSwitchNoTradeReadinessState 是 GH-884 的 deterministic gate state。
///
/// 该 state 只作为 readiness evidence，不代表运行中 broker、OMS 或 production command 状态。
public enum ReleaseV0100KillSwitchNoTradeReadinessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case active
}

/// ReleaseV0100KillSwitchNoTradeOperatorReview 记录人工复核与风险审批要求。
///
/// Review 只保存 reference-only evidence：最后一次 operator review marker 和 risk approval required。
/// 它不读取 secret、不连接 endpoint，也不把 review 转成交易许可。
public struct ReleaseV0100KillSwitchNoTradeOperatorReview: Codable, Equatable, Sendable {
    public let lastOperatorReview: String
    public let riskApprovalRequired: Bool

    public var reviewHeld: Bool {
        lastOperatorReview == ReleaseV0100KillSwitchNoTradeReadinessGate.requiredLastOperatorReview
            && riskApprovalRequired
    }

    public init(
        lastOperatorReview: String = ReleaseV0100KillSwitchNoTradeReadinessGate.requiredLastOperatorReview,
        riskApprovalRequired: Bool = true
    ) throws {
        guard lastOperatorReview == ReleaseV0100KillSwitchNoTradeReadinessGate.requiredLastOperatorReview else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lastOperatorReview",
                expected: ReleaseV0100KillSwitchNoTradeReadinessGate.requiredLastOperatorReview,
                actual: lastOperatorReview
            )
        }
        guard riskApprovalRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "riskApprovalRequired", expected: "true", actual: "false")
        }

        self.lastOperatorReview = lastOperatorReview
        self.riskApprovalRequired = riskApprovalRequired
    }
}

/// ReleaseV0100KillSwitchNoTradeReadinessArtifact 是 GH-884 的 evidence file row。
///
/// Artifact 只证明 readiness 文件名和本地 evidence flags。它不包含 broker / account response，
/// 不来自 endpoint connection，也不会解锁 production cutover。
public struct ReleaseV0100KillSwitchNoTradeReadinessArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100KillSwitchNoTradeReadinessEvidenceArtifactKind
    public let fileName: String
    public let evidenceExists: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool

    public var artifactHeld: Bool {
        fileName == kind.rawValue
            && evidenceExists
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
    }

    public init(
        kind: ReleaseV0100KillSwitchNoTradeReadinessEvidenceArtifactKind,
        fileName: String? = nil,
        evidenceExists: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "readinessEvidenceFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "readinessEvidenceExists", expected: "true", actual: "false")
        }
        guard containsBrokerOrAccountResponse == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsBrokerOrAccountResponse")
        }
        guard producedByEndpointConnection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("producedByEndpointConnection")
        }

        self.kind = kind
        self.fileName = resolvedFileName
        self.evidenceExists = evidenceExists
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
    }
}

/// ReleaseV0100KillSwitchNoTradeReadinessGate 是 GH-884 的 kill switch / no-trade readiness 合同。
///
/// Gate 只证明 production cutover readiness 仍被 kill switch 和 no-trade gate 阻断。它不授权
/// production cutover，不启用 OMS、不暴露 trading button / order form / live command。
public struct ReleaseV0100KillSwitchNoTradeReadinessGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamNoAuthorizationContractHeld: Bool
    public let previousCapitalExposureReadinessHeld: Bool
    public let killSwitchState: ReleaseV0100KillSwitchNoTradeReadinessState
    public let noTradeState: ReleaseV0100KillSwitchNoTradeReadinessState
    public let operatorReview: ReleaseV0100KillSwitchNoTradeOperatorReview
    public let cutoverBlockedIfKillSwitchActive: Bool
    public let cutoverBlockedIfNoTradeActive: Bool
    public let productionCutoverBlocked: Bool
    public let evidenceArtifacts: [ReleaseV0100KillSwitchNoTradeReadinessArtifact]
    public let requirements: [ReleaseV0100KillSwitchNoTradeReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0100KillSwitchNoTradeForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let cutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let killSwitchBypassEnabled: Bool
    public let noTradeBypassEnabled: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-884"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-883"]
            && downstreamIssueID.rawValue == "GH-885"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamNoAuthorizationContractHeld
            && previousCapitalExposureReadinessHeld
            && killSwitchState == .active
            && noTradeState == .active
            && operatorReview.reviewHeld
            && cutoverBlockedIfKillSwitchActive
            && cutoverBlockedIfNoTradeActive
            && productionCutoverBlocked
            && evidenceArtifacts == Self.requiredEvidenceArtifacts
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && orderSubmissionEnabled == false
            && testnetOrderSubmissionEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && killSwitchBypassEnabled == false
            && noTradeBypassEnabled == false
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-884-kill-switch-no-trade-readiness-gate"),
        issueID: Identifier = Identifier.constant("GH-884"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-878"), Identifier.constant("GH-883")],
        downstreamIssueID: Identifier = Identifier.constant("GH-885"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamNoAuthorizationContractHeld: Bool = true,
        previousCapitalExposureReadinessHeld: Bool = true,
        killSwitchState: ReleaseV0100KillSwitchNoTradeReadinessState = .active,
        noTradeState: ReleaseV0100KillSwitchNoTradeReadinessState = .active,
        operatorReview: ReleaseV0100KillSwitchNoTradeOperatorReview = Self.requiredOperatorReview,
        cutoverBlockedIfKillSwitchActive: Bool = true,
        cutoverBlockedIfNoTradeActive: Bool = true,
        productionCutoverBlocked: Bool = true,
        evidenceArtifacts: [ReleaseV0100KillSwitchNoTradeReadinessArtifact] = Self.requiredEvidenceArtifacts,
        requirements: [ReleaseV0100KillSwitchNoTradeReadinessRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100KillSwitchNoTradeForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        cutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        killSwitchBypassEnabled: Bool = false,
        noTradeBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            upstreamIssueIDs: upstreamIssueIDs,
            operatorReview: operatorReview,
            evidenceArtifacts: evidenceArtifacts,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredStateAndTrueFlags(
            upstreamNoAuthorizationContractHeld: upstreamNoAuthorizationContractHeld,
            previousCapitalExposureReadinessHeld: previousCapitalExposureReadinessHeld,
            killSwitchState: killSwitchState,
            noTradeState: noTradeState,
            cutoverBlockedIfKillSwitchActive: cutoverBlockedIfKillSwitchActive,
            cutoverBlockedIfNoTradeActive: cutoverBlockedIfNoTradeActive,
            productionCutoverBlocked: productionCutoverBlocked
        )
        try Self.validateForbiddenFlags(
            cutoverAuthorized: cutoverAuthorized,
            orderSubmissionEnabled: orderSubmissionEnabled,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonEnabled: tradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            killSwitchBypassEnabled: killSwitchBypassEnabled,
            noTradeBypassEnabled: noTradeBypassEnabled
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamNoAuthorizationContractHeld = upstreamNoAuthorizationContractHeld
        self.previousCapitalExposureReadinessHeld = previousCapitalExposureReadinessHeld
        self.killSwitchState = killSwitchState
        self.noTradeState = noTradeState
        self.operatorReview = operatorReview
        self.cutoverBlockedIfKillSwitchActive = cutoverBlockedIfKillSwitchActive
        self.cutoverBlockedIfNoTradeActive = cutoverBlockedIfNoTradeActive
        self.productionCutoverBlocked = productionCutoverBlocked
        self.evidenceArtifacts = evidenceArtifacts
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.cutoverAuthorized = cutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonEnabled = tradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.killSwitchBypassEnabled = killSwitchBypassEnabled
        self.noTradeBypassEnabled = noTradeBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100KillSwitchNoTradeReadinessGate {
        try ReleaseV0100KillSwitchNoTradeReadinessGate()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredLastOperatorReview = "manual-operator-review-required-before-production-cutover"
    public static let requiredRequirements = ReleaseV0100KillSwitchNoTradeReadinessRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100KillSwitchNoTradeForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-007-KILL-SWITCH-NO-TRADE-READINESS-GATE",
        "V0100-007-KILL-SWITCH-STATE",
        "V0100-007-NO-TRADE-STATE",
        "V0100-007-LAST-OPERATOR-REVIEW",
        "V0100-007-RISK-APPROVAL-REQUIRED",
        "V0100-007-CUTOVER-BLOCKED-IF-KILL-SWITCH-ACTIVE",
        "V0100-007-CUTOVER-BLOCKED-IF-NO-TRADE-ACTIVE",
        "V0100-007-KILL-SWITCH-READINESS-JSON",
        "V0100-007-NO-TRADE-READINESS-JSON",
        "V0100-007-PRODUCTION-CUTOVER-BLOCKED",
        "V0100-007-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-884-VERIFY-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE",
        "TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH884KillSwitchNoTradeReadinessGateBlocksCutoverAndOrders",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredOperatorReview: ReleaseV0100KillSwitchNoTradeOperatorReview = {
        do {
            return try ReleaseV0100KillSwitchNoTradeOperatorReview()
        } catch {
            preconditionFailure("GH-884 operator review evidence must be valid: \(error)")
        }
    }()

    public static let requiredEvidenceArtifacts: [ReleaseV0100KillSwitchNoTradeReadinessArtifact] = {
        do {
            return [
                try ReleaseV0100KillSwitchNoTradeReadinessArtifact(kind: .killSwitchReadiness),
                try ReleaseV0100KillSwitchNoTradeReadinessArtifact(kind: .noTradeReadiness)
            ]
        } catch {
            preconditionFailure("GH-884 readiness evidence artifacts must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100KillSwitchNoTradeReadinessGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        upstreamIssueIDs: [Identifier],
        operatorReview: ReleaseV0100KillSwitchNoTradeOperatorReview,
        evidenceArtifacts: [ReleaseV0100KillSwitchNoTradeReadinessArtifact],
        requirements: [ReleaseV0100KillSwitchNoTradeReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0100KillSwitchNoTradeForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-883"], "GH-878,GH-883", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("operatorReview", operatorReview == requiredOperatorReview, requiredLastOperatorReview, operatorReview.lastOperatorReview),
            ("evidenceArtifacts", evidenceArtifacts == requiredEvidenceArtifacts, requiredEvidenceArtifacts.map(\.fileName).joined(separator: ","), evidenceArtifacts.map(\.fileName).joined(separator: ",")),
            ("requirements", requirements == requiredRequirements, requiredRequirements.map(\.rawValue).joined(separator: ","), requirements.map(\.rawValue).joined(separator: ",")),
            ("forbiddenCapabilities", forbiddenCapabilities == requiredForbiddenCapabilities, requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","), forbiddenCapabilities.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredStateAndTrueFlags(
        upstreamNoAuthorizationContractHeld: Bool,
        previousCapitalExposureReadinessHeld: Bool,
        killSwitchState: ReleaseV0100KillSwitchNoTradeReadinessState,
        noTradeState: ReleaseV0100KillSwitchNoTradeReadinessState,
        cutoverBlockedIfKillSwitchActive: Bool,
        cutoverBlockedIfNoTradeActive: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        guard killSwitchState == .active else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "killSwitchState", expected: "active", actual: killSwitchState.rawValue)
        }
        guard noTradeState == .active else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "noTradeState", expected: "active", actual: noTradeState.rawValue)
        }
        let requiredTrueFlags = [
            ("upstreamNoAuthorizationContractHeld", upstreamNoAuthorizationContractHeld),
            ("previousCapitalExposureReadinessHeld", previousCapitalExposureReadinessHeld),
            ("cutoverBlockedIfKillSwitchActive", cutoverBlockedIfKillSwitchActive),
            ("cutoverBlockedIfNoTradeActive", cutoverBlockedIfNoTradeActive),
            ("productionCutoverBlocked", productionCutoverBlocked)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        cutoverAuthorized: Bool,
        orderSubmissionEnabled: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        killSwitchBypassEnabled: Bool,
        noTradeBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("orderSubmissionEnabled", orderSubmissionEnabled),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonEnabled", tradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("killSwitchBypassEnabled", killSwitchBypassEnabled),
            ("noTradeBypassEnabled", noTradeBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
