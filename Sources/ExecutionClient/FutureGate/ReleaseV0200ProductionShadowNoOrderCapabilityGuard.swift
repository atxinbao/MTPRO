import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowOrderCapability 固定 GH-1246 必须拒绝的订单能力。
///
/// 这些 case 只用于表达 production-shadow profile 的禁止能力面。它们不是可执行命令，
/// 不能被映射成 ExecutionClient request、Dashboard command、CLI order command 或 broker call。
public enum ReleaseV0200ProductionShadowOrderCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// ReleaseV0200ProductionShadowOrderCommandSurface 固定 no-order guard 覆盖的入口。
///
/// `dashboard` 和 `cli` 是 #1246 的绕过检查入口：它们只能得到 read-only blocked evidence，
/// 不能绕过 guard 创建真实 order intent。
public enum ReleaseV0200ProductionShadowOrderCommandSurface: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case executionClient = "execution-client"
    case dashboard
    case cli
}

/// ReleaseV0200ProductionShadowNoOrderAttemptState 表达单次订单能力尝试的 fail-closed 状态。
public enum ReleaseV0200ProductionShadowNoOrderAttemptState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitBlocked = "submit-blocked"
    case cancelBlocked = "cancel-blocked"
    case replaceBlocked = "replace-blocked"
    case dashboardBypassBlocked = "dashboard-bypass-blocked"
    case cliBypassBlocked = "cli-bypass-blocked"
}

/// ReleaseV0200ProductionShadowNoOrderFailureClass 固定 #1246 的失败分类。
public enum ReleaseV0200ProductionShadowNoOrderFailureClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitAttemptBlocked = "submit attempt blocked"
    case cancelAttemptBlocked = "cancel attempt blocked"
    case replaceAttemptBlocked = "replace attempt blocked"
    case dashboardBypassAttemptBlocked = "dashboard bypass attempt blocked"
    case cliBypassAttemptBlocked = "cli bypass attempt blocked"
}

/// ReleaseV0200ProductionShadowNoOrderAttemptEvidence 表达一个入口下的订单能力拒绝证据。
///
/// Evidence 只保存脱敏 summary 和 fail-closed classification。它不保存 symbol / quantity /
/// order id / client order id，不构造 URLRequest，不生成 signed material，不调用 transport，也不落盘
/// order payload。
public struct ReleaseV0200ProductionShadowNoOrderAttemptEvidence: Codable, Equatable, Sendable {
    public let attemptID: Identifier
    public let surface: ReleaseV0200ProductionShadowOrderCommandSurface
    public let capability: ReleaseV0200ProductionShadowOrderCapability
    public let state: ReleaseV0200ProductionShadowNoOrderAttemptState
    public let failureClass: ReleaseV0200ProductionShadowNoOrderFailureClass
    public let redactedEvidenceSummary: String
    public let productionShadowReadinessContractHeld: Bool
    public let readOnlyEndpointAllowlistHeld: Bool
    public let realOrderIntentCreated: Bool
    public let signedOrderMaterialGenerated: Bool
    public let orderEndpointTouched: Bool
    public let transportInvoked: Bool
    public let orderPayloadPersisted: Bool
    public let dashboardBypassAllowed: Bool
    public let cliBypassAllowed: Bool

    public var attemptBlockedHeld: Bool {
        Self.expectedState(surface: surface, capability: capability) == state
            && Self.expectedFailureClass(surface: surface, capability: capability) == failureClass
            && Self.isRedactedEvidenceSummary(
                redactedEvidenceSummary,
                surface: surface,
                capability: capability,
                state: state
            )
            && upstreamReadinessHeld
            && forbiddenOrderSideEffectsHeld
    }

    public var upstreamReadinessHeld: Bool {
        productionShadowReadinessContractHeld && readOnlyEndpointAllowlistHeld
    }

    public var forbiddenOrderSideEffectsHeld: Bool {
        realOrderIntentCreated == false
            && signedOrderMaterialGenerated == false
            && orderEndpointTouched == false
            && transportInvoked == false
            && orderPayloadPersisted == false
            && dashboardBypassAllowed == false
            && cliBypassAllowed == false
    }

    public init(
        attemptID: Identifier? = nil,
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability,
        state: ReleaseV0200ProductionShadowNoOrderAttemptState? = nil,
        failureClass: ReleaseV0200ProductionShadowNoOrderFailureClass? = nil,
        redactedEvidenceSummary: String? = nil,
        productionShadowReadinessContractHeld: Bool = true,
        readOnlyEndpointAllowlistHeld: Bool = true,
        realOrderIntentCreated: Bool = false,
        signedOrderMaterialGenerated: Bool = false,
        orderEndpointTouched: Bool = false,
        transportInvoked: Bool = false,
        orderPayloadPersisted: Bool = false,
        dashboardBypassAllowed: Bool = false,
        cliBypassAllowed: Bool = false
    ) throws {
        let resolvedState = state ?? Self.expectedState(surface: surface, capability: capability)
        let resolvedFailure = failureClass ?? Self.expectedFailureClass(surface: surface, capability: capability)
        let resolvedSummary = redactedEvidenceSummary ?? Self.defaultEvidenceSummary(
            surface: surface,
            capability: capability,
            state: resolvedState
        )
        let resolvedID = attemptID ?? Self.deterministicID(
            surface: surface,
            capability: capability,
            state: resolvedState
        )
        try Self.validate(
            surface: surface,
            capability: capability,
            state: resolvedState,
            failureClass: resolvedFailure,
            redactedEvidenceSummary: resolvedSummary,
            productionShadowReadinessContractHeld: productionShadowReadinessContractHeld,
            readOnlyEndpointAllowlistHeld: readOnlyEndpointAllowlistHeld,
            realOrderIntentCreated: realOrderIntentCreated,
            signedOrderMaterialGenerated: signedOrderMaterialGenerated,
            orderEndpointTouched: orderEndpointTouched,
            transportInvoked: transportInvoked,
            orderPayloadPersisted: orderPayloadPersisted,
            dashboardBypassAllowed: dashboardBypassAllowed,
            cliBypassAllowed: cliBypassAllowed
        )
        self.attemptID = resolvedID
        self.surface = surface
        self.capability = capability
        self.state = resolvedState
        self.failureClass = resolvedFailure
        self.redactedEvidenceSummary = resolvedSummary
        self.productionShadowReadinessContractHeld = productionShadowReadinessContractHeld
        self.readOnlyEndpointAllowlistHeld = readOnlyEndpointAllowlistHeld
        self.realOrderIntentCreated = realOrderIntentCreated
        self.signedOrderMaterialGenerated = signedOrderMaterialGenerated
        self.orderEndpointTouched = orderEndpointTouched
        self.transportInvoked = transportInvoked
        self.orderPayloadPersisted = orderPayloadPersisted
        self.dashboardBypassAllowed = dashboardBypassAllowed
        self.cliBypassAllowed = cliBypassAllowed
    }

    public static func deterministicFixtures() throws -> [ReleaseV0200ProductionShadowNoOrderAttemptEvidence] {
        [
            try ReleaseV0200ProductionShadowNoOrderAttemptEvidence(
                surface: .executionClient,
                capability: .submit
            ),
            try ReleaseV0200ProductionShadowNoOrderAttemptEvidence(
                surface: .executionClient,
                capability: .cancel
            ),
            try ReleaseV0200ProductionShadowNoOrderAttemptEvidence(
                surface: .executionClient,
                capability: .replace
            ),
            try ReleaseV0200ProductionShadowNoOrderAttemptEvidence(
                surface: .dashboard,
                capability: .submit
            ),
            try ReleaseV0200ProductionShadowNoOrderAttemptEvidence(
                surface: .cli,
                capability: .cancel
            )
        ]
    }

    public static let summaryPrefix = "order-capability=<blocked>"
    public static let intentMarker = "real-order-intent=<not-created>"
    public static let transportMarker = "transport=<not-invoked>"
    public static let payloadMarker = "order-payload=<not-persisted>"

    public static func expectedState(
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability
    ) -> ReleaseV0200ProductionShadowNoOrderAttemptState {
        switch surface {
        case .dashboard:
            .dashboardBypassBlocked
        case .cli:
            .cliBypassBlocked
        case .executionClient:
            switch capability {
            case .submit:
                .submitBlocked
            case .cancel:
                .cancelBlocked
            case .replace:
                .replaceBlocked
            }
        }
    }

    public static func expectedFailureClass(
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability
    ) -> ReleaseV0200ProductionShadowNoOrderFailureClass {
        switch surface {
        case .dashboard:
            .dashboardBypassAttemptBlocked
        case .cli:
            .cliBypassAttemptBlocked
        case .executionClient:
            switch capability {
            case .submit:
                .submitAttemptBlocked
            case .cancel:
                .cancelAttemptBlocked
            case .replace:
                .replaceAttemptBlocked
            }
        }
    }

    public static func defaultEvidenceSummary(
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability,
        state: ReleaseV0200ProductionShadowNoOrderAttemptState
    ) -> String {
        [
            summaryPrefix,
            "surface=\(surface.rawValue)",
            "capability=\(capability.rawValue)",
            "state=\(state.rawValue)",
            intentMarker,
            transportMarker,
            payloadMarker
        ].joined(separator: "; ")
    }

    public static func deterministicID(
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability,
        state: ReleaseV0200ProductionShadowNoOrderAttemptState
    ) -> Identifier {
        .constant(
            [
                "gh-1246-v0200-no-order-attempt",
                surface.rawValue,
                capability.rawValue,
                state.rawValue
            ].joined(separator: ":"),
            field: "releaseV0200.noOrderGuard.attemptID"
        )
    }
}

private extension ReleaseV0200ProductionShadowNoOrderAttemptEvidence {
    static func validate(
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability,
        state: ReleaseV0200ProductionShadowNoOrderAttemptState,
        failureClass: ReleaseV0200ProductionShadowNoOrderFailureClass,
        redactedEvidenceSummary: String,
        productionShadowReadinessContractHeld: Bool,
        readOnlyEndpointAllowlistHeld: Bool,
        realOrderIntentCreated: Bool,
        signedOrderMaterialGenerated: Bool,
        orderEndpointTouched: Bool,
        transportInvoked: Bool,
        orderPayloadPersisted: Bool,
        dashboardBypassAllowed: Bool,
        cliBypassAllowed: Bool
    ) throws {
        guard productionShadowReadinessContractHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.productionShadowReadinessContractHeld",
                expected: "GH-1239 contract held",
                actual: "false"
            )
        }
        guard readOnlyEndpointAllowlistHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.readOnlyEndpointAllowlistHeld",
                expected: "GH-1241 read-only endpoint allowlist held",
                actual: "false"
            )
        }
        guard state == expectedState(surface: surface, capability: capability) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.state",
                expected: expectedState(surface: surface, capability: capability).rawValue,
                actual: state.rawValue
            )
        }
        guard failureClass == expectedFailureClass(surface: surface, capability: capability) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.failureClass",
                expected: expectedFailureClass(surface: surface, capability: capability).rawValue,
                actual: failureClass.rawValue
            )
        }
        guard isRedactedEvidenceSummary(
            redactedEvidenceSummary,
            surface: surface,
            capability: capability,
            state: state
        ) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.noOrderGuard.unredactedEvidenceSummary"
            )
        }
        for (field, value) in [
            ("realOrderIntentCreated", realOrderIntentCreated),
            ("signedOrderMaterialGenerated", signedOrderMaterialGenerated),
            ("orderEndpointTouched", orderEndpointTouched),
            ("transportInvoked", transportInvoked),
            ("orderPayloadPersisted", orderPayloadPersisted),
            ("dashboardBypassAllowed", dashboardBypassAllowed),
            ("cliBypassAllowed", cliBypassAllowed)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.noOrderGuard.\(field)"
            )
        }
    }

    static func isRedactedEvidenceSummary(
        _ summary: String,
        surface: ReleaseV0200ProductionShadowOrderCommandSurface,
        capability: ReleaseV0200ProductionShadowOrderCapability,
        state: ReleaseV0200ProductionShadowNoOrderAttemptState
    ) -> Bool {
        summary.contains(Self.summaryPrefix)
            && summary.contains("surface=\(surface.rawValue)")
            && summary.contains("capability=\(capability.rawValue)")
            && summary.contains("state=\(state.rawValue)")
            && summary.contains(Self.intentMarker)
            && summary.contains(Self.transportMarker)
            && summary.contains(Self.payloadMarker)
            && summary.localizedCaseInsensitiveContains("symbol=") == false
            && summary.localizedCaseInsensitiveContains("quantity=") == false
            && summary.localizedCaseInsensitiveContains("orderid") == false
            && summary.localizedCaseInsensitiveContains("clientorderid") == false
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("endpoint=") == false
            && summary.localizedCaseInsensitiveContains("/api/v3/order") == false
    }
}

/// ReleaseV0200ProductionShadowNoOrderCapabilityGuard 是 GH-1246 的 no-order capability guard。
///
/// Guard 继承 #1239 顶层 readiness contract 和 #1241 read-only endpoint allowlist，只证明
/// production-shadow profile 不能创建、路由或执行 submit / cancel / replace。Dashboard / CLI
/// 只能消费 blocked evidence，不能绕过 guard 生成真实订单 intent。
public struct ReleaseV0200ProductionShadowNoOrderCapabilityGuard: Codable, Equatable, Sendable {
    public let guardID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let productionShadowReadinessContract: ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract
    public let readOnlyEndpointAllowlist: ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist
    public let blockedAttempts: [ReleaseV0200ProductionShadowNoOrderAttemptEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let signedOrderMaterialGenerated: Bool
    public let accountEndpointTouched: Bool
    public let orderEndpointTouched: Bool
    public let endpointConnectionOpened: Bool
    public let realOrderIntentCreated: Bool
    public let orderPayloadPersisted: Bool
    public let submitCapabilityEnabled: Bool
    public let cancelCapabilityEnabled: Bool
    public let replaceCapabilityEnabled: Bool
    public let dashboardBypassAllowed: Bool
    public let cliBypassAllowed: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var guardHeld: Bool {
        issueID.rawValue == "GH-1246"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1239", "GH-1241"]
            && downstreamIssueID.rawValue == "GH-1247"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && productionShadowReadinessContract.contractHeld
            && readOnlyEndpointAllowlist.allowlistHeld
            && blockedAttemptsHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var blockedAttemptsHeld: Bool {
        blockedAttempts.count == 5
            && Set(blockedAttempts.map(\.surface)) == [.executionClient, .dashboard, .cli]
            && Set(blockedAttempts.filter { $0.surface == .executionClient }.map(\.capability))
                == Set(ReleaseV0200ProductionShadowOrderCapability.allCases)
            && blockedAttempts.allSatisfy(\.attemptBlockedHeld)
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && signedOrderMaterialGenerated == false
            && accountEndpointTouched == false
            && orderEndpointTouched == false
            && endpointConnectionOpened == false
            && realOrderIntentCreated == false
            && orderPayloadPersisted == false
            && submitCapabilityEnabled == false
            && cancelCapabilityEnabled == false
            && replaceCapabilityEnabled == false
            && dashboardBypassAllowed == false
            && cliBypassAllowed == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        guardID: Identifier = Identifier.constant("gh-1246-release-v0.20.0-no-order-capability-guard"),
        issueID: Identifier = Identifier.constant("GH-1246"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1239"), Identifier.constant("GH-1241")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1247"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        productionShadowReadinessContract: ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract? = nil,
        readOnlyEndpointAllowlist: ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist? = nil,
        blockedAttempts: [ReleaseV0200ProductionShadowNoOrderAttemptEvidence]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        signedOrderMaterialGenerated: Bool = false,
        accountEndpointTouched: Bool = false,
        orderEndpointTouched: Bool = false,
        endpointConnectionOpened: Bool = false,
        realOrderIntentCreated: Bool = false,
        orderPayloadPersisted: Bool = false,
        submitCapabilityEnabled: Bool = false,
        cancelCapabilityEnabled: Bool = false,
        replaceCapabilityEnabled: Bool = false,
        dashboardBypassAllowed: Bool = false,
        cliBypassAllowed: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedContract = try productionShadowReadinessContract
            ?? ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.deterministicFixture()
        let resolvedAllowlist = try readOnlyEndpointAllowlist
            ?? ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist.deterministicFixture()
        let resolvedAttempts = try blockedAttempts
            ?? ReleaseV0200ProductionShadowNoOrderAttemptEvidence.deterministicFixtures()
        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueIDs: upstreamIssueIDs,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            productionShadowReadinessContract: resolvedContract,
            readOnlyEndpointAllowlist: resolvedAllowlist,
            blockedAttempts: resolvedAttempts,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            signedOrderMaterialGenerated: signedOrderMaterialGenerated,
            accountEndpointTouched: accountEndpointTouched,
            orderEndpointTouched: orderEndpointTouched,
            endpointConnectionOpened: endpointConnectionOpened,
            realOrderIntentCreated: realOrderIntentCreated,
            orderPayloadPersisted: orderPayloadPersisted,
            submitCapabilityEnabled: submitCapabilityEnabled,
            cancelCapabilityEnabled: cancelCapabilityEnabled,
            replaceCapabilityEnabled: replaceCapabilityEnabled,
            dashboardBypassAllowed: dashboardBypassAllowed,
            cliBypassAllowed: cliBypassAllowed,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )
        self.guardID = guardID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.productionShadowReadinessContract = resolvedContract
        self.readOnlyEndpointAllowlist = resolvedAllowlist
        self.blockedAttempts = resolvedAttempts
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.signedOrderMaterialGenerated = signedOrderMaterialGenerated
        self.accountEndpointTouched = accountEndpointTouched
        self.orderEndpointTouched = orderEndpointTouched
        self.endpointConnectionOpened = endpointConnectionOpened
        self.realOrderIntentCreated = realOrderIntentCreated
        self.orderPayloadPersisted = orderPayloadPersisted
        self.submitCapabilityEnabled = submitCapabilityEnabled
        self.cancelCapabilityEnabled = cancelCapabilityEnabled
        self.replaceCapabilityEnabled = replaceCapabilityEnabled
        self.dashboardBypassAllowed = dashboardBypassAllowed
        self.cliBypassAllowed = cliBypassAllowed
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static let requiredValidationAnchors = [
        "GH-1246-VERIFY-V0200-NO-ORDER-CAPABILITY-GUARD",
        "TVM-RELEASE-V0200-NO-ORDER-CAPABILITY-GUARD",
        "V0200-008-BINANCE-SPOT-PRODUCTION-SHADOW-NO-ORDER-CAPABILITY-GUARD",
        "V0200-008-SUBMIT-BLOCKED",
        "V0200-008-CANCEL-BLOCKED",
        "V0200-008-REPLACE-BLOCKED",
        "V0200-008-DASHBOARD-CLI-CANNOT-BYPASS",
        "V0200-008-NO-REAL-ORDER-INTENT",
        "V0200-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1246ReleaseV0200NoOrderCapabilityGuard",
        "bash checks/verify-v0.20.0-no-order-capability-guard.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowNoOrderCapabilityGuard {
        try ReleaseV0200ProductionShadowNoOrderCapabilityGuard()
    }
}

private extension ReleaseV0200ProductionShadowNoOrderCapabilityGuard {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueIDs: [Identifier],
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        productionShadowReadinessContract: ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract,
        readOnlyEndpointAllowlist: ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist,
        blockedAttempts: [ReleaseV0200ProductionShadowNoOrderAttemptEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard issueID.rawValue == "GH-1246" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.issueID",
                expected: "GH-1246",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-1239", "GH-1241"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.upstreamIssueIDs",
                expected: "GH-1239,GH-1241",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard downstreamIssueID.rawValue == "GH-1247",
              canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
              projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
              releaseVersion == "v0.20.0",
              productionShadowReadinessContract.contractHeld,
              readOnlyEndpointAllowlist.allowlistHeld,
              validationAnchors == requiredValidationAnchors,
              requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.requiredContract",
                expected: "v0.20.0 no-order guard contract",
                actual: issueID.rawValue
            )
        }
        guard blockedAttempts.count == 5,
              Set(blockedAttempts.map(\.surface)) == [.executionClient, .dashboard, .cli],
              Set(blockedAttempts.filter { $0.surface == .executionClient }.map(\.capability))
                == Set(ReleaseV0200ProductionShadowOrderCapability.allCases),
              blockedAttempts.allSatisfy(\.attemptBlockedHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.noOrderGuard.blockedAttempts",
                expected: "submit/cancel/replace plus Dashboard/CLI bypass blocked evidence",
                actual: "\(blockedAttempts.count)"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        signedOrderMaterialGenerated: Bool,
        accountEndpointTouched: Bool,
        orderEndpointTouched: Bool,
        endpointConnectionOpened: Bool,
        realOrderIntentCreated: Bool,
        orderPayloadPersisted: Bool,
        submitCapabilityEnabled: Bool,
        cancelCapabilityEnabled: Bool,
        replaceCapabilityEnabled: Bool,
        dashboardBypassAllowed: Bool,
        cliBypassAllowed: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("signedOrderMaterialGenerated", signedOrderMaterialGenerated),
            ("accountEndpointTouched", accountEndpointTouched),
            ("orderEndpointTouched", orderEndpointTouched),
            ("endpointConnectionOpened", endpointConnectionOpened),
            ("realOrderIntentCreated", realOrderIntentCreated),
            ("orderPayloadPersisted", orderPayloadPersisted),
            ("submitCapabilityEnabled", submitCapabilityEnabled),
            ("cancelCapabilityEnabled", cancelCapabilityEnabled),
            ("replaceCapabilityEnabled", replaceCapabilityEnabled),
            ("dashboardBypassAllowed", dashboardBypassAllowed),
            ("cliBypassAllowed", cliBypassAllowed),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0200.noOrderGuard.\(field)")
        }
    }
}
