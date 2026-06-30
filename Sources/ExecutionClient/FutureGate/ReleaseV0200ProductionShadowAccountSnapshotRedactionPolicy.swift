import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowAccountSnapshotArtifactState 描述 GH-1245 account snapshot artifact policy 的状态。
///
/// 这些状态只用于固定 production-shadow 账号快照证据的脱敏与落盘边界。它们不保存真实余额、
/// account identifier、secret、listenKey、raw broker payload，也不授权 production endpoint 或订单能力。
public enum ReleaseV0200ProductionShadowAccountSnapshotArtifactState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case policyReady = "policy-ready"
    case rawBalancePersistenceBlocked = "raw-balance-persistence-blocked"
    case accountIdentifierPersistenceBlocked = "account-identifier-persistence-blocked"
    case secretPersistenceBlocked = "secret-persistence-blocked"
    case rawBrokerPayloadPersistenceBlocked = "raw-broker-payload-persistence-blocked"
    case unsafeArtifactLocationBlocked = "unsafe-artifact-location-blocked"
}

/// ReleaseV0200ProductionShadowAccountSnapshotFailureClass 固定 #1245 的 fail-closed 分类。
public enum ReleaseV0200ProductionShadowAccountSnapshotFailureClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case rawBalancePersistenceAttempted = "raw balance persistence attempted"
    case accountIdentifierPersistenceAttempted = "account identifier persistence attempted"
    case secretPersistenceAttempted = "secret persistence attempted"
    case rawBrokerPayloadPersistenceAttempted = "raw broker payload persistence attempted"
    case unsafeArtifactLocationAttempted = "unsafe artifact location attempted"
}

/// ReleaseV0200ProductionShadowAccountSnapshotAllowedField 固定可以写入本地 artifact 的字段。
///
/// 允许字段只表达脱敏后的元数据、hash、计数或 bucket；不能表达真实账号、真实余额或 broker payload。
public enum ReleaseV0200ProductionShadowAccountSnapshotAllowedField: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case snapshotID = "snapshot_id_redacted"
    case venue = "venue"
    case productKind = "product_kind"
    case tradingEnvironment = "trading_environment"
    case observationState = "observation_state"
    case accountSummaryHash = "account_summary_hash"
    case balanceBucket = "balance_bucket_redacted"
    case positionCount = "position_count"
    case marginMode = "margin_mode_redacted"
    case policyVersion = "policy_version"
}

/// ReleaseV0200ProductionShadowAccountSnapshotForbiddenField 固定不能写入 artifact 的敏感字段。
public enum ReleaseV0200ProductionShadowAccountSnapshotForbiddenField: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case exactBalance = "exact balance"
    case accountID = "account id"
    case uid = "uid"
    case apiKey = "api key"
    case secretValue = "secret value"
    case signature = "signature"
    case listenKey = "listenKey"
    case rawBrokerPayload = "raw broker payload"
    case endpointResponseBody = "endpoint response body"
    case orderPayload = "order payload"
}

/// ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation 固定 #1245 允许的本地 artifact 路径。
///
/// 路径只能是 repository-relative、release-scoped、redacted 文件名。绝对路径、`..` 逃逸、真实账号 ID
/// 或 exchange payload 文件名都会 fail closed。
public struct ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation: Codable, Equatable, Sendable {
    public let relativePath: String

    public var locationHeld: Bool {
        Self.isAllowed(relativePath)
    }

    public init(
        relativePath: String = Self.requiredRelativePath
    ) throws {
        guard Self.isAllowed(relativePath) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.artifactLocation"
            )
        }
        self.relativePath = relativePath
    }

    public static let requiredRelativePath =
        "artifacts/release-v0.20.0/account-snapshot/production-shadow/<redacted-snapshot-id>.json"

    public static func isAllowed(_ path: String) -> Bool {
        path == requiredRelativePath
            && path.hasPrefix("artifacts/release-v0.20.0/account-snapshot/production-shadow/")
            && path.hasSuffix(".json")
            && path.hasPrefix("/") == false
            && path.contains("..") == false
            && path.localizedCaseInsensitiveContains("accountId") == false
            && path.localizedCaseInsensitiveContains("uid") == false
            && path.localizedCaseInsensitiveContains("api-key") == false
            && path.localizedCaseInsensitiveContains("secret") == false
    }
}

/// ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact 表达可落盘的脱敏账号快照样例。
///
/// Artifact 只保存 redacted JSON example 和 policy metadata。它不保存真实 `/api/v3/account` payload、
/// account ID、balance 数值、secret、signature、listenKey、order payload 或 endpoint response body。
public struct ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState
    public let failureClass: ReleaseV0200ProductionShadowAccountSnapshotFailureClass?
    public let location: ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation
    public let upstreamSignedAccountReadiness: ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness
    public let allowedFields: [ReleaseV0200ProductionShadowAccountSnapshotAllowedField]
    public let forbiddenFields: [ReleaseV0200ProductionShadowAccountSnapshotForbiddenField]
    public let redactedSnapshotJSON: String
    public let redactedEvidenceSummary: String
    public let rawBalancesPersisted: Bool
    public let accountIdentifiersPersisted: Bool
    public let secretMaterialPersisted: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let endpointResponseBodyPersisted: Bool
    public let orderPayloadPersisted: Bool

    public var redactionPolicyHeld: Bool {
        state == .policyReady
            && failureClass == nil
            && upstreamSignedAccountReadiness.readinessHeld
            && location.locationHeld
            && allowedFields == ReleaseV0200ProductionShadowAccountSnapshotAllowedField.allCases
            && forbiddenFields == ReleaseV0200ProductionShadowAccountSnapshotForbiddenField.allCases
            && Self.isSafeRedactedSnapshotJSON(redactedSnapshotJSON)
            && Self.isSafeRedactedEvidenceSummary(redactedEvidenceSummary, state: state)
            && forbiddenPersistenceHeld
    }

    public var failClosedArtifactHeld: Bool {
        state != .policyReady
            && failureClass != nil
            && upstreamSignedAccountReadiness.readinessHeld
            && location.locationHeld
            && allowedFields == ReleaseV0200ProductionShadowAccountSnapshotAllowedField.allCases
            && forbiddenFields == ReleaseV0200ProductionShadowAccountSnapshotForbiddenField.allCases
            && Self.isSafeRedactedSnapshotJSON(redactedSnapshotJSON)
            && Self.isSafeRedactedEvidenceSummary(redactedEvidenceSummary, state: state)
            && forbiddenPersistenceHeld
    }

    public var forbiddenPersistenceHeld: Bool {
        rawBalancesPersisted == false
            && accountIdentifiersPersisted == false
            && secretMaterialPersisted == false
            && rawBrokerPayloadPersisted == false
            && endpointResponseBodyPersisted == false
            && orderPayloadPersisted == false
    }

    public init(
        artifactID: Identifier? = nil,
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState,
        failureClass: ReleaseV0200ProductionShadowAccountSnapshotFailureClass? = nil,
        location: ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation? = nil,
        upstreamSignedAccountReadiness: ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness? = nil,
        allowedFields: [ReleaseV0200ProductionShadowAccountSnapshotAllowedField] =
            ReleaseV0200ProductionShadowAccountSnapshotAllowedField.allCases,
        forbiddenFields: [ReleaseV0200ProductionShadowAccountSnapshotForbiddenField] =
            ReleaseV0200ProductionShadowAccountSnapshotForbiddenField.allCases,
        redactedSnapshotJSON: String = Self.requiredRedactedSnapshotJSON,
        redactedEvidenceSummary: String? = nil,
        rawBalancesPersisted: Bool = false,
        accountIdentifiersPersisted: Bool = false,
        secretMaterialPersisted: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        endpointResponseBodyPersisted: Bool = false,
        orderPayloadPersisted: Bool = false
    ) throws {
        let resolvedLocation = try location ?? ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation()
        let resolvedReadiness = try upstreamSignedAccountReadiness
            ?? ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.deterministicFixture()
        let resolvedSummary = redactedEvidenceSummary ?? Self.defaultRedactedEvidenceSummary(state: state)
        let resolvedID = artifactID ?? Self.deterministicID(state: state, failureClass: failureClass)
        try Self.validate(
            state: state,
            failureClass: failureClass,
            location: resolvedLocation,
            upstreamSignedAccountReadiness: resolvedReadiness,
            allowedFields: allowedFields,
            forbiddenFields: forbiddenFields,
            redactedSnapshotJSON: redactedSnapshotJSON,
            redactedEvidenceSummary: resolvedSummary,
            rawBalancesPersisted: rawBalancesPersisted,
            accountIdentifiersPersisted: accountIdentifiersPersisted,
            secretMaterialPersisted: secretMaterialPersisted,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            endpointResponseBodyPersisted: endpointResponseBodyPersisted,
            orderPayloadPersisted: orderPayloadPersisted
        )
        self.artifactID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.location = resolvedLocation
        self.upstreamSignedAccountReadiness = resolvedReadiness
        self.allowedFields = allowedFields
        self.forbiddenFields = forbiddenFields
        self.redactedSnapshotJSON = redactedSnapshotJSON
        self.redactedEvidenceSummary = resolvedSummary
        self.rawBalancesPersisted = rawBalancesPersisted
        self.accountIdentifiersPersisted = accountIdentifiersPersisted
        self.secretMaterialPersisted = secretMaterialPersisted
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.endpointResponseBodyPersisted = endpointResponseBodyPersisted
        self.orderPayloadPersisted = orderPayloadPersisted
    }

    public static func policyReadyFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
        try ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact(state: .policyReady)
    }

    public static func rawBalanceBlockedFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
        try ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact(
            state: .rawBalancePersistenceBlocked,
            failureClass: .rawBalancePersistenceAttempted
        )
    }

    public static func accountIdentifierBlockedFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
        try ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact(
            state: .accountIdentifierPersistenceBlocked,
            failureClass: .accountIdentifierPersistenceAttempted
        )
    }

    public static func secretBlockedFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
        try ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact(
            state: .secretPersistenceBlocked,
            failureClass: .secretPersistenceAttempted
        )
    }

    public static func rawBrokerPayloadBlockedFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
        try ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact(
            state: .rawBrokerPayloadPersistenceBlocked,
            failureClass: .rawBrokerPayloadPersistenceAttempted
        )
    }

    public static let requiredRedactedSnapshotJSON =
        #"{"snapshot_id":"<redacted>","venue":"binance","product_kind":"spot","trading_environment":"production-shadow","account_id":"<redacted>","balance_bucket":"<redacted-bucket>","position_count":"<count-only>","margin_mode":"<redacted>","raw_broker_payload":"<not-persisted>","policy_version":"v0.20.0-account-snapshot-redaction"}"#
    public static let requiredSummaryPrefix = "account-snapshot-artifact=<redacted>"
    public static let requiredBalanceMarker = "balances=<redacted>"
    public static let requiredAccountMarker = "account-id=<redacted>"
    public static let requiredPayloadMarker = "raw-broker-payload=<not-persisted>"

    public static func deterministicID(
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState,
        failureClass: ReleaseV0200ProductionShadowAccountSnapshotFailureClass?
    ) -> Identifier {
        .constant(
            [
                "gh-1245-v0200-account-snapshot-redaction-artifact",
                state.rawValue,
                failureClass?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0200.accountSnapshotRedaction.artifactID"
        )
    }
}

private extension ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact {
    static func validate(
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState,
        failureClass: ReleaseV0200ProductionShadowAccountSnapshotFailureClass?,
        location: ReleaseV0200ProductionShadowAccountSnapshotArtifactLocation,
        upstreamSignedAccountReadiness: ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness,
        allowedFields: [ReleaseV0200ProductionShadowAccountSnapshotAllowedField],
        forbiddenFields: [ReleaseV0200ProductionShadowAccountSnapshotForbiddenField],
        redactedSnapshotJSON: String,
        redactedEvidenceSummary: String,
        rawBalancesPersisted: Bool,
        accountIdentifiersPersisted: Bool,
        secretMaterialPersisted: Bool,
        rawBrokerPayloadPersisted: Bool,
        endpointResponseBodyPersisted: Bool,
        orderPayloadPersisted: Bool
    ) throws {
        guard upstreamSignedAccountReadiness.readinessHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.upstreamSignedAccountReadiness",
                expected: "GH-1244 signed account read-only readiness held",
                actual: upstreamSignedAccountReadiness.issueID.rawValue
            )
        }
        guard location.locationHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.unsafeArtifactLocation"
            )
        }
        guard allowedFields == ReleaseV0200ProductionShadowAccountSnapshotAllowedField.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.allowedFields",
                expected: ReleaseV0200ProductionShadowAccountSnapshotAllowedField.allCases.map(\.rawValue).joined(separator: ","),
                actual: allowedFields.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenFields == ReleaseV0200ProductionShadowAccountSnapshotForbiddenField.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.forbiddenFields",
                expected: ReleaseV0200ProductionShadowAccountSnapshotForbiddenField.allCases.map(\.rawValue).joined(separator: ","),
                actual: forbiddenFields.map(\.rawValue).joined(separator: ",")
            )
        }
        try validateState(state: state, failureClass: failureClass)
        guard isSafeRedactedSnapshotJSON(redactedSnapshotJSON) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.unsafeSnapshotJSON"
            )
        }
        guard isSafeRedactedEvidenceSummary(redactedEvidenceSummary, state: state) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.unsafeEvidenceSummary"
            )
        }
        for (field, value) in [
            ("rawBalancesPersisted", rawBalancesPersisted),
            ("accountIdentifiersPersisted", accountIdentifiersPersisted),
            ("secretMaterialPersisted", secretMaterialPersisted),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("endpointResponseBodyPersisted", endpointResponseBodyPersisted),
            ("orderPayloadPersisted", orderPayloadPersisted)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.\(field)"
            )
        }
    }

    static func validateState(
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState,
        failureClass: ReleaseV0200ProductionShadowAccountSnapshotFailureClass?
    ) throws {
        switch (state, failureClass) {
        case (.policyReady, nil),
             (.rawBalancePersistenceBlocked, .rawBalancePersistenceAttempted?),
             (.accountIdentifierPersistenceBlocked, .accountIdentifierPersistenceAttempted?),
             (.secretPersistenceBlocked, .secretPersistenceAttempted?),
             (.rawBrokerPayloadPersistenceBlocked, .rawBrokerPayloadPersistenceAttempted?),
             (.unsafeArtifactLocationBlocked, .unsafeArtifactLocationAttempted?):
            return
        case (.policyReady, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.failureClass",
                expected: "nil when policy is ready",
                actual: failureClass.rawValue
            )
        case (_, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (_, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }
    }

    static func defaultRedactedEvidenceSummary(
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState
    ) -> String {
        "\(Self.requiredSummaryPrefix); state=\(state.rawValue); \(Self.requiredBalanceMarker); \(Self.requiredAccountMarker); \(Self.requiredPayloadMarker)"
    }

    static func isSafeRedactedSnapshotJSON(_ json: String) -> Bool {
        json.contains(#""snapshot_id":"<redacted>""#)
            && json.contains(#""account_id":"<redacted>""#)
            && json.contains(#""balance_bucket":"<redacted-bucket>""#)
            && json.contains(#""raw_broker_payload":"<not-persisted>""#)
            && json.contains(#""policy_version":"v0.20.0-account-snapshot-redaction""#)
            && json.localizedCaseInsensitiveContains("free") == false
            && json.localizedCaseInsensitiveContains("locked") == false
            && json.localizedCaseInsensitiveContains("commission") == false
            && json.localizedCaseInsensitiveContains("canTrade") == false
            && json.localizedCaseInsensitiveContains("canWithdraw") == false
            && json.localizedCaseInsensitiveContains("api key") == false
            && json.localizedCaseInsensitiveContains("secret") == false
            && json.localizedCaseInsensitiveContains("signature") == false
            && json.localizedCaseInsensitiveContains("listenKey") == false
            && json.localizedCaseInsensitiveContains("orderId") == false
            && json.localizedCaseInsensitiveContains("raw payload") == false
    }

    static func isSafeRedactedEvidenceSummary(
        _ summary: String,
        state: ReleaseV0200ProductionShadowAccountSnapshotArtifactState
    ) -> Bool {
        summary.contains(Self.requiredSummaryPrefix)
            && summary.contains("state=\(state.rawValue)")
            && summary.contains(Self.requiredBalanceMarker)
            && summary.contains(Self.requiredAccountMarker)
            && summary.contains(Self.requiredPayloadMarker)
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("secret value") == false
            && summary.localizedCaseInsensitiveContains("secret=") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
            && summary.localizedCaseInsensitiveContains("raw payload") == false
            && summary.localizedCaseInsensitiveContains("free=") == false
            && summary.localizedCaseInsensitiveContains("locked=") == false
    }
}

/// ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy 是 GH-1245 的账号快照脱敏与 artifact policy。
///
/// Policy 继承 #1244 signed account read-only readiness，但只表达安全 artifact schema 和验证要求。
/// 它不读取 production secret、不打开 endpoint connection、不保存真实 account snapshot、不启用订单能力，
/// 也不创建 tag 或授权 production cutover。
public struct ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamSignedAccountReadinessHeld: Bool
    public let redactedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact
    public let rawBalanceBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact
    public let accountIdentifierBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact
    public let secretBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact
    public let rawBrokerPayloadBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let signedRequestMaterialGenerated: Bool
    public let accountEndpointTouched: Bool
    public let endpointConnectionOpened: Bool
    public let rawBalancesPersisted: Bool
    public let accountIdentifiersPersisted: Bool
    public let secretMaterialPersisted: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let endpointResponseBodyPersisted: Bool
    public let orderPayloadPersisted: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var policyHeld: Bool {
        issueID.rawValue == "GH-1245"
            && upstreamIssueID.rawValue == "GH-1244"
            && downstreamIssueID.rawValue == "GH-1246"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamSignedAccountReadinessHeld
            && redactedArtifact.redactionPolicyHeld
            && failClosedEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var failClosedEvidenceHeld: Bool {
        rawBalanceBlockedArtifact.failClosedArtifactHeld
            && rawBalanceBlockedArtifact.state == .rawBalancePersistenceBlocked
            && rawBalanceBlockedArtifact.failureClass == .rawBalancePersistenceAttempted
            && accountIdentifierBlockedArtifact.failClosedArtifactHeld
            && accountIdentifierBlockedArtifact.state == .accountIdentifierPersistenceBlocked
            && accountIdentifierBlockedArtifact.failureClass == .accountIdentifierPersistenceAttempted
            && secretBlockedArtifact.failClosedArtifactHeld
            && secretBlockedArtifact.state == .secretPersistenceBlocked
            && secretBlockedArtifact.failureClass == .secretPersistenceAttempted
            && rawBrokerPayloadBlockedArtifact.failClosedArtifactHeld
            && rawBrokerPayloadBlockedArtifact.state == .rawBrokerPayloadPersistenceBlocked
            && rawBrokerPayloadBlockedArtifact.failureClass == .rawBrokerPayloadPersistenceAttempted
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && signedRequestMaterialGenerated == false
            && accountEndpointTouched == false
            && endpointConnectionOpened == false
            && rawBalancesPersisted == false
            && accountIdentifiersPersisted == false
            && secretMaterialPersisted == false
            && rawBrokerPayloadPersisted == false
            && endpointResponseBodyPersisted == false
            && orderPayloadPersisted == false
            && orderSubmitCancelReplaceEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1245-release-v0.20.0-account-snapshot-redaction-policy"),
        issueID: Identifier = Identifier.constant("GH-1245"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1244"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1246"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamSignedAccountReadinessHeld: Bool = true,
        redactedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact? = nil,
        rawBalanceBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact? = nil,
        accountIdentifierBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact? = nil,
        secretBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact? = nil,
        rawBrokerPayloadBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        signedRequestMaterialGenerated: Bool = false,
        accountEndpointTouched: Bool = false,
        endpointConnectionOpened: Bool = false,
        rawBalancesPersisted: Bool = false,
        accountIdentifiersPersisted: Bool = false,
        secretMaterialPersisted: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        endpointResponseBodyPersisted: Bool = false,
        orderPayloadPersisted: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedArtifact = try redactedArtifact
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact.policyReadyFixture()
        let resolvedRawBalanceBlocked = try rawBalanceBlockedArtifact
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact.rawBalanceBlockedFixture()
        let resolvedAccountIdentifierBlocked = try accountIdentifierBlockedArtifact
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact.accountIdentifierBlockedFixture()
        let resolvedSecretBlocked = try secretBlockedArtifact
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact.secretBlockedFixture()
        let resolvedRawBrokerPayloadBlocked = try rawBrokerPayloadBlockedArtifact
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact.rawBrokerPayloadBlockedFixture()
        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueID: upstreamIssueID,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamSignedAccountReadinessHeld: upstreamSignedAccountReadinessHeld,
            redactedArtifact: resolvedArtifact,
            rawBalanceBlockedArtifact: resolvedRawBalanceBlocked,
            accountIdentifierBlockedArtifact: resolvedAccountIdentifierBlocked,
            secretBlockedArtifact: resolvedSecretBlocked,
            rawBrokerPayloadBlockedArtifact: resolvedRawBrokerPayloadBlocked,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            signedRequestMaterialGenerated: signedRequestMaterialGenerated,
            accountEndpointTouched: accountEndpointTouched,
            endpointConnectionOpened: endpointConnectionOpened,
            rawBalancesPersisted: rawBalancesPersisted,
            accountIdentifiersPersisted: accountIdentifiersPersisted,
            secretMaterialPersisted: secretMaterialPersisted,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            endpointResponseBodyPersisted: endpointResponseBodyPersisted,
            orderPayloadPersisted: orderPayloadPersisted,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )
        self.policyID = policyID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamSignedAccountReadinessHeld = upstreamSignedAccountReadinessHeld
        self.redactedArtifact = resolvedArtifact
        self.rawBalanceBlockedArtifact = resolvedRawBalanceBlocked
        self.accountIdentifierBlockedArtifact = resolvedAccountIdentifierBlocked
        self.secretBlockedArtifact = resolvedSecretBlocked
        self.rawBrokerPayloadBlockedArtifact = resolvedRawBrokerPayloadBlocked
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.signedRequestMaterialGenerated = signedRequestMaterialGenerated
        self.accountEndpointTouched = accountEndpointTouched
        self.endpointConnectionOpened = endpointConnectionOpened
        self.rawBalancesPersisted = rawBalancesPersisted
        self.accountIdentifiersPersisted = accountIdentifiersPersisted
        self.secretMaterialPersisted = secretMaterialPersisted
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.endpointResponseBodyPersisted = endpointResponseBodyPersisted
        self.orderPayloadPersisted = orderPayloadPersisted
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy {
        _ = try ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.deterministicFixture()
        return try ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy()
    }

    public static let requiredValidationAnchors = [
        "GH-1245-VERIFY-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY",
        "TVM-RELEASE-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY",
        "V0200-007-BINANCE-SPOT-PRODUCTION-SHADOW-ACCOUNT-SNAPSHOT-REDACTION",
        "V0200-007-ARTIFACT-LOCATION-POLICY",
        "V0200-007-ALLOWED-FIELD-SCHEMA",
        "V0200-007-FORBIDDEN-FIELD-SCHEMA",
        "V0200-007-REDACTED-SNAPSHOT-JSON",
        "V0200-007-NO-RAW-BALANCE-PERSISTENCE",
        "V0200-007-NO-ACCOUNT-ID-PERSISTENCE",
        "V0200-007-NO-SECRET-OR-RAW-PAYLOAD-PERSISTENCE",
        "V0200-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1245ReleaseV0200AccountSnapshotRedactionPolicy",
        "bash checks/verify-v0.20.0-account-snapshot-redaction-policy.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueID: Identifier,
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamSignedAccountReadinessHeld: Bool,
        redactedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact,
        rawBalanceBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact,
        accountIdentifierBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact,
        secretBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact,
        rawBrokerPayloadBlockedArtifact: ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1245", "GH-1245", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1244", "GH-1244", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1246", "GH-1246", downstreamIssueID.rawValue),
            (
                "canonicalQueueRange",
                canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                canonicalQueueRange
            ),
            (
                "projectName",
                projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.20.0", "v0.20.0", releaseVersion),
            ("upstreamSignedAccountReadinessHeld", upstreamSignedAccountReadinessHeld, "true", "false"),
            ("redactedArtifact", redactedArtifact.redactionPolicyHeld, "safe redacted artifact", redactedArtifact.state.rawValue),
            (
                "rawBalanceBlockedArtifact",
                rawBalanceBlockedArtifact.failClosedArtifactHeld
                    && rawBalanceBlockedArtifact.failureClass == .rawBalancePersistenceAttempted,
                "raw balance blocked artifact",
                rawBalanceBlockedArtifact.state.rawValue
            ),
            (
                "accountIdentifierBlockedArtifact",
                accountIdentifierBlockedArtifact.failClosedArtifactHeld
                    && accountIdentifierBlockedArtifact.failureClass == .accountIdentifierPersistenceAttempted,
                "account identifier blocked artifact",
                accountIdentifierBlockedArtifact.state.rawValue
            ),
            (
                "secretBlockedArtifact",
                secretBlockedArtifact.failClosedArtifactHeld
                    && secretBlockedArtifact.failureClass == .secretPersistenceAttempted,
                "secret blocked artifact",
                secretBlockedArtifact.state.rawValue
            ),
            (
                "rawBrokerPayloadBlockedArtifact",
                rawBrokerPayloadBlockedArtifact.failClosedArtifactHeld
                    && rawBrokerPayloadBlockedArtifact.failureClass == .rawBrokerPayloadPersistenceAttempted,
                "raw broker payload blocked artifact",
                rawBrokerPayloadBlockedArtifact.state.rawValue
            ),
            (
                "validationAnchors",
                validationAnchors == Self.requiredValidationAnchors,
                Self.requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]
        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.accountSnapshotRedaction.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        signedRequestMaterialGenerated: Bool,
        accountEndpointTouched: Bool,
        endpointConnectionOpened: Bool,
        rawBalancesPersisted: Bool,
        accountIdentifiersPersisted: Bool,
        secretMaterialPersisted: Bool,
        rawBrokerPayloadPersisted: Bool,
        endpointResponseBodyPersisted: Bool,
        orderPayloadPersisted: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("signedRequestMaterialGenerated", signedRequestMaterialGenerated),
            ("accountEndpointTouched", accountEndpointTouched),
            ("endpointConnectionOpened", endpointConnectionOpened),
            ("rawBalancesPersisted", rawBalancesPersisted),
            ("accountIdentifiersPersisted", accountIdentifiersPersisted),
            ("secretMaterialPersisted", secretMaterialPersisted),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("endpointResponseBodyPersisted", endpointResponseBodyPersisted),
            ("orderPayloadPersisted", orderPayloadPersisted),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.accountSnapshotRedaction.\(field)"
            )
        }
    }
}
