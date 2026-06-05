import Cache
import Database
import DomainModel
import MessageBus

/// `Portfolio` target boundary 表达独立于 Trader account context 的 financial state projection。
///
/// MTP-228 只把 active target boundary anchor 从 `Sources/TargetGraph/Portfolio`
/// 移到 `Sources/Portfolio/TargetGraph`。既有 Portfolio implementation 仍由 `Core`
/// compatibility envelope 编译，因为当前 paper projection tests 和旧 product 仍通过 `Core`
/// 使用这些类型。
public struct PortfolioTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let databaseBoundary: DatabaseTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let financialStateProjectionBoundary: Bool
    public let ownsAccountIdentity: Bool
    public let readsBrokerAccountState: Bool
    public let readsAccountEndpointPayload: Bool
    public let implementsPortfolioRuntime: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "Portfolio",
        canonicalSourceRoot: String = "Sources/Portfolio",
        compiledBoundaryRoot: String = "Sources/Portfolio/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        databaseBoundary: DatabaseTargetBoundary = .mtp217,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        financialStateProjectionBoundary: Bool = true,
        ownsAccountIdentity: Bool = false,
        readsBrokerAccountState: Bool = false,
        readsAccountEndpointPayload: Bool = false,
        implementsPortfolioRuntime: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.messageBusBoundary = messageBusBoundary
        self.cacheBoundary = cacheBoundary
        self.databaseBoundary = databaseBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.financialStateProjectionBoundary = financialStateProjectionBoundary
        self.ownsAccountIdentity = ownsAccountIdentity
        self.readsBrokerAccountState = readsBrokerAccountState
        self.readsAccountEndpointPayload = readsAccountEndpointPayload
        self.implementsPortfolioRuntime = implementsPortfolioRuntime
        self.validationAnchors = validationAnchors
    }

    /// Portfolio 只能保存 financial projection 语义，不能回收 Trader account context 或真实账户输入。
    public var dependencyDirectionHeld: Bool {
        targetName == "Portfolio"
            && canonicalSourceRoot == "Sources/Portfolio"
            && compiledBoundaryRoot == "Sources/Portfolio/TargetGraph"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && databaseBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && financialStateProjectionBoundary
            && ownsAccountIdentity == false
            && readsBrokerAccountState == false
            && readsAccountEndpointPayload == false
            && implementsPortfolioRuntime == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "Cache",
        "Database"
    ]

    public static let requiredForbiddenDependencies = [
        "Trader",
        "TraderStrategies",
        "RiskEngine",
        "ExecutionEngine",
        "ExecutionClient",
        "Workbench",
        "Dashboard",
        "Broker",
        "AccountEndpoint",
        "SignedEndpoint",
        "ListenKey",
        "PrivateStreamRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-219-PORTFOLIO-TARGET-SPLIT",
        "MTP-219-PORTFOLIO-SEPARATE-FROM-TRADER-ACCOUNT",
        "GH-397-PORTFOLIO-REAL-TARGET-SMOKE",
        "MTP-228-PORTFOLIO-REAL-ROOT-TARGET-PATH",
        "MTP-219-NO-REAL-ACCOUNT-BROKER-GUARD"
    ]

    public static let mtp219 = PortfolioTargetBoundary()
}
