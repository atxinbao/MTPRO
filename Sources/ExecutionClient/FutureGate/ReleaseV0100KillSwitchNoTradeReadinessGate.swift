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
    case inactive
    case unknown
    case stale
    case unavailable
}

/// ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState 表示 GH-922 本地 readiness evidence 的新鲜度。
///
/// 这些状态只用于本地 readiness 判断。`unknown`、`stale` 和 `unavailable` 必须 fail closed；
/// 它们不会触发 endpoint connection、broker command 或任何 submit / cancel / replace。
public enum ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fresh
    case unknown
    case stale
    case unavailable
}

/// ReleaseV0110KillSwitchNoTradeReviewState 表示 GH-922 operator review evidence 状态。
///
/// Review evidence 只能决定是否具备 approval-request eligibility；它不等于 production cutover
/// approval，也不授权真实交易。
public enum ReleaseV0110KillSwitchNoTradeReviewState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case reviewed
    case pending
    case unknown
    case unavailable
}

/// ReleaseV0110KillSwitchNoTradeApprovalRequestEligibility 是 GH-922 的本地 eligibility 分类。
public enum ReleaseV0110KillSwitchNoTradeApprovalRequestEligibility: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blocked
    case eligibleForApprovalRequest = "eligible-for-approval-request"
}

/// ReleaseV0120KillSwitchNoTradeTrustworthyObservationAnchors 固定 GH-959 的可信观测验证锚点。
///
/// GH-959 只把 kill switch / no-trade state 的 freshness / review 判断改为从本地
/// source artifact evidence 推导；它不授权 production cutover、不连接 endpoint / broker、
/// 不读取 secret，也不提交 testnet 或 production order。
public enum ReleaseV0120KillSwitchNoTradeTrustworthyObservationAnchors {
    public static let validationAnchors = [
        "GH-959-VERIFY-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS",
        "TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS",
        "V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS",
        "V0120-008-OBSERVED-EXPIRES-REVIEWED-SOURCE-EVIDENCE",
        "V0120-008-DERIVED-FRESHNESS-AND-REVIEW-STATE",
        "V0120-008-STALE-UNREVIEWED-MISMATCH-FAIL-CLOSED",
        "V0120-008-APPROVAL-REQUEST-ONLY-NO-CUTOVER",
        "V0120-008-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0110KillSwitchNoTradeReadinessSnapshot 是 GH-922 对 kill switch 或 no-trade 的单项状态快照。
///
/// 只有 `inactive + fresh + reviewed` 可以进入 approval-request eligibility。任何 active、
/// unknown、stale、unavailable 或未 reviewed 状态都必须 fail closed，并继续阻断订单命令。
/// GH-959 起，freshness / review state 必须由观测时间和本地 source artifact evidence 推导，
/// 不能由 caller 直接声明为 fresh / reviewed。
public struct ReleaseV0110KillSwitchNoTradeReadinessSnapshot: Codable, Equatable, Sendable {
    public let name: String
    public let state: ReleaseV0100KillSwitchNoTradeReadinessState
    public let observedAt: Date
    public let expiresAt: Date
    public let reviewedAt: Date?
    public let reviewedBy: String?
    public let sourceArtifact: String
    public let sourceChecksum: String
    public let sourceRunID: Identifier
    public let freshnessState: ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState
    public let reviewState: ReleaseV0110KillSwitchNoTradeReviewState

    public var approvalRequestEligible: Bool {
        state == .inactive
            && freshnessState == .fresh
            && reviewState == .reviewed
    }

    public var failClosed: Bool {
        approvalRequestEligible == false
    }

    public init(
        name: String,
        state: ReleaseV0100KillSwitchNoTradeReadinessState,
        observedAt: Date,
        expiresAt: Date,
        reviewedAt: Date?,
        reviewedBy: String?,
        sourceArtifact: String,
        sourceChecksum: String,
        sourceRunID: Identifier,
        expectedSourceArtifact: String? = nil,
        expectedSourceChecksum: String? = nil,
        expectedSourceRunID: Identifier? = nil,
        evaluatedAt: Date
    ) throws {
        guard name.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "readinessSnapshotName", expected: "non-empty", actual: name)
        }
        guard ProductionReadinessArtifactDescriptor.isSafeRelativePath(sourceArtifact) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceArtifact",
                expected: "safe relative readiness artifact path",
                actual: sourceArtifact
            )
        }
        guard ReadinessAssessmentManifestV2.isValidSHA256Checksum(sourceChecksum) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceChecksum",
                expected: "sha256:<64 lowercase hex>",
                actual: sourceChecksum
            )
        }
        guard sourceRunID.rawValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceRunID",
                expected: "non-empty",
                actual: sourceRunID.rawValue
            )
        }

        self.name = name
        self.state = state
        self.observedAt = observedAt
        self.expiresAt = expiresAt
        self.reviewedAt = reviewedAt
        self.reviewedBy = reviewedBy
        self.sourceArtifact = sourceArtifact
        self.sourceChecksum = sourceChecksum
        self.sourceRunID = sourceRunID

        let sourceEvidenceMatches =
            sourceArtifact == (expectedSourceArtifact ?? sourceArtifact)
                && sourceChecksum == (expectedSourceChecksum ?? sourceChecksum)
                && sourceRunID == (expectedSourceRunID ?? sourceRunID)

        self.freshnessState = Self.deriveFreshnessState(
            observedAt: observedAt,
            expiresAt: expiresAt,
            evaluatedAt: evaluatedAt,
            sourceEvidenceMatches: sourceEvidenceMatches
        )
        self.reviewState = Self.deriveReviewState(
            observedAt: observedAt,
            expiresAt: expiresAt,
            reviewedAt: reviewedAt,
            reviewedBy: reviewedBy,
            evaluatedAt: evaluatedAt,
            sourceEvidenceMatches: sourceEvidenceMatches
        )
    }
}

private extension ReleaseV0110KillSwitchNoTradeReadinessSnapshot {
    static func deriveFreshnessState(
        observedAt: Date,
        expiresAt: Date,
        evaluatedAt: Date,
        sourceEvidenceMatches: Bool
    ) -> ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState {
        guard sourceEvidenceMatches else {
            return .unavailable
        }
        guard observedAt <= evaluatedAt else {
            return .unknown
        }
        guard expiresAt > observedAt, expiresAt > evaluatedAt else {
            return .stale
        }
        return .fresh
    }

    static func deriveReviewState(
        observedAt: Date,
        expiresAt: Date,
        reviewedAt: Date?,
        reviewedBy: String?,
        evaluatedAt: Date,
        sourceEvidenceMatches: Bool
    ) -> ReleaseV0110KillSwitchNoTradeReviewState {
        guard sourceEvidenceMatches else {
            return .unavailable
        }
        guard let reviewedAt, let reviewedBy, reviewedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return .pending
        }
        guard reviewedAt >= observedAt, reviewedAt <= evaluatedAt, reviewedAt < expiresAt else {
            return .unknown
        }
        return .reviewed
    }
}

/// ReleaseV0110KillSwitchNoTradeReadinessStateModel 是 GH-922 的 v0.11.0 readiness state model。
///
/// Model 只描述本地 readiness artifact 能否进入 approval-request eligibility；即便 eligibility
/// 为 true，也仍保持 production cutover blocked、order submission disabled、testnet order disabled、
/// broker / endpoint / secret / OMS / Dashboard command 全部关闭。
public struct ReleaseV0110KillSwitchNoTradeReadinessStateModel: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let killSwitchSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot
    public let noTradeSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot
    public let approvalRequestEligibility: ReleaseV0110KillSwitchNoTradeApprovalRequestEligibility
    public let productionCutoverBlocked: Bool
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
    public let validationAnchors: [String]

    public var approvalRequestEligible: Bool {
        killSwitchSnapshot.approvalRequestEligible
            && noTradeSnapshot.approvalRequestEligible
            && approvalRequestEligibility == .eligibleForApprovalRequest
            && productionCutoverBlocked
            && productionCapabilitiesDisabled
    }

    public var failClosed: Bool {
        approvalRequestEligible == false
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
    }

    public var stateModelHeld: Bool {
        issueID.rawValue == "GH-922"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-913"]
            && killSwitchSnapshot.name == "kill-switch"
            && noTradeSnapshot.name == "no-trade"
            && approvalRequestEligibility == Self.expectedEligibility(
                killSwitchSnapshot: killSwitchSnapshot,
                noTradeSnapshot: noTradeSnapshot
            )
            && productionCutoverBlocked
            && productionCapabilitiesDisabled
            && validationAnchors == Self.requiredValidationAnchors
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-922"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-913")],
        killSwitchSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot,
        noTradeSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot,
        approvalRequestEligibility: ReleaseV0110KillSwitchNoTradeApprovalRequestEligibility? = nil,
        productionCutoverBlocked: Bool = true,
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
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let resolvedEligibility = approvalRequestEligibility ?? Self.expectedEligibility(
            killSwitchSnapshot: killSwitchSnapshot,
            noTradeSnapshot: noTradeSnapshot
        )
        let expectedEligibility = Self.expectedEligibility(
            killSwitchSnapshot: killSwitchSnapshot,
            noTradeSnapshot: noTradeSnapshot
        )

        guard resolvedEligibility == expectedEligibility else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalRequestEligibility",
                expected: expectedEligibility.rawValue,
                actual: resolvedEligibility.rawValue
            )
        }
        guard productionCutoverBlocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "productionCutoverBlocked", expected: "true", actual: "false")
        }
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
            liveCommandEnabled: liveCommandEnabled
        )
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.killSwitchSnapshot = killSwitchSnapshot
        self.noTradeSnapshot = noTradeSnapshot
        self.approvalRequestEligibility = resolvedEligibility
        self.productionCutoverBlocked = productionCutoverBlocked
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
        self.validationAnchors = validationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-922-VERIFY-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL",
        "TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL",
        "V0110-010-KILL-SWITCH-NO-TRADE-STATE-MODEL",
        "V0110-010-UNKNOWN-STALE-UNAVAILABLE-FAIL-CLOSED",
        "V0110-010-INACTIVE-FRESH-REVIEWED-APPROVAL-REQUEST-ELIGIBILITY",
        "V0110-010-NO-PRODUCTION-CUTOVER-ORDER"
    ]

    public static func blockedFixture() throws -> ReleaseV0110KillSwitchNoTradeReadinessStateModel {
        let evaluatedAt = Date(timeIntervalSince1970: 1_812_500_000)
        return try ReleaseV0110KillSwitchNoTradeReadinessStateModel(
            killSwitchSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot(
                name: "kill-switch",
                state: .active,
                observedAt: evaluatedAt.addingTimeInterval(-60),
                expiresAt: evaluatedAt.addingTimeInterval(300),
                reviewedAt: evaluatedAt.addingTimeInterval(-30),
                reviewedBy: "Codex",
                sourceArtifact: ".local/mtpro/readiness/assessments/gh-959/kill-switch.json",
                sourceChecksum: "sha256:\(String(repeating: "a", count: 64))",
                sourceRunID: Identifier.constant("gh-959-kill-switch-run"),
                evaluatedAt: evaluatedAt
            ),
            noTradeSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot(
                name: "no-trade",
                state: .active,
                observedAt: evaluatedAt.addingTimeInterval(-60),
                expiresAt: evaluatedAt.addingTimeInterval(300),
                reviewedAt: evaluatedAt.addingTimeInterval(-30),
                reviewedBy: "Codex",
                sourceArtifact: ".local/mtpro/readiness/assessments/gh-959/no-trade.json",
                sourceChecksum: "sha256:\(String(repeating: "b", count: 64))",
                sourceRunID: Identifier.constant("gh-959-no-trade-run"),
                evaluatedAt: evaluatedAt
            )
        )
    }

    public static func approvalRequestEligibleFixture() throws -> ReleaseV0110KillSwitchNoTradeReadinessStateModel {
        let evaluatedAt = Date(timeIntervalSince1970: 1_812_500_000)
        return try ReleaseV0110KillSwitchNoTradeReadinessStateModel(
            killSwitchSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot(
                name: "kill-switch",
                state: .inactive,
                observedAt: evaluatedAt.addingTimeInterval(-60),
                expiresAt: evaluatedAt.addingTimeInterval(300),
                reviewedAt: evaluatedAt.addingTimeInterval(-30),
                reviewedBy: "Codex",
                sourceArtifact: ".local/mtpro/readiness/assessments/gh-959/kill-switch.json",
                sourceChecksum: "sha256:\(String(repeating: "a", count: 64))",
                sourceRunID: Identifier.constant("gh-959-kill-switch-run"),
                evaluatedAt: evaluatedAt
            ),
            noTradeSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot(
                name: "no-trade",
                state: .inactive,
                observedAt: evaluatedAt.addingTimeInterval(-60),
                expiresAt: evaluatedAt.addingTimeInterval(300),
                reviewedAt: evaluatedAt.addingTimeInterval(-30),
                reviewedBy: "Codex",
                sourceArtifact: ".local/mtpro/readiness/assessments/gh-959/no-trade.json",
                sourceChecksum: "sha256:\(String(repeating: "b", count: 64))",
                sourceRunID: Identifier.constant("gh-959-no-trade-run"),
                evaluatedAt: evaluatedAt
            )
        )
    }

    public static func expectedEligibility(
        killSwitchSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot,
        noTradeSnapshot: ReleaseV0110KillSwitchNoTradeReadinessSnapshot
    ) -> ReleaseV0110KillSwitchNoTradeApprovalRequestEligibility {
        killSwitchSnapshot.approvalRequestEligible && noTradeSnapshot.approvalRequestEligible
            ? .eligibleForApprovalRequest
            : .blocked
    }
}

private extension ReleaseV0110KillSwitchNoTradeReadinessStateModel {
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
        liveCommandEnabled: Bool
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
            ("liveCommandEnabled", liveCommandEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
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
