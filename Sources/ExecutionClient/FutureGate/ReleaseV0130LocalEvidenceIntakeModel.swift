import DomainModel
import Foundation

/// ReleaseV0130LocalEvidenceIntakeAnchors 固定 GH-995 的本地证据 intake 验证锚点。
///
/// 这些锚点只证明 v0.13.0 readiness engine 可以发现并校验显式 local evidence root；
/// 它们不授权 production cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130LocalEvidenceIntakeAnchors {
    public static let validationAnchors = [
        "GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL",
        "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL",
        "V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT",
        "V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS",
        "V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS",
        "V0130-002-MISSING-MALFORMED-FAILS-CLOSED",
        "V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER",
        "V0130-002-READ-ONLY-INTAKE"
    ]
}

/// ReleaseV0130LocalEvidenceCategory 是 #995 local evidence root 的目录级分类。
///
/// 分类固定为 run logs、event stream、artifacts、registry 和 prior assessments；
/// 后续 bundle、registry write、diff / compare 仍由 #996 之后的 issue 分别实现。
public enum ReleaseV0130LocalEvidenceCategory: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case runLogs = "run-logs"
    case eventStream = "event-stream"
    case artifacts
    case registry
    case priorAssessments = "prior-assessments"
}

/// ReleaseV0130LocalEvidenceSchemaKind 描述 #995 intake 当前允许的本地文件 schema。
public enum ReleaseV0130LocalEvidenceSchemaKind: String, Codable, Equatable, Sendable {
    case jsonObject = "json-object"
    case jsonLines = "json-lines"
}

/// ReleaseV0130LocalEvidenceIntakeState 是单条 evidence 文件的 fail-closed 状态。
public enum ReleaseV0130LocalEvidenceIntakeState: String, Codable, Equatable, Sendable {
    case valid
    case missing
    case malformed
    case forbidden
}

/// ReleaseV0130LocalEvidenceDescriptor 描述 #995 允许读取的本地证据文件。
///
/// Descriptor 只接受显式 root 下的安全相对路径。它不会解析环境变量、secret path、
/// production endpoint URL，也不会生成 readiness output。
public struct ReleaseV0130LocalEvidenceDescriptor: Codable, Equatable, Sendable {
    public let category: ReleaseV0130LocalEvidenceCategory
    public let relativePath: String
    public let schemaKind: ReleaseV0130LocalEvidenceSchemaKind
    public let requiredFields: [String]
    public let required: Bool

    public var descriptorHeld: Bool {
        ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath)
            && requiredFields.isEmpty == false
            && required
    }

    public init(
        category: ReleaseV0130LocalEvidenceCategory,
        relativePath: String,
        schemaKind: ReleaseV0130LocalEvidenceSchemaKind,
        requiredFields: [String],
        required: Bool = true
    ) throws {
        guard ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath) else {
            throw ReleaseV0130LocalEvidenceIntakeError.unsafeRelativePath(relativePath)
        }
        guard requiredFields.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: relativePath,
                reason: "requiredFields must not be empty"
            )
        }
        self.category = category
        self.relativePath = relativePath
        self.schemaKind = schemaKind
        self.requiredFields = requiredFields
        self.required = required
    }
}

/// ReleaseV0130LocalEvidenceIntakeError 描述 #995 intake model 的本地失败原因。
public enum ReleaseV0130LocalEvidenceIntakeError: Error, Equatable, Sendable, CustomStringConvertible {
    case nonFileRoot(String)
    case missingEvidenceRoot(String)
    case missingRequiredDirectory(String)
    case missingRequiredFile(String)
    case unsafeRelativePath(String)
    case malformedJSON(String)
    case schemaViolation(path: String, reason: String)
    case forbiddenCapability(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .nonFileRoot(path):
            "GH-995 local evidence intake requires a local file root, got \(path)"
        case let .missingEvidenceRoot(path):
            "GH-995 local evidence intake fails closed because evidence root is missing at \(path)"
        case let .missingRequiredDirectory(path):
            "GH-995 local evidence intake fails closed because required directory is missing at \(path)"
        case let .missingRequiredFile(path):
            "GH-995 local evidence intake fails closed because required evidence file is missing at \(path)"
        case let .unsafeRelativePath(path):
            "GH-995 local evidence intake rejects unsafe relative path \(path)"
        case let .malformedJSON(path):
            "GH-995 local evidence intake fails closed because evidence JSON is malformed at \(path)"
        case let .schemaViolation(path, reason):
            "GH-995 local evidence intake schema violation at \(path): \(reason)"
        case let .forbiddenCapability(marker):
            "GH-995 local evidence intake rejects forbidden production capability \(marker)"
        case let .boundaryDrift(field):
            "GH-995 local evidence intake boundary drift: \(field)"
        }
    }
}

/// ReleaseV0130LocalEvidenceIntakeRecord 是单条本地 evidence 文件的检查结果。
///
/// Record 固定所有 production / endpoint / broker / order capability 为 false，确保 #995
/// 只是本地只读 intake diagnostics，而不是 readiness bundle、registry write 或 command path。
public struct ReleaseV0130LocalEvidenceIntakeRecord: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let descriptor: ReleaseV0130LocalEvidenceDescriptor
    public let absolutePath: String
    public let state: ReleaseV0130LocalEvidenceIntakeState
    public let byteCount: Int
    public let diagnostic: String
    public let localFileURLOnly: Bool
    public let readOnlyIntake: Bool
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var recordHeld: Bool {
        issueID.rawValue == "GH-995"
            && releaseVersion == "v0.13.0"
            && descriptor.descriptorHeld
            && absolutePath.isEmpty == false
            && byteCount >= 0
            && diagnostic.isEmpty == false
            && localFileURLOnly
            && readOnlyIntake
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
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

    public init(
        issueID: Identifier = Identifier.constant("GH-995"),
        releaseVersion: String = "v0.13.0",
        descriptor: ReleaseV0130LocalEvidenceDescriptor,
        absolutePath: String,
        state: ReleaseV0130LocalEvidenceIntakeState,
        byteCount: Int,
        diagnostic: String,
        localFileURLOnly: Bool = true,
        readOnlyIntake: Bool = true,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true,
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
        self.diagnostic = diagnostic
        self.localFileURLOnly = localFileURLOnly
        self.readOnlyIntake = readOnlyIntake
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard recordHeld else {
            throw ReleaseV0130LocalEvidenceIntakeError.boundaryDrift("recordHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceIntakeReport 汇总 #995 本地 evidence root 发现结果。
public struct ReleaseV0130LocalEvidenceIntakeReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let evidenceRootPath: String
    public let requiredDirectoryPaths: [String]
    public let records: [ReleaseV0130LocalEvidenceIntakeRecord]
    public let diagnostics: [String]
    public let localFileURLOnly: Bool
    public let readOnlyIntake: Bool
    public let assessmentOutputWritten: Bool
    public let registryWritten: Bool
    public let bundleWritten: Bool
    public let diffBuilt: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var valid: Bool {
        records.count == ReleaseV0130LocalEvidenceCategory.allCases.count
            && records.allSatisfy { $0.state == .valid && $0.recordHeld }
            && diagnostics.isEmpty
            && categoryCoverageHeld
            && productionCapabilitiesDisabled
    }

    public var failClosed: Bool {
        valid == false
    }

    public var missingDiagnostics: [String] {
        diagnostics.filter { $0.contains("missing") }
    }

    public var malformedDiagnostics: [String] {
        diagnostics.filter { $0.contains("malformed") || $0.contains("schema violation") }
    }

    public var forbiddenDiagnostics: [String] {
        diagnostics.filter { $0.contains("forbidden") }
    }

    public var categoryCoverageHeld: Bool {
        Set(records.map(\.descriptor.category)) == Set(ReleaseV0130LocalEvidenceCategory.allCases)
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
            && assessmentOutputWritten == false
            && registryWritten == false
            && bundleWritten == false
            && diffBuilt == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-995"),
        releaseVersion: String = "v0.13.0",
        evidenceRootPath: String,
        requiredDirectoryPaths: [String],
        records: [ReleaseV0130LocalEvidenceIntakeRecord],
        diagnostics: [String],
        localFileURLOnly: Bool = true,
        readOnlyIntake: Bool = true,
        assessmentOutputWritten: Bool = false,
        registryWritten: Bool = false,
        bundleWritten: Bool = false,
        diffBuilt: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.evidenceRootPath = evidenceRootPath
        self.requiredDirectoryPaths = requiredDirectoryPaths
        self.records = records
        self.diagnostics = diagnostics
        self.localFileURLOnly = localFileURLOnly
        self.readOnlyIntake = readOnlyIntake
        self.assessmentOutputWritten = assessmentOutputWritten
        self.registryWritten = registryWritten
        self.bundleWritten = bundleWritten
        self.diffBuilt = diffBuilt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0130LocalEvidenceIntakeModel 只读发现并验证 #995 local evidence root。
///
/// Model 只从调用方显式传入的 file URL 读取五类本地 evidence，不解析 secret provider、
/// 不连接 endpoint / broker、不写 registry、不生成 bundle，也不触发任何 submit / cancel / replace。
public struct ReleaseV0130LocalEvidenceIntakeModel {
    public static let requiredDirectories = [
        "run-logs",
        "event-stream",
        "artifacts",
        "registry",
        "prior-assessments"
    ]

    public static let requiredDescriptors: [ReleaseV0130LocalEvidenceDescriptor] = {
        do {
            return [
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .runLogs,
                    relativePath: "run-logs/run-journal.jsonl",
                    schemaKind: .jsonLines,
                    requiredFields: ["sourceRunID", "sourceCommit", "eventType", "createdAt"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .eventStream,
                    relativePath: "event-stream/events.jsonl",
                    schemaKind: .jsonLines,
                    requiredFields: ["eventID", "sourceRunID", "eventType", "occurredAt"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .artifacts,
                    relativePath: "artifacts/artifact-index.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["sourceRunID", "sourceCommit", "artifacts"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .registry,
                    relativePath: "registry/registry.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["registryVersion", "assessments"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .priorAssessments,
                    relativePath: "prior-assessments/assessments-index.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["assessmentIDs", "sourceRunIDs"]
                )
            ]
        } catch {
            preconditionFailure("GH-995 local evidence descriptor constants must be valid: \(error)")
        }
    }()

    private static let forbiddenMarkers = [
        "\"productionTradingEnabledByDefault\":true",
        "\"productionCutoverAuthorized\":true",
        "\"productionSecretRead\":true",
        "\"productionEndpointConnected\":true",
        "\"brokerEndpointConnected\":true",
        "\"productionOrderSubmitted\":true",
        "\"testnetOrderSubmissionAllowed\":true",
        "\"secretValue\":\"",
        "\"rawSecret\":\"",
        "\"listenKey\":\"",
        "\"signature\":\"",
        "\"signature=\"",
        "\"orderEndpointPayload\"",
        "\"accountEndpointPayload\"",
        "\"signedEndpointPayload\"",
        "/api/v3/account",
        "/api/v3/order",
        "/api/v3/userDataStream",
        "api.binance.com",
        "fapi.binance.com"
    ]

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func discover(evidenceRootURL: URL) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        let rootPath = evidenceRootURL.path
        guard evidenceRootURL.isFileURL else {
            return try failureReport(
                evidenceRootPath: evidenceRootURL.absoluteString,
                diagnostics: [ReleaseV0130LocalEvidenceIntakeError.nonFileRoot(evidenceRootURL.absoluteString).description]
            )
        }

        guard isDirectory(evidenceRootURL) else {
            return try failureReport(
                evidenceRootPath: rootPath,
                diagnostics: [ReleaseV0130LocalEvidenceIntakeError.missingEvidenceRoot(rootPath).description]
            )
        }

        var records: [ReleaseV0130LocalEvidenceIntakeRecord] = []
        var diagnostics: [String] = []
        for descriptor in Self.requiredDescriptors {
            let record = try inspect(descriptor: descriptor, evidenceRootURL: evidenceRootURL)
            records.append(record)
            if record.state != .valid {
                diagnostics.append(record.diagnostic)
            }
        }

        return ReleaseV0130LocalEvidenceIntakeReport(
            evidenceRootPath: rootPath,
            requiredDirectoryPaths: Self.requiredDirectories,
            records: records,
            diagnostics: diagnostics
        )
    }

    public func validate(evidenceRootURL: URL) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        try discover(evidenceRootURL: evidenceRootURL)
    }

    private func failureReport(
        evidenceRootPath: String,
        diagnostics: [String]
    ) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        let records = try Self.requiredDescriptors.map { descriptor in
            try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: evidenceRootPath,
                state: .missing,
                byteCount: 0,
                diagnostic: diagnostics.joined(separator: "; ")
            )
        }
        return ReleaseV0130LocalEvidenceIntakeReport(
            evidenceRootPath: evidenceRootPath,
            requiredDirectoryPaths: Self.requiredDirectories,
            records: records,
            diagnostics: diagnostics
        )
    }

    private func inspect(
        descriptor: ReleaseV0130LocalEvidenceDescriptor,
        evidenceRootURL: URL
    ) throws -> ReleaseV0130LocalEvidenceIntakeRecord {
        let evidenceURL = url(for: descriptor.relativePath, under: evidenceRootURL)
        let parentPath = String(descriptor.relativePath.split(separator: "/").dropLast().joined(separator: "/"))
        let parentURL = parentPath.isEmpty ? evidenceRootURL : url(for: parentPath, under: evidenceRootURL)
        let absolutePath = evidenceURL.path

        guard isDirectory(parentURL) else {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .missing,
                byteCount: 0,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .missingRequiredDirectory(parentURL.path)
                    .description
            )
        }

        guard fileManager.fileExists(atPath: absolutePath) else {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .missing,
                byteCount: 0,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .missingRequiredFile(descriptor.relativePath)
                    .description
            )
        }

        let data = try Data(contentsOf: evidenceURL)
        let byteCount = data.count
        let content = String(data: data, encoding: .utf8) ?? ""
        if let forbidden = Self.forbiddenMarkers.first(where: { marker in
            Self.normalized(content).contains(Self.normalized(marker))
        }) {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .forbidden,
                byteCount: byteCount,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .forbiddenCapability(forbidden)
                    .description
            )
        }

        do {
            try validateSchema(data: data, descriptor: descriptor)
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .valid,
                byteCount: byteCount,
                diagnostic: "valid local evidence \(descriptor.relativePath)"
            )
        } catch let error as ReleaseV0130LocalEvidenceIntakeError {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .malformed,
                byteCount: byteCount,
                diagnostic: error.description
            )
        } catch {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .malformed,
                byteCount: byteCount,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .malformedJSON(descriptor.relativePath)
                    .description
            )
        }
    }

    private func validateSchema(
        data: Data,
        descriptor: ReleaseV0130LocalEvidenceDescriptor
    ) throws {
        switch descriptor.schemaKind {
        case .jsonObject:
            let object = try JSONSerialization.jsonObject(with: data)
            guard let dictionary = object as? [String: Any] else {
                throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                    path: descriptor.relativePath,
                    reason: "expected JSON object"
                )
            }
            try requireFields(descriptor.requiredFields, in: dictionary, path: descriptor.relativePath)
        case .jsonLines:
            guard let string = String(data: data, encoding: .utf8) else {
                throw ReleaseV0130LocalEvidenceIntakeError.malformedJSON(descriptor.relativePath)
            }
            let lines = string.split(whereSeparator: \.isNewline)
            guard lines.isEmpty == false else {
                throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                    path: descriptor.relativePath,
                    reason: "expected at least one JSON line"
                )
            }
            for line in lines {
                let lineData = Data(String(line).utf8)
                let object = try JSONSerialization.jsonObject(with: lineData)
                guard let dictionary = object as? [String: Any] else {
                    throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                        path: descriptor.relativePath,
                        reason: "expected JSON object per line"
                    )
                }
                try requireFields(descriptor.requiredFields, in: dictionary, path: descriptor.relativePath)
            }
        }
    }

    private func requireFields(
        _ fields: [String],
        in dictionary: [String: Any],
        path: String
    ) throws {
        let missingFields = fields.filter { dictionary[$0] == nil }
        guard missingFields.isEmpty else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: path,
                reason: "missing required fields \(missingFields.joined(separator: ","))"
            )
        }
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func url(for relativePath: String, under root: URL) -> URL {
        relativePath.split(separator: "/").reduce(root) { partialURL, component in
            partialURL.appendingPathComponent(String(component))
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .lowercased()
    }
}
