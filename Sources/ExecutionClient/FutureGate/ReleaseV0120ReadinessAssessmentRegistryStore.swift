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
        "V0120-003-NO-PRODUCTION-CUTOVER"
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
        let directoryURL = storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(entry.assessmentID.rawValue, isDirectory: true)
            .standardizedFileURL
        guard directoryURL.path.hasPrefix(assessmentsRootURL.standardizedFileURL.path + "/") else {
            throw ReadinessAssessmentRegistryStoreError.unsafeAssessmentID(entry.assessmentID.rawValue)
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
