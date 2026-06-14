import DomainModel
import Foundation

/// ReleaseV070OperationalRunSessionError 描述 GH-783 本地 no-order session 状态机错误。
///
/// 错误只覆盖本地 run session lifecycle 的 deterministic transition；不表达
/// endpoint、secret、broker adapter、production OMS 或真实订单能力。
public enum ReleaseV070OperationalRunSessionError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case invalidTransition(command: ReleaseV070OperationalRunSessionCommand, from: ReleaseV070OperationalRunSessionState)
    case eventRunIDMismatch(expected: Identifier, actual: Identifier)
    case eventSequenceMismatch(expected: Int, actual: Int)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.7.0 operational run session requires a non-empty runID"
        case let .invalidTransition(command, state):
            "Release v0.7.0 operational run session rejects \(command.rawValue) from \(state.rawValue)"
        case let .eventRunIDMismatch(expected, actual):
            "Release v0.7.0 operational run session runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .eventSequenceMismatch(expected, actual):
            "Release v0.7.0 operational run session event sequence mismatch: expected \(expected), actual \(actual)"
        case let .boundaryDrift(field):
            "Release v0.7.0 operational run session boundary drift: \(field)"
        }
    }
}

/// ReleaseV070OperationalRunSessionState 固定 GH-783 允许的本地 session 状态。
public enum ReleaseV070OperationalRunSessionState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case created
    case starting
    case running
    case stopping
    case stopped
    case failed
    case completed
    case recovered
}

/// ReleaseV070OperationalRunSessionCommand 固定 GH-783 的本地 no-order command 集合。
public enum ReleaseV070OperationalRunSessionCommand: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case start
    case stop
    case complete
    case fail
    case recover
}

/// ReleaseV070OperationalRunSessionEvidenceEnvelope 是每个 session 状态的 v0.7.0 证据封套。
///
/// 该封套只记录本地 no-order posture。所有 production / broker / order 授权字段
/// 必须保持 false，后续 issue 也只能在同一封套上追加 read-only evidence。
public struct ReleaseV070OperationalRunSessionEvidenceEnvelope: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let sessionMode: String
    public let sessionState: ReleaseV070OperationalRunSessionState
    public let eventCount: Int
    public let lastCommand: ReleaseV070OperationalRunSessionCommand?
    public let operatorConfirmation: String
    public let venue: String
    public let productTypes: [String]
    public let strategies: [String]
    public let noOrder: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let testnetOrderSubmissionAllowed: Bool

    public var envelopeHeld: Bool {
        issueID.rawValue == "GH-783"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-779", "GH-781"]
            && releaseVersion == "v0.7.0"
            && runID.rawValue.isEmpty == false
            && sessionMode == "local-dry-run"
            && eventCount >= 0
            && operatorConfirmation == "not-required-local"
            && venue == "Binance"
            && productTypes == ["spot", "usdsPerpetual"]
            && strategies == ["EMA", "RSI"]
            && noOrder
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && testnetOrderSubmissionAllowed == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-783"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-779"), Identifier.constant("GH-781")],
        releaseVersion: String = "v0.7.0",
        runID: Identifier,
        sessionMode: String = "local-dry-run",
        sessionState: ReleaseV070OperationalRunSessionState,
        eventCount: Int,
        lastCommand: ReleaseV070OperationalRunSessionCommand? = nil,
        operatorConfirmation: String = "not-required-local",
        venue: String = "Binance",
        productTypes: [String] = ["spot", "usdsPerpetual"],
        strategies: [String] = ["EMA", "RSI"],
        noOrder: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.sessionMode = sessionMode
        self.sessionState = sessionState
        self.eventCount = eventCount
        self.lastCommand = lastCommand
        self.operatorConfirmation = operatorConfirmation
        self.venue = venue
        self.productTypes = productTypes
        self.strategies = strategies
        self.noOrder = noOrder
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed

        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070OperationalRunSessionError.emptyRunID
        }
        guard envelopeHeld else {
            throw ReleaseV070OperationalRunSessionError.boundaryDrift("evidenceEnvelope")
        }
    }
}

/// ReleaseV070OperationalRunSessionEvent 记录一次本地 command 产生的 deterministic state transition。
public struct ReleaseV070OperationalRunSessionEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let runID: Identifier
    public let sequence: Int
    public let command: ReleaseV070OperationalRunSessionCommand
    public let fromState: ReleaseV070OperationalRunSessionState
    public let toState: ReleaseV070OperationalRunSessionState
    public let reason: String?
    public let evidenceEnvelope: ReleaseV070OperationalRunSessionEvidenceEnvelope

    public var eventHeld: Bool {
        eventID.rawValue == "\(runID.rawValue)-session-\(sequence)-\(command.rawValue)"
            && sequence > 0
            && evidenceEnvelope.runID == runID
            && evidenceEnvelope.sessionState == toState
            && evidenceEnvelope.eventCount == sequence
            && evidenceEnvelope.lastCommand == command
            && evidenceEnvelope.envelopeHeld
    }

    public init(
        runID: Identifier,
        sequence: Int,
        command: ReleaseV070OperationalRunSessionCommand,
        fromState: ReleaseV070OperationalRunSessionState,
        toState: ReleaseV070OperationalRunSessionState,
        reason: String? = nil
    ) throws {
        self.eventID = Identifier.constant("\(runID.rawValue)-session-\(sequence)-\(command.rawValue)")
        self.runID = runID
        self.sequence = sequence
        self.command = command
        self.fromState = fromState
        self.toState = toState
        self.reason = reason
        self.evidenceEnvelope = try ReleaseV070OperationalRunSessionEvidenceEnvelope(
            runID: runID,
            sessionState: toState,
            eventCount: sequence,
            lastCommand: command
        )

        guard eventHeld else {
            throw ReleaseV070OperationalRunSessionError.boundaryDrift("sessionEvent")
        }
    }
}

/// ReleaseV070OperationalRunSession 是 GH-783 的本地 no-order session lifecycle。
///
/// 该状态机只为 `.local` run evidence 分配 deterministic lifecycle，不创建真实
/// runtime 进程，不读取 secret，不连接 testnet / production endpoint，也不提交订单。
public struct ReleaseV070OperationalRunSession: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let state: ReleaseV070OperationalRunSessionState
    public let events: [ReleaseV070OperationalRunSessionEvent]
    public let evidenceEnvelope: ReleaseV070OperationalRunSessionEvidenceEnvelope

    public var lifecycleHeld: Bool {
        issueID.rawValue == "GH-783"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-779", "GH-781"]
            && releaseVersion == "v0.7.0"
            && runID.rawValue.isEmpty == false
            && evidenceEnvelope.runID == runID
            && evidenceEnvelope.sessionState == state
            && evidenceEnvelope.eventCount == events.count
            && evidenceEnvelope.envelopeHeld
            && events.allSatisfy(\.eventHeld)
            && eventChainHeld
    }

    public var productionDefaultsClosed: Bool {
        evidenceEnvelope.productionTradingEnabledByDefault == false
            && evidenceEnvelope.productionSecretRead == false
            && evidenceEnvelope.productionEndpointConnected == false
            && evidenceEnvelope.productionBrokerConnected == false
            && evidenceEnvelope.productionOrderSubmitted == false
            && evidenceEnvelope.productionCutoverAuthorized == false
            && evidenceEnvelope.testnetOrderSubmissionAllowed == false
    }

    private var eventChainHeld: Bool {
        var expectedState: ReleaseV070OperationalRunSessionState = .created
        for (index, event) in events.enumerated() {
            guard event.runID == runID else { return false }
            guard event.sequence == index + 1 else { return false }
            guard event.fromState == expectedState else { return false }
            guard (try? Self.nextState(command: event.command, from: event.fromState)) == event.toState else {
                return false
            }
            expectedState = event.toState
        }
        return expectedState == state
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-783"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-779"), Identifier.constant("GH-781")],
        releaseVersion: String = "v0.7.0",
        runID: Identifier,
        state: ReleaseV070OperationalRunSessionState = .created,
        events: [ReleaseV070OperationalRunSessionEvent] = []
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070OperationalRunSessionError.emptyRunID
        }
        try Self.validateEvents(events, runID: runID, finalState: state)

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.state = state
        self.events = events
        self.evidenceEnvelope = try ReleaseV070OperationalRunSessionEvidenceEnvelope(
            runID: runID,
            sessionState: state,
            eventCount: events.count,
            lastCommand: events.last?.command
        )

        guard lifecycleHeld else {
            throw ReleaseV070OperationalRunSessionError.boundaryDrift("operationalRunSession")
        }
    }

    public static func created(runID: Identifier) throws -> ReleaseV070OperationalRunSession {
        try ReleaseV070OperationalRunSession(runID: runID)
    }

    public func applying(
        _ command: ReleaseV070OperationalRunSessionCommand,
        reason: String? = nil
    ) throws -> ReleaseV070OperationalRunSession {
        let next = try Self.nextState(command: command, from: state)
        let event = try ReleaseV070OperationalRunSessionEvent(
            runID: runID,
            sequence: events.count + 1,
            command: command,
            fromState: state,
            toState: next,
            reason: reason
        )
        return try ReleaseV070OperationalRunSession(
            runID: runID,
            state: next,
            events: events + [event]
        )
    }

    public static func deterministicCompletedFixture() throws -> ReleaseV070OperationalRunSession {
        try ReleaseV070OperationalRunSession
            .created(runID: Identifier.constant("gh-783-v070-operational-run-session"))
            .applying(.start)
            .applying(.start)
            .applying(.complete)
    }

    public static func deterministicRecoveredFixture() throws -> ReleaseV070OperationalRunSession {
        try ReleaseV070OperationalRunSession
            .created(runID: Identifier.constant("gh-783-v070-recovered-session"))
            .applying(.start)
            .applying(.fail, reason: "operator-observed-local-start-failure")
            .applying(.recover)
    }

    public static func nextState(
        command: ReleaseV070OperationalRunSessionCommand,
        from state: ReleaseV070OperationalRunSessionState
    ) throws -> ReleaseV070OperationalRunSessionState {
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
            throw ReleaseV070OperationalRunSessionError.invalidTransition(command: command, from: state)
        }
    }

    private static func validateEvents(
        _ events: [ReleaseV070OperationalRunSessionEvent],
        runID: Identifier,
        finalState: ReleaseV070OperationalRunSessionState
    ) throws {
        var expectedState: ReleaseV070OperationalRunSessionState = .created
        for (index, event) in events.enumerated() {
            guard event.runID == runID else {
                throw ReleaseV070OperationalRunSessionError.eventRunIDMismatch(
                    expected: runID,
                    actual: event.runID
                )
            }
            guard event.sequence == index + 1 else {
                throw ReleaseV070OperationalRunSessionError.eventSequenceMismatch(
                    expected: index + 1,
                    actual: event.sequence
                )
            }
            guard event.fromState == expectedState else {
                throw ReleaseV070OperationalRunSessionError.invalidTransition(
                    command: event.command,
                    from: event.fromState
                )
            }
            expectedState = try nextState(command: event.command, from: event.fromState)
            guard event.toState == expectedState else {
                throw ReleaseV070OperationalRunSessionError.invalidTransition(
                    command: event.command,
                    from: event.fromState
                )
            }
        }
        guard expectedState == finalState else {
            throw ReleaseV070OperationalRunSessionError.boundaryDrift("finalState")
        }
    }
}

/// ReleaseV070RunRegistryError 描述 GH-785 本地 run registry / supervisor 错误。
///
/// 该错误只覆盖 local registry metadata、list / inspect / archive / recover 语义和
/// no-order supervisor evidence；不表达远程 run service、production scheduler、
/// concurrent production runtime 或真实订单能力。
public enum ReleaseV070RunRegistryError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case duplicateRunID(String)
    case missingRunID(String)
    case cannotMutateArchivedRun(String)
    case productionBoundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.7.0 run registry requires a non-empty runID"
        case let .duplicateRunID(runID):
            "Release v0.7.0 run registry rejects duplicate runID \(runID)"
        case let .missingRunID(runID):
            "Release v0.7.0 run registry cannot find runID \(runID)"
        case let .cannotMutateArchivedRun(runID):
            "Release v0.7.0 run registry rejects archived run mutation for \(runID)"
        case let .productionBoundaryDrift(field):
            "Release v0.7.0 run registry boundary drift: \(field)"
        }
    }
}

/// ReleaseV070RunRegistryLifecycle 固定 GH-785 registry entry 可见 lifecycle。
public enum ReleaseV070RunRegistryLifecycle: String, Codable, CaseIterable, Equatable, Sendable {
    case active
    case archived
    case recoveryEvidence
}

/// ReleaseV070RunArtifactLocation 是 GH-785 registry 保存的本地 artifact path 视图。
public struct ReleaseV070RunArtifactLocation: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let eventsJSONLPath: String
    public let projectionJSONPath: String
    public let summaryJSONPath: String
    public let statusJSONPath: String
    public let manifestJSONPath: String

    public var locationHeld: Bool {
        runDirectoryPath.isEmpty == false
            && eventsJSONLPath.hasSuffix("events.jsonl")
            && projectionJSONPath.hasSuffix("projection.json")
            && summaryJSONPath.hasSuffix("summary.json")
            && statusJSONPath.hasSuffix("_RUN_STATUS.json")
            && manifestJSONPath.hasSuffix("manifest.json")
    }

    public init(runID: Identifier) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RunRegistryError.emptyRunID
        }
        let root = ".local/mtpro/runs/\(runID.rawValue)"
        self.runDirectoryPath = root
        self.eventsJSONLPath = "\(root)/events.jsonl"
        self.projectionJSONPath = "\(root)/projection.json"
        self.summaryJSONPath = "\(root)/summary.json"
        self.statusJSONPath = "\(root)/_RUN_STATUS.json"
        self.manifestJSONPath = "\(root)/manifest.json"
        guard locationHeld else {
            throw ReleaseV070RunRegistryError.productionBoundaryDrift("artifactLocation")
        }
    }
}

/// ReleaseV070RunRegistryEntry 是 GH-785 `runs list` / inspect 的 deterministic 数据源。
public struct ReleaseV070RunRegistryEntry: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let lifecycle: ReleaseV070RunRegistryLifecycle
    public let sessionState: ReleaseV070OperationalRunSessionState
    public let artifactLocation: ReleaseV070RunArtifactLocation
    public let recoverable: Bool
    public let archived: Bool
    public let recoveryReason: String?
    public let productionTradingAuthorized: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var entryHeld: Bool {
        issueID.rawValue == "GH-785"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-784"]
            && releaseVersion == "v0.7.0"
            && runID.rawValue.isEmpty == false
            && artifactLocation.locationHeld
            && archived == (lifecycle == .archived)
            && recoverable == (lifecycle == .recoveryEvidence)
            && productionTradingAuthorized == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-785"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-784")],
        releaseVersion: String = "v0.7.0",
        runID: Identifier,
        lifecycle: ReleaseV070RunRegistryLifecycle,
        sessionState: ReleaseV070OperationalRunSessionState,
        artifactLocation: ReleaseV070RunArtifactLocation? = nil,
        recoveryReason: String? = nil,
        productionTradingAuthorized: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV070RunRegistryError.emptyRunID
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.lifecycle = lifecycle
        self.sessionState = sessionState
        self.artifactLocation = try artifactLocation ?? ReleaseV070RunArtifactLocation(runID: runID)
        self.recoverable = lifecycle == .recoveryEvidence
        self.archived = lifecycle == .archived
        self.recoveryReason = recoveryReason
        self.productionTradingAuthorized = productionTradingAuthorized
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard entryHeld else {
            throw ReleaseV070RunRegistryError.productionBoundaryDrift("registryEntry")
        }
    }
}

/// ReleaseV070RunRegistryListSurface 是 GH-785 `runs list` 的 deterministic 输出形状。
public struct ReleaseV070RunRegistryListSurface: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let entries: [ReleaseV070RunRegistryEntry]
    public let deterministicDataSource: String
    public let productionTradingAuthorized: Bool

    public var listHeld: Bool {
        issueID.rawValue == "GH-785"
            && entries.isEmpty == false
            && entries.allSatisfy(\.entryHeld)
            && Set(entries.map(\.runID.rawValue)).count == entries.count
            && deterministicDataSource == "local-run-registry-metadata"
            && productionTradingAuthorized == false
    }
}

/// ReleaseV070RunRegistry 让 v0.7 run session 成为可 list / inspect / archive / recover 的本地对象。
public struct ReleaseV070RunRegistry: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public private(set) var entries: [ReleaseV070RunRegistryEntry]

    public var registryHeld: Bool {
        issueID.rawValue == "GH-785"
            && entries.isEmpty == false
            && entries.allSatisfy(\.entryHeld)
            && Set(entries.map(\.runID.rawValue)).count == entries.count
            && entries.allSatisfy { $0.productionTradingAuthorized == false }
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-785"),
        entries: [ReleaseV070RunRegistryEntry]
    ) throws {
        self.issueID = issueID
        self.entries = entries.sorted { $0.runID.rawValue < $1.runID.rawValue }
        try validateEntries(self.entries)
        guard registryHeld else {
            throw ReleaseV070RunRegistryError.productionBoundaryDrift("runRegistry")
        }
    }

    public func listRuns() -> ReleaseV070RunRegistryListSurface {
        ReleaseV070RunRegistryListSurface(
            issueID: issueID,
            entries: entries,
            deterministicDataSource: "local-run-registry-metadata",
            productionTradingAuthorized: false
        )
    }

    public func inspect(runID: Identifier) throws -> ReleaseV070RunRegistryEntry {
        guard let entry = entries.first(where: { $0.runID == runID }) else {
            throw ReleaseV070RunRegistryError.missingRunID(runID.rawValue)
        }
        return entry
    }

    public mutating func archive(runID: Identifier) throws -> ReleaseV070RunRegistryEntry {
        let entry = try inspect(runID: runID)
        guard entry.lifecycle != .archived else {
            throw ReleaseV070RunRegistryError.cannotMutateArchivedRun(runID.rawValue)
        }
        return try replace(
            entry: ReleaseV070RunRegistryEntry(
                runID: runID,
                lifecycle: .archived,
                sessionState: entry.sessionState,
                artifactLocation: entry.artifactLocation
            )
        )
    }

    public mutating func recover(runID: Identifier, reason: String) throws -> ReleaseV070RunRegistryEntry {
        let entry = try inspect(runID: runID)
        guard entry.lifecycle != .archived else {
            throw ReleaseV070RunRegistryError.cannotMutateArchivedRun(runID.rawValue)
        }
        return try replace(
            entry: ReleaseV070RunRegistryEntry(
                runID: runID,
                lifecycle: .recoveryEvidence,
                sessionState: .recovered,
                artifactLocation: entry.artifactLocation,
                recoveryReason: reason
            )
        )
    }

    public static func deterministicFixture() throws -> ReleaseV070RunRegistry {
        try ReleaseV070RunRegistry(
            entries: [
                ReleaseV070RunRegistryEntry(
                    runID: Identifier.constant("gh-785-run-alpha"),
                    lifecycle: .active,
                    sessionState: .running
                ),
                ReleaseV070RunRegistryEntry(
                    runID: Identifier.constant("gh-785-run-beta"),
                    lifecycle: .recoveryEvidence,
                    sessionState: .recovered,
                    recoveryReason: "partial-line-recovery-evidence"
                )
            ]
        )
    }

    @discardableResult
    private mutating func replace(
        entry: ReleaseV070RunRegistryEntry
    ) throws -> ReleaseV070RunRegistryEntry {
        guard let index = entries.firstIndex(where: { $0.runID == entry.runID }) else {
            throw ReleaseV070RunRegistryError.missingRunID(entry.runID.rawValue)
        }
        entries[index] = entry
        entries.sort { $0.runID.rawValue < $1.runID.rawValue }
        try validateEntries(entries)
        guard registryHeld else {
            throw ReleaseV070RunRegistryError.productionBoundaryDrift("registryReplace")
        }
        return entry
    }

    private func validateEntries(
        _ entries: [ReleaseV070RunRegistryEntry]
    ) throws {
        var runIDs = Set<String>()
        for entry in entries {
            guard runIDs.insert(entry.runID.rawValue).inserted else {
                throw ReleaseV070RunRegistryError.duplicateRunID(entry.runID.rawValue)
            }
            guard entry.entryHeld else {
                throw ReleaseV070RunRegistryError.productionBoundaryDrift("registryEntry")
            }
        }
    }
}

/// ReleaseV070RunSupervisor 提供 GH-785 本地 no-order supervisor 视图。
///
/// Supervisor 只把 registry state 暴露给 observer / CLI；它不启动远程 scheduler，
/// 不管理 concurrent production runtime，也不能把 production trading 标记为 authorized。
public struct ReleaseV070RunSupervisor: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public private(set) var registry: ReleaseV070RunRegistry
    public let observerSource: String
    public let cliSource: String
    public let productionTradingAuthorized: Bool

    public var supervisorHeld: Bool {
        issueID.rawValue == "GH-785"
            && registry.registryHeld
            && observerSource == "local-run-registry-state"
            && cliSource == "runs-list-inspect-local-registry"
            && productionTradingAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-785"),
        registry: ReleaseV070RunRegistry,
        observerSource: String = "local-run-registry-state",
        cliSource: String = "runs-list-inspect-local-registry",
        productionTradingAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.registry = registry
        self.observerSource = observerSource
        self.cliSource = cliSource
        self.productionTradingAuthorized = productionTradingAuthorized
        guard supervisorHeld else {
            throw ReleaseV070RunRegistryError.productionBoundaryDrift("runSupervisor")
        }
    }

    public func runsListSurface() -> ReleaseV070RunRegistryListSurface {
        registry.listRuns()
    }

    public func inspect(runID: Identifier) throws -> ReleaseV070RunRegistryEntry {
        try registry.inspect(runID: runID)
    }

    public mutating func archive(runID: Identifier) throws -> ReleaseV070RunRegistryEntry {
        try registry.archive(runID: runID)
    }

    public mutating func recover(runID: Identifier, reason: String) throws -> ReleaseV070RunRegistryEntry {
        try registry.recover(runID: runID, reason: reason)
    }

    public static func deterministicFixture() throws -> ReleaseV070RunSupervisor {
        try ReleaseV070RunSupervisor(registry: .deterministicFixture())
    }
}
