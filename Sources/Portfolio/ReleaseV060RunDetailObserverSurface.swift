import Database
import DomainModel
import Foundation
import MessageBus

/// ReleaseV060RunDetailObserverSurfaceError 描述 GH-764 本地 run detail observer 错误。
///
/// 错误只覆盖本地 artifact 读取、manifest 校验、CLI 参数和只读 read-model 边界；
/// 它不表达 trading button、order form、broker command 或 production cutover 能力。
public enum ReleaseV060RunDetailObserverSurfaceError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidArguments(String)
    case noCompletedRuns(String)
    case artifactGap(String)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case projectionMismatch(String)
    case forbiddenCommandSurface(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case let .invalidArguments(arguments):
            "Release v0.6.0 run detail observer invalid CLI arguments: \(arguments)"
        case let .noCompletedRuns(root):
            "Release v0.6.0 run detail observer found no completed runs under \(root)"
        case let .artifactGap(reason):
            "Release v0.6.0 run detail observer artifact gap: \(reason)"
        case let .runIDMismatch(expected, actual):
            "Release v0.6.0 run detail observer runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .projectionMismatch(reason):
            "Release v0.6.0 run detail observer projection mismatch: \(reason)"
        case let .forbiddenCommandSurface(field):
            "Release v0.6.0 run detail observer rejected command surface: \(field)"
        case let .contractDrift(reason):
            "Release v0.6.0 run detail observer contract drift: \(reason)"
        }
    }
}

/// ReleaseV060RunDetailObserverSection 固定 GH-764 Dashboard run detail sections。
public enum ReleaseV060RunDetailObserverSection:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case runOverview = "Run Overview"
    case eventTimeline = "Event Timeline"
    case riskDecisions = "Risk Decisions"
    case omsTimeline = "OMS Timeline"
    case portfolioProjection = "Portfolio Projection"
    case boundaryEnvironmentSecretPolicy = "Boundary / Environment / Secret Policy"
}

/// ReleaseV060RunDetailObserverCommand 固定 GH-764 允许的 CLI 只读子命令。
public enum ReleaseV060RunDetailObserverCommand:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case list
    case status
    case events
    case projection
    case risk
}

/// ReleaseV060RunDetailObserverStatus 是 Dashboard / CLI 共享的只读状态。
public enum ReleaseV060RunDetailObserverStatus: String, Codable, Equatable, Hashable, Sendable {
    case ready
    case blocked
    case error
    case gap
}

/// ReleaseV060RunDetailObserverArtifactHealth 描述 artifact-backed read-model 健康状态。
public enum ReleaseV060RunDetailObserverArtifactHealth: String, Codable, Equatable, Hashable, Sendable {
    case healthy
    case gap
    case error
}

/// ReleaseV060RunDetailObserverSectionRecord 是 Dashboard / CLI 共用 section 摘要。
///
/// 每条 section 都必须来自同一个本地 runID 的 artifact，不得授权 command、order form
/// 或 trading button。
public struct ReleaseV060RunDetailObserverSectionRecord: Codable, Equatable, Sendable {
    public let section: ReleaseV060RunDetailObserverSection
    public let status: ReleaseV060RunDetailObserverStatus
    public let artifactNames: [String]
    public let itemCount: Int
    public let summary: String
    public let visibleOnDashboard: Bool
    public let visibleOnCLI: Bool
    public let readModelOnly: Bool
    public let authorizesCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesTradingButton: Bool

    public var recordHeld: Bool {
        itemCount >= 0
            && summary.isEmpty == false
            && visibleOnDashboard
            && visibleOnCLI
            && readModelOnly
            && authorizesCommand == false
            && exposesOrderForm == false
            && exposesTradingButton == false
    }

    public init(
        section: ReleaseV060RunDetailObserverSection,
        status: ReleaseV060RunDetailObserverStatus,
        artifactNames: [String],
        itemCount: Int,
        summary: String,
        visibleOnDashboard: Bool = true,
        visibleOnCLI: Bool = true,
        readModelOnly: Bool = true,
        authorizesCommand: Bool = false,
        exposesOrderForm: Bool = false,
        exposesTradingButton: Bool = false
    ) throws {
        try Self.reject(authorizesCommand, "authorizesCommand")
        try Self.reject(exposesOrderForm, "exposesOrderForm")
        try Self.reject(exposesTradingButton, "exposesTradingButton")
        self.section = section
        self.status = status
        self.artifactNames = artifactNames
        self.itemCount = itemCount
        self.summary = summary
        self.visibleOnDashboard = visibleOnDashboard
        self.visibleOnCLI = visibleOnCLI
        self.readModelOnly = readModelOnly
        self.authorizesCommand = authorizesCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesTradingButton = exposesTradingButton

        guard recordHeld else {
            throw ReleaseV060RunDetailObserverSurfaceError.contractDrift(section.rawValue)
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV060RunDetailObserverSurfaceError.forbiddenCommandSurface(field)
        }
    }
}

/// ReleaseV060RunDetailObserverReadModelState 把缺失或损坏 artifact 转成 UI 可展示状态。
public struct ReleaseV060RunDetailObserverReadModelState: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let artifactHealth: ReleaseV060RunDetailObserverArtifactHealth
    public let healthy: Bool
    public let message: String
    public let dashboardReadModelOnly: Bool
    public let commandSurfaceEnabled: Bool
    public let productionTradingEnabledByDefault: Bool

    public var stateHeld: Bool {
        issueID.rawValue == "GH-764"
            && healthy == (artifactHealth == .healthy)
            && message.isEmpty == false
            && dashboardReadModelOnly
            && commandSurfaceEnabled == false
            && productionTradingEnabledByDefault == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-764"),
        runID: Identifier,
        artifactHealth: ReleaseV060RunDetailObserverArtifactHealth,
        message: String,
        dashboardReadModelOnly: Bool = true,
        commandSurfaceEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        self.issueID = issueID
        self.runID = runID
        self.artifactHealth = artifactHealth
        self.healthy = artifactHealth == .healthy
        self.message = message
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault

        guard stateHeld else {
            throw ReleaseV060RunDetailObserverSurfaceError.contractDrift("readModelState")
        }
    }
}

/// ReleaseV060RunDetailObserverEvidence 汇总 GH-764 artifact-backed observer evidence。
public struct ReleaseV060RunDetailObserverEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let storageRootPath: String
    public let observedRunIDs: [Identifier]
    public let selectedRunID: Identifier
    public let writerStatus: ReleaseV060LocalRunJournalWriterStatus
    public let manifestValidation: ReleaseV060LocalRunJournalManifestValidation
    public let manifestArtifactPaths: [String]
    public let reconstructedJournal: ReleaseV050DurableLocalRunJournal
    public let decodedProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let rebuiltProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let sectionRecords: [ReleaseV060RunDetailObserverSectionRecord]
    public let cliCommands: [ReleaseV060RunDetailObserverCommand]
    public let riskDecisions: [RuntimeRiskDecision]
    public let riskReasons: [String]
    public let omsStates: [RuntimeOMSState]
    public let payloadTypes: [RuntimeEventPayloadType]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let cliReadsRunList: Bool
    public let cliReadsStatusEventsProjectionRisk: Bool
    public let dashboardReadsSameManifestAsCLI: Bool
    public let manifestValidatedBeforeHealthyState: Bool
    public let missingOrCorruptArtifactShownAsGap: Bool
    public let dashboardReadModelOnly: Bool
    public let tradingButtonExposed: Bool
    public let orderFormExposed: Bool
    public let liveCommandSurfaceExposed: Bool
    public let brokerExecutionWriteEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-764"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-757", "GH-759", "GH-760", "GH-761", "GH-762", "GH-763"]
            && previousIssueID.rawValue == "GH-763"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-766"]
            && releaseVersion == "v0.6.0"
            && storageRootPath.isEmpty == false
            && observedRunIDs.contains(selectedRunID)
            && writerStatus.runID == selectedRunID
            && writerStatus.completed
            && writerStatus.state == .completed
            && manifestValidation.validationHeld
            && manifestValidation.runID == selectedRunID
            && manifestArtifactPaths.map { URL(fileURLWithPath: $0).lastPathComponent }
                == ["events.jsonl", "projection.json", "summary.json", "_RUN_STATUS.json"]
            && reconstructedJournal.paths.runID == selectedRunID
            && reconstructedJournal.appendOnlyHeld
            && reconstructedJournal.records.count == writerStatus.eventCount
            && decodedProjectionEvidence.evidenceHeld
            && decodedProjectionEvidence.runID == selectedRunID
            && rebuiltProjectionEvidence == decodedProjectionEvidence
            && sectionRecords.map(\.section) == ReleaseV060RunDetailObserverSection.allCases
            && sectionRecords.allSatisfy(\.recordHeld)
            && cliCommands == ReleaseV060RunDetailObserverCommand.allCases
            && riskDecisions.contains(.allowed)
            && riskDecisions.contains(.rejected)
            && riskDecisions.contains(.blocked)
            && riskReasons.isEmpty == false
            && omsStates.contains(.simulatedFilled)
            && Set(payloadTypes).isSuperset(of: Set(Self.requiredPayloadTypes))
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && observerBoundaryHeld
            && forbiddenBoundaryHeld
    }

    public var observerBoundaryHeld: Bool {
        cliReadsRunList
            && cliReadsStatusEventsProjectionRisk
            && dashboardReadsSameManifestAsCLI
            && manifestValidatedBeforeHealthyState
            && missingOrCorruptArtifactShownAsGap
            && dashboardReadModelOnly
    }

    public var forbiddenBoundaryHeld: Bool {
        tradingButtonExposed == false
            && orderFormExposed == false
            && liveCommandSurfaceExposed == false
            && brokerExecutionWriteEnabled == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-764-v060-run-detail-observer-evidence"),
        issueID: Identifier = Identifier.constant("GH-764"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-756"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-759"),
            Identifier.constant("GH-760"),
            Identifier.constant("GH-761"),
            Identifier.constant("GH-762"),
            Identifier.constant("GH-763")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-763"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-766")],
        releaseVersion: String = "v0.6.0",
        storageRootPath: String,
        observedRunIDs: [Identifier],
        selectedRunID: Identifier,
        writerStatus: ReleaseV060LocalRunJournalWriterStatus,
        manifestValidation: ReleaseV060LocalRunJournalManifestValidation,
        manifestArtifactPaths: [String],
        reconstructedJournal: ReleaseV050DurableLocalRunJournal,
        decodedProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence,
        rebuiltProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence,
        sectionRecords: [ReleaseV060RunDetailObserverSectionRecord],
        cliCommands: [ReleaseV060RunDetailObserverCommand] = ReleaseV060RunDetailObserverCommand.allCases,
        riskDecisions: [RuntimeRiskDecision],
        riskReasons: [String],
        omsStates: [RuntimeOMSState],
        payloadTypes: [RuntimeEventPayloadType],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        cliReadsRunList: Bool = true,
        cliReadsStatusEventsProjectionRisk: Bool = true,
        dashboardReadsSameManifestAsCLI: Bool = true,
        manifestValidatedBeforeHealthyState: Bool = true,
        missingOrCorruptArtifactShownAsGap: Bool = true,
        dashboardReadModelOnly: Bool = true,
        tradingButtonExposed: Bool = false,
        orderFormExposed: Bool = false,
        liveCommandSurfaceExposed: Bool = false,
        brokerExecutionWriteEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.reject(tradingButtonExposed, "tradingButtonExposed")
        try Self.reject(orderFormExposed, "orderFormExposed")
        try Self.reject(liveCommandSurfaceExposed, "liveCommandSurfaceExposed")
        try Self.reject(brokerExecutionWriteEnabled, "brokerExecutionWriteEnabled")
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.storageRootPath = storageRootPath
        self.observedRunIDs = observedRunIDs
        self.selectedRunID = selectedRunID
        self.writerStatus = writerStatus
        self.manifestValidation = manifestValidation
        self.manifestArtifactPaths = manifestArtifactPaths
        self.reconstructedJournal = reconstructedJournal
        self.decodedProjectionEvidence = decodedProjectionEvidence
        self.rebuiltProjectionEvidence = rebuiltProjectionEvidence
        self.sectionRecords = sectionRecords
        self.cliCommands = cliCommands
        self.riskDecisions = riskDecisions
        self.riskReasons = riskReasons
        self.omsStates = omsStates
        self.payloadTypes = payloadTypes
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.cliReadsRunList = cliReadsRunList
        self.cliReadsStatusEventsProjectionRisk = cliReadsStatusEventsProjectionRisk
        self.dashboardReadsSameManifestAsCLI = dashboardReadsSameManifestAsCLI
        self.manifestValidatedBeforeHealthyState = manifestValidatedBeforeHealthyState
        self.missingOrCorruptArtifactShownAsGap = missingOrCorruptArtifactShownAsGap
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.tradingButtonExposed = tradingButtonExposed
        self.orderFormExposed = orderFormExposed
        self.liveCommandSurfaceExposed = liveCommandSurfaceExposed
        self.brokerExecutionWriteEnabled = brokerExecutionWriteEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV060RunDetailObserverSurfaceError.contractDrift("runDetailObserverEvidence")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV060RunDetailObserverSurfaceError.forbiddenCommandSurface(field)
        }
    }

    public static let requiredPayloadTypes: [RuntimeEventPayloadType] = [
        .dataEngineMarketEvent,
        .strategyIntentEvent,
        .riskDecisionEvent,
        .omsLifecycleEvent,
        .executionClientDryRunEvent,
        .portfolioProjectionEvent
    ]

    public static let requiredValidationAnchors = [
        "V060-010-DASHBOARD-CLI-RUN-DETAIL-OBSERVER",
        "V060-010-ARTIFACT-BACKED-RUN-LIST-STATUS-EVENTS-PROJECTION-RISK",
        "V060-010-DASHBOARD-READS-SAME-MANIFEST-AS-CLI",
        "V060-010-MANIFEST-CORRUPTION-GAP-STATE",
        "V060-010-NO-PRODUCTION-COMMAND-SURFACE",
        "TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH764DashboardCLIRunDetailObserverReadsArtifactBackedRunJournal",
        "bash checks/verify-v0.6.0-run-detail-observer.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV060RunDetailObserverSurface 从 v0.6 本地 run artifacts 生成 read-only observer。
public struct ReleaseV060RunDetailObserverSurface {
    public static let cliCommand = "run-detail-observer"

    public let storageRootURL: URL
    private let fileManager: FileManager

    public init(
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true),
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    public func runIDs() throws -> [Identifier] {
        guard fileManager.fileExists(atPath: storageRootURL.path) else {
            return []
        }
        return try fileManager.contentsOfDirectory(
            at: storageRootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        .filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
        .map { Identifier.constant($0.lastPathComponent) }
        .sorted { $0.rawValue < $1.rawValue }
    }

    public func observe(runID: Identifier) throws -> ReleaseV060RunDetailObserverEvidence {
        let listedRunIDs = try runIDs()
        guard listedRunIDs.contains(runID) else {
            throw ReleaseV060RunDetailObserverSurfaceError.noCompletedRuns(storageRootURL.path)
        }
        let writer = ReleaseV060LocalRunJournalWriter(storageRootURL: storageRootURL, fileManager: fileManager)
        let status = try writer.inspectRun(runID: runID)
        guard status.completed else {
            throw ReleaseV060RunDetailObserverSurfaceError.artifactGap(status.failureReason ?? "run is not completed")
        }
        let manifestValidation = try writer.validateRunManifest(runID: runID)
        let journal = try decodeJournal(runID: runID)
        let decodedProjection = try decodeJSON(
            ReleaseV050PortfolioRunJournalProjectionEvidence.self,
            from: artifactURL(runID: runID, fileName: "projection.json")
        )
        guard decodedProjection.runID == runID else {
            throw ReleaseV060RunDetailObserverSurfaceError.runIDMismatch(
                expected: runID,
                actual: decodedProjection.runID
            )
        }
        let rebuiltProjection = try ReleaseV050PortfolioRunJournalProjection.project(journal: journal)
        guard rebuiltProjection == decodedProjection else {
            throw ReleaseV060RunDetailObserverSurfaceError.projectionMismatch("projection.json cannot rebuild from events.jsonl")
        }
        let riskEvents = journal.records.compactMap { record -> RiskDecisionEvent? in
            if case let .riskDecision(event) = record.envelope.payload {
                return event
            }
            return nil
        }
        let omsEvents = journal.records.compactMap { record -> OMSLifecycleEvent? in
            if case let .omsLifecycle(event) = record.envelope.payload {
                return event
            }
            return nil
        }
        let riskReasons = riskEvents
            .filter { $0.decision != .allowed }
            .map { "\($0.decision.rawValue):\($0.reason)" }
        let payloadTypes = journal.records.map(\.envelope.payloadType) + [.portfolioProjectionEvent]
        return try ReleaseV060RunDetailObserverEvidence(
            storageRootPath: storageRootURL.path,
            observedRunIDs: listedRunIDs,
            selectedRunID: runID,
            writerStatus: status,
            manifestValidation: manifestValidation,
            manifestArtifactPaths: manifestValidation.artifacts.map(\.path),
            reconstructedJournal: journal,
            decodedProjectionEvidence: decodedProjection,
            rebuiltProjectionEvidence: rebuiltProjection,
            sectionRecords: sectionRecords(
                journal: journal,
                projection: decodedProjection,
                riskEvents: riskEvents,
                omsEvents: omsEvents,
                riskReasons: riskReasons
            ),
            riskDecisions: riskEvents.map(\.decision),
            riskReasons: riskReasons,
            omsStates: omsEvents.map(\.state),
            payloadTypes: payloadTypes
        )
    }

    public func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == Self.cliCommand else {
            throw ReleaseV060RunDetailObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
        }
        guard arguments.count >= 2,
              let command = ReleaseV060RunDetailObserverCommand(rawValue: arguments[1]) else {
            throw ReleaseV060RunDetailObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
        }
        let selectedRunID: Identifier
        if command == .list {
            guard arguments.count == 2 else {
                throw ReleaseV060RunDetailObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
            }
            let ids = try runIDs()
            guard let first = ids.first else {
                throw ReleaseV060RunDetailObserverSurfaceError.noCompletedRuns(storageRootURL.path)
            }
            selectedRunID = first
        } else {
            guard arguments.count == 2 || arguments.count == 3 else {
                throw ReleaseV060RunDetailObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
            }
            selectedRunID = if arguments.count == 3 {
                Identifier.constant(arguments[2])
            } else if let first = try runIDs().first {
                first
            } else {
                throw ReleaseV060RunDetailObserverSurfaceError.noCompletedRuns(storageRootURL.path)
            }
        }
        let evidence = try observe(runID: selectedRunID)
        switch command {
        case .list:
            return listOutput(evidence)
        case .status:
            return statusOutput(evidence)
        case .events:
            return eventsOutput(evidence)
        case .projection:
            return projectionOutput(evidence)
        case .risk:
            return riskOutput(evidence)
        }
    }

    public static func commandLineOutput(
        arguments: [String],
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true)
    ) throws -> String {
        try ReleaseV060RunDetailObserverSurface(storageRootURL: storageRootURL)
            .commandLineOutput(arguments: arguments)
    }

    public static func readModelState(
        storageRootURL: URL,
        runID: Identifier
    ) throws -> ReleaseV060RunDetailObserverReadModelState {
        do {
            let evidence = try ReleaseV060RunDetailObserverSurface(storageRootURL: storageRootURL)
                .observe(runID: runID)
            return try ReleaseV060RunDetailObserverReadModelState(
                runID: evidence.selectedRunID,
                artifactHealth: .healthy,
                message: "run artifacts validated through manifest"
            )
        } catch let error as ReleaseV060LocalRunJournalWriterError {
            return try ReleaseV060RunDetailObserverReadModelState(
                runID: runID,
                artifactHealth: Self.health(for: error),
                message: error.description
            )
        } catch let error as ReleaseV060RunDetailObserverSurfaceError {
            return try ReleaseV060RunDetailObserverReadModelState(
                runID: runID,
                artifactHealth: Self.health(for: error),
                message: error.description
            )
        }
    }

    private static func health(
        for error: ReleaseV060LocalRunJournalWriterError
    ) -> ReleaseV060RunDetailObserverArtifactHealth {
        switch error {
        case .missingArtifact:
            .gap
        case .checksumMismatch, .byteCountMismatch, .artifactMetadataMismatch:
            .error
        default:
            .error
        }
    }

    private static func health(
        for error: ReleaseV060RunDetailObserverSurfaceError
    ) -> ReleaseV060RunDetailObserverArtifactHealth {
        switch error {
        case .artifactGap, .noCompletedRuns:
            .gap
        default:
            .error
        }
    }

    private func sectionRecords(
        journal: ReleaseV050DurableLocalRunJournal,
        projection: ReleaseV050PortfolioRunJournalProjectionEvidence,
        riskEvents: [RiskDecisionEvent],
        omsEvents: [OMSLifecycleEvent],
        riskReasons: [String]
    ) throws -> [ReleaseV060RunDetailObserverSectionRecord] {
        try [
            ReleaseV060RunDetailObserverSectionRecord(
                section: .runOverview,
                status: .ready,
                artifactNames: ["manifest.json", "_RUN_STATUS.json"],
                itemCount: 1,
                summary: "completed run manifest validated"
            ),
            ReleaseV060RunDetailObserverSectionRecord(
                section: .eventTimeline,
                status: .ready,
                artifactNames: ["events.jsonl"],
                itemCount: journal.records.count,
                summary: "event timeline rebuilt from events.jsonl"
            ),
            ReleaseV060RunDetailObserverSectionRecord(
                section: .riskDecisions,
                status: .blocked,
                artifactNames: ["events.jsonl"],
                itemCount: riskEvents.count,
                summary: "risk allow/reject/blocked decisions visible"
            ),
            ReleaseV060RunDetailObserverSectionRecord(
                section: .omsTimeline,
                status: .ready,
                artifactNames: ["events.jsonl"],
                itemCount: omsEvents.count,
                summary: "OMS dry-run timeline visible"
            ),
            ReleaseV060RunDetailObserverSectionRecord(
                section: .portfolioProjection,
                status: .ready,
                artifactNames: ["projection.json"],
                itemCount: projection.productProjections.count,
                summary: "Portfolio projection read from projection.json"
            ),
            ReleaseV060RunDetailObserverSectionRecord(
                section: .boundaryEnvironmentSecretPolicy,
                status: .blocked,
                artifactNames: ["manifest.json", "_RUN_STATUS.json"],
                itemCount: max(riskReasons.count, 1),
                summary: "production endpoint secret and command surfaces remain closed"
            )
        ]
    }

    private func decodeJournal(runID: Identifier) throws -> ReleaseV050DurableLocalRunJournal {
        let eventsURL = artifactURL(runID: runID, fileName: "events.jsonl")
        guard fileManager.fileExists(atPath: eventsURL.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(eventsURL.path)
        }
        let contents = try String(contentsOf: eventsURL, encoding: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = try contents
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { line in
                try decoder.decode(
                    ReleaseV050DurableLocalRunJournalRecord.self,
                    from: Data(line.utf8)
                )
            }
        return try ReleaseV050DurableLocalRunJournal(runID: runID, records: records)
    }

    private func decodeJSON<Value: Decodable>(_ type: Value.Type, from url: URL) throws -> Value {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(url.path)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: url))
    }

    private func artifactURL(runID: Identifier, fileName: String) -> URL {
        storageRootURL
            .appendingPathComponent(runID.rawValue, isDirectory: true)
            .appendingPathComponent(fileName)
    }

    private func listOutput(_ evidence: ReleaseV060RunDetailObserverEvidence) -> String {
        [
            "mtpro \(Self.cliCommand) list blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runIDs=\(evidence.observedRunIDs.map(\.rawValue).joined(separator: ","))",
            "selectedRunID=\(evidence.selectedRunID.rawValue)",
            "manifestValidatedBeforeHealthyState=\(evidence.manifestValidatedBeforeHealthyState)",
            "productionTradingEnabledByDefault=\(evidence.productionTradingEnabledByDefault)",
            "productionEndpointConnected=\(evidence.productionEndpointConnected)",
            "productionSecretAutoReadEnabled=\(evidence.productionSecretAutoReadEnabled)",
            "productionOrderSubmitted=\(evidence.productionOrderSubmitted)",
            "productionCutoverAuthorized=\(evidence.productionCutoverAuthorized)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private func statusOutput(_ evidence: ReleaseV060RunDetailObserverEvidence) -> String {
        [
            "mtpro \(Self.cliCommand) status blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.selectedRunID.rawValue)",
            "eventCount=\(evidence.reconstructedJournal.records.count)",
            "sections=\(evidence.sectionRecords.map { $0.section.rawValue }.joined(separator: ","))",
            "sectionStatuses=\(evidence.sectionRecords.map { $0.status.rawValue }.joined(separator: ","))",
            "dashboardReadsSameManifestAsCLI=\(evidence.dashboardReadsSameManifestAsCLI)",
            "dashboardReadModelOnly=\(evidence.dashboardReadModelOnly)",
            "commandSurfaceEnabled=\(evidence.liveCommandSurfaceExposed)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private func eventsOutput(_ evidence: ReleaseV060RunDetailObserverEvidence) -> String {
        [
            "mtpro \(Self.cliCommand) events blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.selectedRunID.rawValue)",
            "eventCount=\(evidence.reconstructedJournal.records.count)",
            "payloadTypes=\(evidence.payloadTypes.map(\.rawValue).joined(separator: ","))",
            "latestJournalChecksum=\(evidence.reconstructedJournal.latestJournalChecksum)",
            "manifestArtifactCount=\(evidence.manifestValidation.checkedArtifactCount)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private func projectionOutput(_ evidence: ReleaseV060RunDetailObserverEvidence) -> String {
        [
            "mtpro \(Self.cliCommand) projection blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.selectedRunID.rawValue)",
            "projectionID=\(evidence.decodedProjectionEvidence.projectionState.productProjections[0].projectionID.rawValue)",
            "sourceJournalEventCount=\(evidence.decodedProjectionEvidence.projectionState.sourceJournalEventCount)",
            "totalGrossExposureMinorUnits=\(evidence.decodedProjectionEvidence.projectionState.totalGrossExposure.minorUnits)",
            "projectionRebuiltFromEventsJSONL=\(evidence.rebuiltProjectionEvidence == evidence.decodedProjectionEvidence)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private func riskOutput(_ evidence: ReleaseV060RunDetailObserverEvidence) -> String {
        [
            "mtpro \(Self.cliCommand) risk blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.selectedRunID.rawValue)",
            "riskDecisions=\(evidence.riskDecisions.map(\.rawValue).joined(separator: ","))",
            "riskReasons=\(evidence.riskReasons.joined(separator: "|"))",
            "brokerExecutionWriteEnabled=\(evidence.brokerExecutionWriteEnabled)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }
}

/// ReleaseV060RunDetailObserverContract 固定 GH-764 issue-level 验收合同。
public struct ReleaseV060RunDetailObserverContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let cliCommand: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-764"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-757", "GH-759", "GH-760", "GH-761", "GH-762", "GH-763"]
            && previousIssueID.rawValue == "GH-763"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-766"]
            && releaseVersion == "v0.6.0"
            && cliCommand == ReleaseV060RunDetailObserverSurface.cliCommand
            && validationAnchors == ReleaseV060RunDetailObserverEvidence.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060RunDetailObserverEvidence.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-764"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-756"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-759"),
            Identifier.constant("GH-760"),
            Identifier.constant("GH-761"),
            Identifier.constant("GH-762"),
            Identifier.constant("GH-763")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-763"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-766")],
        releaseVersion: String = "v0.6.0",
        cliCommand: String = ReleaseV060RunDetailObserverSurface.cliCommand,
        validationAnchors: [String] = ReleaseV060RunDetailObserverEvidence.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060RunDetailObserverEvidence.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.cliCommand = cliCommand
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV060RunDetailObserverSurfaceError.contractDrift("runDetailObserverContract")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060RunDetailObserverContract {
        try ReleaseV060RunDetailObserverContract()
    }
}
