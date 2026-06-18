import DomainModel
import Foundation

/// ProductionReadinessArtifactStoreAnchors 固定 GH-914 的源码级验证锚点。
///
/// 这些锚点只证明本地 artifact store 已具备可审计边界；它们不授权 production cutover、
/// secret read、endpoint connection、broker connection 或任何订单命令。
public enum ProductionReadinessArtifactStoreAnchors {
    public static let validationAnchors = [
        "GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE",
        "TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE",
        "V0110-002-PRODUCTION-READINESS-ARTIFACT-STORE",
        "V0110-002-LOCAL-EVIDENCE-ROOT",
        "V0110-002-ARTIFACT-STATES",
        "V0110-002-READ-WRITE-PRIMITIVES",
        "V0110-002-NO-PRODUCTION-SECRET-ENDPOINT-ORDER"
    ]
}

/// ProductionReadinessArtifactStoreError 描述 GH-914 本地 readiness artifact store 的失败类型。
///
/// 这些错误只覆盖本地 evidence root、relative path、JSON payload 和 forbidden capability
/// flag；它们不表示 production secret、endpoint、broker session 或订单路径可以被解析或访问。
public enum ProductionReadinessArtifactStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case nonFileRoot(String)
    case emptyArtifactID
    case unsafeRelativePath(String)
    case emptyPayload(String)
    case invalidJSON(String)
    case forbiddenCapability(String)
    case missingArtifact(String)

    public var description: String {
        switch self {
        case let .nonFileRoot(path):
            "GH-914 ProductionReadinessArtifactStore requires a local file root, got \(path)"
        case .emptyArtifactID:
            "GH-914 ProductionReadinessArtifactStore requires a non-empty artifactID"
        case let .unsafeRelativePath(path):
            "GH-914 ProductionReadinessArtifactStore rejects unsafe relative path \(path)"
        case let .emptyPayload(path):
            "GH-914 ProductionReadinessArtifactStore rejects empty payload at \(path)"
        case let .invalidJSON(path):
            "GH-914 ProductionReadinessArtifactStore cannot decode JSON evidence at \(path)"
        case let .forbiddenCapability(flag):
            "GH-914 ProductionReadinessArtifactStore rejects forbidden production capability \(flag)"
        case let .missingArtifact(path):
            "GH-914 ProductionReadinessArtifactStore cannot read missing artifact \(path)"
        }
    }
}

/// ProductionReadinessArtifactState 固定 GH-914 本地 artifact 的四种可审计状态。
///
/// `missing`、`invalid`、`stale`、`valid` 都是本地文件状态，不会转换为 production
/// cutover authorization，也不会触发 secret read、endpoint connect 或 order command。
public enum ProductionReadinessArtifactState: String, Codable, CaseIterable, Equatable, Sendable {
    case missing
    case invalid
    case stale
    case valid
}

/// ProductionReadinessArtifactType 固定 GH-914 store 当前允许的本地 evidence 类型。
public enum ProductionReadinessArtifactType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case jsonEvidence
    case textEvidence
}

/// ProductionReadinessArtifactDescriptor 描述单个 readiness artifact 在本地 store 中的位置和验证方式。
///
/// Descriptor 只接受相对路径，拒绝绝对路径、`..`、空路径和隐藏目录逃逸。这样 store
/// 只能在 approved local evidence root 下读写本地 artifact，不能被误用为任意文件访问器。
public struct ProductionReadinessArtifactDescriptor: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let relativePath: String
    public let artifactType: ProductionReadinessArtifactType
    public let required: Bool
    public let staleAfterSeconds: TimeInterval?

    public var descriptorHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && Self.isSafeRelativePath(relativePath)
            && (staleAfterSeconds == nil || staleAfterSeconds ?? 0 > 0)
    }

    public init(
        artifactID: Identifier,
        relativePath: String,
        artifactType: ProductionReadinessArtifactType,
        required: Bool = true,
        staleAfterSeconds: TimeInterval? = nil
    ) throws {
        guard artifactID.rawValue.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.emptyArtifactID
        }
        guard Self.isSafeRelativePath(relativePath) else {
            throw ProductionReadinessArtifactStoreError.unsafeRelativePath(relativePath)
        }
        if let staleAfterSeconds {
            guard staleAfterSeconds > 0 else {
                throw ProductionReadinessArtifactStoreError.unsafeRelativePath(relativePath)
            }
        }
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.artifactType = artifactType
        self.required = required
        self.staleAfterSeconds = staleAfterSeconds
    }

    public static func isSafeRelativePath(_ path: String) -> Bool {
        guard path.isEmpty == false else {
            return false
        }
        guard path.hasPrefix("/") == false else {
            return false
        }
        guard path.contains("\\") == false else {
            return false
        }
        let components = path.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard components.isEmpty == false else {
            return false
        }
        return components.allSatisfy { component in
            component.isEmpty == false
                && component != "."
                && component != ".."
                && component.hasPrefix("~") == false
        }
    }
}

/// ProductionReadinessArtifactRecord 是 GH-914 artifact inspect / write / read 的统一结果。
///
/// Record 固定 production capability flags 为 false，用来证明本地 artifact store 没有读取
/// production secret、没有连接 endpoint / broker、没有构造 testnet 或 production order payload。
public struct ProductionReadinessArtifactRecord: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let descriptor: ProductionReadinessArtifactDescriptor
    public let absolutePath: String
    public let state: ProductionReadinessArtifactState
    public let byteCount: Int
    public let modifiedAt: Date?
    public let stateReason: String
    public let redactionProof: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let localFileURLOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var recordHeld: Bool {
        issueID.rawValue == "GH-914"
            && releaseVersion == "v0.11.0"
            && descriptor.descriptorHeld
            && absolutePath.isEmpty == false
            && stateReason.isEmpty == false
            && byteCount >= 0
            && stateByteCountHeld
            && redactionProof
            && noSecretValue
            && noOrderPayload
            && localFileURLOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    private var stateByteCountHeld: Bool {
        switch state {
        case .missing:
            byteCount == 0 && modifiedAt == nil
        case .invalid:
            byteCount >= 0
        case .stale, .valid:
            byteCount > 0 && modifiedAt != nil
        }
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-914"),
        releaseVersion: String = "v0.11.0",
        descriptor: ProductionReadinessArtifactDescriptor,
        absolutePath: String,
        state: ProductionReadinessArtifactState,
        byteCount: Int,
        modifiedAt: Date?,
        stateReason: String,
        redactionProof: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        localFileURLOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.descriptor = descriptor
        self.absolutePath = absolutePath
        self.state = state
        self.byteCount = byteCount
        self.modifiedAt = modifiedAt
        self.stateReason = stateReason
        self.redactionProof = redactionProof
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.localFileURLOnly = localFileURLOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard recordHeld else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("recordHeld=false")
        }
    }
}

/// ProductionReadinessArtifactReadResult 汇总本地 artifact 读取结果。
public struct ProductionReadinessArtifactReadResult: Equatable, Sendable {
    public let record: ProductionReadinessArtifactRecord
    public let data: Data

    public var readHeld: Bool {
        record.state == .valid && record.recordHeld && data.isEmpty == false
    }
}

/// ProductionReadinessArtifactStoreSnapshot 是 GH-914 多 artifact inspect 的只读快照。
public struct ProductionReadinessArtifactStoreSnapshot: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let evidenceRootPath: String
    public let records: [ProductionReadinessArtifactRecord]
    public let missingCount: Int
    public let invalidCount: Int
    public let staleCount: Int
    public let validCount: Int
    public let productionCutoverAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var snapshotHeld: Bool {
        issueID.rawValue == "GH-914"
            && releaseVersion == "v0.11.0"
            && evidenceRootPath.isEmpty == false
            && records.allSatisfy(\.recordHeld)
            && missingCount == records.filter { $0.state == .missing }.count
            && invalidCount == records.filter { $0.state == .invalid }.count
            && staleCount == records.filter { $0.state == .stale }.count
            && validCount == records.filter { $0.state == .valid }.count
            && productionCutoverAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-914"),
        releaseVersion: String = "v0.11.0",
        evidenceRootPath: String,
        records: [ProductionReadinessArtifactRecord],
        productionCutoverAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.evidenceRootPath = evidenceRootPath
        self.records = records
        self.missingCount = records.filter { $0.state == .missing }.count
        self.invalidCount = records.filter { $0.state == .invalid }.count
        self.staleCount = records.filter { $0.state == .stale }.count
        self.validCount = records.filter { $0.state == .valid }.count
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard snapshotHeld else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("snapshotHeld=false")
        }
    }
}

/// ProductionReadinessArtifactStore 是 GH-914 的本地 readiness evidence artifact store。
///
/// Store 只在 approved local evidence root 下创建目录、写入 artifact、读取 artifact 和检查
/// missing / invalid / stale / valid 状态。它没有 endpoint client、secret provider、broker
/// adapter、OMS runtime 或 submit / cancel / replace command surface。
public struct ProductionReadinessArtifactStore {
    public static let defaultRelativeRoot = ".local/mtpro/readiness/v0.11.0"

    public let evidenceRootURL: URL
    private let fileManager: FileManager

    public init(
        evidenceRootURL: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(defaultRelativeRoot, isDirectory: true),
        fileManager: FileManager = .default
    ) throws {
        guard evidenceRootURL.isFileURL else {
            throw ProductionReadinessArtifactStoreError.nonFileRoot(evidenceRootURL.absoluteString)
        }
        self.evidenceRootURL = evidenceRootURL.standardizedFileURL
        self.fileManager = fileManager
    }

    public func artifactURL(for descriptor: ProductionReadinessArtifactDescriptor) throws -> URL {
        guard descriptor.descriptorHeld else {
            throw ProductionReadinessArtifactStoreError.unsafeRelativePath(descriptor.relativePath)
        }
        var url = evidenceRootURL
        for component in descriptor.relativePath.split(separator: "/").map(String.init) {
            url.appendPathComponent(component, isDirectory: false)
        }
        let standardized = url.standardizedFileURL
        guard standardized.path.hasPrefix(evidenceRootURL.path + "/") else {
            throw ProductionReadinessArtifactStoreError.unsafeRelativePath(descriptor.relativePath)
        }
        return standardized
    }

    @discardableResult
    public func writeArtifact(
        descriptor: ProductionReadinessArtifactDescriptor,
        data: Data,
        modifiedAt: Date = Date(),
        containsSecretValue: Bool = false,
        containsOrderPayload: Bool = false,
        producedByEndpointConnection: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws -> ProductionReadinessArtifactRecord {
        let url = try artifactURL(for: descriptor)
        guard data.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.emptyPayload(url.path)
        }
        try validateForbiddenInputs(
            data: data,
            descriptor: descriptor,
            containsSecretValue: containsSecretValue,
            containsOrderPayload: containsOrderPayload,
            producedByEndpointConnection: producedByEndpointConnection,
            productionCutoverAuthorized: productionCutoverAuthorized
        )
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
        try fileManager.setAttributes([.modificationDate: modifiedAt], ofItemAtPath: url.path)
        return try inspectArtifact(descriptor, now: modifiedAt)
    }

    @discardableResult
    public func writeStringArtifact(
        descriptor: ProductionReadinessArtifactDescriptor,
        string: String,
        modifiedAt: Date = Date(),
        containsSecretValue: Bool = false,
        containsOrderPayload: Bool = false,
        producedByEndpointConnection: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws -> ProductionReadinessArtifactRecord {
        try writeArtifact(
            descriptor: descriptor,
            data: Data(string.utf8),
            modifiedAt: modifiedAt,
            containsSecretValue: containsSecretValue,
            containsOrderPayload: containsOrderPayload,
            producedByEndpointConnection: producedByEndpointConnection,
            productionCutoverAuthorized: productionCutoverAuthorized
        )
    }

    public func readArtifact(
        descriptor: ProductionReadinessArtifactDescriptor,
        now: Date = Date()
    ) throws -> ProductionReadinessArtifactReadResult {
        let record = try inspectArtifact(descriptor, now: now)
        guard record.state == .valid else {
            throw ProductionReadinessArtifactStoreError.missingArtifact(record.absolutePath)
        }
        let data = try Data(contentsOf: try artifactURL(for: descriptor))
        let result = ProductionReadinessArtifactReadResult(record: record, data: data)
        guard result.readHeld else {
            throw ProductionReadinessArtifactStoreError.invalidJSON(record.absolutePath)
        }
        return result
    }

    public func inspectArtifact(
        _ descriptor: ProductionReadinessArtifactDescriptor,
        now: Date = Date()
    ) throws -> ProductionReadinessArtifactRecord {
        let url = try artifactURL(for: descriptor)
        guard fileManager.fileExists(atPath: url.path) else {
            return try record(
                descriptor: descriptor,
                url: url,
                state: .missing,
                byteCount: 0,
                modifiedAt: nil,
                stateReason: "missing artifact"
            )
        }
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue == false else {
            return try record(
                descriptor: descriptor,
                url: url,
                state: .invalid,
                byteCount: 0,
                modifiedAt: nil,
                stateReason: "artifact path is a directory"
            )
        }
        let data = try Data(contentsOf: url)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let modifiedAt = attributes[.modificationDate] as? Date
        guard data.isEmpty == false else {
            return try record(
                descriptor: descriptor,
                url: url,
                state: .invalid,
                byteCount: data.count,
                modifiedAt: modifiedAt,
                stateReason: "empty artifact payload"
            )
        }
        guard forbiddenTrueFlags(in: data).isEmpty else {
            return try record(
                descriptor: descriptor,
                url: url,
                state: .invalid,
                byteCount: data.count,
                modifiedAt: modifiedAt,
                stateReason: "forbidden production capability flag"
            )
        }
        if descriptor.artifactType == .jsonEvidence {
            do {
                _ = try JSONSerialization.jsonObject(with: data)
            } catch {
                return try record(
                    descriptor: descriptor,
                    url: url,
                    state: .invalid,
                    byteCount: data.count,
                    modifiedAt: modifiedAt,
                    stateReason: "invalid JSON evidence"
                )
            }
        }
        if let staleAfterSeconds = descriptor.staleAfterSeconds,
           let modifiedAt,
           now.timeIntervalSince(modifiedAt) > staleAfterSeconds {
            return try record(
                descriptor: descriptor,
                url: url,
                state: .stale,
                byteCount: data.count,
                modifiedAt: modifiedAt,
                stateReason: "artifact stale"
            )
        }
        return try record(
            descriptor: descriptor,
            url: url,
            state: .valid,
            byteCount: data.count,
            modifiedAt: modifiedAt,
            stateReason: "artifact valid"
        )
    }

    public func inspectArtifacts(
        _ descriptors: [ProductionReadinessArtifactDescriptor],
        now: Date = Date()
    ) throws -> ProductionReadinessArtifactStoreSnapshot {
        let records = try descriptors.map { try inspectArtifact($0, now: now) }
        return try ProductionReadinessArtifactStoreSnapshot(
            evidenceRootPath: evidenceRootURL.path,
            records: records
        )
    }

    private func validateForbiddenInputs(
        data: Data,
        descriptor: ProductionReadinessArtifactDescriptor,
        containsSecretValue: Bool,
        containsOrderPayload: Bool,
        producedByEndpointConnection: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        guard containsSecretValue == false else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("containsSecretValue")
        }
        guard containsOrderPayload == false else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("containsOrderPayload")
        }
        guard producedByEndpointConnection == false else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("producedByEndpointConnection")
        }
        guard productionCutoverAuthorized == false else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("productionCutoverAuthorized")
        }
        let forbiddenFlags = forbiddenTrueFlags(in: data)
        guard forbiddenFlags.isEmpty else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability(forbiddenFlags.joined(separator: ","))
        }
        if descriptor.artifactType == .jsonEvidence {
            do {
                _ = try JSONSerialization.jsonObject(with: data)
            } catch {
                throw ProductionReadinessArtifactStoreError.invalidJSON(descriptor.relativePath)
            }
        }
    }

    private func forbiddenTrueFlags(in data: Data) -> [String] {
        guard let payload = String(data: data, encoding: .utf8) else {
            return ["nonUTF8Payload"]
        }
        return Self.forbiddenTrueFlags.filter { payload.contains($0) }
    }

    private func record(
        descriptor: ProductionReadinessArtifactDescriptor,
        url: URL,
        state: ProductionReadinessArtifactState,
        byteCount: Int,
        modifiedAt: Date?,
        stateReason: String
    ) throws -> ProductionReadinessArtifactRecord {
        try ProductionReadinessArtifactRecord(
            descriptor: descriptor,
            absolutePath: url.path,
            state: state,
            byteCount: byteCount,
            modifiedAt: modifiedAt,
            stateReason: stateReason
        )
    }

    public static let forbiddenTrueFlags = [
        trueFlag("productionTradingEnabledByDefault"),
        trueFlag("productionCutoverAuthorized"),
        trueFlag("productionSecretRead"),
        trueFlag("productionEndpointConnected"),
        trueFlag("brokerEndpointConnected"),
        trueFlag("productionBrokerConnected"),
        trueFlag("productionOrderSubmitted"),
        trueFlag("realOrderSubmissionEnabled"),
        trueFlag("testnetOrderSubmissionAllowed"),
        trueFlag("testnetOrderRoutingAllowed"),
        trueFlag("productionOMSImplemented"),
        trueFlag("tradingButtonEnabled"),
        trueFlag("orderFormEnabled"),
        trueFlag("liveCommandEnabled")
    ]

    private static func trueFlag(_ name: String) -> String {
        name + "=" + "true"
    }
}
