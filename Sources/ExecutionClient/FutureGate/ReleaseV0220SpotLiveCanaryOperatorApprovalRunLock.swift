import DomainModel
import Foundation

/// ReleaseV0220SpotLiveCanaryApprovalState 固定 GH-1310 的 operator approval 状态。
///
/// `approvedUnused` 只表示 Human operator 已批准一次 Binance Spot live canary
/// transport session 可以进入后续 gate。GH-1310 不读取 secret、不连接 endpoint、不发送订单。
public enum ReleaseV0220SpotLiveCanaryApprovalState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missing = "missing"
    case approvedUnused = "approved-unused"
    case approvedUsed = "approved-used"
    case expired = "expired"
    case rejected = "rejected"
    case mismatchedScope = "mismatched-scope"
}

/// ReleaseV0220SpotLiveCanaryRunLockState 表达 GH-1310 的 one-shot run lock 状态。
public enum ReleaseV0220SpotLiveCanaryRunLockState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case available = "available"
    case acquired = "acquired"
    case consumed = "consumed"
    case blockedConcurrentRun = "blocked-concurrent-run"
    case blockedApprovalReuse = "blocked-approval-reuse"
}

/// ReleaseV0220SpotLiveCanaryApprovalFailureClass 固定 GH-1310 的 fail-closed 分类。
public enum ReleaseV0220SpotLiveCanaryApprovalFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missingApproval = "missing approval"
    case expiredApproval = "expired approval"
    case rejectedApproval = "rejected approval"
    case approvalScopeMismatch = "approval scope mismatch"
    case approvalAlreadyUsed = "approval already used"
    case concurrentRunLockHeld = "concurrent run lock held"
    case lockAlreadyConsumed = "lock already consumed"
}

/// ReleaseV0220SpotLiveCanaryApprovalRequirement 固定 GH-1310 的验收要求。
public enum ReleaseV0220SpotLiveCanaryApprovalRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamLiveCanaryTransportContractHeld = "upstream live canary transport contract held"
    case binanceSpotOnly = "Binance Spot only"
    case productionLiveEnvironmentOnly = "productionLive environment only"
    case explicitOperatorApprovalRequired = "explicit operator approval required"
    case approvalBindsVenueProductEnvironmentSymbolNotionalOrderType =
        "approval binds venue / product / environment / symbol / notional / order type"
    case approvalMustBeUnused = "approval must be unused"
    case approvalMustBeFresh = "approval must be fresh"
    case approvalReuseFailsClosed = "approval reuse fails closed"
    case scopeMismatchFailsClosed = "scope mismatch fails closed"
    case oneShotRunLockRequired = "one-shot run lock required"
    case concurrentRunFailsClosed = "concurrent run fails closed"
    case downstreamCredentialSecretReadGateRequired = "downstream credential secret-read gate required"
    case noSecretRead = "no secret read"
    case noEndpointConnection = "no endpoint connection"
    case noOrderSubmission = "no order submission"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0220SpotLiveCanaryApprovalForbiddenCapability 枚举 GH-1310 仍拒绝的能力。
public enum ReleaseV0220SpotLiveCanaryApprovalForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case approvalBypass = "approval bypass"
    case approvalReuse = "approval reuse"
    case staleApprovalUse = "stale approval use"
    case crossScopeApprovalUse = "cross-scope approval use"
    case concurrentRun = "concurrent run"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretReadByThisIssue = "production secret read by this issue"
    case secretValueLogging = "secret value logging"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case signedAccountEndpointRuntime = "signed account endpoint runtime"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case futuresExecution = "Futures execution"
    case okxActiveImplementation = "OKX active implementation"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0220SpotLiveCanaryApprovalScope 是 GH-1310 的审批作用域。
///
/// Scope 必须精确绑定 venue / product / environment / symbol / notional / order type。
/// 后续任何 secret read、signed preflight 或 live submit 都只能消费同一 scope。
public struct ReleaseV0220SpotLiveCanaryApprovalScope: Codable, Equatable, Sendable {
    public let scopeID: Identifier
    public let venue: String
    public let productType: String
    public let environment: String
    public let symbol: String
    public let notionalMinorUnits: Int
    public let orderType: String

    public var scopeHeld: Bool {
        venue == "Binance"
            && productType == "spot"
            && environment == "productionLive"
            && symbol == "BTCUSDT"
            && notionalMinorUnits == 500
            && orderType == "LIMIT"
    }

    public init(
        scopeID: Identifier = Identifier.constant("gh-1310-binance-spot-live-canary-approval-scope"),
        venue: String = "Binance",
        productType: String = "spot",
        environment: String = "productionLive",
        symbol: String = "BTCUSDT",
        notionalMinorUnits: Int = 500,
        orderType: String = "LIMIT"
    ) {
        self.scopeID = scopeID
        self.venue = venue
        self.productType = productType
        self.environment = environment
        self.symbol = symbol
        self.notionalMinorUnits = notionalMinorUnits
        self.orderType = orderType
    }

    public static func deterministicFixture() -> ReleaseV0220SpotLiveCanaryApprovalScope {
        ReleaseV0220SpotLiveCanaryApprovalScope()
    }

    public static func mismatchedSymbolFixture() -> ReleaseV0220SpotLiveCanaryApprovalScope {
        ReleaseV0220SpotLiveCanaryApprovalScope(symbol: "ETHUSDT")
    }
}

/// ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock 是 GH-1310 的 approval session
/// 与 one-shot run lock evidence。
///
/// 它只验证 approval / scope / lock 的本地可消费状态。The approval cannot be reused.
/// 真实 secret read、signed endpoint、submit / status / cancel transport 仍留给后续 issue。
public struct ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let approvalState: ReleaseV0220SpotLiveCanaryApprovalState
    public let runLockState: ReleaseV0220SpotLiveCanaryRunLockState
    public let failureClass: ReleaseV0220SpotLiveCanaryApprovalFailureClass?
    public let approvalScope: ReleaseV0220SpotLiveCanaryApprovalScope
    public let requestedScope: ReleaseV0220SpotLiveCanaryApprovalScope
    public let approvalEvidenceID: String
    public let redactedOperatorID: String
    public let redactedApprovalSummary: String
    public let approvedAtUnixSeconds: Int
    public let expiresAtUnixSeconds: Int
    public let requestedAtUnixSeconds: Int
    public let usedAtUnixSeconds: Int?
    public let requirements: [ReleaseV0220SpotLiveCanaryApprovalRequirement]
    public let forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryApprovalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let upstreamTransportContractHeld: Bool
    public let operatorApprovalRequired: Bool
    public let approvalEvidencePresent: Bool
    public let approvalScopeMatched: Bool
    public let approvalUnused: Bool
    public let approvalFresh: Bool
    public let oneShotRunLockRequired: Bool
    public let concurrentRunBlocked: Bool
    public let credentialSecretReadEnabledByThisIssue: Bool
    public let signedEndpointRuntimeEnabledByThisIssue: Bool
    public let liveOrderSubmitEnabledByThisIssue: Bool
    public let liveOrderStatusCancelEnabledByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByThisIssue: Bool
    public let productionEndpointConnectionEnabledByThisIssue: Bool
    public let productionBrokerConnectionEnabledByThisIssue: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var approvalSessionHeld: Bool {
        issueID.rawValue == "GH-1310"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1309"]
            && downstreamIssueID.rawValue == "GH-1311"
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && approvalState == .approvedUnused
            && runLockState == .available
            && failureClass == nil
            && approvalScope.scopeHeld
            && requestedScope == approvalScope
            && approvalEvidenceID == Self.requiredApprovalEvidenceID
            && redactedOperatorID == Self.requiredRedactedOperatorID
            && Self.isRedactedSummary(redactedApprovalSummary)
            && approvedAtUnixSeconds < expiresAtUnixSeconds
            && requestedAtUnixSeconds >= approvedAtUnixSeconds
            && requestedAtUnixSeconds < expiresAtUnixSeconds
            && usedAtUnixSeconds == nil
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && approvalFlagsHeld
            && forbiddenCapabilitiesClosed
    }

    public var failClosedEvidenceHeld: Bool {
        approvalSessionHeld == false
            && failureClass != nil
            && forbiddenCapabilitiesClosed
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var approvalFlagsHeld: Bool {
        upstreamTransportContractHeld
            && operatorApprovalRequired
            && approvalEvidencePresent
            && approvalScopeMatched
            && approvalUnused
            && approvalFresh
            && oneShotRunLockRequired
            && concurrentRunBlocked
    }

    public var forbiddenCapabilitiesClosed: Bool {
        credentialSecretReadEnabledByThisIssue == false
            && signedEndpointRuntimeEnabledByThisIssue == false
            && liveOrderSubmitEnabledByThisIssue == false
            && liveOrderStatusCancelEnabledByThisIssue == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByThisIssue == false
            && productionEndpointConnectionEnabledByThisIssue == false
            && productionBrokerConnectionEnabledByThisIssue == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingButtonEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1310-v0220-operator-approval-run-lock"),
        issueID: Identifier = Identifier.constant("GH-1310"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1309")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1311"),
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        approvalState: ReleaseV0220SpotLiveCanaryApprovalState = .approvedUnused,
        runLockState: ReleaseV0220SpotLiveCanaryRunLockState = .available,
        failureClass: ReleaseV0220SpotLiveCanaryApprovalFailureClass? = nil,
        approvalScope: ReleaseV0220SpotLiveCanaryApprovalScope = .deterministicFixture(),
        requestedScope: ReleaseV0220SpotLiveCanaryApprovalScope = .deterministicFixture(),
        approvalEvidenceID: String = Self.requiredApprovalEvidenceID,
        redactedOperatorID: String = Self.requiredRedactedOperatorID,
        redactedApprovalSummary: String = Self.requiredRedactedApprovalSummary,
        approvedAtUnixSeconds: Int = 1_772_640_000,
        expiresAtUnixSeconds: Int = 1_772_643_600,
        requestedAtUnixSeconds: Int = 1_772_640_300,
        usedAtUnixSeconds: Int? = nil,
        requirements: [ReleaseV0220SpotLiveCanaryApprovalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryApprovalForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        upstreamTransportContractHeld: Bool = true,
        operatorApprovalRequired: Bool = true,
        approvalEvidencePresent: Bool = true,
        approvalScopeMatched: Bool = true,
        approvalUnused: Bool = true,
        approvalFresh: Bool = true,
        oneShotRunLockRequired: Bool = true,
        concurrentRunBlocked: Bool = true,
        credentialSecretReadEnabledByThisIssue: Bool = false,
        signedEndpointRuntimeEnabledByThisIssue: Bool = false,
        liveOrderSubmitEnabledByThisIssue: Bool = false,
        liveOrderStatusCancelEnabledByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByThisIssue: Bool = false,
        productionEndpointConnectionEnabledByThisIssue: Bool = false,
        productionBrokerConnectionEnabledByThisIssue: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.approvalState = approvalState
        self.runLockState = runLockState
        self.failureClass = failureClass
        self.approvalScope = approvalScope
        self.requestedScope = requestedScope
        self.approvalEvidenceID = approvalEvidenceID
        self.redactedOperatorID = redactedOperatorID
        self.redactedApprovalSummary = redactedApprovalSummary
        self.approvedAtUnixSeconds = approvedAtUnixSeconds
        self.expiresAtUnixSeconds = expiresAtUnixSeconds
        self.requestedAtUnixSeconds = requestedAtUnixSeconds
        self.usedAtUnixSeconds = usedAtUnixSeconds
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.upstreamTransportContractHeld = upstreamTransportContractHeld
        self.operatorApprovalRequired = operatorApprovalRequired
        self.approvalEvidencePresent = approvalEvidencePresent
        self.approvalScopeMatched = approvalScopeMatched
        self.approvalUnused = approvalUnused
        self.approvalFresh = approvalFresh
        self.oneShotRunLockRequired = oneShotRunLockRequired
        self.concurrentRunBlocked = concurrentRunBlocked
        self.credentialSecretReadEnabledByThisIssue = credentialSecretReadEnabledByThisIssue
        self.signedEndpointRuntimeEnabledByThisIssue = signedEndpointRuntimeEnabledByThisIssue
        self.liveOrderSubmitEnabledByThisIssue = liveOrderSubmitEnabledByThisIssue
        self.liveOrderStatusCancelEnabledByThisIssue = liveOrderStatusCancelEnabledByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByThisIssue = productionSecretReadEnabledByThisIssue
        self.productionEndpointConnectionEnabledByThisIssue = productionEndpointConnectionEnabledByThisIssue
        self.productionBrokerConnectionEnabledByThisIssue = productionBrokerConnectionEnabledByThisIssue
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease

        guard approvalSessionHeld || failClosedEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.operatorApprovalRunLock",
                expected: "approved one-shot session or classified fail-closed evidence",
                actual: "invalid approval/run-lock evidence"
            )
        }
    }

    public static func deterministicFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock()
    }

    public static func missingApprovalFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock(
            approvalState: .missing,
            failureClass: .missingApproval,
            approvalEvidencePresent: false,
            approvalUnused: false
        )
    }

    public static func staleApprovalFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock(
            approvalState: .expired,
            failureClass: .expiredApproval,
            requestedAtUnixSeconds: 1_772_644_000,
            approvalFresh: false
        )
    }

    public static func mismatchedScopeFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock(
            approvalState: .mismatchedScope,
            failureClass: .approvalScopeMismatch,
            requestedScope: .mismatchedSymbolFixture(),
            approvalScopeMatched: false
        )
    }

    public static func reusedApprovalFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock(
            approvalState: .approvedUsed,
            runLockState: .blockedApprovalReuse,
            failureClass: .approvalAlreadyUsed,
            usedAtUnixSeconds: 1_772_640_500,
            approvalUnused: false
        )
    }

    public static func concurrentRunFixture() throws -> ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock {
        try ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock(
            runLockState: .blockedConcurrentRun,
            failureClass: .concurrentRunLockHeld
        )
    }

    public static let requiredApprovalEvidenceID =
        "human-operator-approval-evidence:binance:spot:productionLive:v0.22.0:one-shot-live-canary"
    public static let requiredRedactedOperatorID = "operator=<redacted>"
    public static let requiredRedactedApprovalSummary =
        "approval=<redacted>; venue=Binance; product=spot; environment=productionLive; symbol=BTCUSDT; notionalMinorUnits=500; orderType=LIMIT; oneShot=true"

    public static let requiredRequirements: [ReleaseV0220SpotLiveCanaryApprovalRequirement] = [
        .upstreamLiveCanaryTransportContractHeld,
        .binanceSpotOnly,
        .productionLiveEnvironmentOnly,
        .explicitOperatorApprovalRequired,
        .approvalBindsVenueProductEnvironmentSymbolNotionalOrderType,
        .approvalMustBeUnused,
        .approvalMustBeFresh,
        .approvalReuseFailsClosed,
        .scopeMismatchFailsClosed,
        .oneShotRunLockRequired,
        .concurrentRunFailsClosed,
        .downstreamCredentialSecretReadGateRequired,
        .noSecretRead,
        .noEndpointConnection,
        .noOrderSubmission,
        .noProductionCutover
    ]

    public static let requiredForbiddenCapabilities: [ReleaseV0220SpotLiveCanaryApprovalForbiddenCapability] = [
        .approvalBypass,
        .approvalReuse,
        .staleApprovalUse,
        .crossScopeApprovalUse,
        .concurrentRun,
        .productionTradingEnabledByDefault,
        .productionSecretReadByThisIssue,
        .secretValueLogging,
        .productionEndpointConnection,
        .productionBrokerConnection,
        .signedAccountEndpointRuntime,
        .orderSubmitCancelReplace,
        .futuresExecution,
        .okxActiveImplementation,
        .dashboardTradingButton,
        .dashboardOrderForm,
        .productionCutoverAuthorization,
        .tagOrReleasePublication
    ]

    public static let requiredValidationAnchors = [
        "GH-1310-VERIFY-V0220-OPERATOR-APPROVAL-RUN-LOCK",
        "TVM-RELEASE-V0220-OPERATOR-APPROVAL-RUN-LOCK",
        "V0220-002-BLOCKED-BY-GH1309",
        "V0220-002-OPERATOR-APPROVAL-SESSION",
        "V0220-002-SCOPE-BOUND-APPROVAL",
        "V0220-002-APPROVAL-REUSE-FAILS-CLOSED",
        "V0220-002-MISSING-STALE-MISMATCHED-FAILS-CLOSED",
        "V0220-002-ONE-SHOT-RUN-LOCK",
        "V0220-002-NO-SECRET-ENDPOINT-ORDER",
        "V0220-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1310ReleaseV0220OperatorApprovalSessionAndRunLock",
        "bash checks/verify-v0.22.0-operator-approval-run-lock.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]

    public static func isRedactedSummary(_ value: String) -> Bool {
        value.contains("<redacted>")
            && value.contains("oneShot=true")
            && value.contains("BTCUSDT")
            && value.contains("LIMIT")
            && !value.localizedCaseInsensitiveContains("apiKey=")
            && !value.localizedCaseInsensitiveContains("secret")
            && !value.localizedCaseInsensitiveContains("listenKey")
    }
}
