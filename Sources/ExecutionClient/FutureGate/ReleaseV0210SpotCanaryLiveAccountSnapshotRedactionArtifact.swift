import DomainModel
import Foundation

/// ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState 固定 GH-1277 的
/// Binance Spot canary live account snapshot redaction artifact 状态。
///
/// 这些状态只表达 GH-1276 signed account read-only preflight 之后的脱敏 artifact
/// 和 freshness evidence。它们不保存真实余额、account id、raw account payload、
/// secret、listenKey，也不授权 order endpoint、private stream 或 production cutover。
public enum ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case freshRedactedArtifactReady = "fresh-redacted-artifact-ready"
    case staleSnapshotRejected = "stale-snapshot-rejected"
    case malformedSnapshotRejected = "malformed-snapshot-rejected"
    case rawBalancePersistenceBlocked = "raw-balance-persistence-blocked"
    case accountIdentifierPersistenceBlocked = "account-identifier-persistence-blocked"
    case rawPayloadPersistenceBlocked = "raw-payload-persistence-blocked"
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass 固定 GH-1277 的
/// freshness / redaction fail-closed 分类。
public enum ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case staleSnapshot = "stale snapshot"
    case malformedSnapshot = "malformed snapshot"
    case rawBalancePersistenceAttempted = "raw balance persistence attempted"
    case accountIdentifierPersistenceAttempted = "account identifier persistence attempted"
    case rawAccountPayloadPersistenceAttempted = "raw account payload persistence attempted"
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField 固定 GH-1277 artifact
/// 允许落盘的只读 readiness 字段。
///
/// 允许字段只能表达账号 readiness、脱敏状态、freshness 和 release policy version；
/// 不能表达真实余额、真实账号标识、secret、signature、listenKey 或 broker payload。
public enum ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case snapshotID = "snapshot_id_redacted"
    case venue = "venue"
    case productKind = "product_kind"
    case tradingEnvironment = "trading_environment"
    case accountStatus = "account_status_redacted"
    case canTrade = "can_trade_readiness_only"
    case canWithdraw = "can_withdraw_readiness_only"
    case canDeposit = "can_deposit_readiness_only"
    case permissions = "permissions_redacted"
    case freshnessStatus = "freshness_status"
    case freshnessAgeSeconds = "freshness_age_seconds"
    case staleAfterSeconds = "stale_after_seconds"
    case policyVersion = "policy_version"
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField 固定 GH-1277 artifact
/// 禁止持久化的敏感字段。
public enum ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case exactBalance = "exact balance"
    case freeBalance = "free balance"
    case lockedBalance = "locked balance"
    case accountID = "account id"
    case uid = "uid"
    case apiKey = "api key"
    case secretValue = "secret value"
    case signature = "signature"
    case listenKey = "listenKey"
    case rawAccountPayload = "raw account payload"
    case endpointResponseBody = "endpoint response body"
    case orderPayload = "order payload"
    case brokerFill = "broker fill"
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation 固定 GH-1277
/// 允许的脱敏 artifact 路径。
///
/// 路径必须是 repository-relative、release-scoped、redacted 文件名；绝对路径、
/// `..` 逃逸、真实 account id 或 secret material 都会 fail closed。
public struct ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation:
    Codable, Equatable, Sendable
{
    public let relativePath: String

    public var locationHeld: Bool {
        Self.isAllowed(relativePath)
    }

    public init(
        relativePath: String = Self.requiredRelativePath
    ) throws {
        guard Self.isAllowed(relativePath) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.artifactLocation"
            )
        }
        self.relativePath = relativePath
    }

    public static let requiredRelativePath =
        "artifacts/release-v0.21.0/account-snapshot/binance-spot-canary/<redacted-snapshot-id>.json"

    public static func isAllowed(_ path: String) -> Bool {
        path == requiredRelativePath
            && path.hasPrefix("artifacts/release-v0.21.0/account-snapshot/binance-spot-canary/")
            && path.hasSuffix(".json")
            && path.hasPrefix("/") == false
            && path.contains("..") == false
            && path.localizedCaseInsensitiveContains("accountId") == false
            && path.localizedCaseInsensitiveContains("uid") == false
            && path.localizedCaseInsensitiveContains("api-key") == false
            && path.localizedCaseInsensitiveContains("secret") == false
            && path.localizedCaseInsensitiveContains("listenKey") == false
    }
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact 表达 GH-1277 的
/// redacted live account snapshot artifact。
///
/// Artifact 只保存脱敏 JSON example、allowed field schema 和 freshness evidence。
/// 它消费 GH-1276 preflight evidence，但不保存 raw `/api/v3/account` response、
/// raw balances、account id、secret、signature、listenKey、order payload 或 broker fill。
public struct ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact:
    Codable, Equatable, Sendable
{
    public let artifactID: Identifier
    public let state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState
    public let failureClass: ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass?
    public let location: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation
    public let upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight
    public let allowedFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField]
    public let forbiddenFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField]
    public let redactedSnapshotJSON: String
    public let freshnessEvidenceSummary: String
    public let capturedAtUnixSeconds: Int
    public let sourceWatermarkUnixSeconds: Int
    public let staleAfterSeconds: Int
    public let upstreamPreflightEvidenceHeld: Bool
    public let rawBalancesPersisted: Bool
    public let accountIdentifiersPersisted: Bool
    public let secretMaterialPersisted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let endpointResponseBodyPersisted: Bool
    public let orderPayloadPersisted: Bool
    public let malformedSnapshotAccepted: Bool

    public var freshnessAgeSeconds: Int {
        capturedAtUnixSeconds - sourceWatermarkUnixSeconds
    }

    public var freshnessHeld: Bool {
        state == .freshRedactedArtifactReady
            && freshnessAgeSeconds >= 0
            && freshnessAgeSeconds <= staleAfterSeconds
    }

    public var redactionArtifactHeld: Bool {
        state == .freshRedactedArtifactReady
            && failureClass == nil
            && upstreamPreflight.preflightHeld
            && upstreamPreflightEvidenceHeld
            && location.locationHeld
            && allowedFields == ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField.allCases
            && forbiddenFields == ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField.allCases
            && Self.isSafeRedactedSnapshotJSON(redactedSnapshotJSON)
            && Self.isSafeFreshnessEvidenceSummary(freshnessEvidenceSummary, state: state)
            && freshnessHeld
            && forbiddenPersistenceHeld
    }

    public var failClosedArtifactHeld: Bool {
        state != .freshRedactedArtifactReady
            && failureClass != nil
            && upstreamPreflight.preflightHeld
            && location.locationHeld
            && allowedFields == ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField.allCases
            && forbiddenFields == ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField.allCases
            && Self.isSafeRedactedSnapshotJSON(redactedSnapshotJSON)
            && Self.isSafeFreshnessEvidenceSummary(freshnessEvidenceSummary, state: state)
            && failClosedFreshnessStateHeld
            && forbiddenPersistenceHeld
    }

    public var failClosedFreshnessStateHeld: Bool {
        switch state {
        case .freshRedactedArtifactReady:
            return freshnessHeld
        case .staleSnapshotRejected:
            return freshnessAgeSeconds > staleAfterSeconds
        case .malformedSnapshotRejected:
            return malformedSnapshotAccepted == false
        case .rawBalancePersistenceBlocked,
             .accountIdentifierPersistenceBlocked,
             .rawPayloadPersistenceBlocked:
            return true
        }
    }

    public var forbiddenPersistenceHeld: Bool {
        rawBalancesPersisted == false
            && accountIdentifiersPersisted == false
            && secretMaterialPersisted == false
            && rawAccountPayloadPersisted == false
            && endpointResponseBodyPersisted == false
            && orderPayloadPersisted == false
            && malformedSnapshotAccepted == false
    }

    public init(
        artifactID: Identifier? = nil,
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState,
        failureClass: ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass? = nil,
        location: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation? = nil,
        upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight? = nil,
        allowedFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField] =
            ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField.allCases,
        forbiddenFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField] =
            ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField.allCases,
        redactedSnapshotJSON: String = Self.requiredRedactedSnapshotJSON,
        freshnessEvidenceSummary: String? = nil,
        capturedAtUnixSeconds: Int = Self.requiredCapturedAtUnixSeconds,
        sourceWatermarkUnixSeconds: Int = Self.requiredSourceWatermarkUnixSeconds,
        staleAfterSeconds: Int = Self.requiredStaleAfterSeconds,
        upstreamPreflightEvidenceHeld: Bool = true,
        rawBalancesPersisted: Bool = false,
        accountIdentifiersPersisted: Bool = false,
        secretMaterialPersisted: Bool = false,
        rawAccountPayloadPersisted: Bool = false,
        endpointResponseBodyPersisted: Bool = false,
        orderPayloadPersisted: Bool = false,
        malformedSnapshotAccepted: Bool = false
    ) throws {
        let resolvedLocation = try location
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation()
        let resolvedPreflight = try upstreamPreflight
            ?? ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight.deterministicFixture()
        let resolvedSummary = freshnessEvidenceSummary
            ?? Self.defaultFreshnessEvidenceSummary(
                state: state,
                capturedAtUnixSeconds: capturedAtUnixSeconds,
                sourceWatermarkUnixSeconds: sourceWatermarkUnixSeconds,
                staleAfterSeconds: staleAfterSeconds
            )
        let resolvedID = artifactID ?? Self.deterministicID(state: state, failureClass: failureClass)
        try Self.validate(
            state: state,
            failureClass: failureClass,
            location: resolvedLocation,
            upstreamPreflight: resolvedPreflight,
            allowedFields: allowedFields,
            forbiddenFields: forbiddenFields,
            redactedSnapshotJSON: redactedSnapshotJSON,
            freshnessEvidenceSummary: resolvedSummary,
            capturedAtUnixSeconds: capturedAtUnixSeconds,
            sourceWatermarkUnixSeconds: sourceWatermarkUnixSeconds,
            staleAfterSeconds: staleAfterSeconds,
            upstreamPreflightEvidenceHeld: upstreamPreflightEvidenceHeld,
            rawBalancesPersisted: rawBalancesPersisted,
            accountIdentifiersPersisted: accountIdentifiersPersisted,
            secretMaterialPersisted: secretMaterialPersisted,
            rawAccountPayloadPersisted: rawAccountPayloadPersisted,
            endpointResponseBodyPersisted: endpointResponseBodyPersisted,
            orderPayloadPersisted: orderPayloadPersisted,
            malformedSnapshotAccepted: malformedSnapshotAccepted
        )
        self.artifactID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.location = resolvedLocation
        self.upstreamPreflight = resolvedPreflight
        self.allowedFields = allowedFields
        self.forbiddenFields = forbiddenFields
        self.redactedSnapshotJSON = redactedSnapshotJSON
        self.freshnessEvidenceSummary = resolvedSummary
        self.capturedAtUnixSeconds = capturedAtUnixSeconds
        self.sourceWatermarkUnixSeconds = sourceWatermarkUnixSeconds
        self.staleAfterSeconds = staleAfterSeconds
        self.upstreamPreflightEvidenceHeld = upstreamPreflightEvidenceHeld
        self.rawBalancesPersisted = rawBalancesPersisted
        self.accountIdentifiersPersisted = accountIdentifiersPersisted
        self.secretMaterialPersisted = secretMaterialPersisted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.endpointResponseBodyPersisted = endpointResponseBodyPersisted
        self.orderPayloadPersisted = orderPayloadPersisted
        self.malformedSnapshotAccepted = malformedSnapshotAccepted
    }

    public static func freshFixture() throws -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .freshRedactedArtifactReady
        )
    }

    public static func staleFixture() throws -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .staleSnapshotRejected,
            failureClass: .staleSnapshot,
            sourceWatermarkUnixSeconds: requiredCapturedAtUnixSeconds - requiredStaleAfterSeconds - 1
        )
    }

    public static func malformedFixture() throws -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .malformedSnapshotRejected,
            failureClass: .malformedSnapshot
        )
    }

    public static func rawBalanceBlockedFixture() throws
        -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .rawBalancePersistenceBlocked,
            failureClass: .rawBalancePersistenceAttempted
        )
    }

    public static func accountIdentifierBlockedFixture() throws
        -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .accountIdentifierPersistenceBlocked,
            failureClass: .accountIdentifierPersistenceAttempted
        )
    }

    public static func rawPayloadBlockedFixture() throws
        -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact(
            state: .rawPayloadPersistenceBlocked,
            failureClass: .rawAccountPayloadPersistenceAttempted
        )
    }

    public static let requiredRedactedSnapshotJSON =
        #"{"snapshot_id":"<redacted>","venue":"binance","product_kind":"spot","trading_environment":"production-live","account_status":"<redacted-readiness>","can_trade":"<readiness-only>","can_withdraw":"<readiness-only>","can_deposit":"<readiness-only>","permissions":"<redacted>","freshness_status":"fresh","freshness_age_seconds":"<bounded-age>","stale_after_seconds":30,"raw_balances":"<not-persisted>","account_id":"<redacted>","raw_account_payload":"<not-persisted>","policy_version":"v0.21.0-live-account-snapshot-redaction"}"#
    public static let requiredSummaryPrefix = "live-account-snapshot-artifact=<redacted>"
    public static let requiredBalanceMarker = "balances=<not-persisted>"
    public static let requiredAccountMarker = "account-id=<redacted>"
    public static let requiredFreshnessMarker = "freshness=<bounded>"
    public static let requiredPayloadMarker = "raw-account-payload=<not-persisted>"
    public static let requiredCapturedAtUnixSeconds = 1_772_582_400
    public static let requiredSourceWatermarkUnixSeconds = 1_772_582_388
    public static let requiredStaleAfterSeconds = 30

    public static func deterministicID(
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState,
        failureClass: ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass?
    ) -> Identifier {
        .constant(
            [
                "gh-1277-v0210-live-account-snapshot-redaction-artifact",
                state.rawValue,
                failureClass?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0210.liveAccountSnapshotRedaction.artifactID"
        )
    }

    public static func defaultFreshnessEvidenceSummary(
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState,
        capturedAtUnixSeconds: Int,
        sourceWatermarkUnixSeconds: Int,
        staleAfterSeconds: Int
    ) -> String {
        let age = capturedAtUnixSeconds - sourceWatermarkUnixSeconds
        return [
            requiredSummaryPrefix,
            "state=\(state.rawValue)",
            requiredBalanceMarker,
            requiredAccountMarker,
            requiredFreshnessMarker,
            "ageSeconds=\(age)",
            "staleAfterSeconds=\(staleAfterSeconds)",
            requiredPayloadMarker
        ].joined(separator: "; ")
    }
}

private extension ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact {
    static func validate(
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState,
        failureClass: ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass?,
        location: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactLocation,
        upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight,
        allowedFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField],
        forbiddenFields: [ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField],
        redactedSnapshotJSON: String,
        freshnessEvidenceSummary: String,
        capturedAtUnixSeconds: Int,
        sourceWatermarkUnixSeconds: Int,
        staleAfterSeconds: Int,
        upstreamPreflightEvidenceHeld: Bool,
        rawBalancesPersisted: Bool,
        accountIdentifiersPersisted: Bool,
        secretMaterialPersisted: Bool,
        rawAccountPayloadPersisted: Bool,
        endpointResponseBodyPersisted: Bool,
        orderPayloadPersisted: Bool,
        malformedSnapshotAccepted: Bool
    ) throws {
        guard upstreamPreflight.preflightHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.upstreamPreflight",
                expected: "GH-1276 signed account read-only preflight held",
                actual: upstreamPreflight.issueID.rawValue
            )
        }
        guard location.locationHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.unsafeArtifactLocation"
            )
        }
        guard allowedFields == ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.allowedFields",
                expected: ReleaseV0210SpotCanaryLiveAccountSnapshotAllowedField
                    .allCases.map(\.rawValue).joined(separator: ","),
                actual: allowedFields.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenFields == ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.forbiddenFields",
                expected: ReleaseV0210SpotCanaryLiveAccountSnapshotForbiddenField
                    .allCases.map(\.rawValue).joined(separator: ","),
                actual: forbiddenFields.map(\.rawValue).joined(separator: ",")
            )
        }
        guard staleAfterSeconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.staleAfterSeconds",
                expected: "positive freshness threshold",
                actual: "\(staleAfterSeconds)"
            )
        }
        try validateState(
            state: state,
            failureClass: failureClass,
            capturedAtUnixSeconds: capturedAtUnixSeconds,
            sourceWatermarkUnixSeconds: sourceWatermarkUnixSeconds,
            staleAfterSeconds: staleAfterSeconds,
            upstreamPreflightEvidenceHeld: upstreamPreflightEvidenceHeld,
            malformedSnapshotAccepted: malformedSnapshotAccepted
        )
        guard isSafeRedactedSnapshotJSON(redactedSnapshotJSON) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.unsafeSnapshotJSON"
            )
        }
        guard isSafeFreshnessEvidenceSummary(freshnessEvidenceSummary, state: state) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.unsafeFreshnessSummary"
            )
        }
        for (field, value) in [
            ("rawBalancesPersisted", rawBalancesPersisted),
            ("accountIdentifiersPersisted", accountIdentifiersPersisted),
            ("secretMaterialPersisted", secretMaterialPersisted),
            ("rawAccountPayloadPersisted", rawAccountPayloadPersisted),
            ("endpointResponseBodyPersisted", endpointResponseBodyPersisted),
            ("orderPayloadPersisted", orderPayloadPersisted),
            ("malformedSnapshotAccepted", malformedSnapshotAccepted)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.\(field)"
            )
        }
    }

    static func validateState(
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState,
        failureClass: ReleaseV0210SpotCanaryLiveAccountSnapshotFailureClass?,
        capturedAtUnixSeconds: Int,
        sourceWatermarkUnixSeconds: Int,
        staleAfterSeconds: Int,
        upstreamPreflightEvidenceHeld: Bool,
        malformedSnapshotAccepted: Bool
    ) throws {
        let age = capturedAtUnixSeconds - sourceWatermarkUnixSeconds
        switch (state, failureClass) {
        case (.freshRedactedArtifactReady, nil):
            guard upstreamPreflightEvidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.liveAccountSnapshotRedaction.upstreamPreflightEvidenceHeld",
                    expected: "true",
                    actual: "false"
                )
            }
            guard age >= 0, age <= staleAfterSeconds else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.liveAccountSnapshotRedaction.freshnessAgeSeconds",
                    expected: "0...\(staleAfterSeconds)",
                    actual: "\(age)"
                )
            }
        case (.staleSnapshotRejected, .staleSnapshot?):
            guard age > staleAfterSeconds else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.liveAccountSnapshotRedaction.staleSnapshot",
                    expected: "age greater than \(staleAfterSeconds)",
                    actual: "\(age)"
                )
            }
        case (.malformedSnapshotRejected, .malformedSnapshot?):
            guard malformedSnapshotAccepted == false else {
                throw CoreError.liveTradingBoundaryForbiddenCapability(
                    "releaseV0210.liveAccountSnapshotRedaction.malformedSnapshotAccepted"
                )
            }
        case (.rawBalancePersistenceBlocked, .rawBalancePersistenceAttempted?),
             (.accountIdentifierPersistenceBlocked, .accountIdentifierPersistenceAttempted?),
             (.rawPayloadPersistenceBlocked, .rawAccountPayloadPersistenceAttempted?):
            return
        case (.freshRedactedArtifactReady, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.failureClass",
                expected: "nil when fresh artifact is ready",
                actual: failureClass.rawValue
            )
        case (_, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (_, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }
    }

    static func isSafeRedactedSnapshotJSON(_ json: String) -> Bool {
        json.contains(#""snapshot_id":"<redacted>""#)
            && json.contains(#""venue":"binance""#)
            && json.contains(#""product_kind":"spot""#)
            && json.contains(#""trading_environment":"production-live""#)
            && json.contains(#""account_status":"<redacted-readiness>""#)
            && json.contains(#""can_trade":"<readiness-only>""#)
            && json.contains(#""permissions":"<redacted>""#)
            && json.contains(#""freshness_status":"fresh""#)
            && json.contains(#""raw_balances":"<not-persisted>""#)
            && json.contains(#""account_id":"<redacted>""#)
            && json.contains(#""raw_account_payload":"<not-persisted>""#)
            && json.contains(#""policy_version":"v0.21.0-live-account-snapshot-redaction""#)
            && json.localizedCaseInsensitiveContains("\"free\"") == false
            && json.localizedCaseInsensitiveContains("\"locked\"") == false
            && json.localizedCaseInsensitiveContains("commission") == false
            && json.localizedCaseInsensitiveContains("api key") == false
            && json.localizedCaseInsensitiveContains("secret") == false
            && json.localizedCaseInsensitiveContains("signature") == false
            && json.localizedCaseInsensitiveContains("listenKey") == false
            && json.localizedCaseInsensitiveContains("orderId") == false
            && json.localizedCaseInsensitiveContains("raw payload") == false
            && json.localizedCaseInsensitiveContains("broker fill") == false
    }

    static func isSafeFreshnessEvidenceSummary(
        _ summary: String,
        state: ReleaseV0210SpotCanaryLiveAccountSnapshotArtifactState
    ) -> Bool {
        summary.contains(Self.requiredSummaryPrefix)
            && summary.contains("state=\(state.rawValue)")
            && summary.contains(Self.requiredBalanceMarker)
            && summary.contains(Self.requiredAccountMarker)
            && summary.contains(Self.requiredFreshnessMarker)
            && summary.contains(Self.requiredPayloadMarker)
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("secret value") == false
            && summary.localizedCaseInsensitiveContains("secret=") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
            && summary.localizedCaseInsensitiveContains("raw payload") == false
            && summary.localizedCaseInsensitiveContains("free=") == false
            && summary.localizedCaseInsensitiveContains("locked=") == false
            && summary.localizedCaseInsensitiveContains("broker fill") == false
    }
}

/// ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence 是 GH-1277 的
/// live account snapshot redaction / freshness gate。
///
/// Gate 消费 GH-1276 signed account read-only preflight evidence，输出一个
/// redacted live account snapshot artifact schema、freshness score 和 stale /
/// malformed / sensitive persistence fail-closed evidence。它不读取 secret value、
/// 不保存 raw account payload、不连接 order endpoint、不启用真实订单，也不授权
/// production cutover。
public struct ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight
    public let freshArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let staleRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let malformedRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let rawBalanceBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let accountIdentifierBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let rawPayloadBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let signedAccountReadOnlyPreflightConsumed: Bool
    public let redactedSnapshotArtifactCaptured: Bool
    public let freshnessEvidenceCaptured: Bool
    public let staleSnapshotRejected: Bool
    public let malformedSnapshotRejected: Bool
    public let productionSecretValueRead: Bool
    public let credentialSecretValuePersisted: Bool
    public let rawBalancesPersisted: Bool
    public let accountIdentifiersPersisted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let endpointResponseBodyPersisted: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1277"
            && upstreamIssueID.rawValue == "GH-1276"
            && downstreamIssueID.rawValue == "GH-1278"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamPreflight.preflightHeld
            && freshArtifact.redactionArtifactHeld
            && failClosedEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && enabledSnapshotEvidenceHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var enabledSnapshotEvidenceHeld: Bool {
        signedAccountReadOnlyPreflightConsumed
            && redactedSnapshotArtifactCaptured
            && freshnessEvidenceCaptured
            && staleSnapshotRejected
            && malformedSnapshotRejected
    }

    public var failClosedEvidenceHeld: Bool {
        staleRejectedArtifact.state == .staleSnapshotRejected
            && staleRejectedArtifact.failureClass == .staleSnapshot
            && staleRejectedArtifact.failClosedArtifactHeld
            && malformedRejectedArtifact.state == .malformedSnapshotRejected
            && malformedRejectedArtifact.failureClass == .malformedSnapshot
            && malformedRejectedArtifact.failClosedArtifactHeld
            && rawBalanceBlockedArtifact.state == .rawBalancePersistenceBlocked
            && rawBalanceBlockedArtifact.failureClass == .rawBalancePersistenceAttempted
            && rawBalanceBlockedArtifact.failClosedArtifactHeld
            && accountIdentifierBlockedArtifact.state == .accountIdentifierPersistenceBlocked
            && accountIdentifierBlockedArtifact.failureClass == .accountIdentifierPersistenceAttempted
            && accountIdentifierBlockedArtifact.failClosedArtifactHeld
            && rawPayloadBlockedArtifact.state == .rawPayloadPersistenceBlocked
            && rawPayloadBlockedArtifact.failureClass == .rawAccountPayloadPersistenceAttempted
            && rawPayloadBlockedArtifact.failClosedArtifactHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && credentialSecretValuePersisted == false
            && rawBalancesPersisted == false
            && accountIdentifiersPersisted == false
            && rawAccountPayloadPersisted == false
            && endpointResponseBodyPersisted == false
            && orderEndpointTouched == false
            && submitCancelReplaceEnabled == false
            && privateStreamRuntimeEnabled == false
            && listenKeyRuntimeEnabled == false
            && productionBrokerConnectionEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1277-release-v0.21.0-live-account-snapshot-redaction-evidence"),
        issueID: Identifier = Identifier.constant("GH-1277"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1276"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1278"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight? = nil,
        freshArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        staleRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        malformedRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        rawBalanceBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        accountIdentifierBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        rawPayloadBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        signedAccountReadOnlyPreflightConsumed: Bool = true,
        redactedSnapshotArtifactCaptured: Bool = true,
        freshnessEvidenceCaptured: Bool = true,
        staleSnapshotRejected: Bool = true,
        malformedSnapshotRejected: Bool = true,
        productionSecretValueRead: Bool = false,
        credentialSecretValuePersisted: Bool = false,
        rawBalancesPersisted: Bool = false,
        accountIdentifiersPersisted: Bool = false,
        rawAccountPayloadPersisted: Bool = false,
        endpointResponseBodyPersisted: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        listenKeyRuntimeEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedPreflight = try upstreamPreflight
            ?? ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight.deterministicFixture()
        let resolvedFresh = try freshArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.freshFixture()
        let resolvedStale = try staleRejectedArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.staleFixture()
        let resolvedMalformed = try malformedRejectedArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.malformedFixture()
        let resolvedRawBalance = try rawBalanceBlockedArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.rawBalanceBlockedFixture()
        let resolvedAccountIdentifier = try accountIdentifierBlockedArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.accountIdentifierBlockedFixture()
        let resolvedRawPayload = try rawPayloadBlockedArtifact
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact.rawPayloadBlockedFixture()

        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueID: upstreamIssueID,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            upstreamPreflight: resolvedPreflight,
            freshArtifact: resolvedFresh,
            staleRejectedArtifact: resolvedStale,
            malformedRejectedArtifact: resolvedMalformed,
            rawBalanceBlockedArtifact: resolvedRawBalance,
            accountIdentifierBlockedArtifact: resolvedAccountIdentifier,
            rawPayloadBlockedArtifact: resolvedRawPayload,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            signedAccountReadOnlyPreflightConsumed: signedAccountReadOnlyPreflightConsumed,
            redactedSnapshotArtifactCaptured: redactedSnapshotArtifactCaptured,
            freshnessEvidenceCaptured: freshnessEvidenceCaptured,
            staleSnapshotRejected: staleSnapshotRejected,
            malformedSnapshotRejected: malformedSnapshotRejected
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            credentialSecretValuePersisted: credentialSecretValuePersisted,
            rawBalancesPersisted: rawBalancesPersisted,
            accountIdentifiersPersisted: accountIdentifiersPersisted,
            rawAccountPayloadPersisted: rawAccountPayloadPersisted,
            endpointResponseBodyPersisted: endpointResponseBodyPersisted,
            orderEndpointTouched: orderEndpointTouched,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            listenKeyRuntimeEnabled: listenKeyRuntimeEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamPreflight = resolvedPreflight
        self.freshArtifact = resolvedFresh
        self.staleRejectedArtifact = resolvedStale
        self.malformedRejectedArtifact = resolvedMalformed
        self.rawBalanceBlockedArtifact = resolvedRawBalance
        self.accountIdentifierBlockedArtifact = resolvedAccountIdentifier
        self.rawPayloadBlockedArtifact = resolvedRawPayload
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.signedAccountReadOnlyPreflightConsumed = signedAccountReadOnlyPreflightConsumed
        self.redactedSnapshotArtifactCaptured = redactedSnapshotArtifactCaptured
        self.freshnessEvidenceCaptured = freshnessEvidenceCaptured
        self.staleSnapshotRejected = staleSnapshotRejected
        self.malformedSnapshotRejected = malformedSnapshotRejected
        self.productionSecretValueRead = productionSecretValueRead
        self.credentialSecretValuePersisted = credentialSecretValuePersisted
        self.rawBalancesPersisted = rawBalancesPersisted
        self.accountIdentifiersPersisted = accountIdentifiersPersisted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.endpointResponseBodyPersisted = endpointResponseBodyPersisted
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence
    {
        try ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors = [
        "GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION",
        "TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION",
        "V0210-005-LIVE-ACCOUNT-SNAPSHOT-REDACTION",
        "V0210-005-CONSUMES-SIGNED-ACCOUNT-PREFLIGHT",
        "V0210-005-ALLOWED-READINESS-FIELDS",
        "V0210-005-FRESHNESS-STALE-FAIL-CLOSED",
        "V0210-005-NO-RAW-BALANCE-ACCOUNT-ID",
        "V0210-005-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1277ReleaseV0210LiveAccountSnapshotRedactionArtifact",
        "bash checks/verify-v0.21.0-live-account-snapshot-redaction.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueID: Identifier,
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        upstreamPreflight: ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight,
        freshArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        staleRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        malformedRejectedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        rawBalanceBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        accountIdentifierBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        rawPayloadBlockedArtifact: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1277", "GH-1277", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1276", "GH-1276", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1278", "GH-1278", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            (
                "projectName",
                projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            (
                "tradingEnvironment",
                tradingEnvironment == .productionLive,
                ReleaseV0181TradingEnvironment.productionLive.rawValue,
                tradingEnvironment.rawValue
            ),
            ("upstreamPreflight", upstreamPreflight.preflightHeld, "GH-1276 preflight held", upstreamPreflight.issueID.rawValue),
            ("freshArtifact", freshArtifact.redactionArtifactHeld, "fresh redacted artifact held", freshArtifact.state.rawValue),
            ("staleRejectedArtifact", staleRejectedArtifact.failClosedArtifactHeld, "stale fail-closed artifact", staleRejectedArtifact.state.rawValue),
            (
                "malformedRejectedArtifact",
                malformedRejectedArtifact.failClosedArtifactHeld,
                "malformed fail-closed artifact",
                malformedRejectedArtifact.state.rawValue
            ),
            (
                "rawBalanceBlockedArtifact",
                rawBalanceBlockedArtifact.failClosedArtifactHeld,
                "raw balance fail-closed artifact",
                rawBalanceBlockedArtifact.state.rawValue
            ),
            (
                "accountIdentifierBlockedArtifact",
                accountIdentifierBlockedArtifact.failClosedArtifactHeld,
                "account id fail-closed artifact",
                accountIdentifierBlockedArtifact.state.rawValue
            ),
            (
                "rawPayloadBlockedArtifact",
                rawPayloadBlockedArtifact.failClosedArtifactHeld,
                "raw payload fail-closed artifact",
                rawPayloadBlockedArtifact.state.rawValue
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

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        signedAccountReadOnlyPreflightConsumed: Bool,
        redactedSnapshotArtifactCaptured: Bool,
        freshnessEvidenceCaptured: Bool,
        staleSnapshotRejected: Bool,
        malformedSnapshotRejected: Bool
    ) throws {
        for (field, value) in [
            ("signedAccountReadOnlyPreflightConsumed", signedAccountReadOnlyPreflightConsumed),
            ("redactedSnapshotArtifactCaptured", redactedSnapshotArtifactCaptured),
            ("freshnessEvidenceCaptured", freshnessEvidenceCaptured),
            ("staleSnapshotRejected", staleSnapshotRejected),
            ("malformedSnapshotRejected", malformedSnapshotRejected)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.liveAccountSnapshotRedaction.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        credentialSecretValuePersisted: Bool,
        rawBalancesPersisted: Bool,
        accountIdentifiersPersisted: Bool,
        rawAccountPayloadPersisted: Bool,
        endpointResponseBodyPersisted: Bool,
        orderEndpointTouched: Bool,
        submitCancelReplaceEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        listenKeyRuntimeEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("credentialSecretValuePersisted", credentialSecretValuePersisted),
            ("rawBalancesPersisted", rawBalancesPersisted),
            ("accountIdentifiersPersisted", accountIdentifiersPersisted),
            ("rawAccountPayloadPersisted", rawAccountPayloadPersisted),
            ("endpointResponseBodyPersisted", endpointResponseBodyPersisted),
            ("orderEndpointTouched", orderEndpointTouched),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("listenKeyRuntimeEnabled", listenKeyRuntimeEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.liveAccountSnapshotRedaction.\(field)"
            )
        }
    }
}
