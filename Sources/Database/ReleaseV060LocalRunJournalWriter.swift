import Crypto
import DomainModel
import Foundation

/// ReleaseV060LocalRunJournalWriterError 描述 GH-756 本地 run journal writer 的文件系统合同错误。
///
/// 错误只覆盖本地 `.local/mtpro/runs/<runID>/` artifact 写入和 run 状态判断；
/// 不表达 endpoint、secret、broker、OMS production runtime 或真实订单能力。
public enum ReleaseV060LocalRunJournalWriterError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case completedRunRewriteRejected(String)
    case eventLogAlreadyContainsRecords(String)
    case missingArtifact(String)
    case artifactMetadataMismatch(String)
    case checksumMismatch(path: String, expected: String, actual: String)
    case byteCountMismatch(path: String, expected: Int, actual: Int)
    case invalidStatusPayload(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.6.0 local run journal writer requires a non-empty runID"
        case let .completedRunRewriteRejected(path):
            "Release v0.6.0 local run journal writer rejects completed run rewrite at \(path)"
        case let .eventLogAlreadyContainsRecords(path):
            "Release v0.6.0 local run journal writer refuses to overwrite existing JSONL records at \(path)"
        case let .missingArtifact(path):
            "Release v0.6.0 local run journal writer cannot classify completed run without artifact \(path)"
        case let .artifactMetadataMismatch(reason):
            "Release v0.6.0 local run manifest artifact metadata is inconsistent: \(reason)"
        case let .checksumMismatch(path, expected, actual):
            "Release v0.6.0 local run artifact checksum mismatch at \(path), expected \(expected), actual \(actual)"
        case let .byteCountMismatch(path, expected, actual):
            "Release v0.6.0 local run artifact byte count mismatch at \(path), expected \(expected), actual \(actual)"
        case let .invalidStatusPayload(path):
            "Release v0.6.0 local run journal writer cannot decode status payload at \(path)"
        }
    }
}

/// ReleaseV0180RunArtifactLifecycleNamespace 固定 GH-1177 的 venue/product/environment namespace。
///
/// Namespace 是 v0.18.0 run artifact lifecycle manifest 的唯一边界键。它只用于本地
/// evidence 关联和 fail-closed validation，不会触发 endpoint、broker、secret 或订单能力。
/// #1210 起，关键字段使用 DomainModel 的 typed VenueID / ProductKind / TradingEnvironment /
/// AccountProfileID 存储；JSON 仍按旧 raw key 编码，便于历史 fixture migration。
/// GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
/// TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
/// V0180-002-DEPENDENCY-GH1176-DONE
/// V0180-002-LIFECYCLE-MANIFEST-SCHEMA
/// V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
/// V0180-002-ACCOUNT-RUNID-BINDING
/// V0180-002-BOUNDARY-REUSE-REJECTION
/// V0180-002-LOCAL-EVIDENCE-ONLY
/// V0180-002-NO-PRODUCTION-CUTOVER
/// GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
/// TVM-RELEASE-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
/// V0190-005-TYPED-LIFECYCLE-NAMESPACE
/// V0190-005-JSON-DECODE-MIGRATION
/// V0190-005-DASHBOARD-NAMESPACE-CONSISTENCY
/// V0190-005-NAMESPACE-MISMATCH-FAILS-CLOSED
/// V0190-005-NO-PRODUCTION-CUTOVER
public struct ReleaseV0180RunArtifactLifecycleNamespace: Codable, Equatable, Sendable {
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
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: namespaceKey).isEmpty
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
            venueID: ReleaseV0181VenueID(validating: venue, field: "v0180RunArtifactLifecycle.venue"),
            productKind: ReleaseV0181ProductKind(validating: product, field: "v0180RunArtifactLifecycle.product"),
            tradingEnvironment: ReleaseV0181TradingEnvironment(
                validating: environment,
                field: "v0180RunArtifactLifecycle.environment"
            ),
            accountProfileID: ReleaseV0181AccountProfileID(
                accountProfile,
                field: "v0180RunArtifactLifecycle.accountProfile"
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
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "GH-1177 namespace requires venue/product/environment/accountProfile/runID"
            )
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

/// ReleaseV060LocalRunJournalWriterState 是 `_RUN_STATUS.json` 的 run 状态枚举。
///
/// `completed` 只有在 manifest 与所有 required artifacts 存在时才会被 inspect 视为完成；
/// manifest 缺失时，writer 必须把 run 视为 `incomplete`。
public enum ReleaseV060LocalRunJournalWriterState: String, Codable, CaseIterable, Equatable, Sendable {
    case completed
    case failed
    case incomplete
}

/// ReleaseV060LocalRunJournalWriterStatus 是 GH-756 `_RUN_STATUS.json` 的本地状态 shape。
public struct ReleaseV060LocalRunJournalWriterStatus: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let state: ReleaseV060LocalRunJournalWriterState
    public let eventCount: Int
    public let requiredArtifactsPresent: Bool
    public let manifestPresent: Bool
    public let completed: Bool
    public let failureReason: String?
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var statusHeld: Bool {
        issueID.rawValue == "GH-756"
            && eventCount >= 0
            && completed == (state == .completed && requiredArtifactsPresent && manifestPresent)
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-756"),
        runID: Identifier,
        state: ReleaseV060LocalRunJournalWriterState,
        eventCount: Int,
        requiredArtifactsPresent: Bool,
        manifestPresent: Bool,
        failureReason: String? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV060LocalRunJournalWriterError.emptyRunID
        }
        self.issueID = issueID
        self.runID = runID
        self.state = state
        self.eventCount = eventCount
        self.requiredArtifactsPresent = requiredArtifactsPresent
        self.manifestPresent = manifestPresent
        self.completed = state == .completed && requiredArtifactsPresent && manifestPresent
        self.failureReason = failureReason
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard statusHeld else {
            throw ReleaseV060LocalRunJournalWriterError.invalidStatusPayload("_RUN_STATUS.json")
        }
    }
}

/// ReleaseV060LocalRunJournalArtifactMetadata 是 GH-757 `manifest.json` 中的 artifact 审计元数据。
///
/// 元数据只描述本地 artifact path、schemaVersion、sha256、bytes、createdAt 与 required 标记；
/// 它不代表远程签名、生产 attestation、broker payload 或真实订单授权。
public struct ReleaseV060LocalRunJournalArtifactMetadata: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.6.0.local-run-artifact.v1"

    public let path: String
    public let schemaVersion: String
    public let sha256: String
    public let bytes: Int
    public let createdAt: Date
    public let required: Bool

    public var metadataHeld: Bool {
        path.isEmpty == false
            && schemaVersion == Self.schemaVersion
            && sha256.hasPrefix("sha256:")
            && bytes >= 0
            && required
    }

    public init(
        path: String,
        schemaVersion: String = Self.schemaVersion,
        sha256: String,
        bytes: Int,
        createdAt: Date,
        required: Bool = true
    ) throws {
        self.path = path
        self.schemaVersion = schemaVersion
        self.sha256 = sha256
        self.bytes = bytes
        self.createdAt = createdAt
        self.required = required

        guard metadataHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(path)
        }
    }
}

/// ReleaseV060LocalRunJournalWriterManifest 是 GH-756 `manifest.json` 的本地完成证据。
public struct ReleaseV060LocalRunJournalWriterManifest: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let runDirectoryPath: String
    public let eventFileName: String
    public let projectionFileName: String
    public let summaryFileName: String
    public let statusFileName: String
    public let manifestFileName: String
    public let writeOrder: [String]
    public let artifactMetadataSchemaVersion: String
    public let artifacts: [ReleaseV060LocalRunJournalArtifactMetadata]
    public let eventCount: Int
    public let eventsAppendOnly: Bool
    public let atomicArtifactsWritten: Bool
    public let manifestWrittenLast: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-756"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-755", "GH-731"]
            && releaseVersion == "v0.6.0"
            && eventFileName == "events.jsonl"
            && projectionFileName == "projection.json"
            && summaryFileName == "summary.json"
            && statusFileName == "_RUN_STATUS.json"
            && manifestFileName == "manifest.json"
            && writeOrder == [eventFileName, projectionFileName, summaryFileName, statusFileName, manifestFileName]
            && artifactMetadataSchemaVersion == ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
            && artifacts.map { URL(fileURLWithPath: $0.path).lastPathComponent }
                == [eventFileName, projectionFileName, summaryFileName, statusFileName]
            && artifacts.allSatisfy(\.metadataHeld)
            && eventCount > 0
            && eventsAppendOnly
            && atomicArtifactsWritten
            && manifestWrittenLast
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-756"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-755"), Identifier.constant("GH-731")],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        runDirectoryPath: String,
        eventFileName: String = "events.jsonl",
        projectionFileName: String = "projection.json",
        summaryFileName: String = "summary.json",
        statusFileName: String = "_RUN_STATUS.json",
        manifestFileName: String = "manifest.json",
        artifacts: [ReleaseV060LocalRunJournalArtifactMetadata],
        eventCount: Int,
        eventsAppendOnly: Bool = true,
        atomicArtifactsWritten: Bool = true,
        manifestWrittenLast: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV060LocalRunJournalWriterError.emptyRunID
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.runDirectoryPath = runDirectoryPath
        self.eventFileName = eventFileName
        self.projectionFileName = projectionFileName
        self.summaryFileName = summaryFileName
        self.statusFileName = statusFileName
        self.manifestFileName = manifestFileName
        self.writeOrder = [eventFileName, projectionFileName, summaryFileName, statusFileName, manifestFileName]
        self.artifactMetadataSchemaVersion = ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
        self.artifacts = artifacts
        self.eventCount = eventCount
        self.eventsAppendOnly = eventsAppendOnly
        self.atomicArtifactsWritten = atomicArtifactsWritten
        self.manifestWrittenLast = manifestWrittenLast
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard manifestHeld else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(manifestFileName)
        }
    }
}

/// ReleaseV060LocalRunJournalManifestValidation 是 GH-757 本地 manifest 校验结果。
///
/// Validation 只证明本地 required artifact 存在、bytes 与 sha256 和 manifest 一致；
/// 它不连接 endpoint、不读取 secret、不执行 broker command、不授权 production cutover。
public struct ReleaseV060LocalRunJournalManifestValidation: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let runID: Identifier
    public let artifactMetadataSchemaVersion: String
    public let checkedArtifactCount: Int
    public let artifacts: [ReleaseV060LocalRunJournalArtifactMetadata]
    public let validationPassed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var validationHeld: Bool {
        issueID.rawValue == "GH-757"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-755"]
            && artifactMetadataSchemaVersion == ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
            && checkedArtifactCount == artifacts.count
            && checkedArtifactCount > 0
            && artifacts.allSatisfy(\.metadataHeld)
            && validationPassed
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-757"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-756"), Identifier.constant("GH-755")],
        runID: Identifier,
        artifactMetadataSchemaVersion: String = ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion,
        artifacts: [ReleaseV060LocalRunJournalArtifactMetadata],
        validationPassed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.runID = runID
        self.artifactMetadataSchemaVersion = artifactMetadataSchemaVersion
        self.checkedArtifactCount = artifacts.count
        self.artifacts = artifacts
        self.validationPassed = validationPassed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard validationHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch("GH-757 validation result")
        }
    }
}

/// ReleaseV0180RunArtifactLifecycleManifest 是 GH-1177 的 v0.18.0 lifecycle manifest。
///
/// 它把既有本地 run manifest 绑定到 `{venue, product, environment, accountProfile, runID}`
/// namespace。该 manifest 只描述本地 artifact lifecycle，不授权 production cutover、secret
/// read、endpoint connection、broker connection 或 submit / cancel / replace。
public struct ReleaseV0180RunArtifactLifecycleManifest: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.18.0.run-artifact-lifecycle-manifest.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let namespace: ReleaseV0180RunArtifactLifecycleNamespace
    public let runDirectoryPath: String
    public let sourceRunManifestPath: String
    public let sourceRunManifestSchemaVersion: String
    public let requiredArtifactFileNames: [String]
    public let requiredArtifactChecksums: [String]
    public let artifactLifecycleState: String
    public let statusQueryPersistenceNamespace: String
    public let resumeNamespace: String
    public let reconciliationReplayNamespace: String
    public let cliNextActionNamespace: String
    public let dashboardDrilldownNamespace: String
    public let lifecycleChecksum: String
    public let localEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-1177"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1176"]
            && releaseVersion == "v0.18.0"
            && schemaVersion == Self.schemaVersion
            && namespace.namespaceHeld
            && runDirectoryPath.isEmpty == false
            && sourceRunManifestPath.hasSuffix(ReleaseV060LocalRunJournalWriter.manifestFileName)
            && sourceRunManifestSchemaVersion == ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
            && requiredArtifactFileNames == ["events.jsonl", "projection.json", "summary.json", "_RUN_STATUS.json"]
            && requiredArtifactChecksums.count == requiredArtifactFileNames.count
            && requiredArtifactChecksums.allSatisfy { $0.hasPrefix("sha256:") }
            && artifactLifecycleState == "completed-local-run-artifacts-validated"
            && statusQueryPersistenceNamespace == namespace.namespaceKey
            && resumeNamespace == namespace.namespaceKey
            && reconciliationReplayNamespace == namespace.namespaceKey
            && cliNextActionNamespace == namespace.namespaceKey
            && dashboardDrilldownNamespace == namespace.namespaceKey
            && lifecycleChecksum == Self.stableLifecycleChecksum(
                namespace: namespace,
                sourceRunManifestPath: sourceRunManifestPath,
                requiredArtifactChecksums: requiredArtifactChecksums
            )
            && localEvidenceOnly
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1177"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1176")],
        releaseVersion: String = "v0.18.0",
        schemaVersion: String = Self.schemaVersion,
        namespace: ReleaseV0180RunArtifactLifecycleNamespace,
        runDirectoryPath: String,
        sourceRunManifestPath: String,
        sourceValidation: ReleaseV060LocalRunJournalManifestValidation,
        artifactLifecycleState: String = "completed-local-run-artifacts-validated",
        localEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.namespace = namespace
        self.runDirectoryPath = runDirectoryPath
        self.sourceRunManifestPath = sourceRunManifestPath
        self.sourceRunManifestSchemaVersion = sourceValidation.artifactMetadataSchemaVersion
        self.requiredArtifactFileNames = sourceValidation.artifacts.map {
            URL(fileURLWithPath: $0.path).lastPathComponent
        }
        self.requiredArtifactChecksums = sourceValidation.artifacts.map(\.sha256)
        self.artifactLifecycleState = artifactLifecycleState
        self.statusQueryPersistenceNamespace = namespace.namespaceKey
        self.resumeNamespace = namespace.namespaceKey
        self.reconciliationReplayNamespace = namespace.namespaceKey
        self.cliNextActionNamespace = namespace.namespaceKey
        self.dashboardDrilldownNamespace = namespace.namespaceKey
        self.lifecycleChecksum = Self.stableLifecycleChecksum(
            namespace: namespace,
            sourceRunManifestPath: sourceRunManifestPath,
            requiredArtifactChecksums: sourceValidation.artifacts.map(\.sha256)
        )
        self.localEvidenceOnly = localEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard manifestHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "GH-1177 lifecycle manifest"
            )
        }
    }

    public static func stableLifecycleChecksum(
        namespace: ReleaseV0180RunArtifactLifecycleNamespace,
        sourceRunManifestPath: String,
        requiredArtifactChecksums: [String]
    ) -> String {
        ReleaseV060LocalRunJournalWriter.sha256Hex(
            Data(([
                "GH-1177",
                "v0.18.0",
                Self.schemaVersion,
                namespace.namespaceKey,
                sourceRunManifestPath
            ] + requiredArtifactChecksums).joined(separator: "|").utf8)
        )
    }
}

/// ReleaseV0180RunArtifactLifecycleManifestValidation 是 GH-1177 的 namespace-aware 校验结果。
///
/// Validation 必须同时证明旧 run manifest artifact 完整，以及 v0.18 lifecycle manifest 未被跨
/// venue/product/environment/accountProfile/runID 重用。任何 namespace mismatch 都必须 fail closed。
public struct ReleaseV0180RunArtifactLifecycleManifestValidation: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let expectedNamespace: ReleaseV0180RunArtifactLifecycleNamespace
    public let observedNamespace: ReleaseV0180RunArtifactLifecycleNamespace
    public let namespaceMatched: Bool
    public let venueProductEnvironmentMatched: Bool
    public let sourceRunManifestValidation: ReleaseV060LocalRunJournalManifestValidation
    public let lifecycleChecksum: String
    public let validationPassed: Bool
    public let localEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var validationHeld: Bool {
        issueID.rawValue == "GH-1177"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1176"]
            && releaseVersion == "v0.18.0"
            && expectedNamespace.namespaceHeld
            && observedNamespace.namespaceHeld
            && namespaceMatched
            && venueProductEnvironmentMatched
            && sourceRunManifestValidation.validationHeld
            && lifecycleChecksum.hasPrefix("sha256:")
            && validationPassed
            && localEvidenceOnly
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1177"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1176")],
        releaseVersion: String = "v0.18.0",
        expectedNamespace: ReleaseV0180RunArtifactLifecycleNamespace,
        manifest: ReleaseV0180RunArtifactLifecycleManifest,
        sourceRunManifestValidation: ReleaseV060LocalRunJournalManifestValidation,
        validationPassed: Bool = true,
        localEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.expectedNamespace = expectedNamespace
        self.observedNamespace = manifest.namespace
        self.namespaceMatched = expectedNamespace == manifest.namespace
        self.venueProductEnvironmentMatched = expectedNamespace.venue == manifest.namespace.venue
            && expectedNamespace.product == manifest.namespace.product
            && expectedNamespace.environment == manifest.namespace.environment
        self.sourceRunManifestValidation = sourceRunManifestValidation
        self.lifecycleChecksum = manifest.lifecycleChecksum
        self.validationPassed = validationPassed
        self.localEvidenceOnly = localEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard validationHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "GH-1177 lifecycle namespace mismatch"
            )
        }
    }
}

/// ReleaseV060LocalRunJournalWriterResult 汇总一次 completed run 的落盘结果。
public struct ReleaseV060LocalRunJournalWriterResult: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let eventsJSONLPath: String
    public let projectionJSONPath: String
    public let summaryJSONPath: String
    public let statusJSONPath: String
    public let manifestJSONPath: String
    public let status: ReleaseV060LocalRunJournalWriterStatus
    public let manifest: ReleaseV060LocalRunJournalWriterManifest

    public var resultHeld: Bool {
        status.statusHeld
            && status.state == .completed
            && status.completed
            && manifest.manifestHeld
            && manifest.manifestWrittenLast
    }
}

/// ReleaseV070RuntimeEventLogWriterError 描述 GH-784 runtime append / recovery 的本地 JSONL 错误。
///
/// 错误只覆盖 `.local/mtpro/runs/<runID>/events.jsonl` 的本地 append、checksum、
/// duplicate eventID、partial line recovery 和 lock / fsync 证据；不表达 endpoint、
/// secret、broker、OMS production runtime 或真实订单能力。
public enum ReleaseV070RuntimeEventLogWriterError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case emptyAppendBatch
    case emptyPayload(String)
    case payloadContainsNewline(String)
    case duplicateEventID(String)
    case invalidEventLine(path: String, lineNumber: Int)
    case eventChecksumMismatch(eventID: String, expected: String, actual: String)
    case lineChecksumMismatch(eventID: String, expected: String, actual: String)
    case previousLineChecksumMismatch(eventID: String, expected: String, actual: String)
    case runIDMismatch(expected: String, actual: String)
    case lockUnavailable(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.7.0 runtime event log writer requires a non-empty runID"
        case .emptyAppendBatch:
            "Release v0.7.0 runtime event log writer requires at least one event per append batch"
        case let .emptyPayload(eventID):
            "Release v0.7.0 runtime event log writer rejects empty payload for event \(eventID)"
        case let .payloadContainsNewline(eventID):
            "Release v0.7.0 runtime event log writer rejects JSONL payload newline for event \(eventID)"
        case let .duplicateEventID(eventID):
            "Release v0.7.0 runtime event log writer rejects duplicate eventID \(eventID)"
        case let .invalidEventLine(path, lineNumber):
            "Release v0.7.0 runtime event log writer cannot decode event line \(lineNumber) at \(path)"
        case let .eventChecksumMismatch(eventID, expected, actual):
            "Release v0.7.0 runtime event log writer event checksum mismatch for \(eventID), expected \(expected), actual \(actual)"
        case let .lineChecksumMismatch(eventID, expected, actual):
            "Release v0.7.0 runtime event log writer line checksum mismatch for \(eventID), expected \(expected), actual \(actual)"
        case let .previousLineChecksumMismatch(eventID, expected, actual):
            "Release v0.7.0 runtime event log writer previous line checksum mismatch for \(eventID), expected \(expected), actual \(actual)"
        case let .runIDMismatch(expected, actual):
            "Release v0.7.0 runtime event log writer runID mismatch, expected \(expected), actual \(actual)"
        case let .lockUnavailable(path):
            "Release v0.7.0 runtime event log writer cannot acquire local append lock at \(path)"
        }
    }
}

/// ReleaseV070RuntimeEventLogRecoveryAction 固定 GH-784 partial line recovery 的可审计动作。
public enum ReleaseV070RuntimeEventLogRecoveryAction: String, Codable, Equatable, Sendable {
    case noRecoveryNeeded
    case truncatedPartialLine
}

/// ReleaseV070RuntimeEventLogWritePolicy 固定 GH-784 本地 lock / fsync / recovery 策略。
///
/// Policy 只描述 local single-run JSONL append：使用 `.events.jsonl.lock` 目录作为
/// local writer lock，batch append 后执行 `synchronizeFile()`，并在追加前把 partial line
/// 截断到最后一个完整 newline。它不授权 distributed log、broker ingestion 或 production
/// persistence cutover。
public struct ReleaseV070RuntimeEventLogWritePolicy: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let lockPolicy: String
    public let fsyncPolicy: String
    public let partialLineRecoveryPolicy: String
    public let eventChecksumAlgorithm: String
    public let lineChecksumAlgorithm: String
    public let duplicateEventIDRejected: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var policyHeld: Bool {
        issueID.rawValue == "GH-784"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-756"]
            && releaseVersion == "v0.7.0"
            && lockPolicy == "local-lock-directory-per-run"
            && fsyncPolicy == "synchronize-file-after-each-batch"
            && partialLineRecoveryPolicy == "truncate-to-last-complete-newline-before-append"
            && eventChecksumAlgorithm == "sha256(payloadJSON)"
            && lineChecksumAlgorithm == "sha256(runID|sequence|eventID|previousLineChecksum|eventChecksum|payloadJSON|createdAt)"
            && duplicateEventIDRejected
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-784"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-756")],
        releaseVersion: String = "v0.7.0",
        lockPolicy: String = "local-lock-directory-per-run",
        fsyncPolicy: String = "synchronize-file-after-each-batch",
        partialLineRecoveryPolicy: String = "truncate-to-last-complete-newline-before-append",
        eventChecksumAlgorithm: String = "sha256(payloadJSON)",
        lineChecksumAlgorithm: String = "sha256(runID|sequence|eventID|previousLineChecksum|eventChecksum|payloadJSON|createdAt)",
        duplicateEventIDRejected: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.lockPolicy = lockPolicy
        self.fsyncPolicy = fsyncPolicy
        self.partialLineRecoveryPolicy = partialLineRecoveryPolicy
        self.eventChecksumAlgorithm = eventChecksumAlgorithm
        self.lineChecksumAlgorithm = lineChecksumAlgorithm
        self.duplicateEventIDRejected = duplicateEventIDRejected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard policyHeld else {
            throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                eventID: issueID.rawValue,
                expected: "GH-784 policy held",
                actual: "policy drift"
            )
        }
    }
}

/// ReleaseV070RuntimeEventLogEvent 是 GH-784 append batch 的输入事件。
public struct ReleaseV070RuntimeEventLogEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let payloadJSON: String

    public init(
        eventID: Identifier,
        payloadJSON: String
    ) throws {
        guard payloadJSON.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyPayload(eventID.rawValue)
        }
        guard payloadJSON.contains("\n") == false else {
            throw ReleaseV070RuntimeEventLogWriterError.payloadContainsNewline(eventID.rawValue)
        }
        self.eventID = eventID
        self.payloadJSON = payloadJSON
    }
}

/// ReleaseV070RuntimeEventLogRecord 是 GH-784 `events.jsonl` 的单行 runtime append record。
public struct ReleaseV070RuntimeEventLogRecord: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.runtime-event-log-record.v1"
    public static let genesisLineChecksum = "sha256:0000000000000000000000000000000000000000000000000000000000000000"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let sequence: Int
    public let eventID: Identifier
    public let payloadJSON: String
    public let eventChecksum: String
    public let previousLineChecksum: String
    public let lineChecksum: String
    public let createdAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case issueID
        case upstreamIssueIDs
        case releaseVersion
        case schemaVersion
        case runID
        case sequence
        case eventID
        case payloadJSON
        case eventChecksum
        case previousLineChecksum
        case lineChecksum
        case createdAt
        case productionTradingEnabledByDefault
        case productionSecretResolutionEnabled
        case productionEndpointConnectionEnabled
        case realOrderAuthorizationEnabled
        case productionCutoverAuthorized
    }

    public var recordHeld: Bool {
        let expectedEventChecksum = ReleaseV060LocalRunJournalWriter.sha256Hex(Data(payloadJSON.utf8))
        return issueID.rawValue == "GH-784"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-756"]
            && releaseVersion == "v0.7.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && sequence > 0
            && eventID.rawValue.isEmpty == false
            && payloadJSON.isEmpty == false
            && payloadJSON.contains("\n") == false
            && eventChecksum == expectedEventChecksum
            && lineChecksum == Self.computeLineChecksum(
                runID: runID,
                sequence: sequence,
                eventID: eventID,
                previousLineChecksum: previousLineChecksum,
                eventChecksum: eventChecksum,
                payloadJSON: payloadJSON,
                createdAt: createdAt
            )
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-784"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-756")],
        releaseVersion: String = "v0.7.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        sequence: Int,
        eventID: Identifier,
        payloadJSON: String,
        previousLineChecksum: String,
        createdAt: Date = Date(),
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyRunID
        }
        let event = try ReleaseV070RuntimeEventLogEvent(eventID: eventID, payloadJSON: payloadJSON)
        let eventChecksum = ReleaseV060LocalRunJournalWriter.sha256Hex(Data(event.payloadJSON.utf8))
        let lineChecksum = Self.computeLineChecksum(
            runID: runID,
            sequence: sequence,
            eventID: event.eventID,
            previousLineChecksum: previousLineChecksum,
            eventChecksum: eventChecksum,
            payloadJSON: event.payloadJSON,
            createdAt: createdAt
        )
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.sequence = sequence
        self.eventID = event.eventID
        self.payloadJSON = event.payloadJSON
        self.eventChecksum = eventChecksum
        self.previousLineChecksum = previousLineChecksum
        self.lineChecksum = lineChecksum
        self.createdAt = createdAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard recordHeld else {
            throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                eventID: eventID.rawValue,
                expected: lineChecksum,
                actual: "record held false"
            )
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        issueID = try container.decode(Identifier.self, forKey: .issueID)
        upstreamIssueIDs = try container.decode([Identifier].self, forKey: .upstreamIssueIDs)
        releaseVersion = try container.decode(String.self, forKey: .releaseVersion)
        schemaVersion = try container.decodeIfPresent(String.self, forKey: .schemaVersion) ?? Self.schemaVersion
        runID = try container.decode(Identifier.self, forKey: .runID)
        sequence = try container.decode(Int.self, forKey: .sequence)
        eventID = try container.decode(Identifier.self, forKey: .eventID)
        payloadJSON = try container.decode(String.self, forKey: .payloadJSON)
        eventChecksum = try container.decode(String.self, forKey: .eventChecksum)
        previousLineChecksum = try container.decode(String.self, forKey: .previousLineChecksum)
        lineChecksum = try container.decode(String.self, forKey: .lineChecksum)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        productionSecretResolutionEnabled = try container.decode(Bool.self, forKey: .productionSecretResolutionEnabled)
        productionEndpointConnectionEnabled = try container.decode(Bool.self, forKey: .productionEndpointConnectionEnabled)
        realOrderAuthorizationEnabled = try container.decode(Bool.self, forKey: .realOrderAuthorizationEnabled)
        productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
    }

    public static func computeLineChecksum(
        runID: Identifier,
        sequence: Int,
        eventID: Identifier,
        previousLineChecksum: String,
        eventChecksum: String,
        payloadJSON: String,
        createdAt: Date
    ) -> String {
        let input = [
            runID.rawValue,
            "\(sequence)",
            eventID.rawValue,
            previousLineChecksum,
            eventChecksum,
            payloadJSON,
            String(format: "%.6f", createdAt.timeIntervalSince1970)
        ].joined(separator: "|")
        return ReleaseV060LocalRunJournalWriter.sha256Hex(Data(input.utf8))
    }
}

/// ReleaseV070RuntimeEventLogAppendResult 汇总 GH-784 runtime batch append 结果。
public struct ReleaseV070RuntimeEventLogAppendResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let eventsJSONLPath: String
    public let appendedEventCount: Int
    public let totalEventCount: Int
    public let recoveryAction: ReleaseV070RuntimeEventLogRecoveryAction
    public let recoveredByteCount: Int
    public let lineChecksums: [String]
    public let eventChecksums: [String]
    public let writePolicy: ReleaseV070RuntimeEventLogWritePolicy

    public var appendHeld: Bool {
        issueID.rawValue == "GH-784"
            && runID.rawValue.isEmpty == false
            && eventsJSONLPath.hasSuffix("events.jsonl")
            && appendedEventCount > 0
            && totalEventCount >= appendedEventCount
            && recoveredByteCount >= 0
            && lineChecksums.count == totalEventCount
            && eventChecksums.count == totalEventCount
            && lineChecksums.allSatisfy { $0.hasPrefix("sha256:") }
            && eventChecksums.allSatisfy { $0.hasPrefix("sha256:") }
            && writePolicy.policyHeld
    }
}

/// ReleaseV070RuntimeEventLogValidation 是 GH-784 runtime event log 的校验结果。
public struct ReleaseV070RuntimeEventLogValidation: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let eventsJSONLPath: String
    public let eventCount: Int
    public let duplicateEventIDsRejected: Bool
    public let lineChecksumValidationPassed: Bool
    public let eventChecksumValidationPassed: Bool
    public let previousLineChecksumValidationPassed: Bool
    public let writePolicy: ReleaseV070RuntimeEventLogWritePolicy

    public var validationHeld: Bool {
        issueID.rawValue == "GH-784"
            && runID.rawValue.isEmpty == false
            && eventsJSONLPath.hasSuffix("events.jsonl")
            && eventCount > 0
            && duplicateEventIDsRejected
            && lineChecksumValidationPassed
            && eventChecksumValidationPassed
            && previousLineChecksumValidationPassed
            && writePolicy.policyHeld
    }
}

/// ReleaseV080RuntimeEventLogCrashRecoveryPolicy 固定 GH-812 的本地 crash recovery 加固合同。
///
/// Policy 在 GH-784 的 append-only JSONL writer 上补充 schema version、corrupted-line
/// quarantine 和 no-compaction 边界。它只描述本地 evidence 文件处理，不授权 endpoint、
/// broker、OMS production runtime 或订单能力。
public struct ReleaseV080RuntimeEventLogCrashRecoveryPolicy: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.event-log-writer-crash-recovery-policy.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let eventRecordSchemaVersion: String
    public let partialLineRecoveryPolicy: String
    public let corruptedLineQuarantinePolicy: String
    public let compactionPolicy: String
    public let duplicateRunIDRejected: Bool
    public let duplicateEventIDRejected: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var policyHeld: Bool {
        issueID.rawValue == "GH-812"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-784", "GH-811"]
            && releaseVersion == "v0.8.0"
            && schemaVersion == Self.schemaVersion
            && eventRecordSchemaVersion == ReleaseV070RuntimeEventLogRecord.schemaVersion
            && partialLineRecoveryPolicy == "truncate-partial-line-before-append"
            && corruptedLineQuarantinePolicy == "quarantine-complete-corrupted-lines-without-silent-loss"
            && compactionPolicy == "append-only-no-compaction-v0.8.0"
            && duplicateRunIDRejected
            && duplicateEventIDRejected
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-812"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-784"), Identifier.constant("GH-811")],
        releaseVersion: String = "v0.8.0",
        schemaVersion: String = Self.schemaVersion,
        eventRecordSchemaVersion: String = ReleaseV070RuntimeEventLogRecord.schemaVersion,
        partialLineRecoveryPolicy: String = "truncate-partial-line-before-append",
        corruptedLineQuarantinePolicy: String = "quarantine-complete-corrupted-lines-without-silent-loss",
        compactionPolicy: String = "append-only-no-compaction-v0.8.0",
        duplicateRunIDRejected: Bool = true,
        duplicateEventIDRejected: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.eventRecordSchemaVersion = eventRecordSchemaVersion
        self.partialLineRecoveryPolicy = partialLineRecoveryPolicy
        self.corruptedLineQuarantinePolicy = corruptedLineQuarantinePolicy
        self.compactionPolicy = compactionPolicy
        self.duplicateRunIDRejected = duplicateRunIDRejected
        self.duplicateEventIDRejected = duplicateEventIDRejected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard policyHeld else {
            throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                eventID: issueID.rawValue,
                expected: "GH-812 crash recovery policy held",
                actual: "policy drift"
            )
        }
    }
}

/// ReleaseV080RuntimeEventLogQuarantineLine 是 GH-812 `events.jsonl.quarantine` 的单行证据。
public struct ReleaseV080RuntimeEventLogQuarantineLine: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.event-log-writer-quarantine-line.v1"

    public let issueID: Identifier
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let originalLineNumber: Int
    public let originalLine: String
    public let quarantineReason: String
    public let quarantineChecksum: String

    public var lineHeld: Bool {
        issueID.rawValue == "GH-812"
            && releaseVersion == "v0.8.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && originalLineNumber > 0
            && originalLine.isEmpty == false
            && quarantineReason.isEmpty == false
            && quarantineChecksum == Self.stableQuarantineChecksum(
                runID: runID,
                originalLineNumber: originalLineNumber,
                originalLine: originalLine,
                quarantineReason: quarantineReason
            )
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-812"),
        releaseVersion: String = "v0.8.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        originalLineNumber: Int,
        originalLine: String,
        quarantineReason: String,
        quarantineChecksum: String? = nil
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.originalLineNumber = originalLineNumber
        self.originalLine = originalLine
        self.quarantineReason = quarantineReason
        self.quarantineChecksum = quarantineChecksum ?? Self.stableQuarantineChecksum(
            runID: runID,
            originalLineNumber: originalLineNumber,
            originalLine: originalLine,
            quarantineReason: quarantineReason
        )

        guard lineHeld else {
            throw ReleaseV070RuntimeEventLogWriterError.invalidEventLine(
                path: "events.jsonl.quarantine",
                lineNumber: originalLineNumber
            )
        }
    }

    public static func stableQuarantineChecksum(
        runID: Identifier,
        originalLineNumber: Int,
        originalLine: String,
        quarantineReason: String
    ) -> String {
        ReleaseV060LocalRunJournalWriter.sha256Hex(
            Data([
                "GH-812",
                "v0.8.0",
                Self.schemaVersion,
                runID.rawValue,
                String(originalLineNumber),
                originalLine,
                quarantineReason
            ].joined(separator: "|").utf8)
        )
    }
}

/// ReleaseV080RuntimeEventLogQuarantineResult 汇总 GH-812 corrupted-line quarantine 结果。
public struct ReleaseV080RuntimeEventLogQuarantineResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let eventsJSONLPath: String
    public let quarantineJSONLPath: String
    public let originalLineCount: Int
    public let retainedLineCount: Int
    public let quarantinedLineCount: Int
    public let quarantinedLineChecksums: [String]
    public let crashRecoveryPolicy: ReleaseV080RuntimeEventLogCrashRecoveryPolicy

    public var resultHeld: Bool {
        issueID.rawValue == "GH-812"
            && runID.rawValue.isEmpty == false
            && eventsJSONLPath.hasSuffix("events.jsonl")
            && quarantineJSONLPath.hasSuffix("events.jsonl.quarantine")
            && originalLineCount >= retainedLineCount
            && originalLineCount == retainedLineCount + quarantinedLineCount
            && quarantinedLineChecksums.count == quarantinedLineCount
            && quarantinedLineChecksums.allSatisfy { $0.hasPrefix("sha256:") }
            && crashRecoveryPolicy.policyHeld
    }
}

/// ReleaseV060LocalRunJournalWriter 将 GH-731 的 deterministic journal artifact 落到真实本地文件。
///
/// Writer 只写本地 filesystem。它不连接 Binance / production endpoint，不读取 secret，
/// 不调用 broker 或 ExecutionClient，不提交、取消或替换真实订单。
public struct ReleaseV060LocalRunJournalWriter {
    public static let statusFileName = "_RUN_STATUS.json"
    public static let manifestFileName = "manifest.json"
    public static let v0180LifecycleManifestFileName = "lifecycle-manifest-v0.18.0.json"

    private let storageRootURL: URL
    private let fileManager: FileManager

    public init(
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true),
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func writeCompletedRun(
        journal: ReleaseV050DurableLocalRunJournal,
        projectionJSON: String? = nil,
        summaryJSON: String? = nil
    ) throws -> ReleaseV060LocalRunJournalWriterResult {
        let runID = journal.paths.runID
        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        guard fileManager.fileExists(atPath: urls.manifestURL.path) == false else {
            throw ReleaseV060LocalRunJournalWriterError.completedRunRewriteRejected(urls.manifestURL.path)
        }
        guard try existingEventByteCount(at: urls.eventsURL) == 0 else {
            throw ReleaseV060LocalRunJournalWriterError.eventLogAlreadyContainsRecords(urls.eventsURL.path)
        }

        let artifact = try journal.artifact()
        try appendEventsJSONL(artifact.eventsJSONLLines, to: urls.eventsURL)
        try writeAtomicString(projectionJSON ?? artifact.projectionJSON, to: urls.projectionURL)
        try writeAtomicString(summaryJSON ?? artifact.summaryJSON, to: urls.summaryURL)

        let status = try ReleaseV060LocalRunJournalWriterStatus(
            runID: runID,
            state: .completed,
            eventCount: artifact.eventsJSONLLines.count,
            requiredArtifactsPresent: true,
            manifestPresent: true
        )
        try writeAtomicJSON(status, to: urls.statusURL)

        let artifacts = try artifactMetadata(
            urls: urls,
            createdAt: Date()
        )
        let manifest = try ReleaseV060LocalRunJournalWriterManifest(
            runID: runID,
            runDirectoryPath: urls.runDirectoryURL.path,
            artifacts: artifacts,
            eventCount: artifact.eventsJSONLLines.count
        )
        try writeAtomicJSON(manifest, to: urls.manifestURL)

        return ReleaseV060LocalRunJournalWriterResult(
            runDirectoryPath: urls.runDirectoryURL.path,
            eventsJSONLPath: urls.eventsURL.path,
            projectionJSONPath: urls.projectionURL.path,
            summaryJSONPath: urls.summaryURL.path,
            statusJSONPath: urls.statusURL.path,
            manifestJSONPath: urls.manifestURL.path,
            status: status,
            manifest: manifest
        )
    }

    @discardableResult
    public func writeFailedRun(
        runID: Identifier,
        reason: String
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        try writeTerminalStatus(runID: runID, state: .failed, reason: reason)
    }

    @discardableResult
    public func writeIncompleteRun(
        runID: Identifier,
        reason: String = "incomplete"
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        try writeTerminalStatus(runID: runID, state: .incomplete, reason: reason)
    }

    public func inspectRun(runID: Identifier) throws -> ReleaseV060LocalRunJournalWriterStatus {
        let urls = artifactURLs(runID: runID)
        let eventsPresent = fileManager.fileExists(atPath: urls.eventsURL.path)
        let projectionPresent = fileManager.fileExists(atPath: urls.projectionURL.path)
        let summaryPresent = fileManager.fileExists(atPath: urls.summaryURL.path)
        let statusPresent = fileManager.fileExists(atPath: urls.statusURL.path)
        let manifestPresent = fileManager.fileExists(atPath: urls.manifestURL.path)
        let requiredArtifactsPresent = eventsPresent
            && projectionPresent
            && summaryPresent
            && statusPresent
            && manifestPresent
        let eventCount = try countEventLines(at: urls.eventsURL)

        guard statusPresent else {
            return try ReleaseV060LocalRunJournalWriterStatus(
                runID: runID,
                state: .incomplete,
                eventCount: eventCount,
                requiredArtifactsPresent: requiredArtifactsPresent,
                manifestPresent: manifestPresent,
                failureReason: "missing _RUN_STATUS.json"
            )
        }

        let persistedStatus = try decodeJSON(ReleaseV060LocalRunJournalWriterStatus.self, from: urls.statusURL)
        if persistedStatus.state == .failed {
            return persistedStatus
        }
        guard requiredArtifactsPresent else {
            return try ReleaseV060LocalRunJournalWriterStatus(
                runID: runID,
                state: .incomplete,
                eventCount: eventCount,
                requiredArtifactsPresent: false,
                manifestPresent: manifestPresent,
                failureReason: "required artifacts incomplete"
            )
        }
        _ = try validateRunManifest(runID: runID)
        return persistedStatus
    }

    public func validateRunManifest(runID: Identifier) throws -> ReleaseV060LocalRunJournalManifestValidation {
        let urls = artifactURLs(runID: runID)
        guard fileManager.fileExists(atPath: urls.manifestURL.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(urls.manifestURL.path)
        }
        let manifest = try decodeJSON(ReleaseV060LocalRunJournalWriterManifest.self, from: urls.manifestURL)
        let requiredFileNames = [
            manifest.eventFileName,
            manifest.projectionFileName,
            manifest.summaryFileName,
            manifest.statusFileName
        ]
        let manifestFileNames = manifest.artifacts.filter(\.required)
            .map { URL(fileURLWithPath: $0.path).lastPathComponent }
        guard manifestFileNames == requiredFileNames else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "required artifact order \(manifestFileNames.joined(separator: ","))"
            )
        }
        for artifact in manifest.artifacts where artifact.required {
            try validateArtifactMetadata(artifact)
        }
        return try ReleaseV060LocalRunJournalManifestValidation(
            runID: runID,
            artifacts: manifest.artifacts
        )
    }

    @discardableResult
    public func writeVenueProductAwareLifecycleManifest(
        namespace: ReleaseV0180RunArtifactLifecycleNamespace
    ) throws -> ReleaseV0180RunArtifactLifecycleManifest {
        let urls = artifactURLs(runID: namespace.runID)
        let sourceValidation = try validateRunManifest(runID: namespace.runID)
        let manifest = try ReleaseV0180RunArtifactLifecycleManifest(
            namespace: namespace,
            runDirectoryPath: urls.runDirectoryURL.path,
            sourceRunManifestPath: urls.manifestURL.path,
            sourceValidation: sourceValidation
        )
        try writeAtomicJSON(manifest, to: urls.lifecycleManifestURL)
        return manifest
    }

    public func validateVenueProductAwareLifecycleManifest(
        expectedNamespace: ReleaseV0180RunArtifactLifecycleNamespace
    ) throws -> ReleaseV0180RunArtifactLifecycleManifestValidation {
        let urls = artifactURLs(runID: expectedNamespace.runID)
        guard fileManager.fileExists(atPath: urls.lifecycleManifestURL.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(urls.lifecycleManifestURL.path)
        }
        let manifest = try decodeJSON(
            ReleaseV0180RunArtifactLifecycleManifest.self,
            from: urls.lifecycleManifestURL
        )
        guard manifest.namespace == expectedNamespace else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "GH-1177 namespace mismatch expected \(expectedNamespace.namespaceKey) actual \(manifest.namespace.namespaceKey)"
            )
        }
        let sourceValidation = try validateRunManifest(runID: expectedNamespace.runID)
        return try ReleaseV0180RunArtifactLifecycleManifestValidation(
            expectedNamespace: expectedNamespace,
            manifest: manifest,
            sourceRunManifestValidation: sourceValidation
        )
    }

    @discardableResult
    public func appendRuntimeEvents(
        runID: Identifier,
        events: [ReleaseV070RuntimeEventLogEvent]
    ) throws -> ReleaseV070RuntimeEventLogAppendResult {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyRunID
        }
        guard events.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyAppendBatch
        }

        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        return try withRuntimeAppendLock(for: urls.runDirectoryURL) {
            let recovery = try recoverPartialEventLine(at: urls.eventsURL)
            let existingRecords = try decodeRuntimeEventLogRecords(runID: runID, from: urls.eventsURL)
            let existingEventIDs = Set(existingRecords.map(\.eventID.rawValue))
            let incomingEventIDs = events.map(\.eventID.rawValue)
            guard Set(incomingEventIDs).count == incomingEventIDs.count else {
                throw ReleaseV070RuntimeEventLogWriterError.duplicateEventID(
                    incomingEventIDs.first { id in incomingEventIDs.filter { $0 == id }.count > 1 } ?? "unknown"
                )
            }
            if let duplicate = incomingEventIDs.first(where: existingEventIDs.contains) {
                throw ReleaseV070RuntimeEventLogWriterError.duplicateEventID(duplicate)
            }

            var previousLineChecksum = existingRecords.last?.lineChecksum
                ?? ReleaseV070RuntimeEventLogRecord.genesisLineChecksum
            var appendedRecords: [ReleaseV070RuntimeEventLogRecord] = []
            for (offset, event) in events.enumerated() {
                let sequence = existingRecords.count + offset + 1
                let record = try ReleaseV070RuntimeEventLogRecord(
                    runID: runID,
                    sequence: sequence,
                    eventID: event.eventID,
                    payloadJSON: event.payloadJSON,
                    previousLineChecksum: previousLineChecksum,
                    createdAt: Date(timeIntervalSince1970: Double(sequence))
                )
                previousLineChecksum = record.lineChecksum
                appendedRecords.append(record)
            }

            try appendRuntimeRecordLines(appendedRecords, to: urls.eventsURL)
            let allRecords = existingRecords + appendedRecords
            try validateRuntimeRecords(allRecords, runID: runID, path: urls.eventsURL.path)
            let policy = try ReleaseV070RuntimeEventLogWritePolicy()
            let result = ReleaseV070RuntimeEventLogAppendResult(
                issueID: Identifier.constant("GH-784"),
                runID: runID,
                eventsJSONLPath: urls.eventsURL.path,
                appendedEventCount: appendedRecords.count,
                totalEventCount: allRecords.count,
                recoveryAction: recovery.action,
                recoveredByteCount: recovery.recoveredByteCount,
                lineChecksums: allRecords.map(\.lineChecksum),
                eventChecksums: allRecords.map(\.eventChecksum),
                writePolicy: policy
            )
            guard result.appendHeld else {
                throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                    eventID: runID.rawValue,
                    expected: "GH-784 append result held",
                    actual: "append result drift"
                )
            }
            return result
        }
    }

    public func validateRuntimeEventLog(
        runID: Identifier
    ) throws -> ReleaseV070RuntimeEventLogValidation {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyRunID
        }
        let urls = artifactURLs(runID: runID)
        let records = try decodeRuntimeEventLogRecords(runID: runID, from: urls.eventsURL)
        try validateRuntimeRecords(records, runID: runID, path: urls.eventsURL.path)
        let validation = ReleaseV070RuntimeEventLogValidation(
            issueID: Identifier.constant("GH-784"),
            runID: runID,
            eventsJSONLPath: urls.eventsURL.path,
            eventCount: records.count,
            duplicateEventIDsRejected: Set(records.map(\.eventID.rawValue)).count == records.count,
            lineChecksumValidationPassed: records.allSatisfy(\.recordHeld),
            eventChecksumValidationPassed: records.allSatisfy {
                $0.eventChecksum == Self.sha256Hex(Data($0.payloadJSON.utf8))
            },
            previousLineChecksumValidationPassed: records.enumerated().allSatisfy { index, record in
                let expected = index == 0
                    ? ReleaseV070RuntimeEventLogRecord.genesisLineChecksum
                    : records[index - 1].lineChecksum
                return record.previousLineChecksum == expected
            },
            writePolicy: try ReleaseV070RuntimeEventLogWritePolicy()
        )
        guard validation.validationHeld else {
            throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                eventID: runID.rawValue,
                expected: "GH-784 validation held",
                actual: "validation drift"
            )
        }
        return validation
    }

    @discardableResult
    public func quarantineCorruptedRuntimeEventLogLines(
        runID: Identifier
    ) throws -> ReleaseV080RuntimeEventLogQuarantineResult {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RuntimeEventLogWriterError.emptyRunID
        }
        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        return try withRuntimeAppendLock(for: urls.runDirectoryURL) {
            guard fileManager.fileExists(atPath: urls.eventsURL.path) else {
                let policy = try ReleaseV080RuntimeEventLogCrashRecoveryPolicy()
                return ReleaseV080RuntimeEventLogQuarantineResult(
                    issueID: Identifier.constant("GH-812"),
                    runID: runID,
                    eventsJSONLPath: urls.eventsURL.path,
                    quarantineJSONLPath: quarantineURL(for: urls.eventsURL).path,
                    originalLineCount: 0,
                    retainedLineCount: 0,
                    quarantinedLineCount: 0,
                    quarantinedLineChecksums: [],
                    crashRecoveryPolicy: policy
                )
            }

            let contents = try String(contentsOf: urls.eventsURL, encoding: .utf8)
            let lines = contents.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
            var retainedRecords: [ReleaseV070RuntimeEventLogRecord] = []
            var quarantineLines: [ReleaseV080RuntimeEventLogQuarantineLine] = []

            for (index, line) in lines.enumerated() {
                do {
                    let record = try Self.decodeRuntimeRecordLine(line)
                    try validateRuntimeRecords(retainedRecords + [record], runID: runID, path: urls.eventsURL.path)
                    retainedRecords.append(record)
                } catch {
                    let quarantineLine = try ReleaseV080RuntimeEventLogQuarantineLine(
                        runID: runID,
                        originalLineNumber: index + 1,
                        originalLine: line,
                        quarantineReason: "decode-or-checksum-chain-validation-failed"
                    )
                    quarantineLines.append(quarantineLine)
                }
            }

            try rewriteRuntimeRecordLines(retainedRecords, to: urls.eventsURL)
            if quarantineLines.isEmpty == false {
                try appendQuarantineLines(quarantineLines, to: quarantineURL(for: urls.eventsURL))
            }
            try validateRuntimeRecords(retainedRecords, runID: runID, path: urls.eventsURL.path)
            let policy = try ReleaseV080RuntimeEventLogCrashRecoveryPolicy()
            let result = ReleaseV080RuntimeEventLogQuarantineResult(
                issueID: Identifier.constant("GH-812"),
                runID: runID,
                eventsJSONLPath: urls.eventsURL.path,
                quarantineJSONLPath: quarantineURL(for: urls.eventsURL).path,
                originalLineCount: lines.count,
                retainedLineCount: retainedRecords.count,
                quarantinedLineCount: quarantineLines.count,
                quarantinedLineChecksums: quarantineLines.map(\.quarantineChecksum),
                crashRecoveryPolicy: policy
            )
            guard result.resultHeld else {
                throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                    eventID: runID.rawValue,
                    expected: "GH-812 quarantine result held",
                    actual: "quarantine result drift"
                )
            }
            return result
        }
    }

    private func writeTerminalStatus(
        runID: Identifier,
        state: ReleaseV060LocalRunJournalWriterState,
        reason: String
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        let status = try ReleaseV060LocalRunJournalWriterStatus(
            runID: runID,
            state: state,
            eventCount: try countEventLines(at: urls.eventsURL),
            requiredArtifactsPresent: false,
            manifestPresent: false,
            failureReason: reason
        )
        try writeAtomicJSON(status, to: urls.statusURL)
        return status
    }

    private func withRuntimeAppendLock<Result>(
        for runDirectoryURL: URL,
        _ operation: () throws -> Result
    ) throws -> Result {
        let lockURL = runDirectoryURL.appendingPathComponent(".events.jsonl.lock", isDirectory: true)
        do {
            try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
        } catch {
            throw ReleaseV070RuntimeEventLogWriterError.lockUnavailable(lockURL.path)
        }
        defer {
            try? fileManager.removeItem(at: lockURL)
        }
        return try operation()
    }

    private func recoverPartialEventLine(
        at url: URL
    ) throws -> (action: ReleaseV070RuntimeEventLogRecoveryAction, recoveredByteCount: Int) {
        guard fileManager.fileExists(atPath: url.path) else {
            return (.noRecoveryNeeded, 0)
        }
        let data = try Data(contentsOf: url)
        guard data.isEmpty == false else {
            return (.noRecoveryNeeded, 0)
        }
        guard data.last != 0x0A else {
            return (.noRecoveryNeeded, 0)
        }

        let truncateOffset: UInt64
        if let lastNewlineIndex = data.lastIndex(of: 0x0A) {
            truncateOffset = UInt64(data.distance(from: data.startIndex, to: lastNewlineIndex) + 1)
        } else {
            truncateOffset = 0
        }
        let recoveredByteCount = data.count - Int(truncateOffset)
        let handle = try FileHandle(forUpdating: url)
        defer {
            try? handle.close()
        }
        try handle.truncate(atOffset: truncateOffset)
        handle.synchronizeFile()
        return (.truncatedPartialLine, recoveredByteCount)
    }

    private func appendRuntimeRecordLines(
        _ records: [ReleaseV070RuntimeEventLogRecord],
        to url: URL
    ) throws {
        if fileManager.fileExists(atPath: url.path) == false {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer {
            try? handle.close()
        }
        try handle.seekToEnd()
        for record in records {
            try handle.write(contentsOf: Data((Self.encodeRuntimeRecordLine(record) + "\n").utf8))
        }
        handle.synchronizeFile()
    }

    private func rewriteRuntimeRecordLines(
        _ records: [ReleaseV070RuntimeEventLogRecord],
        to url: URL
    ) throws {
        if fileManager.fileExists(atPath: url.path) == false {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer {
            try? handle.close()
        }
        try handle.truncate(atOffset: 0)
        for record in records {
            try handle.write(contentsOf: Data((Self.encodeRuntimeRecordLine(record) + "\n").utf8))
        }
        handle.synchronizeFile()
    }

    private func appendQuarantineLines(
        _ lines: [ReleaseV080RuntimeEventLogQuarantineLine],
        to url: URL
    ) throws {
        if fileManager.fileExists(atPath: url.path) == false {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer {
            try? handle.close()
        }
        try handle.seekToEnd()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        for line in lines {
            try handle.write(contentsOf: encoder.encode(line))
            try handle.write(contentsOf: Data("\n".utf8))
        }
        handle.synchronizeFile()
    }

    private func decodeRuntimeEventLogRecords(
        runID: Identifier,
        from url: URL
    ) throws -> [ReleaseV070RuntimeEventLogRecord] {
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        let contents = try String(contentsOf: url, encoding: .utf8)
        let lines = contents.split(separator: "\n", omittingEmptySubsequences: true)
        let records = try lines.enumerated().map { index, line -> ReleaseV070RuntimeEventLogRecord in
            do {
                return try Self.decodeRuntimeRecordLine(String(line))
            } catch {
                throw ReleaseV070RuntimeEventLogWriterError.invalidEventLine(
                    path: url.path,
                    lineNumber: index + 1
                )
            }
        }
        try validateRuntimeRecords(records, runID: runID, path: url.path)
        return records
    }

    private func validateRuntimeRecords(
        _ records: [ReleaseV070RuntimeEventLogRecord],
        runID: Identifier,
        path: String
    ) throws {
        var eventIDs = Set<String>()
        for (index, record) in records.enumerated() {
            guard record.runID == runID else {
                throw ReleaseV070RuntimeEventLogWriterError.runIDMismatch(
                    expected: runID.rawValue,
                    actual: record.runID.rawValue
                )
            }
            guard eventIDs.insert(record.eventID.rawValue).inserted else {
                throw ReleaseV070RuntimeEventLogWriterError.duplicateEventID(record.eventID.rawValue)
            }
            guard record.sequence == index + 1 else {
                throw ReleaseV070RuntimeEventLogWriterError.invalidEventLine(
                    path: path,
                    lineNumber: index + 1
                )
            }
            let expectedPreviousLineChecksum = index == 0
                ? ReleaseV070RuntimeEventLogRecord.genesisLineChecksum
                : records[index - 1].lineChecksum
            guard record.previousLineChecksum == expectedPreviousLineChecksum else {
                throw ReleaseV070RuntimeEventLogWriterError.previousLineChecksumMismatch(
                    eventID: record.eventID.rawValue,
                    expected: expectedPreviousLineChecksum,
                    actual: record.previousLineChecksum
                )
            }
            let expectedEventChecksum = Self.sha256Hex(Data(record.payloadJSON.utf8))
            guard record.eventChecksum == expectedEventChecksum else {
                throw ReleaseV070RuntimeEventLogWriterError.eventChecksumMismatch(
                    eventID: record.eventID.rawValue,
                    expected: expectedEventChecksum,
                    actual: record.eventChecksum
                )
            }
            let expectedLineChecksum = ReleaseV070RuntimeEventLogRecord.computeLineChecksum(
                runID: record.runID,
                sequence: record.sequence,
                eventID: record.eventID,
                previousLineChecksum: record.previousLineChecksum,
                eventChecksum: record.eventChecksum,
                payloadJSON: record.payloadJSON,
                createdAt: record.createdAt
            )
            guard record.lineChecksum == expectedLineChecksum else {
                throw ReleaseV070RuntimeEventLogWriterError.lineChecksumMismatch(
                    eventID: record.eventID.rawValue,
                    expected: expectedLineChecksum,
                    actual: record.lineChecksum
                )
            }
            guard record.recordHeld else {
                throw ReleaseV070RuntimeEventLogWriterError.invalidEventLine(
                    path: path,
                    lineNumber: index + 1
                )
            }
        }
    }

    private static func encodeRuntimeRecordLine(
        _ record: ReleaseV070RuntimeEventLogRecord
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return String(decoding: try encoder.encode(record), as: UTF8.self)
    }

    private static func decodeRuntimeRecordLine(
        _ line: String
    ) throws -> ReleaseV070RuntimeEventLogRecord {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ReleaseV070RuntimeEventLogRecord.self, from: Data(line.utf8))
    }

    private func quarantineURL(for eventsURL: URL) -> URL {
        eventsURL.deletingLastPathComponent().appendingPathComponent("events.jsonl.quarantine")
    }

    private func ensureWritableRunDirectory(_ url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func appendEventsJSONL(_ lines: [String], to url: URL) throws {
        if fileManager.fileExists(atPath: url.path) == false {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer {
            try? handle.close()
        }
        try handle.seekToEnd()
        for line in lines {
            try handle.write(contentsOf: Data((line + "\n").utf8))
        }
    }

    private func writeAtomicJSON<Value: Encodable>(_ value: Value, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private func writeAtomicString(_ value: String, to url: URL) throws {
        try Data(value.utf8).write(to: url, options: .atomic)
    }

    private func artifactMetadata(
        urls: ArtifactURLs,
        createdAt: Date
    ) throws -> [ReleaseV060LocalRunJournalArtifactMetadata] {
        try [
            metadata(for: urls.eventsURL, createdAt: createdAt),
            metadata(for: urls.projectionURL, createdAt: createdAt),
            metadata(for: urls.summaryURL, createdAt: createdAt),
            metadata(for: urls.statusURL, createdAt: createdAt)
        ]
    }

    private func metadata(
        for url: URL,
        createdAt: Date
    ) throws -> ReleaseV060LocalRunJournalArtifactMetadata {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(url.path)
        }
        let data = try Data(contentsOf: url)
        return try ReleaseV060LocalRunJournalArtifactMetadata(
            path: url.path,
            sha256: Self.sha256Hex(data),
            bytes: data.count,
            createdAt: createdAt,
            required: true
        )
    }

    private func validateArtifactMetadata(
        _ artifact: ReleaseV060LocalRunJournalArtifactMetadata
    ) throws {
        guard fileManager.fileExists(atPath: artifact.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(artifact.path)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: artifact.path))
        guard data.count == artifact.bytes else {
            throw ReleaseV060LocalRunJournalWriterError.byteCountMismatch(
                path: artifact.path,
                expected: artifact.bytes,
                actual: data.count
            )
        }
        let actualChecksum = Self.sha256Hex(data)
        guard actualChecksum == artifact.sha256 else {
            throw ReleaseV060LocalRunJournalWriterError.checksumMismatch(
                path: artifact.path,
                expected: artifact.sha256,
                actual: actualChecksum
            )
        }
    }

    public static func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    private func decodeJSON<Value: Decodable>(_ type: Value.Type, from url: URL) throws -> Value {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV060LocalRunJournalWriterError.invalidStatusPayload(url.path)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: url))
    }

    private func existingEventByteCount(at url: URL) throws -> UInt64 {
        guard fileManager.fileExists(atPath: url.path) else {
            return 0
        }
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? UInt64 ?? 0
    }

    private func countEventLines(at url: URL) throws -> Int {
        guard fileManager.fileExists(atPath: url.path) else {
            return 0
        }
        let contents = try String(contentsOf: url, encoding: .utf8)
        return contents.split(separator: "\n", omittingEmptySubsequences: true).count
    }

    private func artifactURLs(runID: Identifier) -> ArtifactURLs {
        let runDirectoryURL = storageRootURL.appendingPathComponent(runID.rawValue, isDirectory: true)
        return ArtifactURLs(
            runDirectoryURL: runDirectoryURL,
            eventsURL: runDirectoryURL.appendingPathComponent("events.jsonl"),
            projectionURL: runDirectoryURL.appendingPathComponent("projection.json"),
            summaryURL: runDirectoryURL.appendingPathComponent("summary.json"),
            statusURL: runDirectoryURL.appendingPathComponent(Self.statusFileName),
            manifestURL: runDirectoryURL.appendingPathComponent(Self.manifestFileName),
            lifecycleManifestURL: runDirectoryURL.appendingPathComponent(Self.v0180LifecycleManifestFileName)
        )
    }

    private struct ArtifactURLs {
        let runDirectoryURL: URL
        let eventsURL: URL
        let projectionURL: URL
        let summaryURL: URL
        let statusURL: URL
        let manifestURL: URL
        let lifecycleManifestURL: URL
    }
}
