import Foundation

/// Scenario fixture 合同固定 MTP-105 的第一个本地 deterministic scenario 输入。
///
/// 本文件只把 MTP-104 manifest 绑定到一组本地 `MarketBar` fixture records、fixture version、
/// fixed window、fixed record order 和 deterministic summary pre-structure。它不解析文件、不读取网络、
/// 不实现 replay cursor、最终 checksum / freshness evidence、production ingestion、signed/account/listenKey、
/// broker、LiveExecutionAdapter、live command 或交易按钮。

/// FixtureVersion 是本地 deterministic fixture 的稳定版本身份。
///
/// 它复用 `Identifier` 的非空校验，但独立于 dataset version：dataset version 标识 replay 输入版本，
/// fixture version 标识当前仓库内这组本地 fixture records 的版本。
public struct FixtureVersion: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        self.rawValue = try Identifier(rawValue, field: "fixtureVersion").rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

/// ScenarioFixtureSourceKind 说明 first scenario fixture 与现有 public read-only replay 证据的关系。
///
/// 当前唯一允许值是 Binance public read-only 的本地 fixture records。它不是真实网络下载、
/// adapter request、production dataset registry 或 broker / exchange execution source。
public enum ScenarioFixtureSourceKind: String, Codable, Equatable, Sendable {
    case binancePublicReadOnlyLocalFixture = "Binance public read-only local fixture"
}

/// ScenarioFixtureRecordOrderPolicy 固定 MTP-105 的 record order 判定方式。
///
/// first scenario 只允许按 interval start 严格升序排列，后续 replay cursor、checksum evidence 和
/// freshness evidence 仍归 MTP-106，不在这里实现。
public enum ScenarioFixtureRecordOrderPolicy: String, Codable, Equatable, Sendable {
    case fixedAscendingIntervalStart = "fixed ascending interval start"
}

/// ScenarioFixtureRecord 是 first scenario fixture 中的一条固定顺序行情记录。
///
/// `sequence` 是本地 fixture record order，不是 exchange sequence、broker sequence、event log sequence
/// 或 replay cursor。`bar` 只允许 public market data 语义，不包含账户、订单或执行能力。
public struct ScenarioFixtureRecord: Codable, Equatable, Sendable {
    public let sequence: Int
    public let bar: MarketBar
    public let sourceAnchor: String

    public init(
        sequence: Int,
        bar: MarketBar,
        sourceAnchor: String
    ) throws {
        guard sequence > 0 else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "fixtureRecord.sequence",
                expected: "positive sequence",
                actual: String(sequence)
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "fixtureRecord.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }

        self.sequence = sequence
        self.bar = bar
        self.sourceAnchor = sourceAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            sequence: try container.decode(Int.self, forKey: .sequence),
            bar: try container.decode(MarketBar.self, forKey: .bar),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor)
        )
    }

    /// deterministicToken 使用稳定字段顺序表达 record 内容，供 summary preimage 和 tests 比较。
    /// 该 token 不计算最终 checksum，也不表示 production data quality verdict。
    public var deterministicToken: String {
        [
            "sequence=\(sequence)",
            "symbol=\(bar.symbol.rawValue)",
            "timeframe=\(bar.timeframe.rawValue)",
            "window=\(Int(bar.interval.start.timeIntervalSince1970))...\(Int(bar.interval.end.timeIntervalSince1970))",
            "open=\(Self.scaledDecimalToken(bar.open.rawValue))",
            "high=\(Self.scaledDecimalToken(bar.high.rawValue))",
            "low=\(Self.scaledDecimalToken(bar.low.rawValue))",
            "close=\(Self.scaledDecimalToken(bar.close.rawValue))",
            "volume=\(Self.scaledDecimalToken(bar.volume.rawValue))",
            "sourceAnchor=\(sourceAnchor)"
        ].joined(separator: "|")
    }

    private static func scaledDecimalToken(_ value: Double) -> String {
        String(Int((value * 1_000_000).rounded()))
    }
}

/// ScenarioFixtureDeterministicSummary 是 MTP-105 的 deterministic summary pre-structure。
///
/// Summary 固定 record count、fixed window、ordered starts、record order identity 和 checksum preimage。
/// 它故意不输出最终 checksum、freshness verdict、replay cursor 或 data quality gate，避免越过 MTP-106
/// 和 MTP-107 的后续职责。
public struct ScenarioFixtureDeterministicSummary: Codable, Equatable, Sendable {
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let fixedWindow: DateRange
    public let recordCount: Int
    public let orderedRecordStarts: [Int]
    public let recordOrderIdentity: String
    public let canonicalRecordSummary: [String]
    public let checksumPreimage: String
    public let checksumEvidenceDeferredToMTP106: Bool
    public let sourceIdentity: String
    public let publicReadOnlyLocalFixtureRelationshipHeld: Bool
    public let dependsOnNetwork: Bool

    public init(
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        fixtureVersion: FixtureVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        fixedWindow: DateRange,
        canonicalRecordSummary: [String],
        sourceIdentity: String,
        publicReadOnlyLocalFixtureRelationshipHeld: Bool,
        dependsOnNetwork: Bool = false
    ) throws {
        guard canonicalRecordSummary.isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "deterministicSummary.canonicalRecordSummary",
                expected: "non-empty record summary",
                actual: "empty"
            )
        }
        guard publicReadOnlyLocalFixtureRelationshipHeld else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "deterministicSummary.publicReadOnlyLocalFixtureRelationshipHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard dependsOnNetwork == false else {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.dependsOnNetwork")
        }

        let orderedStarts = canonicalRecordSummary.map { token in
            Self.extractRecordStart(from: token)
        }

        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.fixedWindow = fixedWindow
        self.recordCount = canonicalRecordSummary.count
        self.orderedRecordStarts = orderedStarts
        self.recordOrderIdentity = orderedStarts
            .enumerated()
            .map { index, start in "\(index + 1):\(start)" }
            .joined(separator: "|")
        self.canonicalRecordSummary = canonicalRecordSummary
        self.checksumPreimage = canonicalRecordSummary.joined(separator: "\n")
        self.checksumEvidenceDeferredToMTP106 = true
        self.sourceIdentity = sourceIdentity
        self.publicReadOnlyLocalFixtureRelationshipHeld = publicReadOnlyLocalFixtureRelationshipHeld
        self.dependsOnNetwork = dependsOnNetwork
    }

    private static func extractRecordStart(from token: String) -> Int {
        guard let windowField = token.split(separator: "|").first(where: { $0.hasPrefix("window=") }),
              let startToken = windowField.dropFirst("window=".count).split(separator: ".").first,
              let start = Int(startToken) else {
            return -1
        }
        return start
    }
}

/// DeterministicScenarioFixture 是 MTP-105 的 first scenario fixture。
///
/// 它把 `ScenarioManifest.deterministicFixture`、fixture version、public-read-only local source、
/// fixed record order 和 deterministic summary pre-structure 固定为 Core 值对象。初始化和 Codable 解码
/// 都会重新校验 forbidden flags，防止 fixture 被恢复成真实网络下载、production ingestion、broker、
/// Live runtime、live command 或 trading button。
public struct DeterministicScenarioFixture: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let manifest: ScenarioManifest
    public let fixtureVersion: FixtureVersion
    public let sourceKind: ScenarioFixtureSourceKind
    public let sourceAnchor: String
    public let sourceRelationshipAnchors: [String]
    public let recordOrderPolicy: ScenarioFixtureRecordOrderPolicy
    public let records: [ScenarioFixtureRecord]
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let downloadsRealNetworkData: Bool
    public let runsProductionIngestionPipeline: Bool
    public let buildsCloudDataLake: Bool
    public let exposesAdapterRequest: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let usesMultipleSymbols: Bool
    public let usesMultipleTimeframes: Bool

    public var fixedWindow: DateRange {
        let first = records.first!.bar.interval.start
        let last = records.last!.bar.interval.end
        return try! DateRange(start: first, end: last)
    }

    public var deterministicSummary: ScenarioFixtureDeterministicSummary {
        try! ScenarioFixtureDeterministicSummary(
            scenarioID: manifest.scenarioID,
            datasetVersion: manifest.datasetVersion,
            fixtureVersion: fixtureVersion,
            symbol: manifest.symbol,
            timeframe: manifest.timeframe,
            fixedWindow: fixedWindow,
            canonicalRecordSummary: records.map(\.deterministicToken),
            sourceIdentity: manifest.deterministicSerialization.sourceIdentity,
            publicReadOnlyLocalFixtureRelationshipHeld: publicReadOnlyLocalFixtureRelationshipHeld,
            dependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }

    public var fixtureIdentityAlignedWithManifest: Bool {
        manifest == ScenarioManifest.deterministicFixture
            && manifest.singleSymbolSingleTimeframeBoundaryHeld
            && records.allSatisfy { record in
                record.bar.symbol == manifest.symbol
                    && record.bar.timeframe == manifest.timeframe
            }
    }

    public var fixedRecordOrderHeld: Bool {
        recordOrderPolicy == .fixedAscendingIntervalStart
            && records.map(\.sequence) == Array(1...records.count)
            && Self.recordStartsAreStrictlyAscending(records)
    }

    public var publicReadOnlyLocalFixtureRelationshipHeld: Bool {
        sourceKind == .binancePublicReadOnlyLocalFixture
            && sourceRelationshipAnchors == Self.requiredSourceRelationshipAnchors
            && requiredValidationDependsOnNetwork == false
            && downloadsRealNetworkData == false
            && exposesAdapterRequest == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && downloadsRealNetworkData == false
            && runsProductionIngestionPipeline == false
            && buildsCloudDataLake == false
            && exposesAdapterRequest == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && usesMultipleSymbols == false
            && usesMultipleTimeframes == false
    }

    public var fixtureBoundaryHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors
            && fixtureIdentityAlignedWithManifest
            && fixedRecordOrderHeld
            && deterministicSummary.checksumEvidenceDeferredToMTP106
            && publicReadOnlyLocalFixtureRelationshipHeld
            && forbiddenCapabilityBoundaryHeld
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-105-deterministic-scenario-fixture"),
        issueID: Identifier = try! Identifier("MTP-105"),
        manifest: ScenarioManifest = .deterministicFixture,
        fixtureVersion: FixtureVersion = try! FixtureVersion("fixture-v1"),
        sourceKind: ScenarioFixtureSourceKind = .binancePublicReadOnlyLocalFixture,
        sourceAnchor: String = "MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE",
        sourceRelationshipAnchors: [String] = Self.requiredSourceRelationshipAnchors,
        recordOrderPolicy: ScenarioFixtureRecordOrderPolicy = .fixedAscendingIntervalStart,
        records: [ScenarioFixtureRecord] = Self.deterministicRecords,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        downloadsRealNetworkData: Bool = false,
        runsProductionIngestionPipeline: Bool = false,
        buildsCloudDataLake: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        usesMultipleSymbols: Bool = false,
        usesMultipleTimeframes: Bool = false
    ) throws {
        try Self.validate(
            manifest: manifest,
            sourceAnchor: sourceAnchor,
            sourceRelationshipAnchors: sourceRelationshipAnchors,
            recordOrderPolicy: recordOrderPolicy,
            records: records,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsProductionIngestionPipeline: runsProductionIngestionPipeline,
            buildsCloudDataLake: buildsCloudDataLake,
            exposesAdapterRequest: exposesAdapterRequest,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            usesMultipleSymbols: usesMultipleSymbols,
            usesMultipleTimeframes: usesMultipleTimeframes
        )

        self.contractID = contractID
        self.issueID = issueID
        self.manifest = manifest
        self.fixtureVersion = fixtureVersion
        self.sourceKind = sourceKind
        self.sourceAnchor = sourceAnchor
        self.sourceRelationshipAnchors = sourceRelationshipAnchors
        self.recordOrderPolicy = recordOrderPolicy
        self.records = records
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.runsProductionIngestionPipeline = runsProductionIngestionPipeline
        self.buildsCloudDataLake = buildsCloudDataLake
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.usesMultipleSymbols = usesMultipleSymbols
        self.usesMultipleTimeframes = usesMultipleTimeframes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            manifest: try container.decode(ScenarioManifest.self, forKey: .manifest),
            fixtureVersion: try container.decode(FixtureVersion.self, forKey: .fixtureVersion),
            sourceKind: try container.decode(ScenarioFixtureSourceKind.self, forKey: .sourceKind),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            sourceRelationshipAnchors: try container.decode([String].self, forKey: .sourceRelationshipAnchors),
            recordOrderPolicy: try container.decode(ScenarioFixtureRecordOrderPolicy.self, forKey: .recordOrderPolicy),
            records: try container.decode([ScenarioFixtureRecord].self, forKey: .records),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            runsProductionIngestionPipeline: try container.decode(
                Bool.self,
                forKey: .runsProductionIngestionPipeline
            ),
            buildsCloudDataLake: try container.decode(Bool.self, forKey: .buildsCloudDataLake),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            usesMultipleSymbols: try container.decode(Bool.self, forKey: .usesMultipleSymbols),
            usesMultipleTimeframes: try container.decode(Bool.self, forKey: .usesMultipleTimeframes)
        )
    }

    /// containsForbiddenCapabilityText 用于 focused tests 验证 summary / source anchors 未混入禁区词。
    public func containsForbiddenCapabilityText(_ forbiddenTokens: [String]) -> Bool {
        let serialized = (
            records.map(\.deterministicToken)
                + validationAnchors
                + sourceRelationshipAnchors
                + [
                    contractID.rawValue,
                    issueID.rawValue,
                    sourceAnchor,
                    sourceKind.rawValue,
                    fixtureVersion.rawValue,
                    deterministicSummary.checksumPreimage
                ]
        )
        .joined(separator: " ")
        .lowercased()

        return forbiddenTokens.contains { token in
            serialized.contains(token.lowercased())
        }
    }

    public static let requiredSourceRelationshipAnchors: [String] = [
        "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
        "TVM-MARKET-DATA-REPLAY-OPERATIONS",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY",
        "Binance public read-only local fixture"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE",
        "MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR",
        "MTP-105-FIXED-WINDOW-RECORD-ORDER",
        "MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP",
        "MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE",
        "MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE",
        "MTP-105-SCENARIO-FIXTURE-VALIDATION",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY"
    ]

    public static let deterministicFixture: DeterministicScenarioFixture = {
        do {
            return try DeterministicScenarioFixture()
        } catch {
            preconditionFailure("MTP-105 deterministic scenario fixture must be valid: \(error)")
        }
    }()

    public static let deterministicRecords: [ScenarioFixtureRecord] = {
        do {
            let symbol = try Symbol(rawValue: "BTCUSDT")
            return [
                try ScenarioFixtureRecord(
                    sequence: 1,
                    bar: MarketBar(
                        symbol: symbol,
                        timeframe: .oneMinute,
                        interval: DateRange(
                            start: Date(timeIntervalSince1970: 1_704_067_200),
                            end: Date(timeIntervalSince1970: 1_704_067_260)
                        ),
                        open: 42_000.10,
                        high: 42_100.20,
                        low: 41_900.30,
                        close: 42_050.40,
                        volume: 12.345
                    ),
                    sourceAnchor: "MTP-105-FIXED-WINDOW-RECORD-ORDER"
                ),
                try ScenarioFixtureRecord(
                    sequence: 2,
                    bar: MarketBar(
                        symbol: symbol,
                        timeframe: .oneMinute,
                        interval: DateRange(
                            start: Date(timeIntervalSince1970: 1_704_067_260),
                            end: Date(timeIntervalSince1970: 1_704_067_320)
                        ),
                        open: 42_050.40,
                        high: 42_180.10,
                        low: 42_010.00,
                        close: 42_120.70,
                        volume: 10.500
                    ),
                    sourceAnchor: "MTP-105-FIXED-WINDOW-RECORD-ORDER"
                ),
                try ScenarioFixtureRecord(
                    sequence: 3,
                    bar: MarketBar(
                        symbol: symbol,
                        timeframe: .oneMinute,
                        interval: DateRange(
                            start: Date(timeIntervalSince1970: 1_704_067_320),
                            end: Date(timeIntervalSince1970: 1_704_067_380)
                        ),
                        open: 42_120.70,
                        high: 42_140.00,
                        low: 42_000.50,
                        close: 42_020.90,
                        volume: 9.875
                    ),
                    sourceAnchor: "MTP-105-FIXED-WINDOW-RECORD-ORDER"
                )
            ]
        } catch {
            preconditionFailure("MTP-105 deterministic scenario records must be valid: \(error)")
        }
    }()

    private static func validate(
        manifest: ScenarioManifest,
        sourceAnchor: String,
        sourceRelationshipAnchors: [String],
        recordOrderPolicy: ScenarioFixtureRecordOrderPolicy,
        records: [ScenarioFixtureRecord],
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        downloadsRealNetworkData: Bool,
        runsProductionIngestionPipeline: Bool,
        buildsCloudDataLake: Bool,
        exposesAdapterRequest: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        usesMultipleSymbols: Bool,
        usesMultipleTimeframes: Bool
    ) throws {
        guard manifest == ScenarioManifest.deterministicFixture else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.manifest",
                expected: ScenarioManifest.deterministicFixture.scenarioID.rawValue,
                actual: manifest.scenarioID.rawValue
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        guard sourceRelationshipAnchors == Self.requiredSourceRelationshipAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.sourceRelationshipAnchors",
                expected: Self.requiredSourceRelationshipAnchors.joined(separator: ","),
                actual: sourceRelationshipAnchors.joined(separator: ",")
            )
        }
        guard recordOrderPolicy == .fixedAscendingIntervalStart else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.recordOrderPolicy",
                expected: ScenarioFixtureRecordOrderPolicy.fixedAscendingIntervalStart.rawValue,
                actual: recordOrderPolicy.rawValue
            )
        }
        guard records.isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.records",
                expected: "non-empty fixture records",
                actual: "empty"
            )
        }
        guard records.map(\.sequence) == Array(1...records.count) else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.recordSequence",
                expected: Array(1...records.count).map(String.init).joined(separator: ","),
                actual: records.map(\.sequence).map(String.init).joined(separator: ",")
            )
        }
        guard recordStartsAreStrictlyAscending(records) else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.recordOrder",
                expected: "strictly ascending interval starts",
                actual: records.map { String(Int($0.bar.interval.start.timeIntervalSince1970)) }.joined(separator: ",")
            )
        }
        for record in records {
            guard record.bar.symbol == manifest.symbol else {
                throw CoreError.marketDataMismatch(
                    field: "scenarioFixture.record.symbol",
                    expected: manifest.symbol.rawValue,
                    actual: record.bar.symbol.rawValue
                )
            }
            guard record.bar.timeframe == manifest.timeframe else {
                throw CoreError.marketDataMismatch(
                    field: "scenarioFixture.record.timeframe",
                    expected: manifest.timeframe.rawValue,
                    actual: record.bar.timeframe.rawValue
                )
            }
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioFixture.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("downloadsRealNetworkData", downloadsRealNetworkData),
            ("runsProductionIngestionPipeline", runsProductionIngestionPipeline),
            ("buildsCloudDataLake", buildsCloudDataLake),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton),
            ("usesMultipleSymbols", usesMultipleSymbols),
            ("usesMultipleTimeframes", usesMultipleTimeframes)
        ]

        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.\(capability.0)")
        }
    }

    private static func recordStartsAreStrictlyAscending(_ records: [ScenarioFixtureRecord]) -> Bool {
        var previousStart: Date?
        for record in records {
            let currentStart = record.bar.interval.start
            if let previousStart, currentStart <= previousStart {
                return false
            }
            previousStart = currentStart
        }
        return true
    }
}
