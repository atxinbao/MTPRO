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
        "V0120-004-NO-PRODUCTION-CUTOVER"
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

    private func abortMarkerURL(for control: ReadinessAssessmentTransactionControl) -> URL {
        assessmentDirectoryURL(for: control.assessmentID).appendingPathComponent(
            "abort-marker-\(control.transactionID.rawValue).json",
            isDirectory: false
        )
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let parentURL = url.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: Self.ownerOnlyDirectoryPermissions]
        )
        let data = try Self.encoder.encode(value)
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
