import DomainModel
import Foundation

// GH-1178 static contract boundary:
// statusQueryRetryArtifactPersistence=ReleaseV0180StatusQueryRetryArtifactPersistence
// retryAttemptsPersisted=true
// timeoutResultPersisted=true
// classifiedFailurePersisted=true
// redactionStatusPersisted=true
// venueProductEnvironmentNamespacePersisted=true
// localArtifactStoreReplayable=true
// failedStatusQueryFailClosed=true
// operatorVisibleFailureEvidence=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
// TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
// V0180-003-DEPENDENCY-GH1177-DONE
// V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED
// V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
// V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION
// V0180-003-REDACTION-STATUS-PERSISTED
// V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE
// V0180-003-LOCAL-ARTIFACT-STORE-REPLAY
// V0180-003-NO-PRODUCTION-CUTOVER
// GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS
// TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS
// V0181-004-RUNS-NAMESPACE-PATH
// V0181-004-V0180-ACTIVE-PATHS-MIGRATED
// V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED
// V0181-004-OLD-VERSION-FIXTURES-PRESERVED
// V0181-004-NO-PRODUCTION-CUTOVER
// GH-1204-VERIFY-V0181-TYPED-NAMESPACE-MODEL
// TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL
// V0181-005-TYPED-VENUE-PRODUCT-ENVIRONMENT
// V0181-005-ACCOUNT-PROFILE-ID
// V0181-005-ALLOWED-PAIRS-FAIL-CLOSED
// V0181-005-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
// V0181-005-JSON-CODEC-MIGRATION
// V0181-005-NO-PRODUCTION-CUTOVER

/// ReleaseV0180StatusQueryRetryArtifactNamespace 是 GH-1178 在 ExecutionClient 内使用的
/// status-query artifact namespace。
///
/// `Database` target 已在 GH-1177 定义 run artifact lifecycle namespace；ExecutionClient
/// 不能反向依赖 Database，因此这里保留同形字段和同一 namespace key 语义。#1204 起，
/// 关键字段由 typed VenueID / ProductKind / TradingEnvironment / AccountProfileID 存储，
/// 对外 JSON 仍编码为既有 raw value，便于旧 evidence 迁移。
public struct ReleaseV0180StatusQueryRetryArtifactNamespace: Codable, Equatable, Sendable {
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let accountProfileID: ReleaseV0181AccountProfileID
    public let runID: Identifier

    public var venue: String { venueID.rawValue }

    public var product: String { productKind.rawValue }

    public var environment: String { tradingEnvironment.rawValue }

    public var accountProfile: String { accountProfileID.rawValue }

    public var namespaceKey: String {
        [
            "venue=\(venue)",
            "product=\(product)",
            "environment=\(environment)",
            "accountProfile=\(accountProfile)",
            "runID=\(runID.rawValue)"
        ].joined(separator: "|")
    }

    public var venueProductPairSupported: Bool {
        ReleaseV0181VenueProductNamespacePolicy.supportsPair(
            venueID: venueID,
            productKind: productKind
        )
    }

    public var namespaceHeld: Bool {
        ReleaseV0181VenueProductNamespacePolicy.supportsCriticalNamespace(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment
        )
            && runID.rawValue.isEmpty == false
            && ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers(in: namespaceKey).isEmpty
    }

    private enum CodingKeys: String, CodingKey {
        case venue
        case product
        case environment
        case accountProfile
        case runID
    }

    public init(
        venue: String,
        product: String,
        environment: String,
        accountProfile: String,
        runID: Identifier
    ) throws {
        try self.init(
            venueID: ReleaseV0181VenueID(validating: venue, field: "v0180StatusQueryRetryArtifact.venue"),
            productKind: ReleaseV0181ProductKind(validating: product, field: "v0180StatusQueryRetryArtifact.product"),
            tradingEnvironment: ReleaseV0181TradingEnvironment(
                validating: environment,
                field: "v0180StatusQueryRetryArtifact.environment"
            ),
            accountProfileID: ReleaseV0181AccountProfileID(
                accountProfile,
                field: "v0180StatusQueryRetryArtifact.accountProfile"
            ),
            runID: runID
        )
    }

    public init(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID,
        runID: Identifier
    ) throws {
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.accountProfileID = accountProfileID
        self.runID = runID

        guard namespaceHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.namespace")
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            venue: container.decode(String.self, forKey: .venue),
            product: container.decode(String.self, forKey: .product),
            environment: container.decode(String.self, forKey: .environment),
            accountProfile: container.decode(String.self, forKey: .accountProfile),
            runID: container.decode(Identifier.self, forKey: .runID)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(venue, forKey: .venue)
        try container.encode(product, forKey: .product)
        try container.encode(environment, forKey: .environment)
        try container.encode(accountProfile, forKey: .accountProfile)
        try container.encode(runID, forKey: .runID)
    }
}

/// ReleaseV0180StatusQueryRetryAttemptSnapshot 保存单次 status-query attempt 的脱敏 replay 字段。
///
/// Snapshot 只保留 retry / timeout / classification 所需字段，不保存 raw request、raw response、
/// credential value、raw order id 或 broker payload。
public struct ReleaseV0180StatusQueryRetryAttemptSnapshot: Codable, Equatable, Sendable {
    public let attemptID: Identifier
    public let attemptIndex: Int
    public let timeoutMilliseconds: Int
    public let status: ReleaseV0170SignedStatusQueryValidationStatus
    public let failureReason: ReleaseV0170SignedStatusQueryFailureReason?
    public let failureField: String?
    public let retryScheduled: Bool
    public let retryableFailure: Bool
    public let failClosed: Bool
    public let redactedFailureEvidenceOnly: Bool

    public var attemptSnapshotHeld: Bool {
        attemptIndex > 0
            && timeoutMilliseconds > 0
            && redactedFailureEvidenceOnly
            && ((status == .passed
                && failureReason == nil
                && failureField == nil
                && retryScheduled == false
                && retryableFailure == false
                && failClosed)
                || (status == .failed
                    && failureReason != nil
                    && failureField?.isEmpty == false
                    && failClosed))
    }

    public init(attempt: ReleaseV0170SignedStatusQueryAttemptEvidence) throws {
        self.attemptID = attempt.attemptID
        self.attemptIndex = attempt.attemptIndex
        self.timeoutMilliseconds = attempt.timeoutMilliseconds
        self.status = attempt.status
        self.failureReason = attempt.failure?.reason
        self.failureField = attempt.failure?.field
        self.retryScheduled = attempt.retryScheduled
        self.retryableFailure = attempt.failure?.retryable ?? false
        self.failClosed = attempt.failure?.failClosed ?? true
        self.redactedFailureEvidenceOnly = attempt.redactedFailureEvidenceOnly

        guard attemptSnapshotHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift(
                "v0180StatusQueryRetryArtifact.attempt.\(attempt.attemptIndex)"
            )
        }
    }
}

/// ReleaseV0180StatusQueryRetryArtifactSnapshot 是写入 artifact payload 的结构化 GH-1178 证据。
///
/// 它把 retry attempts、timeout result、classified failure、redaction status 与
/// venue/product/environment namespace 一起持久化到 append-only payload JSON 中，使本地 replay
/// 不需要重新触发 status query。
public struct ReleaseV0180StatusQueryRetryArtifactSnapshot: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let releaseVersion: String
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let resultID: Identifier
    public let signedStatusQueryRequestID: Identifier
    public let status: ReleaseV0170SignedStatusQueryValidationStatus
    public let attemptSnapshots: [ReleaseV0180StatusQueryRetryAttemptSnapshot]
    public let retryAttemptsPersisted: Bool
    public let timeoutResultPersisted: Bool
    public let classifiedFailurePersisted: Bool
    public let redactionStatus: String
    public let redactionStatusPersisted: Bool
    public let venueProductEnvironmentNamespacePersisted: Bool
    public let localArtifactStoreReplayable: Bool
    public let failedStatusQueryFailClosed: Bool
    public let operatorVisibleFailureEvidence: Bool
    public let operatorNextAction: String
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var classifiedFailureReasons: [ReleaseV0170SignedStatusQueryFailureReason] {
        attemptSnapshots.compactMap(\.failureReason)
    }

    public var snapshotHeld: Bool {
        issueID.rawValue == "GH-1178"
            && blockedByIssueID.rawValue == "GH-1177"
            && releaseVersion == "v0.18.0"
            && namespace.namespaceHeld
            && namespace.runID.rawValue.isEmpty == false
            && resultID.rawValue.isEmpty == false
            && signedStatusQueryRequestID.rawValue.isEmpty == false
            && attemptSnapshots.isEmpty == false
            && attemptSnapshots.allSatisfy(\.attemptSnapshotHeld)
            && retryAttemptsPersisted
            && classifiedFailurePersisted == (classifiedFailureReasons.isEmpty == false)
            && redactionStatus == "redactedEvidenceOnly"
            && redactionStatusPersisted
            && venueProductEnvironmentNamespacePersisted
            && localArtifactStoreReplayable
            && operatorNextAction.isEmpty == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
            && ((status == .passed
                && timeoutResultPersisted == false
                && failedStatusQueryFailClosed
                && operatorVisibleFailureEvidence == false)
                || (status == .failed
                    && timeoutResultPersisted == classifiedFailureReasons.contains(.timeout)
                    && classifiedFailureReasons.isEmpty == false
                    && failedStatusQueryFailClosed
                    && operatorVisibleFailureEvidence))
    }

    public init(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        result: ReleaseV0170SignedStatusQueryResult,
        issueID: Identifier = .constant("GH-1178"),
        blockedByIssueID: Identifier = .constant("GH-1177"),
        releaseVersion: String = "v0.18.0",
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let attemptSnapshots = try result.attempts.map(ReleaseV0180StatusQueryRetryAttemptSnapshot.init(attempt:))
        let failureReasons = attemptSnapshots.compactMap(\.failureReason)
        self.issueID = issueID
        self.blockedByIssueID = blockedByIssueID
        self.releaseVersion = releaseVersion
        self.namespace = namespace
        self.resultID = result.resultID
        self.signedStatusQueryRequestID = result.signedStatusQueryRequestID
        self.status = result.status
        self.attemptSnapshots = attemptSnapshots
        self.retryAttemptsPersisted = true
        self.timeoutResultPersisted = failureReasons.contains(.timeout)
        self.classifiedFailurePersisted = failureReasons.isEmpty == false
        self.redactionStatus = "redactedEvidenceOnly"
        self.redactionStatusPersisted = true
        self.venueProductEnvironmentNamespacePersisted = true
        self.localArtifactStoreReplayable = true
        self.failedStatusQueryFailClosed = true
        self.operatorVisibleFailureEvidence = result.status == .failed
        self.operatorNextAction = result.status == .failed
            ? "review-redacted-status-query-failure-before-resume"
            : "continue-from-replayed-status-query-evidence"
        self.productionTradingEnabledByDefault = false
        self.productionSecretReadEnabled = false
        self.productionEndpointConnectionEnabled = false
        self.productionBrokerConnectionEnabled = false
        self.productionOrderSubmitCancelReplaceEnabled = false
        self.productionCutoverAuthorized = false
        self.validationAnchors = validationAnchors

        guard result.resultHeld, snapshotHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.snapshot")
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE",
        "TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE",
        "V0180-003-DEPENDENCY-GH1177-DONE",
        "V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED",
        "V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE",
        "V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION",
        "V0180-003-REDACTION-STATUS-PERSISTED",
        "V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE",
        "V0180-003-LOCAL-ARTIFACT-STORE-REPLAY",
        "V0180-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1178StatusQueryRetryResultPersistsNamespaceAndFailureIntoArtifactStore",
        "bash checks/verify-v0.18.0-status-query-retry-artifact-persistence.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV0180StatusQueryRetryArtifactPersistence 是 GH-1178 append / validate 的返回证据。
public struct ReleaseV0180StatusQueryRetryArtifactPersistence: Equatable, Sendable {
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let snapshot: ReleaseV0180StatusQueryRetryArtifactSnapshot
    public let payload: ReleaseV0160LocalExecutionArtifactPayload
    public let record: ReleaseV0160LocalExecutionArtifactRecord
    public let replay: ReleaseV0160LocalExecutionArtifactReplay

    public var persistenceHeld: Bool {
        namespace == snapshot.namespace
            && payload.kind == .status
            && payload.statusQueryRetrySnapshot == snapshot
            && payload.evidenceID == snapshot.resultID
            && record.kind == .status
            && record.runID == namespace.runID
            && record.evidenceID == snapshot.resultID
            && replay.runID == namespace.runID
            && replay.replayedKinds.contains(.status)
            && replay.chainValidated
            && snapshot.snapshotHeld
            && payload.boundaryHeld
            && record.recordHeld
            && replay.replayHeld
    }
}

public extension ReleaseV0160LocalExecutionArtifactStore {
    /// 将 GH-1178 status-query retry result 写入现有 append-only artifact store。
    ///
    /// 写入内容包括结构化 snapshot 与通用 artifact record；调用方随后可通过
    /// `validateStatusQueryRetryResult` 在本地重放同一证据，不需要重新连接 endpoint。
    func appendStatusQueryRetryResult(
        runID: Identifier,
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        result: ReleaseV0170SignedStatusQueryResult,
        observedAt: Date
    ) throws -> ReleaseV0180StatusQueryRetryArtifactPersistence {
        guard namespace.runID == runID else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.runID")
        }

        let snapshot = try ReleaseV0180StatusQueryRetryArtifactSnapshot(
            namespace: namespace,
            result: result
        )
        let payload = try ReleaseV0160LocalExecutionArtifactPayload(
            kind: .status,
            evidenceID: snapshot.resultID,
            redactedSummary: Self.v0180StatusQueryRetrySummary(snapshot: snapshot),
            redactedEvidenceReferences: Self.v0180StatusQueryRetryReferences(snapshot: snapshot),
            observedAt: observedAt,
            statusQueryRetrySnapshot: snapshot
        )
        let record = try append(runID: runID, payload: payload, appendedAt: observedAt)
        let replay = try replay(runID: runID)
        let persistence = ReleaseV0180StatusQueryRetryArtifactPersistence(
            namespace: namespace,
            snapshot: snapshot,
            payload: payload,
            record: record,
            replay: replay
        )
        guard persistence.persistenceHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.persistence")
        }
        return persistence
    }

    /// 从本地 artifact store replay 最新 status-query retry snapshot 并校验 namespace。
    func validateStatusQueryRetryResult(
        runID: Identifier,
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    ) throws -> ReleaseV0180StatusQueryRetryArtifactPersistence {
        guard namespace.runID == runID else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.runID")
        }

        let replay = try replay(runID: runID)
        guard let record = replay.records.last(where: { $0.kind == .status }) else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.missingArtifact("v0180StatusQueryRetryArtifact.status")
        }
        let data = try Data(contentsOf: fileURL(forRelativePath: record.payloadPath))
        let payload = try Self.v0180StatusQueryPayloadDecoder.decode(
            ReleaseV0160LocalExecutionArtifactPayload.self,
            from: data
        )
        guard let snapshot = payload.statusQueryRetrySnapshot else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.snapshot")
        }
        guard snapshot.namespace == namespace else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.namespace")
        }

        let persistence = ReleaseV0180StatusQueryRetryArtifactPersistence(
            namespace: namespace,
            snapshot: snapshot,
            payload: payload,
            record: record,
            replay: replay
        )
        guard persistence.persistenceHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180StatusQueryRetryArtifact.validation")
        }
        return persistence
    }

    private static var v0180StatusQueryPayloadDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func v0180StatusQueryRetrySummary(
        snapshot: ReleaseV0180StatusQueryRetryArtifactSnapshot
    ) -> String {
        [
            "GH-1178 status query retry result persisted",
            "status=\(snapshot.status.rawValue)",
            "namespace=\(snapshot.namespace.namespaceKey)",
            "attempts=\(snapshot.attemptSnapshots.count)",
            "failureReasons=\(snapshot.classifiedFailureReasons.map(\.rawValue).joined(separator: ","))",
            "redactionStatus=\(snapshot.redactionStatus)",
            "nextAction=\(snapshot.operatorNextAction)"
        ].joined(separator: "; ")
    }

    private static func v0180StatusQueryRetryReferences(
        snapshot: ReleaseV0180StatusQueryRetryArtifactSnapshot
    ) -> [String] {
        [
            ".local/mtpro/runs/\(snapshot.namespace.venue)/\(snapshot.namespace.product)/\(snapshot.namespace.environment)/\(snapshot.namespace.accountProfile)/\(snapshot.namespace.runID.rawValue)/artifacts/status-query-retry-result-redacted.json",
            "namespace:\(snapshot.namespace.namespaceKey)",
            "resultID:\(snapshot.resultID.rawValue)",
            "redaction:\(snapshot.redactionStatus)",
            "operatorNextAction:\(snapshot.operatorNextAction)"
        ]
    }
}
