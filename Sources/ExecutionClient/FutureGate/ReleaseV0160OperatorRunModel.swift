import Crypto
import DomainModel
import Foundation

/// ReleaseV0160OperatorRunModelError 描述 GH-1102 operator run model 的 fail-closed 错误。
///
/// 该错误只覆盖 Binance Spot Testnet operator beta 的本地 run id lifecycle、action sequence、
/// redacted metadata 和 artifact linkage。它不代表 testnet network runtime，不读取 credential value，
/// 不连接 testnet / production endpoint，也不授权 production order 或 production cutover。
public enum ReleaseV0160OperatorRunModelError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case invalidTransition(action: String, fromState: String)
    case eventRunIDMismatch(expected: Identifier, actual: Identifier)
    case eventSequenceMismatch(expected: Int, actual: Int)
    case checksumMismatch(field: String, expected: String, actual: String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.16.0 operator run model requires a non-empty runID"
        case let .invalidTransition(action, state):
            "Release v0.16.0 operator run model rejects \(action) from \(state)"
        case let .eventRunIDMismatch(expected, actual):
            "Release v0.16.0 operator run model runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .eventSequenceMismatch(expected, actual):
            "Release v0.16.0 operator run model sequence mismatch: expected \(expected), actual \(actual)"
        case let .checksumMismatch(field, expected, actual):
            "Release v0.16.0 operator run model checksum mismatch for \(field): expected \(expected), actual \(actual)"
        case let .boundaryDrift(field):
            "Release v0.16.0 operator run model boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160OperatorRunAction 固定 GH-1102 支持的 operator action sequence 词汇。
///
/// 这些 action 只是本地 run model 的 lifecycle 事件名称。submit / cancel / status / reconcile
/// runtime 仍由后续 GH-1103..GH-1107 分别授权，本 issue 不执行网络请求。
public enum ReleaseV0160OperatorRunAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case create
    case requestSubmit = "request-submit"
    case recordSubmitObserved = "record-submit-observed"
    case requestStatus = "request-status"
    case recordStatusObserved = "record-status-observed"
    case requestCancel = "request-cancel"
    case recordCancelObserved = "record-cancel-observed"
    case reconcile
    case fail
    case recover
    case close
}

/// ReleaseV0160OperatorRunState 固定 GH-1102 operator run lifecycle state。
public enum ReleaseV0160OperatorRunState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case initialized
    case created
    case submitRequested
    case submitObserved
    case statusRequested
    case statusObserved
    case cancelRequested
    case cancelObserved
    case reconciled
    case failed
    case recovered
    case closed
}

/// ReleaseV0160OperatorRunArtifactRole 固定 GH-1102 artifact linkage 的角色。
///
/// 所有 artifact 只允许存储 redacted evidence handle、path 和 checksum，不保存 raw request、
/// raw response、API key、secret、listen key 或 broker payload。
public enum ReleaseV0160OperatorRunArtifactRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case runMetadataJSON = "run-metadata.json"
    case actionEventsJSONL = "action-events.jsonl"
    case redactedExecutionEvidenceJSON = "redacted-execution-evidence.json"
    case statusSnapshotJSON = "status-snapshot.json"
    case reconciliationJSON = "reconciliation.json"
}

/// ReleaseV0160OperatorRunArtifactLink 描述 GH-1102 run model 输出的本地 artifact reference。
public struct ReleaseV0160OperatorRunArtifactLink: Codable, Equatable, Sendable {
    public let role: ReleaseV0160OperatorRunArtifactRole
    public let path: String
    public let checksum: String
    public let redacted: Bool
    public let containsCredentialValue: Bool
    public let containsRawBrokerPayload: Bool
    public let containsRawOrderIdentity: Bool

    public var linkHeld: Bool {
        path.hasPrefix(".local/mtpro/v0.16.0/operator-runs/")
            && path.hasSuffix(role.rawValue)
            && checksum == Self.stableChecksum(role: role, path: path)
            && redacted
            && containsCredentialValue == false
            && containsRawBrokerPayload == false
            && containsRawOrderIdentity == false
    }

    public init(
        role: ReleaseV0160OperatorRunArtifactRole,
        runID: Identifier,
        checksum: String? = nil,
        redacted: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawBrokerPayload: Bool = false,
        containsRawOrderIdentity: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160OperatorRunModelError.emptyRunID
        }
        let path = ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/\(role.rawValue)"
        self.role = role
        self.path = path
        self.checksum = checksum ?? Self.stableChecksum(role: role, path: path)
        self.redacted = redacted
        self.containsCredentialValue = containsCredentialValue
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.containsRawOrderIdentity = containsRawOrderIdentity

        guard linkHeld else {
            throw ReleaseV0160OperatorRunModelError.boundaryDrift("artifactLink.\(role.rawValue)")
        }
    }

    public static func stableChecksum(role: ReleaseV0160OperatorRunArtifactRole, path: String) -> String {
        stableSHA256([
            "GH-1102",
            "v0.16.0",
            "artifact-link",
            role.rawValue,
            path,
            "redacted=true",
            "containsCredentialValue=false",
            "containsRawBrokerPayload=false",
            "containsRawOrderIdentity=false"
        ])
    }
}

/// ReleaseV0160OperatorRunMetadata 是 GH-1102 的 run metadata 顶层 payload。
public struct ReleaseV0160OperatorRunMetadata: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let runRootPath: String
    public let venue: String
    public let productType: String
    public let operatorConfirmationPhrase: String
    public let createdAt: Date
    public let artifactLinks: [ReleaseV0160OperatorRunArtifactLink]
    public let allowedActions: [ReleaseV0160OperatorRunAction]
    public let metadataChecksum: String
    public let redactedMetadataOnly: Bool
    public let testnetCredentialValueReadEnabledByThisIssue: Bool
    public let testnetNetworkConnectionEnabledByThisIssue: Bool
    public let testnetOrderSubmissionImplementedByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var metadataHeld: Bool {
        issueID.rawValue == "GH-1102"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1101"]
            && releaseVersion == "v0.16.0"
            && runID.rawValue.isEmpty == false
            && runRootPath == ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)"
            && venue == "Binance"
            && productType == "spot"
            && operatorConfirmationPhrase == Self.requiredOperatorConfirmationPhrase
            && artifactLinks.count == ReleaseV0160OperatorRunArtifactRole.allCases.count
            && artifactLinks.allSatisfy(\.linkHeld)
            && Set(artifactLinks.map(\.role)) == Set(ReleaseV0160OperatorRunArtifactRole.allCases)
            && allowedActions == ReleaseV0160OperatorRunAction.allCases
            && metadataChecksum == Self.stableMetadataChecksum(
                runID: runID,
                runRootPath: runRootPath,
                createdAt: createdAt,
                artifactLinks: artifactLinks
            )
            && redactedMetadataOnly
            && testnetCredentialValueReadEnabledByThisIssue == false
            && testnetNetworkConnectionEnabledByThisIssue == false
            && testnetOrderSubmissionImplementedByThisIssue == false
            && productionDefaultsClosed
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1102"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1101")],
        releaseVersion: String = "v0.16.0",
        runID: Identifier,
        createdAt: Date,
        artifactLinks: [ReleaseV0160OperatorRunArtifactLink]? = nil,
        allowedActions: [ReleaseV0160OperatorRunAction] = ReleaseV0160OperatorRunAction.allCases,
        metadataChecksum: String? = nil,
        redactedMetadataOnly: Bool = true,
        testnetCredentialValueReadEnabledByThisIssue: Bool = false,
        testnetNetworkConnectionEnabledByThisIssue: Bool = false,
        testnetOrderSubmissionImplementedByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160OperatorRunModelError.emptyRunID
        }
        let runRootPath = ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)"
        let resolvedLinks = try artifactLinks ?? ReleaseV0160OperatorRunArtifactRole.allCases.map {
            try ReleaseV0160OperatorRunArtifactLink(role: $0, runID: runID)
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.runRootPath = runRootPath
        self.venue = "Binance"
        self.productType = "spot"
        self.operatorConfirmationPhrase = Self.requiredOperatorConfirmationPhrase
        self.createdAt = createdAt
        self.artifactLinks = resolvedLinks
        self.allowedActions = allowedActions
        self.metadataChecksum = metadataChecksum ?? Self.stableMetadataChecksum(
            runID: runID,
            runRootPath: runRootPath,
            createdAt: createdAt,
            artifactLinks: resolvedLinks
        )
        self.redactedMetadataOnly = redactedMetadataOnly
        self.testnetCredentialValueReadEnabledByThisIssue = testnetCredentialValueReadEnabledByThisIssue
        self.testnetNetworkConnectionEnabledByThisIssue = testnetNetworkConnectionEnabledByThisIssue
        self.testnetOrderSubmissionImplementedByThisIssue = testnetOrderSubmissionImplementedByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard metadataHeld else {
            throw ReleaseV0160OperatorRunModelError.boundaryDrift("runMetadata")
        }
    }

    public static let requiredOperatorConfirmationPhrase = "CONFIRM_BINANCE_SPOT_TESTNET_OPERATOR_BETA"

    public static func stableMetadataChecksum(
        runID: Identifier,
        runRootPath: String,
        createdAt: Date,
        artifactLinks: [ReleaseV0160OperatorRunArtifactLink]
    ) -> String {
        stableSHA256([
            "GH-1102",
            "v0.16.0",
            "operator-run-metadata",
            runID.rawValue,
            runRootPath,
            String(createdAt.timeIntervalSince1970),
            "venue=Binance",
            "productType=spot",
            "operatorConfirmationPhrase=\(requiredOperatorConfirmationPhrase)",
            "redactedMetadataOnly=true",
            "testnetCredentialValueReadEnabledByThisIssue=false",
            "testnetNetworkConnectionEnabledByThisIssue=false",
            "testnetOrderSubmissionImplementedByThisIssue=false",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false"
        ] + artifactLinks.map { "\($0.role.rawValue)=\($0.path)=\($0.checksum)" })
    }
}

/// ReleaseV0160OperatorRunEvent 是 GH-1102 action sequence 的单条本地事件。
public struct ReleaseV0160OperatorRunEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let runID: Identifier
    public let sequence: Int
    public let action: ReleaseV0160OperatorRunAction
    public let fromState: ReleaseV0160OperatorRunState
    public let toState: ReleaseV0160OperatorRunState
    public let operatorConfirmed: Bool
    public let redactedEvidenceOnly: Bool
    public let artifactRoles: [ReleaseV0160OperatorRunArtifactRole]
    public let previousEventChecksum: String?
    public let eventChecksum: String
    public let createdAt: Date
    public let testnetNetworkPerformedByThisIssue: Bool
    public let productionOrderSubmitted: Bool

    public var eventHeld: Bool {
        eventID == Self.deterministicID(runID: runID, sequence: sequence, action: action)
            && runID.rawValue.isEmpty == false
            && sequence > 0
            && operatorConfirmed
            && redactedEvidenceOnly
            && artifactRoles.isEmpty == false
            && Set(artifactRoles).isSubset(of: Set(ReleaseV0160OperatorRunArtifactRole.allCases))
            && eventChecksum == Self.stableEventChecksum(
                runID: runID,
                sequence: sequence,
                action: action,
                fromState: fromState,
                toState: toState,
                artifactRoles: artifactRoles,
                previousEventChecksum: previousEventChecksum,
                createdAt: createdAt
            )
            && testnetNetworkPerformedByThisIssue == false
            && productionOrderSubmitted == false
    }

    public init(
        runID: Identifier,
        sequence: Int,
        action: ReleaseV0160OperatorRunAction,
        fromState: ReleaseV0160OperatorRunState,
        toState: ReleaseV0160OperatorRunState,
        operatorConfirmed: Bool = true,
        redactedEvidenceOnly: Bool = true,
        artifactRoles: [ReleaseV0160OperatorRunArtifactRole],
        previousEventChecksum: String? = nil,
        eventChecksum: String? = nil,
        createdAt: Date,
        testnetNetworkPerformedByThisIssue: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160OperatorRunModelError.emptyRunID
        }
        self.eventID = Self.deterministicID(runID: runID, sequence: sequence, action: action)
        self.runID = runID
        self.sequence = sequence
        self.action = action
        self.fromState = fromState
        self.toState = toState
        self.operatorConfirmed = operatorConfirmed
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.artifactRoles = artifactRoles
        self.previousEventChecksum = previousEventChecksum
        self.createdAt = createdAt
        self.testnetNetworkPerformedByThisIssue = testnetNetworkPerformedByThisIssue
        self.productionOrderSubmitted = productionOrderSubmitted
        self.eventChecksum = eventChecksum ?? Self.stableEventChecksum(
            runID: runID,
            sequence: sequence,
            action: action,
            fromState: fromState,
            toState: toState,
            artifactRoles: artifactRoles,
            previousEventChecksum: previousEventChecksum,
            createdAt: createdAt
        )

        guard eventHeld else {
            throw ReleaseV0160OperatorRunModelError.boundaryDrift("runEvent.\(action.rawValue)")
        }
    }

    public static func deterministicID(
        runID: Identifier,
        sequence: Int,
        action: ReleaseV0160OperatorRunAction
    ) -> Identifier {
        Identifier.constant("gh-1102-v0160-event-\(runID.rawValue)-\(sequence)-\(action.rawValue)")
    }

    public static func stableEventChecksum(
        runID: Identifier,
        sequence: Int,
        action: ReleaseV0160OperatorRunAction,
        fromState: ReleaseV0160OperatorRunState,
        toState: ReleaseV0160OperatorRunState,
        artifactRoles: [ReleaseV0160OperatorRunArtifactRole],
        previousEventChecksum: String?,
        createdAt: Date
    ) -> String {
        stableSHA256([
            "GH-1102",
            "v0.16.0",
            "operator-run-event",
            runID.rawValue,
            String(sequence),
            action.rawValue,
            fromState.rawValue,
            toState.rawValue,
            artifactRoles.map(\.rawValue).joined(separator: ","),
            previousEventChecksum ?? "",
            String(createdAt.timeIntervalSince1970),
            "operatorConfirmed=true",
            "redactedEvidenceOnly=true",
            "testnetNetworkPerformedByThisIssue=false",
            "productionOrderSubmitted=false"
        ])
    }
}

/// ReleaseV0160OperatorRunModel 是 GH-1102 的本地 operator run id lifecycle。
///
/// 该 model 让后续 submit / cancel / status / reconciliation issue 共享一个 run id、状态机、
/// action sequence 和 artifact linkage。它不执行网络 I/O，不读写 secret，也不提交订单。
public struct ReleaseV0160OperatorRunModel: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let metadata: ReleaseV0160OperatorRunMetadata
    public let state: ReleaseV0160OperatorRunState
    public let events: [ReleaseV0160OperatorRunEvent]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]

    public var modelHeld: Bool {
        issueID.rawValue == "GH-1102"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1101"]
            && releaseVersion == "v0.16.0"
            && runID.rawValue.isEmpty == false
            && metadata.runID == runID
            && metadata.metadataHeld
            && events.isEmpty == false
            && events.map(\.sequence) == Array(1...events.count)
            && events.allSatisfy(\.eventHeld)
            && events.allSatisfy { $0.runID == runID }
            && eventChainHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var actionSequence: [ReleaseV0160OperatorRunAction] {
        events.map(\.action)
    }

    public var productionDefaultsClosed: Bool {
        metadata.productionDefaultsClosed
            && events.allSatisfy { $0.productionOrderSubmitted == false }
            && events.allSatisfy { $0.testnetNetworkPerformedByThisIssue == false }
    }

    private var eventChainHeld: Bool {
        var expectedState: ReleaseV0160OperatorRunState = .initialized
        for (index, event) in events.enumerated() {
            guard event.sequence == index + 1 else { return false }
            guard event.fromState == expectedState else { return false }
            guard (try? Self.nextState(action: event.action, from: event.fromState)) == event.toState else {
                return false
            }
            expectedState = event.toState
        }
        return expectedState == state
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1102"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1101")],
        releaseVersion: String = "v0.16.0",
        runID: Identifier,
        metadata: ReleaseV0160OperatorRunMetadata? = nil,
        state: ReleaseV0160OperatorRunState,
        events: [ReleaseV0160OperatorRunEvent],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160OperatorRunModelError.emptyRunID
        }
        try Self.validateEvents(events, runID: runID, finalState: state)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.metadata = try metadata ?? ReleaseV0160OperatorRunMetadata(
            runID: runID,
            createdAt: Self.fixtureStartDate
        )
        self.state = state
        self.events = events
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands

        guard modelHeld else {
            throw ReleaseV0160OperatorRunModelError.boundaryDrift("operatorRunModel")
        }
    }

    public static func created(runID: Identifier, createdAt: Date = fixtureStartDate) throws -> ReleaseV0160OperatorRunModel {
        let metadata = try ReleaseV0160OperatorRunMetadata(runID: runID, createdAt: createdAt)
        let event = try ReleaseV0160OperatorRunEvent(
            runID: runID,
            sequence: 1,
            action: .create,
            fromState: .initialized,
            toState: .created,
            artifactRoles: [.runMetadataJSON, .actionEventsJSONL],
            createdAt: createdAt
        )
        return try ReleaseV0160OperatorRunModel(
            runID: runID,
            metadata: metadata,
            state: .created,
            events: [event]
        )
    }

    public func applying(
        _ action: ReleaseV0160OperatorRunAction,
        artifactRoles: [ReleaseV0160OperatorRunArtifactRole],
        at createdAt: Date
    ) throws -> ReleaseV0160OperatorRunModel {
        let next = try Self.nextState(action: action, from: state)
        let event = try ReleaseV0160OperatorRunEvent(
            runID: runID,
            sequence: events.count + 1,
            action: action,
            fromState: state,
            toState: next,
            artifactRoles: artifactRoles,
            previousEventChecksum: events.last?.eventChecksum,
            createdAt: createdAt
        )
        return try ReleaseV0160OperatorRunModel(
            runID: runID,
            metadata: metadata,
            state: next,
            events: events + [event]
        )
    }

    public static func nextState(
        action: ReleaseV0160OperatorRunAction,
        from state: ReleaseV0160OperatorRunState
    ) throws -> ReleaseV0160OperatorRunState {
        switch (state, action) {
        case (.initialized, .create):
            .created
        case (.created, .requestSubmit), (.recovered, .requestSubmit):
            .submitRequested
        case (.submitRequested, .recordSubmitObserved):
            .submitObserved
        case (.submitObserved, .requestStatus), (.cancelObserved, .requestStatus):
            .statusRequested
        case (.statusRequested, .recordStatusObserved):
            .statusObserved
        case (.submitObserved, .requestCancel), (.statusObserved, .requestCancel):
            .cancelRequested
        case (.cancelRequested, .recordCancelObserved):
            .cancelObserved
        case (.submitObserved, .reconcile), (.statusObserved, .reconcile), (.cancelObserved, .reconcile):
            .reconciled
        case (.created, .fail), (.submitRequested, .fail), (.submitObserved, .fail),
             (.statusRequested, .fail), (.statusObserved, .fail), (.cancelRequested, .fail),
             (.cancelObserved, .fail), (.reconciled, .fail):
            .failed
        case (.failed, .recover):
            .recovered
        case (.reconciled, .close), (.failed, .close):
            .closed
        default:
            throw ReleaseV0160OperatorRunModelError.invalidTransition(
                action: action.rawValue,
                fromState: state.rawValue
            )
        }
    }

    public static func deterministicFixture() throws -> ReleaseV0160OperatorRunModel {
        let start = try created(runID: Identifier.constant("gh-1102-v0160-operator-run"))
        return try start
            .applying(.requestSubmit, artifactRoles: [.actionEventsJSONL, .redactedExecutionEvidenceJSON], at: fixtureDate(offset: 1))
            .applying(.recordSubmitObserved, artifactRoles: [.redactedExecutionEvidenceJSON, .statusSnapshotJSON], at: fixtureDate(offset: 2))
            .applying(.requestStatus, artifactRoles: [.actionEventsJSONL, .statusSnapshotJSON], at: fixtureDate(offset: 3))
            .applying(.recordStatusObserved, artifactRoles: [.statusSnapshotJSON], at: fixtureDate(offset: 4))
            .applying(.requestCancel, artifactRoles: [.actionEventsJSONL, .redactedExecutionEvidenceJSON], at: fixtureDate(offset: 5))
            .applying(.recordCancelObserved, artifactRoles: [.redactedExecutionEvidenceJSON, .statusSnapshotJSON], at: fixtureDate(offset: 6))
            .applying(.reconcile, artifactRoles: [.reconciliationJSON, .statusSnapshotJSON], at: fixtureDate(offset: 7))
            .applying(.close, artifactRoles: [.runMetadataJSON, .actionEventsJSONL, .reconciliationJSON], at: fixtureDate(offset: 8))
    }

    public static let requiredValidationAnchors = [
        "GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL",
        "TVM-RELEASE-V0160-OPERATOR-RUN-MODEL",
        "V0160-002-RUN-ID-LIFECYCLE",
        "V0160-002-ACTION-SEQUENCE",
        "V0160-002-ARTIFACT-LINKAGE",
        "V0160-002-INVALID-TRANSITION-FAILS-CLOSED",
        "V0160-002-REDACTED-METADATA",
        "V0160-002-NO-NETWORK-BY-THIS-ISSUE",
        "V0160-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1102ReleaseV0160OperatorRunModelDefinesRunIDLifecycleAndFailsClosed",
        "bash checks/verify-v0.16.0-operator-run-model.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let fixtureStartDate = Date(timeIntervalSince1970: 1_782_000_000)

    private static func fixtureDate(offset: TimeInterval) -> Date {
        Date(timeInterval: offset, since: fixtureStartDate)
    }

    private static func validateEvents(
        _ events: [ReleaseV0160OperatorRunEvent],
        runID: Identifier,
        finalState: ReleaseV0160OperatorRunState
    ) throws {
        var expectedState: ReleaseV0160OperatorRunState = .initialized
        for (index, event) in events.enumerated() {
            guard event.runID == runID else {
                throw ReleaseV0160OperatorRunModelError.eventRunIDMismatch(expected: runID, actual: event.runID)
            }
            guard event.sequence == index + 1 else {
                throw ReleaseV0160OperatorRunModelError.eventSequenceMismatch(expected: index + 1, actual: event.sequence)
            }
            guard event.fromState == expectedState else {
                throw ReleaseV0160OperatorRunModelError.invalidTransition(
                    action: event.action.rawValue,
                    fromState: event.fromState.rawValue
                )
            }
            expectedState = try nextState(action: event.action, from: event.fromState)
            guard event.toState == expectedState else {
                throw ReleaseV0160OperatorRunModelError.invalidTransition(
                    action: event.action.rawValue,
                    fromState: event.fromState.rawValue
                )
            }
            if let previous = event.previousEventChecksum,
               index > 0,
               previous != events[index - 1].eventChecksum {
                throw ReleaseV0160OperatorRunModelError.checksumMismatch(
                    field: "previousEventChecksum",
                    expected: events[index - 1].eventChecksum,
                    actual: previous
                )
            }
        }
        guard expectedState == finalState else {
            throw ReleaseV0160OperatorRunModelError.boundaryDrift("finalState")
        }
    }
}

private func stableSHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
