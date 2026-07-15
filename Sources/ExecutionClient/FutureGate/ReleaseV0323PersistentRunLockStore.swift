import Crypto
import Foundation

// GH-1537-IMPLEMENT-ATOMIC-PERSISTENT-RUN-LOCK-REGISTRY
// TVM-RELEASE-V0323-PERSISTENT-RUN-LOCK-REGISTRY
// V0323-003-PERSISTENT-RUN-LOCK-REGISTRY

public enum ReleaseV0323PersistentRunLockState: String, Codable, Equatable, Sendable {
    case active
    case released
    case staleRecovered = "stale-recovered"
}

public struct ReleaseV0323PersistentRunLockRecord: Codable, Equatable, Sendable {
    public let runID: String
    public let ownerID: String
    public let nonce: String
    public let sourceCommit: String
    public let acquiredAtEpochSeconds: Int
    public let state: ReleaseV0323PersistentRunLockState
    public let releasedAtEpochSeconds: Int?
    public let recoveredByOwnerID: String?

    public init(
        runID: String,
        ownerID: String,
        nonce: String,
        sourceCommit: String,
        acquiredAtEpochSeconds: Int,
        state: ReleaseV0323PersistentRunLockState,
        releasedAtEpochSeconds: Int? = nil,
        recoveredByOwnerID: String? = nil
    ) {
        self.runID = runID
        self.ownerID = ownerID
        self.nonce = nonce
        self.sourceCommit = sourceCommit
        self.acquiredAtEpochSeconds = acquiredAtEpochSeconds
        self.state = state
        self.releasedAtEpochSeconds = releasedAtEpochSeconds
        self.recoveredByOwnerID = recoveredByOwnerID
    }
}

private struct ReleaseV0323PersistentRunLockRegistryPayload: Codable, Equatable {
    let schemaVersion: String
    let records: [ReleaseV0323PersistentRunLockRecord]
}

public struct ReleaseV0323PersistentRunLockRegistryDocument: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let records: [ReleaseV0323PersistentRunLockRecord]
    public let registrySHA256: String

    public init(records: [ReleaseV0323PersistentRunLockRecord]) throws {
        self.schemaVersion = "v0323-persistent-run-lock-registry-v1"
        self.records = records.sorted { $0.runID < $1.runID }
        self.registrySHA256 = try Self.checksum(schemaVersion: schemaVersion, records: self.records)
    }

    public var checksumHeld: Bool {
        (try? Self.checksum(schemaVersion: schemaVersion, records: records)) == registrySHA256
    }

    private static func checksum(
        schemaVersion: String,
        records: [ReleaseV0323PersistentRunLockRecord]
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(
            ReleaseV0323PersistentRunLockRegistryPayload(
                schemaVersion: schemaVersion,
                records: records
            )
        )
        return "sha256:" + SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

public enum ReleaseV0323PersistentRunLockStoreError: Error, Equatable, Sendable {
    case unsafeIdentity(String)
    case registryTransactionUnavailable
    case runLockUnavailable(String)
    case duplicateRunID(String)
    case duplicateNonce(String)
    case replayRejected(String)
    case missingRegistry
    case corruptedRegistry
    case missingRun(String)
    case missingOwnerRecord(String)
    case wrongOwner(expected: String, actual: String)
    case wrongNonce
    case lockNotStale(String)
}

public struct ReleaseV0323PersistentRunLockStore: Sendable {
    public static let validationAnchor = "TVM-RELEASE-V0323-PERSISTENT-RUN-LOCK-REGISTRY"

    public let storageRoot: URL

    public init(storageRoot: URL) {
        self.storageRoot = storageRoot.standardizedFileURL
    }

    private var fileManager: FileManager { .default }

    public func acquire(
        runID: String,
        ownerID: String,
        nonce: String,
        sourceCommit: String,
        acquiredAtEpochSeconds: Int
    ) throws -> ReleaseV0323PersistentRunLockRecord {
        try validateIdentity(runID)
        try validateIdentity(ownerID)
        try validateIdentity(nonce)
        guard ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit) else {
            throw ReleaseV0323PersistentRunLockStoreError.unsafeIdentity(sourceCommit)
        }

        return try withRegistryTransaction {
            var records = try loadRecords(createIfMissing: true)
            if let existing = records.first(where: { $0.runID == runID }) {
                if existing.state == .active {
                    throw ReleaseV0323PersistentRunLockStoreError.duplicateRunID(runID)
                }
                throw ReleaseV0323PersistentRunLockStoreError.replayRejected(runID)
            }
            guard records.contains(where: { $0.nonce == nonce }) == false else {
                throw ReleaseV0323PersistentRunLockStoreError.duplicateNonce(nonce)
            }

            let lockURL = runLockURL(runID: runID)
            do {
                try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
            } catch {
                throw ReleaseV0323PersistentRunLockStoreError.runLockUnavailable(runID)
            }

            let record = ReleaseV0323PersistentRunLockRecord(
                runID: runID,
                ownerID: ownerID,
                nonce: nonce,
                sourceCommit: sourceCommit,
                acquiredAtEpochSeconds: acquiredAtEpochSeconds,
                state: .active
            )
            do {
                try writeOwnerRecord(record, at: lockURL)
                records.append(record)
                try save(records: records)
                return record
            } catch {
                try? fileManager.removeItem(at: lockURL)
                throw error
            }
        }
    }

    public func release(
        runID: String,
        ownerID: String,
        nonce: String,
        releasedAtEpochSeconds: Int
    ) throws -> ReleaseV0323PersistentRunLockRecord {
        try withRegistryTransaction {
            var records = try loadRecords(createIfMissing: false)
            guard let index = records.firstIndex(where: { $0.runID == runID }) else {
                throw ReleaseV0323PersistentRunLockStoreError.missingRun(runID)
            }
            let persisted = records[index]
            guard persisted.state == .active else {
                throw ReleaseV0323PersistentRunLockStoreError.replayRejected(runID)
            }
            let owner = try loadOwnerRecord(runID: runID)
            guard owner.ownerID == ownerID, persisted.ownerID == ownerID else {
                throw ReleaseV0323PersistentRunLockStoreError.wrongOwner(
                    expected: persisted.ownerID,
                    actual: ownerID
                )
            }
            guard owner.nonce == nonce, persisted.nonce == nonce else {
                throw ReleaseV0323PersistentRunLockStoreError.wrongNonce
            }

            let released = ReleaseV0323PersistentRunLockRecord(
                runID: persisted.runID,
                ownerID: persisted.ownerID,
                nonce: persisted.nonce,
                sourceCommit: persisted.sourceCommit,
                acquiredAtEpochSeconds: persisted.acquiredAtEpochSeconds,
                state: .released,
                releasedAtEpochSeconds: releasedAtEpochSeconds
            )
            try fileManager.removeItem(at: runLockURL(runID: runID))
            records[index] = released
            try save(records: records)
            return released
        }
    }

    public func recoverStaleLock(
        runID: String,
        requestingOwnerID: String,
        recoveredAtEpochSeconds: Int,
        staleAfterSeconds: Int
    ) throws -> ReleaseV0323PersistentRunLockRecord {
        try validateIdentity(requestingOwnerID)
        return try withRegistryTransaction {
            var records = try loadRecords(createIfMissing: false)
            guard let index = records.firstIndex(where: { $0.runID == runID }) else {
                throw ReleaseV0323PersistentRunLockStoreError.missingRun(runID)
            }
            let persisted = records[index]
            guard persisted.state == .active,
                  staleAfterSeconds >= 0,
                  recoveredAtEpochSeconds - persisted.acquiredAtEpochSeconds > staleAfterSeconds
            else {
                throw ReleaseV0323PersistentRunLockStoreError.lockNotStale(runID)
            }
            let owner = try loadOwnerRecord(runID: runID)
            guard owner.ownerID == persisted.ownerID else {
                throw ReleaseV0323PersistentRunLockStoreError.wrongOwner(
                    expected: persisted.ownerID,
                    actual: owner.ownerID
                )
            }
            guard owner.nonce == persisted.nonce else {
                throw ReleaseV0323PersistentRunLockStoreError.wrongNonce
            }

            let recovered = ReleaseV0323PersistentRunLockRecord(
                runID: persisted.runID,
                ownerID: persisted.ownerID,
                nonce: persisted.nonce,
                sourceCommit: persisted.sourceCommit,
                acquiredAtEpochSeconds: persisted.acquiredAtEpochSeconds,
                state: .staleRecovered,
                releasedAtEpochSeconds: recoveredAtEpochSeconds,
                recoveredByOwnerID: requestingOwnerID
            )
            try fileManager.removeItem(at: runLockURL(runID: runID))
            records[index] = recovered
            try save(records: records)
            return recovered
        }
    }

    public func replayRecord(runID: String) throws -> ReleaseV0323PersistentRunLockRecord {
        let records = try loadRecords(createIfMissing: false)
        guard let record = records.first(where: { $0.runID == runID }) else {
            throw ReleaseV0323PersistentRunLockStoreError.missingRun(runID)
        }
        return record
    }

    public func registryDocument() throws -> ReleaseV0323PersistentRunLockRegistryDocument {
        let data: Data
        do {
            data = try Data(contentsOf: registryURL)
        } catch {
            throw ReleaseV0323PersistentRunLockStoreError.missingRegistry
        }
        do {
            let document = try JSONDecoder().decode(ReleaseV0323PersistentRunLockRegistryDocument.self, from: data)
            guard document.schemaVersion == "v0323-persistent-run-lock-registry-v1",
                  document.checksumHeld
            else {
                throw ReleaseV0323PersistentRunLockStoreError.corruptedRegistry
            }
            return document
        } catch let error as ReleaseV0323PersistentRunLockStoreError {
            throw error
        } catch {
            throw ReleaseV0323PersistentRunLockStoreError.corruptedRegistry
        }
    }

    private var registryURL: URL {
        storageRoot.appendingPathComponent("registry.json")
    }

    private var locksRootURL: URL {
        storageRoot.appendingPathComponent("locks", isDirectory: true)
    }

    private var registryTransactionLockURL: URL {
        storageRoot.appendingPathComponent("registry-write.lock", isDirectory: true)
    }

    private func runLockURL(runID: String) -> URL {
        locksRootURL.appendingPathComponent("\(runID).lock", isDirectory: true)
    }

    private func withRegistryTransaction<T>(_ body: () throws -> T) throws -> T {
        try fileManager.createDirectory(at: storageRoot, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: locksRootURL, withIntermediateDirectories: true)
        do {
            try fileManager.createDirectory(at: registryTransactionLockURL, withIntermediateDirectories: false)
        } catch {
            throw ReleaseV0323PersistentRunLockStoreError.registryTransactionUnavailable
        }
        defer { try? fileManager.removeItem(at: registryTransactionLockURL) }
        return try body()
    }

    private func loadRecords(createIfMissing: Bool) throws -> [ReleaseV0323PersistentRunLockRecord] {
        if fileManager.fileExists(atPath: registryURL.path) == false {
            guard createIfMissing else {
                throw ReleaseV0323PersistentRunLockStoreError.missingRegistry
            }
            return []
        }
        return try registryDocument().records
    }

    private func save(records: [ReleaseV0323PersistentRunLockRecord]) throws {
        let document = try ReleaseV0323PersistentRunLockRegistryDocument(records: records)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(document).write(to: registryURL, options: .atomic)
    }

    private func writeOwnerRecord(_ record: ReleaseV0323PersistentRunLockRecord, at lockURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(record).write(to: lockURL.appendingPathComponent("owner.json"), options: .atomic)
    }

    private func loadOwnerRecord(runID: String) throws -> ReleaseV0323PersistentRunLockRecord {
        do {
            return try JSONDecoder().decode(
                ReleaseV0323PersistentRunLockRecord.self,
                from: Data(contentsOf: runLockURL(runID: runID).appendingPathComponent("owner.json"))
            )
        } catch {
            throw ReleaseV0323PersistentRunLockStoreError.missingOwnerRecord(runID)
        }
    }

    private func validateIdentity(_ value: String) throws {
        guard value.isEmpty == false,
              value != ".",
              value != "..",
              value.contains("/") == false,
              value.contains("\\") == false,
              value.hasPrefix("~") == false
        else {
            throw ReleaseV0323PersistentRunLockStoreError.unsafeIdentity(value)
        }
    }
}
