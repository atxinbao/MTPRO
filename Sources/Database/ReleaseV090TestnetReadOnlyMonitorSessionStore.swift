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
    case corruptedAccountSnapshotFreshness(String)
    case corruptedPrivateStreamHeartbeat(String)
    case corruptedMonitorRecovery(String)
    case checksumMismatch(expected: String, actual: String)
    case invalidTransition(command: String, fromState: String)
    case unsafeCredentialReference(String)
    case unsafeListenKeyReference(String)
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
        case let .corruptedAccountSnapshotFreshness(path):
            "Release v0.9.0 signed account snapshot freshness fails closed because account-snapshot-freshness.json is corrupted at \(path)"
        case let .corruptedPrivateStreamHeartbeat(path):
            "Release v0.9.0 private stream heartbeat fails closed because private-stream-heartbeat.json is corrupted at \(path)"
        case let .corruptedMonitorRecovery(path):
            "Release v0.9.0 monitor recovery fails closed because monitor-recovery.json is corrupted at \(path)"
        case let .checksumMismatch(expected, actual):
            "Release v0.9.0 testnet read-only monitor session checksum mismatch: expected \(expected), actual \(actual)"
        case let .invalidTransition(command, fromState):
            "Release v0.9.0 testnet read-only monitor session rejects \(command) from \(fromState)"
        case let .unsafeCredentialReference(reference):
            "Release v0.9.0 signed account snapshot freshness rejects unsafe credential reference \(reference)"
        case let .unsafeListenKeyReference(reference):
            "Release v0.9.0 private stream heartbeat rejects unsafe listenKey reference \(reference)"
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
        "V090-003-NO-ORDER-PRODUCTION-CUTOVER",
        "GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS",
        "TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS",
        "V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS",
        "V090-004-ACCOUNT-SNAPSHOT-FRESHNESS-JSON",
        "V090-004-REDACTED-CREDENTIAL-REFERENCE",
        "V090-004-NO-RAW-PAYLOAD-PERSISTENCE",
        "GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS",
        "TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS",
        "V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS",
        "V090-005-PRIVATE-STREAM-HEARTBEAT-JSON",
        "V090-005-REDACTED-LISTENKEY-REFERENCE",
        "V090-005-NO-RAW-PRIVATE-PAYLOAD-PERSISTENCE",
        "GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW",
        "TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW",
        "V090-006-MONITOR-RECOVERY-WORKFLOW",
        "V090-006-MONITOR-RECOVERY-JSON",
        "V090-006-PRESERVE-MONITOR-EVENT-HISTORY",
        "V090-006-LOCAL-MANUAL-RECOVERY-ONLY",
        "GH-850-VERIFY-V090-ALERT-READ-MODEL",
        "TVM-RELEASE-V090-ALERT-READ-MODEL",
        "V090-008-ALERT-READ-MODEL",
        "V090-008-ALERT-FIELDS",
        "V090-008-MONITOR-SESSION-EVIDENCE-BINDING",
        "V090-008-LOCAL-READ-MODEL-ONLY",
        "V090-008-NO-NOTIFICATION-SIDE-EFFECTS",
        "V090-008-NO-AUTOMATED-TRADING-REACTION",
        "V090-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands: [String] = [
        "bash checks/verify-v0.9.0-monitor-session-store.sh",
        "bash checks/verify-v0.9.0-snapshot-freshness-monitor.sh",
        "bash checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh",
        "bash checks/verify-v0.9.0-monitor-recovery-workflow.sh",
        "bash checks/verify-v0.9.0-alert-read-model.sh",
        "swift test --filter TargetGraphTests/testGH845TestnetReadOnlyMonitorSessionStorePersistsArtifactsAndFailsClosed",
        "swift test --filter TargetGraphTests/testGH850MonitorAlertReadModelBindsFreshnessAndHeartbeatWithoutNotificationSideEffects"
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
    public let accountSnapshotFreshnessJSONPath: String
    public let privateStreamHeartbeatJSONPath: String
    public let monitorRecoveryJSONPath: String

    public var pathsHeld: Bool {
        runDirectoryPath.hasPrefix(".local/mtpro/runs/")
            && monitorDirectoryPath == "\(runDirectoryPath)/testnet-readonly-monitor"
            && monitorSessionJSONPath == "\(monitorDirectoryPath)/monitor_session.json"
            && monitorEventsJSONLPath == "\(monitorDirectoryPath)/monitor_events.jsonl"
            && monitorStatusJSONPath == "\(monitorDirectoryPath)/monitor_status.json"
            && accountSnapshotFreshnessJSONPath == "\(monitorDirectoryPath)/account-snapshot-freshness.json"
            && privateStreamHeartbeatJSONPath == "\(monitorDirectoryPath)/private-stream-heartbeat.json"
            && monitorRecoveryJSONPath == "\(monitorDirectoryPath)/monitor-recovery.json"
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
        self.accountSnapshotFreshnessJSONPath = "\(monitorDirectoryPath)/account-snapshot-freshness.json"
        self.privateStreamHeartbeatJSONPath = "\(monitorDirectoryPath)/private-stream-heartbeat.json"
        self.monitorRecoveryJSONPath = "\(monitorDirectoryPath)/monitor-recovery.json"

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
            artifactPaths.accountSnapshotFreshnessJSONPath,
            artifactPaths.privateStreamHeartbeatJSONPath,
            artifactPaths.monitorRecoveryJSONPath,
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

/// ReleaseV090AccountSnapshotFreshnessStatus 固定 v0.9.0 freshness / staleness taxonomy。
///
/// 这些状态只描述本地 read-only monitor artifact freshness，不授权 reconnect、
/// endpoint mutation、broker action、testnet order 或 production order。
public enum ReleaseV090AccountSnapshotFreshnessStatus: String, Codable, CaseIterable, Equatable, Sendable {
    case fresh
    case stale
    case disconnected
    case recovering
    case recovered
    case blocked
    case unavailable
}

/// ReleaseV090AccountSnapshotAgeBucket 固定 account snapshot freshness 的可审计年龄分桶。
public enum ReleaseV090AccountSnapshotAgeBucket: String, Codable, Equatable, Sendable {
    case withinThreshold
    case overThreshold
    case unavailable
}

/// ReleaseV090AccountSnapshotFreshnessDocument 是 `account-snapshot-freshness.json` 的本地 payload。
///
/// 文档只保存 snapshot freshness evidence 和 redacted credential reference；它不保存
/// raw account payload、credential value、endpoint secret、broker state 或 order request。
public struct ReleaseV090AccountSnapshotFreshnessDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.account-snapshot-freshness.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let monitorSessionChecksum: String
    public let accountSnapshotFreshnessJSONPath: String
    public let source: String
    public let snapshotObservedAt: Date
    public let recordedAt: Date
    public let latencyMilliseconds: Int
    public let ageSeconds: Int
    public let staleThresholdSeconds: Int
    public let freshnessStatus: ReleaseV090AccountSnapshotFreshnessStatus
    public let ageBucket: ReleaseV090AccountSnapshotAgeBucket
    public let staleReason: String?
    public let redactedCredentialReference: String
    public let redactionHeld: Bool
    public let rawPayloadPersisted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let credentialValuePersisted: Bool
    public let noOrderHeld: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let ciNetworkRequired: Bool
    public let ciSecretRead: Bool
    public let ciOrderSubmissionAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool
    public let freshnessChecksum: String

    public var documentHeld: Bool {
        issueID.rawValue == "GH-846"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-843", "GH-844", "GH-845"]
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && monitorSessionChecksum.hasPrefix("sha256:")
            && accountSnapshotFreshnessJSONPath == ".local/mtpro/runs/\(runID.rawValue)/testnet-readonly-monitor/account-snapshot-freshness.json"
            && source == "signed-account-snapshot"
            && snapshotObservedAt <= recordedAt
            && latencyMilliseconds >= 0
            && ageSeconds >= 0
            && staleThresholdSeconds > 0
            && freshnessStatus == Self.status(ageSeconds: ageSeconds, staleThresholdSeconds: staleThresholdSeconds)
            && ageBucket == Self.ageBucket(ageSeconds: ageSeconds, staleThresholdSeconds: staleThresholdSeconds)
            && (freshnessStatus == .stale ? staleReason != nil : true)
            && redactedCredentialReference.hasSuffix(":<redacted>")
            && redactedCredentialReference.containsForbiddenCredentialMaterial == false
            && redactionHeld
            && rawPayloadPersisted == false
            && rawAccountPayloadPersisted == false
            && credentialValuePersisted == false
            && noOrderHeld
            && testnetReadOnlyObservabilityAllowed
            && ciNetworkRequired == false
            && ciSecretRead == false
            && ciOrderSubmissionAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
            && freshnessChecksum == Self.stableFreshnessChecksum(
                runID: runID,
                monitorSessionChecksum: monitorSessionChecksum,
                accountSnapshotFreshnessJSONPath: accountSnapshotFreshnessJSONPath,
                source: source,
                snapshotObservedAt: snapshotObservedAt,
                recordedAt: recordedAt,
                latencyMilliseconds: latencyMilliseconds,
                ageSeconds: ageSeconds,
                staleThresholdSeconds: staleThresholdSeconds,
                freshnessStatus: freshnessStatus,
                ageBucket: ageBucket,
                staleReason: staleReason,
                redactedCredentialReference: redactedCredentialReference
            )
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-846"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-843"), Identifier.constant("GH-844"), Identifier.constant("GH-845")],
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        monitorSessionChecksum: String,
        accountSnapshotFreshnessJSONPath: String,
        source: String = "signed-account-snapshot",
        snapshotObservedAt: Date,
        recordedAt: Date,
        latencyMilliseconds: Int,
        staleThresholdSeconds: Int,
        redactedCredentialReference: String,
        staleReason: String? = nil,
        freshnessChecksum: String? = nil,
        redactionHeld: Bool = true,
        rawPayloadPersisted: Bool = false,
        rawAccountPayloadPersisted: Bool = false,
        credentialValuePersisted: Bool = false,
        noOrderHeld: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        ciNetworkRequired: Bool = false,
        ciSecretRead: Bool = false,
        ciOrderSubmissionAllowed: Bool = false,
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
        let ageSeconds = max(0, Int(recordedAt.timeIntervalSince(snapshotObservedAt)))
        let freshnessStatus = Self.status(ageSeconds: ageSeconds, staleThresholdSeconds: staleThresholdSeconds)
        let ageBucket = Self.ageBucket(ageSeconds: ageSeconds, staleThresholdSeconds: staleThresholdSeconds)

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.monitorSessionChecksum = monitorSessionChecksum
        self.accountSnapshotFreshnessJSONPath = accountSnapshotFreshnessJSONPath
        self.source = source
        self.snapshotObservedAt = snapshotObservedAt
        self.recordedAt = recordedAt
        self.latencyMilliseconds = latencyMilliseconds
        self.ageSeconds = ageSeconds
        self.staleThresholdSeconds = staleThresholdSeconds
        self.freshnessStatus = freshnessStatus
        self.ageBucket = ageBucket
        self.staleReason = staleReason
        self.redactedCredentialReference = redactedCredentialReference
        self.redactionHeld = redactionHeld
        self.rawPayloadPersisted = rawPayloadPersisted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.credentialValuePersisted = credentialValuePersisted
        self.noOrderHeld = noOrderHeld
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.ciNetworkRequired = ciNetworkRequired
        self.ciSecretRead = ciSecretRead
        self.ciOrderSubmissionAllowed = ciOrderSubmissionAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed
        self.freshnessChecksum = freshnessChecksum ?? Self.stableFreshnessChecksum(
            runID: runID,
            monitorSessionChecksum: monitorSessionChecksum,
            accountSnapshotFreshnessJSONPath: accountSnapshotFreshnessJSONPath,
            source: source,
            snapshotObservedAt: snapshotObservedAt,
            recordedAt: recordedAt,
            latencyMilliseconds: latencyMilliseconds,
            ageSeconds: ageSeconds,
            staleThresholdSeconds: staleThresholdSeconds,
            freshnessStatus: freshnessStatus,
            ageBucket: ageBucket,
            staleReason: staleReason,
            redactedCredentialReference: redactedCredentialReference
        )

        guard documentHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("accountSnapshotFreshnessDocument")
        }
    }

    public static func status(
        ageSeconds: Int,
        staleThresholdSeconds: Int
    ) -> ReleaseV090AccountSnapshotFreshnessStatus {
        ageSeconds <= staleThresholdSeconds ? .fresh : .stale
    }

    public static func ageBucket(
        ageSeconds: Int,
        staleThresholdSeconds: Int
    ) -> ReleaseV090AccountSnapshotAgeBucket {
        ageSeconds <= staleThresholdSeconds ? .withinThreshold : .overThreshold
    }

    public static func stableFreshnessChecksum(
        runID: Identifier,
        monitorSessionChecksum: String,
        accountSnapshotFreshnessJSONPath: String,
        source: String,
        snapshotObservedAt: Date,
        recordedAt: Date,
        latencyMilliseconds: Int,
        ageSeconds: Int,
        staleThresholdSeconds: Int,
        freshnessStatus: ReleaseV090AccountSnapshotFreshnessStatus,
        ageBucket: ReleaseV090AccountSnapshotAgeBucket,
        staleReason: String?,
        redactedCredentialReference: String
    ) -> String {
        stableSHA256([
            "GH-846",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            monitorSessionChecksum,
            accountSnapshotFreshnessJSONPath,
            source,
            String(snapshotObservedAt.timeIntervalSince1970),
            String(recordedAt.timeIntervalSince1970),
            String(latencyMilliseconds),
            String(ageSeconds),
            String(staleThresholdSeconds),
            freshnessStatus.rawValue,
            ageBucket.rawValue,
            staleReason ?? "",
            redactedCredentialReference,
            "redactionHeld=true",
            "rawPayloadPersisted=false",
            "rawAccountPayloadPersisted=false",
            "credentialValuePersisted=false",
            "noOrderHeld=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "ciNetworkRequired=false",
            "ciSecretRead=false",
            "ciOrderSubmissionAllowed=false",
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

/// ReleaseV090PrivateStreamHeartbeatStatus 固定 private stream read-only monitor 的心跳状态分类。
///
/// 状态只描述本地 evidence 的 freshness / staleness，不触发 reconnect、
/// endpoint mutation、broker action、testnet order 或 production order。
public enum ReleaseV090PrivateStreamHeartbeatStatus: String, Codable, CaseIterable, Equatable, Sendable {
    case healthy
    case stale
    case disconnected
    case recovering
    case recovered
    case expired
    case unavailable
}

/// ReleaseV090PrivateStreamListenKeyAgeBucket 固定 listenKey 生命周期的本地证据分桶。
public enum ReleaseV090PrivateStreamListenKeyAgeBucket: String, Codable, Equatable, Sendable {
    case valid
    case nearExpiry
    case expired
    case unavailable
}

/// ReleaseV090PrivateStreamHeartbeatDocument 是 `private-stream-heartbeat.json` 的本地 payload。
///
/// 文档只保存 private stream heartbeat / staleness evidence 和 redacted listenKey reference；
/// 它不保存 raw listenKey、raw private stream payload、credential value、endpoint secret、
/// broker state 或 order request。
public struct ReleaseV090PrivateStreamHeartbeatDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.private-stream-heartbeat.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let monitorSessionChecksum: String
    public let privateStreamHeartbeatJSONPath: String
    public let source: String
    public let lastEventObservedAt: Date
    public let heartbeatRecordedAt: Date
    public let heartbeatIntervalSeconds: Int
    public let lastEventAgeSeconds: Int
    public let staleThresholdSeconds: Int
    public let listenKeyCreatedAt: Date
    public let listenKeyExpiresAt: Date
    public let listenKeyAgeSeconds: Int
    public let listenKeySecondsUntilExpiry: Int
    public let listenKeyAgeBucket: ReleaseV090PrivateStreamListenKeyAgeBucket
    public let heartbeatStatus: ReleaseV090PrivateStreamHeartbeatStatus
    public let streamStale: Bool
    public let streamRecovered: Bool
    public let disconnectedReason: String?
    public let recoveryReason: String?
    public let redactedListenKeyReference: String
    public let listenKeyReferenceHash: String
    public let redactionHeld: Bool
    public let rawListenKeyPersisted: Bool
    public let rawPrivatePayloadPersisted: Bool
    public let credentialValuePersisted: Bool
    public let noOrderHeld: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let ciNetworkRequired: Bool
    public let ciSecretRead: Bool
    public let ciOrderSubmissionAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool
    public let heartbeatChecksum: String

    public var documentHeld: Bool {
        issueID.rawValue == "GH-847"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-843", "GH-844", "GH-845", "GH-846"]
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && monitorSessionChecksum.hasPrefix("sha256:")
            && privateStreamHeartbeatJSONPath == ".local/mtpro/runs/\(runID.rawValue)/testnet-readonly-monitor/private-stream-heartbeat.json"
            && source == "private-stream-readonly"
            && lastEventObservedAt <= heartbeatRecordedAt
            && listenKeyCreatedAt <= heartbeatRecordedAt
            && listenKeyCreatedAt < listenKeyExpiresAt
            && heartbeatIntervalSeconds > 0
            && lastEventAgeSeconds >= 0
            && staleThresholdSeconds > 0
            && listenKeyAgeSeconds >= 0
            && listenKeySecondsUntilExpiry >= 0
            && listenKeyAgeBucket == Self.listenKeyAgeBucket(
                heartbeatRecordedAt: heartbeatRecordedAt,
                listenKeyExpiresAt: listenKeyExpiresAt,
                nearExpiryThresholdSeconds: heartbeatIntervalSeconds
            )
            && heartbeatStatus == Self.status(
                lastEventAgeSeconds: lastEventAgeSeconds,
                staleThresholdSeconds: staleThresholdSeconds,
                heartbeatRecordedAt: heartbeatRecordedAt,
                listenKeyExpiresAt: listenKeyExpiresAt,
                streamRecovered: streamRecovered,
                disconnectedReason: disconnectedReason
            )
            && streamStale == (lastEventAgeSeconds > staleThresholdSeconds)
            && (streamRecovered ? recoveryReason != nil && streamStale == false : true)
            && redactedListenKeyReference.hasSuffix(":<redacted>")
            && redactedListenKeyReference.containsForbiddenCredentialMaterial == false
            && listenKeyReferenceHash.hasPrefix("sha256:")
            && redactionHeld
            && rawListenKeyPersisted == false
            && rawPrivatePayloadPersisted == false
            && credentialValuePersisted == false
            && noOrderHeld
            && testnetReadOnlyObservabilityAllowed
            && ciNetworkRequired == false
            && ciSecretRead == false
            && ciOrderSubmissionAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
            && heartbeatChecksum == Self.stableHeartbeatChecksum(
                runID: runID,
                monitorSessionChecksum: monitorSessionChecksum,
                privateStreamHeartbeatJSONPath: privateStreamHeartbeatJSONPath,
                source: source,
                lastEventObservedAt: lastEventObservedAt,
                heartbeatRecordedAt: heartbeatRecordedAt,
                heartbeatIntervalSeconds: heartbeatIntervalSeconds,
                lastEventAgeSeconds: lastEventAgeSeconds,
                staleThresholdSeconds: staleThresholdSeconds,
                listenKeyCreatedAt: listenKeyCreatedAt,
                listenKeyExpiresAt: listenKeyExpiresAt,
                listenKeyAgeSeconds: listenKeyAgeSeconds,
                listenKeySecondsUntilExpiry: listenKeySecondsUntilExpiry,
                listenKeyAgeBucket: listenKeyAgeBucket,
                heartbeatStatus: heartbeatStatus,
                streamStale: streamStale,
                streamRecovered: streamRecovered,
                disconnectedReason: disconnectedReason,
                recoveryReason: recoveryReason,
                redactedListenKeyReference: redactedListenKeyReference,
                listenKeyReferenceHash: listenKeyReferenceHash
            )
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-847"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-843"),
            Identifier.constant("GH-844"),
            Identifier.constant("GH-845"),
            Identifier.constant("GH-846")
        ],
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        monitorSessionChecksum: String,
        privateStreamHeartbeatJSONPath: String,
        source: String = "private-stream-readonly",
        lastEventObservedAt: Date,
        heartbeatRecordedAt: Date,
        heartbeatIntervalSeconds: Int,
        staleThresholdSeconds: Int,
        listenKeyCreatedAt: Date,
        listenKeyExpiresAt: Date,
        redactedListenKeyReference: String,
        listenKeyReferenceHash: String,
        disconnectedReason: String? = nil,
        recoveryReason: String? = nil,
        streamRecovered: Bool = false,
        heartbeatChecksum: String? = nil,
        redactionHeld: Bool = true,
        rawListenKeyPersisted: Bool = false,
        rawPrivatePayloadPersisted: Bool = false,
        credentialValuePersisted: Bool = false,
        noOrderHeld: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        ciNetworkRequired: Bool = false,
        ciSecretRead: Bool = false,
        ciOrderSubmissionAllowed: Bool = false,
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
        let lastEventAgeSeconds = max(0, Int(heartbeatRecordedAt.timeIntervalSince(lastEventObservedAt)))
        let listenKeyAgeSeconds = max(0, Int(heartbeatRecordedAt.timeIntervalSince(listenKeyCreatedAt)))
        let listenKeySecondsUntilExpiry = max(0, Int(listenKeyExpiresAt.timeIntervalSince(heartbeatRecordedAt)))
        let listenKeyAgeBucket = Self.listenKeyAgeBucket(
            heartbeatRecordedAt: heartbeatRecordedAt,
            listenKeyExpiresAt: listenKeyExpiresAt,
            nearExpiryThresholdSeconds: heartbeatIntervalSeconds
        )
        let heartbeatStatus = Self.status(
            lastEventAgeSeconds: lastEventAgeSeconds,
            staleThresholdSeconds: staleThresholdSeconds,
            heartbeatRecordedAt: heartbeatRecordedAt,
            listenKeyExpiresAt: listenKeyExpiresAt,
            streamRecovered: streamRecovered,
            disconnectedReason: disconnectedReason
        )
        let streamStale = lastEventAgeSeconds > staleThresholdSeconds

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.monitorSessionChecksum = monitorSessionChecksum
        self.privateStreamHeartbeatJSONPath = privateStreamHeartbeatJSONPath
        self.source = source
        self.lastEventObservedAt = lastEventObservedAt
        self.heartbeatRecordedAt = heartbeatRecordedAt
        self.heartbeatIntervalSeconds = heartbeatIntervalSeconds
        self.lastEventAgeSeconds = lastEventAgeSeconds
        self.staleThresholdSeconds = staleThresholdSeconds
        self.listenKeyCreatedAt = listenKeyCreatedAt
        self.listenKeyExpiresAt = listenKeyExpiresAt
        self.listenKeyAgeSeconds = listenKeyAgeSeconds
        self.listenKeySecondsUntilExpiry = listenKeySecondsUntilExpiry
        self.listenKeyAgeBucket = listenKeyAgeBucket
        self.heartbeatStatus = heartbeatStatus
        self.streamStale = streamStale
        self.streamRecovered = streamRecovered
        self.disconnectedReason = disconnectedReason
        self.recoveryReason = recoveryReason
        self.redactedListenKeyReference = redactedListenKeyReference
        self.listenKeyReferenceHash = listenKeyReferenceHash
        self.redactionHeld = redactionHeld
        self.rawListenKeyPersisted = rawListenKeyPersisted
        self.rawPrivatePayloadPersisted = rawPrivatePayloadPersisted
        self.credentialValuePersisted = credentialValuePersisted
        self.noOrderHeld = noOrderHeld
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.ciNetworkRequired = ciNetworkRequired
        self.ciSecretRead = ciSecretRead
        self.ciOrderSubmissionAllowed = ciOrderSubmissionAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed
        self.heartbeatChecksum = heartbeatChecksum ?? Self.stableHeartbeatChecksum(
            runID: runID,
            monitorSessionChecksum: monitorSessionChecksum,
            privateStreamHeartbeatJSONPath: privateStreamHeartbeatJSONPath,
            source: source,
            lastEventObservedAt: lastEventObservedAt,
            heartbeatRecordedAt: heartbeatRecordedAt,
            heartbeatIntervalSeconds: heartbeatIntervalSeconds,
            lastEventAgeSeconds: lastEventAgeSeconds,
            staleThresholdSeconds: staleThresholdSeconds,
            listenKeyCreatedAt: listenKeyCreatedAt,
            listenKeyExpiresAt: listenKeyExpiresAt,
            listenKeyAgeSeconds: listenKeyAgeSeconds,
            listenKeySecondsUntilExpiry: listenKeySecondsUntilExpiry,
            listenKeyAgeBucket: listenKeyAgeBucket,
            heartbeatStatus: heartbeatStatus,
            streamStale: streamStale,
            streamRecovered: streamRecovered,
            disconnectedReason: disconnectedReason,
            recoveryReason: recoveryReason,
            redactedListenKeyReference: redactedListenKeyReference,
            listenKeyReferenceHash: listenKeyReferenceHash
        )

        guard documentHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("privateStreamHeartbeatDocument")
        }
    }

    public static func status(
        lastEventAgeSeconds: Int,
        staleThresholdSeconds: Int,
        heartbeatRecordedAt: Date,
        listenKeyExpiresAt: Date,
        streamRecovered: Bool,
        disconnectedReason: String?
    ) -> ReleaseV090PrivateStreamHeartbeatStatus {
        if heartbeatRecordedAt >= listenKeyExpiresAt {
            return .expired
        }
        if disconnectedReason != nil {
            return .disconnected
        }
        if streamRecovered {
            return .recovered
        }
        return lastEventAgeSeconds > staleThresholdSeconds ? .stale : .healthy
    }

    public static func listenKeyAgeBucket(
        heartbeatRecordedAt: Date,
        listenKeyExpiresAt: Date,
        nearExpiryThresholdSeconds: Int
    ) -> ReleaseV090PrivateStreamListenKeyAgeBucket {
        let secondsUntilExpiry = Int(listenKeyExpiresAt.timeIntervalSince(heartbeatRecordedAt))
        if secondsUntilExpiry <= 0 {
            return .expired
        }
        if secondsUntilExpiry <= nearExpiryThresholdSeconds {
            return .nearExpiry
        }
        return .valid
    }

    public static func stableHeartbeatChecksum(
        runID: Identifier,
        monitorSessionChecksum: String,
        privateStreamHeartbeatJSONPath: String,
        source: String,
        lastEventObservedAt: Date,
        heartbeatRecordedAt: Date,
        heartbeatIntervalSeconds: Int,
        lastEventAgeSeconds: Int,
        staleThresholdSeconds: Int,
        listenKeyCreatedAt: Date,
        listenKeyExpiresAt: Date,
        listenKeyAgeSeconds: Int,
        listenKeySecondsUntilExpiry: Int,
        listenKeyAgeBucket: ReleaseV090PrivateStreamListenKeyAgeBucket,
        heartbeatStatus: ReleaseV090PrivateStreamHeartbeatStatus,
        streamStale: Bool,
        streamRecovered: Bool,
        disconnectedReason: String?,
        recoveryReason: String?,
        redactedListenKeyReference: String,
        listenKeyReferenceHash: String
    ) -> String {
        stableSHA256([
            "GH-847",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            monitorSessionChecksum,
            privateStreamHeartbeatJSONPath,
            source,
            String(lastEventObservedAt.timeIntervalSince1970),
            String(heartbeatRecordedAt.timeIntervalSince1970),
            String(heartbeatIntervalSeconds),
            String(lastEventAgeSeconds),
            String(staleThresholdSeconds),
            String(listenKeyCreatedAt.timeIntervalSince1970),
            String(listenKeyExpiresAt.timeIntervalSince1970),
            String(listenKeyAgeSeconds),
            String(listenKeySecondsUntilExpiry),
            listenKeyAgeBucket.rawValue,
            heartbeatStatus.rawValue,
            String(streamStale),
            String(streamRecovered),
            disconnectedReason ?? "",
            recoveryReason ?? "",
            redactedListenKeyReference,
            listenKeyReferenceHash,
            "redactionHeld=true",
            "rawListenKeyPersisted=false",
            "rawPrivatePayloadPersisted=false",
            "credentialValuePersisted=false",
            "noOrderHeld=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "ciNetworkRequired=false",
            "ciSecretRead=false",
            "ciOrderSubmissionAllowed=false",
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

    public static func listenKeyReferenceHash(_ reference: String) -> String {
        stableSHA256(["GH-847", "listenKeyReference", reference])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV090MonitorRecoveryAction 固定 no-order monitor recovery 的本地动作分类。
public enum ReleaseV090MonitorRecoveryAction: String, Codable, CaseIterable, Equatable, Sendable {
    case recoverStaleMonitor
    case recoverDisconnectedMonitor
    case reopenListenKeyEvidence
    case rebuildReadModelEvidence
}

/// ReleaseV090MonitorRecoveryDocument 是 `monitor-recovery.json` 的本地 payload。
///
/// 文档只保存手动 recovery evidence、事件历史 checksum 前缀和 redacted listenKey reference；
/// 它不启动 reconnect runtime，不保存 raw listenKey / private payload，不写 broker 或 order。
public struct ReleaseV090MonitorRecoveryDocument: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.monitor-recovery.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let monitorRecoveryJSONPath: String
    public let preRecoveryMonitorSessionChecksum: String
    public let recoveredMonitorSessionChecksum: String
    public let recoveryAction: ReleaseV090MonitorRecoveryAction
    public let fromState: ReleaseV090TestnetReadOnlyMonitorState
    public let intermediateState: ReleaseV090TestnetReadOnlyMonitorState
    public let toState: ReleaseV090TestnetReadOnlyMonitorState
    public let recoveryReason: String
    public let recoveredAt: Date
    public let observedAfterRecoveryAt: Date
    public let previousEventCount: Int
    public let recoveredEventCount: Int
    public let previousEventChecksums: [String]
    public let recoveredEventChecksums: [String]
    public let eventHistoryPreserved: Bool
    public let redactedListenKeyReference: String
    public let listenKeyReferenceHash: String
    public let reopenedListenKeyEvidence: Bool
    public let rebuiltReadModelEvidence: Bool
    public let rebuiltReadModelEvidenceChecksum: String
    public let manualLocalRecovery: Bool
    public let automaticReconnectCommand: Bool
    public let rawListenKeyPersisted: Bool
    public let rawPrivatePayloadPersisted: Bool
    public let credentialValuePersisted: Bool
    public let noOrderHeld: Bool
    public let testnetReadOnlyObservabilityAllowed: Bool
    public let ciNetworkRequired: Bool
    public let ciSecretRead: Bool
    public let ciOrderSubmissionAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool
    public let recoveryChecksum: String

    public var documentHeld: Bool {
        issueID.rawValue == "GH-848"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-843", "GH-844", "GH-845", "GH-846", "GH-847"]
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && monitorRecoveryJSONPath == ".local/mtpro/runs/\(runID.rawValue)/testnet-readonly-monitor/monitor-recovery.json"
            && preRecoveryMonitorSessionChecksum.hasPrefix("sha256:")
            && recoveredMonitorSessionChecksum.hasPrefix("sha256:")
            && (recoveryAction == .recoverStaleMonitor || recoveryAction == .recoverDisconnectedMonitor)
            && (fromState == .stale || fromState == .disconnected)
            && intermediateState == .recovering
            && toState == .observing
            && recoveryReason.isEmpty == false
            && recoveredAt <= observedAfterRecoveryAt
            && previousEventCount == previousEventChecksums.count
            && recoveredEventCount == recoveredEventChecksums.count
            && recoveredEventCount == previousEventCount + 2
            && Array(recoveredEventChecksums.prefix(previousEventChecksums.count)) == previousEventChecksums
            && eventHistoryPreserved
            && redactedListenKeyReference.hasSuffix(":<redacted>")
            && redactedListenKeyReference.containsForbiddenCredentialMaterial == false
            && listenKeyReferenceHash.hasPrefix("sha256:")
            && reopenedListenKeyEvidence
            && rebuiltReadModelEvidence
            && rebuiltReadModelEvidenceChecksum.hasPrefix("sha256:")
            && manualLocalRecovery
            && automaticReconnectCommand == false
            && rawListenKeyPersisted == false
            && rawPrivatePayloadPersisted == false
            && credentialValuePersisted == false
            && noOrderHeld
            && testnetReadOnlyObservabilityAllowed
            && ciNetworkRequired == false
            && ciSecretRead == false
            && ciOrderSubmissionAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
            && recoveryChecksum == Self.stableRecoveryChecksum(
                runID: runID,
                monitorRecoveryJSONPath: monitorRecoveryJSONPath,
                preRecoveryMonitorSessionChecksum: preRecoveryMonitorSessionChecksum,
                recoveredMonitorSessionChecksum: recoveredMonitorSessionChecksum,
                recoveryAction: recoveryAction,
                fromState: fromState,
                intermediateState: intermediateState,
                toState: toState,
                recoveryReason: recoveryReason,
                recoveredAt: recoveredAt,
                observedAfterRecoveryAt: observedAfterRecoveryAt,
                previousEventChecksums: previousEventChecksums,
                recoveredEventChecksums: recoveredEventChecksums,
                redactedListenKeyReference: redactedListenKeyReference,
                listenKeyReferenceHash: listenKeyReferenceHash,
                rebuiltReadModelEvidenceChecksum: rebuiltReadModelEvidenceChecksum
            )
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-848"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-843"),
            Identifier.constant("GH-844"),
            Identifier.constant("GH-845"),
            Identifier.constant("GH-846"),
            Identifier.constant("GH-847")
        ],
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        monitorRecoveryJSONPath: String,
        preRecoveryMonitorSessionChecksum: String,
        recoveredMonitorSessionChecksum: String,
        recoveryAction: ReleaseV090MonitorRecoveryAction,
        fromState: ReleaseV090TestnetReadOnlyMonitorState,
        intermediateState: ReleaseV090TestnetReadOnlyMonitorState,
        toState: ReleaseV090TestnetReadOnlyMonitorState,
        recoveryReason: String,
        recoveredAt: Date,
        observedAfterRecoveryAt: Date,
        previousEventChecksums: [String],
        recoveredEventChecksums: [String],
        redactedListenKeyReference: String,
        listenKeyReferenceHash: String,
        rebuiltReadModelEvidenceChecksum: String,
        recoveryChecksum: String? = nil,
        reopenedListenKeyEvidence: Bool = true,
        rebuiltReadModelEvidence: Bool = true,
        manualLocalRecovery: Bool = true,
        automaticReconnectCommand: Bool = false,
        rawListenKeyPersisted: Bool = false,
        rawPrivatePayloadPersisted: Bool = false,
        credentialValuePersisted: Bool = false,
        noOrderHeld: Bool = true,
        testnetReadOnlyObservabilityAllowed: Bool = true,
        ciNetworkRequired: Bool = false,
        ciSecretRead: Bool = false,
        ciOrderSubmissionAllowed: Bool = false,
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
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.monitorRecoveryJSONPath = monitorRecoveryJSONPath
        self.preRecoveryMonitorSessionChecksum = preRecoveryMonitorSessionChecksum
        self.recoveredMonitorSessionChecksum = recoveredMonitorSessionChecksum
        self.recoveryAction = recoveryAction
        self.fromState = fromState
        self.intermediateState = intermediateState
        self.toState = toState
        self.recoveryReason = recoveryReason
        self.recoveredAt = recoveredAt
        self.observedAfterRecoveryAt = observedAfterRecoveryAt
        self.previousEventCount = previousEventChecksums.count
        self.recoveredEventCount = recoveredEventChecksums.count
        self.previousEventChecksums = previousEventChecksums
        self.recoveredEventChecksums = recoveredEventChecksums
        self.eventHistoryPreserved = Array(recoveredEventChecksums.prefix(previousEventChecksums.count)) == previousEventChecksums
        self.redactedListenKeyReference = redactedListenKeyReference
        self.listenKeyReferenceHash = listenKeyReferenceHash
        self.reopenedListenKeyEvidence = reopenedListenKeyEvidence
        self.rebuiltReadModelEvidence = rebuiltReadModelEvidence
        self.rebuiltReadModelEvidenceChecksum = rebuiltReadModelEvidenceChecksum
        self.manualLocalRecovery = manualLocalRecovery
        self.automaticReconnectCommand = automaticReconnectCommand
        self.rawListenKeyPersisted = rawListenKeyPersisted
        self.rawPrivatePayloadPersisted = rawPrivatePayloadPersisted
        self.credentialValuePersisted = credentialValuePersisted
        self.noOrderHeld = noOrderHeld
        self.testnetReadOnlyObservabilityAllowed = testnetReadOnlyObservabilityAllowed
        self.ciNetworkRequired = ciNetworkRequired
        self.ciSecretRead = ciSecretRead
        self.ciOrderSubmissionAllowed = ciOrderSubmissionAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed
        self.recoveryChecksum = recoveryChecksum ?? Self.stableRecoveryChecksum(
            runID: runID,
            monitorRecoveryJSONPath: monitorRecoveryJSONPath,
            preRecoveryMonitorSessionChecksum: preRecoveryMonitorSessionChecksum,
            recoveredMonitorSessionChecksum: recoveredMonitorSessionChecksum,
            recoveryAction: recoveryAction,
            fromState: fromState,
            intermediateState: intermediateState,
            toState: toState,
            recoveryReason: recoveryReason,
            recoveredAt: recoveredAt,
            observedAfterRecoveryAt: observedAfterRecoveryAt,
            previousEventChecksums: previousEventChecksums,
            recoveredEventChecksums: recoveredEventChecksums,
            redactedListenKeyReference: redactedListenKeyReference,
            listenKeyReferenceHash: listenKeyReferenceHash,
            rebuiltReadModelEvidenceChecksum: rebuiltReadModelEvidenceChecksum
        )

        guard documentHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorRecoveryDocument")
        }
    }

    public static func readModelEvidenceChecksum(_ reference: String) -> String {
        stableSHA256(["GH-848", "rebuiltReadModelEvidence", reference])
    }

    public static func stableRecoveryChecksum(
        runID: Identifier,
        monitorRecoveryJSONPath: String,
        preRecoveryMonitorSessionChecksum: String,
        recoveredMonitorSessionChecksum: String,
        recoveryAction: ReleaseV090MonitorRecoveryAction,
        fromState: ReleaseV090TestnetReadOnlyMonitorState,
        intermediateState: ReleaseV090TestnetReadOnlyMonitorState,
        toState: ReleaseV090TestnetReadOnlyMonitorState,
        recoveryReason: String,
        recoveredAt: Date,
        observedAfterRecoveryAt: Date,
        previousEventChecksums: [String],
        recoveredEventChecksums: [String],
        redactedListenKeyReference: String,
        listenKeyReferenceHash: String,
        rebuiltReadModelEvidenceChecksum: String
    ) -> String {
        stableSHA256([
            "GH-848",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            monitorRecoveryJSONPath,
            preRecoveryMonitorSessionChecksum,
            recoveredMonitorSessionChecksum,
            recoveryAction.rawValue,
            fromState.rawValue,
            intermediateState.rawValue,
            toState.rawValue,
            recoveryReason,
            String(recoveredAt.timeIntervalSince1970),
            String(observedAfterRecoveryAt.timeIntervalSince1970),
            String(previousEventChecksums.count),
            String(recoveredEventChecksums.count),
            previousEventChecksums.joined(separator: ","),
            recoveredEventChecksums.joined(separator: ","),
            redactedListenKeyReference,
            listenKeyReferenceHash,
            "reopenedListenKeyEvidence=true",
            "rebuiltReadModelEvidence=true",
            rebuiltReadModelEvidenceChecksum,
            "manualLocalRecovery=true",
            "automaticReconnectCommand=false",
            "rawListenKeyPersisted=false",
            "rawPrivatePayloadPersisted=false",
            "credentialValuePersisted=false",
            "noOrderHeld=true",
            "testnetReadOnlyObservabilityAllowed=true",
            "ciNetworkRequired=false",
            "ciSecretRead=false",
            "ciOrderSubmissionAllowed=false",
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

/// ReleaseV090MonitorAlertSeverity 固定 GH-850 alert read-model 的本地严重度分类。
///
/// 严重度只用于 operator 可读的本地 monitor freshness / staleness 视图，不会触发
/// SMS、email、webhook、push、paging、automatic recovery、broker command 或任何订单动作。
public enum ReleaseV090MonitorAlertSeverity: String, Codable, CaseIterable, Equatable, Sendable {
    case info
    case warning
    case critical
}

/// ReleaseV090MonitorAlertSource 固定 GH-850 alert 可以绑定的本地 evidence 来源。
public enum ReleaseV090MonitorAlertSource: String, Codable, CaseIterable, Equatable, Sendable {
    case accountSnapshotFreshness
    case privateStreamHeartbeat
}

/// ReleaseV090MonitorAlertLifecycle 固定 GH-850 alert 的本地 lifecycle 状态。
public enum ReleaseV090MonitorAlertLifecycle: String, Codable, CaseIterable, Equatable, Sendable {
    case raised
    case acknowledged
    case resolved
}

/// ReleaseV090MonitorAlert 是 GH-850 的本地 alert 行。
///
/// JSON 字段显式保留 `alert_id` 和 `ack_required`，以便后续 Dashboard / CLI 可以
/// 稳定读取；但该行只是一条本地 read-model evidence，不保存通知配置，不调用外部服务，
/// 不触发 automatic trading reaction，也不授权 testnet / production submit / cancel / replace。
public struct ReleaseV090MonitorAlert: Codable, Equatable, Sendable {
    public let alertID: Identifier
    public let severity: ReleaseV090MonitorAlertSeverity
    public let reason: String
    public let source: ReleaseV090MonitorAlertSource
    public let ackRequired: Bool
    public let lifecycle: ReleaseV090MonitorAlertLifecycle
    public let raisedAt: Date
    public let acknowledgedAt: Date?
    public let resolvedAt: Date?
    public let lastUpdatedAt: Date
    public let monitorSessionChecksum: String
    public let sourceChecksum: String
    public let sourceArtifact: String
    public let localReadModelOnly: Bool
    public let notificationSideEffectsEnabled: Bool
    public let smsNotificationSent: Bool
    public let emailNotificationSent: Bool
    public let webhookNotificationSent: Bool
    public let pushNotificationSent: Bool
    public let externalServiceCalled: Bool
    public let pagingCommandCreated: Bool
    public let incidentCommandCreated: Bool
    public let automaticRecoveryCommand: Bool
    public let automatedTradingReactionEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let alertChecksum: String

    private enum CodingKeys: String, CodingKey {
        case alertID = "alert_id"
        case severity
        case reason
        case source
        case ackRequired = "ack_required"
        case lifecycle
        case raisedAt
        case acknowledgedAt
        case resolvedAt
        case lastUpdatedAt
        case monitorSessionChecksum
        case sourceChecksum
        case sourceArtifact
        case localReadModelOnly
        case notificationSideEffectsEnabled
        case smsNotificationSent
        case emailNotificationSent
        case webhookNotificationSent
        case pushNotificationSent
        case externalServiceCalled
        case pagingCommandCreated
        case incidentCommandCreated
        case automaticRecoveryCommand
        case automatedTradingReactionEnabled
        case tradingButtonVisible
        case orderFormVisible
        case liveCommandEnabled
        case testnetOrderRoutingAllowed
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case alertChecksum
    }

    public var alertHeld: Bool {
        alertID.rawValue.isEmpty == false
            && reason.isEmpty == false
            && raisedAt <= lastUpdatedAt
            && (ackRequired ? lifecycle == .raised || lifecycle == .acknowledged : true)
            && (lifecycle == .acknowledged ? acknowledgedAt != nil : true)
            && (lifecycle == .resolved ? resolvedAt != nil && ackRequired == false : true)
            && monitorSessionChecksum.hasPrefix("sha256:")
            && sourceChecksum.hasPrefix("sha256:")
            && ["account-snapshot-freshness.json", "private-stream-heartbeat.json"].contains(sourceArtifact)
            && localReadModelOnly
            && notificationSideEffectsEnabled == false
            && smsNotificationSent == false
            && emailNotificationSent == false
            && webhookNotificationSent == false
            && pushNotificationSent == false
            && externalServiceCalled == false
            && pagingCommandCreated == false
            && incidentCommandCreated == false
            && automaticRecoveryCommand == false
            && automatedTradingReactionEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && testnetOrderRoutingAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && alertChecksum == Self.stableAlertChecksum(
                alertID: alertID,
                severity: severity,
                reason: reason,
                source: source,
                ackRequired: ackRequired,
                lifecycle: lifecycle,
                raisedAt: raisedAt,
                acknowledgedAt: acknowledgedAt,
                resolvedAt: resolvedAt,
                lastUpdatedAt: lastUpdatedAt,
                monitorSessionChecksum: monitorSessionChecksum,
                sourceChecksum: sourceChecksum,
                sourceArtifact: sourceArtifact
            )
    }

    public init(
        alertID: Identifier,
        severity: ReleaseV090MonitorAlertSeverity,
        reason: String,
        source: ReleaseV090MonitorAlertSource,
        ackRequired: Bool,
        lifecycle: ReleaseV090MonitorAlertLifecycle,
        raisedAt: Date,
        acknowledgedAt: Date? = nil,
        resolvedAt: Date? = nil,
        lastUpdatedAt: Date,
        monitorSessionChecksum: String,
        sourceChecksum: String,
        sourceArtifact: String,
        alertChecksum: String? = nil,
        localReadModelOnly: Bool = true,
        notificationSideEffectsEnabled: Bool = false,
        smsNotificationSent: Bool = false,
        emailNotificationSent: Bool = false,
        webhookNotificationSent: Bool = false,
        pushNotificationSent: Bool = false,
        externalServiceCalled: Bool = false,
        pagingCommandCreated: Bool = false,
        incidentCommandCreated: Bool = false,
        automaticRecoveryCommand: Bool = false,
        automatedTradingReactionEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.alertID = alertID
        self.severity = severity
        self.reason = reason
        self.source = source
        self.ackRequired = ackRequired
        self.lifecycle = lifecycle
        self.raisedAt = raisedAt
        self.acknowledgedAt = acknowledgedAt
        self.resolvedAt = resolvedAt
        self.lastUpdatedAt = lastUpdatedAt
        self.monitorSessionChecksum = monitorSessionChecksum
        self.sourceChecksum = sourceChecksum
        self.sourceArtifact = sourceArtifact
        self.localReadModelOnly = localReadModelOnly
        self.notificationSideEffectsEnabled = notificationSideEffectsEnabled
        self.smsNotificationSent = smsNotificationSent
        self.emailNotificationSent = emailNotificationSent
        self.webhookNotificationSent = webhookNotificationSent
        self.pushNotificationSent = pushNotificationSent
        self.externalServiceCalled = externalServiceCalled
        self.pagingCommandCreated = pagingCommandCreated
        self.incidentCommandCreated = incidentCommandCreated
        self.automaticRecoveryCommand = automaticRecoveryCommand
        self.automatedTradingReactionEnabled = automatedTradingReactionEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.alertChecksum = alertChecksum ?? Self.stableAlertChecksum(
            alertID: alertID,
            severity: severity,
            reason: reason,
            source: source,
            ackRequired: ackRequired,
            lifecycle: lifecycle,
            raisedAt: raisedAt,
            acknowledgedAt: acknowledgedAt,
            resolvedAt: resolvedAt,
            lastUpdatedAt: lastUpdatedAt,
            monitorSessionChecksum: monitorSessionChecksum,
            sourceChecksum: sourceChecksum,
            sourceArtifact: sourceArtifact
        )

        guard alertHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorAlert")
        }
    }

    public static func stableAlertChecksum(
        alertID: Identifier,
        severity: ReleaseV090MonitorAlertSeverity,
        reason: String,
        source: ReleaseV090MonitorAlertSource,
        ackRequired: Bool,
        lifecycle: ReleaseV090MonitorAlertLifecycle,
        raisedAt: Date,
        acknowledgedAt: Date?,
        resolvedAt: Date?,
        lastUpdatedAt: Date,
        monitorSessionChecksum: String,
        sourceChecksum: String,
        sourceArtifact: String
    ) -> String {
        stableSHA256([
            "GH-850",
            "v0.9.0",
            alertID.rawValue,
            severity.rawValue,
            reason,
            source.rawValue,
            String(ackRequired),
            lifecycle.rawValue,
            String(raisedAt.timeIntervalSince1970),
            String(acknowledgedAt?.timeIntervalSince1970 ?? 0),
            String(resolvedAt?.timeIntervalSince1970 ?? 0),
            String(lastUpdatedAt.timeIntervalSince1970),
            monitorSessionChecksum,
            sourceChecksum,
            sourceArtifact,
            "localReadModelOnly=true",
            "notificationSideEffectsEnabled=false",
            "smsNotificationSent=false",
            "emailNotificationSent=false",
            "webhookNotificationSent=false",
            "pushNotificationSent=false",
            "externalServiceCalled=false",
            "pagingCommandCreated=false",
            "incidentCommandCreated=false",
            "automaticRecoveryCommand=false",
            "automatedTradingReactionEnabled=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandEnabled=false",
            "testnetOrderRoutingAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false"
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV090MonitorAlertReadModel 是 GH-850 的本地 alert read-model envelope。
///
/// Read model 从 monitor session、account snapshot freshness 和 private stream heartbeat
/// checksum 派生 alert_id / severity / reason / source / ack_required / lifecycle 字段。
/// 它不持久化通知队列，不调用短信、邮件、webhook、push 或外部服务，不自动恢复，
/// 不触发交易反应，也不授权 testnet / production 订单。
public struct ReleaseV090MonitorAlertReadModel: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.9.0.monitor-alert-read-model.v1"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let releaseVersion: String
    public let schemaVersion: String
    public let runID: Identifier
    public let generatedAt: Date
    public let monitorSessionChecksum: String
    public let accountSnapshotFreshnessChecksum: String
    public let privateStreamHeartbeatChecksum: String
    public let alerts: [ReleaseV090MonitorAlert]
    public let localReadModelOnly: Bool
    public let noNotificationSideEffects: Bool
    public let smsNotificationSent: Bool
    public let emailNotificationSent: Bool
    public let webhookNotificationSent: Bool
    public let pushNotificationSent: Bool
    public let externalServiceCalled: Bool
    public let automatedTradingReactionEnabled: Bool
    public let noOrderHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let requiredValidationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let readModelChecksum: String

    public var readModelHeld: Bool {
        issueID.rawValue == "GH-850"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-845", "GH-846", "GH-847", "GH-849"]
            && previousIssueID.rawValue == "GH-849"
            && downstreamIssueID.rawValue == "GH-851"
            && releaseVersion == "v0.9.0"
            && schemaVersion == Self.schemaVersion
            && runID.rawValue.isEmpty == false
            && monitorSessionChecksum.hasPrefix("sha256:")
            && accountSnapshotFreshnessChecksum.hasPrefix("sha256:")
            && privateStreamHeartbeatChecksum.hasPrefix("sha256:")
            && alerts.isEmpty == false
            && alerts.allSatisfy(\.alertHeld)
            && alerts.allSatisfy { $0.monitorSessionChecksum == monitorSessionChecksum }
            && alerts.contains { $0.source == .accountSnapshotFreshness }
            && alerts.contains { $0.source == .privateStreamHeartbeat }
            && alerts.contains { $0.ackRequired }
            && localReadModelOnly
            && noNotificationSideEffects
            && smsNotificationSent == false
            && emailNotificationSent == false
            && webhookNotificationSent == false
            && pushNotificationSent == false
            && externalServiceCalled == false
            && automatedTradingReactionEnabled == false
            && noOrderHeld
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && requiredValidationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && readModelChecksum == Self.stableReadModelChecksum(
                runID: runID,
                generatedAt: generatedAt,
                monitorSessionChecksum: monitorSessionChecksum,
                accountSnapshotFreshnessChecksum: accountSnapshotFreshnessChecksum,
                privateStreamHeartbeatChecksum: privateStreamHeartbeatChecksum,
                alerts: alerts
            )
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-850"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-845"),
            Identifier.constant("GH-846"),
            Identifier.constant("GH-847"),
            Identifier.constant("GH-849")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-849"),
        downstreamIssueID: Identifier = Identifier.constant("GH-851"),
        releaseVersion: String = "v0.9.0",
        schemaVersion: String = Self.schemaVersion,
        runID: Identifier,
        generatedAt: Date,
        monitorSessionChecksum: String,
        accountSnapshotFreshnessChecksum: String,
        privateStreamHeartbeatChecksum: String,
        alerts: [ReleaseV090MonitorAlert],
        readModelChecksum: String? = nil,
        localReadModelOnly: Bool = true,
        noNotificationSideEffects: Bool = true,
        smsNotificationSent: Bool = false,
        emailNotificationSent: Bool = false,
        webhookNotificationSent: Bool = false,
        pushNotificationSent: Bool = false,
        externalServiceCalled: Bool = false,
        automatedTradingReactionEnabled: Bool = false,
        noOrderHeld: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        requiredValidationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.generatedAt = generatedAt
        self.monitorSessionChecksum = monitorSessionChecksum
        self.accountSnapshotFreshnessChecksum = accountSnapshotFreshnessChecksum
        self.privateStreamHeartbeatChecksum = privateStreamHeartbeatChecksum
        self.alerts = alerts
        self.localReadModelOnly = localReadModelOnly
        self.noNotificationSideEffects = noNotificationSideEffects
        self.smsNotificationSent = smsNotificationSent
        self.emailNotificationSent = emailNotificationSent
        self.webhookNotificationSent = webhookNotificationSent
        self.pushNotificationSent = pushNotificationSent
        self.externalServiceCalled = externalServiceCalled
        self.automatedTradingReactionEnabled = automatedTradingReactionEnabled
        self.noOrderHeld = noOrderHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.requiredValidationAnchors = requiredValidationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.readModelChecksum = readModelChecksum ?? Self.stableReadModelChecksum(
            runID: runID,
            generatedAt: generatedAt,
            monitorSessionChecksum: monitorSessionChecksum,
            accountSnapshotFreshnessChecksum: accountSnapshotFreshnessChecksum,
            privateStreamHeartbeatChecksum: privateStreamHeartbeatChecksum,
            alerts: alerts
        )

        guard readModelHeld else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("monitorAlertReadModel")
        }
    }

    public init(
        session: ReleaseV090TestnetReadOnlyMonitorSessionDocument,
        accountSnapshotFreshness: ReleaseV090AccountSnapshotFreshnessDocument,
        privateStreamHeartbeat: ReleaseV090PrivateStreamHeartbeatDocument,
        generatedAt: Date
    ) throws {
        let alerts = try Self.makeAlerts(
            session: session,
            accountSnapshotFreshness: accountSnapshotFreshness,
            privateStreamHeartbeat: privateStreamHeartbeat,
            generatedAt: generatedAt
        )
        try self.init(
            runID: session.runID,
            generatedAt: generatedAt,
            monitorSessionChecksum: session.sessionChecksum,
            accountSnapshotFreshnessChecksum: accountSnapshotFreshness.freshnessChecksum,
            privateStreamHeartbeatChecksum: privateStreamHeartbeat.heartbeatChecksum,
            alerts: alerts
        )
    }

    public static let requiredValidationAnchors = [
        "GH-850-VERIFY-V090-ALERT-READ-MODEL",
        "TVM-RELEASE-V090-ALERT-READ-MODEL",
        "V090-008-ALERT-READ-MODEL",
        "V090-008-ALERT-FIELDS",
        "V090-008-MONITOR-SESSION-EVIDENCE-BINDING",
        "V090-008-LOCAL-READ-MODEL-ONLY",
        "V090-008-NO-NOTIFICATION-SIDE-EFFECTS",
        "V090-008-NO-AUTOMATED-TRADING-REACTION",
        "V090-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH850MonitorAlertReadModelBindsFreshnessAndHeartbeatWithoutNotificationSideEffects",
        "bash checks/verify-v0.9.0-alert-read-model.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func makeAlerts(
        session: ReleaseV090TestnetReadOnlyMonitorSessionDocument,
        accountSnapshotFreshness: ReleaseV090AccountSnapshotFreshnessDocument,
        privateStreamHeartbeat: ReleaseV090PrivateStreamHeartbeatDocument,
        generatedAt: Date
    ) throws -> [ReleaseV090MonitorAlert] {
        var alerts: [ReleaseV090MonitorAlert] = []

        if accountSnapshotFreshness.freshnessStatus == .stale {
            alerts.append(try ReleaseV090MonitorAlert(
                alertID: Identifier.constant("gh-850-\(session.runID.rawValue)-snapshot-stale"),
                severity: .warning,
                reason: accountSnapshotFreshness.staleReason ?? "account-snapshot-freshness-stale",
                source: .accountSnapshotFreshness,
                ackRequired: true,
                lifecycle: .raised,
                raisedAt: generatedAt,
                lastUpdatedAt: generatedAt,
                monitorSessionChecksum: session.sessionChecksum,
                sourceChecksum: accountSnapshotFreshness.freshnessChecksum,
                sourceArtifact: "account-snapshot-freshness.json"
            ))
        }

        switch privateStreamHeartbeat.heartbeatStatus {
        case .stale:
            alerts.append(try ReleaseV090MonitorAlert(
                alertID: Identifier.constant("gh-850-\(session.runID.rawValue)-private-stream-stale"),
                severity: .warning,
                reason: "private-stream-heartbeat-stale",
                source: .privateStreamHeartbeat,
                ackRequired: true,
                lifecycle: .raised,
                raisedAt: generatedAt,
                lastUpdatedAt: generatedAt,
                monitorSessionChecksum: session.sessionChecksum,
                sourceChecksum: privateStreamHeartbeat.heartbeatChecksum,
                sourceArtifact: "private-stream-heartbeat.json"
            ))
        case .disconnected, .expired:
            alerts.append(try ReleaseV090MonitorAlert(
                alertID: Identifier.constant("gh-850-\(session.runID.rawValue)-private-stream-\(privateStreamHeartbeat.heartbeatStatus.rawValue)"),
                severity: .critical,
                reason: privateStreamHeartbeat.disconnectedReason ?? "private-stream-\(privateStreamHeartbeat.heartbeatStatus.rawValue)",
                source: .privateStreamHeartbeat,
                ackRequired: true,
                lifecycle: .raised,
                raisedAt: generatedAt,
                lastUpdatedAt: generatedAt,
                monitorSessionChecksum: session.sessionChecksum,
                sourceChecksum: privateStreamHeartbeat.heartbeatChecksum,
                sourceArtifact: "private-stream-heartbeat.json"
            ))
        case .recovered:
            alerts.append(try ReleaseV090MonitorAlert(
                alertID: Identifier.constant("gh-850-\(session.runID.rawValue)-private-stream-recovered"),
                severity: .info,
                reason: privateStreamHeartbeat.recoveryReason ?? "private-stream-recovered",
                source: .privateStreamHeartbeat,
                ackRequired: false,
                lifecycle: .resolved,
                raisedAt: generatedAt,
                resolvedAt: generatedAt,
                lastUpdatedAt: generatedAt,
                monitorSessionChecksum: session.sessionChecksum,
                sourceChecksum: privateStreamHeartbeat.heartbeatChecksum,
                sourceArtifact: "private-stream-heartbeat.json"
            ))
        case .healthy, .recovering, .unavailable:
            break
        }

        return alerts
    }

    public static func deterministicFixture(
        generatedAt: Date = Date(timeIntervalSince1970: 1_782_500_080)
    ) throws -> ReleaseV090MonitorAlertReadModel {
        let session = try ReleaseV090TestnetReadOnlyMonitorSessionStore.deterministicFixture(
            createdAt: Date(timeIntervalSince1970: 1_782_500_000)
        )
        let freshness = try ReleaseV090AccountSnapshotFreshnessDocument(
            runID: session.runID,
            monitorSessionChecksum: session.sessionChecksum,
            accountSnapshotFreshnessJSONPath: session.artifactPaths.accountSnapshotFreshnessJSONPath,
            snapshotObservedAt: Date(timeIntervalSince1970: 1_782_500_000),
            recordedAt: Date(timeIntervalSince1970: 1_782_500_080),
            latencyMilliseconds: 240,
            staleThresholdSeconds: 30,
            redactedCredentialReference: "gh-850-testnet-readonly-profile:<redacted>",
            staleReason: "snapshot-age-over-threshold"
        )
        let heartbeat = try ReleaseV090PrivateStreamHeartbeatDocument(
            runID: session.runID,
            monitorSessionChecksum: session.sessionChecksum,
            privateStreamHeartbeatJSONPath: session.artifactPaths.privateStreamHeartbeatJSONPath,
            lastEventObservedAt: Date(timeIntervalSince1970: 1_782_500_000),
            heartbeatRecordedAt: Date(timeIntervalSince1970: 1_782_500_080),
            heartbeatIntervalSeconds: 60,
            staleThresholdSeconds: 45,
            listenKeyCreatedAt: Date(timeIntervalSince1970: 1_782_500_000),
            listenKeyExpiresAt: Date(timeIntervalSince1970: 1_782_503_600),
            redactedListenKeyReference: "gh-850-stream-lease-profile:<redacted>",
            listenKeyReferenceHash: ReleaseV090PrivateStreamHeartbeatDocument.listenKeyReferenceHash(
                "gh-850-stream-lease-profile"
            ),
            disconnectedReason: "heartbeat-missed"
        )
        return try ReleaseV090MonitorAlertReadModel(
            session: session,
            accountSnapshotFreshness: freshness,
            privateStreamHeartbeat: heartbeat,
            generatedAt: generatedAt
        )
    }

    public static func stableReadModelChecksum(
        runID: Identifier,
        generatedAt: Date,
        monitorSessionChecksum: String,
        accountSnapshotFreshnessChecksum: String,
        privateStreamHeartbeatChecksum: String,
        alerts: [ReleaseV090MonitorAlert]
    ) -> String {
        stableSHA256([
            "GH-850",
            "v0.9.0",
            Self.schemaVersion,
            runID.rawValue,
            String(generatedAt.timeIntervalSince1970),
            monitorSessionChecksum,
            accountSnapshotFreshnessChecksum,
            privateStreamHeartbeatChecksum,
            "localReadModelOnly=true",
            "noNotificationSideEffects=true",
            "smsNotificationSent=false",
            "emailNotificationSent=false",
            "webhookNotificationSent=false",
            "pushNotificationSent=false",
            "externalServiceCalled=false",
            "automatedTradingReactionEnabled=false",
            "noOrderHeld=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false"
        ] + alerts.map(\.alertChecksum))
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
    public func recordAccountSnapshotFreshness(
        runID: Identifier,
        snapshotObservedAt: Date,
        recordedAt: Date,
        latencyMilliseconds: Int,
        staleThresholdSeconds: Int,
        credentialReference: String,
        staleReason: String? = nil
    ) throws -> ReleaseV090AccountSnapshotFreshnessDocument {
        try withMonitorLock(runID: runID) {
            let session = try load(runID: runID)
            let redactedCredentialReference = try Self.redactedCredentialReference(from: credentialReference)
            let document = try ReleaseV090AccountSnapshotFreshnessDocument(
                runID: runID,
                monitorSessionChecksum: session.sessionChecksum,
                accountSnapshotFreshnessJSONPath: session.artifactPaths.accountSnapshotFreshnessJSONPath,
                snapshotObservedAt: snapshotObservedAt,
                recordedAt: recordedAt,
                latencyMilliseconds: latencyMilliseconds,
                staleThresholdSeconds: staleThresholdSeconds,
                redactedCredentialReference: redactedCredentialReference,
                staleReason: staleReason
            )
            try writeJSON(document, to: accountSnapshotFreshnessURL(runID: runID))
            return document
        }
    }

    public func accountSnapshotFreshness(runID: Identifier) throws -> ReleaseV090AccountSnapshotFreshnessDocument {
        let freshnessURL = try accountSnapshotFreshnessURL(runID: runID)
        guard fileManager.fileExists(atPath: freshnessURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedAccountSnapshotFreshness(freshnessURL.path)
        }
        do {
            let session = try load(runID: runID)
            let data = try Data(contentsOf: freshnessURL)
            let document = try Self.decoder.decode(ReleaseV090AccountSnapshotFreshnessDocument.self, from: data)
            let expectedChecksum = ReleaseV090AccountSnapshotFreshnessDocument.stableFreshnessChecksum(
                runID: document.runID,
                monitorSessionChecksum: document.monitorSessionChecksum,
                accountSnapshotFreshnessJSONPath: document.accountSnapshotFreshnessJSONPath,
                source: document.source,
                snapshotObservedAt: document.snapshotObservedAt,
                recordedAt: document.recordedAt,
                latencyMilliseconds: document.latencyMilliseconds,
                ageSeconds: document.ageSeconds,
                staleThresholdSeconds: document.staleThresholdSeconds,
                freshnessStatus: document.freshnessStatus,
                ageBucket: document.ageBucket,
                staleReason: document.staleReason,
                redactedCredentialReference: document.redactedCredentialReference
            )
            guard document.freshnessChecksum == expectedChecksum else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.freshnessChecksum
                )
            }
            guard document.monitorSessionChecksum == session.sessionChecksum, document.documentHeld else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("decodedAccountSnapshotFreshness")
            }
            return document
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedAccountSnapshotFreshness(freshnessURL.path)
        }
    }

    @discardableResult
    public func recordPrivateStreamHeartbeat(
        runID: Identifier,
        lastEventObservedAt: Date,
        heartbeatRecordedAt: Date,
        heartbeatIntervalSeconds: Int,
        staleThresholdSeconds: Int,
        listenKeyCreatedAt: Date,
        listenKeyExpiresAt: Date,
        listenKeyReference: String,
        disconnectedReason: String? = nil,
        recoveryReason: String? = nil,
        streamRecovered: Bool = false
    ) throws -> ReleaseV090PrivateStreamHeartbeatDocument {
        try withMonitorLock(runID: runID) {
            let session = try load(runID: runID)
            let redactedListenKeyReference = try Self.redactedListenKeyReference(from: listenKeyReference)
            let listenKeyReferenceHash = ReleaseV090PrivateStreamHeartbeatDocument.listenKeyReferenceHash(listenKeyReference)
            let document = try ReleaseV090PrivateStreamHeartbeatDocument(
                runID: runID,
                monitorSessionChecksum: session.sessionChecksum,
                privateStreamHeartbeatJSONPath: session.artifactPaths.privateStreamHeartbeatJSONPath,
                lastEventObservedAt: lastEventObservedAt,
                heartbeatRecordedAt: heartbeatRecordedAt,
                heartbeatIntervalSeconds: heartbeatIntervalSeconds,
                staleThresholdSeconds: staleThresholdSeconds,
                listenKeyCreatedAt: listenKeyCreatedAt,
                listenKeyExpiresAt: listenKeyExpiresAt,
                redactedListenKeyReference: redactedListenKeyReference,
                listenKeyReferenceHash: listenKeyReferenceHash,
                disconnectedReason: disconnectedReason,
                recoveryReason: recoveryReason,
                streamRecovered: streamRecovered
            )
            try writeJSON(document, to: privateStreamHeartbeatURL(runID: runID))
            return document
        }
    }

    public func privateStreamHeartbeat(runID: Identifier) throws -> ReleaseV090PrivateStreamHeartbeatDocument {
        let heartbeatURL = try privateStreamHeartbeatURL(runID: runID)
        guard fileManager.fileExists(atPath: heartbeatURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedPrivateStreamHeartbeat(heartbeatURL.path)
        }
        do {
            let session = try load(runID: runID)
            let data = try Data(contentsOf: heartbeatURL)
            let document = try Self.decoder.decode(ReleaseV090PrivateStreamHeartbeatDocument.self, from: data)
            let expectedChecksum = ReleaseV090PrivateStreamHeartbeatDocument.stableHeartbeatChecksum(
                runID: document.runID,
                monitorSessionChecksum: document.monitorSessionChecksum,
                privateStreamHeartbeatJSONPath: document.privateStreamHeartbeatJSONPath,
                source: document.source,
                lastEventObservedAt: document.lastEventObservedAt,
                heartbeatRecordedAt: document.heartbeatRecordedAt,
                heartbeatIntervalSeconds: document.heartbeatIntervalSeconds,
                lastEventAgeSeconds: document.lastEventAgeSeconds,
                staleThresholdSeconds: document.staleThresholdSeconds,
                listenKeyCreatedAt: document.listenKeyCreatedAt,
                listenKeyExpiresAt: document.listenKeyExpiresAt,
                listenKeyAgeSeconds: document.listenKeyAgeSeconds,
                listenKeySecondsUntilExpiry: document.listenKeySecondsUntilExpiry,
                listenKeyAgeBucket: document.listenKeyAgeBucket,
                heartbeatStatus: document.heartbeatStatus,
                streamStale: document.streamStale,
                streamRecovered: document.streamRecovered,
                disconnectedReason: document.disconnectedReason,
                recoveryReason: document.recoveryReason,
                redactedListenKeyReference: document.redactedListenKeyReference,
                listenKeyReferenceHash: document.listenKeyReferenceHash
            )
            guard document.heartbeatChecksum == expectedChecksum else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.heartbeatChecksum
                )
            }
            guard document.monitorSessionChecksum == session.sessionChecksum, document.documentHeld else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("decodedPrivateStreamHeartbeat")
            }
            return document
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedPrivateStreamHeartbeat(heartbeatURL.path)
        }
    }

    @discardableResult
    public func recordMonitorRecovery(
        runID: Identifier,
        recoveredAt: Date,
        listenKeyReference: String,
        recoveryReason: String,
        rebuiltReadModelEvidenceReference: String,
        observedAfterRecoveryAt: Date? = nil
    ) throws -> ReleaseV090MonitorRecoveryDocument {
        try withMonitorLock(runID: runID) {
            let current = try load(runID: runID)
            guard current.state == .stale || current.state == .disconnected else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.invalidTransition(
                    command: ReleaseV090TestnetReadOnlyMonitorCommand.recover.rawValue,
                    fromState: current.state.rawValue
                )
            }
            let observedAt = observedAfterRecoveryAt ?? recoveredAt.addingTimeInterval(1)
            let recovering = try current.applying(command: .recover, reason: recoveryReason, at: recoveredAt)
            let recovered = try recovering.applying(command: .observe, reason: "monitor-recovery-observed", at: observedAt)
            try writeUnlocked(recovered)

            let redactedListenKeyReference = try Self.redactedListenKeyReference(from: listenKeyReference)
            let listenKeyReferenceHash = ReleaseV090PrivateStreamHeartbeatDocument.listenKeyReferenceHash(listenKeyReference)
            let previousEventChecksums = current.events.map(\.eventChecksum)
            let recoveredEventChecksums = recovered.events.map(\.eventChecksum)
            let action: ReleaseV090MonitorRecoveryAction = current.state == .stale
                ? .recoverStaleMonitor
                : .recoverDisconnectedMonitor
            let document = try ReleaseV090MonitorRecoveryDocument(
                runID: runID,
                monitorRecoveryJSONPath: recovered.artifactPaths.monitorRecoveryJSONPath,
                preRecoveryMonitorSessionChecksum: current.sessionChecksum,
                recoveredMonitorSessionChecksum: recovered.sessionChecksum,
                recoveryAction: action,
                fromState: current.state,
                intermediateState: recovering.state,
                toState: recovered.state,
                recoveryReason: recoveryReason,
                recoveredAt: recoveredAt,
                observedAfterRecoveryAt: observedAt,
                previousEventChecksums: previousEventChecksums,
                recoveredEventChecksums: recoveredEventChecksums,
                redactedListenKeyReference: redactedListenKeyReference,
                listenKeyReferenceHash: listenKeyReferenceHash,
                rebuiltReadModelEvidenceChecksum: ReleaseV090MonitorRecoveryDocument.readModelEvidenceChecksum(
                    rebuiltReadModelEvidenceReference
                )
            )
            try writeJSON(document, to: monitorRecoveryURL(runID: runID))
            return document
        }
    }

    public func monitorRecovery(runID: Identifier) throws -> ReleaseV090MonitorRecoveryDocument {
        let recoveryURL = try monitorRecoveryURL(runID: runID)
        guard fileManager.fileExists(atPath: recoveryURL.path) else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorRecovery(recoveryURL.path)
        }
        do {
            let session = try load(runID: runID)
            let data = try Data(contentsOf: recoveryURL)
            let document = try Self.decoder.decode(ReleaseV090MonitorRecoveryDocument.self, from: data)
            let expectedChecksum = ReleaseV090MonitorRecoveryDocument.stableRecoveryChecksum(
                runID: document.runID,
                monitorRecoveryJSONPath: document.monitorRecoveryJSONPath,
                preRecoveryMonitorSessionChecksum: document.preRecoveryMonitorSessionChecksum,
                recoveredMonitorSessionChecksum: document.recoveredMonitorSessionChecksum,
                recoveryAction: document.recoveryAction,
                fromState: document.fromState,
                intermediateState: document.intermediateState,
                toState: document.toState,
                recoveryReason: document.recoveryReason,
                recoveredAt: document.recoveredAt,
                observedAfterRecoveryAt: document.observedAfterRecoveryAt,
                previousEventChecksums: document.previousEventChecksums,
                recoveredEventChecksums: document.recoveredEventChecksums,
                redactedListenKeyReference: document.redactedListenKeyReference,
                listenKeyReferenceHash: document.listenKeyReferenceHash,
                rebuiltReadModelEvidenceChecksum: document.rebuiltReadModelEvidenceChecksum
            )
            guard document.recoveryChecksum == expectedChecksum else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.checksumMismatch(
                    expected: expectedChecksum,
                    actual: document.recoveryChecksum
                )
            }
            guard document.recoveredMonitorSessionChecksum == session.sessionChecksum, document.documentHeld else {
                throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.boundaryDrift("decodedMonitorRecovery")
            }
            return document
        } catch let error as ReleaseV090TestnetReadOnlyMonitorSessionStoreError {
            throw error
        } catch {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.corruptedMonitorRecovery(recoveryURL.path)
        }
    }

    public func monitorAlertReadModel(
        runID: Identifier,
        generatedAt: Date
    ) throws -> ReleaseV090MonitorAlertReadModel {
        let session = try load(runID: runID)
        let freshness = try accountSnapshotFreshness(runID: runID)
        let heartbeat = try privateStreamHeartbeat(runID: runID)
        return try ReleaseV090MonitorAlertReadModel(
            session: session,
            accountSnapshotFreshness: freshness,
            privateStreamHeartbeat: heartbeat,
            generatedAt: generatedAt
        )
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

    private func accountSnapshotFreshnessURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("account-snapshot-freshness.json", isDirectory: false)
    }

    private func privateStreamHeartbeatURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("private-stream-heartbeat.json", isDirectory: false)
    }

    private func monitorRecoveryURL(runID: Identifier) throws -> URL {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.emptyRunID
        }
        return monitorDirectoryURL(runID: runID).appendingPathComponent("monitor-recovery.json", isDirectory: false)
    }

    private static func redactedCredentialReference(from credentialReference: String) throws -> String {
        let trimmed = credentialReference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, trimmed.containsForbiddenCredentialMaterial == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.unsafeCredentialReference(credentialReference)
        }
        return "\(trimmed):<redacted>"
    }

    private static func redactedListenKeyReference(from listenKeyReference: String) throws -> String {
        let trimmed = listenKeyReference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, trimmed.containsForbiddenCredentialMaterial == false else {
            throw ReleaseV090TestnetReadOnlyMonitorSessionStoreError.unsafeListenKeyReference(listenKeyReference)
        }
        return "\(trimmed):<redacted>"
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

private extension String {
    /// 只允许保存逻辑 credential profile reference；明显的 secret、token 或 raw key 片段必须 fail closed。
    var containsForbiddenCredentialMaterial: Bool {
        let lowered = lowercased()
        let forbiddenFragments = [
            "secret",
            "api_key",
            "apikey",
            "api-key",
            "token",
            "password",
            "private",
            "raw",
            "listenkey",
            "listen-key",
            "signature=",
            "x-mbx-apikey",
            "begin ",
            "-----"
        ]
        if forbiddenFragments.contains(where: lowered.contains) {
            return true
        }
        let compact = replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ":", with: "")
        return compact.count >= 32 && compact.allSatisfy { $0.isLetter || $0.isNumber }
    }
}
