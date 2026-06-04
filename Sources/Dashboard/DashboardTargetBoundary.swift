import Foundation
import Workbench

/// `Dashboard` executable target boundary 表达 Workbench read-model-only display surface。
///
/// Dashboard 只能启动 macOS shell / smoke summary，并消费 Workbench 导出的
/// `DashboardViewModel` 与 `DashboardShellSnapshot`。它不直接依赖 Core、Persistence、
/// Runtime、Adapters、ExecutionClient、broker、OMS、schema、account payload 或 live command。
/// MTP-230 后 Dashboard executable 只保留应用入口 / target boundary，shell snapshot
/// 由 Workbench 真实 root 编译并作为只读 ViewModel 展示 API 输出。
public struct DashboardTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let shellSource: String
    public let workbenchBoundary: WorkbenchTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let displaySurfaceOnly: Bool
    public let consumesWorkbenchOnly: Bool
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
        shellSource: String = "Sources/Workbench/Dashboard/DashboardShell.swift",
        workbenchBoundary: WorkbenchTargetBoundary = .mtp230,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        displaySurfaceOnly: Bool = true,
        consumesWorkbenchOnly: Bool = true,
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
        self.workbenchBoundary = workbenchBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.displaySurfaceOnly = displaySurfaceOnly
        self.consumesWorkbenchOnly = consumesWorkbenchOnly
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

    /// Dashboard 只能依赖 Workbench 展示模型，不越级读取 runtime / adapter / schema。
    public var dependencyDirectionHeld: Bool {
        targetName == "Dashboard"
            && canonicalSourceRoot == "Sources/Dashboard"
            && shellSource == "Sources/Workbench/Dashboard/DashboardShell.swift"
            && workbenchBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && displaySurfaceOnly
            && consumesWorkbenchOnly
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
        "Workbench"
    ]

    public static let requiredForbiddenDependencies = [
        "Core",
        "Persistence",
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
        "MTP-221-DASHBOARD-CONSUMES-WORKBENCH-ONLY",
        "MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD",
        "MTP-230-DASHBOARD-REAL-ROOT-TARGET-PATH",
        "MTP-230-DASHBOARD-CONSUMES-WORKBENCH-SHELL-ONLY"
    ]

    public static let mtp221 = DashboardTargetBoundary()
    public static let mtp230 = DashboardTargetBoundary()
}
