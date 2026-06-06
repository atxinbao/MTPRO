import Foundation

/// `Dashboard` executable target boundary 表达 read-model-only display surface。
///
/// Dashboard 直接拥有 ReadModels / Report / Events / FutureLiveProConsole 和 shell
/// snapshot，只消费 Core / Persistence 导出的稳定 read model 与 projection snapshot。
/// 它不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、
/// broker state，也不能提供 Live PRO Console、trading button、live command 或 order form。
public struct DashboardTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let shellSource: String
    public let compiledSourceRoots: [String]
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let displaySurfaceOnly: Bool
    public let consumesReadModelOnly: Bool
    public let consumesViewModelOnly: Bool
    public let exposesRuntimeObject: Bool
    public let readsAdapterRequest: Bool
    public let exposesPersistenceSchema: Bool
    public let exposesAccountPayload: Bool
    public let exposesBrokerState: Bool
    public let exposesLivePROConsole: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "Dashboard",
        canonicalSourceRoot: String = "Sources/Dashboard",
        shellSource: String = "Sources/Dashboard/DashboardShell.swift",
        compiledSourceRoots: [String] = Self.requiredCompiledSourceRoots,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        displaySurfaceOnly: Bool = true,
        consumesReadModelOnly: Bool = true,
        consumesViewModelOnly: Bool = true,
        exposesRuntimeObject: Bool = false,
        readsAdapterRequest: Bool = false,
        exposesPersistenceSchema: Bool = false,
        exposesAccountPayload: Bool = false,
        exposesBrokerState: Bool = false,
        exposesLivePROConsole: Bool = false,
        providesTradingButton: Bool = false,
        providesLiveCommand: Bool = false,
        exposesOrderForm: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.shellSource = shellSource
        self.compiledSourceRoots = compiledSourceRoots
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.displaySurfaceOnly = displaySurfaceOnly
        self.consumesReadModelOnly = consumesReadModelOnly
        self.consumesViewModelOnly = consumesViewModelOnly
        self.exposesRuntimeObject = exposesRuntimeObject
        self.readsAdapterRequest = readsAdapterRequest
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.exposesAccountPayload = exposesAccountPayload
        self.exposesBrokerState = exposesBrokerState
        self.exposesLivePROConsole = exposesLivePROConsole
        self.providesTradingButton = providesTradingButton
        self.providesLiveCommand = providesLiveCommand
        self.exposesOrderForm = exposesOrderForm
        self.validationAnchors = validationAnchors
    }

    /// Dashboard 只能承载只读展示模型，不越级读取 runtime / adapter / schema。
    public var dependencyDirectionHeld: Bool {
        targetName == "Dashboard"
            && canonicalSourceRoot == "Sources/Dashboard"
            && shellSource == "Sources/Dashboard/DashboardShell.swift"
            && compiledSourceRoots == Self.requiredCompiledSourceRoots
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && displaySurfaceOnly
            && consumesReadModelOnly
            && consumesViewModelOnly
            && exposesRuntimeObject == false
            && readsAdapterRequest == false
            && exposesPersistenceSchema == false
            && exposesAccountPayload == false
            && exposesBrokerState == false
            && exposesLivePROConsole == false
            && providesTradingButton == false
            && providesLiveCommand == false
            && exposesOrderForm == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "Core",
        "Persistence"
    ]

    public static let requiredForbiddenDependencies = [
        "Adapters",
        "Runtime",
        "DataClient",
        "DataEngine",
        "DatabaseSchema",
        "ExecutionClient",
        "ExecutionEngineRuntime",
        "TraderRuntime",
        "StrategyRuntime",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateWebSocketRuntime",
        "LiveCommandSurface",
        "OrderForm"
    ]

    public static let requiredValidationAnchors = [
        "MTP-221-DASHBOARD-TARGET-SPLIT",
        "MTP-221-DASHBOARD-READ-MODEL-VIEWMODEL-ONLY",
        "MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD",
        "MTP-230-DASHBOARD-REAL-ROOT-TARGET-PATH",
        "MTP-230-DASHBOARD-OWNS-READ-MODEL-SHELL",
        "MTP-DASHBOARD-WORKBENCH-TARGET-RETIRED",
        "GH-420-DASHBOARD-ACTIVE-SOURCE-NAMING-CLEAN"
    ]

    public static let requiredCompiledSourceRoots = [
        "Sources/Dashboard/DashboardApplication.swift",
        "Sources/Dashboard/DashboardTargetBoundary.swift",
        "Sources/Dashboard/DashboardShell.swift",
        "Sources/Dashboard/PaperWorkflowObservability.swift",
        "Sources/Dashboard/PaperWorkflowDashboardArchitecture.swift",
        "Sources/Dashboard/DashboardBetaAcceptancePath.swift",
        "Sources/Dashboard/DashboardBetaFirstRunState.swift",
        "Sources/Dashboard/ReadModels",
        "Sources/Dashboard/Report",
        "Sources/Dashboard/Events",
        "Sources/Dashboard/FutureLiveProConsole"
    ]

    public static let mtp221 = DashboardTargetBoundary()
    public static let mtp230 = DashboardTargetBoundary()
    public static let gh420 = DashboardTargetBoundary()
}
