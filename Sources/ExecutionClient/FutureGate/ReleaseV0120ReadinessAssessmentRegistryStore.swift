import Crypto
import DomainModel
import Foundation

/// ReadinessAssessmentRegistryStoreAnchors 固定 GH-954 的源码级验证锚点。
///
/// 这些锚点只证明 v0.12.0 readiness assessment history 可以在本地 registry 中被
/// 创建、列出、检查、归档、恢复和标记为 compare-ready；它们不授权 production cutover、
/// secret read、endpoint / broker connection 或任何订单命令。
public enum ReadinessAssessmentRegistryStoreAnchors {
    public static let validationAnchors = [
        "GH-954-VERIFY-V0120-READINESS-ASSESSMENT-REGISTRY-STORE",
        "TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE",
        "V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE",
        "V0120-003-REGISTRY-JSON-PATH",
        "V0120-003-ASSESSMENT-DIRECTORY-PATH",
        "V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER",
        "V0120-003-COMPARE-READY-METADATA",
        "V0120-003-NO-PRODUCTION-CUTOVER",
        "GH-955-VERIFY-V0120-ASSESSMENT-TRANSACTION-LOCK",
        "TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK",
        "V0120-004-ASSESSMENT-TRANSACTION-LOCK",
        "V0120-004-TRANSACTION-ID-GENERATION-ID",
        "V0120-004-STAGING-DIRECTORY-COMMIT-MARKER",
        "V0120-004-COMPARE-AND-SWAP-MANIFEST",
        "V0120-004-CRASH-RECOVERY-SEMANTICS",
        "V0120-004-NO-PRODUCTION-CUTOVER",
        "GH-956-VERIFY-V0120-READINESS-MANIFEST-V2",
        "TVM-RELEASE-V0120-READINESS-MANIFEST-V2",
        "V0120-005-READINESS-MANIFEST-V2",
        "V0120-005-ASSESSMENT-GENERATION-PROVENANCE",
        "V0120-005-SOURCE-RUN-COMMIT-PROVENANCE",
        "V0120-005-CANONICAL-ARTIFACT-METADATA",
        "V0120-005-PRODUCER-VERSION-SCHEMA",
        "V0120-005-NO-PRODUCTION-CUTOVER",
        "GH-957-VERIFY-V0120-ARTIFACT-CONTENT-POLICY-REDACTION",
        "TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION",
        "V0120-006-ARTIFACT-CONTENT-POLICY",
        "V0120-006-JSON-SCHEMA-ALLOWLIST",
        "V0120-006-FORBIDDEN-FIELD-REJECTION",
        "V0120-006-RAW-SECRET-LISTENKEY-REJECTION",
        "V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION",
        "V0120-006-CONTENT-VALIDATION-CHECKSUM",
        "V0120-006-NO-PRODUCTION-CUTOVER",
        "GH-958-VERIFY-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT",
        "TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT",
        "V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT",
        "V0120-007-READINESS-BUNDLE-V2-JSON",
        "V0120-007-READINESS-BUNDLE-V2-MANIFEST-JSON",
        "V0120-007-REVIEW-SNAPSHOT-IMMUTABLE",
        "V0120-007-NEW-GENERATION-ON-CHANGE",
        "V0120-007-BUNDLE-MANIFEST-CHECKSUM",
        "V0120-007-NO-PRODUCTION-CUTOVER",
        "GH-962-VERIFY-V0120-READINESS-ASSESSMENT-DIFF-COMPARE",
        "TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE",
        "V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE",
        "V0120-011-POLICY-ARTIFACT-RISK-KILL-APPROVAL-SECTIONS",
        "V0120-011-SOURCE-RUN-EVIDENCE-COMPARISON",
        "V0120-011-NON-MUTATING-COMPARE",
        "V0120-011-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReadinessAssessmentRegistryStoreError 描述 GH-954 本地 registry store 的失败类型。
///
/// 错误只覆盖 `.local/mtpro/readiness/registry.json`、assessmentID、metadata state、
/// checksum 和本地 lock 语义；它不会表达 endpoint、secret、broker、OMS 或订单能力。
public enum ReadinessAssessmentRegistryStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyAssessmentID
    case unsafeAssessmentID(String)
    case duplicateAssessmentID(String)
    case missingAssessmentID(String)
    case missingRegistry(String)
    case corruptedRegistry(String)
    case checksumMismatch(expected: String, actual: String)
    case cannotMutateArchivedAssessment(String)
    case lockUnavailable(String)
    case transactionAlreadyExists(String)
    case generationMismatch(expected: String, actual: String)
    case concurrentModification(expected: String, actual: String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyAssessmentID:
            "GH-954 ReadinessAssessmentRegistryStore requires a non-empty assessmentID"
        case let .unsafeAssessmentID(assessmentID):
            "GH-954 ReadinessAssessmentRegistryStore rejects unsafe assessmentID \(assessmentID)"
        case let .duplicateAssessmentID(assessmentID):
            "GH-954 ReadinessAssessmentRegistryStore rejects duplicate assessmentID \(assessmentID)"
        case let .missingAssessmentID(assessmentID):
            "GH-954 ReadinessAssessmentRegistryStore cannot find assessmentID \(assessmentID)"
        case let .missingRegistry(path):
            "GH-954 ReadinessAssessmentRegistryStore fails closed because registry is missing at \(path)"
        case let .corruptedRegistry(path):
            "GH-954 ReadinessAssessmentRegistryStore fails closed because registry is corrupted at \(path)"
        case let .checksumMismatch(expected, actual):
            "GH-954 ReadinessAssessmentRegistryStore checksum mismatch: expected \(expected), actual \(actual)"
        case let .cannotMutateArchivedAssessment(assessmentID):
            "GH-954 ReadinessAssessmentRegistryStore rejects archived assessment mutation for \(assessmentID)"
        case let .lockUnavailable(path):
            "GH-954 ReadinessAssessmentRegistryStore lock is unavailable at \(path)"
        case let .transactionAlreadyExists(transactionID):
            "GH-955 ReadinessAssessmentRegistryStore transaction already exists: \(transactionID)"
        case let .generationMismatch(expected, actual):
            "GH-955 ReadinessAssessmentRegistryStore generation mismatch: expected \(expected), actual \(actual)"
        case let .concurrentModification(expected, actual):
            "GH-955 ReadinessAssessmentRegistryStore concurrent modification: expected \(expected), actual \(actual)"
        case let .boundaryDrift(field):
            "GH-954 ReadinessAssessmentRegistryStore boundary drift: \(field)"
        }
    }
}

/// ReadinessAssessmentRegistryState 固定 v0.12.0 assessment metadata state。
///
/// `ready` 和 `compare-ready` 都只表示本地 evidence 足以进入后续比较或审计，
/// 不能被解释成 production cutover、broker session 或 order authorization。
public enum ReadinessAssessmentRegistryState: String, Codable, CaseIterable, Equatable, Sendable {
    case baseline
    case followUp = "follow-up"
    case ready
    case compareReady = "compare-ready"
    case blocked
    case incomplete
    case invalid
    case stale
    case superseded
    case archived
    case recovered
}

/// ReadinessAssessmentRegistryLifecycle 固定 registry entry 的本地 lifecycle。
public enum ReadinessAssessmentRegistryLifecycle: String, Codable, CaseIterable, Equatable, Sendable {
    case active
    case archived
    case recoveryEvidence = "recovery-evidence"
}

/// ReadinessAssessmentRegistryArtifactPaths 是 assessment entry 保存的本地路径清单。
///
/// 路径只允许指向 `.local/mtpro/readiness/assessments/<assessmentID>/...` 下的本地
/// metadata / provenance / comparison / export evidence，不能保存 secret value、
/// listenKey、endpoint token、broker payload 或 order request payload。
public struct ReadinessAssessmentRegistryArtifactPaths: Codable, Equatable, Sendable {
    public let assessmentDirectoryPath: String
    public let metadataJSONPath: String
    public let provenanceSummaryJSONPath: String
    public let comparisonMetadataJSONPath: String
    public let redactedExportDirectoryPath: String

    public var pathsHeld: Bool {
        assessmentDirectoryPath.hasPrefix(".local/mtpro/readiness/assessments/")
            && metadataJSONPath == "\(assessmentDirectoryPath)/metadata.json"
            && provenanceSummaryJSONPath == "\(assessmentDirectoryPath)/provenance-summary.json"
            && comparisonMetadataJSONPath == "\(assessmentDirectoryPath)/comparison-metadata.json"
            && redactedExportDirectoryPath == "\(assessmentDirectoryPath)/redacted-export"
    }

    public init(assessmentID: Identifier) throws {
        try Self.validateAssessmentID(assessmentID)
        let directoryPath = ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)"
        self.assessmentDirectoryPath = directoryPath
        self.metadataJSONPath = "\(directoryPath)/metadata.json"
        self.provenanceSummaryJSONPath = "\(directoryPath)/provenance-summary.json"
        self.comparisonMetadataJSONPath = "\(directoryPath)/comparison-metadata.json"
        self.redactedExportDirectoryPath = "\(directoryPath)/redacted-export"

        guard pathsHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactPaths")
        }
    }

    public static func validateAssessmentID(_ assessmentID: Identifier) throws {
        guard assessmentID.rawValue.isEmpty == false else {
            throw ReadinessAssessmentRegistryStoreError.emptyAssessmentID
        }
        guard isSafePathComponent(assessmentID.rawValue) else {
            throw ReadinessAssessmentRegistryStoreError.unsafeAssessmentID(assessmentID.rawValue)
        }
    }

    private static func isSafePathComponent(_ value: String) -> Bool {
        value.isEmpty == false
            && value != "."
            && value != ".."
            && value.hasPrefix("~") == false
            && value.contains("/") == false
            && value.contains("\\") == false
    }
}

/// ReadinessAssessmentRegistryEntry 是 GH-954 `registry.json` 的单条 assessment metadata。
///
/// Entry 记录 assessmentID、metadata state、artifact paths、source release / patch、
/// lifecycle、timestamps 和 checksum。所有 production / broker / order 授权字段必须保持 false。
public struct ReadinessAssessmentRegistryEntry: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let state: ReadinessAssessmentRegistryState
    public let lifecycle: ReadinessAssessmentRegistryLifecycle
    public let artifactPaths: ReadinessAssessmentRegistryArtifactPaths
    public let sourceReleaseVersion: String
    public let sourcePatchVersion: String?
    public let comparisonBaseAssessmentID: Identifier?
    public let assessedBy: String
    public let reason: String
    public let createdAt: Date
    public let updatedAt: Date
    public let failureReason: String?
    public let recoveryReason: String?
    public let entryChecksum: String
    public let assessmentSessionLocalOnly: Bool
    public let assessmentSessionMayRecordHistory: Bool
    public let assessmentSessionMayComparePreviousAssessments: Bool
    public let assessmentSessionMayExportRedactedEvidence: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var entryHeld: Bool {
        issueID.rawValue == "GH-954"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-952", "GH-953"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && artifactPaths.pathsHeld
            && sourceReleaseVersion.isEmpty == false
            && assessedBy.isEmpty == false
            && reason.isEmpty == false
            && createdAt <= updatedAt
            && lifecycleStateHeld
            && compareReadyMetadataHeld
            && entryChecksum == Self.stableEntryChecksum(
                assessmentID: assessmentID,
                state: state,
                lifecycle: lifecycle,
                artifactPaths: artifactPaths,
                sourceReleaseVersion: sourceReleaseVersion,
                sourcePatchVersion: sourcePatchVersion,
                comparisonBaseAssessmentID: comparisonBaseAssessmentID,
                assessedBy: assessedBy,
                reason: reason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                failureReason: failureReason,
                recoveryReason: recoveryReason
            )
            && assessmentSessionLocalOnly
            && assessmentSessionMayRecordHistory
            && assessmentSessionMayComparePreviousAssessments
            && assessmentSessionMayExportRedactedEvidence
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public var compareReadyMetadataHeld: Bool {
        switch state {
        case .compareReady:
            comparisonBaseAssessmentID != nil
                && comparisonBaseAssessmentID?.rawValue != assessmentID.rawValue
        case .baseline, .followUp, .ready, .blocked, .incomplete, .invalid, .stale, .superseded, .archived, .recovered:
            true
        }
    }

    private var lifecycleStateHeld: Bool {
        switch lifecycle {
        case .active:
            state != .archived && state != .recovered
        case .archived:
            state == .archived
        case .recoveryEvidence:
            state == .recovered
        }
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-954"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-952"), Identifier.constant("GH-953")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        state: ReadinessAssessmentRegistryState,
        lifecycle: ReadinessAssessmentRegistryLifecycle = .active,
        artifactPaths: ReadinessAssessmentRegistryArtifactPaths? = nil,
        sourceReleaseVersion: String,
        sourcePatchVersion: String? = nil,
        comparisonBaseAssessmentID: Identifier? = nil,
        assessedBy: String,
        reason: String,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String? = nil,
        recoveryReason: String? = nil,
        entryChecksum: String? = nil,
        assessmentSessionLocalOnly: Bool = true,
        assessmentSessionMayRecordHistory: Bool = true,
        assessmentSessionMayComparePreviousAssessments: Bool = true,
        assessmentSessionMayExportRedactedEvidence: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        let resolvedPaths = try artifactPaths ?? ReadinessAssessmentRegistryArtifactPaths(assessmentID: assessmentID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.state = state
        self.lifecycle = lifecycle
        self.artifactPaths = resolvedPaths
        self.sourceReleaseVersion = sourceReleaseVersion
        self.sourcePatchVersion = sourcePatchVersion
        self.comparisonBaseAssessmentID = comparisonBaseAssessmentID
        self.assessedBy = assessedBy
        self.reason = reason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.failureReason = failureReason
        self.recoveryReason = recoveryReason
        self.entryChecksum = entryChecksum ?? Self.stableEntryChecksum(
            assessmentID: assessmentID,
            state: state,
            lifecycle: lifecycle,
            artifactPaths: resolvedPaths,
            sourceReleaseVersion: sourceReleaseVersion,
            sourcePatchVersion: sourcePatchVersion,
            comparisonBaseAssessmentID: comparisonBaseAssessmentID,
            assessedBy: assessedBy,
            reason: reason,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.assessmentSessionMayRecordHistory = assessmentSessionMayRecordHistory
        self.assessmentSessionMayComparePreviousAssessments = assessmentSessionMayComparePreviousAssessments
        self.assessmentSessionMayExportRedactedEvidence = assessmentSessionMayExportRedactedEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard entryHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("registryEntry")
        }
    }

    public func archived(at updatedAt: Date) throws -> ReadinessAssessmentRegistryEntry {
        try ReadinessAssessmentRegistryEntry(
            assessmentID: assessmentID,
            state: .archived,
            lifecycle: .archived,
            artifactPaths: artifactPaths,
            sourceReleaseVersion: sourceReleaseVersion,
            sourcePatchVersion: sourcePatchVersion,
            comparisonBaseAssessmentID: comparisonBaseAssessmentID,
            assessedBy: assessedBy,
            reason: reason,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
    }

    public func recovered(reason recoveryReason: String, at updatedAt: Date) throws -> ReadinessAssessmentRegistryEntry {
        try ReadinessAssessmentRegistryEntry(
            assessmentID: assessmentID,
            state: .recovered,
            lifecycle: .recoveryEvidence,
            artifactPaths: artifactPaths,
            sourceReleaseVersion: sourceReleaseVersion,
            sourcePatchVersion: sourcePatchVersion,
            comparisonBaseAssessmentID: comparisonBaseAssessmentID,
            assessedBy: assessedBy,
            reason: reason,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
    }

    public static func stableEntryChecksum(
        assessmentID: Identifier,
        state: ReadinessAssessmentRegistryState,
        lifecycle: ReadinessAssessmentRegistryLifecycle,
        artifactPaths: ReadinessAssessmentRegistryArtifactPaths,
        sourceReleaseVersion: String,
        sourcePatchVersion: String?,
        comparisonBaseAssessmentID: Identifier?,
        assessedBy: String,
        reason: String,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String?,
        recoveryReason: String?
    ) -> String {
        stableSHA256([
            "GH-954",
            "v0.12.0",
            assessmentID.rawValue,
            state.rawValue,
            lifecycle.rawValue,
            artifactPaths.assessmentDirectoryPath,
            artifactPaths.metadataJSONPath,
            artifactPaths.provenanceSummaryJSONPath,
            artifactPaths.comparisonMetadataJSONPath,
            artifactPaths.redactedExportDirectoryPath,
            sourceReleaseVersion,
            sourcePatchVersion ?? "",
            comparisonBaseAssessmentID?.rawValue ?? "",
            assessedBy,
            reason,
            String(createdAt.timeIntervalSince1970),
            String(updatedAt.timeIntervalSince1970),
            failureReason ?? "",
            recoveryReason ?? "",
            "assessmentSessionLocalOnly=true",
            "assessmentSessionMayRecordHistory=true",
            "assessmentSessionMayComparePreviousAssessments=true",
            "assessmentSessionMayExportRedactedEvidence=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentRegistryDocument 是 `.local/mtpro/readiness/registry.json` 的顶层 payload。
public struct ReadinessAssessmentRegistryDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.12.0.readiness-assessment-registry.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let registryPath: String
    public let assessmentsRootPath: String
    public let lockPath: String
    public let entries: [ReadinessAssessmentRegistryEntry]
    public let createdAt: Date
    public let updatedAt: Date
    public let registryChecksum: String
    public let missingOrCorruptedRegistryFailsClosed: Bool
    public let assessmentSessionLocalOnly: Bool
    public let assessmentSessionMayRecordHistory: Bool
    public let assessmentSessionMayComparePreviousAssessments: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var documentHeld: Bool {
        issueID.rawValue == "GH-954"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-952", "GH-953"]
            && releaseVersion == "v0.12.0"
            && schemaVersion == Self.schemaVersion
            && registryPath == ".local/mtpro/readiness/registry.json"
            && assessmentsRootPath == ".local/mtpro/readiness/assessments"
            && lockPath == ".local/mtpro/readiness/registry.lock"
            && entries.allSatisfy(\.entryHeld)
            && Set(entries.map(\.assessmentID.rawValue)).count == entries.count
            && entries.map(\.assessmentID.rawValue) == entries.map(\.assessmentID.rawValue).sorted()
            && createdAt <= updatedAt
            && registryChecksum == Self.stableRegistryChecksum(
                entries: entries,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            && missingOrCorruptedRegistryFailsClosed
            && assessmentSessionLocalOnly
            && assessmentSessionMayRecordHistory
            && assessmentSessionMayComparePreviousAssessments
            && productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-954"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-952"), Identifier.constant("GH-953")],
        releaseVersion: String = "v0.12.0",
        schemaVersion: String = Self.schemaVersion,
        registryPath: String = ".local/mtpro/readiness/registry.json",
        assessmentsRootPath: String = ".local/mtpro/readiness/assessments",
        lockPath: String = ".local/mtpro/readiness/registry.lock",
        entries: [ReadinessAssessmentRegistryEntry],
        createdAt: Date,
        updatedAt: Date,
        registryChecksum: String? = nil,
        missingOrCorruptedRegistryFailsClosed: Bool = true,
        assessmentSessionLocalOnly: Bool = true,
        assessmentSessionMayRecordHistory: Bool = true,
        assessmentSessionMayComparePreviousAssessments: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        let sortedEntries = entries.sorted { $0.assessmentID.rawValue < $1.assessmentID.rawValue }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.registryPath = registryPath
        self.assessmentsRootPath = assessmentsRootPath
        self.lockPath = lockPath
        self.entries = sortedEntries
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.registryChecksum = registryChecksum ?? Self.stableRegistryChecksum(
            entries: sortedEntries,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        self.missingOrCorruptedRegistryFailsClosed = missingOrCorruptedRegistryFailsClosed
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.assessmentSessionMayRecordHistory = assessmentSessionMayRecordHistory
        self.assessmentSessionMayComparePreviousAssessments = assessmentSessionMayComparePreviousAssessments
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        try Self.validateEntries(sortedEntries)
        guard documentHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("registryDocument")
        }
    }

    public func appending(
        entry: ReadinessAssessmentRegistryEntry,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryDocument {
        guard entries.contains(where: { $0.assessmentID == entry.assessmentID }) == false else {
            throw ReadinessAssessmentRegistryStoreError.duplicateAssessmentID(entry.assessmentID.rawValue)
        }
        return try ReadinessAssessmentRegistryDocument(
            entries: entries + [entry],
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    public func replacing(
        entry: ReadinessAssessmentRegistryEntry,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryDocument {
        var nextEntries = entries
        guard let index = nextEntries.firstIndex(where: { $0.assessmentID == entry.assessmentID }) else {
            throw ReadinessAssessmentRegistryStoreError.missingAssessmentID(entry.assessmentID.rawValue)
        }
        nextEntries[index] = entry
        return try ReadinessAssessmentRegistryDocument(
            entries: nextEntries,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    public func listAssessments() -> [ReadinessAssessmentRegistryEntry] {
        entries
    }

    public func inspect(assessmentID: Identifier) throws -> ReadinessAssessmentRegistryEntry {
        guard let entry = entries.first(where: { $0.assessmentID == assessmentID }) else {
            throw ReadinessAssessmentRegistryStoreError.missingAssessmentID(assessmentID.rawValue)
        }
        return entry
    }

    public func compareReadyAssessments() -> [ReadinessAssessmentRegistryEntry] {
        entries.filter { entry in
            entry.state == .compareReady && entry.lifecycle == .active && entry.compareReadyMetadataHeld
        }
    }

    public static func stableRegistryChecksum(
        entries: [ReadinessAssessmentRegistryEntry],
        createdAt: Date,
        updatedAt: Date
    ) -> String {
        stableSHA256([
            "GH-954",
            "v0.12.0",
            Self.schemaVersion,
            ".local/mtpro/readiness/registry.json",
            ".local/mtpro/readiness/assessments",
            ".local/mtpro/readiness/registry.lock",
            String(createdAt.timeIntervalSince1970),
            String(updatedAt.timeIntervalSince1970)
        ] + entries.sorted { $0.assessmentID.rawValue < $1.assessmentID.rawValue }.map(\.entryChecksum))
    }

    private static func validateEntries(_ entries: [ReadinessAssessmentRegistryEntry]) throws {
        var assessmentIDs = Set<String>()
        for entry in entries {
            guard assessmentIDs.insert(entry.assessmentID.rawValue).inserted else {
                throw ReadinessAssessmentRegistryStoreError.duplicateAssessmentID(entry.assessmentID.rawValue)
            }
            guard entry.entryHeld else {
                throw ReadinessAssessmentRegistryStoreError.boundaryDrift("registryEntry")
            }
        }
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentManifestV2ArtifactContentType 固定 GH-956 manifest v2 允许的本地 artifact 内容类型。
///
/// 当前类型只描述本地 readiness evidence artifact 的序列化格式。它不表示 endpoint payload、
/// broker fill、OMS command 或任何可发送订单的运行时消息。
public enum ReadinessAssessmentManifestV2ArtifactContentType: String, Codable, CaseIterable, Equatable, Sendable {
    case jsonEvidence = "application/json"
    case jsonLinesEvidence = "application/x-ndjson"
    case textEvidence = "text/plain"
}

/// ReadinessAssessmentManifestV2 是 GH-956 assessment-scoped manifest / provenance schema。
///
/// Manifest V2 只记录本地 assessmentID / generationID、来源 run / commit、artifact checksum、
/// byte count、schema version 和 producer version。`manifestHeld` 为 true 只证明本地
/// evidence 可追溯，不授权 production cutover、secret read、endpoint / broker connection
/// 或 submit / cancel / replace 命令。
public struct ReadinessAssessmentManifestV2: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.12.0.readiness-assessment-manifest.v2"
    public static let canonicalizationAlgorithm = "canonical-json-sha256"
    public static let forbiddenSourceCommitPlaceholders: Set<String> = [
        "0000000000000000000000000000000000000000",
        "0123456789abcdef0123456789abcdef01234567",
        "1111111111111111111111111111111111111111"
    ]

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let sourceRunIDs: [Identifier]
    public let sourceCommit: String
    public let schemaVersion: String
    public let canonicalizationAlgorithm: String
    public let artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType
    public let artifactSHA256: String
    public let artifactBytes: Int
    public let createdAt: Date
    public let producerVersion: String
    public let manifestChecksum: String
    public let assessmentSessionLocalOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-956"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-955"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && sourceRunIDs.isEmpty == false
            && sourceRunIDs.allSatisfy { $0.rawValue.isEmpty == false }
            && sourceRunIDs.map(\.rawValue) == sourceRunIDs.map(\.rawValue).sorted()
            && Self.isValidSourceCommit(sourceCommit)
            && schemaVersion == Self.schemaVersion
            && canonicalizationAlgorithm == Self.canonicalizationAlgorithm
            && Self.isValidSHA256Checksum(artifactSHA256)
            && artifactBytes > 0
            && producerVersion.isEmpty == false
            && manifestChecksum == Self.stableManifestChecksum(
                assessmentID: assessmentID,
                generationID: generationID,
                sourceRunIDs: sourceRunIDs,
                sourceCommit: sourceCommit,
                artifactContentType: artifactContentType,
                artifactSHA256: artifactSHA256,
                artifactBytes: artifactBytes,
                createdAt: createdAt,
                producerVersion: producerVersion
            )
            && assessmentSessionLocalOnly
            && productionCapabilitiesDisabled
    }

    public var manifestV2Path: String {
        ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/manifest-v2.json"
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-956"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-955")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        generationID: Identifier,
        sourceRunIDs: [Identifier],
        sourceCommit: String,
        schemaVersion: String = Self.schemaVersion,
        canonicalizationAlgorithm: String = Self.canonicalizationAlgorithm,
        artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType,
        artifactSHA256: String,
        artifactBytes: Int,
        createdAt: Date,
        producerVersion: String,
        manifestChecksum: String? = nil,
        assessmentSessionLocalOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        for sourceRunID in sourceRunIDs {
            try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(sourceRunID)
        }
        let sortedSourceRunIDs = sourceRunIDs.sorted { $0.rawValue < $1.rawValue }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.sourceRunIDs = sortedSourceRunIDs
        self.sourceCommit = sourceCommit
        self.schemaVersion = schemaVersion
        self.canonicalizationAlgorithm = canonicalizationAlgorithm
        self.artifactContentType = artifactContentType
        self.artifactSHA256 = artifactSHA256
        self.artifactBytes = artifactBytes
        self.createdAt = createdAt
        self.producerVersion = producerVersion
        self.manifestChecksum = manifestChecksum ?? Self.stableManifestChecksum(
            assessmentID: assessmentID,
            generationID: generationID,
            sourceRunIDs: sortedSourceRunIDs,
            sourceCommit: sourceCommit,
            artifactContentType: artifactContentType,
            artifactSHA256: artifactSHA256,
            artifactBytes: artifactBytes,
            createdAt: createdAt,
            producerVersion: producerVersion
        )
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessManifestV2")
        }
    }

    public static func stableManifestChecksum(
        assessmentID: Identifier,
        generationID: Identifier,
        sourceRunIDs: [Identifier],
        sourceCommit: String,
        artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType,
        artifactSHA256: String,
        artifactBytes: Int,
        createdAt: Date,
        producerVersion: String
    ) -> String {
        stableSHA256([
            "GH-956",
            "v0.12.0",
            Self.schemaVersion,
            Self.canonicalizationAlgorithm,
            assessmentID.rawValue,
            generationID.rawValue,
            sourceRunIDs.map(\.rawValue).sorted().joined(separator: ","),
            sourceCommit,
            artifactContentType.rawValue,
            artifactSHA256,
            String(artifactBytes),
            String(createdAt.timeIntervalSince1970),
            producerVersion,
            "assessmentSessionLocalOnly=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ])
    }

    public static func isValidSHA256Checksum(_ checksum: String) -> Bool {
        guard checksum.hasPrefix("sha256:") else {
            return false
        }
        let hex = checksum.dropFirst("sha256:".count)
        return hex.count == 64 && hex.allSatisfy(Self.isLowercaseHexCharacter)
    }

    public static func isValidSourceCommit(_ sourceCommit: String) -> Bool {
        sourceCommit.count == 40
            && sourceCommit.allSatisfy(Self.isLowercaseHexCharacter)
            && Self.forbiddenSourceCommitPlaceholders.contains(sourceCommit) == false
    }

    private static func isLowercaseHexCharacter(_ character: Character) -> Bool {
        Set("0123456789abcdef").contains(character)
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentArtifactContentValidationState 固定 GH-957 content policy validator 状态。
///
/// `valid` 只表示本地 artifact bytes 通过 JSON schema / redaction policy；它不授权
/// production cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReadinessAssessmentArtifactContentValidationState: String, Codable, CaseIterable, Equatable, Sendable {
    case valid
}

/// ReadinessAssessmentArtifactContentPolicy 定义 GH-957 每个 readiness artifact 的内容策略。
///
/// Policy 只描述本地 JSON evidence 的 top-level field allowlist、required field、forbidden
/// field 和 raw marker denylist。它拒绝 raw secret、raw listenKey、order payload 和
/// production endpoint response 形状，但不会读取 secret、调用 endpoint 或连接 broker。
public struct ReadinessAssessmentArtifactContentPolicy: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.12.0.artifact-content-policy.v1"
    public static let checksumAlgorithm = "canonical-json-sha256"
    public static let defaultForbiddenJSONFields = [
        "apiKey",
        "balance",
        "balances",
        "clientOrderId",
        "endpointResponse",
        "listenKey",
        "makerCommission",
        "orderId",
        "origClientOrderId",
        "price",
        "privatePayload",
        "quantity",
        "secret",
        "serverTime",
        "side",
        "signature",
        "status",
        "timeInForce",
        "type"
    ]
    public static let defaultForbiddenRawMarkers = [
        "/api/v3/account",
        "/api/v3/order",
        "/api/v3/userDataStream",
        "/fapi/v1/account",
        "/fapi/v1/order",
        "X-MBX-APIKEY",
        "api.binance.com",
        "fapi.binance.com",
        "listenKey=",
        "raw-listen-key",
        "raw-secret",
        "secretKey=",
        "sk_live_"
    ]

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let checksumAlgorithm: String
    public let policyVersion: String
    public let artifactID: Identifier
    public let artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType
    public let allowedJSONFields: [String]
    public let requiredJSONFields: [String]
    public let forbiddenJSONFields: [String]
    public let forbiddenRawMarkers: [String]
    public let policyChecksum: String
    public let assessmentSessionLocalOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var policyHeld: Bool {
        issueID.rawValue == "GH-957"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-956"]
            && releaseVersion == "v0.12.0"
            && schemaVersion == Self.schemaVersion
            && checksumAlgorithm == Self.checksumAlgorithm
            && policyVersion.isEmpty == false
            && artifactID.rawValue.isEmpty == false
            && artifactContentType == .jsonEvidence
            && allowedJSONFields.isEmpty == false
            && requiredJSONFields.isEmpty == false
            && forbiddenJSONFields.isEmpty == false
            && forbiddenRawMarkers.isEmpty == false
            && Self.isSortedUnique(allowedJSONFields)
            && Self.isSortedUnique(requiredJSONFields)
            && Self.isSortedUnique(forbiddenJSONFields)
            && Self.isSortedUnique(forbiddenRawMarkers)
            && Set(requiredJSONFields).isSubset(of: Set(allowedJSONFields))
            && Set(allowedJSONFields).isDisjoint(with: Set(forbiddenJSONFields))
            && Set(requiredJSONFields).isDisjoint(with: Set(forbiddenJSONFields))
            && policyChecksum == Self.stablePolicyChecksum(
                policyVersion: policyVersion,
                artifactID: artifactID,
                artifactContentType: artifactContentType,
                allowedJSONFields: allowedJSONFields,
                requiredJSONFields: requiredJSONFields,
                forbiddenJSONFields: forbiddenJSONFields,
                forbiddenRawMarkers: forbiddenRawMarkers
            )
            && assessmentSessionLocalOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-957"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-956")],
        releaseVersion: String = "v0.12.0",
        schemaVersion: String = Self.schemaVersion,
        checksumAlgorithm: String = Self.checksumAlgorithm,
        policyVersion: String,
        artifactID: Identifier,
        artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType = .jsonEvidence,
        allowedJSONFields: [String],
        requiredJSONFields: [String],
        forbiddenJSONFields: [String] = Self.defaultForbiddenJSONFields,
        forbiddenRawMarkers: [String] = Self.defaultForbiddenRawMarkers,
        policyChecksum: String? = nil,
        assessmentSessionLocalOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(artifactID)
        let sortedAllowedJSONFields = allowedJSONFields.sorted()
        let sortedRequiredJSONFields = requiredJSONFields.sorted()
        let sortedForbiddenJSONFields = forbiddenJSONFields.sorted()
        let sortedForbiddenRawMarkers = forbiddenRawMarkers.sorted()

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.checksumAlgorithm = checksumAlgorithm
        self.policyVersion = policyVersion
        self.artifactID = artifactID
        self.artifactContentType = artifactContentType
        self.allowedJSONFields = sortedAllowedJSONFields
        self.requiredJSONFields = sortedRequiredJSONFields
        self.forbiddenJSONFields = sortedForbiddenJSONFields
        self.forbiddenRawMarkers = sortedForbiddenRawMarkers
        self.policyChecksum = policyChecksum ?? Self.stablePolicyChecksum(
            policyVersion: policyVersion,
            artifactID: artifactID,
            artifactContentType: artifactContentType,
            allowedJSONFields: sortedAllowedJSONFields,
            requiredJSONFields: sortedRequiredJSONFields,
            forbiddenJSONFields: sortedForbiddenJSONFields,
            forbiddenRawMarkers: sortedForbiddenRawMarkers
        )
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard policyHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy")
        }
    }

    public static func stablePolicyChecksum(
        policyVersion: String,
        artifactID: Identifier,
        artifactContentType: ReadinessAssessmentManifestV2ArtifactContentType,
        allowedJSONFields: [String],
        requiredJSONFields: [String],
        forbiddenJSONFields: [String],
        forbiddenRawMarkers: [String]
    ) -> String {
        stableSHA256([
            "GH-957",
            "v0.12.0",
            Self.schemaVersion,
            Self.checksumAlgorithm,
            policyVersion,
            artifactID.rawValue,
            artifactContentType.rawValue,
            allowedJSONFields.sorted().joined(separator: ","),
            requiredJSONFields.sorted().joined(separator: ","),
            forbiddenJSONFields.sorted().joined(separator: ","),
            forbiddenRawMarkers.sorted().joined(separator: ","),
            "assessmentSessionLocalOnly=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ])
    }

    private static func isSortedUnique(_ values: [String]) -> Bool {
        values == values.sorted() && Set(values).count == values.count && values.allSatisfy { $0.isEmpty == false }
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentArtifactContentValidationResult 是 GH-957 content validator 输出的本地 evidence。
///
/// Result 记录通过 allowlist / denylist / checksum 校验后的 artifact 内容证明。它只证明
/// artifact 未包含 raw secret、raw listenKey、order payload 或 production endpoint response；
/// 不会把 readiness evidence 升级为交易授权。
public struct ReadinessAssessmentArtifactContentValidationResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let artifactID: Identifier
    public let policyVersion: String
    public let policyChecksum: String
    public let artifactSHA256: String
    public let validationState: ReadinessAssessmentArtifactContentValidationState
    public let observedTopLevelJSONFields: [String]
    public let missingRequiredJSONFields: [String]
    public let unexpectedJSONFields: [String]
    public let forbiddenJSONFields: [String]
    public let forbiddenRawMarkers: [String]
    public let validatedAt: Date
    public let stateReason: String
    public let contentValidationChecksum: String
    public let assessmentSessionLocalOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var validationHeld: Bool {
        issueID.rawValue == "GH-957"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-956"]
            && releaseVersion == "v0.12.0"
            && artifactID.rawValue.isEmpty == false
            && policyVersion.isEmpty == false
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(policyChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactSHA256)
            && validationState == .valid
            && observedTopLevelJSONFields.isEmpty == false
            && observedTopLevelJSONFields == observedTopLevelJSONFields.sorted()
            && missingRequiredJSONFields.isEmpty
            && unexpectedJSONFields.isEmpty
            && forbiddenJSONFields.isEmpty
            && forbiddenRawMarkers.isEmpty
            && stateReason == "artifact content policy valid"
            && contentValidationChecksum == Self.stableContentValidationChecksum(
                artifactID: artifactID,
                policyVersion: policyVersion,
                policyChecksum: policyChecksum,
                artifactSHA256: artifactSHA256,
                observedTopLevelJSONFields: observedTopLevelJSONFields,
                validatedAt: validatedAt
            )
            && assessmentSessionLocalOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-957"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-956")],
        releaseVersion: String = "v0.12.0",
        artifactID: Identifier,
        policyVersion: String,
        policyChecksum: String,
        artifactSHA256: String,
        validationState: ReadinessAssessmentArtifactContentValidationState = .valid,
        observedTopLevelJSONFields: [String],
        missingRequiredJSONFields: [String] = [],
        unexpectedJSONFields: [String] = [],
        forbiddenJSONFields: [String] = [],
        forbiddenRawMarkers: [String] = [],
        validatedAt: Date,
        stateReason: String = "artifact content policy valid",
        contentValidationChecksum: String? = nil,
        assessmentSessionLocalOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(artifactID)
        let sortedObservedTopLevelJSONFields = observedTopLevelJSONFields.sorted()
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.artifactID = artifactID
        self.policyVersion = policyVersion
        self.policyChecksum = policyChecksum
        self.artifactSHA256 = artifactSHA256
        self.validationState = validationState
        self.observedTopLevelJSONFields = sortedObservedTopLevelJSONFields
        self.missingRequiredJSONFields = missingRequiredJSONFields.sorted()
        self.unexpectedJSONFields = unexpectedJSONFields.sorted()
        self.forbiddenJSONFields = forbiddenJSONFields.sorted()
        self.forbiddenRawMarkers = forbiddenRawMarkers.sorted()
        self.validatedAt = validatedAt
        self.stateReason = stateReason
        self.contentValidationChecksum = contentValidationChecksum ?? Self.stableContentValidationChecksum(
            artifactID: artifactID,
            policyVersion: policyVersion,
            policyChecksum: policyChecksum,
            artifactSHA256: artifactSHA256,
            observedTopLevelJSONFields: sortedObservedTopLevelJSONFields,
            validatedAt: validatedAt
        )
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard validationHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentValidationResult")
        }
    }

    public static func stableContentValidationChecksum(
        artifactID: Identifier,
        policyVersion: String,
        policyChecksum: String,
        artifactSHA256: String,
        observedTopLevelJSONFields: [String],
        validatedAt: Date
    ) -> String {
        stableSHA256([
            "GH-957",
            "v0.12.0",
            artifactID.rawValue,
            policyVersion,
            policyChecksum,
            artifactSHA256,
            observedTopLevelJSONFields.sorted().joined(separator: ","),
            String(validatedAt.timeIntervalSince1970),
            "artifact content policy valid",
            "assessmentSessionLocalOnly=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentBundleV2ReviewState 固定 GH-958 review snapshot 状态。
///
/// `in-review` 只表示本地 readiness bundle 已进入人工审阅证据阶段；它不是 approval，
/// 也不会授权 production cutover、secret read、endpoint / broker connection 或订单命令。
public enum ReadinessAssessmentBundleV2ReviewState: String, Codable, CaseIterable, Equatable, Sendable {
    case draft
    case inReview = "in-review"
}

/// ReadinessAssessmentBundleV2ArtifactSnapshot 记录 bundle 内单个本地 evidence artifact。
///
/// Snapshot 只引用 Manifest V2 / content-policy validation 的 checksum，不保存 raw secret、
/// listenKey、endpoint response、broker payload 或 order payload。
public struct ReadinessAssessmentBundleV2ArtifactSnapshot: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let manifestChecksum: String
    public let artifactSHA256: String
    public let contentValidationChecksum: String
    public let artifactPath: String
    public let redactedEvidenceOnly: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var snapshotHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(manifestChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactSHA256)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(contentValidationChecksum)
            && artifactPath.hasPrefix(".local/mtpro/readiness/assessments/")
            && artifactPath.hasSuffix(".json")
            && redactedEvidenceOnly
            && noSecretValue
            && noOrderPayload
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
    }

    public init(
        artifactID: Identifier,
        manifestChecksum: String,
        artifactSHA256: String,
        contentValidationChecksum: String,
        artifactPath: String,
        redactedEvidenceOnly: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(artifactID)
        self.artifactID = artifactID
        self.manifestChecksum = manifestChecksum
        self.artifactSHA256 = artifactSHA256
        self.contentValidationChecksum = contentValidationChecksum
        self.artifactPath = artifactPath
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard snapshotHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2ArtifactSnapshot")
        }
    }
}

/// ReadinessAssessmentBundleV2 是 GH-958 reviewable readiness bundle payload。
///
/// Bundle V2 是 assessment generation scoped 本地 JSON evidence。进入 `in-review` 后，
/// 同一 generation 的 bundle 不允许原地修改；任何输入变化必须创建新的 generation。
public struct ReadinessAssessmentBundleV2: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.12.0.readiness-bundle.v2"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let schemaVersion: String
    public let bundlePath: String
    public let manifestPath: String
    public let reviewState: ReadinessAssessmentBundleV2ReviewState
    public let sourceRunIDs: [Identifier]
    public let sourceCommit: String
    public let artifactSnapshots: [ReadinessAssessmentBundleV2ArtifactSnapshot]
    public let createdAt: Date
    public let producerVersion: String
    public let bundleChecksum: String
    public let immutableAfterReview: Bool
    public let changeRequiresNewGeneration: Bool
    public let assessmentSessionLocalOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var bundleHeld: Bool {
        issueID.rawValue == "GH-958"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-957"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && schemaVersion == Self.schemaVersion
            && bundlePath == Self.bundlePath(assessmentID: assessmentID, generationID: generationID)
            && manifestPath == Self.manifestPath(assessmentID: assessmentID, generationID: generationID)
            && sourceRunIDs.isEmpty == false
            && sourceRunIDs.map(\.rawValue) == sourceRunIDs.map(\.rawValue).sorted()
            && sourceRunIDs.allSatisfy { $0.rawValue.isEmpty == false }
            && ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit)
            && artifactSnapshots.isEmpty == false
            && artifactSnapshots.allSatisfy(\.snapshotHeld)
            && artifactSnapshots.map(\.artifactID.rawValue) == artifactSnapshots.map(\.artifactID.rawValue).sorted()
            && Set(artifactSnapshots.map(\.artifactID.rawValue)).count == artifactSnapshots.count
            && producerVersion.isEmpty == false
            && bundleChecksum == Self.stableBundleChecksum(
                assessmentID: assessmentID,
                generationID: generationID,
                reviewState: reviewState,
                sourceRunIDs: sourceRunIDs,
                sourceCommit: sourceCommit,
                artifactSnapshots: artifactSnapshots,
                createdAt: createdAt,
                producerVersion: producerVersion
            )
            && immutableAfterReview
            && changeRequiresNewGeneration
            && assessmentSessionLocalOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-958"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-957")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        generationID: Identifier,
        schemaVersion: String = Self.schemaVersion,
        reviewState: ReadinessAssessmentBundleV2ReviewState,
        sourceRunIDs: [Identifier],
        sourceCommit: String,
        artifactSnapshots: [ReadinessAssessmentBundleV2ArtifactSnapshot],
        createdAt: Date,
        producerVersion: String,
        bundleChecksum: String? = nil,
        immutableAfterReview: Bool = true,
        changeRequiresNewGeneration: Bool = true,
        assessmentSessionLocalOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        for sourceRunID in sourceRunIDs {
            try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(sourceRunID)
        }
        let sortedSourceRunIDs = sourceRunIDs.sorted { $0.rawValue < $1.rawValue }
        let sortedArtifactSnapshots = artifactSnapshots.sorted { $0.artifactID.rawValue < $1.artifactID.rawValue }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.schemaVersion = schemaVersion
        self.bundlePath = Self.bundlePath(assessmentID: assessmentID, generationID: generationID)
        self.manifestPath = Self.manifestPath(assessmentID: assessmentID, generationID: generationID)
        self.reviewState = reviewState
        self.sourceRunIDs = sortedSourceRunIDs
        self.sourceCommit = sourceCommit
        self.artifactSnapshots = sortedArtifactSnapshots
        self.createdAt = createdAt
        self.producerVersion = producerVersion
        self.bundleChecksum = bundleChecksum ?? Self.stableBundleChecksum(
            assessmentID: assessmentID,
            generationID: generationID,
            reviewState: reviewState,
            sourceRunIDs: sortedSourceRunIDs,
            sourceCommit: sourceCommit,
            artifactSnapshots: sortedArtifactSnapshots,
            createdAt: createdAt,
            producerVersion: producerVersion
        )
        self.immutableAfterReview = immutableAfterReview
        self.changeRequiresNewGeneration = changeRequiresNewGeneration
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard bundleHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2")
        }
    }

    public static func stableBundleChecksum(
        assessmentID: Identifier,
        generationID: Identifier,
        reviewState: ReadinessAssessmentBundleV2ReviewState,
        sourceRunIDs: [Identifier],
        sourceCommit: String,
        artifactSnapshots: [ReadinessAssessmentBundleV2ArtifactSnapshot],
        createdAt: Date,
        producerVersion: String
    ) -> String {
        stableSHA256([
            "GH-958",
            "v0.12.0",
            Self.schemaVersion,
            bundlePath(assessmentID: assessmentID, generationID: generationID),
            manifestPath(assessmentID: assessmentID, generationID: generationID),
            assessmentID.rawValue,
            generationID.rawValue,
            reviewState.rawValue,
            sourceRunIDs.map(\.rawValue).sorted().joined(separator: ","),
            sourceCommit,
            String(createdAt.timeIntervalSince1970),
            producerVersion,
            "immutableAfterReview=true",
            "changeRequiresNewGeneration=true",
            "assessmentSessionLocalOnly=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ] + artifactSnapshots.sorted { $0.artifactID.rawValue < $1.artifactID.rawValue }.flatMap { snapshot in
            [
                snapshot.artifactID.rawValue,
                snapshot.manifestChecksum,
                snapshot.artifactSHA256,
                snapshot.contentValidationChecksum,
                snapshot.artifactPath
            ]
        })
    }

    public static func bundlePath(assessmentID: Identifier, generationID: Identifier) -> String {
        ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/generations/\(generationID.rawValue)/readiness-bundle-v2.json"
    }

    public static func manifestPath(assessmentID: Identifier, generationID: Identifier) -> String {
        ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/generations/\(generationID.rawValue)/readiness-bundle-v2.manifest.json"
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentBundleV2Manifest 记录 bundle JSON 的实际文件 checksum。
///
/// Manifest 只证明 review snapshot 的本地 bytes / checksum / generation identity；它不表示
/// approval、cutover、broker connection 或 order authorization。
public struct ReadinessAssessmentBundleV2Manifest: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.12.0.readiness-bundle-manifest.v2"
    public static let canonicalizationAlgorithm = "canonical-json-sha256"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let schemaVersion: String
    public let canonicalizationAlgorithm: String
    public let bundlePath: String
    public let manifestPath: String
    public let bundleChecksum: String
    public let bundleJSONSHA256: String
    public let bundleBytes: Int
    public let createdAt: Date
    public let producerVersion: String
    public let manifestChecksum: String
    public let immutableAfterReview: Bool
    public let changeRequiresNewGeneration: Bool
    public let assessmentSessionLocalOnly: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-958"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-957"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && schemaVersion == Self.schemaVersion
            && canonicalizationAlgorithm == Self.canonicalizationAlgorithm
            && bundlePath == ReadinessAssessmentBundleV2.bundlePath(assessmentID: assessmentID, generationID: generationID)
            && manifestPath == ReadinessAssessmentBundleV2.manifestPath(assessmentID: assessmentID, generationID: generationID)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(bundleChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(bundleJSONSHA256)
            && bundleBytes > 0
            && producerVersion.isEmpty == false
            && manifestChecksum == Self.stableManifestChecksum(
                assessmentID: assessmentID,
                generationID: generationID,
                bundleChecksum: bundleChecksum,
                bundleJSONSHA256: bundleJSONSHA256,
                bundleBytes: bundleBytes,
                createdAt: createdAt,
                producerVersion: producerVersion
            )
            && immutableAfterReview
            && changeRequiresNewGeneration
            && assessmentSessionLocalOnly
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-958"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-957")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        generationID: Identifier,
        schemaVersion: String = Self.schemaVersion,
        canonicalizationAlgorithm: String = Self.canonicalizationAlgorithm,
        bundleChecksum: String,
        bundleJSONSHA256: String,
        bundleBytes: Int,
        createdAt: Date,
        producerVersion: String,
        manifestChecksum: String? = nil,
        immutableAfterReview: Bool = true,
        changeRequiresNewGeneration: Bool = true,
        assessmentSessionLocalOnly: Bool = true,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.schemaVersion = schemaVersion
        self.canonicalizationAlgorithm = canonicalizationAlgorithm
        self.bundlePath = ReadinessAssessmentBundleV2.bundlePath(assessmentID: assessmentID, generationID: generationID)
        self.manifestPath = ReadinessAssessmentBundleV2.manifestPath(assessmentID: assessmentID, generationID: generationID)
        self.bundleChecksum = bundleChecksum
        self.bundleJSONSHA256 = bundleJSONSHA256
        self.bundleBytes = bundleBytes
        self.createdAt = createdAt
        self.producerVersion = producerVersion
        self.manifestChecksum = manifestChecksum ?? Self.stableManifestChecksum(
            assessmentID: assessmentID,
            generationID: generationID,
            bundleChecksum: bundleChecksum,
            bundleJSONSHA256: bundleJSONSHA256,
            bundleBytes: bundleBytes,
            createdAt: createdAt,
            producerVersion: producerVersion
        )
        self.immutableAfterReview = immutableAfterReview
        self.changeRequiresNewGeneration = changeRequiresNewGeneration
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2Manifest")
        }
    }

    public static func stableManifestChecksum(
        assessmentID: Identifier,
        generationID: Identifier,
        bundleChecksum: String,
        bundleJSONSHA256: String,
        bundleBytes: Int,
        createdAt: Date,
        producerVersion: String
    ) -> String {
        stableSHA256([
            "GH-958",
            "v0.12.0",
            Self.schemaVersion,
            Self.canonicalizationAlgorithm,
            ReadinessAssessmentBundleV2.bundlePath(assessmentID: assessmentID, generationID: generationID),
            ReadinessAssessmentBundleV2.manifestPath(assessmentID: assessmentID, generationID: generationID),
            assessmentID.rawValue,
            generationID.rawValue,
            bundleChecksum,
            bundleJSONSHA256,
            String(bundleBytes),
            String(createdAt.timeIntervalSince1970),
            producerVersion,
            "immutableAfterReview=true",
            "changeRequiresNewGeneration=true",
            "assessmentSessionLocalOnly=true",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentTransactionControl 固定 GH-955 assessment 写入交易的控制面。
///
/// 它只描述本地 transactionID / generationID、staging directory、commit marker 和
/// compare-and-swap manifest 路径；这些字段不能被解释成 production cutover 或订单授权。
public struct ReadinessAssessmentTransactionControl: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let transactionID: Identifier
    public let generationID: Identifier
    public let expectedPreviousGenerationID: Identifier?
    public let assessmentLockPath: String
    public let stagingDirectoryPath: String
    public let transactionManifestPath: String
    public let commitMarkerPath: String
    public let compareAndSwapManifestPath: String
    public let startedAt: Date
    public let assessmentSessionLocalOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool

    public var controlHeld: Bool {
        issueID.rawValue == "GH-955"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-954"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && transactionID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && assessmentLockPath == ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/assessment.lock"
            && stagingDirectoryPath == ".local/mtpro/readiness/staging/\(assessmentID.rawValue)/\(transactionID.rawValue)"
            && transactionManifestPath == "\(stagingDirectoryPath)/transaction-manifest.json"
            && commitMarkerPath == ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/commit-marker.json"
            && compareAndSwapManifestPath == ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/compare-and-swap-manifest.json"
            && assessmentSessionLocalOnly
            && productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-955"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-954")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        transactionID: Identifier,
        generationID: Identifier,
        expectedPreviousGenerationID: Identifier?,
        startedAt: Date,
        assessmentSessionLocalOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(transactionID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        if let expectedPreviousGenerationID {
            try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(expectedPreviousGenerationID)
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.transactionID = transactionID
        self.generationID = generationID
        self.expectedPreviousGenerationID = expectedPreviousGenerationID
        self.assessmentLockPath = ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/assessment.lock"
        self.stagingDirectoryPath = ".local/mtpro/readiness/staging/\(assessmentID.rawValue)/\(transactionID.rawValue)"
        self.transactionManifestPath = "\(stagingDirectoryPath)/transaction-manifest.json"
        self.commitMarkerPath = ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/commit-marker.json"
        self.compareAndSwapManifestPath = ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/compare-and-swap-manifest.json"
        self.startedAt = startedAt
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled

        guard controlHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("transactionControl")
        }
    }
}

/// ReadinessAssessmentCompareAndSwapManifest 是 GH-955 的 generation compare-and-swap 记录。
public struct ReadinessAssessmentCompareAndSwapManifest: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let assessmentID: Identifier
    public let transactionID: Identifier
    public let currentGenerationID: Identifier
    public let previousGenerationID: Identifier?
    public let committedAt: Date
    public let manifestChecksum: String
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-955"
            && assessmentID.rawValue.isEmpty == false
            && transactionID.rawValue.isEmpty == false
            && currentGenerationID.rawValue.isEmpty == false
            && previousGenerationID?.rawValue != currentGenerationID.rawValue
            && manifestChecksum == Self.stableManifestChecksum(
                assessmentID: assessmentID,
                transactionID: transactionID,
                currentGenerationID: currentGenerationID,
                previousGenerationID: previousGenerationID,
                committedAt: committedAt
            )
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-955"),
        assessmentID: Identifier,
        transactionID: Identifier,
        currentGenerationID: Identifier,
        previousGenerationID: Identifier?,
        committedAt: Date,
        manifestChecksum: String? = nil,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(transactionID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(currentGenerationID)
        if let previousGenerationID {
            try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(previousGenerationID)
        }
        self.issueID = issueID
        self.assessmentID = assessmentID
        self.transactionID = transactionID
        self.currentGenerationID = currentGenerationID
        self.previousGenerationID = previousGenerationID
        self.committedAt = committedAt
        self.manifestChecksum = manifestChecksum ?? Self.stableManifestChecksum(
            assessmentID: assessmentID,
            transactionID: transactionID,
            currentGenerationID: currentGenerationID,
            previousGenerationID: previousGenerationID,
            committedAt: committedAt
        )
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("compareAndSwapManifest")
        }
    }

    public static func stableManifestChecksum(
        assessmentID: Identifier,
        transactionID: Identifier,
        currentGenerationID: Identifier,
        previousGenerationID: Identifier?,
        committedAt: Date
    ) -> String {
        stableSHA256([
            "GH-955",
            "v0.12.0",
            assessmentID.rawValue,
            transactionID.rawValue,
            currentGenerationID.rawValue,
            previousGenerationID?.rawValue ?? "",
            String(committedAt.timeIntervalSince1970),
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentCommitMarker 固定 transaction 成功提交后的本地 marker。
public struct ReadinessAssessmentCommitMarker: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let assessmentID: Identifier
    public let transactionID: Identifier
    public let generationID: Identifier
    public let committedAt: Date
    public let manifestChecksum: String
    public let markerChecksum: String
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var markerHeld: Bool {
        issueID.rawValue == "GH-955"
            && assessmentID.rawValue.isEmpty == false
            && transactionID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && manifestChecksum.hasPrefix("sha256:")
            && markerChecksum == Self.stableMarkerChecksum(
                assessmentID: assessmentID,
                transactionID: transactionID,
                generationID: generationID,
                committedAt: committedAt,
                manifestChecksum: manifestChecksum
            )
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-955"),
        assessmentID: Identifier,
        transactionID: Identifier,
        generationID: Identifier,
        committedAt: Date,
        manifestChecksum: String,
        markerChecksum: String? = nil,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(transactionID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        self.issueID = issueID
        self.assessmentID = assessmentID
        self.transactionID = transactionID
        self.generationID = generationID
        self.committedAt = committedAt
        self.manifestChecksum = manifestChecksum
        self.markerChecksum = markerChecksum ?? Self.stableMarkerChecksum(
            assessmentID: assessmentID,
            transactionID: transactionID,
            generationID: generationID,
            committedAt: committedAt,
            manifestChecksum: manifestChecksum
        )
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard markerHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("commitMarker")
        }
    }

    public static func stableMarkerChecksum(
        assessmentID: Identifier,
        transactionID: Identifier,
        generationID: Identifier,
        committedAt: Date,
        manifestChecksum: String
    ) -> String {
        stableSHA256([
            "GH-955",
            "v0.12.0",
            assessmentID.rawValue,
            transactionID.rawValue,
            generationID.rawValue,
            String(committedAt.timeIntervalSince1970),
            manifestChecksum,
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentTransactionAbortMarker 记录本地 transaction abort 证据。
public struct ReadinessAssessmentTransactionAbortMarker: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let assessmentID: Identifier
    public let transactionID: Identifier
    public let reason: String
    public let abortedAt: Date
    public let abortMarkerPath: String
    public let stagingRemoved: Bool
    public let assessmentLockReleased: Bool
    public let productionCutoverAuthorized: Bool

    public var abortHeld: Bool {
        issueID.rawValue == "GH-955"
            && assessmentID.rawValue.isEmpty == false
            && transactionID.rawValue.isEmpty == false
            && reason.isEmpty == false
            && abortMarkerPath == ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/abort-marker-\(transactionID.rawValue).json"
            && stagingRemoved
            && assessmentLockReleased
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-955"),
        assessmentID: Identifier,
        transactionID: Identifier,
        reason: String,
        abortedAt: Date,
        stagingRemoved: Bool,
        assessmentLockReleased: Bool,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(transactionID)
        self.issueID = issueID
        self.assessmentID = assessmentID
        self.transactionID = transactionID
        self.reason = reason
        self.abortedAt = abortedAt
        self.abortMarkerPath = ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/abort-marker-\(transactionID.rawValue).json"
        self.stagingRemoved = stagingRemoved
        self.assessmentLockReleased = assessmentLockReleased
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard abortHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("transactionAbortMarker")
        }
    }
}

/// ReadinessAssessmentTransactionRecoveryReport 是 GH-955 crash recovery 的本地清理报告。
public struct ReadinessAssessmentTransactionRecoveryReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let recoveredAt: Date
    public let recoveredStagingDirectoryPaths: [String]
    public let recoveredAssessmentLockPaths: [String]
    public let productionCutoverAuthorized: Bool
    public let productionOrderSubmitted: Bool

    public var recoveryHeld: Bool {
        issueID.rawValue == "GH-955"
            && recoveredStagingDirectoryPaths == recoveredStagingDirectoryPaths.sorted()
            && recoveredAssessmentLockPaths == recoveredAssessmentLockPaths.sorted()
            && productionCutoverAuthorized == false
            && productionOrderSubmitted == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-955"),
        recoveredAt: Date,
        recoveredStagingDirectoryPaths: [String],
        recoveredAssessmentLockPaths: [String],
        productionCutoverAuthorized: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        self.issueID = issueID
        self.recoveredAt = recoveredAt
        self.recoveredStagingDirectoryPaths = recoveredStagingDirectoryPaths.sorted()
        self.recoveredAssessmentLockPaths = recoveredAssessmentLockPaths.sorted()
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionOrderSubmitted = productionOrderSubmitted

        guard recoveryHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("transactionRecoveryReport")
        }
    }
}

/// ReadinessAssessmentRegistryTransactionResult 汇总一次 transaction-backed assessment write。
public struct ReadinessAssessmentRegistryTransactionResult: Equatable, Sendable {
    public let document: ReadinessAssessmentRegistryDocument
    public let control: ReadinessAssessmentTransactionControl
    public let manifest: ReadinessAssessmentCompareAndSwapManifest
    public let commitMarker: ReadinessAssessmentCommitMarker
}

/// ReadinessAssessmentBundleV2SnapshotWriteResult 汇总 GH-958 review snapshot write evidence。
public struct ReadinessAssessmentBundleV2SnapshotWriteResult: Equatable, Sendable {
    public let bundle: ReadinessAssessmentBundleV2
    public let manifest: ReadinessAssessmentBundleV2Manifest
}

/// ReadinessAssessmentComparisonSection 固定 GH-962 本地 assessment compare 的比较维度。
///
/// 这些 section 只用于 operator review 的本地差异阅读；它们不能被解释成 approval、
/// production cutover、broker connection 或 submit / cancel / replace 授权。
public enum ReadinessAssessmentComparisonSection: String, Codable, CaseIterable, Equatable, Sendable {
    case policy
    case artifacts
    case riskLimits = "risk-limits"
    case killSwitchState = "kill-switch-state"
    case approvalState = "approval-state"
    case sourceRunEvidence = "source-run-evidence"
}

/// ReadinessAssessmentComparisonDeltaState 表示单个 compare section 的差异状态。
public enum ReadinessAssessmentComparisonDeltaState: String, Codable, CaseIterable, Equatable, Sendable {
    case unchanged
    case changed
}

/// ReadinessAssessmentComparisonSnapshot 是 GH-962 比较两个 assessment 时的稳定输入视图。
///
/// Snapshot 只引用前序 evidence 的 checksum 和 source run fingerprint，不保存 secret、
/// endpoint response、broker payload 或 order payload。比较只能消费这些本地 evidence 指纹。
public struct ReadinessAssessmentComparisonSnapshot: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let policyChecksum: String
    public let artifactBundleChecksum: String
    public let riskLimitChecksum: String
    public let killSwitchStateChecksum: String
    public let approvalStateChecksum: String
    public let sourceRunSnapshot: ReleaseV0120ShadowParitySourceRunSnapshot
    public let assessmentSessionLocalOnly: Bool
    public let compareDoesNotMutateAssessments: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var snapshotHeld: Bool {
        issueID.rawValue == "GH-962"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-961"]
            && releaseVersion == "v0.12.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(policyChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactBundleChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(riskLimitChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(killSwitchStateChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(approvalStateChecksum)
            && sourceRunSnapshot.snapshotHeld
            && assessmentSessionLocalOnly
            && compareDoesNotMutateAssessments
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-962"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-961")],
        releaseVersion: String = "v0.12.0",
        assessmentID: Identifier,
        generationID: Identifier,
        policyChecksum: String,
        artifactBundleChecksum: String,
        riskLimitChecksum: String,
        killSwitchStateChecksum: String,
        approvalStateChecksum: String,
        sourceRunSnapshot: ReleaseV0120ShadowParitySourceRunSnapshot,
        assessmentSessionLocalOnly: Bool = true,
        compareDoesNotMutateAssessments: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(assessmentID)
        try ReadinessAssessmentRegistryArtifactPaths.validateAssessmentID(generationID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.policyChecksum = policyChecksum
        self.artifactBundleChecksum = artifactBundleChecksum
        self.riskLimitChecksum = riskLimitChecksum
        self.killSwitchStateChecksum = killSwitchStateChecksum
        self.approvalStateChecksum = approvalStateChecksum
        self.sourceRunSnapshot = sourceRunSnapshot
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.compareDoesNotMutateAssessments = compareDoesNotMutateAssessments
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard snapshotHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessAssessmentComparisonSnapshot")
        }
    }

    public func comparisonValue(for section: ReadinessAssessmentComparisonSection) -> String {
        switch section {
        case .policy:
            policyChecksum
        case .artifacts:
            artifactBundleChecksum
        case .riskLimits:
            riskLimitChecksum
        case .killSwitchState:
            killSwitchStateChecksum
        case .approvalState:
            approvalStateChecksum
        case .sourceRunEvidence:
            sourceRunSnapshot.snapshotChecksum
        }
    }
}

/// ReadinessAssessmentComparisonDelta 是 GH-962 单个 section 的 deterministic diff row。
public struct ReadinessAssessmentComparisonDelta: Codable, Equatable, Sendable {
    public let section: ReadinessAssessmentComparisonSection
    public let baselineValue: String
    public let followUpValue: String
    public let deltaState: ReadinessAssessmentComparisonDeltaState
    public let stateReason: String

    public var deltaHeld: Bool {
        baselineValue.isEmpty == false
            && followUpValue.isEmpty == false
            && deltaState == (baselineValue == followUpValue ? .unchanged : .changed)
            && stateReason == (deltaState == .unchanged ? "matched" : "changed")
    }

    public init(
        section: ReadinessAssessmentComparisonSection,
        baselineValue: String,
        followUpValue: String
    ) {
        self.section = section
        self.baselineValue = baselineValue
        self.followUpValue = followUpValue
        self.deltaState = baselineValue == followUpValue ? .unchanged : .changed
        self.stateReason = baselineValue == followUpValue ? "matched" : "changed"
    }
}

/// ReadinessAssessmentComparisonReport 是 GH-962 的 operator review compare 输出。
///
/// Report 只解释两个 local readiness assessment snapshot 的 matched / changed sections。
/// 它不修改 registry，不创建 approval，不授权 production cutover，也不启用任何订单路径。
public struct ReadinessAssessmentComparisonReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let baselineAssessmentID: Identifier
    public let followUpAssessmentID: Identifier
    public let baselineGenerationID: Identifier
    public let followUpGenerationID: Identifier
    public let comparedAt: Date
    public let comparedSections: [ReadinessAssessmentComparisonSection]
    public let changedSections: [ReadinessAssessmentComparisonSection]
    public let unchangedSections: [ReadinessAssessmentComparisonSection]
    public let deltas: [ReadinessAssessmentComparisonDelta]
    public let hasDifferences: Bool
    public let reportChecksum: String
    public let assessmentSessionLocalOnly: Bool
    public let compareDoesNotMutateAssessments: Bool
    public let operatorReviewOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let realOrderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var reportHeld: Bool {
        issueID.rawValue == "GH-962"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-951", "GH-961"]
            && releaseVersion == "v0.12.0"
            && baselineAssessmentID.rawValue.isEmpty == false
            && followUpAssessmentID.rawValue.isEmpty == false
            && baselineAssessmentID != followUpAssessmentID
            && baselineGenerationID.rawValue.isEmpty == false
            && followUpGenerationID.rawValue.isEmpty == false
            && comparedSections == ReadinessAssessmentComparisonSection.allCases
            && deltas.map(\.section) == comparedSections
            && deltas.allSatisfy(\.deltaHeld)
            && changedSections == deltas.filter { $0.deltaState == .changed }.map(\.section)
            && unchangedSections == deltas.filter { $0.deltaState == .unchanged }.map(\.section)
            && hasDifferences == (changedSections.isEmpty == false)
            && reportChecksum == Self.stableReportChecksum(
                baselineAssessmentID: baselineAssessmentID,
                followUpAssessmentID: followUpAssessmentID,
                baselineGenerationID: baselineGenerationID,
                followUpGenerationID: followUpGenerationID,
                comparedAt: comparedAt,
                deltas: deltas
            )
            && assessmentSessionLocalOnly
            && compareDoesNotMutateAssessments
            && operatorReviewOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && realOrderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-962"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-951"), Identifier.constant("GH-961")],
        releaseVersion: String = "v0.12.0",
        baselineSnapshot: ReadinessAssessmentComparisonSnapshot,
        followUpSnapshot: ReadinessAssessmentComparisonSnapshot,
        comparedAt: Date,
        reportChecksum: String? = nil,
        assessmentSessionLocalOnly: Bool = true,
        compareDoesNotMutateAssessments: Bool = true,
        operatorReviewOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        guard baselineSnapshot.snapshotHeld, followUpSnapshot.snapshotHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessAssessmentComparisonSnapshot")
        }
        let sections = ReadinessAssessmentComparisonSection.allCases
        let resolvedDeltas = sections.map { section in
            ReadinessAssessmentComparisonDelta(
                section: section,
                baselineValue: baselineSnapshot.comparisonValue(for: section),
                followUpValue: followUpSnapshot.comparisonValue(for: section)
            )
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.baselineAssessmentID = baselineSnapshot.assessmentID
        self.followUpAssessmentID = followUpSnapshot.assessmentID
        self.baselineGenerationID = baselineSnapshot.generationID
        self.followUpGenerationID = followUpSnapshot.generationID
        self.comparedAt = comparedAt
        self.comparedSections = sections
        self.changedSections = resolvedDeltas.filter { $0.deltaState == .changed }.map(\.section)
        self.unchangedSections = resolvedDeltas.filter { $0.deltaState == .unchanged }.map(\.section)
        self.deltas = resolvedDeltas
        self.hasDifferences = resolvedDeltas.contains { $0.deltaState == .changed }
        self.reportChecksum = reportChecksum ?? Self.stableReportChecksum(
            baselineAssessmentID: baselineSnapshot.assessmentID,
            followUpAssessmentID: followUpSnapshot.assessmentID,
            baselineGenerationID: baselineSnapshot.generationID,
            followUpGenerationID: followUpSnapshot.generationID,
            comparedAt: comparedAt,
            deltas: resolvedDeltas
        )
        self.assessmentSessionLocalOnly = assessmentSessionLocalOnly
        self.compareDoesNotMutateAssessments = compareDoesNotMutateAssessments
        self.operatorReviewOnly = operatorReviewOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard reportHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessAssessmentComparisonReport")
        }
    }

    public static func stableReportChecksum(
        baselineAssessmentID: Identifier,
        followUpAssessmentID: Identifier,
        baselineGenerationID: Identifier,
        followUpGenerationID: Identifier,
        comparedAt: Date,
        deltas: [ReadinessAssessmentComparisonDelta]
    ) -> String {
        stableSHA256([
            "GH-962",
            "v0.12.0",
            baselineAssessmentID.rawValue,
            followUpAssessmentID.rawValue,
            baselineGenerationID.rawValue,
            followUpGenerationID.rawValue,
            String(comparedAt.timeIntervalSince1970),
            "assessmentSessionLocalOnly=true",
            "compareDoesNotMutateAssessments=true",
            "operatorReviewOnly=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "realOrderSubmissionEnabled=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false"
        ] + deltas.map { delta in
            [
                delta.section.rawValue,
                delta.baselineValue,
                delta.followUpValue,
                delta.deltaState.rawValue,
                delta.stateReason
            ].joined(separator: "=")
        })
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReadinessAssessmentRegistryStore 提供 GH-954 的本地 assessment history 持久化入口。
///
/// Store 只操作 `.local/mtpro/readiness/registry.json`、`registry.lock` 和
/// `.local/mtpro/readiness/assessments/<assessmentID>/`。它不会启动 runtime，不读取
/// secret，不连接 endpoint / broker，也不创建 submit / cancel / replace 命令。
public struct ReadinessAssessmentRegistryStore {
    public static let defaultRelativeRoot = ".local/mtpro/readiness"
    public static let ownerOnlyDirectoryPermissions = 0o700
    public static let ownerOnlyFilePermissions = 0o600

    public let storageRootURL: URL
    public let fileManager: FileManager

    public var registryURL: URL {
        storageRootURL.appendingPathComponent("registry.json", isDirectory: false)
    }

    public var assessmentsRootURL: URL {
        storageRootURL.appendingPathComponent("assessments", isDirectory: true)
    }

    public var lockURL: URL {
        storageRootURL.appendingPathComponent("registry.lock", isDirectory: true)
    }

    public var stagingRootURL: URL {
        storageRootURL.appendingPathComponent("staging", isDirectory: true)
    }

    public init(
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL.standardizedFileURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func create(
        assessmentID: Identifier,
        state: ReadinessAssessmentRegistryState,
        sourceReleaseVersion: String,
        sourcePatchVersion: String? = nil,
        comparisonBaseAssessmentID: Identifier? = nil,
        assessedBy: String,
        reason: String,
        createdAt: Date,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryDocument {
        try withRegistryLock {
            let current = try loadIfPresent(createdAt: createdAt)
            guard current.entries.contains(where: { $0.assessmentID == assessmentID }) == false else {
                throw ReadinessAssessmentRegistryStoreError.duplicateAssessmentID(assessmentID.rawValue)
            }
            let entry = try ReadinessAssessmentRegistryEntry(
                assessmentID: assessmentID,
                state: state,
                sourceReleaseVersion: sourceReleaseVersion,
                sourcePatchVersion: sourcePatchVersion,
                comparisonBaseAssessmentID: comparisonBaseAssessmentID,
                assessedBy: assessedBy,
                reason: reason,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            try createAssessmentDirectory(for: entry)
            let next = try current.appending(entry: entry, updatedAt: updatedAt)
            try writeUnlocked(next)
            return next
        }
    }

    @discardableResult
    public func createWithTransaction(
        assessmentID: Identifier,
        transactionID: Identifier,
        generationID: Identifier,
        expectedPreviousGenerationID: Identifier?,
        state: ReadinessAssessmentRegistryState,
        sourceReleaseVersion: String,
        sourcePatchVersion: String? = nil,
        comparisonBaseAssessmentID: Identifier? = nil,
        assessedBy: String,
        reason: String,
        createdAt: Date,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryTransactionResult {
        let control = try ReadinessAssessmentTransactionControl(
            assessmentID: assessmentID,
            transactionID: transactionID,
            generationID: generationID,
            expectedPreviousGenerationID: expectedPreviousGenerationID,
            startedAt: createdAt
        )

        return try withRegistryLock {
            let current = try loadIfPresent(createdAt: createdAt)
            try createAssessmentDirectory(for: assessmentID)
            return try withAssessmentLock(assessmentID: assessmentID) {
                try createStagingDirectory(for: control)
                let manifestBeforeWrite = try loadCompareAndSwapManifestIfPresent(assessmentID: assessmentID)
                try validateGenerationTransition(
                    expectedPreviousGenerationID: expectedPreviousGenerationID,
                    actualGenerationID: manifestBeforeWrite?.currentGenerationID,
                    nextGenerationID: generationID
                )
                let entry = try ReadinessAssessmentRegistryEntry(
                    assessmentID: assessmentID,
                    state: state,
                    sourceReleaseVersion: sourceReleaseVersion,
                    sourcePatchVersion: sourcePatchVersion,
                    comparisonBaseAssessmentID: comparisonBaseAssessmentID,
                    assessedBy: assessedBy,
                    reason: reason,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
                let next = try current.appending(entry: entry, updatedAt: updatedAt)
                let manifest = try ReadinessAssessmentCompareAndSwapManifest(
                    assessmentID: assessmentID,
                    transactionID: transactionID,
                    currentGenerationID: generationID,
                    previousGenerationID: expectedPreviousGenerationID,
                    committedAt: updatedAt
                )
                let commitMarker = try ReadinessAssessmentCommitMarker(
                    assessmentID: assessmentID,
                    transactionID: transactionID,
                    generationID: generationID,
                    committedAt: updatedAt,
                    manifestChecksum: manifest.manifestChecksum
                )
                try writeJSON(control, to: transactionManifestURL(for: control))
                try writeJSON(commitMarker, to: stagingCommitMarkerURL(for: control))
                try writeUnlocked(next)
                try writeJSON(manifest, to: compareAndSwapManifestURL(for: assessmentID))
                try writeJSON(commitMarker, to: commitMarkerURL(for: assessmentID))
                try fileManager.removeItem(at: stagingDirectoryURL(for: control))
                return ReadinessAssessmentRegistryTransactionResult(
                    document: next,
                    control: control,
                    manifest: manifest,
                    commitMarker: commitMarker
                )
            }
        }
    }

    @discardableResult
    public func stageAssessmentTransaction(
        assessmentID: Identifier,
        transactionID: Identifier,
        generationID: Identifier,
        expectedPreviousGenerationID: Identifier?,
        startedAt: Date
    ) throws -> ReadinessAssessmentTransactionControl {
        let control = try ReadinessAssessmentTransactionControl(
            assessmentID: assessmentID,
            transactionID: transactionID,
            generationID: generationID,
            expectedPreviousGenerationID: expectedPreviousGenerationID,
            startedAt: startedAt
        )
        try ensureStoreDirectories()
        try createAssessmentDirectory(for: assessmentID)
        try createAssessmentLock(assessmentID: assessmentID)
        try createStagingDirectory(for: control)
        try writeJSON(control, to: transactionManifestURL(for: control))
        return control
    }

    @discardableResult
    public func abortAssessmentTransaction(
        control: ReadinessAssessmentTransactionControl,
        reason: String,
        abortedAt: Date
    ) throws -> ReadinessAssessmentTransactionAbortMarker {
        let stagingURL = stagingDirectoryURL(for: control)
        let lockURL = assessmentLockURL(for: control.assessmentID)
        let stagingRemoved = removeIfExists(stagingURL)
        let assessmentLockReleased = removeIfExists(lockURL)
        let marker = try ReadinessAssessmentTransactionAbortMarker(
            assessmentID: control.assessmentID,
            transactionID: control.transactionID,
            reason: reason,
            abortedAt: abortedAt,
            stagingRemoved: stagingRemoved,
            assessmentLockReleased: assessmentLockReleased
        )
        try writeJSON(marker, to: abortMarkerURL(for: control))
        return marker
    }

    @discardableResult
    public func recoverInterruptedTransactions(recoveredAt: Date) throws -> ReadinessAssessmentTransactionRecoveryReport {
        var recoveredStagingPaths: [String] = []
        var recoveredLockPaths: [String] = []

        if fileManager.fileExists(atPath: stagingRootURL.path) {
            let stagingChildren = try fileManager.contentsOfDirectory(
                at: stagingRootURL,
                includingPropertiesForKeys: nil
            )
            for assessmentStagingURL in stagingChildren {
                let transactionURLs = try fileManager.contentsOfDirectory(
                    at: assessmentStagingURL,
                    includingPropertiesForKeys: nil
                )
                for transactionURL in transactionURLs {
                    recoveredStagingPaths.append(relativeReadinessPath(for: transactionURL))
                }
            }
            try fileManager.removeItem(at: stagingRootURL)
        }

        if fileManager.fileExists(atPath: assessmentsRootURL.path) {
            let assessmentURLs = try fileManager.contentsOfDirectory(
                at: assessmentsRootURL,
                includingPropertiesForKeys: nil
            )
            for assessmentURL in assessmentURLs {
                let lockURL = assessmentURL.appendingPathComponent("assessment.lock", isDirectory: true)
                if fileManager.fileExists(atPath: lockURL.path) {
                    recoveredLockPaths.append(relativeReadinessPath(for: lockURL))
                    try fileManager.removeItem(at: lockURL)
                }
            }
        }

        return try ReadinessAssessmentTransactionRecoveryReport(
            recoveredAt: recoveredAt,
            recoveredStagingDirectoryPaths: recoveredStagingPaths,
            recoveredAssessmentLockPaths: recoveredLockPaths
        )
    }

    public func load() throws -> ReadinessAssessmentRegistryDocument {
        guard fileManager.fileExists(atPath: registryURL.path) else {
            throw ReadinessAssessmentRegistryStoreError.missingRegistry(registryURL.path)
        }
        return try loadExistingUnlocked()
    }

    public func listAssessments() throws -> [ReadinessAssessmentRegistryEntry] {
        try load().listAssessments()
    }

    public func inspect(assessmentID: Identifier) throws -> ReadinessAssessmentRegistryEntry {
        try load().inspect(assessmentID: assessmentID)
    }

    public func compareReadyAssessments() throws -> [ReadinessAssessmentRegistryEntry] {
        try load().compareReadyAssessments()
    }

    public func compareAssessments(
        baselineSnapshot: ReadinessAssessmentComparisonSnapshot,
        followUpSnapshot: ReadinessAssessmentComparisonSnapshot,
        comparedAt: Date
    ) throws -> ReadinessAssessmentComparisonReport {
        let before = try? load()
        let report = try ReadinessAssessmentComparisonReport(
            baselineSnapshot: baselineSnapshot,
            followUpSnapshot: followUpSnapshot,
            comparedAt: comparedAt
        )
        if let before {
            let after = try load()
            guard after == before else {
                throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessAssessmentComparisonMutatedRegistry")
            }
        }
        return report
    }

    @discardableResult
    public func writeManifestV2(_ manifest: ReadinessAssessmentManifestV2) throws -> ReadinessAssessmentManifestV2 {
        try ensureStoreDirectories()
        try createAssessmentDirectory(for: manifest.assessmentID)
        try writeJSON(manifest, to: manifestV2URL(for: manifest.assessmentID))
        return manifest
    }

    public func readManifestV2(assessmentID: Identifier) throws -> ReadinessAssessmentManifestV2 {
        let manifestURL = manifestV2URL(for: assessmentID)
        let data = try Data(contentsOf: manifestURL)
        let manifest = try Self.decoder.decode(ReadinessAssessmentManifestV2.self, from: data)
        guard manifest.assessmentID == assessmentID && manifest.manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("decodedReadinessManifestV2")
        }
        return manifest
    }

    public func validateArtifactContent(
        data: Data,
        manifest: ReadinessAssessmentManifestV2,
        policy: ReadinessAssessmentArtifactContentPolicy,
        validatedAt: Date
    ) throws -> ReadinessAssessmentArtifactContentValidationResult {
        guard manifest.manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:manifestHeld=false")
        }
        guard policy.policyHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:policyHeld=false")
        }
        guard manifest.artifactContentType == .jsonEvidence,
              policy.artifactContentType == .jsonEvidence else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:jsonEvidenceRequired")
        }

        let canonicalData = try Self.canonicalJSONData(for: data)
        let artifactChecksum = Self.sha256Checksum(for: canonicalData)
        guard artifactChecksum == manifest.artifactSHA256 else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:artifactSHA256Mismatch")
        }

        let jsonObject = try Self.jsonObject(for: canonicalData)
        let topLevelFields = try Self.topLevelJSONFields(in: jsonObject)
        let allJSONFields = Self.recursiveJSONFields(in: jsonObject)
        let allowedFields = Set(policy.allowedJSONFields)
        let requiredFields = Set(policy.requiredJSONFields)
        let observedFields = Set(topLevelFields)
        let allFields = Set(allJSONFields)
        let missingRequiredFields = policy.requiredJSONFields.filter { observedFields.contains($0) == false }
        let unexpectedFields = topLevelFields.filter { allowedFields.contains($0) == false }
        let forbiddenFields = policy.forbiddenJSONFields.filter { allFields.contains($0) }
        let forbiddenRawMarkers = Self.forbiddenRawMarkers(in: canonicalData, policy: policy)

        guard requiredFields.isSubset(of: allowedFields),
              missingRequiredFields.isEmpty,
              unexpectedFields.isEmpty,
              forbiddenFields.isEmpty,
              forbiddenRawMarkers.isEmpty else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:rejectedContent")
        }

        return try ReadinessAssessmentArtifactContentValidationResult(
            artifactID: policy.artifactID,
            policyVersion: policy.policyVersion,
            policyChecksum: policy.policyChecksum,
            artifactSHA256: artifactChecksum,
            observedTopLevelJSONFields: topLevelFields,
            validatedAt: validatedAt
        )
    }

    @discardableResult
    public func writeReadinessBundleV2ReviewSnapshot(
        _ bundle: ReadinessAssessmentBundleV2
    ) throws -> ReadinessAssessmentBundleV2SnapshotWriteResult {
        guard bundle.bundleHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2:bundleHeld=false")
        }
        guard bundle.reviewState == .inReview else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2:reviewStateMustBeInReview")
        }

        try ensureStoreDirectories()
        try createAssessmentDirectory(for: bundle.assessmentID)
        let bundleURL = readinessBundleV2URL(assessmentID: bundle.assessmentID, generationID: bundle.generationID)
        let manifestURL = readinessBundleV2ManifestURL(assessmentID: bundle.assessmentID, generationID: bundle.generationID)

        if fileManager.fileExists(atPath: bundleURL.path) || fileManager.fileExists(atPath: manifestURL.path) {
            let existing = try readReadinessBundleV2(
                assessmentID: bundle.assessmentID,
                generationID: bundle.generationID
            )
            if existing.reviewState == .inReview {
                throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessBundleV2:generationImmutable")
            }
        }

        let bundleData = try Self.encoder.encode(bundle)
        let manifest = try ReadinessAssessmentBundleV2Manifest(
            assessmentID: bundle.assessmentID,
            generationID: bundle.generationID,
            bundleChecksum: bundle.bundleChecksum,
            bundleJSONSHA256: Self.sha256Checksum(for: bundleData),
            bundleBytes: bundleData.count,
            createdAt: bundle.createdAt,
            producerVersion: bundle.producerVersion
        )
        try writeData(bundleData, to: bundleURL)
        try writeJSON(manifest, to: manifestURL)
        return ReadinessAssessmentBundleV2SnapshotWriteResult(bundle: bundle, manifest: manifest)
    }

    public func readReadinessBundleV2(
        assessmentID: Identifier,
        generationID: Identifier
    ) throws -> ReadinessAssessmentBundleV2 {
        let data = try Data(contentsOf: readinessBundleV2URL(assessmentID: assessmentID, generationID: generationID))
        let bundle = try Self.decoder.decode(ReadinessAssessmentBundleV2.self, from: data)
        guard bundle.assessmentID == assessmentID,
              bundle.generationID == generationID,
              bundle.bundleHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("decodedReadinessBundleV2")
        }
        return bundle
    }

    public func readReadinessBundleV2Manifest(
        assessmentID: Identifier,
        generationID: Identifier
    ) throws -> ReadinessAssessmentBundleV2Manifest {
        let data = try Data(contentsOf: readinessBundleV2ManifestURL(assessmentID: assessmentID, generationID: generationID))
        let manifest = try Self.decoder.decode(ReadinessAssessmentBundleV2Manifest.self, from: data)
        guard manifest.assessmentID == assessmentID,
              manifest.generationID == generationID,
              manifest.manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("decodedReadinessBundleV2Manifest")
        }
        return manifest
    }

    @discardableResult
    public func archive(
        assessmentID: Identifier,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryDocument {
        try mutate(updatedAt: updatedAt) { document in
            let entry = try document.inspect(assessmentID: assessmentID)
            guard entry.lifecycle != .archived else {
                throw ReadinessAssessmentRegistryStoreError.cannotMutateArchivedAssessment(assessmentID.rawValue)
            }
            return try entry.archived(at: updatedAt)
        }
    }

    @discardableResult
    public func recover(
        assessmentID: Identifier,
        reason: String,
        updatedAt: Date
    ) throws -> ReadinessAssessmentRegistryDocument {
        try mutate(updatedAt: updatedAt) { document in
            let entry = try document.inspect(assessmentID: assessmentID)
            guard entry.lifecycle != .archived else {
                throw ReadinessAssessmentRegistryStoreError.cannotMutateArchivedAssessment(assessmentID.rawValue)
            }
            return try entry.recovered(reason: reason, at: updatedAt)
        }
    }

    public static func deterministicFixture(
        createdAt: Date = Date(timeIntervalSince1970: 1_812_000_000),
        updatedAt: Date = Date(timeIntervalSince1970: 1_812_000_120)
    ) throws -> ReadinessAssessmentRegistryDocument {
        try ReadinessAssessmentRegistryDocument(
            entries: [
                ReadinessAssessmentRegistryEntry(
                    assessmentID: Identifier.constant("gh-954-baseline"),
                    state: .baseline,
                    sourceReleaseVersion: "v0.11.0",
                    sourcePatchVersion: "v0.11.1",
                    assessedBy: "Codex",
                    reason: "baseline assessment imported from v0.11.x facts",
                    createdAt: createdAt,
                    updatedAt: updatedAt
                ),
                ReadinessAssessmentRegistryEntry(
                    assessmentID: Identifier.constant("gh-954-follow-up"),
                    state: .compareReady,
                    sourceReleaseVersion: "v0.12.0",
                    sourcePatchVersion: nil,
                    comparisonBaseAssessmentID: Identifier.constant("gh-954-baseline"),
                    assessedBy: "Codex",
                    reason: "follow-up assessment ready for local diff",
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            ],
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    @discardableResult
    private func mutate(
        updatedAt: Date,
        transform: (ReadinessAssessmentRegistryDocument) throws -> ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessAssessmentRegistryDocument {
        try withRegistryLock {
            let current = try loadExistingUnlocked()
            let entry = try transform(current)
            try createAssessmentDirectory(for: entry)
            let next = try current.replacing(entry: entry, updatedAt: updatedAt)
            try writeUnlocked(next)
            return next
        }
    }

    private func loadIfPresent(createdAt: Date) throws -> ReadinessAssessmentRegistryDocument {
        if fileManager.fileExists(atPath: registryURL.path) {
            return try loadExistingUnlocked()
        }
        return try ReadinessAssessmentRegistryDocument(
            entries: [],
            createdAt: createdAt,
            updatedAt: createdAt
        )
    }

    private func loadExistingUnlocked() throws -> ReadinessAssessmentRegistryDocument {
        do {
            let data = try Data(contentsOf: registryURL)
            let document = try Self.decoder.decode(ReadinessAssessmentRegistryDocument.self, from: data)
            let expectedChecksum = ReadinessAssessmentRegistryDocument.stableRegistryChecksum(
                entries: document.entries,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
            guard document.registryChecksum == expectedChecksum else {
                throw ReadinessAssessmentRegistryStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.registryChecksum
                )
            }
            guard document.documentHeld else {
                throw ReadinessAssessmentRegistryStoreError.boundaryDrift("decodedRegistryDocument")
            }
            return document
        } catch let error as ReadinessAssessmentRegistryStoreError {
            throw error
        } catch {
            throw ReadinessAssessmentRegistryStoreError.corruptedRegistry(registryURL.path)
        }
    }

    private func withRegistryLock<T>(_ operation: () throws -> T) throws -> T {
        do {
            try fileManager.createDirectory(
                at: storageRootURL,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
            )
            try fileManager.setAttributes(
                [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
                ofItemAtPath: storageRootURL.path
            )
            try fileManager.createDirectory(
                at: assessmentsRootURL,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
            )
            try fileManager.setAttributes(
                [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
                ofItemAtPath: assessmentsRootURL.path
            )
            try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
        } catch {
            throw ReadinessAssessmentRegistryStoreError.lockUnavailable(lockURL.path)
        }
        defer {
            try? fileManager.removeItem(at: lockURL)
        }
        return try operation()
    }

    private func createAssessmentDirectory(for entry: ReadinessAssessmentRegistryEntry) throws {
        try createAssessmentDirectory(for: entry.assessmentID)
    }

    private func createAssessmentDirectory(for assessmentID: Identifier) throws {
        let directoryURL = storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(assessmentID.rawValue, isDirectory: true)
            .standardizedFileURL
        guard directoryURL.path.hasPrefix(assessmentsRootURL.standardizedFileURL.path + "/") else {
            throw ReadinessAssessmentRegistryStoreError.unsafeAssessmentID(assessmentID.rawValue)
        }
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
            ofItemAtPath: directoryURL.path
        )
    }

    private func ensureStoreDirectories() throws {
        try fileManager.createDirectory(
            at: storageRootURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
            ofItemAtPath: storageRootURL.path
        )
        try fileManager.createDirectory(
            at: assessmentsRootURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
            ofItemAtPath: assessmentsRootURL.path
        )
    }

    private func withAssessmentLock<T>(
        assessmentID: Identifier,
        operation: () throws -> T
    ) throws -> T {
        try createAssessmentLock(assessmentID: assessmentID)
        defer {
            try? fileManager.removeItem(at: assessmentLockURL(for: assessmentID))
        }
        return try operation()
    }

    private func createAssessmentLock(assessmentID: Identifier) throws {
        let lockURL = assessmentLockURL(for: assessmentID)
        do {
            try fileManager.createDirectory(
                at: lockURL,
                withIntermediateDirectories: false,
                attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
            )
        } catch {
            throw ReadinessAssessmentRegistryStoreError.lockUnavailable(relativeReadinessPath(for: lockURL))
        }
    }

    private func createStagingDirectory(for control: ReadinessAssessmentTransactionControl) throws {
        let stagingURL = stagingDirectoryURL(for: control)
        guard fileManager.fileExists(atPath: stagingURL.path) == false else {
            throw ReadinessAssessmentRegistryStoreError.transactionAlreadyExists(control.transactionID.rawValue)
        }
        try fileManager.createDirectory(
            at: stagingURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyDirectoryPermissions],
            ofItemAtPath: stagingURL.path
        )
    }

    private func loadCompareAndSwapManifestIfPresent(
        assessmentID: Identifier
    ) throws -> ReadinessAssessmentCompareAndSwapManifest? {
        let manifestURL = compareAndSwapManifestURL(for: assessmentID)
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: manifestURL)
        let manifest = try Self.decoder.decode(ReadinessAssessmentCompareAndSwapManifest.self, from: data)
        guard manifest.manifestHeld else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("decodedCompareAndSwapManifest")
        }
        return manifest
    }

    private func validateGenerationTransition(
        expectedPreviousGenerationID: Identifier?,
        actualGenerationID: Identifier?,
        nextGenerationID: Identifier
    ) throws {
        guard expectedPreviousGenerationID?.rawValue == actualGenerationID?.rawValue else {
            throw ReadinessAssessmentRegistryStoreError.concurrentModification(
                expected: expectedPreviousGenerationID?.rawValue ?? "<none>",
                actual: actualGenerationID?.rawValue ?? "<none>"
            )
        }
        guard expectedPreviousGenerationID?.rawValue != nextGenerationID.rawValue else {
            throw ReadinessAssessmentRegistryStoreError.generationMismatch(
                expected: "new generation different from \(expectedPreviousGenerationID?.rawValue ?? "<none>")",
                actual: nextGenerationID.rawValue
            )
        }
    }

    private func assessmentDirectoryURL(for assessmentID: Identifier) -> URL {
        assessmentsRootURL.appendingPathComponent(assessmentID.rawValue, isDirectory: true)
    }

    private func assessmentLockURL(for assessmentID: Identifier) -> URL {
        assessmentDirectoryURL(for: assessmentID).appendingPathComponent("assessment.lock", isDirectory: true)
    }

    private func stagingDirectoryURL(for control: ReadinessAssessmentTransactionControl) -> URL {
        stagingRootURL
            .appendingPathComponent(control.assessmentID.rawValue, isDirectory: true)
            .appendingPathComponent(control.transactionID.rawValue, isDirectory: true)
    }

    private func transactionManifestURL(for control: ReadinessAssessmentTransactionControl) -> URL {
        stagingDirectoryURL(for: control).appendingPathComponent("transaction-manifest.json", isDirectory: false)
    }

    private func stagingCommitMarkerURL(for control: ReadinessAssessmentTransactionControl) -> URL {
        stagingDirectoryURL(for: control).appendingPathComponent("commit-marker.json", isDirectory: false)
    }

    private func compareAndSwapManifestURL(for assessmentID: Identifier) -> URL {
        assessmentDirectoryURL(for: assessmentID).appendingPathComponent(
            "compare-and-swap-manifest.json",
            isDirectory: false
        )
    }

    private func commitMarkerURL(for assessmentID: Identifier) -> URL {
        assessmentDirectoryURL(for: assessmentID).appendingPathComponent("commit-marker.json", isDirectory: false)
    }

    private func manifestV2URL(for assessmentID: Identifier) -> URL {
        assessmentDirectoryURL(for: assessmentID).appendingPathComponent("manifest-v2.json", isDirectory: false)
    }

    private func generationDirectoryURL(assessmentID: Identifier, generationID: Identifier) -> URL {
        assessmentDirectoryURL(for: assessmentID)
            .appendingPathComponent("generations", isDirectory: true)
            .appendingPathComponent(generationID.rawValue, isDirectory: true)
    }

    private func readinessBundleV2URL(assessmentID: Identifier, generationID: Identifier) -> URL {
        generationDirectoryURL(assessmentID: assessmentID, generationID: generationID)
            .appendingPathComponent("readiness-bundle-v2.json", isDirectory: false)
    }

    private func readinessBundleV2ManifestURL(assessmentID: Identifier, generationID: Identifier) -> URL {
        generationDirectoryURL(assessmentID: assessmentID, generationID: generationID)
            .appendingPathComponent("readiness-bundle-v2.manifest.json", isDirectory: false)
    }

    private func abortMarkerURL(for control: ReadinessAssessmentTransactionControl) -> URL {
        assessmentDirectoryURL(for: control.assessmentID).appendingPathComponent(
            "abort-marker-\(control.transactionID.rawValue).json",
            isDirectory: false
        )
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try Self.encoder.encode(value)
        try writeData(data, to: url)
    }

    private func writeData(_ data: Data, to url: URL) throws {
        let parentURL = url.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        try data.write(to: url, options: .atomic)
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyFilePermissions],
            ofItemAtPath: url.path
        )
    }

    private func removeIfExists(_ url: URL) -> Bool {
        guard fileManager.fileExists(atPath: url.path) else {
            return true
        }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }

    private func relativeReadinessPath(for url: URL) -> String {
        let rootPath = storageRootURL.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        guard path.hasPrefix(rootPath) else {
            return path
        }
        let suffix = String(path.dropFirst(rootPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return suffix.isEmpty ? Self.defaultRelativeRoot : "\(Self.defaultRelativeRoot)/\(suffix)"
    }

    private func writeUnlocked(_ document: ReadinessAssessmentRegistryDocument) throws {
        let data = try Self.encoder.encode(document)
        let temporaryURL = registryURL.appendingPathExtension("tmp")
        try data.write(to: temporaryURL, options: .atomic)
        try fileManager.setAttributes(
            [.posixPermissions: Self.ownerOnlyFilePermissions],
            ofItemAtPath: temporaryURL.path
        )
        if fileManager.fileExists(atPath: registryURL.path) {
            try fileManager.removeItem(at: registryURL)
        }
        try fileManager.moveItem(at: temporaryURL, to: registryURL)
    }

    private static func canonicalJSONData(for data: Data) throws -> Data {
        let object = try jsonObject(for: data)
        guard JSONSerialization.isValidJSONObject(object) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:invalidJSON")
        }
        do {
            return try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
        } catch {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:invalidJSON")
        }
    }

    private static func jsonObject(for data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data)
        } catch {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:invalidJSON")
        }
    }

    private static func topLevelJSONFields(in object: Any) throws -> [String] {
        guard let dictionary = object as? [String: Any] else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("artifactContentPolicy:topLevelObjectRequired")
        }
        return dictionary.keys.sorted()
    }

    private static func recursiveJSONFields(in object: Any) -> [String] {
        if let dictionary = object as? [String: Any] {
            return dictionary.keys.sorted() + dictionary.values.flatMap { recursiveJSONFields(in: $0) }
        }
        if let array = object as? [Any] {
            return array.flatMap { recursiveJSONFields(in: $0) }
        }
        return []
    }

    private static func forbiddenRawMarkers(
        in data: Data,
        policy: ReadinessAssessmentArtifactContentPolicy
    ) -> [String] {
        guard let payload = String(data: data, encoding: .utf8) else {
            return ["nonUTF8Payload"]
        }
        let loweredPayload = payload.lowercased()
        return policy.forbiddenRawMarkers.filter { marker in
            loweredPayload.contains(marker.lowercased())
        }
    }

    private static func sha256Checksum(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
