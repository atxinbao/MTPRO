import Foundation
import Core
import Persistence

/// PaperWorkflowEvidenceExplorerSection 定义 Event Timeline / Evidence Explorer 的只读分区。
///
/// 分区只用于 App 层 read model / ViewModel 观察，不是查询语言、命令路由或 UI 控件配置。
/// 每个分区都只能从稳定 read model 或 append-only event envelope 派生；Live 分区只能展示
/// blocked / monitoring evidence。禁止读取 SQLite / DuckDB schema、Runtime object、adapter request，
/// 也禁止恢复任何真实交易能力、live audit、incident replay 或 stop control。
public enum PaperWorkflowEvidenceExplorerSection: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case marketEvent = "market event"
    case marketDataReplayOperation = "market data replay operation"
    case scenarioReplayEvidence = "scenario replay evidence"
    case liveExecutionControlBlockedEvidence = "live execution control blocked evidence"
    case liveRiskGateBlockedEvidence = "live risk gate blocked evidence"
    case liveIncidentStopBlockedEvidence = "live incident / stop blocked evidence"
    case liveTradingBlockedEvidence = "live trading blocked evidence"
    case liveMonitoringEvidence = "live monitoring evidence"
    case strategySignal = "strategy signal"
    case riskDecision = "risk decision"
    case paperOrder = "paper order"
    case simulatedFill = "simulated fill"
    case portfolioProjection = "portfolio projection"
    case reportArtifact = "report artifact"
}

/// PaperWorkflowEvidenceLinkSummary 是 Evidence Explorer 暴露的最小 evidence link。
///
/// link 只保存可审计 evidence ID、所属分区和可选 source sequence，供 timeline item、report
/// artifact 和 paper workflow chain 做确定性关联；它不包含数据库表名、SQL、runtime object、
/// broker order ID 或任何可执行命令。
public struct PaperWorkflowEvidenceLinkSummary: Codable, Equatable, Hashable, Sendable {
    public let section: PaperWorkflowEvidenceExplorerSection
    public let evidenceID: String
    public let label: String
    public let sourceSequence: Int?

    public init(
        section: PaperWorkflowEvidenceExplorerSection,
        evidenceID: String,
        label: String,
        sourceSequence: Int? = nil
    ) {
        self.section = section
        self.evidenceID = evidenceID
        self.label = label
        self.sourceSequence = sourceSequence
    }
}

/// PaperWorkflowEventTimelineItem 是 Event Timeline 的稳定只读行。
///
/// 输入只能来自 projection read model 或 append-only `EventEnvelope`。`sequence` 表示本地事实流
/// 的顺序，不代表 broker / exchange 回报；`evidenceLinks` 只做 read-only navigation summary，
/// 不提供 risk control、position management、order submit / cancel / replace 等动作。
public struct PaperWorkflowEventTimelineItem: Codable, Equatable, Sendable {
    public let section: PaperWorkflowEvidenceExplorerSection
    public let sequence: Int?
    public let occurredAt: Date?
    public let stream: String?
    public let title: String
    public let summary: String
    public let evidenceLinks: [PaperWorkflowEvidenceLinkSummary]

    public init(
        section: PaperWorkflowEvidenceExplorerSection,
        sequence: Int? = nil,
        occurredAt: Date? = nil,
        stream: String? = nil,
        title: String,
        summary: String,
        evidenceLinks: [PaperWorkflowEvidenceLinkSummary] = []
    ) {
        self.section = section
        self.sequence = sequence
        self.occurredAt = occurredAt
        self.stream = stream
        self.title = title
        self.summary = summary
        self.evidenceLinks = evidenceLinks.sortedByEvidenceLink()
    }
}

/// PaperWorkflowEvidenceExplorerSectionSnapshot 汇总每个只读分区的 timeline 覆盖情况。
///
/// snapshot 只表达当前 read model 中已有 evidence 数量和最新 sequence，不触发 replay、不访问
/// persistence adapter，也不把 filter 状态解释成查询语言。
public struct PaperWorkflowEvidenceExplorerSectionSnapshot: Codable, Equatable, Sendable {
    public let section: PaperWorkflowEvidenceExplorerSection
    public let itemCount: Int
    public let evidenceLinkCount: Int
    public let latestSequence: Int?
    public let selected: Bool

    public init(
        section: PaperWorkflowEvidenceExplorerSection,
        itemCount: Int,
        evidenceLinkCount: Int,
        latestSequence: Int?,
        selected: Bool
    ) {
        self.section = section
        self.itemCount = itemCount
        self.evidenceLinkCount = evidenceLinkCount
        self.latestSequence = latestSequence
        self.selected = selected
    }
}

/// PaperWorkflowEvidenceExplorerFilterSnapshot 表达 Explorer 的只读 filter 状态。
///
/// filter 只在已生成的 App 层 snapshot 内筛选分区，不下推到 SQLite / DuckDB，不调用 Runtime，
/// 不构造查询语言，也不产生任何 command surface。
public struct PaperWorkflowEvidenceExplorerFilterSnapshot: Codable, Equatable, Sendable {
    public let availableSections: [PaperWorkflowEvidenceExplorerSection]
    public let selectedSections: [PaperWorkflowEvidenceExplorerSection]
    public let matchingItemCount: Int
    public let readOnly: Bool
    public let supportsQueryLanguage: Bool
    public let supportsCommandSurface: Bool

    public init(
        availableSections: [PaperWorkflowEvidenceExplorerSection],
        selectedSections: [PaperWorkflowEvidenceExplorerSection],
        matchingItemCount: Int
    ) {
        self.availableSections = availableSections
        self.selectedSections = selectedSections
        self.matchingItemCount = matchingItemCount
        self.readOnly = true
        self.supportsQueryLanguage = false
        self.supportsCommandSurface = false
    }
}

/// PaperWorkflowEvidenceExplorerReadModel 汇总 Event Timeline / Evidence Explorer 的稳定输入。
///
/// 该 read model 只组合 Dashboard 已有 App read models：market、strategy、report、
/// scenario replay evidence、
/// Live blocked evidence、Live monitoring evidence、execution-control blocked evidence、
/// Live Risk gate blocked evidence、incident / stop blocked evidence、
/// paper workflow observability 和 append-only event timeline。
/// 它不新增 projection schema，不直接读取 Persistence adapter，不暴露 Runtime object，
/// 也不提供交易、风控、live command、live audit、incident replay 或 stop control。
public struct PaperWorkflowEvidenceExplorerReadModel: Equatable, Sendable {
    public let market: MarketReadModel
    public let strategy: StrategyReadModel
    public let report: ReportReadModel
    public let scenarioReplayEvidence: ScenarioReplayEvidenceReadModel
    public let liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel
    public let liveMonitoringEvidence: LiveMonitoringEvidenceReadModel
    public let liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel
    public let liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel
    public let liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel
    public let paperWorkflowObservability: PaperWorkflowObservabilityReadModel
    public let events: EventTimelineReadModel
    public let lastAppliedSequence: Int?

    public init(
        market: MarketReadModel = MarketReadModel(),
        strategy: StrategyReadModel = StrategyReadModel(),
        report: ReportReadModel = ReportReadModel(),
        scenarioReplayEvidence: ScenarioReplayEvidenceReadModel? = nil,
        liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel? = nil,
        liveMonitoringEvidence: LiveMonitoringEvidenceReadModel? = nil,
        liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel? = nil,
        liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel? = nil,
        liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel? = nil,
        paperWorkflowObservability: PaperWorkflowObservabilityReadModel = PaperWorkflowObservabilityReadModel(),
        events: EventTimelineReadModel = EventTimelineReadModel()
    ) {
        self.market = market
        self.strategy = strategy
        self.report = report
        self.scenarioReplayEvidence = scenarioReplayEvidence
            ?? report.scenarioReplayEvidence
        self.liveTradingBlockedEvidence = liveTradingBlockedEvidence
            ?? report.liveTradingBlockedEvidence
        self.liveMonitoringEvidence = liveMonitoringEvidence
            ?? report.liveMonitoringEvidence
        self.liveExecutionControlBlockedEvidence = liveExecutionControlBlockedEvidence
            ?? report.liveExecutionControlBlockedEvidence
        self.liveRiskGateBlockedEvidence = liveRiskGateBlockedEvidence
            ?? report.liveRiskGateBlockedEvidence
        self.liveIncidentStopBlockedEvidence = liveIncidentStopBlockedEvidence
            ?? report.liveIncidentStopBlockedEvidence
        self.paperWorkflowObservability = paperWorkflowObservability
        self.events = events
        self.lastAppliedSequence = Self.maxSequence(
            market.lastAppliedSequence,
            strategy.lastAppliedSequence,
            report.lastAppliedSequence,
            self.scenarioReplayEvidence.lastAppliedSequence,
            self.liveTradingBlockedEvidence.lastAppliedSequence,
            self.liveMonitoringEvidence.lastAppliedSequence,
            self.liveExecutionControlBlockedEvidence.lastAppliedSequence,
            self.liveRiskGateBlockedEvidence.lastAppliedSequence,
            self.liveIncidentStopBlockedEvidence.lastAppliedSequence,
            paperWorkflowObservability.lastAppliedSequence,
            events.envelopes.map(\.sequence).max()
        )
    }

    private static func maxSequence(_ values: Int?...) -> Int? {
        values.compactMap { $0 }.max()
    }
}

/// PaperWorkflowEvidenceExplorerViewModel 是 Dashboard / Workbench 可消费的只读 Explorer 快照。
///
/// ViewModel 从 read model 派生 timeline rows、evidence links 和 section filter snapshot。
/// 所有 boundary flags 必须保持 read-model-only / paper-only / Live blocked 与 monitoring evidence only；
/// 该类型不实现 UI controls、Runtime command、order-level command、report archive/export 或任何 Live / broker 能力。
public struct PaperWorkflowEvidenceExplorerViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let timelineItems: [PaperWorkflowEventTimelineItem]
    public let evidenceLinks: [PaperWorkflowEvidenceLinkSummary]
    public let sectionSnapshots: [PaperWorkflowEvidenceExplorerSectionSnapshot]
    public let filterSnapshot: PaperWorkflowEvidenceExplorerFilterSnapshot
    public let timelineItemCount: Int
    public let evidenceLinkCount: Int
    public let coversMarketEvents: Bool
    public let coversMarketDataReplayOperations: Bool
    public let coversScenarioReplayEvidence: Bool
    public let coversLiveExecutionControlBlockedEvidence: Bool
    public let coversLiveRiskGateBlockedEvidence: Bool
    public let coversLiveIncidentStopBlockedEvidence: Bool
    public let coversLiveTradingBlockedEvidence: Bool
    public let coversLiveMonitoringEvidence: Bool
    public let coversStrategySignals: Bool
    public let coversRiskDecisions: Bool
    public let coversPaperOrders: Bool
    public let coversSimulatedFills: Bool
    public let coversPortfolioProjections: Bool
    public let coversReportArtifacts: Bool
    public let coversPaperWorkflowChainEvidence: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let supportsQueryLanguage: Bool
    public let providesLiveAudit: Bool
    public let providesIncidentReplay: Bool
    public let providesStopControl: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(
        readModel: PaperWorkflowEvidenceExplorerReadModel,
        selectedSections requestedSections: [PaperWorkflowEvidenceExplorerSection]? = nil
    ) {
        let source = ViewModelSourceContract()
        let selectedSections = Self.normalizeSelectedSections(requestedSections)
        let selectedSectionSet = Set(selectedSections)
        let allTimelineItems = Self.makeTimelineItems(from: readModel)
        let scenarioReplay = ScenarioReplayEvidenceViewModel(
            readModel: readModel.scenarioReplayEvidence
        )
        let liveExecutionControl = LiveExecutionControlBlockedEvidenceViewModel(
            readModel: readModel.liveExecutionControlBlockedEvidence
        )
        let liveRiskGate = LiveRiskGateBlockedEvidenceViewModel(
            readModel: readModel.liveRiskGateBlockedEvidence
        )
        let liveIncidentStop = LiveIncidentStopBlockedEvidenceViewModel(
            readModel: readModel.liveIncidentStopBlockedEvidence
        )
        let timelineItems = allTimelineItems
            .filter { selectedSectionSet.contains($0.section) }
            .sortedByTimelinePosition()
        let evidenceLinks = timelineItems
            .flatMap(\.evidenceLinks)
            .uniqueEvidenceLinks()
        let sectionSnapshots = Self.makeSectionSnapshots(
            items: allTimelineItems,
            selectedSections: selectedSectionSet
        )
        let coversMarketEvents = allTimelineItems.contains { $0.section == .marketEvent }
        let coversMarketDataReplayOperations = allTimelineItems.contains {
            $0.section == .marketDataReplayOperation
        }
        let coversScenarioReplayEvidence = allTimelineItems.contains {
            $0.section == .scenarioReplayEvidence
        }
        let coversLiveExecutionControlBlockedEvidence = allTimelineItems.contains {
            $0.section == .liveExecutionControlBlockedEvidence
        }
        let coversLiveRiskGateBlockedEvidence = allTimelineItems.contains {
            $0.section == .liveRiskGateBlockedEvidence
        }
        let coversLiveIncidentStopBlockedEvidence = allTimelineItems.contains {
            $0.section == .liveIncidentStopBlockedEvidence
        }
        let coversLiveTradingBlockedEvidence = allTimelineItems.contains {
            $0.section == .liveTradingBlockedEvidence
        }
        let coversLiveMonitoringEvidence = allTimelineItems.contains {
            $0.section == .liveMonitoringEvidence
        }
        let coversStrategySignals = allTimelineItems.contains { $0.section == .strategySignal }
        let coversRiskDecisions = allTimelineItems.contains { $0.section == .riskDecision }
        let coversPaperOrders = allTimelineItems.contains { $0.section == .paperOrder }
        let coversSimulatedFills = allTimelineItems.contains { $0.section == .simulatedFill }
        let coversPortfolioProjections = allTimelineItems.contains { $0.section == .portfolioProjection }
        let coversReportArtifacts = allTimelineItems.contains { $0.section == .reportArtifact }
        let coversPaperWorkflowChainEvidence = Self.coversPaperWorkflowChainEvidence(allTimelineItems)
        let exposesDatabaseSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || scenarioReplay.exposesDatabaseSchema
            || liveExecutionControl.exposesPersistenceSchema
            || liveRiskGate.exposesPersistenceSchema
            || liveIncidentStop.exposesPersistenceSchema
        let exposesRuntimeObject = source.exposesRuntimeObjects
            || scenarioReplay.exposesRuntimeObject
            || liveExecutionControl.invokesRuntimeControl
            || liveRiskGate.invokesRuntimeControl
            || liveIncidentStop.invokesRuntimeControl
        let exposesAdapterRequest = source.callsBinanceAdapter
            || scenarioReplay.exposesAdapterRequest
            || liveExecutionControl.readsAdapter
            || liveRiskGate.readsAdapter
            || liveIncidentStop.readsAdapter
        let providesCommandSurface = scenarioReplay.providesCommandSurface
            || liveExecutionControl.providesCommandSurface
            || liveRiskGate.providesCommandSurface
            || liveIncidentStop.providesCommandSurface
        let providesOrderLevelCommand = scenarioReplay.providesOrderLevelCommand
            || liveExecutionControl.providesOrderLevelCommand
        let supportsQueryLanguage = false
        let providesLiveAudit = false
        let providesIncidentReplay = liveIncidentStop.providesIncidentReplay
        let providesStopControl = liveIncidentStop.providesStopControl
        let authorizesLiveTrading = scenarioReplay.authorizesLiveTrading
            || liveExecutionControl.authorizesLiveTrading
            || liveRiskGate.authorizesLiveTrading
            || liveIncidentStop.authorizesLiveTrading
        let touchesBrokerAction = liveExecutionControl.instantiatesBrokerExecutionAdapter
            || liveExecutionControl.instantiatesExchangeExecutionAdapter
            || liveRiskGate.instantiatesBrokerExecutionAdapter
            || liveRiskGate.instantiatesExchangeExecutionAdapter
            || liveIncidentStop.executesBrokerAction
        let authorizesTradingExecution = scenarioReplay.authorizesTradingExecution
            || liveExecutionControl.authorizesTradingExecution
            || liveRiskGate.authorizesTradingExecution
            || liveIncidentStop.authorizesTradingExecution

        self.source = source
        self.timelineItems = timelineItems
        self.evidenceLinks = evidenceLinks
        self.sectionSnapshots = sectionSnapshots
        self.filterSnapshot = PaperWorkflowEvidenceExplorerFilterSnapshot(
            availableSections: PaperWorkflowEvidenceExplorerSection.allCases,
            selectedSections: selectedSections,
            matchingItemCount: timelineItems.count
        )
        self.timelineItemCount = timelineItems.count
        self.evidenceLinkCount = evidenceLinks.count
        self.coversMarketEvents = coversMarketEvents
        self.coversMarketDataReplayOperations = coversMarketDataReplayOperations
        self.coversScenarioReplayEvidence = coversScenarioReplayEvidence
        self.coversLiveExecutionControlBlockedEvidence = coversLiveExecutionControlBlockedEvidence
        self.coversLiveRiskGateBlockedEvidence = coversLiveRiskGateBlockedEvidence
        self.coversLiveIncidentStopBlockedEvidence = coversLiveIncidentStopBlockedEvidence
        self.coversLiveTradingBlockedEvidence = coversLiveTradingBlockedEvidence
        self.coversLiveMonitoringEvidence = coversLiveMonitoringEvidence
        self.coversStrategySignals = coversStrategySignals
        self.coversRiskDecisions = coversRiskDecisions
        self.coversPaperOrders = coversPaperOrders
        self.coversSimulatedFills = coversSimulatedFills
        self.coversPortfolioProjections = coversPortfolioProjections
        self.coversReportArtifacts = coversReportArtifacts
        self.coversPaperWorkflowChainEvidence = coversPaperWorkflowChainEvidence
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && supportsQueryLanguage == false
            && providesLiveAudit == false
            && providesIncidentReplay == false
            && providesStopControl == false
            && scenarioReplay.readModelOnlyBoundaryHeld
            && liveExecutionControl.readModelOnlyBoundaryHeld
            && liveRiskGate.readModelOnlyBoundaryHeld
            && liveIncidentStop.readModelOnlyBoundaryHeld
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.supportsQueryLanguage = supportsQueryLanguage
        self.providesLiveAudit = providesLiveAudit
        self.providesIncidentReplay = providesIncidentReplay
        self.providesStopControl = providesStopControl
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }

    private static func normalizeSelectedSections(
        _ requestedSections: [PaperWorkflowEvidenceExplorerSection]?
    ) -> [PaperWorkflowEvidenceExplorerSection] {
        guard let requestedSections else {
            return PaperWorkflowEvidenceExplorerSection.allCases
        }
        let requestedSet = Set(requestedSections)
        return PaperWorkflowEvidenceExplorerSection.allCases.filter {
            requestedSet.contains($0)
        }
    }

    private static func makeTimelineItems(
        from readModel: PaperWorkflowEvidenceExplorerReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        (
            makeMarketItems(readModel.market)
                + makeMarketDataReplayOperationItems(readModel.report.marketDataReplayOperations)
                + makeScenarioReplayEvidenceItems(readModel.scenarioReplayEvidence)
                + makeLiveExecutionControlBlockedEvidenceItems(readModel.liveExecutionControlBlockedEvidence)
                + makeLiveRiskGateBlockedEvidenceItems(readModel.liveRiskGateBlockedEvidence)
                + makeLiveIncidentStopBlockedEvidenceItems(readModel.liveIncidentStopBlockedEvidence)
                + makeLiveTradingBlockedEvidenceItems(readModel.liveTradingBlockedEvidence)
                + makeLiveMonitoringEvidenceItems(readModel.liveMonitoringEvidence)
                + makeStrategyItems(readModel.strategy)
                + readModel.events.envelopes.compactMap(makeEnvelopeItem)
                + makeReportItems(readModel.report)
        ).sortedByTimelinePosition()
    }

    private static func makeMarketItems(_ readModel: MarketReadModel) -> [PaperWorkflowEventTimelineItem] {
        let barItems = readModel.bars.map { bar in
            PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                occurredAt: bar.interval.end,
                stream: "market",
                title: "Market bar",
                summary: "\(bar.symbol.rawValue) \(bar.timeframe.rawValue) close \(bar.close.rawValue)",
                evidenceLinks: [
                    marketLink(
                        id: "market-bar-\(bar.symbol.rawValue)-\(Int(bar.interval.end.timeIntervalSince1970))",
                        label: "market bar"
                    )
                ]
            )
        }
        let tradeItems = readModel.trades.map { trade in
            PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                occurredAt: trade.tradedAt,
                stream: "market",
                title: "Market trade",
                summary: "\(trade.symbol.rawValue) trade \(trade.price.rawValue)",
                evidenceLinks: [
                    marketLink(
                        id: "market-trade-\(trade.symbol.rawValue)-\(Int(trade.tradedAt.timeIntervalSince1970))",
                        label: "market trade"
                    )
                ]
            )
        }
        let bestBidAskItems = readModel.bestBidAsks.map { bestBidAsk in
            PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                occurredAt: bestBidAsk.observedAt,
                stream: "market",
                title: "Best bid ask",
                summary: "\(bestBidAsk.symbol.rawValue) bid \(bestBidAsk.bid.price.rawValue) ask \(bestBidAsk.ask.price.rawValue)",
                evidenceLinks: [
                    marketLink(
                        id: "best-bid-ask-\(bestBidAsk.symbol.rawValue)-\(Int(bestBidAsk.observedAt.timeIntervalSince1970))",
                        label: "best bid ask"
                    )
                ]
            )
        }
        let snapshotItems = readModel.orderBookSnapshots.map { snapshot in
            PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                occurredAt: snapshot.observedAt,
                stream: "market",
                title: "Order book snapshot",
                summary: "\(snapshot.symbol.rawValue) depth \(snapshot.bids.count + snapshot.asks.count)",
                evidenceLinks: [
                    marketLink(
                        id: "order-book-snapshot-\(snapshot.symbol.rawValue)-\(Int(snapshot.observedAt.timeIntervalSince1970))",
                        label: "order book snapshot"
                    )
                ]
            )
        }
        let deltaItems = readModel.orderBookDeltas.map { delta in
            PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                occurredAt: delta.observedAt,
                stream: "market",
                title: "Order book delta",
                summary: "\(delta.symbol.rawValue) updates \(delta.bidUpdates.count + delta.askUpdates.count)",
                evidenceLinks: [
                    marketLink(
                        id: "order-book-delta-\(delta.symbol.rawValue)-\(Int(delta.observedAt.timeIntervalSince1970))",
                        label: "order book delta"
                    )
                ]
            )
        }
        return barItems + tradeItems + bestBidAskItems + snapshotItems + deltaItems
    }

    private static func makeMarketDataReplayOperationItems(
        _ readModel: MarketDataReplayOperationsEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.map { item in
            let projectionStatus = item.projectionSnapshotConsistencyHeld
                ? "projection consistent"
                : "projection drift"
            return PaperWorkflowEventTimelineItem(
                section: .marketDataReplayOperation,
                sequence: item.eventLogLastSequence,
                stream: "market replay",
                title: "Market data replay operation",
                summary: "batch=\(item.batchID); replay=\(item.replayRunID); freshness=\(item.freshnessStatus); retention=\(item.retentionStatus.rawValue); \(projectionStatus)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .marketDataReplayOperation,
                        evidenceID: item.batchID,
                        label: "batch id",
                        sourceSequence: item.eventLogLastSequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .marketDataReplayOperation,
                        evidenceID: item.replayRunID,
                        label: "replay run id",
                        sourceSequence: item.projectionLastAppliedSequence
                    )
                ]
            )
        }
    }

    private static func makeScenarioReplayEvidenceItems(
        _ readModel: ScenarioReplayEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.flatMap { item in
            item.timelineEntries.map { entry in
                PaperWorkflowEventTimelineItem(
                    section: .scenarioReplayEvidence,
                    sequence: readModel.lastAppliedSequence,
                    stream: "scenario replay",
                    title: entry.title,
                    summary: entry.summary,
                    evidenceLinks: [
                        PaperWorkflowEvidenceLinkSummary(
                            section: .scenarioReplayEvidence,
                            evidenceID: entry.entryID,
                            label: entry.kind,
                            sourceSequence: readModel.lastAppliedSequence
                        ),
                        PaperWorkflowEvidenceLinkSummary(
                            section: .scenarioReplayEvidence,
                            evidenceID: item.reportInputVersionIdentity,
                            label: "report input version",
                            sourceSequence: readModel.lastAppliedSequence
                        )
                    ]
                )
            }
        }
    }

    private static func makeLiveTradingBlockedEvidenceItems(
        _ readModel: LiveTradingBlockedEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveTradingBlockedEvidence,
                sequence: readModel.lastAppliedSequence,
                stream: "live boundary",
                title: "Live trading gate blocked",
                summary: "\(item.capability.rawValue) blocked; gate=\(item.gate.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .liveTradingBlockedEvidence,
                        evidenceID: item.evidenceID,
                        label: "live blocked capability",
                        sourceSequence: readModel.lastAppliedSequence
                    )
                ]
            )
        }
    }

    private static func makeLiveExecutionControlBlockedEvidenceItems(
        _ readModel: LiveExecutionControlBlockedEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveExecutionControlBlockedEvidence,
                sequence: readModel.lastAppliedSequence,
                stream: "live execution control",
                title: "Live execution control gate blocked",
                summary: "\(item.gate.rawValue) blocked; reasons=\(item.blockedReasonLabels.joined(separator: ", "))",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .liveExecutionControlBlockedEvidence,
                        evidenceID: item.evidenceID,
                        label: "execution-control blocked gate",
                        sourceSequence: readModel.lastAppliedSequence
                    )
                ]
            )
        }
    }

    private static func makeLiveRiskGateBlockedEvidenceItems(
        _ readModel: LiveRiskGateBlockedEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveRiskGateBlockedEvidence,
                sequence: readModel.lastAppliedSequence,
                stream: "live risk gate",
                title: "Live risk gate blocked",
                summary: "\(item.gate.rawValue) blocked; reasons=\(item.blockedReasonLabels.joined(separator: ", "))",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .liveRiskGateBlockedEvidence,
                        evidenceID: item.evidenceID,
                        label: "live risk blocked gate",
                        sourceSequence: readModel.lastAppliedSequence
                    )
                ]
            )
        }
    }

    private static func makeLiveIncidentStopBlockedEvidenceItems(
        _ readModel: LiveIncidentStopBlockedEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        readModel.items.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveIncidentStopBlockedEvidence,
                sequence: readModel.lastAppliedSequence,
                stream: "live incident stop",
                title: "Live incident / stop gate blocked",
                summary: "\(item.gate.rawValue) blocked; reasons=\(item.blockedReasonLabels.joined(separator: ", "))",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .liveIncidentStopBlockedEvidence,
                        evidenceID: item.evidenceID,
                        label: "incident-stop blocked gate",
                        sourceSequence: readModel.lastAppliedSequence
                    )
                ]
            )
        }
    }

    private static func makeLiveMonitoringEvidenceItems(
        _ readModel: LiveMonitoringEvidenceReadModel
    ) -> [PaperWorkflowEventTimelineItem] {
        let monitoring = readModel.monitoringEvidence
        let streamEvidence = monitoring.streamEvidence
        let runtimeHealth = streamEvidence.runtimeHealth
        let sequence = readModel.lastAppliedSequence
        let healthItem = PaperWorkflowEventTimelineItem(
            section: .liveMonitoringEvidence,
            sequence: sequence,
            stream: "live monitoring",
            title: "Live monitoring runtime health",
            summary: "health=\(runtimeHealth.status.rawValue); connections=\(runtimeHealth.connections.count)",
            evidenceLinks: [
                liveMonitoringLink(
                    id: runtimeHealth.healthID.rawValue,
                    label: "runtime health",
                    sequence: sequence
                )
            ]
        )
        let connectionItems = runtimeHealth.connections.map { connection in
            PaperWorkflowEventTimelineItem(
                section: .liveMonitoringEvidence,
                sequence: sequence,
                stream: "live monitoring",
                title: "Live monitoring connection",
                summary: "\(connection.connectionKind.rawValue) \(connection.status.rawValue)",
                evidenceLinks: [
                    liveMonitoringLink(
                        id: connection.connectionID.rawValue,
                        label: "connection status",
                        sequence: sequence
                    )
                ]
            )
        }
        let streamItems = streamEvidence.streamEvidence.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveMonitoringEvidence,
                sequence: sequence,
                stream: "live monitoring",
                title: "Live monitoring stream",
                summary: "\(item.streamKind.rawValue) \(item.status.rawValue); evidence=\(item.evidenceKind.rawValue)",
                evidenceLinks: [
                    liveMonitoringLink(
                        id: item.streamID.rawValue,
                        label: "stream evidence",
                        sequence: sequence
                    )
                ]
            )
        }
        let latencyItems = monitoring.latencyEvidence.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveMonitoringEvidence,
                sequence: sequence,
                stream: "live monitoring",
                title: "Live monitoring latency",
                summary: "\(item.scope.rawValue) \(item.bucket.rawValue); latency=\(formatMilliseconds(item.measuredLatencyMilliseconds)); freshness=\(formatMilliseconds(item.freshnessAgeMilliseconds))",
                evidenceLinks: [
                    liveMonitoringLink(
                        id: item.latencyID.rawValue,
                        label: "latency evidence",
                        sequence: sequence
                    )
                ]
            )
        }
        let errorItems = monitoring.errorEvidence.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveMonitoringEvidence,
                sequence: sequence,
                stream: "live monitoring",
                title: "Live monitoring error",
                summary: "\(item.scope.rawValue) \(item.status.rawValue); code=\(item.errorCode)",
                evidenceLinks: [
                    liveMonitoringLink(
                        id: item.errorID.rawValue,
                        label: "error evidence",
                        sequence: sequence
                    )
                ]
            )
        }
        let degradedStateItems = monitoring.degradedStateEvidence.map { item in
            PaperWorkflowEventTimelineItem(
                section: .liveMonitoringEvidence,
                sequence: sequence,
                stream: "live monitoring",
                title: "Live monitoring degraded state",
                summary: "\(item.scope.rawValue) \(item.status.rawValue); reason=\(item.reason)",
                evidenceLinks: [
                    liveMonitoringLink(
                        id: item.stateID.rawValue,
                        label: "degraded state evidence",
                        sequence: sequence
                    )
                ]
            )
        }
        return [healthItem] + connectionItems + streamItems + latencyItems + errorItems + degradedStateItems
    }

    private static func makeStrategyItems(_ readModel: StrategyReadModel) -> [PaperWorkflowEventTimelineItem] {
        readModel.signals.map { signal in
            PaperWorkflowEventTimelineItem(
                section: .strategySignal,
                occurredAt: signal.generatedAt,
                stream: "strategy",
                title: "Strategy signal",
                summary: "\(signal.strategyID.rawValue) \(signal.symbol.rawValue) \(signal.direction.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .strategySignal,
                        evidenceID: signal.strategyID.rawValue,
                        label: "strategy signal"
                    )
                ]
            )
        }
    }

    private static func makeEnvelopeItem(_ envelope: EventEnvelope) -> PaperWorkflowEventTimelineItem? {
        switch envelope.event {
        case let .market(event):
            return PaperWorkflowEventTimelineItem(
                section: .marketEvent,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Market event",
                summary: "\(event.symbol.rawValue) \(envelope.stream.rawValue)",
                evidenceLinks: [
                    marketLink(
                        id: "market-envelope-\(envelope.sequence)",
                        label: "market envelope",
                        sequence: envelope.sequence
                    )
                ]
            )
        case let .strategySignal(signal):
            return PaperWorkflowEventTimelineItem(
                section: .strategySignal,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Strategy signal event",
                summary: "\(signal.strategyID.rawValue) \(signal.direction.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .strategySignal,
                        evidenceID: signal.strategyID.rawValue,
                        label: "strategy signal",
                        sourceSequence: envelope.sequence
                    )
                ]
            )
        case let .paper(.executionDecisionRecorded(decision)):
            var evidenceLinks = [
                PaperWorkflowEvidenceLinkSummary(
                    section: .riskDecision,
                    evidenceID: decision.decisionID.rawValue,
                    label: "execution decision",
                    sourceSequence: envelope.sequence
                )
            ]
            if let orderIntent = decision.paperOrderIntent {
                evidenceLinks.append(
                    PaperWorkflowEvidenceLinkSummary(
                        section: .paperOrder,
                        evidenceID: orderIntent.orderID.rawValue,
                        label: "generated paper order",
                        sourceSequence: decision.sourceOrderIntentSequence
                    )
                )
            }
            if let simulatedFillEvidence = decision.simulatedFillEvidence {
                evidenceLinks.append(
                    PaperWorkflowEvidenceLinkSummary(
                        section: .simulatedFill,
                        evidenceID: simulatedFillEvidence.fillID.rawValue,
                        label: "generated simulated fill",
                        sourceSequence: simulatedFillEvidence.sourceOrderIntentSequence
                    )
                )
            }
            return PaperWorkflowEventTimelineItem(
                section: .riskDecision,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Paper execution decision",
                summary: "\(decision.decisionID.rawValue) \(decision.status.rawValue)",
                evidenceLinks: evidenceLinks
            )
        case let .paper(.orderIntentRecorded(orderIntent)):
            return PaperWorkflowEventTimelineItem(
                section: .paperOrder,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Paper order intent",
                summary: "\(orderIntent.orderID.rawValue) \(orderIntent.lifecycleState.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .paperOrder,
                        evidenceID: orderIntent.orderID.rawValue,
                        label: "paper order",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .riskDecision,
                        evidenceID: orderIntent.riskDecisionID.rawValue,
                        label: "risk decision",
                        sourceSequence: orderIntent.sourceRiskDecisionSequence
                    )
                ]
            )
        case let .paper(.orderLocalLifecycleTransitionRecorded(transition)):
            return PaperWorkflowEventTimelineItem(
                section: .paperOrder,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Paper local lifecycle transition",
                summary: "\(transition.transitionID.rawValue) \(transition.toState.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .paperOrder,
                        evidenceID: transition.transitionID.rawValue,
                        label: "local lifecycle transition",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .riskDecision,
                        evidenceID: transition.riskDecisionID.rawValue,
                        label: "paper risk decision",
                        sourceSequence: transition.sourceRiskDecisionSequence
                    )
                ]
            )
        case let .paper(.simulatedFillRecorded(fill)):
            return PaperWorkflowEventTimelineItem(
                section: .simulatedFill,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Simulated fill evidence",
                summary: "\(fill.fillID.rawValue) notional \(fill.grossNotional)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .simulatedFill,
                        evidenceID: fill.fillID.rawValue,
                        label: "simulated fill",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .paperOrder,
                        evidenceID: fill.orderID.rawValue,
                        label: "paper order",
                        sourceSequence: fill.sourceOrderIntentSequence
                    )
                ]
            )
        case let .risk(.evaluationRequested(query)):
            return PaperWorkflowEventTimelineItem(
                section: .riskDecision,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Risk evaluation requested",
                summary: "\(query.paperOrderID.rawValue) \(query.executionMode.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .riskDecision,
                        evidenceID: query.paperOrderID.rawValue,
                        label: "risk evaluation",
                        sourceSequence: envelope.sequence
                    )
                ]
            )
        case let .risk(.blocked(evidence)):
            return PaperWorkflowEventTimelineItem(
                section: .riskDecision,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Risk blocker evidence",
                summary: "\(evidence.evidenceID.rawValue) \(evidence.reason.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .riskDecision,
                        evidenceID: evidence.evidenceID.rawValue,
                        label: "risk blocker",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .paperOrder,
                        evidenceID: evidence.paperOrderID.rawValue,
                        label: "blocked paper order",
                        sourceSequence: envelope.sequence
                    )
                ]
            )
        case let .portfolio(.paperProjectionUpdated(update)):
            return PaperWorkflowEventTimelineItem(
                section: .portfolioProjection,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Portfolio projection update",
                summary: "\(update.updateID.rawValue) \(update.portfolioID.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .portfolioProjection,
                        evidenceID: update.updateID.rawValue,
                        label: "portfolio projection",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .simulatedFill,
                        evidenceID: update.fillID.rawValue,
                        label: "simulated fill",
                        sourceSequence: update.sourceSequence
                    )
                ]
            )
        case let .portfolio(.paperAccountPortfolioProjectionUpdated(snapshot)):
            return PaperWorkflowEventTimelineItem(
                section: .portfolioProjection,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Paper account portfolio projection",
                summary: "\(snapshot.snapshotID.rawValue) positions=\(snapshot.positions.count)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .portfolioProjection,
                        evidenceID: snapshot.snapshotID.rawValue,
                        label: "account portfolio projection",
                        sourceSequence: envelope.sequence
                    ),
                    PaperWorkflowEvidenceLinkSummary(
                        section: .simulatedFill,
                        evidenceID: snapshot.sourceFillIDs.map(\.rawValue).joined(separator: ","),
                        label: "replayed simulated fills",
                        sourceSequence: snapshot.sourceSequences.first ?? envelope.sequence
                    )
                ]
            )
        case let .portfolio(.exposureUpdated(exposure)):
            return PaperWorkflowEventTimelineItem(
                section: .portfolioProjection,
                sequence: envelope.sequence,
                occurredAt: envelope.recordedAt,
                stream: envelope.stream.rawValue,
                title: "Portfolio exposure update",
                summary: "\(exposure.portfolioID.rawValue) \(exposure.symbol.rawValue)",
                evidenceLinks: [
                    PaperWorkflowEvidenceLinkSummary(
                        section: .portfolioProjection,
                        evidenceID: exposure.portfolioID.rawValue,
                        label: "portfolio exposure",
                        sourceSequence: envelope.sequence
                    )
                ]
            )
        default:
            return nil
        }
    }

    private static func makeReportItems(_ readModel: ReportReadModel) -> [PaperWorkflowEventTimelineItem] {
        readModel.artifacts.map { artifact in
            PaperWorkflowEventTimelineItem(
                section: .reportArtifact,
                sequence: artifact.lastAppliedSequence,
                stream: "report",
                title: "Report artifact",
                summary: "\(artifact.reportID) \(artifact.parityStatus.rawValue)",
                evidenceLinks: makeReportEvidenceLinks(artifact)
            )
        }
    }

    private static func makeReportEvidenceLinks(
        _ artifact: ResearchBacktestReportArtifact
    ) -> [PaperWorkflowEvidenceLinkSummary] {
        let reportLinks = [
            PaperWorkflowEvidenceLinkSummary(
                section: .reportArtifact,
                evidenceID: artifact.reportID,
                label: "report artifact",
                sourceSequence: artifact.lastAppliedSequence
            )
        ]
        let riskLinks = artifact.paperRuntimeEvidence.riskBlockerEvidenceIDs.map {
            PaperWorkflowEvidenceLinkSummary(
                section: .riskDecision,
                evidenceID: $0,
                label: "risk blocker"
            )
        }
        let decisionLinks = artifact.paperExecutionWorkflowEvidence.decisionIDs.map {
            PaperWorkflowEvidenceLinkSummary(
                section: .riskDecision,
                evidenceID: $0,
                label: "execution decision"
            )
        }
        let orderLinks = (
            artifact.paperExecutionWorkflowEvidence.paperOrderIDs
                + artifact.paperRuntimeEvidence.rejectedPaperOrderIDs
        ).uniqueSortedStrings().map {
            PaperWorkflowEvidenceLinkSummary(
                section: .paperOrder,
                evidenceID: $0,
                label: "paper order"
            )
        }
        let fillLinks = artifact.paperExecutionWorkflowEvidence.simulatedFillIDs.map {
            PaperWorkflowEvidenceLinkSummary(
                section: .simulatedFill,
                evidenceID: $0,
                label: "simulated fill"
            )
        }
        let portfolioLinks = (
            artifact.paperExecutionWorkflowEvidence.portfolioUpdateIDs
                + artifact.paperRuntimeEvidence.portfolioUpdateIDs
                + artifact.paperExecutionWorkflowEvidence.portfolioIDs
                + artifact.paperRuntimeEvidence.portfolioIDs
        ).uniqueSortedStrings().map {
            PaperWorkflowEvidenceLinkSummary(
                section: .portfolioProjection,
                evidenceID: $0,
                label: "portfolio evidence"
            )
        }
        return (reportLinks + riskLinks + decisionLinks + orderLinks + fillLinks + portfolioLinks)
            .uniqueEvidenceLinks()
    }

    private static func makeSectionSnapshots(
        items: [PaperWorkflowEventTimelineItem],
        selectedSections: Set<PaperWorkflowEvidenceExplorerSection>
    ) -> [PaperWorkflowEvidenceExplorerSectionSnapshot] {
        PaperWorkflowEvidenceExplorerSection.allCases.map { section in
            let sectionItems = items.filter { $0.section == section }
            return PaperWorkflowEvidenceExplorerSectionSnapshot(
                section: section,
                itemCount: sectionItems.count,
                evidenceLinkCount: sectionItems.flatMap(\.evidenceLinks).uniqueEvidenceLinks().count,
                latestSequence: sectionItems.compactMap(\.sequence).max(),
                selected: selectedSections.contains(section)
            )
        }
    }

    private static func coversPaperWorkflowChainEvidence(
        _ items: [PaperWorkflowEventTimelineItem]
    ) -> Bool {
        let links = items.flatMap(\.evidenceLinks)
        let hasDecision = links.contains { $0.section == .riskDecision }
        let hasOrder = links.contains { $0.section == .paperOrder }
        let hasFill = links.contains { $0.section == .simulatedFill }
        let hasPortfolio = links.contains { $0.section == .portfolioProjection }
        let hasReport = links.contains { $0.section == .reportArtifact }
        return hasDecision && hasOrder && hasFill && hasPortfolio && hasReport
    }

    private static func marketLink(
        id: String,
        label: String,
        sequence: Int? = nil
    ) -> PaperWorkflowEvidenceLinkSummary {
        PaperWorkflowEvidenceLinkSummary(
            section: .marketEvent,
            evidenceID: id,
            label: label,
            sourceSequence: sequence
        )
    }

    private static func liveMonitoringLink(
        id: String,
        label: String,
        sequence: Int? = nil
    ) -> PaperWorkflowEvidenceLinkSummary {
        PaperWorkflowEvidenceLinkSummary(
            section: .liveMonitoringEvidence,
            evidenceID: id,
            label: label,
            sourceSequence: sequence
        )
    }

    private static func formatMilliseconds(_ value: Int?) -> String {
        value.map { "\($0)ms" } ?? "n/a"
    }
}

private extension Array where Element == PaperWorkflowEventTimelineItem {
    func sortedByTimelinePosition() -> [PaperWorkflowEventTimelineItem] {
        sorted { lhs, rhs in
            let lhsTime = lhs.occurredAt ?? .distantFuture
            let rhsTime = rhs.occurredAt ?? .distantFuture
            if lhsTime != rhsTime {
                return lhsTime < rhsTime
            }
            if lhs.sequence != rhs.sequence {
                return (lhs.sequence ?? Int.max) < (rhs.sequence ?? Int.max)
            }
            if lhs.section != rhs.section {
                return lhs.section.rawValue < rhs.section.rawValue
            }
            return lhs.title < rhs.title
        }
    }
}

private extension Array where Element == PaperWorkflowEvidenceLinkSummary {
    func sortedByEvidenceLink() -> [PaperWorkflowEvidenceLinkSummary] {
        sorted { lhs, rhs in
            if lhs.section != rhs.section {
                return lhs.section.rawValue < rhs.section.rawValue
            }
            if lhs.evidenceID != rhs.evidenceID {
                return lhs.evidenceID < rhs.evidenceID
            }
            if lhs.sourceSequence != rhs.sourceSequence {
                return (lhs.sourceSequence ?? Int.max) < (rhs.sourceSequence ?? Int.max)
            }
            return lhs.label < rhs.label
        }
    }

    func uniqueEvidenceLinks() -> [PaperWorkflowEvidenceLinkSummary] {
        var seen = Set<PaperWorkflowEvidenceLinkSummary>()
        var values: [PaperWorkflowEvidenceLinkSummary] = []
        for value in sortedByEvidenceLink() where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}
