import DomainModel
import Foundation

// GH-1107 static contract boundary:
// omsObservedStatusReconciliation=ReleaseV0160OMSObservedStatusReconciliationEngine
// submitObservedReconciliation=true
// cancelObservedReconciliation=true
// unknownStatusFailsClosed=true
// mismatchFailsClosed=true
// localArtifactsOnly=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0160OMSObservedStatusReconciliationError 描述 GH-1107 本地 OMS observed-status reconciliation 的 fail-closed 错误。
///
/// 本错误只覆盖 v0.16.0 Binance Spot Testnet operator beta 的本地 artifact 对账。它不读取 secret，
/// 不连接 endpoint，不发送 submit / cancel / replace，也不授权 production cutover。
public enum ReleaseV0160OMSObservedStatusReconciliationError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyEvidence(String)
    case invalidArtifactKind(expected: String, actual: String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .emptyEvidence(field):
            "Release v0.16.0 OMS observed status reconciliation requires non-empty evidence: \(field)"
        case let .invalidArtifactKind(expected, actual):
            "Release v0.16.0 OMS observed status reconciliation artifact kind mismatch: expected \(expected), actual \(actual)"
        case let .boundaryDrift(field):
            "Release v0.16.0 OMS observed status reconciliation boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160OMSObservedStatusReconciliationStatus 是 GH-1107 report 的顶层结果。
public enum ReleaseV0160OMSObservedStatusReconciliationStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case passed
    case failed
}

/// ReleaseV0160OMSExpectedObservationState 表达本地 OMS 期望达到的观测态。
///
/// 该状态只来自 submit / cancel / status 本地 artifact 组合，不代表 broker fill 或 production OMS。
public enum ReleaseV0160OMSExpectedObservationState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitObserved
    case cancelObserved
}

/// ReleaseV0160BinanceSpotTestnetObservedOrderStatus 固定 GH-1107 可接受的 Binance Spot Testnet status vocabulary。
public enum ReleaseV0160BinanceSpotTestnetObservedOrderStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case new = "NEW"
    case partiallyFilled = "PARTIALLY_FILLED"
    case filled = "FILLED"
    case canceled = "CANCELED"
    case rejected = "REJECTED"
    case expired = "EXPIRED"
    case unknown = "UNKNOWN"

    public init(rawBinanceStatus: String) {
        let normalized = rawBinanceStatus.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self = Self(rawValue: normalized) ?? .unknown
    }

    public var compatibleOMSStates: Set<ReleaseV0160OMSExpectedObservationState> {
        switch self {
        case .new, .partiallyFilled, .filled:
            [.submitObserved]
        case .canceled:
            [.cancelObserved]
        case .rejected, .expired, .unknown:
            []
        }
    }
}

/// ReleaseV0160OMSObservedStatusFailureReason 枚举 GH-1107 必须显式暴露的 fail-closed 差异。
public enum ReleaseV0160OMSObservedStatusFailureReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case missingSubmitArtifact
    case missingCancelArtifact
    case missingStatusArtifact
    case unknownObservedStatus
    case submitStateMismatch
    case cancelStateMismatch
    case artifactKindMismatch
    case boundaryDrift
}

/// ReleaseV0160OMSObservedStatusEvidence 是从 status artifact 和脱敏 status 枚举生成的观测输入。
///
/// Evidence 只保存 status artifact identity、checksum 和规范化 status。raw response、raw order id、
/// API key、secret、broker payload 和 production endpoint 不进入该结构。
public struct ReleaseV0160OMSObservedStatusEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let runID: Identifier
    public let statusArtifactRecordID: Identifier
    public let statusArtifactChecksum: String
    public let observedStatus: ReleaseV0160BinanceSpotTestnetObservedOrderStatus
    public let rawStatusRedacted: Bool
    public let sourceStatusArtifactConsumed: Bool
    public let redactedEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        statusArtifact: ReleaseV0160LocalExecutionArtifactRecord,
        rawBinanceStatus: String,
        rawStatusRedacted: Bool = true,
        sourceStatusArtifactConsumed: Bool = true,
        redactedEvidenceOnly: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard statusArtifact.kind == .status else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.invalidArtifactKind(
                expected: ReleaseV0160LocalExecutionArtifactKind.status.rawValue,
                actual: statusArtifact.kind.rawValue
            )
        }
        let observedStatus = ReleaseV0160BinanceSpotTestnetObservedOrderStatus(rawBinanceStatus: rawBinanceStatus)
        self.evidenceID = Self.deterministicID(
            runID: statusArtifact.runID,
            statusArtifactRecordID: statusArtifact.recordID,
            observedStatus: observedStatus
        )
        self.runID = statusArtifact.runID
        self.statusArtifactRecordID = statusArtifact.recordID
        self.statusArtifactChecksum = statusArtifact.recordChecksum
        self.observedStatus = observedStatus
        self.rawStatusRedacted = rawStatusRedacted
        self.sourceStatusArtifactConsumed = sourceStatusArtifactConsumed
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard boundaryHeld else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("observedStatusEvidence")
        }
    }

    public var boundaryHeld: Bool {
        runID.rawValue.isEmpty == false
            && statusArtifactRecordID.rawValue.isEmpty == false
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(statusArtifactChecksum)
            && rawStatusRedacted
            && sourceStatusArtifactConsumed
            && redactedEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        runID: Identifier,
        statusArtifactRecordID: Identifier,
        observedStatus: ReleaseV0160BinanceSpotTestnetObservedOrderStatus
    ) -> Identifier {
        .constant(
            "gh-1107-v0160-oms-observed-status:\(runID.rawValue):\(statusArtifactRecordID.rawValue):\(observedStatus.rawValue)",
            field: "releaseV0160OMSObservedStatusReconciliation.evidenceID"
        )
    }
}

/// ReleaseV0160OMSObservedStatusReconciliationFailure 是 GH-1107 的 fail-closed mismatch 证据。
public struct ReleaseV0160OMSObservedStatusReconciliationFailure: Codable, Equatable, Sendable {
    public let failureID: Identifier
    public let reason: ReleaseV0160OMSObservedStatusFailureReason
    public let expected: String
    public let actual: String
    public let failClosed: Bool

    public init(
        reason: ReleaseV0160OMSObservedStatusFailureReason,
        expected: String,
        actual: String,
        failClosed: Bool = true
    ) throws {
        guard expected.isEmpty == false, actual.isEmpty == false else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.emptyEvidence("failure expected/actual")
        }
        guard failClosed else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("failure.failClosed")
        }
        self.failureID = Self.deterministicID(reason: reason, expected: expected, actual: actual)
        self.reason = reason
        self.expected = expected
        self.actual = actual
        self.failClosed = failClosed
    }

    public var boundaryHeld: Bool {
        expected.isEmpty == false && actual.isEmpty == false && failClosed
    }

    public static func deterministicID(
        reason: ReleaseV0160OMSObservedStatusFailureReason,
        expected: String,
        actual: String
    ) -> Identifier {
        .constant(
            "gh-1107-v0160-oms-reconciliation-failure:\(reason.rawValue):\(expected):\(actual)",
            field: "releaseV0160OMSObservedStatusReconciliation.failureID"
        )
    }
}

/// ReleaseV0160OMSObservedStatusReconciliationReport 是 #1107 的本地 reconciliation 输出。
///
/// Report 只汇总 submit / cancel / status 本地 artifact 和脱敏 status observation。任何 unknown、
/// 缺失 artifact 或状态不一致都会生成 fail-closed failure，而不会触发网络或订单动作。
public struct ReleaseV0160OMSObservedStatusReconciliationReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let runID: Identifier
    public let expectedState: ReleaseV0160OMSExpectedObservationState
    public let observedStatusEvidenceID: Identifier
    public let observedStatus: ReleaseV0160BinanceSpotTestnetObservedOrderStatus
    public let submitArtifactRecordID: Identifier?
    public let cancelArtifactRecordID: Identifier?
    public let statusArtifactRecordID: Identifier?
    public let status: ReleaseV0160OMSObservedStatusReconciliationStatus
    public let failures: [ReleaseV0160OMSObservedStatusReconciliationFailure]
    public let submitObservedReconciliation: Bool
    public let cancelObservedReconciliation: Bool
    public let unknownStatusFailsClosed: Bool
    public let mismatchFailsClosed: Bool
    public let localArtifactsOnly: Bool
    public let sourceSubmitArtifactConsumed: Bool
    public let sourceCancelArtifactConsumed: Bool
    public let sourceStatusArtifactConsumed: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        runID: Identifier,
        expectedState: ReleaseV0160OMSExpectedObservationState,
        observedStatusEvidence: ReleaseV0160OMSObservedStatusEvidence,
        submitArtifact: ReleaseV0160LocalExecutionArtifactRecord?,
        cancelArtifact: ReleaseV0160LocalExecutionArtifactRecord?,
        statusArtifact: ReleaseV0160LocalExecutionArtifactRecord?,
        failures: [ReleaseV0160OMSObservedStatusReconciliationFailure],
        submitObservedReconciliation: Bool = true,
        cancelObservedReconciliation: Bool = true,
        unknownStatusFailsClosed: Bool = true,
        mismatchFailsClosed: Bool = true,
        localArtifactsOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard observedStatusEvidence.boundaryHeld,
              observedStatusEvidence.runID == runID,
              failures.allSatisfy(\.boundaryHeld) else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("report.sourceEvidence")
        }
        guard submitObservedReconciliation,
              cancelObservedReconciliation,
              unknownStatusFailsClosed,
              mismatchFailsClosed,
              localArtifactsOnly else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("report.guardFlags")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("report.validationAnchors")
        }

        let status: ReleaseV0160OMSObservedStatusReconciliationStatus = failures.isEmpty ? .passed : .failed
        self.reportID = Self.deterministicID(
            runID: runID,
            expectedState: expectedState,
            observedStatusEvidenceID: observedStatusEvidence.evidenceID,
            failureIDs: failures.map(\.failureID)
        )
        self.runID = runID
        self.expectedState = expectedState
        self.observedStatusEvidenceID = observedStatusEvidence.evidenceID
        self.observedStatus = observedStatusEvidence.observedStatus
        self.submitArtifactRecordID = submitArtifact?.recordID
        self.cancelArtifactRecordID = cancelArtifact?.recordID
        self.statusArtifactRecordID = statusArtifact?.recordID
        self.status = status
        self.failures = failures
        self.submitObservedReconciliation = submitObservedReconciliation
        self.cancelObservedReconciliation = cancelObservedReconciliation
        self.unknownStatusFailsClosed = unknownStatusFailsClosed
        self.mismatchFailsClosed = mismatchFailsClosed
        self.localArtifactsOnly = localArtifactsOnly
        self.sourceSubmitArtifactConsumed = submitArtifact != nil
        self.sourceCancelArtifactConsumed = cancelArtifact != nil
        self.sourceStatusArtifactConsumed = statusArtifact != nil
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard boundaryHeld else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("report.boundaryHeld")
        }
    }

    public var boundaryHeld: Bool {
        runID.rawValue.isEmpty == false
            && observedStatusEvidenceID.rawValue.isEmpty == false
            && (status == .passed ? failures.isEmpty : failures.isEmpty == false)
            && failures.allSatisfy(\.boundaryHeld)
            && submitObservedReconciliation
            && cancelObservedReconciliation
            && unknownStatusFailsClosed
            && mismatchFailsClosed
            && localArtifactsOnly
            && (status == .failed || sourceSubmitArtifactConsumed)
            && (status == .failed || sourceStatusArtifactConsumed)
            && (expectedState == .submitObserved || status == .failed || sourceCancelArtifactConsumed)
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1107-VERIFY-V0160-OMS-OBSERVED-STATUS-RECONCILIATION",
        "TVM-RELEASE-V0160-OMS-OBSERVED-STATUS-RECONCILIATION",
        "V0160-007-SUBMIT-OBSERVED-RECONCILIATION",
        "V0160-007-CANCEL-OBSERVED-RECONCILIATION",
        "V0160-007-UNKNOWN-STATUS-FAILS-CLOSED",
        "V0160-007-MISMATCH-FAILS-CLOSED",
        "V0160-007-LOCAL-ARTIFACTS-ONLY",
        "V0160-007-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        runID: Identifier,
        expectedState: ReleaseV0160OMSExpectedObservationState,
        observedStatusEvidenceID: Identifier,
        failureIDs: [Identifier]
    ) -> Identifier {
        .constant(
            [
                "gh-1107-v0160-oms-reconciliation-report",
                runID.rawValue,
                expectedState.rawValue,
                observedStatusEvidenceID.rawValue,
                "\(failureIDs.count)",
                failureIDs.last?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0160OMSObservedStatusReconciliation.reportID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("report.\(field)")
        }
    }
}

/// ReleaseV0160OMSObservedStatusReconciliationEngine 是 #1107 的无状态本地对账器。
///
/// Engine 只消费 #1106 replay records 和脱敏 status evidence，不读取 credential，不连接 endpoint，
/// 不发送 testnet 或 production order。
public struct ReleaseV0160OMSObservedStatusReconciliationEngine: Codable, Equatable, Sendable {
    public let engineID: Identifier
    public let submitObservedReconciliation: Bool
    public let cancelObservedReconciliation: Bool
    public let unknownStatusFailsClosed: Bool
    public let mismatchFailsClosed: Bool
    public let localArtifactsOnly: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        engineID: Identifier = Identifier.constant("gh-1107-v0160-oms-observed-status-reconciliation-engine"),
        submitObservedReconciliation: Bool = true,
        cancelObservedReconciliation: Bool = true,
        unknownStatusFailsClosed: Bool = true,
        mismatchFailsClosed: Bool = true,
        localArtifactsOnly: Bool = true,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0160OMSObservedStatusReconciliationReport.requiredValidationAnchors
    ) throws {
        self.engineID = engineID
        self.submitObservedReconciliation = submitObservedReconciliation
        self.cancelObservedReconciliation = cancelObservedReconciliation
        self.unknownStatusFailsClosed = unknownStatusFailsClosed
        self.mismatchFailsClosed = mismatchFailsClosed
        self.localArtifactsOnly = localArtifactsOnly
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard boundaryHeld else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("engine.boundaryHeld")
        }
    }

    public var boundaryHeld: Bool {
        engineID.rawValue.isEmpty == false
            && submitObservedReconciliation
            && cancelObservedReconciliation
            && unknownStatusFailsClosed
            && mismatchFailsClosed
            && localArtifactsOnly
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0160OMSObservedStatusReconciliationReport.requiredValidationAnchors
    }

    public func reconcile(
        replay: ReleaseV0160LocalExecutionArtifactReplay,
        observedStatusEvidence: ReleaseV0160OMSObservedStatusEvidence,
        expectedState: ReleaseV0160OMSExpectedObservationState
    ) throws -> ReleaseV0160OMSObservedStatusReconciliationReport {
        guard boundaryHeld, replay.replayHeld, replay.runID == observedStatusEvidence.runID else {
            throw ReleaseV0160OMSObservedStatusReconciliationError.boundaryDrift("engine.reconcile.source")
        }
        let recordsByKind = Dictionary(grouping: replay.records, by: \.kind)
        let submitArtifact = recordsByKind[.submit]?.last
        let cancelArtifact = recordsByKind[.cancel]?.last
        let statusArtifact = recordsByKind[.status]?.last
        var failures: [ReleaseV0160OMSObservedStatusReconciliationFailure] = []

        if submitArtifact == nil {
            failures.append(try failure(.missingSubmitArtifact, expected: "submit artifact", actual: "missing"))
        }
        if statusArtifact == nil || statusArtifact?.recordID != observedStatusEvidence.statusArtifactRecordID {
            failures.append(try failure(.missingStatusArtifact, expected: observedStatusEvidence.statusArtifactRecordID.rawValue, actual: statusArtifact?.recordID.rawValue ?? "missing"))
        }
        if expectedState == .cancelObserved, cancelArtifact == nil {
            failures.append(try failure(.missingCancelArtifact, expected: "cancel artifact", actual: "missing"))
        }
        if observedStatusEvidence.observedStatus == .unknown {
            failures.append(try failure(.unknownObservedStatus, expected: "known Binance Spot Testnet order status", actual: observedStatusEvidence.observedStatus.rawValue))
        } else if observedStatusEvidence.observedStatus.compatibleOMSStates.contains(expectedState) == false {
            let reason: ReleaseV0160OMSObservedStatusFailureReason = expectedState == .submitObserved ? .submitStateMismatch : .cancelStateMismatch
            failures.append(try failure(reason, expected: expectedState.rawValue, actual: observedStatusEvidence.observedStatus.rawValue))
        }

        return try ReleaseV0160OMSObservedStatusReconciliationReport(
            runID: observedStatusEvidence.runID,
            expectedState: expectedState,
            observedStatusEvidence: observedStatusEvidence,
            submitArtifact: submitArtifact,
            cancelArtifact: cancelArtifact,
            statusArtifact: statusArtifact,
            failures: failures
        )
    }

    private func failure(
        _ reason: ReleaseV0160OMSObservedStatusFailureReason,
        expected: String,
        actual: String
    ) throws -> ReleaseV0160OMSObservedStatusReconciliationFailure {
        try ReleaseV0160OMSObservedStatusReconciliationFailure(
            reason: reason,
            expected: expected,
            actual: actual
        )
    }
}
