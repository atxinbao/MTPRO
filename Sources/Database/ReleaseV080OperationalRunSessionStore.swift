import Crypto
import DomainModel
import Foundation

/// ReleaseV080OperationalRunSessionStoreError 描述 GH-811 本地 session store 的 fail-closed 错误。
///
/// 错误只覆盖 `.local/mtpro/runs/<runID>/session.json`、`session_events.jsonl`
/// 和 `session_status.json` 的本地持久化；它不表达 endpoint、secret、broker adapter、
/// OMS production runtime 或任何订单能力。
public enum ReleaseV080OperationalRunSessionStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case duplicateSession(String)
    case missingSession(String)
    case corruptedSession(String)
    case corruptedEvents(String)
    case corruptedStatus(String)
    case checksumMismatch(expected: String, actual: String)
    case invalidTransition(command: String, fromState: String)
    case lockUnavailable(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.8.0 operational run session store requires a non-empty runID"
        case let .duplicateSession(runID):
            "Release v0.8.0 operational run session store rejects duplicate runID \(runID)"
        case let .missingSession(path):
            "Release v0.8.0 operational run session store fails closed because session is missing at \(path)"
        case let .corruptedSession(path):
            "Release v0.8.0 operational run session store fails closed because session JSON is corrupted at \(path)"
        case let .corruptedEvents(path):
            "Release v0.8.0 operational run session store fails closed because session event history is corrupted at \(path)"
        case let .corruptedStatus(path):
            "Release v0.8.0 operational run session store fails closed because session status is corrupted at \(path)"
        case let .checksumMismatch(expected, actual):
            "Release v0.8.0 operational run session store checksum mismatch: expected \(expected), actual \(actual)"
        case let .invalidTransition(command, fromState):
            "Release v0.8.0 operational run session store rejects \(command) from \(fromState)"
        case let .lockUnavailable(path):
            "Release v0.8.0 operational run session store lock is unavailable at \(path)"
        case let .boundaryDrift(field):
            "Release v0.8.0 operational run session store boundary drift: \(field)"
        }
    }
}

/// ReleaseV080OperationalRunSessionStoreContract 固定 GH-811 的验证锚点和命令。
public enum ReleaseV080OperationalRunSessionStoreContract {
    public static let requiredValidationAnchors: [String] = [
        "GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE",
        "TVM-RELEASE-V080-OPERATIONAL-SESSION-STORE",
        "V080-005-OPERATIONAL-RUN-SESSION-STORE",
        "V080-005-SESSION-JSON",
        "V080-005-SESSION-EVENTS-JSONL",
        "V080-005-SESSION-STATUS-JSON",
        "V080-005-INVALID-TRANSITION-FAILS-CLOSED",
        "V080-005-RECOVERY-PRESERVES-HISTORY"
    ]

    public static let requiredValidationCommands: [String] = [
        "bash checks/verify-v0.8.0-operational-session-store.sh",
        "swift test --filter TargetGraphTests/testGH811OperationalRunSessionStorePersistsLifecycleAndRejectsInvalidTransitions"
    ]
}

/// ReleaseV080OperationalRunSessionStoreState 固定 GH-811 可持久化 session lifecycle state。
public enum ReleaseV080OperationalRunSessionStoreState: String, Codable, CaseIterable, Equatable, Sendable {
    case created
    case starting
    case running
    case stopping
    case stopped
    case failed
    case recovered
    case completed
}

/// ReleaseV080OperationalRunSessionStoreCommand 固定 GH-811 允许记录的本地 lifecycle command。
public enum ReleaseV080OperationalRunSessionStoreCommand: String, Codable, CaseIterable, Equatable, Sendable {
    case create
    case start
    case stop
    case fail
    case recover
    case complete
}

/// ReleaseV080OperationalRunSessionArtifactPaths 是 GH-811 session 文件路径清单。
///
/// V080-005-SESSION-JSON、V080-005-SESSION-EVENTS-JSONL 和
/// V080-005-SESSION-STATUS-JSON 都必须保持在 `.local/mtpro/runs/<runID>/` 下。
public struct ReleaseV080OperationalRunSessionArtifactPaths: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let sessionJSONPath: String
    public let sessionEventsJSONLPath: String
    public let sessionStatusJSONPath: String

    public var pathsHeld: Bool {
        runDirectoryPath.hasPrefix(".local/mtpro/runs/")
            && sessionJSONPath == "\(runDirectoryPath)/session.json"
            && sessionEventsJSONLPath == "\(runDirectoryPath)/session_events.jsonl"
            && sessionStatusJSONPath == "\(runDirectoryPath)/session_status.json"
    }

    public init(runID: Identifier) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        let runDirectoryPath = ".local/mtpro/runs/\(runID.rawValue)"
        self.runDirectoryPath = runDirectoryPath
        self.sessionJSONPath = "\(runDirectoryPath)/session.json"
        self.sessionEventsJSONLPath = "\(runDirectoryPath)/session_events.jsonl"
        self.sessionStatusJSONPath = "\(runDirectoryPath)/session_status.json"

        guard pathsHeld else {
            throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("sessionArtifactPaths")
        }
    }
}

/// ReleaseV080OperationalRunSessionEvent 是 `session_events.jsonl` 的单行事件 payload。
///
/// 每个事件只记录本地 operator run lifecycle transition 和 no-order boundary evidence；
/// 它不能携带 secret、endpoint、broker command 或 order request payload。
public struct ReleaseV080OperationalRunSessionEvent: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let sequence: Int
    public let command: ReleaseV080OperationalRunSessionStoreCommand
    public let fromState: ReleaseV080OperationalRunSessionStoreState?
    public let toState: ReleaseV080OperationalRunSessionStoreState
    public let reason: String?
    public let createdAt: Date
    public let previousEventChecksum: String?
    public let eventChecksum: String
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

    public var eventHeld: Bool {
        issueID.rawValue == "GH-811"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-809", "GH-810"]
            && releaseVersion == "v0.8.0"
            && runID.rawValue.isEmpty == false
            && sequence >= 1
            && eventChecksum == Self.stableEventChecksum(
                runID: runID,
                sequence: sequence,
                command: command,
                fromState: fromState,
                toState: toState,
                reason: reason,
                createdAt: createdAt,
                previousEventChecksum: previousEventChecksum
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
        issueID: Identifier = Identifier.constant("GH-811"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-809"), Identifier.constant("GH-810")],
        releaseVersion: String = "v0.8.0",
        runID: Identifier,
        sequence: Int,
        command: ReleaseV080OperationalRunSessionStoreCommand,
        fromState: ReleaseV080OperationalRunSessionStoreState?,
        toState: ReleaseV080OperationalRunSessionStoreState,
        reason: String? = nil,
        createdAt: Date,
        previousEventChecksum: String? = nil,
        eventChecksum: String? = nil,
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
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.sequence = sequence
        self.command = command
        self.fromState = fromState
        self.toState = toState
        self.reason = reason
        self.createdAt = createdAt
        self.previousEventChecksum = previousEventChecksum
        self.eventChecksum = eventChecksum ?? Self.stableEventChecksum(
            runID: runID,
            sequence: sequence,
            command: command,
            fromState: fromState,
            toState: toState,
            reason: reason,
            createdAt: createdAt,
            previousEventChecksum: previousEventChecksum
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

        guard eventHeld else {
            throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("sessionEvent")
        }
    }

    public static func stableEventChecksum(
        runID: Identifier,
        sequence: Int,
        command: ReleaseV080OperationalRunSessionStoreCommand,
        fromState: ReleaseV080OperationalRunSessionStoreState?,
        toState: ReleaseV080OperationalRunSessionStoreState,
        reason: String?,
        createdAt: Date,
        previousEventChecksum: String?
    ) -> String {
        stableSHA256([
            "GH-811",
            "v0.8.0",
            runID.rawValue,
            String(sequence),
            command.rawValue,
            fromState?.rawValue ?? "",
            toState.rawValue,
            reason ?? "",
            String(createdAt.timeIntervalSince1970),
            previousEventChecksum ?? "",
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

/// ReleaseV080OperationalRunSessionDocument 是 GH-811 的 `session.json` 顶层 payload。
public struct ReleaseV080OperationalRunSessionDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.operational-run-session-store.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let artifactPaths: ReleaseV080OperationalRunSessionArtifactPaths
    public let state: ReleaseV080OperationalRunSessionStoreState
    public let createdAt: Date
    public let updatedAt: Date
    public let failureReason: String?
    public let recoveryReason: String?
    public let events: [ReleaseV080OperationalRunSessionEvent]
    public let sessionChecksum: String
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

    public var documentHeld: Bool {
        issueID.rawValue == "GH-811"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-809", "GH-810"]
            && releaseVersion == "v0.8.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && artifactPaths.pathsHeld
            && createdAt <= updatedAt
            && events.isEmpty == false
            && events.map(\.sequence) == Array(1...events.count)
            && events.allSatisfy(\.eventHeld)
            && events.allSatisfy { $0.runID == runID }
            && events.last?.toState == state
            && (state == .failed ? failureReason != nil : true)
            && (state == .recovered ? recoveryReason != nil : true)
            && sessionChecksum == Self.stableSessionChecksum(
                runID: runID,
                artifactPaths: artifactPaths,
                state: state,
                createdAt: createdAt,
                updatedAt: updatedAt,
                failureReason: failureReason,
                recoveryReason: recoveryReason,
                events: events
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

    public var recoveryPreservesHistory: Bool {
        guard state == .recovered else {
            return true
        }
        return recoveryReason != nil
            && events.count >= 3
            && events.contains { $0.command == .fail }
            && events.last?.command == .recover
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-811"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-809"), Identifier.constant("GH-810")],
        releaseVersion: String = "v0.8.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        artifactPaths: ReleaseV080OperationalRunSessionArtifactPaths? = nil,
        state: ReleaseV080OperationalRunSessionStoreState,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String? = nil,
        recoveryReason: String? = nil,
        events: [ReleaseV080OperationalRunSessionEvent],
        sessionChecksum: String? = nil,
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
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        let resolvedPaths = try artifactPaths ?? ReleaseV080OperationalRunSessionArtifactPaths(runID: runID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.artifactPaths = resolvedPaths
        self.state = state
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.failureReason = failureReason
        self.recoveryReason = recoveryReason
        self.events = events
        self.sessionChecksum = sessionChecksum ?? Self.stableSessionChecksum(
            runID: runID,
            artifactPaths: resolvedPaths,
            state: state,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            recoveryReason: recoveryReason,
            events: events
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

        guard documentHeld else {
            throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("sessionDocument")
        }
    }

    public func applying(
        command: ReleaseV080OperationalRunSessionStoreCommand,
        reason: String?,
        at updatedAt: Date
    ) throws -> ReleaseV080OperationalRunSessionDocument {
        let nextState = try Self.nextState(from: state, command: command)
        let nextEvent = try ReleaseV080OperationalRunSessionEvent(
            runID: runID,
            sequence: events.count + 1,
            command: command,
            fromState: state,
            toState: nextState,
            reason: reason,
            createdAt: updatedAt,
            previousEventChecksum: events.last?.eventChecksum
        )
        return try ReleaseV080OperationalRunSessionDocument(
            runID: runID,
            artifactPaths: artifactPaths,
            state: nextState,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: command == .fail ? reason : failureReason,
            recoveryReason: command == .recover ? reason : recoveryReason,
            events: events + [nextEvent]
        )
    }

    public static func nextState(
        from state: ReleaseV080OperationalRunSessionStoreState,
        command: ReleaseV080OperationalRunSessionStoreCommand
    ) throws -> ReleaseV080OperationalRunSessionStoreState {
        switch (state, command) {
        case (.created, .start):
            .starting
        case (.starting, .start):
            .running
        case (.running, .stop):
            .stopping
        case (.stopping, .stop):
            .stopped
        case (.running, .complete), (.stopped, .complete):
            .completed
        case (.created, .fail), (.starting, .fail), (.running, .fail), (.stopping, .fail):
            .failed
        case (.failed, .recover):
            .recovered
        case (.recovered, .start):
            .running
        default:
            throw ReleaseV080OperationalRunSessionStoreError.invalidTransition(
                command: command.rawValue,
                fromState: state.rawValue
            )
        }
    }

    public static func stableSessionChecksum(
        runID: Identifier,
        artifactPaths: ReleaseV080OperationalRunSessionArtifactPaths,
        state: ReleaseV080OperationalRunSessionStoreState,
        createdAt: Date,
        updatedAt: Date,
        failureReason: String?,
        recoveryReason: String?,
        events: [ReleaseV080OperationalRunSessionEvent]
    ) -> String {
        stableSHA256([
            "GH-811",
            "v0.8.0",
            Self.schemaVersion,
            runID.rawValue,
            artifactPaths.runDirectoryPath,
            artifactPaths.sessionJSONPath,
            artifactPaths.sessionEventsJSONLPath,
            artifactPaths.sessionStatusJSONPath,
            state.rawValue,
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
        ] + events.map(\.eventChecksum))
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV080OperationalRunSessionStatusDocument 是 `session_status.json` 的轻量状态快照。
public struct ReleaseV080OperationalRunSessionStatusDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.8.0.operational-run-session-status.v1"

    public let issueID: Identifier
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let sessionStatusJSONPath: String
    public let state: ReleaseV080OperationalRunSessionStoreState
    public let updatedAt: Date
    public let eventCount: Int
    public let lastEventChecksum: String
    public let failureReason: String?
    public let recoveryReason: String?
    public let statusChecksum: String
    public let noOrder: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool

    public var statusHeld: Bool {
        issueID.rawValue == "GH-811"
            && releaseVersion == "v0.8.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && sessionStatusJSONPath == ".local/mtpro/runs/\(runID.rawValue)/session_status.json"
            && eventCount >= 1
            && lastEventChecksum.hasPrefix("sha256:")
            && statusChecksum == Self.stableStatusChecksum(
                runID: runID,
                sessionStatusJSONPath: sessionStatusJSONPath,
                state: state,
                updatedAt: updatedAt,
                eventCount: eventCount,
                lastEventChecksum: lastEventChecksum,
                failureReason: failureReason,
                recoveryReason: recoveryReason
            )
            && noOrder
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
        issueID: Identifier = Identifier.constant("GH-811"),
        releaseVersion: String = "v0.8.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        sessionStatusJSONPath: String,
        state: ReleaseV080OperationalRunSessionStoreState,
        updatedAt: Date,
        eventCount: Int,
        lastEventChecksum: String,
        failureReason: String? = nil,
        recoveryReason: String? = nil,
        statusChecksum: String? = nil,
        noOrder: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.sessionStatusJSONPath = sessionStatusJSONPath
        self.state = state
        self.updatedAt = updatedAt
        self.eventCount = eventCount
        self.lastEventChecksum = lastEventChecksum
        self.failureReason = failureReason
        self.recoveryReason = recoveryReason
        self.statusChecksum = statusChecksum ?? Self.stableStatusChecksum(
            runID: runID,
            sessionStatusJSONPath: sessionStatusJSONPath,
            state: state,
            updatedAt: updatedAt,
            eventCount: eventCount,
            lastEventChecksum: lastEventChecksum,
            failureReason: failureReason,
            recoveryReason: recoveryReason
        )
        self.noOrder = noOrder
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed

        guard statusHeld else {
            throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("sessionStatus")
        }
    }

    public init(document: ReleaseV080OperationalRunSessionDocument) throws {
        try self.init(
            runID: document.runID,
            sessionStatusJSONPath: document.artifactPaths.sessionStatusJSONPath,
            state: document.state,
            updatedAt: document.updatedAt,
            eventCount: document.events.count,
            lastEventChecksum: document.events.last?.eventChecksum ?? "",
            failureReason: document.failureReason,
            recoveryReason: document.recoveryReason
        )
    }

    public static func stableStatusChecksum(
        runID: Identifier,
        sessionStatusJSONPath: String,
        state: ReleaseV080OperationalRunSessionStoreState,
        updatedAt: Date,
        eventCount: Int,
        lastEventChecksum: String,
        failureReason: String?,
        recoveryReason: String?
    ) -> String {
        stableSHA256([
            "GH-811",
            "v0.8.0",
            Self.schemaVersion,
            runID.rawValue,
            sessionStatusJSONPath,
            state.rawValue,
            String(updatedAt.timeIntervalSince1970),
            String(eventCount),
            lastEventChecksum,
            failureReason ?? "",
            recoveryReason ?? "",
            "noOrder=true",
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

/// ReleaseV080OperationalRunSessionStore 提供 GH-811 的本地 lifecycle session 持久化入口。
///
/// Store 只操作 `.local/mtpro/runs/<runID>/session.json`、`session_events.jsonl`
/// 和 `session_status.json`；它不会启动 runtime，不读取 secret，不连接网络，
/// 不调用 broker，也不创建订单。
public struct ReleaseV080OperationalRunSessionStore {
    public let storageRootURL: URL
    public let fileManager: FileManager

    public init(
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func create(
        runID: Identifier,
        reason: String? = "local-operator-created",
        createdAt: Date
    ) throws -> ReleaseV080OperationalRunSessionDocument {
        try withSessionLock(runID: runID) {
            let sessionURL = try self.sessionURL(runID: runID)
            guard fileManager.fileExists(atPath: sessionURL.path) == false else {
                throw ReleaseV080OperationalRunSessionStoreError.duplicateSession(runID.rawValue)
            }
            let event = try ReleaseV080OperationalRunSessionEvent(
                runID: runID,
                sequence: 1,
                command: .create,
                fromState: nil,
                toState: .created,
                reason: reason,
                createdAt: createdAt
            )
            let document = try ReleaseV080OperationalRunSessionDocument(
                runID: runID,
                state: .created,
                createdAt: createdAt,
                updatedAt: createdAt,
                events: [event]
            )
            try writeUnlocked(document)
            return document
        }
    }

    public func load(runID: Identifier) throws -> ReleaseV080OperationalRunSessionDocument {
        let sessionURL = try sessionURL(runID: runID)
        guard fileManager.fileExists(atPath: sessionURL.path) else {
            throw ReleaseV080OperationalRunSessionStoreError.missingSession(sessionURL.path)
        }
        do {
            let data = try Data(contentsOf: sessionURL)
            let document = try Self.decoder.decode(ReleaseV080OperationalRunSessionDocument.self, from: data)
            let expectedChecksum = ReleaseV080OperationalRunSessionDocument.stableSessionChecksum(
                runID: document.runID,
                artifactPaths: document.artifactPaths,
                state: document.state,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt,
                failureReason: document.failureReason,
                recoveryReason: document.recoveryReason,
                events: document.events
            )
            guard document.sessionChecksum == expectedChecksum else {
                throw ReleaseV080OperationalRunSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.sessionChecksum
                )
            }
            guard document.documentHeld else {
                throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("decodedSessionDocument")
            }
            let persistedEvents = try loadEvents(runID: runID)
            guard persistedEvents == document.events else {
                throw ReleaseV080OperationalRunSessionStoreError.corruptedEvents(try eventsURL(runID: runID).path)
            }
            _ = try status(runID: runID)
            return document
        } catch let error as ReleaseV080OperationalRunSessionStoreError {
            throw error
        } catch {
            throw ReleaseV080OperationalRunSessionStoreError.corruptedSession(sessionURL.path)
        }
    }

    public func status(runID: Identifier) throws -> ReleaseV080OperationalRunSessionStatusDocument {
        let statusURL = try statusURL(runID: runID)
        guard fileManager.fileExists(atPath: statusURL.path) else {
            throw ReleaseV080OperationalRunSessionStoreError.corruptedStatus(statusURL.path)
        }
        do {
            let data = try Data(contentsOf: statusURL)
            let status = try Self.decoder.decode(ReleaseV080OperationalRunSessionStatusDocument.self, from: data)
            let expectedChecksum = ReleaseV080OperationalRunSessionStatusDocument.stableStatusChecksum(
                runID: status.runID,
                sessionStatusJSONPath: status.sessionStatusJSONPath,
                state: status.state,
                updatedAt: status.updatedAt,
                eventCount: status.eventCount,
                lastEventChecksum: status.lastEventChecksum,
                failureReason: status.failureReason,
                recoveryReason: status.recoveryReason
            )
            guard status.statusChecksum == expectedChecksum else {
                throw ReleaseV080OperationalRunSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: status.statusChecksum
                )
            }
            guard status.statusHeld else {
                throw ReleaseV080OperationalRunSessionStoreError.boundaryDrift("decodedSessionStatus")
            }
            return status
        } catch let error as ReleaseV080OperationalRunSessionStoreError {
            throw error
        } catch {
            throw ReleaseV080OperationalRunSessionStoreError.corruptedStatus(statusURL.path)
        }
    }

    @discardableResult
    public func apply(
        runID: Identifier,
        command: ReleaseV080OperationalRunSessionStoreCommand,
        reason: String? = nil,
        at updatedAt: Date
    ) throws -> ReleaseV080OperationalRunSessionDocument {
        try withSessionLock(runID: runID) {
            let current = try load(runID: runID)
            let next = try current.applying(command: command, reason: reason, at: updatedAt)
            try writeUnlocked(next)
            return next
        }
    }

    public static func deterministicFixture(
        createdAt: Date = Date(timeIntervalSince1970: 1_782_000_000)
    ) throws -> ReleaseV080OperationalRunSessionDocument {
        let store = ReleaseV080OperationalRunSessionStore(
            storageRootURL: URL(fileURLWithPath: "/tmp/mtpro-gh811-fixture", isDirectory: true)
        )
        _ = store
        let runID = Identifier.constant("gh-811-run-alpha")
        let event = try ReleaseV080OperationalRunSessionEvent(
            runID: runID,
            sequence: 1,
            command: .create,
            fromState: nil,
            toState: .created,
            reason: "deterministic-local-fixture",
            createdAt: createdAt
        )
        return try ReleaseV080OperationalRunSessionDocument(
            runID: runID,
            state: .created,
            createdAt: createdAt,
            updatedAt: createdAt,
            events: [event]
        )
    }

    private func loadEvents(runID: Identifier) throws -> [ReleaseV080OperationalRunSessionEvent] {
        let eventsURL = try eventsURL(runID: runID)
        guard fileManager.fileExists(atPath: eventsURL.path) else {
            throw ReleaseV080OperationalRunSessionStoreError.corruptedEvents(eventsURL.path)
        }
        do {
            let payload = try String(contentsOf: eventsURL, encoding: .utf8)
            let lines = payload.split(separator: "\n", omittingEmptySubsequences: true)
            return try lines.map { line in
                try Self.decoder.decode(
                    ReleaseV080OperationalRunSessionEvent.self,
                    from: Data(line.utf8)
                )
            }
        } catch let error as ReleaseV080OperationalRunSessionStoreError {
            throw error
        } catch {
            throw ReleaseV080OperationalRunSessionStoreError.corruptedEvents(eventsURL.path)
        }
    }

    private func withSessionLock<T>(
        runID: Identifier,
        _ operation: () throws -> T
    ) throws -> T {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        let directoryURL = runDirectoryURL(runID: runID)
        let lockURL = directoryURL.appendingPathComponent("session.lock", isDirectory: true)
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
        } catch {
            throw ReleaseV080OperationalRunSessionStoreError.lockUnavailable(lockURL.path)
        }
        defer {
            try? fileManager.removeItem(at: lockURL)
        }
        return try operation()
    }

    private func writeUnlocked(_ document: ReleaseV080OperationalRunSessionDocument) throws {
        let directoryURL = runDirectoryURL(runID: document.runID)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try writeJSON(document, to: sessionURL(runID: document.runID))
        try writeEventsJSONL(document.events, to: eventsURL(runID: document.runID))
        try writeJSON(ReleaseV080OperationalRunSessionStatusDocument(document: document), to: statusURL(runID: document.runID))
    }

    private func writeJSON<T: Encodable>(_ payload: T, to url: URL) throws {
        let data = try Self.encoder.encode(payload)
        let temporaryURL = url.appendingPathExtension("tmp")
        try data.write(to: temporaryURL, options: .atomic)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try fileManager.moveItem(at: temporaryURL, to: url)
    }

    private func writeEventsJSONL(
        _ events: [ReleaseV080OperationalRunSessionEvent],
        to url: URL
    ) throws {
        let lines = try events.map { event in
            String(decoding: try Self.compactEncoder.encode(event), as: UTF8.self)
        }
        let payload = lines.joined(separator: "\n") + "\n"
        let temporaryURL = url.appendingPathExtension("tmp")
        try Data(payload.utf8).write(to: temporaryURL, options: .atomic)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try fileManager.moveItem(at: temporaryURL, to: url)
    }

    private func runDirectoryURL(runID: Identifier) -> URL {
        storageRootURL.appendingPathComponent(runID.rawValue, isDirectory: true)
    }

    private func sessionURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        return runDirectoryURL(runID: runID).appendingPathComponent("session.json", isDirectory: false)
    }

    private func eventsURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        return runDirectoryURL(runID: runID).appendingPathComponent("session_events.jsonl", isDirectory: false)
    }

    private func statusURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV080OperationalRunSessionStoreError.emptyRunID
        }
        return runDirectoryURL(runID: runID).appendingPathComponent("session_status.json", isDirectory: false)
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var compactEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
