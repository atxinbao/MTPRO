import Foundation

/// Scenario manifest 合同固定 MTP-104 的本地 scenario 输入身份。
///
/// 本文件只定义 scenario id、dataset version、single-symbol / single-timeframe manifest 和
/// deterministic serialization evidence。它不解析 manifest 文件、不新增 fixture 数据、不实现 replay cursor、
/// 不暴露数据库 schema 或 adapter request，也不接 signed/account/listenKey、broker、live runtime 或 order command。

/// ScenarioID 是本地 scenario replay 的稳定场景标识。
///
/// 它复用 Core `Identifier` 的非空校验，但用独立类型表达语义边界，避免把数据库主键、
/// runtime job id、broker/order id 或 UI selection id 误当成 replay 输入身份。
public struct ScenarioID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        self.rawValue = try Identifier(rawValue, field: "scenarioID").rawValue
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

/// DatasetVersion 是 scenario replay 输入数据版本的本地合同。
///
/// 它不是 production dataset registry、cloud data lake version 或外部 catalog service version；
/// 当前只作为 fixture / replay / report input 后续路径可消费的稳定字符串身份。
public struct DatasetVersion: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        self.rawValue = try Identifier(rawValue, field: "datasetVersion").rawValue
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

/// ScenarioManifestScope 固定 MTP-104 的 first scenario 约束。
///
/// 当前只允许 single-symbol / single-timeframe 输入身份；多 symbol、多 timeframe catalog 仍归后续
/// 独立 issue 或 Project，不得从 manifest 合同偷渡。
public enum ScenarioManifestScope: String, Codable, Equatable, Sendable {
    case singleSymbolSingleTimeframe = "single-symbol / single-timeframe"
}

/// ScenarioManifestDeterministicSerialization 是 manifest 的稳定序列化证据。
///
/// 该值只保存可比较的 identity fields 和固定字段顺序，供 tests、fixture、replay 和 report input
/// 后续消费；它不读取文件、不计算 checksum、不暴露 SQLite / DuckDB schema 或 adapter payload。
public struct ScenarioManifestDeterministicSerialization: Codable, Equatable, Sendable {
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let sourceAnchor: String
    public let scope: ScenarioManifestScope
    public let canonicalFieldOrder: [String]

    public init(
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        sourceAnchor: String,
        scope: ScenarioManifestScope,
        canonicalFieldOrder: [String] = Self.requiredCanonicalFieldOrder
    ) throws {
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "serialization.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        guard scope == .singleSymbolSingleTimeframe else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "serialization.scope",
                expected: ScenarioManifestScope.singleSymbolSingleTimeframe.rawValue,
                actual: scope.rawValue
            )
        }
        guard canonicalFieldOrder == Self.requiredCanonicalFieldOrder else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "serialization.canonicalFieldOrder",
                expected: Self.requiredCanonicalFieldOrder.joined(separator: ","),
                actual: canonicalFieldOrder.joined(separator: ",")
            )
        }

        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.sourceAnchor = sourceAnchor
        self.scope = scope
        self.canonicalFieldOrder = canonicalFieldOrder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            scenarioID: try container.decode(ScenarioID.self, forKey: .scenarioID),
            datasetVersion: try container.decode(DatasetVersion.self, forKey: .datasetVersion),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            scope: try container.decode(ScenarioManifestScope.self, forKey: .scope),
            canonicalFieldOrder: try container.decode([String].self, forKey: .canonicalFieldOrder)
        )
    }

    public var sourceIdentity: String {
        [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            symbol.rawValue,
            timeframe.rawValue,
            sourceAnchor,
            scope.rawValue
        ].joined(separator: "|")
    }

    public static let requiredCanonicalFieldOrder: [String] = [
        "scenarioID",
        "datasetVersion",
        "symbol",
        "timeframe",
        "sourceAnchor",
        "scope"
    ]
}

/// ScenarioManifest 是 MTP-104 的最小 scenario manifest 值合同。
///
/// manifest 只表达本地输入身份：scenario id、dataset version、symbol、timeframe、source anchor
/// 和 single-symbol / single-timeframe scope。初始化和 Codable 解码都会重新校验 forbidden flags，
/// 防止 payload 恢复数据库 schema、adapter request、secret、signed/account/listenKey、broker、
/// live runtime 或 order command 能力。
public struct ScenarioManifest: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let sourceAnchor: String
    public let scope: ScenarioManifestScope
    public let validationAnchors: [String]
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let providesOrderCommand: Bool
    public let runsLiveRuntime: Bool
    public let registersProductionDataset: Bool
    public let downloadsRealNetworkData: Bool
    public let usesMultipleSymbols: Bool
    public let usesMultipleTimeframes: Bool

    public var singleSymbolSingleTimeframeBoundaryHeld: Bool {
        scope == .singleSymbolSingleTimeframe
            && usesMultipleSymbols == false
            && usesMultipleTimeframes == false
    }

    public var manifestBoundaryHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors
            && sourceAnchor.isEmpty == false
            && singleSymbolSingleTimeframeBoundaryHeld
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && providesOrderCommand == false
            && runsLiveRuntime == false
            && registersProductionDataset == false
            && downloadsRealNetworkData == false
    }

    public var deterministicSerialization: ScenarioManifestDeterministicSerialization {
        try! ScenarioManifestDeterministicSerialization(
            scenarioID: scenarioID,
            datasetVersion: datasetVersion,
            symbol: symbol,
            timeframe: timeframe,
            sourceAnchor: sourceAnchor,
            scope: scope,
            canonicalFieldOrder: ScenarioManifestDeterministicSerialization.requiredCanonicalFieldOrder
        )
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-104-scenario-manifest-contract"),
        issueID: Identifier = try! Identifier("MTP-104"),
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        sourceAnchor: String,
        scope: ScenarioManifestScope = .singleSymbolSingleTimeframe,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        exposesDatabaseSchema: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        providesOrderCommand: Bool = false,
        runsLiveRuntime: Bool = false,
        registersProductionDataset: Bool = false,
        downloadsRealNetworkData: Bool = false,
        usesMultipleSymbols: Bool = false,
        usesMultipleTimeframes: Bool = false
    ) throws {
        try Self.validate(
            sourceAnchor: sourceAnchor,
            scope: scope,
            validationAnchors: validationAnchors,
            exposesDatabaseSchema: exposesDatabaseSchema,
            exposesAdapterRequest: exposesAdapterRequest,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            providesOrderCommand: providesOrderCommand,
            runsLiveRuntime: runsLiveRuntime,
            registersProductionDataset: registersProductionDataset,
            downloadsRealNetworkData: downloadsRealNetworkData,
            usesMultipleSymbols: usesMultipleSymbols,
            usesMultipleTimeframes: usesMultipleTimeframes
        )

        self.contractID = contractID
        self.issueID = issueID
        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.sourceAnchor = sourceAnchor
        self.scope = scope
        self.validationAnchors = validationAnchors
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.providesOrderCommand = providesOrderCommand
        self.runsLiveRuntime = runsLiveRuntime
        self.registersProductionDataset = registersProductionDataset
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.usesMultipleSymbols = usesMultipleSymbols
        self.usesMultipleTimeframes = usesMultipleTimeframes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            scenarioID: try container.decode(ScenarioID.self, forKey: .scenarioID),
            datasetVersion: try container.decode(DatasetVersion.self, forKey: .datasetVersion),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            scope: try container.decode(ScenarioManifestScope.self, forKey: .scope),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            providesOrderCommand: try container.decode(Bool.self, forKey: .providesOrderCommand),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            registersProductionDataset: try container.decode(Bool.self, forKey: .registersProductionDataset),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            usesMultipleSymbols: try container.decode(Bool.self, forKey: .usesMultipleSymbols),
            usesMultipleTimeframes: try container.decode(Bool.self, forKey: .usesMultipleTimeframes)
        )
    }

    public static let canonicalSerializationFieldOrder: [String] =
        ScenarioManifestDeterministicSerialization.requiredCanonicalFieldOrder

    public static let requiredValidationAnchors: [String] = [
        "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
        "MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY",
        "MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST",
        "MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION",
        "MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY",
        "MTP-104-SCENARIO-MANIFEST-VALIDATION",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY"
    ]

    public static let deterministicFixture: ScenarioManifest = {
        do {
            return try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS"
            )
        } catch {
            preconditionFailure("MTP-104 scenario manifest fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        sourceAnchor: String,
        scope: ScenarioManifestScope,
        validationAnchors: [String],
        exposesDatabaseSchema: Bool,
        exposesAdapterRequest: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        providesOrderCommand: Bool,
        runsLiveRuntime: Bool,
        registersProductionDataset: Bool,
        downloadsRealNetworkData: Bool,
        usesMultipleSymbols: Bool,
        usesMultipleTimeframes: Bool
    ) throws {
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        guard scope == .singleSymbolSingleTimeframe else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scope",
                expected: ScenarioManifestScope.singleSymbolSingleTimeframe.rawValue,
                actual: scope.rawValue
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("providesOrderCommand", providesOrderCommand),
            ("runsLiveRuntime", runsLiveRuntime),
            ("registersProductionDataset", registersProductionDataset),
            ("downloadsRealNetworkData", downloadsRealNetworkData),
            ("usesMultipleSymbols", usesMultipleSymbols),
            ("usesMultipleTimeframes", usesMultipleTimeframes)
        ]

        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.\(capability.0)")
        }
    }
}
