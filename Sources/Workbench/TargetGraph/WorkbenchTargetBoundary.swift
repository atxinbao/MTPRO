import Foundation

/// `Workbench` target boundary 表达 App read-model / ViewModel consumption layer。
///
/// MTP-221 只把 Workbench 拆为可构建 target，并保留 `App` compatibility export。
/// MTP-230 将 Workbench target path 收口到 `Sources/Workbench`，使 UI 只读 shell
/// 与 Workbench 编译归属位于同一真实模块 root。
/// Workbench 可以消费 Core / Persistence 导出的稳定 read model 和 projection snapshot，
/// 但不能直接读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、
/// broker state，也不能提供 Live PRO Console、trading button、live command 或 order form。
public struct WorkbenchTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoots: [String]
    public let compiledSourceRoots: [String]
    public let retainedCompatibilityEnvelope: String
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
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
        targetName: String = "Workbench",
        canonicalSourceRoots: [String] = Self.requiredCanonicalSourceRoots,
        compiledSourceRoots: [String] = Self.requiredCompiledSourceRoots,
        retainedCompatibilityEnvelope: String = "App",
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
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
        self.canonicalSourceRoots = canonicalSourceRoots
        self.compiledSourceRoots = compiledSourceRoots
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
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

    /// Workbench 只能消费 read model / ViewModel，不拥有 runtime 或 live command surface。
    public var dependencyDirectionHeld: Bool {
        targetName == "Workbench"
            && canonicalSourceRoots == Self.requiredCanonicalSourceRoots
            && compiledSourceRoots == Self.requiredCompiledSourceRoots
            && retainedCompatibilityEnvelope == "App"
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
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

    public static let requiredCanonicalSourceRoots = [
        "Sources/Workbench/ReadModels",
        "Sources/Workbench/Report",
        "Sources/Workbench/Dashboard",
        "Sources/Workbench/Events",
        "Sources/Workbench/FutureLiveProConsole",
        "Sources/Workbench/TargetGraph"
    ]

    public static let requiredCompiledSourceRoots = requiredCanonicalSourceRoots

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
        "MTP-221-WORKBENCH-TARGET-SPLIT",
        "MTP-221-READ-MODEL-VIEWMODEL-ONLY",
        "MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD",
        "MTP-230-WORKBENCH-REAL-ROOT-TARGET-PATH",
        "MTP-230-WORKBENCH-READ-MODEL-ONLY-ROOT"
    ]

    public static let mtp221 = WorkbenchTargetBoundary()
    public static let mtp230 = WorkbenchTargetBoundary()
}
