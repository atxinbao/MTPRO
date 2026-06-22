import Crypto
import DomainModel
import Foundation

// GH-1075 static contract boundary:
// failureSimulationOnly=true
// deterministicFailureSimulation=true
// appendOnlyFailureEvidence=true
// redactedRequestIdentity=true
// redactedResponseIdentity=true
// omsStateExplainable=true
// reconciliationMismatchFailClosed=true
// rawSecretPersisted=false
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0150BinanceSpotTestnetFailureSimulationCase 固定 #1075 必须覆盖的签名 transport 失败场景。
///
/// 这些 case 只生成本地、确定性的 failure evidence。它们不会执行网络动作，也不会读取 secret、
/// 连接 production endpoint 或提交真实订单。
public enum ReleaseV0150BinanceSpotTestnetFailureSimulationCase: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case rejectedRequest
    case timeout
    case rateLimit
    case staleCredential
    case badSignature
    case cancelNotFound
    case reconciliationMismatch

    public var actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind {
        switch self {
        case .rejectedRequest, .timeout, .rateLimit, .staleCredential, .badSignature:
            .submit
        case .cancelNotFound:
            .cancel
        case .reconciliationMismatch:
            .cancelReplace
        }
    }

    public var simulatedHTTPStatusCode: Int? {
        switch self {
        case .rejectedRequest:
            400
        case .timeout:
            nil
        case .rateLimit:
            429
        case .staleCredential:
            401
        case .badSignature:
            400
        case .cancelNotFound:
            404
        case .reconciliationMismatch:
            200
        }
    }

    public var expectedLifecycleState: OrderLifecycleState {
        switch self {
        case .rejectedRequest, .badSignature:
            .rejected
        case .timeout, .rateLimit, .staleCredential, .cancelNotFound, .reconciliationMismatch:
            .failedClosed
        }
    }

    public var reconciliationFailureReason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason? {
        switch self {
        case .reconciliationMismatch:
            .lifecycleStateMismatch
        case .rejectedRequest, .timeout, .rateLimit, .staleCredential, .badSignature, .cancelNotFound:
            nil
        }
    }

    public var failureDetail: String {
        switch self {
        case .rejectedRequest:
            "Signed Spot Testnet submit was rejected before accepted runtime evidence could be emitted."
        case .timeout:
            "Signed Spot Testnet transport timed out and failed closed without retrying against production."
        case .rateLimit:
            "Signed Spot Testnet transport received rate-limit feedback and failed closed without fallback."
        case .staleCredential:
            "Credential reference was treated as stale and failed closed before reusable secret material persisted."
        case .badSignature:
            "Signed request signature was treated as invalid and failed closed with redacted request identity."
        case .cancelNotFound:
            "Cancel request could not find the redacted testnet order identity and failed closed locally."
        case .reconciliationMismatch:
            "OMS expected / observed reconciliation mismatch produced fail-closed lifecycle mismatch evidence."
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence 是单个 #1075 failure case 的脱敏证据。
///
/// Evidence 只保存 signed request / response digest、credential reference、预期 OMS 状态和 checksum。
/// 它不保存 raw request body、raw response body、API key、secret、order identity material 或 broker payload。
public struct ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence: Codable, Equatable, Sendable, CustomStringConvertible {
    public let evidenceID: Identifier
    public let sequenceNumber: Int
    public let simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase
    public let actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind
    public let sourceSignedRequestID: Identifier
    public let sourceCredentialReferenceID: Identifier
    public let redactedRequestDigest: String
    public let redactedResponseDigest: String
    public let simulatedHTTPStatusCode: Int?
    public let expectedLifecycleState: OrderLifecycleState
    public let reconciliationFailureReason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason?
    public let failureDetail: String
    public let observedAtMilliseconds: Int64
    public let previousFailureChecksum: String?
    public let failureChecksumAlgorithm: String
    public let failureChecksum: String
    public let failureSimulationOnly: Bool
    public let deterministicFailureSimulation: Bool
    public let appendOnlyFailureEvidence: Bool
    public let redactedRequestIdentity: Bool
    public let redactedResponseIdentity: Bool
    public let requestBodyRedacted: Bool
    public let responseBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let omsStateExplainable: Bool
    public let reconciliationMismatchFailClosed: Bool
    public let rawSecretPersisted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        evidenceID: Identifier,
        sequenceNumber: Int,
        simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase,
        sourceSignedRequestID: Identifier,
        sourceCredentialReferenceID: Identifier,
        redactedRequestDigest: String,
        redactedResponseDigest: String,
        observedAtMilliseconds: Int64,
        previousFailureChecksum: String?,
        failureChecksum: String,
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind? = nil,
        simulatedHTTPStatusCode: Int? = nil,
        expectedLifecycleState: OrderLifecycleState? = nil,
        reconciliationFailureReason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason? = nil,
        failureDetail: String? = nil,
        failureSimulationOnly: Bool = true,
        deterministicFailureSimulation: Bool = true,
        appendOnlyFailureEvidence: Bool = true,
        redactedRequestIdentity: Bool = true,
        redactedResponseIdentity: Bool = true,
        requestBodyRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        omsStateExplainable: Bool = true,
        reconciliationMismatchFailClosed: Bool = true,
        rawSecretPersisted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let resolvedActionKind = actionKind ?? simulationCase.actionKind
        let resolvedHTTPStatus = simulatedHTTPStatusCode ?? simulationCase.simulatedHTTPStatusCode
        let resolvedLifecycleState = expectedLifecycleState ?? simulationCase.expectedLifecycleState
        let resolvedReconciliationReason = reconciliationFailureReason ?? simulationCase.reconciliationFailureReason
        let resolvedFailureDetail = failureDetail ?? simulationCase.failureDetail

        guard sequenceNumber > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.sequenceNumber",
                expected: "positive append-only sequence",
                actual: "\(sequenceNumber)"
            )
        }
        guard observedAtMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.observedAtMilliseconds",
                expected: "positive unix epoch milliseconds",
                actual: "\(observedAtMilliseconds)"
            )
        }
        guard resolvedActionKind == simulationCase.actionKind else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.actionKind",
                expected: simulationCase.actionKind.rawValue,
                actual: resolvedActionKind.rawValue
            )
        }
        guard resolvedHTTPStatus == simulationCase.simulatedHTTPStatusCode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.simulatedHTTPStatusCode",
                expected: simulationCase.simulatedHTTPStatusCode.map(String.init) ?? "timeout-without-status",
                actual: resolvedHTTPStatus.map(String.init) ?? "nil"
            )
        }
        guard resolvedLifecycleState == simulationCase.expectedLifecycleState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.expectedLifecycleState",
                expected: simulationCase.expectedLifecycleState.rawValue,
                actual: resolvedLifecycleState.rawValue
            )
        }
        guard resolvedReconciliationReason == simulationCase.reconciliationFailureReason else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.reconciliationFailureReason",
                expected: simulationCase.reconciliationFailureReason?.rawValue ?? "none",
                actual: resolvedReconciliationReason?.rawValue ?? "none"
            )
        }
        guard resolvedFailureDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.failureDetail",
                expected: "non-empty failure detail",
                actual: "empty"
            )
        }
        guard Self.isLowercaseSHA256(redactedRequestDigest),
              Self.isLowercaseSHA256(redactedResponseDigest),
              previousFailureChecksum.map(Self.isLowercaseSHA256) ?? true,
              Self.isLowercaseSHA256(failureChecksum) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.checksum",
                expected: "lowercase sha256 checksums",
                actual: "\(redactedRequestDigest):\(redactedResponseDigest):\(previousFailureChecksum ?? "<nil>"):\(failureChecksum)"
            )
        }
        let expectedChecksum = Self.canonicalChecksum(
            sequenceNumber: sequenceNumber,
            simulationCase: simulationCase,
            actionKind: resolvedActionKind,
            sourceSignedRequestID: sourceSignedRequestID,
            sourceCredentialReferenceID: sourceCredentialReferenceID,
            redactedRequestDigest: redactedRequestDigest,
            redactedResponseDigest: redactedResponseDigest,
            simulatedHTTPStatusCode: resolvedHTTPStatus,
            expectedLifecycleState: resolvedLifecycleState,
            reconciliationFailureReason: resolvedReconciliationReason,
            failureDetail: resolvedFailureDetail,
            observedAtMilliseconds: observedAtMilliseconds,
            previousFailureChecksum: previousFailureChecksum,
            validationAnchors: validationAnchors
        )
        guard failureChecksum == expectedChecksum else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.failureChecksum",
                expected: expectedChecksum,
                actual: failureChecksum
            )
        }
        guard evidenceID == Self.deterministicID(
            sequenceNumber: sequenceNumber,
            simulationCase: simulationCase,
            failureChecksum: failureChecksum
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.evidenceID",
                expected: Self.deterministicID(
                    sequenceNumber: sequenceNumber,
                    simulationCase: simulationCase,
                    failureChecksum: failureChecksum
                ).rawValue,
                actual: evidenceID.rawValue
            )
        }
        guard failureSimulationOnly,
              deterministicFailureSimulation,
              appendOnlyFailureEvidence,
              redactedRequestIdentity,
              redactedResponseIdentity,
              requestBodyRedacted,
              responseBodyRedacted,
              credentialMaterialRedacted,
              omsStateExplainable,
              reconciliationMismatchFailClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.unheldEvidenceBoundary")
        }
        try Self.forbid(rawSecretPersisted, "rawSecretPersisted")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.evidenceID = evidenceID
        self.sequenceNumber = sequenceNumber
        self.simulationCase = simulationCase
        self.actionKind = resolvedActionKind
        self.sourceSignedRequestID = sourceSignedRequestID
        self.sourceCredentialReferenceID = sourceCredentialReferenceID
        self.redactedRequestDigest = redactedRequestDigest
        self.redactedResponseDigest = redactedResponseDigest
        self.simulatedHTTPStatusCode = resolvedHTTPStatus
        self.expectedLifecycleState = resolvedLifecycleState
        self.reconciliationFailureReason = resolvedReconciliationReason
        self.failureDetail = resolvedFailureDetail
        self.observedAtMilliseconds = observedAtMilliseconds
        self.previousFailureChecksum = previousFailureChecksum
        self.failureChecksumAlgorithm = Self.requiredChecksumAlgorithm
        self.failureChecksum = failureChecksum
        self.failureSimulationOnly = failureSimulationOnly
        self.deterministicFailureSimulation = deterministicFailureSimulation
        self.appendOnlyFailureEvidence = appendOnlyFailureEvidence
        self.redactedRequestIdentity = redactedRequestIdentity
        self.redactedResponseIdentity = redactedResponseIdentity
        self.requestBodyRedacted = requestBodyRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.omsStateExplainable = omsStateExplainable
        self.reconciliationMismatchFailClosed = reconciliationMismatchFailClosed
        self.rawSecretPersisted = rawSecretPersisted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        actionKind == simulationCase.actionKind
            && simulatedHTTPStatusCode == simulationCase.simulatedHTTPStatusCode
            && expectedLifecycleState == simulationCase.expectedLifecycleState
            && reconciliationFailureReason == simulationCase.reconciliationFailureReason
            && failureChecksumAlgorithm == Self.requiredChecksumAlgorithm
            && Self.isLowercaseSHA256(redactedRequestDigest)
            && Self.isLowercaseSHA256(redactedResponseDigest)
            && Self.isLowercaseSHA256(failureChecksum)
            && failureSimulationOnly
            && deterministicFailureSimulation
            && appendOnlyFailureEvidence
            && redactedRequestIdentity
            && redactedResponseIdentity
            && requestBodyRedacted
            && responseBodyRedacted
            && credentialMaterialRedacted
            && omsStateExplainable
            && reconciliationMismatchFailClosed
            && rawSecretPersisted == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence(sequence: \(sequenceNumber), case: \(simulationCase.rawValue), request: \(sourceSignedRequestID.rawValue), requestBody: <redacted>, responseBody: <redacted>, credentialMaterial: <redacted>, checksum: \(failureChecksum))"
    }

    public static let requiredChecksumAlgorithm = "sha256"

    public static let requiredValidationAnchors = [
        "GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT",
        "TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT",
        "V0150-010-REJECTED-TIMEOUT-RATELIMIT",
        "V0150-010-CREDENTIAL-SIGNATURE-FAILURES",
        "V0150-010-CANCEL-NOT-FOUND",
        "V0150-010-RECONCILIATION-MISMATCH",
        "V0150-010-APPEND-ONLY-REDACTED-FAILURE-EVIDENCE",
        "V0150-010-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        sequenceNumber: Int,
        simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase,
        failureChecksum: String
    ) -> Identifier {
        .constant(
            "gh-1075-v0150-failure-simulation:\(sequenceNumber):\(simulationCase.rawValue):\(failureChecksum)",
            field: "releaseV0150FailureSimulation.evidenceID"
        )
    }

    public static func canonicalChecksum(
        sequenceNumber: Int,
        simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase,
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind,
        sourceSignedRequestID: Identifier,
        sourceCredentialReferenceID: Identifier,
        redactedRequestDigest: String,
        redactedResponseDigest: String,
        simulatedHTTPStatusCode: Int?,
        expectedLifecycleState: OrderLifecycleState,
        reconciliationFailureReason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason?,
        failureDetail: String,
        observedAtMilliseconds: Int64,
        previousFailureChecksum: String?,
        validationAnchors: [String]
    ) -> String {
        let payload = [
            "gh-1075-v0150-failure-simulation-evidence",
            "\(sequenceNumber)",
            simulationCase.rawValue,
            actionKind.rawValue,
            sourceSignedRequestID.rawValue,
            sourceCredentialReferenceID.rawValue,
            redactedRequestDigest,
            redactedResponseDigest,
            simulatedHTTPStatusCode.map(String.init) ?? "timeout-without-status",
            expectedLifecycleState.rawValue,
            reconciliationFailureReason?.rawValue ?? "none",
            failureDetail,
            "\(observedAtMilliseconds)",
            previousFailureChecksum ?? "genesis",
            validationAnchors.joined(separator: "|")
        ].joined(separator: "\n")
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func redactedDigest(
        simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase,
        sourceID: Identifier,
        suffix: String
    ) -> String {
        let payload = "gh-1075-redacted-\(simulationCase.rawValue):\(sourceID.rawValue):\(suffix)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.evidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetFailureSimulationReport 汇总 #1075 的七类 fail-closed 场景。
public struct ReleaseV0150BinanceSpotTestnetFailureSimulationReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let evidence: [ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence]
    public let failureCasesCovered: [ReleaseV0150BinanceSpotTestnetFailureSimulationCase]
    public let latestFailureChecksum: String
    public let appendOnlyChecksumChainVerified: Bool
    public let allFailuresFailClosed: Bool
    public let redactedFailureEvidence: Bool
    public let signedTransportFailuresCovered: Bool
    public let cancelNotFoundCovered: Bool
    public let reconciliationMismatchCovered: Bool
    public let omsStatesExplainable: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        reportID: Identifier,
        evidence: [ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence],
        appendOnlyChecksumChainVerified: Bool = true,
        allFailuresFailClosed: Bool = true,
        redactedFailureEvidence: Bool = true,
        signedTransportFailuresCovered: Bool = true,
        cancelNotFoundCovered: Bool = true,
        reconciliationMismatchCovered: Bool = true,
        omsStatesExplainable: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors
    ) throws {
        guard evidence.count == Self.requiredFailureCases.count,
              Set(evidence.map(\.simulationCase)) == Set(Self.requiredFailureCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.caseCoverage",
                expected: Self.requiredFailureCases.map(\.rawValue).joined(separator: ","),
                actual: evidence.map(\.simulationCase.rawValue).joined(separator: ",")
            )
        }
        try Self.validateAppendOnlyChain(evidence)
        guard evidence.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.unheldReportEvidence")
        }
        guard appendOnlyChecksumChainVerified,
              allFailuresFailClosed,
              redactedFailureEvidence,
              signedTransportFailuresCovered,
              cancelNotFoundCovered,
              reconciliationMismatchCovered,
              omsStatesExplainable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.unheldReportBoundary")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.report.validationAnchors",
                expected: ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        let latestChecksum = evidence[evidence.index(before: evidence.endIndex)].failureChecksum
        guard reportID == Self.deterministicID(latestFailureChecksum: latestChecksum, evidenceIDs: evidence.map(\.evidenceID)) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.reportID",
                expected: Self.deterministicID(
                    latestFailureChecksum: latestChecksum,
                    evidenceIDs: evidence.map(\.evidenceID)
                ).rawValue,
                actual: reportID.rawValue
            )
        }

        self.reportID = reportID
        self.evidence = evidence
        self.failureCasesCovered = Self.requiredFailureCases
        self.latestFailureChecksum = latestChecksum
        self.appendOnlyChecksumChainVerified = appendOnlyChecksumChainVerified
        self.allFailuresFailClosed = allFailuresFailClosed
        self.redactedFailureEvidence = redactedFailureEvidence
        self.signedTransportFailuresCovered = signedTransportFailuresCovered
        self.cancelNotFoundCovered = cancelNotFoundCovered
        self.reconciliationMismatchCovered = reconciliationMismatchCovered
        self.omsStatesExplainable = omsStatesExplainable
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        evidence.count == Self.requiredFailureCases.count
            && Set(evidence.map(\.simulationCase)) == Set(Self.requiredFailureCases)
            && evidence.allSatisfy(\.boundaryHeld)
            && appendOnlyChecksumChainVerified
            && allFailuresFailClosed
            && redactedFailureEvidence
            && signedTransportFailuresCovered
            && cancelNotFoundCovered
            && reconciliationMismatchCovered
            && omsStatesExplainable
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors
    }

    public static let requiredFailureCases: [ReleaseV0150BinanceSpotTestnetFailureSimulationCase] = [
        .rejectedRequest,
        .timeout,
        .rateLimit,
        .staleCredential,
        .badSignature,
        .cancelNotFound,
        .reconciliationMismatch
    ]

    public static func deterministicID(
        latestFailureChecksum: String,
        evidenceIDs: [Identifier]
    ) -> Identifier {
        .constant(
            [
                "gh-1075-v0150-failure-simulation-report",
                latestFailureChecksum,
                "\(evidenceIDs.count)",
                evidenceIDs.last?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0150FailureSimulation.reportID"
        )
    }

    public static func validateAppendOnlyChain(
        _ evidence: [ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence]
    ) throws {
        guard evidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.evidence",
                expected: "at least one failure simulation evidence",
                actual: "empty"
            )
        }
        var previousChecksum: String?
        for (index, item) in evidence.enumerated() {
            guard item.boundaryHeld else {
                throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.chain.unheldEvidence")
            }
            guard item.sequenceNumber == index + 1 else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0150FailureSimulation.chain.sequenceNumber",
                    expected: "\(index + 1)",
                    actual: "\(item.sequenceNumber)"
                )
            }
            guard item.previousFailureChecksum == previousChecksum else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0150FailureSimulation.chain.previousFailureChecksum",
                    expected: previousChecksum ?? "<nil>",
                    actual: item.previousFailureChecksum ?? "<nil>"
                )
            }
            previousChecksum = item.failureChecksum
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.report.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetFailureSimulationSuite 生成 #1075 本地 deterministic failure report。
///
/// Suite 不依赖真实 transport，不执行网络动作，不读取环境变量或 secret store。它只用固定 identity
/// 和 checksum 链路证明失败路径可解释、脱敏、append-only，并且始终 fail closed。
public struct ReleaseV0150BinanceSpotTestnetFailureSimulationSuite: Codable, Equatable, Sendable {
    public let suiteID: Identifier
    public let validationAnchors: [String]
    public let failureSimulationOnly: Bool
    public let deterministicFailureSimulation: Bool
    public let testnetEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        suiteID: Identifier = Identifier.constant(
            "gh-1075-v0150-failure-simulation-suite",
            field: "releaseV0150FailureSimulation.suiteID"
        ),
        validationAnchors: [String] = ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors,
        failureSimulationOnly: Bool = true,
        deterministicFailureSimulation: Bool = true,
        testnetEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard validationAnchors == ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150FailureSimulation.suite.validationAnchors",
                expected: ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard failureSimulationOnly, deterministicFailureSimulation, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.suiteBoundary")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.suiteID = suiteID
        self.validationAnchors = validationAnchors
        self.failureSimulationOnly = failureSimulationOnly
        self.deterministicFailureSimulation = deterministicFailureSimulation
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        validationAnchors == ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.requiredValidationAnchors
            && failureSimulationOnly
            && deterministicFailureSimulation
            && testnetEvidenceOnly
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public func run(
        observedAtBaseMilliseconds: Int64 = 1_704_068_000_000
    ) throws -> ReleaseV0150BinanceSpotTestnetFailureSimulationReport {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.unheldSuite")
        }
        var previousChecksum: String?
        var evidence: [ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence] = []

        for (index, simulationCase) in ReleaseV0150BinanceSpotTestnetFailureSimulationReport.requiredFailureCases.enumerated() {
            let nextEvidence = try Self.makeEvidence(
                sequenceNumber: index + 1,
                simulationCase: simulationCase,
                observedAtMilliseconds: observedAtBaseMilliseconds + Int64(index + 1),
                previousFailureChecksum: previousChecksum,
                validationAnchors: validationAnchors
            )
            evidence.append(nextEvidence)
            previousChecksum = nextEvidence.failureChecksum
        }

        let latestChecksum = evidence[evidence.index(before: evidence.endIndex)].failureChecksum
        return try ReleaseV0150BinanceSpotTestnetFailureSimulationReport(
            reportID: ReleaseV0150BinanceSpotTestnetFailureSimulationReport.deterministicID(
                latestFailureChecksum: latestChecksum,
                evidenceIDs: evidence.map(\.evidenceID)
            ),
            evidence: evidence,
            validationAnchors: validationAnchors
        )
    }

    private static func makeEvidence(
        sequenceNumber: Int,
        simulationCase: ReleaseV0150BinanceSpotTestnetFailureSimulationCase,
        observedAtMilliseconds: Int64,
        previousFailureChecksum: String?,
        validationAnchors: [String]
    ) throws -> ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence {
        let signedRequestID = Identifier.constant(
            "gh-1075-\(simulationCase.rawValue)-signed-request",
            field: "releaseV0150FailureSimulation.signedRequestID"
        )
        let credentialReferenceID = Identifier.constant(
            "gh-1075-\(simulationCase.rawValue)-credential-reference",
            field: "releaseV0150FailureSimulation.credentialReferenceID"
        )
        let redactedRequestDigest = ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.redactedDigest(
            simulationCase: simulationCase,
            sourceID: signedRequestID,
            suffix: "request"
        )
        let redactedResponseDigest = ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.redactedDigest(
            simulationCase: simulationCase,
            sourceID: signedRequestID,
            suffix: "response"
        )
        let checksum = ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.canonicalChecksum(
            sequenceNumber: sequenceNumber,
            simulationCase: simulationCase,
            actionKind: simulationCase.actionKind,
            sourceSignedRequestID: signedRequestID,
            sourceCredentialReferenceID: credentialReferenceID,
            redactedRequestDigest: redactedRequestDigest,
            redactedResponseDigest: redactedResponseDigest,
            simulatedHTTPStatusCode: simulationCase.simulatedHTTPStatusCode,
            expectedLifecycleState: simulationCase.expectedLifecycleState,
            reconciliationFailureReason: simulationCase.reconciliationFailureReason,
            failureDetail: simulationCase.failureDetail,
            observedAtMilliseconds: observedAtMilliseconds,
            previousFailureChecksum: previousFailureChecksum,
            validationAnchors: validationAnchors
        )

        return try ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence(
            evidenceID: ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence.deterministicID(
                sequenceNumber: sequenceNumber,
                simulationCase: simulationCase,
                failureChecksum: checksum
            ),
            sequenceNumber: sequenceNumber,
            simulationCase: simulationCase,
            sourceSignedRequestID: signedRequestID,
            sourceCredentialReferenceID: credentialReferenceID,
            redactedRequestDigest: redactedRequestDigest,
            redactedResponseDigest: redactedResponseDigest,
            observedAtMilliseconds: observedAtMilliseconds,
            previousFailureChecksum: previousFailureChecksum,
            failureChecksum: checksum,
            validationAnchors: validationAnchors
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150FailureSimulation.suite.\(field)")
        }
    }
}
