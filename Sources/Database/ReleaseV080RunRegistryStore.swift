import Crypto
import DomainModel
import Foundation

/// ReleaseV080RunRegistryStoreError 描述 GH-809 持久化 run registry store 的本地文件错误。
///
/// 错误只覆盖 `.local/mtpro/runs/registry.json`、registry lock、checksum、
/// list / inspect / archive / recover 语义和 fail-closed 读取；不表达 endpoint、
/// secret、broker adapter、OMS production runtime 或任何订单能力。
public enum ReleaseV080RunRegistryStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case duplicateRunID(String)
    case missingRunID(String)
    case missingRegistry(String)
    case corruptedRegistry(String)
    case checksumMismatch(expected: String, actual: String)
    case cannotMutateArchivedRun(String)
    case lockUnavailable(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.8.0 run registry store requires a non-empty runID"
        case let .duplicateRunID(runID):
            "Release v0.8.0 run registry store rejects duplicate runID \(runID)"
        case let .missingRunID(runID):
            "Release v0.8.0 run registry store cannot find runID \(runID)"
        case let .missingRegistry(path):
            "Release v0.8.0 run registry store fails closed because registry is missing at \(path)"
        case let .corruptedRegistry(path):
            "Release v0.8.0 run registry store fails closed because registry is corrupted at \(path)"
        case let .checksumMismatch(expected, actual):
            "Release v0.8.0 run registry store checksum mismatch: expected \(expected), actual \(actual)"
        case let .cannotMutateArchivedRun(runID):
            "Release v0.8.0 run registry store rejects archived run mutation for \(runID)"
        case let .lockUnavailable(path):
            "Release v0.8.0 run registry store lock is unavailable at \(path)"
        case let .boundaryDrift(field):
            "Release v0.8.0 run registry store boundary drift: \(field)"
        }
    }
}

/// ReleaseV080RunRegistryStoreContract 固定 GH-809 的验证锚点和命令。
public enum ReleaseV080RunRegistryStoreContract {
    public static let requiredValidationAnchors: [String] = [
        "GH-809-VERIFY-V080-RUN-REGISTRY-STORE",
        "TVM-RELEASE-V080-RUN-REGISTRY-STORE",
        "V080-003-RUN-REGISTRY-STORE",
        "V080-003-REGISTRY-JSON-PATH",
        "V080-003-REGISTRY-LOCK",
        "V080-003-REGISTRY-CHECKSUM",
        "V080-003-LIST-INSPECT-ARCHIVE-RECOVER",
        "V080-003-MISSING-CORRUPTED-FAILS-CLOSED",
        "V080-003-NO-PRODUCTION-BROKER-ORDER-FIELDS"
    ]

    public static let requiredValidationCommands: [String] = [
        "bash checks/verify-v0.8.0-run-registry-store.sh",
        "swift test --filter TargetGraphTests/testGH809RunRegistryStorePersistsRegistryJSONChecksumAndFailClosedStates"
    ]
}

/// ReleaseV080RunRegistryState 固定 GH-809 可持久化 run state。
///
/// `failed` 与 `incomplete` 是本地 fail-closed 状态；它们不触发 recovery，
/// 不启动 runtime，也不打开 broker / order path。
public enum ReleaseV080RunRegistryState: String, Codable, CaseIterable, Equatable, Sendable {
    case created
    case running
    case stopped
    case failed
    case completed
    case recovered
    case incomplete
}

/// ReleaseV080RunRegistryLifecycle 固定 GH-809 registry entry 的本地 lifecycle。
public enum ReleaseV080RunRegistryLifecycle: String, Codable, CaseIterable, Equatable, Sendable {
    case active
    case archived
    case recoveryEvidence
}

/// ReleaseV080RunRegistryArtifactPaths 是 registry entry 保存的本地 artifact path 清单。
///
/// 路径只指向 `.local/mtpro/runs/<runID>/...` 下的本地证据文件，不能保存
/// secret value、listenKey value、broker command payload 或 order request payload。
public struct ReleaseV080RunRegistryArtifactPaths: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let eventsJSONLPath: String
    public let manifestJSONPath: String
    public let statusJSONPath: String
    public let operatorSessionStoreJSONPath: String
    public let reconciliationReviewJSONPath: String
    public let riskPolicyProfileJSONPath: String
    public let dashboardReadonlySnapshotJSONPath: String

    public var pathsHeld: Bool {
        runDirectoryPath.hasPrefix(".local/mtpro/runs/")
            && eventsJSONLPath == "\(runDirectoryPath)/events.jsonl"
            && manifestJSONPath == "\(runDirectoryPath)/manifest.json"
            && statusJSONPath == "\(runDirectoryPath)/status.json"
            && operatorSessionStoreJSONPath == "\(runDirectoryPath)/operator-session-store.json"
            && reconciliationReviewJSONPath == "\(runDirectoryPath)/reconciliation-review.json"
            && riskPolicyProfileJSONPath == "\(runDirectoryPath)/risk-policy-profile.json"
            && dashboardReadonlySnapshotJSONPath == "\(runDirectoryPath)/dashboard-readonly-snapshot.json"
    }

    public init(runID: Identifier) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080RunRegistryStoreError.emptyRunID
        }
        let runDirectoryPath = ".local/mtpro/runs/\(runID.rawValue)"
        self.runDirectoryPath = runDirectoryPath
        self.eventsJSONLPath = "\(runDirectoryPath)/events.jsonl"
        self.manifestJSONPath = "\(runDirectoryPath)/manifest.json"
        self.statusJSONPath = "\(runDirectoryPath)/status.json"
        self.operatorSessionStoreJSONPath = "\(runDirectoryPath)/operator-session-store.json"
        self.reconciliationReviewJSONPath = "\(runDirectoryPath)/reconciliation-review.json"
        self.riskPolicyProfileJSONPath = "\(runDirectoryPath)/risk-policy-profile.json"
        self.dashboardReadonlySnapshotJSONPath = "\(runDirectoryPath)/dashboard-readonly-snapshot.json"

        guard pathsHeld else {
            throw ReleaseV080RunRegistryStoreError.boundaryDrift("artifactPaths")
        }
    }
}

/// ReleaseV080RunRegistryEntry 是 `registry.json` 中的单条 run metadata。
///
/// Entry 记录 runID、state、artifact paths、lifecycle、timestamps 和 entryChecksum。
/// 所有 production / broker / order 授权字段必须保持 false。
public struct ReleaseV080RunRegistryEntry: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let state: ReleaseV080RunRegistryState
    public let lifecycle: ReleaseV080RunRegistryLifecycle
    public let artifactPaths: ReleaseV080RunRegistryArtifactPaths
    public let createdAt: Date
    public let updatedAt: Date
    public let failureReason: String?
    public let recoveryReason: String?
    public let entryChecksum: String
    public let persistentLocalRuntime: Bool
    public let noOrder: Bool
    public let testnetReadOnlyMonitoringAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var entryHeld: Bool {
        issueID.rawValue == "GH-809"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-807", "GH-808"]
            && releaseVersion == "v0.8.0"
            && runID.rawValue.isEmpty == false
            && artifactPaths.pathsHeld
            && createdAt <= updatedAt
            && (lifecycle == .archived ? state != .running : true)
            && (lifecycle == .recoveryEvidence ? state == .recovered : true)
            && entryChecksum == Self.stableEntryChecksum(
                runID: runID,
                state: state,
                lifecycle: lifecycle,
                artifactPaths: artifactPaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                failureReason: failureReason,
                recoveryReason: recoveryReason
            )
            && persistentLocalRuntime
            && noOrder
            && testnetReadOnlyMonitoringAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-809"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-807"), Identifier.constant("GH-808")],
        releaseVersion: String = "v0.8.0",
        runID: Identifier,
        state: ReleaseV080RunRegistryState,
        lifecycle: ReleaseV080RunRegistryLifecycle = .active,
        artifactPaths: ReleaseV080RunRegistryArtifactPaths? = nil,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String? = nil,
        recoveryReason: String? = nil,
        entryChecksum: String? = nil,
        persistentLocalRuntime: Bool = true,
        noOrder: Bool = true,
        testnetReadOnlyMonitoringAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080RunRegistryStoreError.emptyRunID
        }
        let resolvedPaths = try artifactPaths ?? ReleaseV080RunRegistryArtifactPaths(runID: runID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.state = state
        self.lifecycle = lifecycle
        self.artifactPaths = resolvedPaths
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.failureReason = failureReason
        self.recoveryReason = recoveryReason
        self.entryChecksum = entryChecksum ?? Self.stableEntryChecksum(
            runID: runID,
            state: state,
            lifecycle: lifecycle,
            artifactPaths: resolvedPaths,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
        self.persistentLocalRuntime = persistentLocalRuntime
        self.noOrder = noOrder
        self.testnetReadOnlyMonitoringAllowed = testnetReadOnlyMonitoringAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard entryHeld else {
            throw ReleaseV080RunRegistryStoreError.boundaryDrift("registryEntry")
        }
    }

    public func archived(at updatedAt: Date) throws -> ReleaseV080RunRegistryEntry {
        try ReleaseV080RunRegistryEntry(
            runID: runID,
            state: state == .running ? .stopped : state,
            lifecycle: .archived,
            artifactPaths: artifactPaths,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
    }

    public func recovered(reason: String, at updatedAt: Date) throws -> ReleaseV080RunRegistryEntry {
        try ReleaseV080RunRegistryEntry(
            runID: runID,
            state: .recovered,
            lifecycle: .recoveryEvidence,
            artifactPaths: artifactPaths,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: reason
        )
    }

    public static func stableEntryChecksum(
        runID: Identifier,
        state: ReleaseV080RunRegistryState,
        lifecycle: ReleaseV080RunRegistryLifecycle,
        artifactPaths: ReleaseV080RunRegistryArtifactPaths,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String?,
        recoveryReason: String?
    ) -> String {
        stableSHA256([
            "GH-809",
            "v0.8.0",
            runID.rawValue,
            state.rawValue,
            lifecycle.rawValue,
            artifactPaths.runDirectoryPath,
            artifactPaths.eventsJSONLPath,
            artifactPaths.manifestJSONPath,
            artifactPaths.statusJSONPath,
            artifactPaths.operatorSessionStoreJSONPath,
            artifactPaths.reconciliationReviewJSONPath,
            artifactPaths.riskPolicyProfileJSONPath,
            artifactPaths.dashboardReadonlySnapshotJSONPath,
            String(createdAt.timeIntervalSince1970),
            String(updatedAt.timeIntervalSince1970),
            failureReason ?? "",
            recoveryReason ?? "",
            "persistentLocalRuntime=true",
            "noOrder=true",
            "testnetReadOnlyMonitoringAllowed=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
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

/// ReleaseV080RunRegistryDocument 是 `.local/mtpro/runs/registry.json` 的顶层 payload。
public struct ReleaseV080RunRegistryDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.run-registry-store.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let registryPath: String
    public let lockPath: String
    public let entries: [ReleaseV080RunRegistryEntry]
    public let createdAt: Date
    public let updatedAt: Date
    public let registryChecksum: String
    public let missingOrCorruptedRegistryFailsClosed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var documentHeld: Bool {
        issueID.rawValue == "GH-809"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-807", "GH-808"]
            && releaseVersion == "v0.8.0"
            && schemaVersion == Self.schemaVersion
            && registryPath == ".local/mtpro/runs/registry.json"
            && lockPath == ".local/mtpro/runs/registry.lock"
            && entries.isEmpty == false
            && entries.allSatisfy(\.entryHeld)
            && Set(entries.map(\.runID.rawValue)).count == entries.count
            && entries.map(\.runID.rawValue) == entries.map(\.runID.rawValue).sorted()
            && createdAt <= updatedAt
            && registryChecksum == Self.stableRegistryChecksum(
                entries: entries,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            && missingOrCorruptedRegistryFailsClosed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-809"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-807"), Identifier.constant("GH-808")],
        releaseVersion: String = "v0.8.0",
        schemaVersion: String = Self.schemaVersion,
        registryPath: String = ".local/mtpro/runs/registry.json",
        lockPath: String = ".local/mtpro/runs/registry.lock",
        entries: [ReleaseV080RunRegistryEntry],
        createdAt: Date,
        updatedAt: Date,
        registryChecksum: String? = nil,
        missingOrCorruptedRegistryFailsClosed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        let sortedEntries = entries.sorted { $0.runID.rawValue < $1.runID.rawValue }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.registryPath = registryPath
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
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        try Self.validateEntries(sortedEntries)
        guard documentHeld else {
            throw ReleaseV080RunRegistryStoreError.boundaryDrift("registryDocument")
        }
    }

    public func replacing(
        entry: ReleaseV080RunRegistryEntry,
        updatedAt: Date
    ) throws -> ReleaseV080RunRegistryDocument {
        var nextEntries = entries
        guard let index = nextEntries.firstIndex(where: { $0.runID == entry.runID }) else {
            throw ReleaseV080RunRegistryStoreError.missingRunID(entry.runID.rawValue)
        }
        nextEntries[index] = entry
        return try ReleaseV080RunRegistryDocument(
            entries: nextEntries,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    public func listRuns() -> [ReleaseV080RunRegistryEntry] {
        entries
    }

    public func inspect(runID: Identifier) throws -> ReleaseV080RunRegistryEntry {
        guard let entry = entries.first(where: { $0.runID == runID }) else {
            throw ReleaseV080RunRegistryStoreError.missingRunID(runID.rawValue)
        }
        return entry
    }

    public static func stableRegistryChecksum(
        entries: [ReleaseV080RunRegistryEntry],
        createdAt: Date,
        updatedAt: Date
    ) -> String {
        stableSHA256([
            "GH-809",
            "v0.8.0",
            Self.schemaVersion,
            ".local/mtpro/runs/registry.json",
            ".local/mtpro/runs/registry.lock",
            String(createdAt.timeIntervalSince1970),
            String(updatedAt.timeIntervalSince1970)
        ] + entries.sorted { $0.runID.rawValue < $1.runID.rawValue }.map(\.entryChecksum))
    }

    private static func validateEntries(
        _ entries: [ReleaseV080RunRegistryEntry]
    ) throws {
        var runIDs = Set<String>()
        for entry in entries {
            guard runIDs.insert(entry.runID.rawValue).inserted else {
                throw ReleaseV080RunRegistryStoreError.duplicateRunID(entry.runID.rawValue)
            }
            guard entry.entryHeld else {
                throw ReleaseV080RunRegistryStoreError.boundaryDrift("registryEntry")
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

/// ReleaseV080RunRegistryStore 提供 GH-809 的本地持久化读写入口。
///
/// Store 只操作 `.local/mtpro/runs/registry.json` 和 `registry.lock`；它不会启动
/// runtime，不读取 secret，不连接网络，不调用 broker，也不创建订单。
public struct ReleaseV080RunRegistryStore {
    public let storageRootURL: URL
    public let fileManager: FileManager

    public var registryURL: URL {
        storageRootURL.appendingPathComponent("registry.json", isDirectory: false)
    }

    public var lockURL: URL {
        storageRootURL.appendingPathComponent("registry.lock", isDirectory: true)
    }

    public init(
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func save(
        entries: [ReleaseV080RunRegistryEntry],
        createdAt: Date,
        updatedAt: Date
    ) throws -> ReleaseV080RunRegistryDocument {
        try withRegistryLock {
            let document = try ReleaseV080RunRegistryDocument(
                entries: entries,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            try writeUnlocked(document)
            return document
        }
    }

    public func load() throws -> ReleaseV080RunRegistryDocument {
        guard fileManager.fileExists(atPath: registryURL.path) else {
            throw ReleaseV080RunRegistryStoreError.missingRegistry(registryURL.path)
        }
        do {
            let data = try Data(contentsOf: registryURL)
            let document = try Self.decoder.decode(ReleaseV080RunRegistryDocument.self, from: data)
            let expectedChecksum = ReleaseV080RunRegistryDocument.stableRegistryChecksum(
                entries: document.entries,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
            guard document.registryChecksum == expectedChecksum else {
                throw ReleaseV080RunRegistryStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.registryChecksum
                )
            }
            guard document.documentHeld else {
                throw ReleaseV080RunRegistryStoreError.boundaryDrift("decodedRegistryDocument")
            }
            return document
        } catch let error as ReleaseV080RunRegistryStoreError {
            throw error
        } catch {
            throw ReleaseV080RunRegistryStoreError.corruptedRegistry(registryURL.path)
        }
    }

    public func listRuns() throws -> [ReleaseV080RunRegistryEntry] {
        try load().listRuns()
    }

    public func inspect(runID: Identifier) throws -> ReleaseV080RunRegistryEntry {
        try load().inspect(runID: runID)
    }

    @discardableResult
    public func archive(
        runID: Identifier,
        updatedAt: Date
    ) throws -> ReleaseV080RunRegistryDocument {
        try mutate(updatedAt: updatedAt) { document in
            let entry = try document.inspect(runID: runID)
            guard entry.lifecycle != .archived else {
                throw ReleaseV080RunRegistryStoreError.cannotMutateArchivedRun(runID.rawValue)
            }
            return try entry.archived(at: updatedAt)
        }
    }

    @discardableResult
    public func recover(
        runID: Identifier,
        reason: String,
        updatedAt: Date
    ) throws -> ReleaseV080RunRegistryDocument {
        try mutate(updatedAt: updatedAt) { document in
            let entry = try document.inspect(runID: runID)
            guard entry.lifecycle != .archived else {
                throw ReleaseV080RunRegistryStoreError.cannotMutateArchivedRun(runID.rawValue)
            }
            return try entry.recovered(reason: reason, at: updatedAt)
        }
    }

    public static func deterministicFixture(
        createdAt: Date = Date(timeIntervalSince1970: 1_781_000_000),
        updatedAt: Date = Date(timeIntervalSince1970: 1_781_000_120)
    ) throws -> ReleaseV080RunRegistryDocument {
        try ReleaseV080RunRegistryDocument(
            entries: [
                ReleaseV080RunRegistryEntry(
                    runID: Identifier.constant("gh-809-run-alpha"),
                    state: .running,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                ),
                ReleaseV080RunRegistryEntry(
                    runID: Identifier.constant("gh-809-run-beta"),
                    state: .incomplete,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    failureReason: "manifest-missing-fails-closed"
                ),
                ReleaseV080RunRegistryEntry(
                    runID: Identifier.constant("gh-809-run-gamma"),
                    state: .failed,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    failureReason: "registry-recovery-required"
                )
            ],
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    @discardableResult
    private func mutate(
        updatedAt: Date,
        transform: (ReleaseV080RunRegistryDocument) throws -> ReleaseV080RunRegistryEntry
    ) throws -> ReleaseV080RunRegistryDocument {
        try withRegistryLock {
            let current = try load()
            let entry = try transform(current)
            let next = try current.replacing(entry: entry, updatedAt: updatedAt)
            try writeUnlocked(next)
            return next
        }
    }

    private func withRegistryLock<T>(_ operation: () throws -> T) throws -> T {
        do {
            try fileManager.createDirectory(
                at: storageRootURL,
                withIntermediateDirectories: true
            )
            try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
        } catch {
            throw ReleaseV080RunRegistryStoreError.lockUnavailable(lockURL.path)
        }
        defer {
            try? fileManager.removeItem(at: lockURL)
        }
        return try operation()
    }

    private func writeUnlocked(_ document: ReleaseV080RunRegistryDocument) throws {
        let data = try Self.encoder.encode(document)
        let temporaryURL = registryURL.appendingPathExtension("tmp")
        try data.write(to: temporaryURL, options: .atomic)
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
