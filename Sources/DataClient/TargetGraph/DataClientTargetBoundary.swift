import DomainModel

/// `DataClient` target boundary 表达交易所 public read-only 数据适配层。
///
/// MTP-227 把 active target boundary anchor 从 `Sources/TargetGraph/DataClient`
/// 移到 `Sources/DataClient/TargetGraph`。GH-396 起 Binance public market data
/// implementation 由 `DataClient` target 拥有；`Adapters` 只保留兼容 re-export。
/// 本 issue 不接 signed endpoint、account endpoint、listenKey、private stream runtime
/// 或 broker path。
public struct DataClientTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let publicReadOnlyBoundary: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBrokerOrExecutionAdapter: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "DataClient",
        canonicalSourceRoot: String = "Sources/DataClient",
        compiledBoundaryRoot: String = "Sources/DataClient/TargetGraph",
        retainedCompatibilityEnvelope: String = "Adapters(re-export only)",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        allowedDependencies: [String] = ["DomainModel"],
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        publicReadOnlyBoundary: Bool = true,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBrokerOrExecutionAdapter: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.publicReadOnlyBoundary = publicReadOnlyBoundary
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBrokerOrExecutionAdapter = connectsBrokerOrExecutionAdapter
        self.validationAnchors = validationAnchors
    }

    /// DataClient 只能是 public market data input boundary，不能升级成 execution adapter。
    public var dependencyDirectionHeld: Bool {
        targetName == "DataClient"
            && canonicalSourceRoot == "Sources/DataClient"
            && compiledBoundaryRoot == "Sources/DataClient/TargetGraph"
            && retainedCompatibilityEnvelope == "Adapters(re-export only)"
            && domainModelBoundary.boundaryHeld
            && allowedDependencies == ["DomainModel"]
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && publicReadOnlyBoundary
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBrokerOrExecutionAdapter == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredForbiddenDependencies = [
        "DataEngine",
        "Trader",
        "TraderStrategies",
        "RiskEngine",
        "ExecutionEngine",
        "ExecutionClient",
        "Workbench",
        "Dashboard",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateStreamRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-218-DATACLIENT-TARGET-SPLIT",
        "MTP-218-PUBLIC-READ-ONLY-DATA-BOUNDARY",
        "MTP-227-DATACLIENT-REAL-ROOT-TARGET-PATH",
        "MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD",
        "GH-395-DATACLIENT-REAL-TARGET-SMOKE",
        "GH-395-DATACLIENT-PUBLIC-READ-ONLY-SOURCE",
        "GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP",
        "GH-396-ADAPTERS-REEXPORT-ONLY"
    ]

    public static let mtp218 = DataClientTargetBoundary()
}
