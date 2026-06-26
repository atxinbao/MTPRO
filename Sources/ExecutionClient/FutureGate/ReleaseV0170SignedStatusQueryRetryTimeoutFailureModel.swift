import Crypto
import DomainModel
import Foundation

// GH-1141 static contract boundary:
// signedStatusQueryRetryTimeoutFailureModel=ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel
// boundedRetry=true
// timeoutClassification=true
// classifiedFailureEvidence=true
// retryLimitFailClosed=true
// redactedFailureEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170SignedStatusQueryFailureReason 固定 GH-1141 status query 失败分类。
///
/// 分类只解释 Binance Spot Testnet status query 观察失败，不触发 production fallback、
/// broker fallback、submit / cancel / replace retry 或 production cutover。
public enum ReleaseV0170SignedStatusQueryFailureReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case timeout
    case retryableHTTPStatus
    case nonRetryableHTTPStatus
    case transportFailure
    case retryLimitExceeded
    case boundaryDrift
    case redactionPolicyViolation
}

/// ReleaseV0170SignedStatusQueryValidationStatus 是 GH-1141 wrapper 的顶层状态。
public enum ReleaseV0170SignedStatusQueryValidationStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case passed
    case failed
}

/// ReleaseV0170SignedStatusQueryRuntimeError 提供测试和 wrapper 内部使用的本地错误语义。
///
/// 它不包含 raw response body、API key、secret、raw order identity 或 endpoint payload。
public enum ReleaseV0170SignedStatusQueryRuntimeError:
    Error,
    Equatable,
    Sendable,
    CustomStringConvertible
{
    case timeout(milliseconds: Int)
    case transportFailure(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .timeout(milliseconds):
            "Release v0.17.0 signed status query timed out after \(milliseconds) ms"
        case let .transportFailure(detail):
            "Release v0.17.0 signed status query transport failure: \(detail)"
        case let .boundaryDrift(field):
            "Release v0.17.0 signed status query boundary drift: \(field)"
        }
    }
}

/// ReleaseV0170SignedStatusQueryRetryPolicy 定义 bounded retry / timeout contract。
///
/// `maxAttempts` 包含首次尝试；`perAttemptTimeoutMilliseconds` 是每次 status query
/// 的本地上限。二者都必须为正数，避免无界等待或无界 retry。
public struct ReleaseV0170SignedStatusQueryRetryPolicy:
    Codable,
    Equatable,
    Sendable
{
    public let maxAttempts: Int
    public let perAttemptTimeoutMilliseconds: Int
    public let retryableReasons: [ReleaseV0170SignedStatusQueryFailureReason]
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        maxAttempts > 0
            && maxAttempts <= 5
            && perAttemptTimeoutMilliseconds > 0
            && perAttemptTimeoutMilliseconds <= 30_000
            && retryableReasons.contains(.timeout)
            && retryableReasons.contains(.retryableHTTPStatus)
            && retryableReasons.contains(.transportFailure)
            && productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
    }

    public init(
        maxAttempts: Int = 3,
        perAttemptTimeoutMilliseconds: Int = 5_000,
        retryableReasons: [ReleaseV0170SignedStatusQueryFailureReason] = [
            .timeout,
            .retryableHTTPStatus,
            .transportFailure
        ],
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.maxAttempts = maxAttempts
        self.perAttemptTimeoutMilliseconds = perAttemptTimeoutMilliseconds
        self.retryableReasons = retryableReasons
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170SignedStatusQueryRetryPolicy",
                expected: "bounded retry, positive timeout, production disabled",
                actual: "maxAttempts=\(maxAttempts), timeout=\(perAttemptTimeoutMilliseconds)"
            )
        }
    }
}

/// ReleaseV0170SignedStatusQueryAttemptFailure 是单次 status query 尝试的脱敏失败证据。
public struct ReleaseV0170SignedStatusQueryAttemptFailure:
    Codable,
    Equatable,
    Sendable
{
    public let failureID: Identifier
    public let reason: ReleaseV0170SignedStatusQueryFailureReason
    public let field: String
    public let detail: String
    public let retryable: Bool
    public let failClosed: Bool

    public var failureHeld: Bool {
        failureID == Self.deterministicID(reason: reason, field: field, detail: detail)
            && field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && failClosed
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: detail).isEmpty
    }

    public init(
        reason: ReleaseV0170SignedStatusQueryFailureReason,
        field: String,
        detail: String,
        retryable: Bool,
        failClosed: Bool = true
    ) throws {
        let sanitizedDetail = Self.sanitizedDetail(detail)
        let trimmedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedField.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170SignedStatusFailure.field",
                expected: "non-empty field",
                actual: field
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0170SignedStatusFailure.failOpen")
        }

        self.failureID = Self.deterministicID(
            reason: reason,
            field: trimmedField,
            detail: sanitizedDetail
        )
        self.reason = reason
        self.field = trimmedField
        self.detail = sanitizedDetail
        self.retryable = retryable
        self.failClosed = failClosed

        guard failureHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170SignedStatusFailure",
                expected: "redacted fail-closed failure evidence",
                actual: reason.rawValue
            )
        }
    }

    public static func deterministicID(
        reason: ReleaseV0170SignedStatusQueryFailureReason,
        field: String,
        detail: String
    ) -> Identifier {
        .constant(
            "gh-1141-signed-status-failure:\(reason.rawValue):\(field):\(detail)",
            field: "releaseV0170SignedStatusFailure.failureID"
        )
    }

    private static func sanitizedDetail(_ detail: String) -> String {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return "redacted-empty-failure-detail"
        }
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return String(trimmed.prefix(160))
    }
}

/// ReleaseV0170SignedStatusQueryAttemptEvidence 记录每次 status query attempt 的审计事实。
public struct ReleaseV0170SignedStatusQueryAttemptEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let attemptID: Identifier
    public let attemptIndex: Int
    public let timeoutMilliseconds: Int
    public let status: ReleaseV0170SignedStatusQueryValidationStatus
    public let transportResultID: Identifier?
    public let failure: ReleaseV0170SignedStatusQueryAttemptFailure?
    public let retryScheduled: Bool
    public let testnetEndpointOnly: Bool
    public let redactedFailureEvidenceOnly: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool

    public var attemptHeld: Bool {
        attemptID == Self.deterministicID(
            attemptIndex: attemptIndex,
            status: status,
            transportResultID: transportResultID,
            failureID: failure?.failureID
        )
            && attemptIndex > 0
            && timeoutMilliseconds > 0
            && testnetEndpointOnly
            && redactedFailureEvidenceOnly
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
            && ((status == .passed && transportResultID != nil && failure == nil && retryScheduled == false)
                || (status == .failed && failure?.failureHeld == true))
    }

    public init(
        attemptIndex: Int,
        timeoutMilliseconds: Int,
        status: ReleaseV0170SignedStatusQueryValidationStatus,
        transportResultID: Identifier?,
        failure: ReleaseV0170SignedStatusQueryAttemptFailure?,
        retryScheduled: Bool,
        testnetEndpointOnly: Bool = true,
        redactedFailureEvidenceOnly: Bool = true,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        self.attemptID = Self.deterministicID(
            attemptIndex: attemptIndex,
            status: status,
            transportResultID: transportResultID,
            failureID: failure?.failureID
        )
        self.attemptIndex = attemptIndex
        self.timeoutMilliseconds = timeoutMilliseconds
        self.status = status
        self.transportResultID = transportResultID
        self.failure = failure
        self.retryScheduled = retryScheduled
        self.testnetEndpointOnly = testnetEndpointOnly
        self.redactedFailureEvidenceOnly = redactedFailureEvidenceOnly
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted

        guard attemptHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170SignedStatusAttemptEvidence",
                expected: "bounded redacted attempt evidence",
                actual: "attempt=\(attemptIndex), status=\(status.rawValue)"
            )
        }
    }

    public static func deterministicID(
        attemptIndex: Int,
        status: ReleaseV0170SignedStatusQueryValidationStatus,
        transportResultID: Identifier?,
        failureID: Identifier?
    ) -> Identifier {
        .constant(
            [
                "gh-1141-signed-status-attempt",
                "\(attemptIndex)",
                status.rawValue,
                transportResultID?.rawValue ?? "none",
                failureID?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0170SignedStatusAttempt.attemptID"
        )
    }
}

/// ReleaseV0170SignedStatusQueryResult 汇总 bounded retry / timeout 后的最终证据。
public struct ReleaseV0170SignedStatusQueryResult:
    Codable,
    Equatable,
    Sendable
{
    public let resultID: Identifier
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let releaseVersion: String
    public let mode: ReleaseV0170OperatorBetaHardeningMode
    public let status: ReleaseV0170SignedStatusQueryValidationStatus
    public let signedStatusQueryRequestID: Identifier
    public let finalTransportResultID: Identifier?
    public let finalTransportResult: ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult?
    public let attempts: [ReleaseV0170SignedStatusQueryAttemptEvidence]
    public let retryPolicy: ReleaseV0170SignedStatusQueryRetryPolicy
    public let boundedRetry: Bool
    public let timeoutClassification: Bool
    public let classifiedFailureEvidence: Bool
    public let retryLimitFailClosed: Bool
    public let redactedFailureEvidenceOnly: Bool
    public let testnetEndpointOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var resultHeld: Bool {
        issueID.rawValue == "GH-1141"
            && blockedByIssueID.rawValue == "GH-1139"
            && releaseVersion == "v0.17.0"
            && mode == .signedStatusRetryTimeoutFailureModel
            && attempts.isEmpty == false
            && attempts.count <= retryPolicy.maxAttempts
            && attempts.allSatisfy(\.attemptHeld)
            && retryPolicy.boundaryHeld
            && boundedRetry
            && timeoutClassification
            && classifiedFailureEvidence
            && retryLimitFailClosed
            && redactedFailureEvidenceOnly
            && testnetEndpointOnly
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
            && finalTransportResultID == finalTransportResult?.transportResultID
            && ((status == .passed && finalTransportResultID != nil && finalTransportResult?.boundaryHeld == true && attempts.last?.status == .passed)
                || (status == .failed && finalTransportResultID == nil && finalTransportResult == nil && attempts.last?.status == .failed))
            && resultID == Self.deterministicID(
                signedStatusQueryRequestID: signedStatusQueryRequestID,
                status: status,
                attempts: attempts,
                finalTransportResultID: finalTransportResultID
            )
    }

    public var failures: [ReleaseV0170SignedStatusQueryAttemptFailure] {
        attempts.compactMap(\.failure)
    }

    public init(
        signedStatusQueryRequestID: Identifier,
        status: ReleaseV0170SignedStatusQueryValidationStatus,
        finalTransportResultID: Identifier?,
        finalTransportResult: ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult? = nil,
        attempts: [ReleaseV0170SignedStatusQueryAttemptEvidence],
        retryPolicy: ReleaseV0170SignedStatusQueryRetryPolicy,
        issueID: Identifier = .constant("GH-1141"),
        blockedByIssueID: Identifier = .constant("GH-1139"),
        releaseVersion: String = "v0.17.0",
        mode: ReleaseV0170OperatorBetaHardeningMode = .signedStatusRetryTimeoutFailureModel,
        boundedRetry: Bool = true,
        timeoutClassification: Bool = true,
        classifiedFailureEvidence: Bool = true,
        retryLimitFailClosed: Bool = true,
        redactedFailureEvidenceOnly: Bool = true,
        testnetEndpointOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        self.resultID = Self.deterministicID(
            signedStatusQueryRequestID: signedStatusQueryRequestID,
            status: status,
            attempts: attempts,
            finalTransportResultID: finalTransportResultID
        )
        self.issueID = issueID
        self.blockedByIssueID = blockedByIssueID
        self.releaseVersion = releaseVersion
        self.mode = mode
        self.status = status
        self.signedStatusQueryRequestID = signedStatusQueryRequestID
        self.finalTransportResultID = finalTransportResultID
        self.finalTransportResult = finalTransportResult
        self.attempts = attempts
        self.retryPolicy = retryPolicy
        self.boundedRetry = boundedRetry
        self.timeoutClassification = timeoutClassification
        self.classifiedFailureEvidence = classifiedFailureEvidence
        self.retryLimitFailClosed = retryLimitFailClosed
        self.redactedFailureEvidenceOnly = redactedFailureEvidenceOnly
        self.testnetEndpointOnly = testnetEndpointOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard resultHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170SignedStatusQueryResult",
                expected: "bounded retry timeout classified failure result",
                actual: status.rawValue
            )
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL",
        "TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL",
        "V0170-003-BOUNDED-STATUS-QUERY-RETRY",
        "V0170-003-PER-ATTEMPT-TIMEOUT",
        "V0170-003-CLASSIFIED-FAILURE-EVIDENCE",
        "V0170-003-RETRY-LIMIT-FAIL-CLOSED",
        "V0170-003-REDACTED-FAILURE-EVIDENCE",
        "V0170-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1141ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel",
        "bash checks/verify-v0.17.0-signed-status-query-retry-timeout-failure-model.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(
        signedStatusQueryRequestID: Identifier,
        status: ReleaseV0170SignedStatusQueryValidationStatus,
        attempts: [ReleaseV0170SignedStatusQueryAttemptEvidence],
        finalTransportResultID: Identifier?
    ) -> Identifier {
        .constant(
            [
                "gh-1141-signed-status-query-result",
                signedStatusQueryRequestID.rawValue,
                status.rawValue,
                attempts.map(\.attemptID.rawValue).joined(separator: "|"),
                finalTransportResultID?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0170SignedStatusQueryResult.resultID"
        )
    }
}

/// ReleaseV0170SignedStatusQueryRetryTimeoutFailureError 让旧 CLI path 保持 throwing 行为。
public struct ReleaseV0170SignedStatusQueryRetryTimeoutFailureError:
    Error,
    Equatable,
    Sendable,
    CustomStringConvertible
{
    public let result: ReleaseV0170SignedStatusQueryResult

    public var description: String {
        let reasons = result.failures.map(\.reason.rawValue).joined(separator: ",")
        return "Release v0.17.0 signed status query failed closed: \(reasons)"
    }
}

public typealias ReleaseV0170SignedStatusQueryAttemptOperation = @Sendable (
    Int,
    ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
    ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
    ReleaseV0150BinanceSpotTestnetCredentialMaterial
) async throws -> ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult

/// ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel 执行 GH-1141 bounded status query wrapper。
///
/// Wrapper 只调用注入的 Binance Spot Testnet status query transport，不构造 production URL，
/// 不读取 production secret，不做 submit / cancel / replace retry。失败只输出分类证据并 fail closed。
public struct ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel: Sendable {
    public init() {}

    public func execute(
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        retryPolicy: ReleaseV0170SignedStatusQueryRetryPolicy,
        transport: any ReleaseV0160BinanceSpotTestnetOrderStatusTransport
    ) async throws -> ReleaseV0170SignedStatusQueryResult {
        try await execute(
            signedRequest: signedRequest,
            orderIdentity: orderIdentity,
            credential: credential,
            retryPolicy: retryPolicy
        ) { _, request, identity, material in
            try await transport.querySpotTestnetOrderStatus(
                signedRequest: request,
                orderIdentity: identity,
                credential: material
            )
        }
    }

    public func execute(
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        retryPolicy: ReleaseV0170SignedStatusQueryRetryPolicy,
        operation: @escaping ReleaseV0170SignedStatusQueryAttemptOperation
    ) async throws -> ReleaseV0170SignedStatusQueryResult {
        guard signedRequest.boundaryHeld,
              signedRequest.endpointHost == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.canonicalSpotTestnetHost,
              signedRequest.httpMethod == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.httpMethod,
              orderIdentity.reference.sourceSubmitRuntimeEvidenceID == signedRequest.sourceSubmitRuntimeEvidenceID,
              credential.reference.referenceID == signedRequest.credentialReferenceID,
              retryPolicy.boundaryHeld else {
            let failure = try ReleaseV0170SignedStatusQueryAttemptFailure(
                reason: .boundaryDrift,
                field: "preflight",
                detail: "signed status query preflight boundary drift",
                retryable: false
            )
            let attempt = try ReleaseV0170SignedStatusQueryAttemptEvidence(
                attemptIndex: 1,
                timeoutMilliseconds: max(retryPolicy.perAttemptTimeoutMilliseconds, 1),
                status: .failed,
                transportResultID: nil,
                failure: failure,
                retryScheduled: false
            )
            return try ReleaseV0170SignedStatusQueryResult(
                signedStatusQueryRequestID: signedRequest.requestID,
                status: .failed,
                finalTransportResultID: nil,
                attempts: [attempt],
                retryPolicy: retryPolicy
            )
        }

        var attempts: [ReleaseV0170SignedStatusQueryAttemptEvidence] = []
        for attemptIndex in 1...retryPolicy.maxAttempts {
            do {
                let transportResult = try await Self.withTimeout(
                    milliseconds: retryPolicy.perAttemptTimeoutMilliseconds
                ) {
                    try await operation(attemptIndex, signedRequest, orderIdentity, credential)
                }
                guard transportResult.boundaryHeld,
                      transportResult.signedStatusQueryRequestID == signedRequest.requestID else {
                    throw ReleaseV0170SignedStatusQueryRuntimeError.boundaryDrift("transportResult")
                }
                attempts.append(try ReleaseV0170SignedStatusQueryAttemptEvidence(
                    attemptIndex: attemptIndex,
                    timeoutMilliseconds: retryPolicy.perAttemptTimeoutMilliseconds,
                    status: .passed,
                    transportResultID: transportResult.transportResultID,
                    failure: nil,
                    retryScheduled: false
                ))
                return try ReleaseV0170SignedStatusQueryResult(
                    signedStatusQueryRequestID: signedRequest.requestID,
                    status: .passed,
                    finalTransportResultID: transportResult.transportResultID,
                    finalTransportResult: transportResult,
                    attempts: attempts,
                    retryPolicy: retryPolicy
                )
            } catch {
                let classified = try Self.classifiedFailure(
                    error,
                    retryPolicy: retryPolicy
                )
                let shouldRetry = classified.retryable && attemptIndex < retryPolicy.maxAttempts
                attempts.append(try ReleaseV0170SignedStatusQueryAttemptEvidence(
                    attemptIndex: attemptIndex,
                    timeoutMilliseconds: retryPolicy.perAttemptTimeoutMilliseconds,
                    status: .failed,
                    transportResultID: nil,
                    failure: classified,
                    retryScheduled: shouldRetry
                ))
                if shouldRetry == false {
                    break
                }
            }
        }

        let finalAttempts: [ReleaseV0170SignedStatusQueryAttemptEvidence]
        if attempts.count == retryPolicy.maxAttempts,
           let lastFailure = attempts.last?.failure,
           lastFailure.retryable {
            let limitFailure = try ReleaseV0170SignedStatusQueryAttemptFailure(
                reason: .retryLimitExceeded,
                field: "retryLimit",
                detail: "maxAttempts=\(retryPolicy.maxAttempts)",
                retryable: false
            )
            finalAttempts = Array(attempts.dropLast()) + [
                try ReleaseV0170SignedStatusQueryAttemptEvidence(
                    attemptIndex: attempts.count,
                    timeoutMilliseconds: retryPolicy.perAttemptTimeoutMilliseconds,
                    status: .failed,
                    transportResultID: nil,
                    failure: limitFailure,
                    retryScheduled: false
                )
            ]
        } else {
            finalAttempts = attempts
        }

        return try ReleaseV0170SignedStatusQueryResult(
            signedStatusQueryRequestID: signedRequest.requestID,
            status: .failed,
            finalTransportResultID: nil,
            attempts: finalAttempts,
            retryPolicy: retryPolicy
        )
    }

    public static func classifiedFailure(
        _ error: Error,
        retryPolicy: ReleaseV0170SignedStatusQueryRetryPolicy
    ) throws -> ReleaseV0170SignedStatusQueryAttemptFailure {
        let reason = Self.classifiedReason(error)
        return try ReleaseV0170SignedStatusQueryAttemptFailure(
            reason: reason,
            field: Self.classifiedField(error),
            detail: String(describing: error),
            retryable: retryPolicy.retryableReasons.contains(reason)
        )
    }

    public static func classifiedReason(_ error: Error) -> ReleaseV0170SignedStatusQueryFailureReason {
        if let runtimeError = error as? ReleaseV0170SignedStatusQueryRuntimeError {
            switch runtimeError {
            case .timeout:
                return .timeout
            case .boundaryDrift:
                return .boundaryDrift
            case .transportFailure:
                return .transportFailure
            }
        }
        if let transportError = error as? ReleaseV0151BinanceSpotTestnetURLSessionTransportError {
            switch transportError {
            case let .httpStatus(code) where code == 408 || code == 429 || code >= 500:
                return .retryableHTTPStatus
            case .httpStatus:
                return .nonRetryableHTTPStatus
            case .invalidBaseURL, .productionHostForbidden, .invalidRequestURL, .invalidTimeout, .nonHTTPResponse:
                return .boundaryDrift
            }
        }
        if String(describing: error).localizedCaseInsensitiveContains("timeout") {
            return .timeout
        }
        return .transportFailure
    }

    private static func classifiedField(_ error: Error) -> String {
        switch classifiedReason(error) {
        case .timeout:
            "timeout"
        case .retryableHTTPStatus, .nonRetryableHTTPStatus:
            "httpStatus"
        case .transportFailure:
            "transport"
        case .retryLimitExceeded:
            "retryLimit"
        case .boundaryDrift:
            "boundary"
        case .redactionPolicyViolation:
            "redaction"
        }
    }

    private static func withTimeout<T: Sendable>(
        milliseconds: Int,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                let nanoseconds = UInt64(milliseconds) * 1_000_000
                try await Task.sleep(nanoseconds: nanoseconds)
                throw ReleaseV0170SignedStatusQueryRuntimeError.timeout(milliseconds: milliseconds)
            }
            guard let value = try await group.next() else {
                throw ReleaseV0170SignedStatusQueryRuntimeError.timeout(milliseconds: milliseconds)
            }
            group.cancelAll()
            return value
        }
    }
}
