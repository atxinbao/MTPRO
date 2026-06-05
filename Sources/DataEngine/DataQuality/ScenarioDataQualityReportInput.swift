import DomainModel
import Foundation

/// Scenario data quality / report input 合同固定 MTP-107 的质量门禁和报告输入版本证据。
///
/// 本文件只消费 MTP-106 `ScenarioReplayEvidence` 的本地 deterministic evidence，输出可编码、
/// 可比较、可追溯的 quality verdict 和 report input version。它不解析 manifest 文件、不暴露
/// SQLite / DuckDB schema、不读取 Runtime object、不做 production data observability、不自动下载
/// 或修复数据，也不接 signed/account/listenKey、broker、LiveExecutionAdapter、OMS、live command 或交易按钮。

/// ScenarioDataQualityGateKind 定义 MTP-107 最小 data quality gate taxonomy。
///
/// 这些 gate 只服务 local scenario replay 与 report reproducibility：record order、window coverage、
/// checksum、freshness、missing data 和 duplicate data。它们不是生产数据监控平台规则，也不授权
/// 自动下载、自动修复、broker/account reconciliation 或 Simulated Exchange / Backtest Parity runtime。
public enum ScenarioDataQualityGateKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case recordOrder = "record order"
    case windowCoverage = "window coverage"
    case checksumMatch = "checksum match"
    case freshnessStatus = "freshness status"
    case missingData = "missing data"
    case duplicateData = "duplicate data"
}

/// ScenarioDataQualityGateVerdict 表达单个 quality gate 的判定结果。
///
/// `passed` 表示当前本地 replay evidence 可直接作为报告输入；`marked` 表示 evidence 可追溯但
/// 需要在 report input version 中标注，例如 stale fixture；`rejected` 表示该输入不能作为
/// accepted report input 使用，例如 checksum mismatch、missing data 或 duplicate data。
public enum ScenarioDataQualityGateVerdict: String, Codable, Equatable, Hashable, Sendable {
    case passed
    case marked
    case rejected
}

/// ScenarioDataQualityVerdict 是全部 quality gates 汇总后的报告输入质量结论。
///
/// 任一 gate `rejected` 时整体为 rejected；没有 rejected 但存在 marked 时整体为 marked；全部通过时
/// 才是 accepted。该 verdict 只用于本地 report reproducibility evidence，不代表生产数据 SLA。
public enum ScenarioDataQualityVerdict: String, Codable, Equatable, Hashable, Sendable {
    case accepted
    case marked
    case rejected
}

/// ScenarioDataQualityGateEvidence 保存单个 data quality gate 的 deterministic 判定证据。
///
/// `expected` / `actual` 只复制 MTP-106 replay evidence 与当前观测输入的稳定摘要，不暴露数据库
/// schema、adapter request、Runtime object 或外部系统 payload。
public struct ScenarioDataQualityGateEvidence: Codable, Equatable, Sendable {
    public let kind: ScenarioDataQualityGateKind
    public let verdict: ScenarioDataQualityGateVerdict
    public let expected: String
    public let actual: String
    public let sourceAnchor: String
    public let summaryLine: String

    public init(
        kind: ScenarioDataQualityGateKind,
        verdict: ScenarioDataQualityGateVerdict,
        expected: String,
        actual: String,
        sourceAnchor: String
    ) throws {
        guard expected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityGate.expected",
                expected: "non-empty expected evidence",
                actual: "empty"
            )
        }
        guard actual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityGate.actual",
                expected: "non-empty actual evidence",
                actual: "empty"
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityGate.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }

        self.kind = kind
        self.verdict = verdict
        self.expected = expected
        self.actual = actual
        self.sourceAnchor = sourceAnchor
        self.summaryLine = "\(kind.rawValue)=\(verdict.rawValue)"
    }
}

/// ScenarioDataQualityGateEvaluation 汇总 MTP-107 的最小 gate 判定。
///
/// Evaluation 默认消费 `ScenarioReplayEvidence.deterministicFixture`，并允许 tests 注入 checksum、
/// record order、freshness、missing / duplicate 摘要来验证 bad fixture 如何被 rejected 或 marked。
/// 这些注入只用于 deterministic Core tests，不是 runtime repair、network reload 或 production observer。
public struct ScenarioDataQualityGateEvaluation: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let replayInputIdentity: String
    public let replayWindowIdentity: String
    public let gates: [ScenarioDataQualityGateEvidence]
    public let qualityVerdict: ScenarioDataQualityVerdict
    public let qualitySummary: String
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let runsProductionDataObservability: Bool
    public let performsAutomaticDownload: Bool
    public let performsAutomaticRepair: Bool
    public let performsBrokerAccountReconciliation: Bool
    public let implementsSimulatedExchangeBacktestParity: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsRuntimeObject: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var gateTaxonomyHeld: Bool {
        gates.map(\.kind) == ScenarioDataQualityGateKind.allCases
    }

    public var allRequiredGatesEvaluated: Bool {
        gateTaxonomyHeld && gates.count == ScenarioDataQualityGateKind.allCases.count
    }

    public var acceptedForReportInput: Bool {
        qualityVerdict == .accepted
    }

    public var qualityGateBoundaryHeld: Bool {
        allRequiredGatesEvaluated
            && validationAnchors == Self.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && runsProductionDataObservability == false
            && performsAutomaticDownload == false
            && performsAutomaticRepair == false
            && performsBrokerAccountReconciliation == false
            && implementsSimulatedExchangeBacktestParity == false
            && exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && readsRuntimeObject == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-107-data-quality-gate-evaluation"),
        issueID: Identifier = try! Identifier("MTP-107"),
        replayEvidence: ScenarioReplayEvidence = .deterministicFixture,
        observedOrderedRecordStarts: [Int]? = nil,
        observedWindowDescription: String? = nil,
        observedRecordCount: Int? = nil,
        observedChecksum: String? = nil,
        observedFreshnessStatus: ScenarioReplayFreshnessStatus? = nil,
        missingRecordSequences: [Int] = [],
        duplicateRecordSequences: [Int] = [],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        runsProductionDataObservability: Bool = false,
        performsAutomaticDownload: Bool = false,
        performsAutomaticRepair: Bool = false,
        performsBrokerAccountReconciliation: Bool = false,
        implementsSimulatedExchangeBacktestParity: Bool = false,
        exposesDatabaseSchema: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsRuntimeObject: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validateForbidden(
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            runsProductionDataObservability: runsProductionDataObservability,
            performsAutomaticDownload: performsAutomaticDownload,
            performsAutomaticRepair: performsAutomaticRepair,
            performsBrokerAccountReconciliation: performsBrokerAccountReconciliation,
            implementsSimulatedExchangeBacktestParity: implementsSimulatedExchangeBacktestParity,
            exposesDatabaseSchema: exposesDatabaseSchema,
            exposesAdapterRequest: exposesAdapterRequest,
            readsRuntimeObject: readsRuntimeObject,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )
        guard replayEvidence.evidenceBoundaryHeld else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQuality.replayEvidenceBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        try Self.validateSequenceList(missingRecordSequences, field: "missingRecordSequences")
        try Self.validateSequenceList(duplicateRecordSequences, field: "duplicateRecordSequences")

        let observedStarts = observedOrderedRecordStarts ?? replayEvidence.replayWindow.orderedRecordStarts
        let observedOrderIdentity = Self.recordOrderIdentity(for: observedStarts)
        let windowDescription = observedWindowDescription ?? replayEvidence.replayWindow.windowDescription
        let recordCount = observedRecordCount ?? replayEvidence.replayWindow.recordCount
        let checksum = observedChecksum ?? replayEvidence.checksumEvidence.checksum
        let freshness = observedFreshnessStatus ?? replayEvidence.freshnessEvidence.status
        let gates = try Self.buildGates(
            replayEvidence: replayEvidence,
            observedOrderedRecordStarts: observedStarts,
            observedRecordOrderIdentity: observedOrderIdentity,
            observedWindowDescription: windowDescription,
            observedRecordCount: recordCount,
            observedChecksum: checksum,
            observedFreshnessStatus: freshness,
            missingRecordSequences: missingRecordSequences,
            duplicateRecordSequences: duplicateRecordSequences
        )
        let qualityVerdict = Self.qualityVerdict(for: gates)

        self.contractID = contractID
        self.issueID = issueID
        self.replayInputIdentity = replayEvidence.dataQualityGateInputIdentity
        self.replayWindowIdentity = replayEvidence.replayWindow.deterministicWindowIdentity
        self.gates = gates
        self.qualityVerdict = qualityVerdict
        self.qualitySummary = gates.map(\.summaryLine).joined(separator: "; ")
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.runsProductionDataObservability = runsProductionDataObservability
        self.performsAutomaticDownload = performsAutomaticDownload
        self.performsAutomaticRepair = performsAutomaticRepair
        self.performsBrokerAccountReconciliation = performsBrokerAccountReconciliation
        self.implementsSimulatedExchangeBacktestParity = implementsSimulatedExchangeBacktestParity
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsRuntimeObject = readsRuntimeObject
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contractID = try container.decode(Identifier.self, forKey: .contractID)
        let issueID = try container.decode(Identifier.self, forKey: .issueID)
        let replayInputIdentity = try container.decode(String.self, forKey: .replayInputIdentity)
        let replayWindowIdentity = try container.decode(String.self, forKey: .replayWindowIdentity)
        let gates = try container.decode([ScenarioDataQualityGateEvidence].self, forKey: .gates)
        let qualityVerdict = try container.decode(ScenarioDataQualityVerdict.self, forKey: .qualityVerdict)
        let qualitySummary = try container.decode(String.self, forKey: .qualitySummary)
        let validationAnchors = try container.decode([String].self, forKey: .validationAnchors)
        let expected = try ScenarioDataQualityGateEvaluation()

        try Self.validateForbidden(
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            runsProductionDataObservability: try container.decode(
                Bool.self,
                forKey: .runsProductionDataObservability
            ),
            performsAutomaticDownload: try container.decode(Bool.self, forKey: .performsAutomaticDownload),
            performsAutomaticRepair: try container.decode(Bool.self, forKey: .performsAutomaticRepair),
            performsBrokerAccountReconciliation: try container.decode(
                Bool.self,
                forKey: .performsBrokerAccountReconciliation
            ),
            implementsSimulatedExchangeBacktestParity: try container.decode(
                Bool.self,
                forKey: .implementsSimulatedExchangeBacktestParity
            ),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsRuntimeObject: try container.decode(Bool.self, forKey: .readsRuntimeObject),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )

        guard contractID == expected.contractID,
              issueID == expected.issueID,
              replayInputIdentity == expected.replayInputIdentity,
              replayWindowIdentity == expected.replayWindowIdentity,
              gates == expected.gates,
              qualityVerdict == expected.qualityVerdict,
              qualitySummary == expected.qualitySummary else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityGateEvaluation",
                expected: expected.qualitySummary,
                actual: qualitySummary
            )
        }

        try self.init()
    }

    public static let requiredValidationAnchors: [String] = [
        "MTP-107-DATA-QUALITY-GATE-TAXONOMY",
        "MTP-107-MINIMAL-DATA-QUALITY-GATES",
        "MTP-107-REPORT-INPUT-VERSIONING",
        "MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE",
        "MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM",
        "MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY"
    ]

    private static func buildGates(
        replayEvidence: ScenarioReplayEvidence,
        observedOrderedRecordStarts: [Int],
        observedRecordOrderIdentity: String,
        observedWindowDescription: String,
        observedRecordCount: Int,
        observedChecksum: String,
        observedFreshnessStatus: ScenarioReplayFreshnessStatus,
        missingRecordSequences: [Int],
        duplicateRecordSequences: [Int]
    ) throws -> [ScenarioDataQualityGateEvidence] {
        let replayWindow = replayEvidence.replayWindow
        return [
            try ScenarioDataQualityGateEvidence(
                kind: .recordOrder,
                verdict: observedOrderedRecordStarts == replayWindow.orderedRecordStarts ? .passed : .rejected,
                expected: replayWindow.recordOrderIdentity,
                actual: observedRecordOrderIdentity,
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            ),
            try ScenarioDataQualityGateEvidence(
                kind: .windowCoverage,
                verdict: observedWindowDescription == replayWindow.windowDescription
                    && observedRecordCount == replayWindow.recordCount ? .passed : .rejected,
                expected: "window=\(replayWindow.windowDescription); records=\(replayWindow.recordCount)",
                actual: "window=\(observedWindowDescription); records=\(observedRecordCount)",
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            ),
            try ScenarioDataQualityGateEvidence(
                kind: .checksumMatch,
                verdict: observedChecksum == replayEvidence.checksumEvidence.checksum ? .passed : .rejected,
                expected: replayEvidence.checksumEvidence.checksum,
                actual: observedChecksum,
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            ),
            try ScenarioDataQualityGateEvidence(
                kind: .freshnessStatus,
                verdict: freshnessVerdict(observedFreshnessStatus),
                expected: ScenarioReplayFreshnessStatus.fresh.rawValue,
                actual: observedFreshnessStatus.rawValue,
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            ),
            try ScenarioDataQualityGateEvidence(
                kind: .missingData,
                verdict: missingRecordSequences.isEmpty ? .passed : .rejected,
                expected: "none",
                actual: sequenceSummary(missingRecordSequences),
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            ),
            try ScenarioDataQualityGateEvidence(
                kind: .duplicateData,
                verdict: duplicateRecordSequences.isEmpty ? .passed : .rejected,
                expected: "none",
                actual: sequenceSummary(duplicateRecordSequences),
                sourceAnchor: "MTP-107-MINIMAL-DATA-QUALITY-GATES"
            )
        ]
    }

    private static func validateForbidden(
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        runsProductionDataObservability: Bool,
        performsAutomaticDownload: Bool,
        performsAutomaticRepair: Bool,
        performsBrokerAccountReconciliation: Bool,
        implementsSimulatedExchangeBacktestParity: Bool,
        exposesDatabaseSchema: Bool,
        exposesAdapterRequest: Bool,
        readsRuntimeObject: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQuality.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("runsProductionDataObservability", runsProductionDataObservability),
            ("performsAutomaticDownload", performsAutomaticDownload),
            ("performsAutomaticRepair", performsAutomaticRepair),
            ("performsBrokerAccountReconciliation", performsBrokerAccountReconciliation),
            ("implementsSimulatedExchangeBacktestParity", implementsSimulatedExchangeBacktestParity),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsRuntimeObject", readsRuntimeObject),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioDataQuality.\(capability.0)"
            )
        }
    }

    private static func validateSequenceList(_ values: [Int], field: String) throws {
        guard values.allSatisfy({ $0 > 0 }) else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQuality.\(field)",
                expected: "positive deterministic record sequences",
                actual: values.map(String.init).joined(separator: ",")
            )
        }
        guard values == values.sorted(), Set(values).count == values.count else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQuality.\(field)",
                expected: "sorted unique sequence list",
                actual: values.map(String.init).joined(separator: ",")
            )
        }
    }

    private static func recordOrderIdentity(for starts: [Int]) -> String {
        starts.enumerated().map { index, start in "\(index + 1):\(start)" }.joined(separator: "|")
    }

    private static func sequenceSummary(_ values: [Int]) -> String {
        values.isEmpty ? "none" : values.map(String.init).joined(separator: ",")
    }

    private static func freshnessVerdict(_ status: ScenarioReplayFreshnessStatus) -> ScenarioDataQualityGateVerdict {
        switch status {
        case .fresh:
            return .passed
        case .stale:
            return .marked
        case .expired, .notRetained:
            return .rejected
        }
    }

    private static func qualityVerdict(for gates: [ScenarioDataQualityGateEvidence]) -> ScenarioDataQualityVerdict {
        if gates.contains(where: { $0.verdict == .rejected }) {
            return .rejected
        }
        if gates.contains(where: { $0.verdict == .marked }) {
            return .marked
        }
        return .accepted
    }
}

/// ScenarioReportInputVersion 是 MTP-107 的 stable report input versioning contract。
///
/// Report / Backtest / future Simulated Exchange 只能通过这个值对象追溯 scenario id、dataset version、
/// fixture version、replay window、checksum、freshness 和 quality verdict。该 contract 不暴露
/// SQLite / DuckDB schema、adapter request、Runtime object、broker payload 或真实账户资料。
public struct ScenarioReportInputVersion: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let replayWindowIdentity: String
    public let replayWindowDescription: String
    public let checksum: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let qualityVerdict: ScenarioDataQualityVerdict
    public let qualitySummary: String
    public let canonicalFieldOrder: [String]
    public let versionIdentity: String
    public let sourceAnchors: [String]
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsRuntimeObject: Bool

    public var reportInputBoundaryHeld: Bool {
        canonicalFieldOrder == Self.requiredCanonicalFieldOrder
            && sourceAnchors == Self.requiredSourceAnchors
            && exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && readsRuntimeObject == false
            && versionIdentity.contains(checksum)
            && versionIdentity.contains(qualityVerdict.rawValue)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-107-report-input-versioning"),
        issueID: Identifier = try! Identifier("MTP-107"),
        replayEvidence: ScenarioReplayEvidence = .deterministicFixture,
        qualityEvaluation: ScenarioDataQualityGateEvaluation = try! ScenarioDataQualityGateEvaluation(),
        canonicalFieldOrder: [String] = Self.requiredCanonicalFieldOrder,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        exposesDatabaseSchema: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsRuntimeObject: Bool = false
    ) throws {
        guard canonicalFieldOrder == Self.requiredCanonicalFieldOrder else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReportInputVersion.canonicalFieldOrder",
                expected: Self.requiredCanonicalFieldOrder.joined(separator: ","),
                actual: canonicalFieldOrder.joined(separator: ",")
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReportInputVersion.sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
        guard replayEvidence.dataQualityGateInputIdentity == qualityEvaluation.replayInputIdentity,
              replayEvidence.replayWindow.deterministicWindowIdentity == qualityEvaluation.replayWindowIdentity else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReportInputVersion.qualityEvaluation",
                expected: replayEvidence.dataQualityGateInputIdentity,
                actual: qualityEvaluation.replayInputIdentity
            )
        }
        let forbiddenFlags = [
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsRuntimeObject", readsRuntimeObject)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioReportInputVersion.\(capability.0)"
            )
        }

        let replayWindow = replayEvidence.replayWindow
        self.contractID = contractID
        self.issueID = issueID
        self.scenarioID = replayWindow.scenarioID
        self.datasetVersion = replayWindow.datasetVersion
        self.fixtureVersion = replayWindow.fixtureVersion
        self.symbol = replayWindow.symbol
        self.timeframe = replayWindow.timeframe
        self.replayWindowIdentity = replayWindow.deterministicWindowIdentity
        self.replayWindowDescription = replayWindow.windowDescription
        self.checksum = replayEvidence.checksumEvidence.checksum
        self.freshnessStatus = replayEvidence.freshnessEvidence.status
        self.qualityVerdict = qualityEvaluation.qualityVerdict
        self.qualitySummary = qualityEvaluation.qualitySummary
        self.canonicalFieldOrder = canonicalFieldOrder
        self.versionIdentity = [
            replayWindow.scenarioID.rawValue,
            replayWindow.datasetVersion.rawValue,
            replayWindow.fixtureVersion.rawValue,
            replayWindow.windowDescription,
            replayEvidence.checksumEvidence.checksum,
            replayEvidence.freshnessEvidence.status.rawValue,
            qualityEvaluation.qualityVerdict.rawValue
        ].joined(separator: "|")
        self.sourceAnchors = sourceAnchors
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsRuntimeObject = readsRuntimeObject
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let expected = try ScenarioReportInputVersion()
        let scenarioID = try container.decode(ScenarioID.self, forKey: .scenarioID)
        let datasetVersion = try container.decode(DatasetVersion.self, forKey: .datasetVersion)
        let fixtureVersion = try container.decode(FixtureVersion.self, forKey: .fixtureVersion)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let replayWindowIdentity = try container.decode(String.self, forKey: .replayWindowIdentity)
        let replayWindowDescription = try container.decode(String.self, forKey: .replayWindowDescription)
        let checksum = try container.decode(String.self, forKey: .checksum)
        let freshnessStatus = try container.decode(ScenarioReplayFreshnessStatus.self, forKey: .freshnessStatus)
        let qualityVerdict = try container.decode(ScenarioDataQualityVerdict.self, forKey: .qualityVerdict)
        let qualitySummary = try container.decode(String.self, forKey: .qualitySummary)
        let versionIdentity = try container.decode(String.self, forKey: .versionIdentity)
        let decoded = try ScenarioReportInputVersion(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            canonicalFieldOrder: try container.decode([String].self, forKey: .canonicalFieldOrder),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsRuntimeObject: try container.decode(Bool.self, forKey: .readsRuntimeObject)
        )
        let decodedIdentity = [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            replayWindowDescription,
            checksum,
            freshnessStatus.rawValue,
            qualityVerdict.rawValue
        ].joined(separator: "|")
        guard decoded == expected,
              scenarioID == expected.scenarioID,
              datasetVersion == expected.datasetVersion,
              fixtureVersion == expected.fixtureVersion,
              symbol == expected.symbol,
              timeframe == expected.timeframe,
              replayWindowIdentity == expected.replayWindowIdentity,
              replayWindowDescription == expected.replayWindowDescription,
              checksum == expected.checksum,
              freshnessStatus == expected.freshnessStatus,
              qualityVerdict == expected.qualityVerdict,
              qualitySummary == expected.qualitySummary,
              versionIdentity == expected.versionIdentity else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReportInputVersion",
                expected: expected.versionIdentity,
                actual: "\(decodedIdentity); encodedVersionIdentity=\(versionIdentity)"
            )
        }
        self = decoded
    }

    public static let requiredCanonicalFieldOrder: [String] = [
        "scenarioID",
        "datasetVersion",
        "fixtureVersion",
        "replayWindow",
        "checksum",
        "freshnessStatus",
        "qualityVerdict"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
        "MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE",
        "MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION",
        "MTP-107-REPORT-INPUT-VERSIONING"
    ]
}

/// ScenarioDataQualityReportInputEvidence 是 MTP-107 的聚合 evidence fixture。
///
/// 该 fixture 把 MTP-106 replay evidence、MTP-107 quality gates 和 report input version 绑定到同一
/// deterministic identity。后续 MTP-108 App read model 可以消费这个聚合值，但不得读取 Core 之外的
/// persistence schema、adapter request、Runtime object 或任何 live / broker / trading command surface。
public struct ScenarioDataQualityReportInputEvidence: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let replayEvidence: ScenarioReplayEvidence
    public let qualityEvaluation: ScenarioDataQualityGateEvaluation
    public let reportInputVersion: ScenarioReportInputVersion
    public let validationAnchors: [String]
    public let reportReproducibilityEvidenceHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let buildsProductionDataPlatform: Bool
    public let runsProductionDataObservability: Bool
    public let performsAutomaticDownload: Bool
    public let performsAutomaticRepair: Bool
    public let performsBrokerAccountReconciliation: Bool
    public let implementsSimulatedExchangeBacktestParity: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsRuntimeObject: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var evidenceBoundaryHeld: Bool {
        replayEvidence.evidenceBoundaryHeld
            && qualityEvaluation.qualityGateBoundaryHeld
            && reportInputVersion.reportInputBoundaryHeld
            && reportInputVersion.versionIdentity.contains(reportInputVersion.checksum)
            && validationAnchors == ScenarioDataQualityGateEvaluation.requiredValidationAnchors
            && reportReproducibilityEvidenceHeld
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && buildsProductionDataPlatform == false
            && runsProductionDataObservability == false
            && performsAutomaticDownload == false
            && performsAutomaticRepair == false
            && performsBrokerAccountReconciliation == false
            && implementsSimulatedExchangeBacktestParity == false
            && exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && readsRuntimeObject == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-107-data-quality-report-input-evidence"),
        issueID: Identifier = try! Identifier("MTP-107"),
        replayEvidence: ScenarioReplayEvidence = .deterministicFixture,
        qualityEvaluation: ScenarioDataQualityGateEvaluation = try! ScenarioDataQualityGateEvaluation(),
        reportInputVersion: ScenarioReportInputVersion = try! ScenarioReportInputVersion(),
        validationAnchors: [String] = ScenarioDataQualityGateEvaluation.requiredValidationAnchors,
        reportReproducibilityEvidenceHeld: Bool = true,
        requiredValidationDependsOnNetwork: Bool = false,
        buildsProductionDataPlatform: Bool = false,
        runsProductionDataObservability: Bool = false,
        performsAutomaticDownload: Bool = false,
        performsAutomaticRepair: Bool = false,
        performsBrokerAccountReconciliation: Bool = false,
        implementsSimulatedExchangeBacktestParity: Bool = false,
        exposesDatabaseSchema: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsRuntimeObject: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        guard replayEvidence.dataQualityGateInputIdentity == qualityEvaluation.replayInputIdentity,
              reportInputVersion.versionIdentity.contains(qualityEvaluation.qualityVerdict.rawValue),
              reportInputVersion.qualitySummary == qualityEvaluation.qualitySummary else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityReportInputEvidence",
                expected: qualityEvaluation.qualitySummary,
                actual: reportInputVersion.qualitySummary
            )
        }
        guard validationAnchors == ScenarioDataQualityGateEvaluation.requiredValidationAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityReportInputEvidence.validationAnchors",
                expected: ScenarioDataQualityGateEvaluation.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard reportReproducibilityEvidenceHeld else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioDataQualityReportInputEvidence.reportReproducibilityEvidenceHeld",
                expected: "true",
                actual: "false"
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("buildsProductionDataPlatform", buildsProductionDataPlatform),
            ("runsProductionDataObservability", runsProductionDataObservability),
            ("performsAutomaticDownload", performsAutomaticDownload),
            ("performsAutomaticRepair", performsAutomaticRepair),
            ("performsBrokerAccountReconciliation", performsBrokerAccountReconciliation),
            ("implementsSimulatedExchangeBacktestParity", implementsSimulatedExchangeBacktestParity),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsRuntimeObject", readsRuntimeObject),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioDataQualityReportInputEvidence.\(capability.0)"
            )
        }

        self.contractID = contractID
        self.issueID = issueID
        self.replayEvidence = replayEvidence
        self.qualityEvaluation = qualityEvaluation
        self.reportInputVersion = reportInputVersion
        self.validationAnchors = validationAnchors
        self.reportReproducibilityEvidenceHeld = reportReproducibilityEvidenceHeld
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.buildsProductionDataPlatform = buildsProductionDataPlatform
        self.runsProductionDataObservability = runsProductionDataObservability
        self.performsAutomaticDownload = performsAutomaticDownload
        self.performsAutomaticRepair = performsAutomaticRepair
        self.performsBrokerAccountReconciliation = performsBrokerAccountReconciliation
        self.implementsSimulatedExchangeBacktestParity = implementsSimulatedExchangeBacktestParity
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsRuntimeObject = readsRuntimeObject
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            replayEvidence: try container.decode(ScenarioReplayEvidence.self, forKey: .replayEvidence),
            qualityEvaluation: try container.decode(ScenarioDataQualityGateEvaluation.self, forKey: .qualityEvaluation),
            reportInputVersion: try container.decode(ScenarioReportInputVersion.self, forKey: .reportInputVersion),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            reportReproducibilityEvidenceHeld: try container.decode(
                Bool.self,
                forKey: .reportReproducibilityEvidenceHeld
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            buildsProductionDataPlatform: try container.decode(Bool.self, forKey: .buildsProductionDataPlatform),
            runsProductionDataObservability: try container.decode(
                Bool.self,
                forKey: .runsProductionDataObservability
            ),
            performsAutomaticDownload: try container.decode(Bool.self, forKey: .performsAutomaticDownload),
            performsAutomaticRepair: try container.decode(Bool.self, forKey: .performsAutomaticRepair),
            performsBrokerAccountReconciliation: try container.decode(
                Bool.self,
                forKey: .performsBrokerAccountReconciliation
            ),
            implementsSimulatedExchangeBacktestParity: try container.decode(
                Bool.self,
                forKey: .implementsSimulatedExchangeBacktestParity
            ),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsRuntimeObject: try container.decode(Bool.self, forKey: .readsRuntimeObject),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    /// containsForbiddenCapabilityText 用于 focused tests 证明 report input identity 未混入禁区能力文本。
    public func containsForbiddenCapabilityText(_ forbiddenTokens: [String]) -> Bool {
        let serialized = [
            qualityEvaluation.replayInputIdentity,
            qualityEvaluation.qualitySummary,
            reportInputVersion.versionIdentity,
            reportInputVersion.qualitySummary
        ]
        .joined(separator: " ")
        .lowercased()

        return forbiddenTokens.contains { token in
            serialized.contains(token.lowercased())
        }
    }

    public static let deterministicFixture: ScenarioDataQualityReportInputEvidence = {
        do {
            return try ScenarioDataQualityReportInputEvidence()
        } catch {
            preconditionFailure("MTP-107 data quality report input evidence fixture must be valid: \(error)")
        }
    }()
}
