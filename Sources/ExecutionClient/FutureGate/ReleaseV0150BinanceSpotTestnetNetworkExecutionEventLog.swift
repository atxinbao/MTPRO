import Crypto
import DomainModel
import Foundation

// GH-1071 静态合同边界：
// appendOnlyNetworkExecutionEventLog=true
// redactedRequestIdentity=true
// redactedResponseIdentity=true
// checksumChainVerified=true
// rawSecretPersisted=false
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind 是 v0.15.0 network action event log 的动作枚举。
///
/// 当前 event log 把已完成的 Spot Testnet submit / cancel / cancelReplace runtime evidence 写入 append-only event log。
/// `cancelReplace` 表示 #1070 cancel + new submit emulation 的聚合 artifact；本类型不实现 production
/// endpoint、broker endpoint 或真实订单。
public enum ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case cancelReplace
}

/// ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact 记录一次 testnet network action 的脱敏 artifact。
///
/// Artifact 只保存 request / response identity、HTTP 状态、生命周期状态、checksum chain 和生产禁区布尔值。
/// 它不保存 API key、secret、raw request body、raw response body 或交易所未脱敏 order payload。
public struct ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact: Codable, Equatable, Sendable, CustomStringConvertible {
    public let eventArtifactID: Identifier
    public let sequenceNumber: Int
    public let actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind
    public let actionEvidenceID: Identifier
    public let intentID: Identifier
    public let signedRequestID: Identifier
    public let transportResultID: Identifier
    public let credentialReferenceID: Identifier
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let orderLifecycleState: OrderLifecycleState
    public let observedAtMilliseconds: Int64
    public let previousArtifactChecksum: String?
    public let artifactChecksumAlgorithm: String
    public let artifactChecksum: String
    public let appendOnlyArtifact: Bool
    public let redactedRequestIdentity: Bool
    public let redactedResponseIdentity: Bool
    public let requestBodyRedacted: Bool
    public let responseBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let rawSecretPersisted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        eventArtifactID: Identifier,
        sequenceNumber: Int,
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind,
        actionEvidenceID: Identifier,
        intentID: Identifier,
        signedRequestID: Identifier,
        transportResultID: Identifier,
        credentialReferenceID: Identifier,
        endpointHost: String,
        endpointPath: String,
        httpStatusCode: Int,
        orderLifecycleState: OrderLifecycleState,
        observedAtMilliseconds: Int64,
        previousArtifactChecksum: String?,
        artifactChecksum: String,
        appendOnlyArtifact: Bool = true,
        redactedRequestIdentity: Bool = true,
        redactedResponseIdentity: Bool = true,
        requestBodyRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        rawSecretPersisted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sequenceNumber > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.sequenceNumber",
                expected: "positive append-only sequence",
                actual: "\(sequenceNumber)"
            )
        }
        guard observedAtMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.observedAtMilliseconds",
                expected: "positive unix epoch milliseconds",
                actual: "\(observedAtMilliseconds)"
            )
        }
        guard endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost,
              endpointPath == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.endpoint")
        }
        guard (200..<300).contains(httpStatusCode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.httpStatusCode",
                expected: "2xx Binance Spot Testnet response",
                actual: "\(httpStatusCode)"
            )
        }
        guard Self.allowedLifecycleStates[actionKind]?.contains(orderLifecycleState) == true else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.orderLifecycleState",
                expected: "lifecycle state compatible with \(actionKind.rawValue)",
                actual: orderLifecycleState.rawValue
            )
        }
        guard previousArtifactChecksum.map(Self.isLowercaseSHA256) ?? true else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.previousArtifactChecksum",
                expected: "nil or lowercase sha256 checksum",
                actual: previousArtifactChecksum ?? "<nil>"
            )
        }
        guard Self.isLowercaseSHA256(artifactChecksum) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.artifactChecksum",
                expected: "lowercase sha256 checksum",
                actual: artifactChecksum
            )
        }
        let expectedChecksum = Self.canonicalChecksum(
            sequenceNumber: sequenceNumber,
            actionKind: actionKind,
            actionEvidenceID: actionEvidenceID,
            intentID: intentID,
            signedRequestID: signedRequestID,
            transportResultID: transportResultID,
            credentialReferenceID: credentialReferenceID,
            endpointHost: endpointHost,
            endpointPath: endpointPath,
            httpStatusCode: httpStatusCode,
            orderLifecycleState: orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            validationAnchors: validationAnchors
        )
        guard artifactChecksum == expectedChecksum else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.artifactChecksum",
                expected: expectedChecksum,
                actual: artifactChecksum
            )
        }
        guard eventArtifactID == Self.deterministicID(
            sequenceNumber: sequenceNumber,
            actionKind: actionKind,
            artifactChecksum: artifactChecksum
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEvent.eventArtifactID",
                expected: Self.deterministicID(
                    sequenceNumber: sequenceNumber,
                    actionKind: actionKind,
                    artifactChecksum: artifactChecksum
                ).rawValue,
                actual: eventArtifactID.rawValue
            )
        }
        guard appendOnlyArtifact,
              redactedRequestIdentity,
              redactedResponseIdentity,
              requestBodyRedacted,
              responseBodyRedacted,
              credentialMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.unredactedArtifact")
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
                field: "releaseV0150NetworkEvent.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.eventArtifactID = eventArtifactID
        self.sequenceNumber = sequenceNumber
        self.actionKind = actionKind
        self.actionEvidenceID = actionEvidenceID
        self.intentID = intentID
        self.signedRequestID = signedRequestID
        self.transportResultID = transportResultID
        self.credentialReferenceID = credentialReferenceID
        self.endpointHost = endpointHost
        self.endpointPath = endpointPath
        self.httpStatusCode = httpStatusCode
        self.orderLifecycleState = orderLifecycleState
        self.observedAtMilliseconds = observedAtMilliseconds
        self.previousArtifactChecksum = previousArtifactChecksum
        self.artifactChecksumAlgorithm = Self.requiredChecksumAlgorithm
        self.artifactChecksum = artifactChecksum
        self.appendOnlyArtifact = appendOnlyArtifact
        self.redactedRequestIdentity = redactedRequestIdentity
        self.redactedResponseIdentity = redactedResponseIdentity
        self.requestBodyRedacted = requestBodyRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
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
        endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
            && (200..<300).contains(httpStatusCode)
            && Self.allowedLifecycleStates[actionKind]?.contains(orderLifecycleState) == true
            && artifactChecksumAlgorithm == Self.requiredChecksumAlgorithm
            && Self.isLowercaseSHA256(artifactChecksum)
            && appendOnlyArtifact
            && redactedRequestIdentity
            && redactedResponseIdentity
            && requestBodyRedacted
            && responseBodyRedacted
            && credentialMaterialRedacted
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
        "ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact(sequence: \(sequenceNumber), actionKind: \(actionKind.rawValue), request: \(signedRequestID.rawValue), response: \(transportResultID.rawValue), requestBody: <redacted>, responseBody: <redacted>, credentialMaterial: <redacted>, checksum: \(artifactChecksum))"
    }

    public static let requiredChecksumAlgorithm = "sha256"

    public static let requiredValidationAnchors = [
        "GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG",
        "TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG",
        "V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG",
        "V0150-006-REQUEST-RESPONSE-IDENTITY",
        "V0150-006-CHECKSUM-CHAIN",
        "V0150-006-RAW-SECRET-NOT-PERSISTED",
        "V0150-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let allowedLifecycleStates: [ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind: Set<OrderLifecycleState>] = [
        .submit: [.submittedTestnet, .accepted],
        .cancel: [.cancelRequested, .cancelled],
        .cancelReplace: [.replaceRequested, .replaced]
    ]

    public static func fromSubmitRuntimeEvidence(
        _ evidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        sequenceNumber: Int,
        observedAtMilliseconds: Int64,
        previousArtifactChecksum: String? = nil
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact {
        guard evidence.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.submitEvidence")
        }
        let checksum = canonicalChecksum(
            sequenceNumber: sequenceNumber,
            actionKind: .submit,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            validationAnchors: requiredValidationAnchors
        )
        return try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact(
            eventArtifactID: deterministicID(
                sequenceNumber: sequenceNumber,
                actionKind: .submit,
                artifactChecksum: checksum
            ),
            sequenceNumber: sequenceNumber,
            actionKind: .submit,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            artifactChecksum: checksum
        )
    }

    public static func fromCancelRuntimeEvidence(
        _ evidence: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence,
        sequenceNumber: Int,
        observedAtMilliseconds: Int64,
        previousArtifactChecksum: String
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact {
        guard evidence.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.cancelEvidence")
        }
        let checksum = canonicalChecksum(
            sequenceNumber: sequenceNumber,
            actionKind: .cancel,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedCancelRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            validationAnchors: requiredValidationAnchors
        )
        return try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact(
            eventArtifactID: deterministicID(
                sequenceNumber: sequenceNumber,
                actionKind: .cancel,
                artifactChecksum: checksum
            ),
            sequenceNumber: sequenceNumber,
            actionKind: .cancel,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedCancelRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            artifactChecksum: checksum
        )
    }

    public static func fromCancelReplaceRuntimeEvidence(
        _ evidence: ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence,
        sequenceNumber: Int,
        observedAtMilliseconds: Int64,
        previousArtifactChecksum: String
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact {
        guard evidence.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.cancelReplaceEvidence")
        }
        let checksum = canonicalChecksum(
            sequenceNumber: sequenceNumber,
            actionKind: .cancelReplace,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedReplacementRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            validationAnchors: requiredValidationAnchors
        )
        return try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact(
            eventArtifactID: deterministicID(
                sequenceNumber: sequenceNumber,
                actionKind: .cancelReplace,
                artifactChecksum: checksum
            ),
            sequenceNumber: sequenceNumber,
            actionKind: .cancelReplace,
            actionEvidenceID: evidence.runtimeEvidenceID,
            intentID: evidence.intentID,
            signedRequestID: evidence.signedReplacementRequestID,
            transportResultID: evidence.transportResultID,
            credentialReferenceID: evidence.credentialReferenceID,
            endpointHost: evidence.endpointHost,
            endpointPath: evidence.endpointPath,
            httpStatusCode: evidence.httpStatusCode,
            orderLifecycleState: evidence.orderLifecycleState,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: previousArtifactChecksum,
            artifactChecksum: checksum
        )
    }

    public static func deterministicID(
        sequenceNumber: Int,
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind,
        artifactChecksum: String
    ) -> Identifier {
        .constant(
            "gh-1071-v0150-network-event:\(sequenceNumber):\(actionKind.rawValue):\(artifactChecksum)",
            field: "releaseV0150NetworkEvent.eventArtifactID"
        )
    }

    public static func canonicalChecksum(
        sequenceNumber: Int,
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind,
        actionEvidenceID: Identifier,
        intentID: Identifier,
        signedRequestID: Identifier,
        transportResultID: Identifier,
        credentialReferenceID: Identifier,
        endpointHost: String,
        endpointPath: String,
        httpStatusCode: Int,
        orderLifecycleState: OrderLifecycleState,
        observedAtMilliseconds: Int64,
        previousArtifactChecksum: String?,
        validationAnchors: [String]
    ) -> String {
        let payload = [
            "gh-1071-v0150-network-event",
            "\(sequenceNumber)",
            actionKind.rawValue,
            actionEvidenceID.rawValue,
            intentID.rawValue,
            signedRequestID.rawValue,
            transportResultID.rawValue,
            credentialReferenceID.rawValue,
            endpointHost,
            endpointPath,
            "\(httpStatusCode)",
            orderLifecycleState.rawValue,
            "\(observedAtMilliseconds)",
            previousArtifactChecksum ?? "genesis",
            validationAnchors.joined(separator: "|")
        ].joined(separator: "\n")
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEvent.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog 表达 append-only checksum chain。
///
/// Log 只接受顺序递增、previous checksum 正确衔接、全部 boundary-held 的 event artifact。
/// 该类型不执行网络动作；它只把已完成的 v0.15.0 Spot Testnet network action evidence 固定为
/// replay-friendly artifact chain，供后续 OMS / reconciliation / Dashboard read-model 消费。
public struct ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog: Codable, Equatable, Sendable {
    public let logID: Identifier
    public let eventArtifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact]
    public let latestArtifactChecksum: String
    public let checksumChainVerified: Bool
    public let appendOnlyNetworkExecutionEventLog: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        logID: Identifier,
        eventArtifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact],
        checksumChainVerified: Bool = true,
        appendOnlyNetworkExecutionEventLog: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard eventArtifacts.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEventLog.eventArtifacts",
                expected: "at least one network execution event artifact",
                actual: "empty"
            )
        }
        try Self.validateAppendOnlyChain(eventArtifacts)
        guard checksumChainVerified, appendOnlyNetworkExecutionEventLog else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEventLog.unverifiedChain")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        let latestChecksum = eventArtifacts[eventArtifacts.index(before: eventArtifacts.endIndex)].artifactChecksum
        guard logID == Self.deterministicID(latestArtifactChecksum: latestChecksum, eventCount: eventArtifacts.count) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEventLog.logID",
                expected: Self.deterministicID(
                    latestArtifactChecksum: latestChecksum,
                    eventCount: eventArtifacts.count
                ).rawValue,
                actual: logID.rawValue
            )
        }

        self.logID = logID
        self.eventArtifacts = eventArtifacts
        self.latestArtifactChecksum = latestChecksum
        self.checksumChainVerified = checksumChainVerified
        self.appendOnlyNetworkExecutionEventLog = appendOnlyNetworkExecutionEventLog
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        eventArtifacts.isEmpty == false
            && eventArtifacts.allSatisfy(\.boundaryHeld)
            && checksumChainVerified
            && appendOnlyNetworkExecutionEventLog
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public func appending(
        _ eventArtifact: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog {
        try Self.make(eventArtifacts: eventArtifacts + [eventArtifact])
    }

    public static func make(
        eventArtifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact]
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog {
        try validateAppendOnlyChain(eventArtifacts)
        let latestChecksum = eventArtifacts[eventArtifacts.index(before: eventArtifacts.endIndex)].artifactChecksum
        return try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog(
            logID: deterministicID(latestArtifactChecksum: latestChecksum, eventCount: eventArtifacts.count),
            eventArtifacts: eventArtifacts
        )
    }

    public static func deterministicID(latestArtifactChecksum: String, eventCount: Int) -> Identifier {
        .constant(
            "gh-1071-v0150-network-event-log:\(eventCount):\(latestArtifactChecksum)",
            field: "releaseV0150NetworkEventLog.logID"
        )
    }

    public static func validateAppendOnlyChain(
        _ eventArtifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact]
    ) throws {
        guard eventArtifacts.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150NetworkEventLog.eventArtifacts",
                expected: "at least one event artifact",
                actual: "empty"
            )
        }
        var previousChecksum: String?
        for (index, event) in eventArtifacts.enumerated() {
            guard event.boundaryHeld else {
                throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEventLog.eventBoundary")
            }
            guard event.sequenceNumber == index + 1 else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0150NetworkEventLog.sequenceNumber",
                    expected: "\(index + 1)",
                    actual: "\(event.sequenceNumber)"
                )
            }
            guard event.previousArtifactChecksum == previousChecksum else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0150NetworkEventLog.previousArtifactChecksum",
                    expected: previousChecksum ?? "<nil>",
                    actual: event.previousArtifactChecksum ?? "<nil>"
                )
            }
            previousChecksum = event.artifactChecksum
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150NetworkEventLog.\(field)")
        }
    }
}
