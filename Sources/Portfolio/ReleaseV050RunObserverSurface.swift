import Database
import DomainModel
import Foundation
import MessageBus

/// ReleaseV050RunObserverSurfaceError 描述 GH-737 Dashboard / CLI observer 合同错误。
///
/// 错误只覆盖 run journal / Portfolio projection 只读观察面、CLI 参数和禁止命令边界；
/// 它不表达 broker command、真实订单或 production cutover 能力。
public enum ReleaseV050RunObserverSurfaceError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidArguments(String)
    case runIDMismatch(expected: Identifier, actual: String)
    case missingSection(ReleaseV050RunObserverSection)
    case missingProjection
    case forbiddenCommandSurface(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case let .invalidArguments(arguments):
            "Release v0.5.0 run observer invalid CLI arguments: \(arguments)"
        case let .runIDMismatch(expected, actual):
            "Release v0.5.0 run observer runID mismatch: expected \(expected.rawValue), actual \(actual)"
        case let .missingSection(section):
            "Release v0.5.0 run observer missing Dashboard / CLI section: \(section.rawValue)"
        case .missingProjection:
            "Release v0.5.0 run observer requires Portfolio projection evidence"
        case let .forbiddenCommandSurface(field):
            "Release v0.5.0 run observer rejected command surface: \(field)"
        case let .contractDrift(reason):
            "Release v0.5.0 run observer contract drift: \(reason)"
        }
    }
}

/// ReleaseV050RunObserverSection 固定 GH-737 必须展示的 observer sections。
public enum ReleaseV050RunObserverSection:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case runOverview = "Run Overview"
    case dataFreshness = "Data Freshness"
    case strategyIntents = "Strategy Intents"
    case riskDecisions = "Risk Decisions"
    case omsTimeline = "OMS Timeline"
    case executionDryRunEvidence = "Execution Dry-run Evidence"
    case portfolioProjection = "Portfolio Projection"
    case blockedRejectedReasons = "Blocked / Rejected Reasons"
    case environmentEndpointSecretBoundary = "Environment / Endpoint / Secret Boundary"
}

/// ReleaseV050RunObserverStatus 是 Dashboard / CLI 只读状态词汇。
public enum ReleaseV050RunObserverStatus: String, Codable, Equatable, Hashable, Sendable {
    case ready
    case blocked
    case rejected
}

/// ReleaseV050RunObserverCommand 固定 GH-737 允许的 CLI observer 子命令。
public enum ReleaseV050RunObserverCommand:
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

/// ReleaseV050RunObserverSectionRecord 是 Dashboard / CLI 共用的只读 section 摘要。
///
/// 每个 section 都必须同时对 Dashboard 和 CLI 可见，但不能授权 command、order form、
/// trading button 或 broker write。
public struct ReleaseV050RunObserverSectionRecord: Codable, Equatable, Sendable {
    public let section: ReleaseV050RunObserverSection
    public let status: ReleaseV050RunObserverStatus
    public let sourcePayloadTypes: [RuntimeEventPayloadType]
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
        section: ReleaseV050RunObserverSection,
        status: ReleaseV050RunObserverStatus,
        sourcePayloadTypes: [RuntimeEventPayloadType],
        itemCount: Int,
        summary: String,
        visibleOnDashboard: Bool = true,
        visibleOnCLI: Bool = true,
        readModelOnly: Bool = true,
        authorizesCommand: Bool = false,
        exposesOrderForm: Bool = false,
        exposesTradingButton: Bool = false
    ) throws {
        guard itemCount >= 0, summary.isEmpty == false else {
            throw ReleaseV050RunObserverSurfaceError.contractDrift(section.rawValue)
        }
        try Self.forbid(authorizesCommand, "authorizesCommand")
        try Self.forbid(exposesOrderForm, "exposesOrderForm")
        try Self.forbid(exposesTradingButton, "exposesTradingButton")

        self.section = section
        self.status = status
        self.sourcePayloadTypes = sourcePayloadTypes
        self.itemCount = itemCount
        self.summary = summary
        self.visibleOnDashboard = visibleOnDashboard
        self.visibleOnCLI = visibleOnCLI
        self.readModelOnly = readModelOnly
        self.authorizesCommand = authorizesCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesTradingButton = exposesTradingButton

        guard recordHeld else {
            throw ReleaseV050RunObserverSurfaceError.contractDrift("sectionRecordHeld")
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV050RunObserverSurfaceError.forbiddenCommandSurface(field)
        }
    }
}

/// ReleaseV050RunObserverSurfaceEvidence 汇总 GH-737 Dashboard / CLI run observer evidence。
public struct ReleaseV050RunObserverSurfaceEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let runID: Identifier
    public let sourceProjectionEvidenceID: Identifier
    public let sourceJournalLatestChecksum: String
    public let sourceJournalEventCount: Int
    public let sourcePayloadTypes: [RuntimeEventPayloadType]
    public let dashboardSections: [ReleaseV050RunObserverSectionRecord]
    public let cliCommands: [ReleaseV050RunObserverCommand]
    public let riskDecisions: [RuntimeRiskDecision]
    public let riskReasons: [String]
    public let omsStates: [RuntimeOMSState]
    public let executionDryRunCommands: [RuntimeDryRunCommandKind]
    public let portfolioProjectionState: ReleaseV050PortfolioRunJournalProjectionState
    public let dashboardReadModelEvent: DashboardReadModelEvent
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let dashboardReadsByRunID: Bool
    public let cliReadsByRunID: Bool
    public let consumesRunJournal: Bool
    public let consumesPortfolioProjection: Bool
    public let displaysBlockedRejectedReasons: Bool
    public let displaysBoundaryEvidence: Bool
    public let defaultDemoSnapshotUsedForV050Path: Bool
    public let brokerExecutionWriteEnabled: Bool
    public let tradingButtonExposed: Bool
    public let orderFormExposed: Bool
    public let liveCommandSurfaceExposed: Bool
    public let productionCommandSurfaceExposed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-737"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-735", "GH-736"]
            && previousIssueID.rawValue == "GH-736"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-738", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"
            && sourceProjectionEvidenceID.rawValue == "gh-736-v050-portfolio-run-journal-projection-evidence"
            && sourceJournalLatestChecksum.hasPrefix("fnv1a64:")
            && sourceJournalEventCount > 0
            && Set(sourcePayloadTypes).isSuperset(of: Set(Self.requiredSourcePayloadTypes))
            && dashboardSections.map(\.section) == ReleaseV050RunObserverSection.allCases
            && dashboardSections.allSatisfy(\.recordHeld)
            && cliCommands == ReleaseV050RunObserverCommand.allCases
            && riskDecisions.contains(.rejected)
            && riskDecisions.contains(.blocked)
            && riskReasons.isEmpty == false
            && omsStates.contains(.simulatedFilled)
            && executionDryRunCommands.contains(.submit)
            && portfolioProjectionState.stateHeld
            && portfolioProjectionState.runID == runID
            && dashboardReadModelEvent.sourceProjectionID == portfolioProjectionState.productProjections[0].projectionID
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && observerBoundaryHeld
            && forbiddenBoundaryHeld
    }

    public var observerBoundaryHeld: Bool {
        dashboardReadsByRunID
            && cliReadsByRunID
            && consumesRunJournal
            && consumesPortfolioProjection
            && displaysBlockedRejectedReasons
            && displaysBoundaryEvidence
            && defaultDemoSnapshotUsedForV050Path == false
    }

    public var forbiddenBoundaryHeld: Bool {
        brokerExecutionWriteEnabled == false
            && tradingButtonExposed == false
            && orderFormExposed == false
            && liveCommandSurfaceExposed == false
            && productionCommandSurfaceExposed == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-737-v050-run-observer-surface-evidence"),
        issueID: Identifier = Identifier.constant("GH-737"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-731"),
            Identifier.constant("GH-735"),
            Identifier.constant("GH-736")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-736"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-738"), Identifier.constant("GH-739")],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge",
        runID: Identifier,
        sourceProjectionEvidenceID: Identifier,
        sourceJournalLatestChecksum: String,
        sourceJournalEventCount: Int,
        sourcePayloadTypes: [RuntimeEventPayloadType],
        dashboardSections: [ReleaseV050RunObserverSectionRecord],
        cliCommands: [ReleaseV050RunObserverCommand] = ReleaseV050RunObserverCommand.allCases,
        riskDecisions: [RuntimeRiskDecision],
        riskReasons: [String],
        omsStates: [RuntimeOMSState],
        executionDryRunCommands: [RuntimeDryRunCommandKind],
        portfolioProjectionState: ReleaseV050PortfolioRunJournalProjectionState,
        dashboardReadModelEvent: DashboardReadModelEvent,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        dashboardReadsByRunID: Bool = true,
        cliReadsByRunID: Bool = true,
        consumesRunJournal: Bool = true,
        consumesPortfolioProjection: Bool = true,
        displaysBlockedRejectedReasons: Bool = true,
        displaysBoundaryEvidence: Bool = true,
        defaultDemoSnapshotUsedForV050Path: Bool = false,
        brokerExecutionWriteEnabled: Bool = false,
        tradingButtonExposed: Bool = false,
        orderFormExposed: Bool = false,
        liveCommandSurfaceExposed: Bool = false,
        productionCommandSurfaceExposed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.forbid(brokerExecutionWriteEnabled, "brokerExecutionWriteEnabled")
        try Self.forbid(tradingButtonExposed, "tradingButtonExposed")
        try Self.forbid(orderFormExposed, "orderFormExposed")
        try Self.forbid(liveCommandSurfaceExposed, "liveCommandSurfaceExposed")
        try Self.forbid(productionCommandSurfaceExposed, "productionCommandSurfaceExposed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSecretAutoReadEnabled, "productionSecretAutoReadEnabled")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.runID = runID
        self.sourceProjectionEvidenceID = sourceProjectionEvidenceID
        self.sourceJournalLatestChecksum = sourceJournalLatestChecksum
        self.sourceJournalEventCount = sourceJournalEventCount
        self.sourcePayloadTypes = sourcePayloadTypes
        self.dashboardSections = dashboardSections
        self.cliCommands = cliCommands
        self.riskDecisions = riskDecisions
        self.riskReasons = riskReasons
        self.omsStates = omsStates
        self.executionDryRunCommands = executionDryRunCommands
        self.portfolioProjectionState = portfolioProjectionState
        self.dashboardReadModelEvent = dashboardReadModelEvent
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.dashboardReadsByRunID = dashboardReadsByRunID
        self.cliReadsByRunID = cliReadsByRunID
        self.consumesRunJournal = consumesRunJournal
        self.consumesPortfolioProjection = consumesPortfolioProjection
        self.displaysBlockedRejectedReasons = displaysBlockedRejectedReasons
        self.displaysBoundaryEvidence = displaysBoundaryEvidence
        self.defaultDemoSnapshotUsedForV050Path = defaultDemoSnapshotUsedForV050Path
        self.brokerExecutionWriteEnabled = brokerExecutionWriteEnabled
        self.tradingButtonExposed = tradingButtonExposed
        self.orderFormExposed = orderFormExposed
        self.liveCommandSurfaceExposed = liveCommandSurfaceExposed
        self.productionCommandSurfaceExposed = productionCommandSurfaceExposed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV050RunObserverSurfaceError.contractDrift(evidenceDriftReason)
        }
    }

    private var evidenceDriftReason: String {
        [
            "issue=\(issueID.rawValue == "GH-737")",
            "upstream=\(upstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-735", "GH-736"])",
            "sourceTypes=\(Set(sourcePayloadTypes).isSuperset(of: Set(Self.requiredSourcePayloadTypes)))",
            "sections=\(dashboardSections.map(\.section) == ReleaseV050RunObserverSection.allCases)",
            "sectionHeld=\(dashboardSections.allSatisfy(\.recordHeld))",
            "commands=\(cliCommands == ReleaseV050RunObserverCommand.allCases)",
            "risk=\(riskDecisions.contains(.rejected) && riskDecisions.contains(.blocked))",
            "oms=\(omsStates.contains(.simulatedFilled))",
            "execution=\(executionDryRunCommands.contains(.submit))",
            "projection=\(portfolioProjectionState.stateHeld && portfolioProjectionState.runID == runID)",
            "readModel=\(dashboardReadModelEvent.sourceProjectionID == portfolioProjectionState.productProjections[0].projectionID)",
            "anchors=\(validationAnchors == Self.requiredValidationAnchors)",
            "observer=\(observerBoundaryHeld)",
            "forbidden=\(forbiddenBoundaryHeld)",
            "brokerWrite=\(brokerExecutionWriteEnabled)",
            "button=\(tradingButtonExposed)",
            "orderForm=\(orderFormExposed)",
            "liveCommand=\(liveCommandSurfaceExposed)",
            "productionCommand=\(productionCommandSurfaceExposed)",
            "productionTrading=\(productionTradingEnabledByDefault)",
            "productionEndpoint=\(productionEndpointConnected)",
            "productionSecret=\(productionSecretAutoReadEnabled)",
            "productionOrder=\(productionOrderSubmitted)",
            "productionCutover=\(productionCutoverAuthorized)"
        ].joined(separator: ",")
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV050RunObserverSurfaceError.forbiddenCommandSurface(field)
        }
    }

    public static let requiredSourcePayloadTypes: [RuntimeEventPayloadType] = [
        .dataEngineMarketEvent,
        .strategyIntentEvent,
        .riskDecisionEvent,
        .omsLifecycleEvent,
        .executionClientDryRunEvent
    ]

    public static let requiredValidationAnchors = [
        "V050-12-DASHBOARD-CLI-RUN-OBSERVER",
        "V050-12-RUNID-STATUS-EVENTS-PROJECTION-RISK",
        "V050-12-DASHBOARD-SECTIONS-CONSUME-RUN-JOURNAL",
        "V050-12-BLOCKED-REJECTED-BOUNDARY-EVIDENCE",
        "V050-12-NO-PRODUCTION-COMMAND-SURFACE",
        "TVM-RELEASE-V050-DASHBOARD-CLI-RUN-OBSERVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH737DashboardCLIRunObserverReadsJournalProjectionAndBoundaryByRunID",
        "bash checks/verify-v0.5.0-observer.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV050RunObserverSurface 生成 GH-737 Dashboard / CLI 只读 observer surface。
public enum ReleaseV050RunObserverSurface {
    public static let cliCommand = "run-observer"

    public static func deterministicEvidence() async throws -> ReleaseV050RunObserverSurfaceEvidence {
        let projection = try await deterministicProjectionEvidence()
        return try evidence(from: projection)
    }

    public static func commandLineOutput(arguments: [String]) async throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV050RunObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
        }
        guard arguments.count >= 2,
              let command = ReleaseV050RunObserverCommand(rawValue: arguments[1]) else {
            throw ReleaseV050RunObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
        }

        let evidence = try await deterministicEvidence()
        if arguments.count == 3, arguments[2] != evidence.runID.rawValue {
            throw ReleaseV050RunObserverSurfaceError.runIDMismatch(expected: evidence.runID, actual: arguments[2])
        }
        guard arguments.count == 2 || arguments.count == 3 else {
            throw ReleaseV050RunObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
        }

        switch command {
        case .list:
            guard arguments.count == 2 else {
                throw ReleaseV050RunObserverSurfaceError.invalidArguments(arguments.joined(separator: " "))
            }
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

    public static func commandSurfaceRejected() async throws -> Bool {
        let evidence = try await deterministicEvidence()
        do {
            _ = try ReleaseV050RunObserverSurfaceEvidence(
                runID: evidence.runID,
                sourceProjectionEvidenceID: evidence.sourceProjectionEvidenceID,
                sourceJournalLatestChecksum: evidence.sourceJournalLatestChecksum,
                sourceJournalEventCount: evidence.sourceJournalEventCount,
                sourcePayloadTypes: evidence.sourcePayloadTypes,
                dashboardSections: evidence.dashboardSections,
                riskDecisions: evidence.riskDecisions,
                riskReasons: evidence.riskReasons,
                omsStates: evidence.omsStates,
                executionDryRunCommands: evidence.executionDryRunCommands,
                portfolioProjectionState: evidence.portfolioProjectionState,
                dashboardReadModelEvent: evidence.dashboardReadModelEvent,
                liveCommandSurfaceExposed: true
            )
            return false
        } catch ReleaseV050RunObserverSurfaceError.forbiddenCommandSurface("liveCommandSurfaceExposed") {
            return true
        }
    }

    private static func evidence(
        from projection: ReleaseV050PortfolioRunJournalProjectionEvidence
    ) throws -> ReleaseV050RunObserverSurfaceEvidence {
        guard let firstProjection = projection.productProjections.first else {
            throw ReleaseV050RunObserverSurfaceError.missingProjection
        }

        let riskEvents = projection.replayedEnvelopes.compactMap { envelope -> RiskDecisionEvent? in
            if case let .riskDecision(event) = envelope.payload {
                return event
            }
            return nil
        }
        let omsEvents = projection.replayedEnvelopes.compactMap { envelope -> OMSLifecycleEvent? in
            if case let .omsLifecycle(event) = envelope.payload {
                return event
            }
            return nil
        }
        let executionEvents = projection.replayedEnvelopes.compactMap { envelope -> ExecutionClientDryRunEvent? in
            if case let .executionClientDryRun(event) = envelope.payload {
                return event
            }
            return nil
        }
        let blockedRejectedReasons = riskEvents
            .filter { $0.decision != .allowed }
            .map { "\($0.decision.rawValue):\($0.reason)" }
        let sections = try sectionRecords(
            projection: projection,
            riskEvents: riskEvents,
            omsEvents: omsEvents,
            executionEvents: executionEvents,
            blockedRejectedReasons: blockedRejectedReasons
        )
        let readModelEvent = try DashboardReadModelEvent(
            readModelID: Identifier.constant("gh-737-v050-dashboard-run-observer-read-model"),
            sourceProjectionID: firstProjection.projectionID,
            statusSummary: "blocked observer surface by runID"
        )
        return try ReleaseV050RunObserverSurfaceEvidence(
            runID: projection.runID,
            sourceProjectionEvidenceID: projection.evidenceID,
            sourceJournalLatestChecksum: projection.sourceJournalLatestChecksum,
            sourceJournalEventCount: projection.replayedEnvelopes.count,
            sourcePayloadTypes: projection.sourcePayloadTypes,
            dashboardSections: sections,
            riskDecisions: riskEvents.map(\.decision),
            riskReasons: blockedRejectedReasons,
            omsStates: omsEvents.map(\.state),
            executionDryRunCommands: executionEvents.map(\.commandKind),
            portfolioProjectionState: projection.projectionState,
            dashboardReadModelEvent: readModelEvent
        )
    }

    private static func sectionRecords(
        projection: ReleaseV050PortfolioRunJournalProjectionEvidence,
        riskEvents: [RiskDecisionEvent],
        omsEvents: [OMSLifecycleEvent],
        executionEvents: [ExecutionClientDryRunEvent],
        blockedRejectedReasons: [String]
    ) throws -> [ReleaseV050RunObserverSectionRecord] {
        let counts = Dictionary(grouping: projection.sourcePayloadTypes) { $0 }
            .mapValues(\.count)
        let specs: [(ReleaseV050RunObserverSection, ReleaseV050RunObserverStatus, [RuntimeEventPayloadType], Int, String)] = [
            (.runOverview, .ready, projection.sourcePayloadTypes, 1, "run journal observer ready"),
            (.dataFreshness, .ready, [.dataEngineMarketEvent], counts[.dataEngineMarketEvent] ?? 0, "market event freshness visible"),
            (.strategyIntents, .ready, [.strategyIntentEvent], counts[.strategyIntentEvent] ?? 0, "strategy intents visible"),
            (.riskDecisions, .rejected, [.riskDecisionEvent], riskEvents.count, "risk decisions include rejected and blocked reasons"),
            (.omsTimeline, .ready, [.omsLifecycleEvent], omsEvents.count, "OMS dry-run timeline visible"),
            (.executionDryRunEvidence, .ready, [.executionClientDryRunEvent], executionEvents.count, "Execution dry-run evidence visible"),
            (.portfolioProjection, .ready, [.portfolioProjectionEvent], projection.productProjections.count, "Portfolio projection visible by runID"),
            (.blockedRejectedReasons, .blocked, [.riskDecisionEvent, .omsLifecycleEvent], blockedRejectedReasons.count, "blocked and rejected reasons visible"),
            (.environmentEndpointSecretBoundary, .blocked, projection.sourcePayloadTypes, 5, "production endpoint secret and command boundaries closed")
        ]
        return try specs.map {
            try ReleaseV050RunObserverSectionRecord(
                section: $0.0,
                status: $0.1,
                sourcePayloadTypes: $0.2,
                itemCount: $0.3,
                summary: $0.4
            )
        }
    }

    private static func deterministicProjectionEvidence() async throws -> ReleaseV050PortfolioRunJournalProjectionEvidence {
        let runID = Identifier.constant("gh-737-v050-run-observer-run")
        let streamID = try MessageBusJournalStreamID("release-v050-run-observer")
        let correlationID = Identifier.constant("gh-737-v050-run-observer-correlation")
        let catalogEntry = try ReleaseV050InstrumentCatalog.requiredEntries()[0]
        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>()
        let baseDate = Date(timeIntervalSince1970: 1_784_096_400)
        var causationID: Identifier?

        func publish(
            payload: ReleaseV050RuntimeEventPayload,
            offset: TimeInterval
        ) async throws {
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: baseDate.addingTimeInterval(offset)
            )
            causationID = envelope.eventID
        }

        try await publish(
            payload: .dataEngineMarket(
                DataEngineMarketEvent(
                    instrument: catalogEntry.instrument,
                    price: try ReleaseV050PortfolioRunJournalProjection.referencePrice(from: catalogEntry),
                    quantity: catalogEntry.minQuantity,
                    qualityTag: "observerFresh"
                )
            ),
            offset: 0
        )
        let allowedIntentID = Identifier.constant("gh-737-v050-run-observer-allowed-intent")
        try await publish(
            payload: .strategyIntent(
                StrategyIntentEvent(
                    strategyID: allowedIntentID,
                    instrument: catalogEntry.instrument,
                    intentSide: "buy",
                    targetQuantity: catalogEntry.minQuantity
                )
            ),
            offset: 1
        )
        let allowedDecisionID = Identifier.constant("gh-737-v050-run-observer-risk-allowed")
        try await publish(
            payload: .riskDecision(
                RiskDecisionEvent(
                    decisionID: allowedDecisionID,
                    sourceIntentID: allowedIntentID,
                    decision: .allowed,
                    reason: "dryRunAllowed"
                )
            ),
            offset: 2
        )
        let rejectedIntentID = Identifier.constant("gh-737-v050-run-observer-rejected-intent")
        try await publish(
            payload: .strategyIntent(
                StrategyIntentEvent(
                    strategyID: rejectedIntentID,
                    instrument: catalogEntry.instrument,
                    intentSide: "buy",
                    targetQuantity: catalogEntry.minQuantity
                )
            ),
            offset: 3
        )
        try await publish(
            payload: .riskDecision(
                RiskDecisionEvent(
                    decisionID: Identifier.constant("gh-737-v050-run-observer-risk-rejected"),
                    sourceIntentID: rejectedIntentID,
                    decision: .rejected,
                    reason: "notionalLimitExceeded"
                )
            ),
            offset: 4
        )
        let blockedIntentID = Identifier.constant("gh-737-v050-run-observer-blocked-intent")
        try await publish(
            payload: .strategyIntent(
                StrategyIntentEvent(
                    strategyID: blockedIntentID,
                    instrument: catalogEntry.instrument,
                    intentSide: "buy",
                    targetQuantity: catalogEntry.minQuantity
                )
            ),
            offset: 5
        )
        try await publish(
            payload: .riskDecision(
                RiskDecisionEvent(
                    decisionID: Identifier.constant("gh-737-v050-run-observer-risk-blocked"),
                    sourceIntentID: blockedIntentID,
                    decision: .blocked,
                    reason: "killSwitchActive"
                )
            ),
            offset: 6
        )

        let orderID = Identifier.constant("gh-737-v050-run-observer-order")
        for (index, state) in [
            RuntimeOMSState.created,
            .riskApproved,
            .acceptedByOMS,
            .simulatedSubmitted,
            .simulatedPartiallyFilled,
            .simulatedFilled
        ].enumerated() {
            try await publish(
                payload: .omsLifecycle(
                    OMSLifecycleEvent(
                        orderID: orderID,
                        sourceRiskDecisionID: allowedDecisionID,
                        state: state
                    )
                ),
                offset: TimeInterval(7 + index)
            )
            if state == .simulatedSubmitted {
                try await publish(
                    payload: .executionClientDryRun(
                        ExecutionClientDryRunEvent(
                            requestID: Identifier.constant("gh-737-v050-run-observer-submit"),
                            sourceOMSOrderID: orderID,
                            commandKind: .submit,
                            acceptedByDryRunAdapter: true
                        )
                    ),
                    offset: 7.5
                )
            }
        }

        var journal = try ReleaseV050DurableLocalRunJournal(runID: runID)
        for envelope in await bus.snapshot() {
            try journal.append(envelope: envelope)
        }
        return try ReleaseV050PortfolioRunJournalProjection.project(journal: journal)
    }

    private static func listOutput(_ evidence: ReleaseV050RunObserverSurfaceEvidence) -> String {
        [
            "mtpro \(cliCommand) list blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runIDs=\(evidence.runID.rawValue)",
            "validationAnchor=\(evidence.validationAnchors.last ?? "")",
            "productionTradingEnabledByDefault=\(evidence.productionTradingEnabledByDefault)",
            "productionEndpointConnected=\(evidence.productionEndpointConnected)",
            "productionSecretAutoReadEnabled=\(evidence.productionSecretAutoReadEnabled)",
            "productionOrderSubmitted=\(evidence.productionOrderSubmitted)",
            "productionCutoverAuthorized=\(evidence.productionCutoverAuthorized)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private static func statusOutput(_ evidence: ReleaseV050RunObserverSurfaceEvidence) -> String {
        let sections = evidence.dashboardSections.map(\.section.rawValue).joined(separator: ",")
        let statuses = evidence.dashboardSections.map(\.status.rawValue).joined(separator: ",")
        return [
            "mtpro \(cliCommand) status blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.runID.rawValue)",
            "sections=\(sections)",
            "sectionStatuses=\(statuses)",
            "dashboardReadsByRunID=\(evidence.dashboardReadsByRunID)",
            "cliReadsByRunID=\(evidence.cliReadsByRunID)",
            "defaultDemoSnapshotUsedForV050Path=\(evidence.defaultDemoSnapshotUsedForV050Path)",
            "displaysBoundaryEvidence=\(evidence.displaysBoundaryEvidence)",
            "commandSurfaceEnabled=\(evidence.liveCommandSurfaceExposed)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private static func eventsOutput(_ evidence: ReleaseV050RunObserverSurfaceEvidence) -> String {
        [
            "mtpro \(cliCommand) events blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.runID.rawValue)",
            "eventCount=\(evidence.sourceJournalEventCount)",
            "payloadTypes=\(evidence.sourcePayloadTypes.map(\.rawValue).joined(separator: ","))",
            "journalChecksum=\(evidence.sourceJournalLatestChecksum)",
            "consumesRunJournal=\(evidence.consumesRunJournal)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private static func projectionOutput(_ evidence: ReleaseV050RunObserverSurfaceEvidence) -> String {
        [
            "mtpro \(cliCommand) projection blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.runID.rawValue)",
            "projectionID=\(evidence.portfolioProjectionState.productProjections[0].projectionID.rawValue)",
            "productTypes=\(evidence.portfolioProjectionState.productProjections.map { $0.productType.rawValue }.joined(separator: ","))",
            "totalGrossExposureMinorUnits=\(evidence.portfolioProjectionState.totalGrossExposure.minorUnits)",
            "consumesPortfolioProjection=\(evidence.consumesPortfolioProjection)",
            "brokerTruth=\(evidence.portfolioProjectionState.brokerTruth)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }

    private static func riskOutput(_ evidence: ReleaseV050RunObserverSurfaceEvidence) -> String {
        [
            "mtpro \(cliCommand) risk blocked",
            "issue=\(evidence.issueID.rawValue)",
            "runID=\(evidence.runID.rawValue)",
            "riskDecisions=\(evidence.riskDecisions.map(\.rawValue).joined(separator: ","))",
            "blockedRejectedReasons=\(evidence.riskReasons.joined(separator: "|"))",
            "displaysBlockedRejectedReasons=\(evidence.displaysBlockedRejectedReasons)",
            "brokerExecutionWriteEnabled=\(evidence.brokerExecutionWriteEnabled)",
            "boundaryHeld=\(evidence.evidenceHeld)"
        ].joined(separator: "\n")
    }
}
