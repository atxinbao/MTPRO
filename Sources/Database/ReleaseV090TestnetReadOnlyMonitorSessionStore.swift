import Crypto
import DomainModel
import Foundation

/// ReleaseV090TestnetReadOnlyMonitorSessionStoreError 描述 GH-845 monitor session artifact 的本地 fail-closed 错误。
///
/// 错误只覆盖 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/` 下的
/// `monitor_session.json`、`monitor_events.jsonl` 和 `monitor_status.json`；
/// 它不表达 endpoint、secret、broker adapter、OMS production runtime 或任何订单能力。
public enum ReleaseV090TestnetReadOnlyMonitorSessionStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case duplicateMonitorSession(String)
    case missingMonitorSession(String)
    case corruptedMonitorSession(String)
    case corruptedMonitorEvents(String)
    case corruptedMonitorStatus(String)
    case checksumMismatch(expected: String, actual: String)
    case invalidTransition(command: String, fromState: String)
    case lockUnavailable(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.9.0 testnet read-only monitor session requires a non-empty runID"
        case let .duplicateMonitorSession(runID):
            "Release v0.9.0 testnet read-only monitor session rejects duplicate runID \(runID)"
        case let .missingMonitorSession(path):
            "Release v0.9.0 testnet read-only monitor session fails closed because monitor_session.json is missing at \(path)"
        case let .corruptedMonitorSession(path):
            "Release v0.9.0 testnet read-only monitor session fails closed because monitor_session.json is corrupted at \(path)"
        case let .corruptedMonitorEvents(path):
            "Release v0.9.0 testnet read-only monitor session fails closed because monitor_events.jsonl is corrupted at \(path)"
        case let .corruptedMonitorStatus(path):
            "Release v0.9.0 testnet read-only monitor session fails closed because monitor_status.json is corrupted at \(path)"
        case let .checksumMismatch(expected, actual):
            "Release v0.9.0 testnet read-only monitor session checksum mismatch: expected \(expected), actual \(actual)"
        case let .invalidTransition(command, fromState):
            "Release v0.9.0 testnet read-only monitor session rejects \(command) from \(fromState)"
        case let .lockUnavailable(path):
            "Release v0.9.0 testnet read-only monitor session lock is unavailable at \(path)"
        case let .boundaryDrift(field):
            "Release v0.9.0 testnet read-only monitor session boundary drift: \(field)"
        }
    }
}

/// ReleaseV090TestnetReadOnlyMonitorSessionStoreContract 固定 GH-845 的验证锚点和命令。
public enum ReleaseV090TestnetReadOnlyMonitorSessionStoreContract {
    public static let requiredValidationAnchors: [String] = [
        "GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE",
        "TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE",
        "V090-003-TESTNET-READONLY-MONITOR-SESSION",
        "V090-003-MONITOR-SESSION-JSON",
        "V090-003-MONITOR-EVENTS-JSONL",
        "V090-003-MONITOR-STATUS-JSON",
        "V090-003-MONITOR-STATE-TAXONOMY",
        "V090-003-APPEND-ONLY-MONITOR-EVENTS",
        "V090-003-CORRUPTED-ARTIFACTS-FAIL-CLOSED",
        "V090-003-NO-ORDER-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands: [String] = [
        "bash checks/verify-v0.9.0-monitor-session-store.sh",
        "swift test --filter TargetGraphTests/testGH845TestnetReadOnlyMonitorSessionStorePersistsArtifactsAndFailsClosed"
    ]
}

/// ReleaseV090TestnetReadOnlyMonitorState 固定 GH-845 monitor session 的本地状态分类。
///
/// 这些状态只描述 testnet read-only observability artifact，不触发 reconnect command、
/// endpoint mutation、broker action、testnet order 或 production order。
public enum ReleaseV090TestnetReadOnlyMonitorState: String, Codable, CaseIterable, Equatable, Sendable {
    case created
    case connecting
    case observing
    case stale
    case disconnected
    case recovering
    case stopped
    case failed
}

/// ReleaseV090TestnetReadOnlyMonitorCommand 固定 GH-845 允许写入 JSONL 的本地事件命令。
public enum ReleaseV090TestnetReadOnlyMonitorCommand: String, Codable, CaseIterable, Equatable, Sendable {
    case create
    case connect
    case observe
    case markStale
    case disconnect
    case recover
    case stop
    case fail
}

/// ReleaseV090TestnetReadOnlyMonitorArtifactPaths 固定 GH-845 三个本地 artifact 路径。
///
/// 路径只允许落在 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/`，不能保存
/// credential value、raw listenKey、raw private stream payload、broker command payload 或 order request payload。
public struct ReleaseV090TestnetReadOnlyMonitorArtifactPaths: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let monitorDirectoryPath: String
    public let monitorSessionJSONPath: String
    public let monitorEventsJSONLPath: String
    public let monitorStatusJSONPath: String

    public var pathsHeld: Bool {
        runDirectoryPath.hasPrefix(".local/mtpro/runs/")
            && monitorDirectoryPath == "\(runDirectoryPath)/testnet-readonly-monitor"
            && monitorSessionJSONPath == "\(monitorDirectoryPath)/monitor_session.json"
            && monitorEventsJSONLPath == "\(monitorDirectoryPath)/monitor_events.jsonl"
            && monitorStatusJSONPath == "\(monitorDirectoryPath)/monitor_status.json"
    }

    public init(runID: Identifier) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        let runDirectoryPath = ".local/mtpro/runs/\(runID.rawValue)"
        let monitorDirectoryPath = "\(runDirectoryPath)/testnet-readonly-monitor"
        self.runDirectoryPath = runDirectoryPath
        self.monitorDirectoryPath = monitorDirectoryPath
        self.monitorSessionJSONPath = "\(monitorDirectoryPath)/monitor_session.json"
        self.monitorEventsJSONLPath = "\(monitorDirectoryPath)/monitor_events.jsonl"
        self.monitorStatusJSONPath = "\(monitorDirectoryPath)/monitor_status.json"

        guard pathsHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorArtifactPaths")
        }
    }
}

/// ReleaseV090TestnetReadOnlyMonitorEvent 是 `monitor_events.jsonl` 的单行 append-only evidence。
///
/// 每个事件只记录本地 monitor state transition、checksum chain 和 no-order boundary evidence；
/// 它不能携带 secret、endpoint、broker command 或 order request payload。
public struct ReleaseV090TestnetReadOnlyMonitorEvent: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let sequence: Int
    public let command: ReleaseV090TestnetReadOnlyMonitorCommand
    public let fromState: ReleaseV090TestnetReadOnlyMonitorState?
    public let toState: ReleaseV090TestnetReadOnlyMonitorState
    public let reason: String?
    public let observedAt: Date
    public let previousEventChecksum: String?
    public let eventChecksum: String
    public let persistentLocalArtifact: Bool
    public let appendOnlyMonitorEvents: Bool
    public let noOrder: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool

    public var eventHeld: Bool {
        issueID.rawValue == "GH-845"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-843", "GH-844"]
            && releaseVersion == "v0.9.0"
            && runID.rawValue.isEmpty == false
            && sequence >= 1
            && eventChecksum == Self.stableEventChecksum(
                runID: runID,
                sequence: sequence,
                command: command,
                fromState: fromState,
                toState: toState,
                reason: reason,
                observedAt: observedAt,
                previousEventChecksum: previousEventChecksum
            )
            && persistentLocalArtifact
            && appendOnlyMonitorEvents
            && noOrder
            && testnetReadOnlyObservabilityAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-845"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-843"), Identifier.constant("GH-844")],
        releaseVersion: String = "v0.9.0",
        runID: Identifier,
        sequence: Int,
        command: ReleaseV090TestnetReadOnlyMonitorCommand,
        fromState: ReleaseV090TestnetReadOnlyMonitorState?,
        toState: ReleaseV090TestnetReadOnlyMonitorState,
        reason: String? = nil,
        observedAt: Date,
        previousEventChecksum: String? = nil,
        eventChecksum: String? = nil,
        persistentLocalArtifact: Bool = true,
        appendOnlyMonitorEvents: Bool = true,
        noOrder: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        testnetCancelReplaceAllowed: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
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
        self.observedAt = observedAt
        self.previousEventChecksum = previousEventChecksum
        self.eventChecksum = eventChecksum ?? Self.stableEventChecksum(
            runID: runID,
            sequence: sequence,
            command: command,
            fromState: fromState,
            toState: toState,
            reason: reason,
            observedAt: observedAt,
            previousEventChecksum: previousEventChecksum
        )
        self.persistentLocalArtifact = persistentLocalArtifact
        self.appendOnlyMonitorEvents = appendOnlyMonitorEvents
        self.noOrder = noOrder
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed

        guard eventHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorEvent")
        }
    }

    public static func stableEventChecksum(
        runID: Identifier,
        sequence: Int,
        command: ReleaseV090TestnetReadOnlyMonitorCommand,
        fromState: ReleaseV090TestnetReadOnlyMonitorState?,
        toState: ReleaseV090TestnetReadOnlyMonitorState,
        reason: String?,
        observedAt: Date,
        previousEventChecksum: String?
    ) -> String {
        stableSHA256([
            "GH-845",
            "v0.9.0",
            runID.rawValue,
            String(sequence),
            command.rawValue,
            fromState?.rawValue ?? "",
            toState.rawValue,
            reason ?? "",
            String(observedAt.timeIntervalSince1970),
            previousEventChecksum ?? "",
            "persistentLocalArtifact=true",
            "appendOnlyMonitorEvents=true",
            "noOrder=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false",
            "testnetCancelReplaceAllowed=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV090TestnetReadOnlyMonitorSessionDocument 是 `monitor_session.json` 顶层 payload。
public struct ReleaseV090TestnetReadOnlyMonitorSessionDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.testnet-readonly-monitor-session.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let artifactPaths: ReleaseV090TestnetReadOnlyMonitorArtifactPaths
    public let state: ReleaseV090TestnetReadOnlyMonitorState
    public let createdAt: Date
    public let updatedAt: Date
    public let staleReason: String?
    public let disconnectedReason: String?
    public let recoveryReason: String?
    public let failureReason: String?
    public let events: [ReleaseV090TestnetReadOnlyMonitorEvent]
    public let sessionChecksum: String
    public let persistentLocalArtifact: Bool
    public let appendOnlyMonitorEvents: Bool
    public let noOrder: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool

    public var documentHeld: Bool {
        issueID.rawValue == "GH-845"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-843", "GH-844"]
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && artifactPaths.pathsHeld
            && createdAt <= updatedAt
            && events.isEmpty == false
            && events.map(\.sequence) == Array(1...events.count)
            && events.allSatisfy(\.eventHeld)
            && events.allSatisfy { $0.runID == runID }
            && events.last?.toState == state
            && (state == .stale ? staleReason != nil : true)
            && (state == .disconnected ? disconnectedReason != nil : true)
            && (state == .recovering ? recoveryReason != nil : true)
            && (state == .failed ? failureReason != nil : true)
            && sessionChecksum == Self.stableSessionChecksum(
                runID: runID,
                artifactPaths: artifactPaths,
                state: state,
                createdAt: createdAt,
                updatedAt: updatedAt,
                staleReason: staleReason,
                disconnectedReason: disconnectedReason,
                recoveryReason: recoveryReason,
                failureReason: failureReason,
                events: events
            )
            && persistentLocalArtifact
            && appendOnlyMonitorEvents
            && noOrder
            && testnetReadOnlyObservabilityAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
    }

    public var observedStateTaxonomyHeld: Bool {
        Set(events.map(\.toState)).isSubset(of: Set(ReleaseV090TestnetReadOnlyMonitorState.allCases))
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-845"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-843"), Identifier.constant("GH-844")],
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        artifactPaths: ReleaseV090TestnetReadOnlyMonitorArtifactPaths? = nil,
        state: ReleaseV090TestnetReadOnlyMonitorState,
        createdAt: Date,
        updatedAt: Date,
        staleReason: String? = nil,
        disconnectedReason: String? = nil,
        recoveryReason: String? = nil,
        failureReason: String? = nil,
        events: [ReleaseV090TestnetReadOnlyMonitorEvent],
        sessionChecksum: String? = nil,
        persistentLocalArtifact: Bool = true,
        appendOnlyMonitorEvents: Bool = true,
        noOrder: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        testnetCancelReplaceAllowed: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        let resolvedPaths = try artifactPaths ?? ReleaseV090TestnetReadOnlyMonitorArtifactPaths(runID: runID)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.artifactPaths = resolvedPaths
        self.state = state
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.staleReason = staleReason
        self.disconnectedReason = disconnectedReason
        self.recoveryReason = recoveryReason
        self.failureReason = failureReason
        self.events = events
        self.sessionChecksum = sessionChecksum ?? Self.stableSessionChecksum(
            runID: runID,
            artifactPaths: resolvedPaths,
            state: state,
            createdAt: createdAt,
            updatedAt: updatedAt,
            staleReason: staleReason,
            disconnectedReason: disconnectedReason,
            recoveryReason: recoveryReason,
            failureReason: failureReason,
            events: events
        )
        self.persistentLocalArtifact = persistentLocalArtifact
        self.appendOnlyMonitorEvents = appendOnlyMonitorEvents
        self.noOrder = noOrder
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed

        guard documentHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorSessionDocument")
        }
    }

    public func applying(
        command: ReleaseV090TestnetReadOnlyMonitorCommand,
        reason: String?,
        at updatedAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        let nextState = try Self.nextState(from: state, command: command)
        let nextEvent = try ReleaseV090TestnetReadOnlyMonitorEvent(
            runID: runID,
            sequence: events.count + 1,
            command: command,
            fromState: state,
            toState: nextState,
            reason: reason,
            observedAt: updatedAt,
            previousEventChecksum: events.last?.eventChecksum
        )
        return try ReleaseV090TestnetReadOnlyMonitorSessionDocument(
            runID: runID,
            artifactPaths: artifactPaths,
            state: nextState,
            createdAt: createdAt,
            updatedAt: updatedAt,
            staleReason: command == .markStale ? reason : staleReason,
            disconnectedReason: command == .disconnect ? reason : disconnectedReason,
            recoveryReason: command == .recover ? reason : recoveryReason,
            failureReason: command == .fail ? reason : failureReason,
            events: events + [nextEvent]
        )
    }

    public static func nextState(
        from state: ReleaseV090TestnetReadOnlyMonitorState,
        command: ReleaseV090TestnetReadOnlyMonitorCommand
    ) throws -> ReleaseV090TestnetReadOnlyMonitorState {
        switch (state, command) {
        case (.created, .connect):
            .connecting
        case (.connecting, .observe), (.recovering, .observe):
            .observing
        case (.observing, .markStale):
            .stale
        case (.connecting, .disconnect), (.observing, .disconnect), (.stale, .disconnect):
            .disconnected
        case (.stale, .recover), (.disconnected, .recover):
            .recovering
        case (.created, .stop), (.connecting, .stop), (.observing, .stop), (.stale, .stop), (.disconnected, .stop), (.recovering, .stop):
            .stopped
        case (.created, .fail), (.connecting, .fail), (.observing, .fail), (.stale, .fail), (.disconnected, .fail), (.recovering, .fail):
            .failed
        default:
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.invalidTransition(
                command: command.rawValue,
                fromState: state.rawValue
            )
        }
    }

    public static func stableSessionChecksum(
        runID: Identifier,
        artifactPaths: ReleaseV090TestnetReadOnlyMonitorArtifactPaths,
        state: ReleaseV090TestnetReadOnlyMonitorState,
        createdAt: Date,
        updatedAt: Date,
        staleReason: String?,
        disconnectedReason: String?,
        recoveryReason: String?,
        failureReason: String?,
        events: [ReleaseV090TestnetReadOnlyMonitorEvent]
    ) -> String {
        stableSHA256([
            "GH-845",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            artifactPaths.runDirectoryPath,
            artifactPaths.monitorDirectoryPath,
            artifactPaths.monitorSessionJSONPath,
            artifactPaths.monitorEventsJSONLPath,
            artifactPaths.monitorStatusJSONPath,
            state.rawValue,
            String(createdAt.timeIntervalSince1970),
            String(updatedAt.timeIntervalSince1970),
            staleReason ?? "",
            disconnectedReason ?? "",
            recoveryReason ?? "",
            failureReason ?? "",
            "persistentLocalArtifact=true",
            "appendOnlyMonitorEvents=true",
            "noOrder=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false",
            "testnetCancelReplaceAllowed=false"
        ] + events.map(\.eventChecksum))
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV090TestnetReadOnlyMonitorStatusDocument 是 `monitor_status.json` 的轻量状态快照。
public struct ReleaseV090TestnetReadOnlyMonitorStatusDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.testnet-readonly-monitor-status.v1"

    public let issueID: Identifier
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let monitorStatusJSONPath: String
    public let state: ReleaseV090TestnetReadOnlyMonitorState
    public let updatedAt: Date
    public let eventCount: Int
    public let lastEventChecksum: String
    public let staleReason: String?
    public let disconnectedReason: String?
    public let recoveryReason: String?
    public let failureReason: String?
    public let statusChecksum: String
    public let noOrder: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool

    public var statusHeld: Bool {
        issueID.rawValue == "GH-845"
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && monitorStatusJSONPath == ".local/mtpro/runs/\(runID.rawValue)/testnet-readonly-monitor/monitor_status.json"
            && eventCount >= 1
            && lastEventChecksum.hasPrefix("sha256:")
            && statusChecksum == Self.stableStatusChecksum(
                runID: runID,
                monitorStatusJSONPath: monitorStatusJSONPath,
                state: state,
                updatedAt: updatedAt,
                eventCount: eventCount,
                lastEventChecksum: lastEventChecksum,
                staleReason: staleReason,
                disconnectedReason: disconnectedReason,
                recoveryReason: recoveryReason,
                failureReason: failureReason
            )
            && noOrder
            && testnetReadOnlyObservabilityAllowed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-845"),
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        monitorStatusJSONPath: String,
        state: ReleaseV090TestnetReadOnlyMonitorState,
        updatedAt: Date,
        eventCount: Int,
        lastEventChecksum: String,
        staleReason: String? = nil,
        disconnectedReason: String? = nil,
        recoveryReason: String? = nil,
        failureReason: String? = nil,
        statusChecksum: String? = nil,
        noOrder: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        testnetCancelReplaceAllowed: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.monitorStatusJSONPath = monitorStatusJSONPath
        self.state = state
        self.updatedAt = updatedAt
        self.eventCount = eventCount
        self.lastEventChecksum = lastEventChecksum
        self.staleReason = staleReason
        self.disconnectedReason = disconnectedReason
        self.recoveryReason = recoveryReason
        self.failureReason = failureReason
        self.statusChecksum = statusChecksum ?? Self.stableStatusChecksum(
            runID: runID,
            monitorStatusJSONPath: monitorStatusJSONPath,
            state: state,
            updatedAt: updatedAt,
            eventCount: eventCount,
            lastEventChecksum: lastEventChecksum,
            staleReason: staleReason,
            disconnectedReason: disconnectedReason,
            recoveryReason: recoveryReason,
            failureReason: failureReason
        )
        self.noOrder = noOrder
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed

        guard statusHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorStatus")
        }
    }

    public init(document: ReleaseV090TestnetReadOnlyMonitorSessionDocument) throws {
        try self.init(
            runID: document.runID,
            monitorStatusJSONPath: document.artifactPaths.monitorStatusJSONPath,
            state: document.state,
            updatedAt: document.updatedAt,
            eventCount: document.events.count,
            lastEventChecksum: document.events.last?.eventChecksum ?? "",
            staleReason: document.staleReason,
            disconnectedReason: document.disconnectedReason,
            recoveryReason: document.recoveryReason,
            failureReason: document.failureReason
        )
    }

    public static func stableStatusChecksum(
        runID: Identifier,
        monitorStatusJSONPath: String,
        state: ReleaseV090TestnetReadOnlyMonitorState,
        updatedAt: Date,
        eventCount: Int,
        lastEventChecksum: String,
        staleReason: String?,
        disconnectedReason: String?,
        recoveryReason: String?,
        failureReason: String?
    ) -> String {
        stableSHA256([
            "GH-845",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            monitorStatusJSONPath,
            state.rawValue,
            String(updatedAt.timeIntervalSince1970),
            String(eventCount),
            lastEventChecksum,
            staleReason ?? "",
            disconnectedReason ?? "",
            recoveryReason ?? "",
            failureReason ?? "",
            "noOrder=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionBrokerConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false",
            "testnetCancelReplaceAllowed=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV090TestnetReadOnlyMonitorSessionStore 提供 GH-845 monitor session 本地持久化入口。
///
/// Store 只操作本地 `monitor_session.json`、`monitor_events.jsonl` 和
/// `monitor_status.json`；它不会启动 runtime，不读取 secret，不连接网络，
/// 不调用 broker，也不创建或取消订单。
public struct ReleaseV090TestnetReadOnlyMonitorSessionStore {
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
        reason: String? = "testnet-readonly-monitor-created",
        createdAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        try withMonitorLock(runID: runID) {
            let sessionURL = try monitorSessionURL(runID: runID)
            guard fileManager.fileExists(atPath: sessionURL.path) == false else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.duplicateMonitorSession(runID.rawValue)
            }
            let event = try ReleaseV090TestnetReadOnlyMonitorEvent(
                runID: runID,
                sequence: 1,
                command: .create,
                fromState: nil,
                toState: .created,
                reason: reason,
                observedAt: createdAt
            )
            let document = try ReleaseV090TestnetReadOnlyMonitorSessionDocument(
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

    public func load(runID: Identifier) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        let sessionURL = try monitorSessionURL(runID: runID)
        guard fileManager.fileExists(atPath: sessionURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.missingMonitorSession(sessionURL.path)
        }
        do {
            let data = try Data(contentsOf: sessionURL)
            let document = try Self.decoder.decode(ReleaseV090TestnetReadOnlyMonitorSessionDocument.self, from: data)
            let expectedChecksum = ReleaseV090TestnetReadOnlyMonitorSessionDocument.stableSessionChecksum(
                runID: document.runID,
                artifactPaths: document.artifactPaths,
                state: document.state,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt,
                staleReason: document.staleReason,
                disconnectedReason: document.disconnectedReason,
                recoveryReason: document.recoveryReason,
                failureReason: document.failureReason,
                events: document.events
            )
            guard document.sessionChecksum == expectedChecksum else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.sessionChecksum
                )
            }
            guard document.documentHeld else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("decodedMonitorSessionDocument")
            }
            let persistedEvents = try loadEvents(runID: runID)
            guard persistedEvents == document.events else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorEvents(
                    try monitorEventsURL(runID: runID).path
                )
            }
            _ = try status(runID: runID)
            return document
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorSession(sessionURL.path)
        }
    }

    public func status(runID: Identifier) throws -> ReleaseV090TestnetReadOnlyMonitorStatusDocument {
        let statusURL = try monitorStatusURL(runID: runID)
        guard fileManager.fileExists(atPath: statusURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorStatus(statusURL.path)
        }
        do {
            let data = try Data(contentsOf: statusURL)
            let status = try Self.decoder.decode(ReleaseV090TestnetReadOnlyMonitorStatusDocument.self, from: data)
            let expectedChecksum = ReleaseV090TestnetReadOnlyMonitorStatusDocument.stableStatusChecksum(
                runID: status.runID,
                monitorStatusJSONPath: status.monitorStatusJSONPath,
                state: status.state,
                updatedAt: status.updatedAt,
                eventCount: status.eventCount,
                lastEventChecksum: status.lastEventChecksum,
                staleReason: status.staleReason,
                disconnectedReason: status.disconnectedReason,
                recoveryReason: status.recoveryReason,
                failureReason: status.failureReason
            )
            guard status.statusChecksum == expectedChecksum else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: status.statusChecksum
                )
            }
            guard status.statusHeld else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("decodedMonitorStatus")
            }
            return status
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorStatus(statusURL.path)
        }
    }

    @discardableResult
    public func apply(
        runID: Identifier,
        command: ReleaseV090TestnetReadOnlyMonitorCommand,
        reason: String? = nil,
        at updatedAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        try withMonitorLock(runID: runID) {
            let current = try load(runID: runID)
            let next = try current.applying(command: command, reason: reason, at: updatedAt)
            try writeUnlocked(next)
            return next
        }
    }

    public static func deterministicFixture(
        createdAt: Date = Date(timeIntervalSince1970: 1_782_100_000)
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        let runID = Identifier.constant("gh-845-monitor-alpha")
        let event = try ReleaseV090TestnetReadOnlyMonitorEvent(
            runID: runID,
            sequence: 1,
            command: .create,
            fromState: nil,
            toState: .created,
            reason: "deterministic-monitor-fixture",
            observedAt: createdAt
        )
        return try ReleaseV090TestnetReadOnlyMonitorSessionDocument(
            runID: runID,
            state: .created,
            createdAt: createdAt,
            updatedAt: createdAt,
            events: [event]
        )
    }

    private func loadEvents(runID: Identifier) throws -> [ReleaseV090TestnetReadOnlyMonitorEvent] {
        let eventsURL = try monitorEventsURL(runID: runID)
        guard fileManager.fileExists(atPath: eventsURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorEvents(eventsURL.path)
        }
        do {
            let payload = try String(contentsOf: eventsURL, encoding: .utf8)
            let lines = payload.split(separator: "\n", omittingEmptySubsequences: true)
            return try lines.map { line in
                try Self.decoder.decode(
                    ReleaseV090TestnetReadOnlyMonitorEvent.self,
                    from: Data(line.utf8)
                )
            }
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorEvents(eventsURL.path)
        }
    }

    private func withMonitorLock<T>(
        runID: Identifier,
        _ operation: () throws -> T
    ) throws -> T {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        let directoryURL = monitorDirectoryURL(runID: runID)
        let lockURL = directoryURL.appendingPathComponent("monitor.lock", isDirectory: true)
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: lockURL, withIntermediateDirectories: false)
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.lockUnavailable(lockURL.path)
        }
        defer {
            try? fileManager.removeItem(at: lockURL)
        }
        return try operation()
    }

    private func writeUnlocked(_ document: ReleaseV090TestnetReadOnlyMonitorSessionDocument) throws {
        let directoryURL = monitorDirectoryURL(runID: document.runID)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try writeJSON(document, to: monitorSessionURL(runID: document.runID))
        try writeEventsJSONL(document.events, to: monitorEventsURL(runID: document.runID))
        try writeJSON(ReleaseV090TestnetReadOnlyMonitorStatusDocument(document: document), to: monitorStatusURL(runID: document.runID))
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
        _ events: [ReleaseV090TestnetReadOnlyMonitorEvent],
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

    private func monitorDirectoryURL(runID: Identifier) -> URL {
        storageRootURL
            .appendingPathComponent(runID.rawValue, isDirectory: true)
            .appendingPathComponent("testnet-readonly-monitor", isDirectory: true)
    }

    private func monitorSessionURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("monitor_session.json", isDirectory: false)
    }

    private func monitorEventsURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("monitor_events.jsonl", isDirectory: false)
    }

    private func monitorStatusURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("monitor_status.json", isDirectory: false)
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
