import DomainModel
import Crypto
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

/// ProductionReadinessManifestAnchors 固定 GH-915 的 manifest schema / atomic IO 验证锚点。
///
/// GH-915 只把 v0.11.0 readiness evidence 升级为可校验的本地 manifest，不授权
/// production endpoint、secret provider、broker adapter 或任何 submit / cancel / replace 命令。
public enum ProductionReadinessManifestAnchors {
    public static let validationAnchors = [
        "GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO",
        "TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO",
        "V0110-003-READINESS-MANIFEST-SCHEMA",
        "V0110-003-ATOMIC-JSON-ARTIFACT-IO",
        "V0110-003-MANIFEST-POLICY-VERSION",
        "V0110-003-MANIFEST-ENTRY-STATE-VALIDATION",
        "V0110-003-EVIDENCE-EXISTS-IS-NOT-SUFFICIENT"
    ]
}

/// ProductionReadinessCanonicalChecksumAnchors 固定 GH-916 的 canonical JSON SHA256 验证锚点。
///
/// GH-916 只替换本地 readiness artifact / manifest 的完整性 checksum policy，不新增
/// endpoint、secret、broker、OMS 或任何 submit / cancel / replace 命令路径。
public enum ProductionReadinessCanonicalChecksumAnchors {
    public static let validationAnchors = [
        "GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM",
        "TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM",
        "V0110-004-CANONICAL-JSON-SHA256",
        "V0110-004-CHECKSUM-FORMAT-VALIDATION",
        "V0110-004-CHECKSUM-MISMATCH-FAILS-CLOSED",
        "V0110-004-NO-PLACEHOLDER-CHECKSUMS"
    ]
}

/// ProductionReadinessBundleValidationAnchors 固定 GH-917 的 bundle validation 验证锚点。
///
/// GH-917 只读取本地 manifest 与本地 artifact，归类 bundle integrity state；它不读取
/// production secret、不连接 endpoint / broker、不提交订单，也不把 valid bundle 转换成 cutover 授权。
public enum ProductionReadinessBundleValidationAnchors {
    public static let validationAnchors = [
        "GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION",
        "TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION",
        "V0110-005-READINESS-BUNDLE-VALIDATION",
        "V0110-005-REQUIRED-ARTIFACT-SET",
        "V0110-005-BUNDLE-VALIDATION-STATES",
        "V0110-005-POLICY-VERSION-BLOCKED",
        "V0110-005-CHECKSUM-MISMATCH-STATE",
        "V0110-005-NO-PRODUCTION-CUTOVER"
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
    case invalidManifest(String)
    case manifestPolicyMismatch(expected: String, actual: String)
    case manifestEntryRejected(String)
    case invalidChecksumFormat(String)
    case checksumMismatch(String)

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
        case let .invalidManifest(reason):
            "GH-915 ProductionReadinessManifest rejects invalid manifest: \(reason)"
        case let .manifestPolicyMismatch(expected, actual):
            "GH-915 ProductionReadinessManifest expected policy \(expected), got \(actual)"
        case let .manifestEntryRejected(reason):
            "GH-915 ProductionReadinessManifest rejects entry: \(reason)"
        case let .invalidChecksumFormat(checksum):
            "GH-916 ProductionReadinessManifest rejects invalid checksum format \(checksum)"
        case let .checksumMismatch(path):
            "GH-916 ProductionReadinessManifest checksum mismatch for \(path)"
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

/// ProductionReadinessManifestEntry 是 GH-915 manifest 中单个 readiness artifact 的 schema。
///
/// Entry 必须绑定真实 artifact path、type、size、checksum、createdAt、policyVersion 和
/// validationState。`evidenceExists` 只是审计字段，读取 manifest 时仍会重新 inspect / read 本地
/// artifact；不能因为该字段为 true 就把 missing / stale / malformed artifact 视为有效。
public struct ProductionReadinessManifestEntry: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let relativePath: String
    public let artifactType: ProductionReadinessArtifactType
    public let staleAfterSeconds: TimeInterval?
    public let size: Int
    public let checksum: String
    public let createdAt: Date
    public let policyVersion: String
    public let validationState: ProductionReadinessArtifactState
    public let evidenceExists: Bool
    public let stateReason: String

    public var entryHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath)
            && (staleAfterSeconds == nil || staleAfterSeconds ?? 0 > 0)
            && size > 0
            && ProductionReadinessArtifactStore.isValidSHA256Checksum(checksum)
            && policyVersion.isEmpty == false
            && validationState == .valid
            && evidenceExists
            && stateReason == "artifact valid"
    }

    public init(
        artifactID: Identifier,
        relativePath: String,
        artifactType: ProductionReadinessArtifactType,
        staleAfterSeconds: TimeInterval? = nil,
        size: Int,
        checksum: String,
        createdAt: Date,
        policyVersion: String,
        validationState: ProductionReadinessArtifactState,
        evidenceExists: Bool,
        stateReason: String
    ) throws {
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.artifactType = artifactType
        self.staleAfterSeconds = staleAfterSeconds
        self.size = size
        self.checksum = checksum
        self.createdAt = createdAt
        self.policyVersion = policyVersion
        self.validationState = validationState
        self.evidenceExists = evidenceExists
        self.stateReason = stateReason

        guard entryHeld else {
            throw ProductionReadinessArtifactStoreError.manifestEntryRejected("entryHeld=false")
        }
    }

    public init(
        record: ProductionReadinessArtifactRecord,
        data: Data,
        policyVersion: String,
        createdAt: Date
    ) throws {
        try self.init(
            artifactID: record.descriptor.artifactID,
            relativePath: record.descriptor.relativePath,
            artifactType: record.descriptor.artifactType,
            staleAfterSeconds: record.descriptor.staleAfterSeconds,
            size: data.count,
            checksum: try ProductionReadinessArtifactStore.canonicalJSONSHA256Checksum(for: data),
            createdAt: createdAt,
            policyVersion: policyVersion,
            validationState: record.state,
            evidenceExists: record.state == .valid,
            stateReason: record.stateReason
        )
    }
}

/// ProductionReadinessManifest 是 GH-915 的 readiness manifest schema。
///
/// Manifest 只描述本地 readiness evidence artifact 的完整性，不携带 secret、endpoint、
/// broker session 或订单命令。所有 production capability flags 必须固定为 false。
public struct ProductionReadinessManifest: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let manifestID: Identifier
    public let policyVersion: String
    public let generatedAt: Date
    public let entries: [ProductionReadinessManifestEntry]
    public let atomicWriteRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-915"
            && releaseVersion == "v0.11.0"
            && manifestID.rawValue.isEmpty == false
            && policyVersion.isEmpty == false
            && entries.isEmpty == false
            && entries.allSatisfy(\.entryHeld)
            && entries.allSatisfy { $0.policyVersion == policyVersion }
            && atomicWriteRequired
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-915"),
        releaseVersion: String = "v0.11.0",
        manifestID: Identifier,
        policyVersion: String,
        generatedAt: Date,
        entries: [ProductionReadinessManifestEntry],
        atomicWriteRequired: Bool = true,
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
        self.manifestID = manifestID
        self.policyVersion = policyVersion
        self.generatedAt = generatedAt
        self.entries = entries
        self.atomicWriteRequired = atomicWriteRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard manifestHeld else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("manifestHeld=false")
        }
    }
}

/// ProductionReadinessManifestReadResult 绑定 manifest JSON payload、manifest record 和 decoded schema。
public struct ProductionReadinessManifestReadResult: Equatable, Sendable {
    public let manifest: ProductionReadinessManifest
    public let record: ProductionReadinessArtifactRecord
    public let data: Data

    public var manifestReadHeld: Bool {
        manifest.manifestHeld
            && record.recordHeld
            && record.state == .valid
            && data.isEmpty == false
    }
}

/// ProductionReadinessBundleValidationState 是 GH-917 的 bundle-level readiness 结果。
///
/// 这些状态只描述本地 evidence bundle 是否可审计。`valid` 也不代表 production cutover、
/// endpoint readiness、secret readiness 或订单授权。
public enum ProductionReadinessBundleValidationState: String, Codable, CaseIterable, Equatable, Sendable {
    case notEvaluated = "not-evaluated"
    case valid
    case blocked
    case stale
    case missing
    case invalid
    case checksumMismatch = "checksum-mismatch"
}

/// ProductionReadinessBundleValidationResult 汇总 GH-917 bundle validation 的只读证据。
///
/// Result 固定 production capability flags 为 false，并记录 required artifact set 与实际
/// manifest entries。它只由本地 artifact / manifest / checksum 推导，不访问任何外部生产系统。
public struct ProductionReadinessBundleValidationResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let policyVersion: String
    public let state: ProductionReadinessBundleValidationState
    public let requiredArtifactIDs: [Identifier]
    public let manifestArtifactIDs: [Identifier]
    public let missingRequiredArtifactIDs: [Identifier]
    public let unexpectedArtifactIDs: [Identifier]
    public let validatedAt: Date
    public let stateReason: String
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var resultHeld: Bool {
        issueID.rawValue == "GH-917"
            && releaseVersion == "v0.11.0"
            && policyVersion.isEmpty == false
            && requiredArtifactIDs.isEmpty == false
            && requiredArtifactIDs.allSatisfy { $0.rawValue.isEmpty == false }
            && manifestArtifactIDs.allSatisfy { $0.rawValue.isEmpty == false }
            && stateReason.isEmpty == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
            && validStateHeld
    }

    public var bundleValidHeld: Bool {
        resultHeld
            && state == .valid
            && missingRequiredArtifactIDs.isEmpty
            && unexpectedArtifactIDs.isEmpty
            && Set(requiredArtifactIDs.map(\.rawValue)) == Set(manifestArtifactIDs.map(\.rawValue))
    }

    private var validStateHeld: Bool {
        switch state {
        case .valid:
            missingRequiredArtifactIDs.isEmpty && unexpectedArtifactIDs.isEmpty
        case .missing:
            missingRequiredArtifactIDs.isEmpty == false || stateReason.contains("missing")
        case .notEvaluated, .blocked, .stale, .invalid, .checksumMismatch:
            true
        }
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-917"),
        releaseVersion: String = "v0.11.0",
        policyVersion: String,
        state: ProductionReadinessBundleValidationState,
        requiredArtifactIDs: [Identifier],
        manifestArtifactIDs: [Identifier] = [],
        missingRequiredArtifactIDs: [Identifier] = [],
        unexpectedArtifactIDs: [Identifier] = [],
        validatedAt: Date,
        stateReason: String,
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
        self.policyVersion = policyVersion
        self.state = state
        self.requiredArtifactIDs = requiredArtifactIDs
        self.manifestArtifactIDs = manifestArtifactIDs
        self.missingRequiredArtifactIDs = missingRequiredArtifactIDs
        self.unexpectedArtifactIDs = unexpectedArtifactIDs
        self.validatedAt = validatedAt
        self.stateReason = stateReason
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard resultHeld else {
            throw ProductionReadinessArtifactStoreError.forbiddenCapability("bundleValidationResultHeld=false")
        }
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

    /// canonicalJSONData 固定 GH-916 readiness JSON 的 canonical byte policy。
    ///
    /// 当前 policy 只接受 object / array JSON payload，按 sorted key、无 pretty whitespace、
    /// 不转义 slash 的方式重新编码。这样 artifact 原始缩进或字段顺序变化不会改变 checksum。
    public static func canonicalJSONData(for data: Data) throws -> Data {
        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw ProductionReadinessArtifactStoreError.invalidJSON("canonical JSON payload")
        }
        guard JSONSerialization.isValidJSONObject(object) else {
            throw ProductionReadinessArtifactStoreError.invalidJSON("canonical JSON payload")
        }
        do {
            return try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
        } catch {
            throw ProductionReadinessArtifactStoreError.invalidJSON("canonical JSON payload")
        }
    }

    /// canonicalJSONSHA256Checksum 为 readiness artifact 输出 `sha256:<64 hex>`。
    ///
    /// 该 checksum 只基于本地 canonical JSON bytes，不读取 secret、不访问 endpoint、不连接 broker。
    public static func canonicalJSONSHA256Checksum(for data: Data) throws -> String {
        try sha256Checksum(for: canonicalJSONData(for: data))
    }

    public static func isValidSHA256Checksum(_ checksum: String) -> Bool {
        let prefix = "sha256:"
        guard checksum.hasPrefix(prefix) else {
            return false
        }
        let digest = checksum.dropFirst(prefix.count)
        guard digest.count == 64 else {
            return false
        }
        return digest.unicodeScalars.allSatisfy { scalar in
            ("0"..."9").contains(String(scalar)) || ("a"..."f").contains(String(scalar))
        }
    }

    @discardableResult
    public func writeReadinessManifest(
        manifestID: Identifier = Identifier.constant("gh-915-readiness-manifest"),
        manifestRelativePath: String,
        descriptors: [ProductionReadinessArtifactDescriptor],
        policyVersion: String,
        generatedAt: Date,
        now: Date
    ) throws -> ProductionReadinessManifestReadResult {
        guard policyVersion.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("empty policyVersion")
        }
        guard descriptors.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("empty entries")
        }

        let entries = try descriptors.map { descriptor -> ProductionReadinessManifestEntry in
            let record = try inspectArtifact(descriptor, now: now)
            guard record.state == .valid else {
                throw ProductionReadinessArtifactStoreError.manifestEntryRejected(
                    "\(descriptor.relativePath) state=\(record.state.rawValue)"
                )
            }
            let read = try readArtifact(descriptor: descriptor, now: now)
            return try ProductionReadinessManifestEntry(
                record: record,
                data: read.data,
                policyVersion: policyVersion,
                createdAt: record.modifiedAt ?? generatedAt
            )
        }

        let manifest = try ProductionReadinessManifest(
            manifestID: manifestID,
            policyVersion: policyVersion,
            generatedAt: generatedAt,
            entries: entries
        )
        let data = try encodeManifest(manifest)
        let descriptor = try ProductionReadinessArtifactDescriptor(
            artifactID: manifestID,
            relativePath: manifestRelativePath,
            artifactType: .jsonEvidence,
            staleAfterSeconds: nil
        )
        let record = try writeArtifact(
            descriptor: descriptor,
            data: data,
            modifiedAt: generatedAt
        )
        let result = ProductionReadinessManifestReadResult(
            manifest: manifest,
            record: record,
            data: data
        )
        guard result.manifestReadHeld else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("manifestReadHeld=false")
        }
        return result
    }

    public func readReadinessManifest(
        descriptor: ProductionReadinessArtifactDescriptor,
        requiredPolicyVersion: String,
        now: Date
    ) throws -> ProductionReadinessManifestReadResult {
        guard requiredPolicyVersion.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("empty requiredPolicyVersion")
        }
        let read = try readArtifact(descriptor: descriptor, now: now)
        let manifest: ProductionReadinessManifest
        do {
            manifest = try manifestDecoder().decode(ProductionReadinessManifest.self, from: read.data)
        } catch {
            throw ProductionReadinessArtifactStoreError.invalidManifest("malformed JSON schema")
        }
        try validateReadinessManifest(
            manifest,
            requiredPolicyVersion: requiredPolicyVersion,
            now: now
        )
        let result = ProductionReadinessManifestReadResult(
            manifest: manifest,
            record: read.record,
            data: read.data
        )
        guard result.manifestReadHeld else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("manifestReadHeld=false")
        }
        return result
    }

    /// notEvaluatedReadinessBundleValidation 为 GH-917 提供显式未评估状态。
    ///
    /// 该状态只说明 bundle validator 尚未读取本地 manifest，不代表 readiness 通过，也不授权
    /// production cutover、secret read、endpoint connection、broker connection 或订单命令。
    public static func notEvaluatedReadinessBundleValidation(
        requiredPolicyVersion: String,
        requiredArtifactIDs: [Identifier],
        evaluatedAt: Date
    ) throws -> ProductionReadinessBundleValidationResult {
        try ProductionReadinessBundleValidationResult(
            policyVersion: requiredPolicyVersion,
            state: .notEvaluated,
            requiredArtifactIDs: requiredArtifactIDs,
            validatedAt: evaluatedAt,
            stateReason: "bundle validation not evaluated"
        )
    }

    /// validateReadinessBundle 执行 GH-917 的本地 bundle-level validation。
    ///
    /// Validator 只读取本地 manifest descriptor 和 manifest 内声明的本地 artifact；它重新校验
    /// schema、artifact existence、checksum、size、timestamp、policyVersion 与 required artifact set。
    /// 返回 `valid` 也只证明本地 evidence bundle integrity pass，不会转换成 production cutover 授权。
    public func validateReadinessBundle(
        manifestDescriptor: ProductionReadinessArtifactDescriptor,
        requiredPolicyVersion: String,
        requiredArtifactIDs: [Identifier],
        now: Date
    ) throws -> ProductionReadinessBundleValidationResult {
        guard requiredPolicyVersion.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("empty requiredPolicyVersion")
        }
        guard requiredArtifactIDs.isEmpty == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("empty requiredArtifactIDs")
        }

        let manifestRecord = try inspectArtifact(manifestDescriptor, now: now)
        switch manifestRecord.state {
        case .missing:
            return try bundleValidationResult(
                state: .missing,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                missingRequiredArtifactIDs: requiredArtifactIDs,
                validatedAt: now,
                stateReason: "missing readiness manifest"
            )
        case .stale:
            return try bundleValidationResult(
                state: .stale,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                validatedAt: now,
                stateReason: "stale readiness manifest"
            )
        case .invalid:
            return try bundleValidationResult(
                state: .invalid,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                validatedAt: now,
                stateReason: "invalid readiness manifest artifact"
            )
        case .valid:
            break
        }

        let manifestData: Data
        do {
            manifestData = try Data(contentsOf: try artifactURL(for: manifestDescriptor))
        } catch {
            return try bundleValidationResult(
                state: .missing,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                missingRequiredArtifactIDs: requiredArtifactIDs,
                validatedAt: now,
                stateReason: "missing readiness manifest data"
            )
        }

        let manifest: ProductionReadinessManifest
        do {
            manifest = try manifestDecoder().decode(ProductionReadinessManifest.self, from: manifestData)
        } catch {
            return try bundleValidationResult(
                state: .invalid,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                validatedAt: now,
                stateReason: "malformed readiness manifest schema"
            )
        }

        let manifestArtifactIDs = manifest.entries.map(\.artifactID)
        let requiredSet = Set(requiredArtifactIDs.map(\.rawValue))
        let manifestSet = Set(manifestArtifactIDs.map(\.rawValue))
        let missingRequiredArtifactIDs = requiredArtifactIDs.filter { manifestSet.contains($0.rawValue) == false }
        let unexpectedArtifactIDs = manifestArtifactIDs.filter { requiredSet.contains($0.rawValue) == false }

        guard manifest.issueID.rawValue == "GH-915",
              manifest.releaseVersion == "v0.11.0",
              manifest.manifestID.rawValue.isEmpty == false,
              manifest.entries.isEmpty == false,
              manifest.atomicWriteRequired,
              manifest.productionTradingEnabledByDefault == false,
              manifest.productionSecretRead == false,
              manifest.productionEndpointConnected == false,
              manifest.brokerEndpointConnected == false,
              manifest.productionOrderSubmitted == false,
              manifest.testnetOrderSubmissionAllowed == false,
              manifest.productionCutoverAuthorized == false else {
            return try bundleValidationResult(
                state: .invalid,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                manifestArtifactIDs: manifestArtifactIDs,
                missingRequiredArtifactIDs: missingRequiredArtifactIDs,
                unexpectedArtifactIDs: unexpectedArtifactIDs,
                validatedAt: now,
                stateReason: "invalid readiness manifest header"
            )
        }

        guard missingRequiredArtifactIDs.isEmpty else {
            return try bundleValidationResult(
                state: .missing,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                manifestArtifactIDs: manifestArtifactIDs,
                missingRequiredArtifactIDs: missingRequiredArtifactIDs,
                unexpectedArtifactIDs: unexpectedArtifactIDs,
                validatedAt: now,
                stateReason: "missing required artifact set"
            )
        }

        guard unexpectedArtifactIDs.isEmpty else {
            return try bundleValidationResult(
                state: .invalid,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                manifestArtifactIDs: manifestArtifactIDs,
                unexpectedArtifactIDs: unexpectedArtifactIDs,
                validatedAt: now,
                stateReason: "unexpected readiness artifact entry"
            )
        }

        guard manifest.policyVersion == requiredPolicyVersion else {
            return try bundleValidationResult(
                state: .blocked,
                requiredPolicyVersion: requiredPolicyVersion,
                requiredArtifactIDs: requiredArtifactIDs,
                manifestArtifactIDs: manifestArtifactIDs,
                validatedAt: now,
                stateReason: "policy version mismatch"
            )
        }

        for entry in manifest.entries {
            guard entry.policyVersion == requiredPolicyVersion else {
                return try bundleValidationResult(
                    state: .blocked,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "entry policy version mismatch"
                )
            }
            guard entry.evidenceExists,
                  entry.validationState == .valid,
                  ProductionReadinessArtifactDescriptor.isSafeRelativePath(entry.relativePath),
                  ProductionReadinessArtifactStore.isValidSHA256Checksum(entry.checksum) else {
                return try bundleValidationResult(
                    state: .invalid,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "invalid readiness manifest entry"
                )
            }

            let descriptor: ProductionReadinessArtifactDescriptor
            do {
                descriptor = try ProductionReadinessArtifactDescriptor(
                    artifactID: entry.artifactID,
                    relativePath: entry.relativePath,
                    artifactType: entry.artifactType,
                    staleAfterSeconds: entry.staleAfterSeconds
                )
            } catch {
                return try bundleValidationResult(
                    state: .invalid,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "unsafe readiness artifact descriptor"
                )
            }

            let record = try inspectArtifact(descriptor, now: now)
            switch record.state {
            case .missing:
                return try bundleValidationResult(
                    state: .missing,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    missingRequiredArtifactIDs: [entry.artifactID],
                    validatedAt: now,
                    stateReason: "missing readiness artifact"
                )
            case .stale:
                return try bundleValidationResult(
                    state: .stale,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "stale readiness artifact"
                )
            case .invalid:
                return try bundleValidationResult(
                    state: .invalid,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "invalid readiness artifact"
                )
            case .valid:
                break
            }

            let data: Data
            do {
                data = try Data(contentsOf: try artifactURL(for: descriptor))
            } catch {
                return try bundleValidationResult(
                    state: .missing,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    missingRequiredArtifactIDs: [entry.artifactID],
                    validatedAt: now,
                    stateReason: "missing readiness artifact data"
                )
            }
            guard data.count == entry.size,
                  entry.validationState == record.state,
                  Self.timestampsMatch(entry.createdAt, record.modifiedAt) else {
                return try bundleValidationResult(
                    state: .invalid,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "readiness artifact size state or timestamp mismatch"
                )
            }
            guard try Self.canonicalJSONSHA256Checksum(for: data) == entry.checksum else {
                return try bundleValidationResult(
                    state: .checksumMismatch,
                    requiredPolicyVersion: requiredPolicyVersion,
                    requiredArtifactIDs: requiredArtifactIDs,
                    manifestArtifactIDs: manifestArtifactIDs,
                    validatedAt: now,
                    stateReason: "readiness artifact checksum mismatch"
                )
            }
        }

        return try bundleValidationResult(
            state: .valid,
            requiredPolicyVersion: requiredPolicyVersion,
            requiredArtifactIDs: requiredArtifactIDs,
            manifestArtifactIDs: manifestArtifactIDs,
            validatedAt: now,
            stateReason: "readiness bundle valid"
        )
    }

    public func validateReadinessManifest(
        _ manifest: ProductionReadinessManifest,
        requiredPolicyVersion: String,
        now: Date
    ) throws {
        guard manifest.issueID.rawValue == "GH-915",
              manifest.releaseVersion == "v0.11.0",
              manifest.manifestID.rawValue.isEmpty == false,
              manifest.policyVersion.isEmpty == false,
              manifest.entries.isEmpty == false,
              manifest.atomicWriteRequired,
              manifest.productionTradingEnabledByDefault == false,
              manifest.productionSecretRead == false,
              manifest.productionEndpointConnected == false,
              manifest.brokerEndpointConnected == false,
              manifest.productionOrderSubmitted == false,
              manifest.testnetOrderSubmissionAllowed == false,
              manifest.productionCutoverAuthorized == false else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("manifest header invalid")
        }
        for entry in manifest.entries {
            guard Self.isValidSHA256Checksum(entry.checksum) else {
                throw ProductionReadinessArtifactStoreError.invalidChecksumFormat(entry.checksum)
            }
        }
        guard manifest.manifestHeld else {
            throw ProductionReadinessArtifactStoreError.invalidManifest("manifestHeld=false")
        }
        guard manifest.policyVersion == requiredPolicyVersion else {
            throw ProductionReadinessArtifactStoreError.manifestPolicyMismatch(
                expected: requiredPolicyVersion,
                actual: manifest.policyVersion
            )
        }

        for entry in manifest.entries {
            guard entry.policyVersion == requiredPolicyVersion else {
                throw ProductionReadinessArtifactStoreError.manifestPolicyMismatch(
                    expected: requiredPolicyVersion,
                    actual: entry.policyVersion
                )
            }
            guard entry.entryHeld else {
                throw ProductionReadinessArtifactStoreError.manifestEntryRejected(
                    "\(entry.relativePath) entryHeld=false"
                )
            }
            let descriptor = try ProductionReadinessArtifactDescriptor(
                artifactID: entry.artifactID,
                relativePath: entry.relativePath,
                artifactType: entry.artifactType,
                staleAfterSeconds: entry.staleAfterSeconds
            )
            let record = try inspectArtifact(descriptor, now: now)
            guard record.state == .valid else {
                throw ProductionReadinessArtifactStoreError.manifestEntryRejected(
                    "\(entry.relativePath) state=\(record.state.rawValue)"
                )
            }
            let data = try Data(contentsOf: try artifactURL(for: descriptor))
            guard data.count == entry.size else {
                throw ProductionReadinessArtifactStoreError.manifestEntryRejected(
                    "\(entry.relativePath) size mismatch"
                )
            }
            guard Self.isValidSHA256Checksum(entry.checksum) else {
                throw ProductionReadinessArtifactStoreError.invalidChecksumFormat(entry.checksum)
            }
            guard try Self.canonicalJSONSHA256Checksum(for: data) == entry.checksum else {
                throw ProductionReadinessArtifactStoreError.checksumMismatch(entry.relativePath)
            }
            guard entry.validationState == record.state else {
                throw ProductionReadinessArtifactStoreError.manifestEntryRejected(
                    "\(entry.relativePath) validationState mismatch"
                )
            }
        }
    }

    private func bundleValidationResult(
        state: ProductionReadinessBundleValidationState,
        requiredPolicyVersion: String,
        requiredArtifactIDs: [Identifier],
        manifestArtifactIDs: [Identifier] = [],
        missingRequiredArtifactIDs: [Identifier] = [],
        unexpectedArtifactIDs: [Identifier] = [],
        validatedAt: Date,
        stateReason: String
    ) throws -> ProductionReadinessBundleValidationResult {
        try ProductionReadinessBundleValidationResult(
            policyVersion: requiredPolicyVersion,
            state: state,
            requiredArtifactIDs: requiredArtifactIDs.sorted { $0.rawValue < $1.rawValue },
            manifestArtifactIDs: manifestArtifactIDs.sorted { $0.rawValue < $1.rawValue },
            missingRequiredArtifactIDs: missingRequiredArtifactIDs.sorted { $0.rawValue < $1.rawValue },
            unexpectedArtifactIDs: unexpectedArtifactIDs.sorted { $0.rawValue < $1.rawValue },
            validatedAt: validatedAt,
            stateReason: stateReason
        )
    }

    private static func timestampsMatch(_ expected: Date, _ actual: Date?) -> Bool {
        guard let actual else {
            return false
        }
        return abs(expected.timeIntervalSince(actual)) < 0.001
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

    private func encodeManifest(_ manifest: ProductionReadinessManifest) throws -> Data {
        do {
            return try Self.canonicalJSONData(for: manifestEncoder().encode(manifest))
        } catch {
            throw ProductionReadinessArtifactStoreError.invalidManifest("encoding failed")
        }
    }

    private func manifestEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    private static func sha256Checksum(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    private func manifestDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
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
