import DomainModel

/// `DataClient` target boundary 表达交易所 public read-only 数据适配层。
///
/// MTP-218 只建立 `DataClient -> DomainModel` 的 SwiftPM target 方向。现有
/// Binance public market data implementation 仍由 `Adapters` compatibility envelope 编译，
/// 因为下游测试和旧 product 仍通过 `Adapters` 暴露当前 public data path。
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
        compiledBoundaryRoot: String = "Sources/TargetGraph/DataClient",
        retainedCompatibilityEnvelope: String = "Adapters",
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
            && compiledBoundaryRoot == "Sources/TargetGraph/DataClient"
            && retainedCompatibilityEnvelope == "Adapters"
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
        "MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD"
    ]

    public static let mtp218 = DataClientTargetBoundary()
}
