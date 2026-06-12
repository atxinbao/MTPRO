import Core
import Foundation

/// ReleaseV020DashboardControlPanel 固定 GH-594 Dashboard 必须展示的 release v0.2.0 控制面板。
///
/// 这些 panel 只是 read-model / view-model 层的产品控制面证据。它们不等于 SwiftUI Button、
/// broker command、ExecutionClient call、OMS mutation、signed endpoint 或真实 submit / cancel /
/// replace action。
public enum ReleaseV020DashboardControlPanel: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spot
    case perp
    case ema
    case rsi
    case risk
    case oms
    case portfolio

    public var dashboardLabel: String {
        switch self {
        case .spot:
            return "Spot"
        case .perp:
            return "Perp"
        case .ema:
            return "EMA"
        case .rsi:
            return "RSI"
        case .risk:
            return "Risk"
        case .oms:
            return "OMS"
        case .portfolio:
            return "Portfolio"
        }
    }
}

/// ReleaseV020DashboardStrategyPanel 固定 release v0.2.0 Dashboard 可展示的 active strategies。
///
/// Dashboard 只能展示 EMA / RSI 状态和 gate 证据，不创建第三 active strategy，也不拥有
/// Strategy runtime lifecycle。
public enum ReleaseV020DashboardStrategyPanel: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema
    case rsi
}

/// ReleaseV020DashboardCommandMode 固定 GH-594 command entry 的可见 gate 模式。
///
/// 默认模式必须是 `noTrade`；`dryRun` 与 `testnet` 只是 gate label，`productionDisabled`
/// 只解释 production command 默认关闭。
public enum ReleaseV020DashboardCommandMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noTrade = "no-trade"
    case dryRun = "dry-run"
    case testnet = "testnet"
    case productionDisabled = "production disabled"
}

/// ReleaseV020DashboardCommandGatewayPanelViewModel 是单个 Dashboard panel 的 CommandGateway gate 证据。
///
/// 每个 panel 都必须声明 CommandGateway route、Risk / Execution / OMS / Event Store /
/// kill switch / no-trade gate，并保持 command entry 默认 disabled。
public struct ReleaseV020DashboardCommandGatewayPanelViewModel: Codable, Equatable, Sendable {
    public let panel: ReleaseV020DashboardControlPanel
    public let dashboardLabel: String
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV020DashboardStrategyPanel]
    public let commandGatewayRoute: String
    public let defaultMode: ReleaseV020DashboardCommandMode
    public let visibleModes: [ReleaseV020DashboardCommandMode]
    public let commandEntryVisible: Bool
    public let commandEntryEnabled: Bool
    public let productionCommandEnabled: Bool
    public let routesThroughCommandGateway: Bool
    public let riskEngineGateRequired: Bool
    public let executionEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let eventStoreGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let noTradeStateRequired: Bool
    public let disabledReason: String
    public let sourceEvidenceAnchor: String
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointTouched: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let bypassesCommandGateway: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool
    public let authorizesTradingExecution: Bool

    public init(
        panel: ReleaseV020DashboardControlPanel,
        productTypes: [ProductType]? = nil,
        strategies: [ReleaseV020DashboardStrategyPanel]? = nil,
        commandGatewayRoute: String? = nil,
        defaultMode: ReleaseV020DashboardCommandMode = .noTrade,
        visibleModes: [ReleaseV020DashboardCommandMode] = ReleaseV020DashboardCommandMode.allCases,
        commandEntryVisible: Bool = true,
        commandEntryEnabled: Bool = false,
        productionCommandEnabled: Bool = false,
        routesThroughCommandGateway: Bool = true,
        riskEngineGateRequired: Bool = true,
        executionEngineGateRequired: Bool = true,
        omsGateRequired: Bool = true,
        eventStoreGateRequired: Bool = true,
        killSwitchGateRequired: Bool = true,
        noTradeStateRequired: Bool = true,
        disabledReason: String? = nil,
        sourceEvidenceAnchor: String? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        bypassesCommandGateway: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesExecutionEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeState: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        let resolvedProducts = Self.normalizedProducts(productTypes ?? Self.defaultProductTypes(for: panel))
        let resolvedStrategies = Self.normalizedStrategies(strategies ?? Self.defaultStrategies(for: panel))
        let resolvedRoute = commandGatewayRoute ?? "command-gateway/release-v0.2.0/\(panel.rawValue)"
        let resolvedAnchor = sourceEvidenceAnchor ?? "GH-594-\(panel.rawValue.uppercased())-DASHBOARD-COMMANDGATEWAY"

        guard resolvedProducts.isEmpty == false,
              Set(resolvedProducts).isSubset(of: Set(ProductType.allCases)),
              resolvedProducts.count == Set(resolvedProducts).count,
              resolvedStrategies.isEmpty == false,
              Set(resolvedStrategies).isSubset(of: Set(ReleaseV020DashboardStrategyPanel.allCases)),
              resolvedStrategies.count == Set(resolvedStrategies).count,
              resolvedRoute.hasPrefix("command-gateway/release-v0.2.0/"),
              defaultMode == .noTrade,
              visibleModes == ReleaseV020DashboardCommandMode.allCases,
              commandEntryVisible,
              commandEntryEnabled == false,
              productionCommandEnabled == false,
              routesThroughCommandGateway,
              riskEngineGateRequired,
              executionEngineGateRequired,
              omsGateRequired,
              eventStoreGateRequired,
              killSwitchGateRequired,
              noTradeStateRequired,
              resolvedAnchor.hasPrefix("GH-594-") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020DashboardCommandGatewaySurface.panel",
                expected: "read-only Dashboard panel routed through CommandGateway with disabled production command",
                actual: panel.rawValue
            )
        }

        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("productionEndpointTouched", productionEndpointTouched),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("bypassesCommandGateway", bypassesCommandGateway),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("bypassesExecutionEngine", bypassesExecutionEngine),
            ("bypassesOMS", bypassesOMS),
            ("bypassesEventStore", bypassesEventStore),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("bypassesNoTradeState", bypassesNoTradeState),
            ("authorizesTradingExecution", authorizesTradingExecution)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020DashboardCommandGatewaySurface.\(forbiddenFlag.0)"
            )
        }

        self.panel = panel
        self.dashboardLabel = panel.dashboardLabel
        self.productTypes = resolvedProducts
        self.strategies = resolvedStrategies
        self.commandGatewayRoute = resolvedRoute
        self.defaultMode = defaultMode
        self.visibleModes = visibleModes
        self.commandEntryVisible = commandEntryVisible
        self.commandEntryEnabled = commandEntryEnabled
        self.productionCommandEnabled = productionCommandEnabled
        self.routesThroughCommandGateway = routesThroughCommandGateway
        self.riskEngineGateRequired = riskEngineGateRequired
        self.executionEngineGateRequired = executionEngineGateRequired
        self.omsGateRequired = omsGateRequired
        self.eventStoreGateRequired = eventStoreGateRequired
        self.killSwitchGateRequired = killSwitchGateRequired
        self.noTradeStateRequired = noTradeStateRequired
        self.disabledReason = disabledReason
            ?? "\(panel.dashboardLabel) command entry remains disabled; Dashboard routes only through CommandGateway evidence."
        self.sourceEvidenceAnchor = resolvedAnchor
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointTouched = productionEndpointTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.bypassesCommandGateway = bypassesCommandGateway
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesExecutionEngine = bypassesExecutionEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesEventStore = bypassesEventStore
        self.bypassesKillSwitch = bypassesKillSwitch
        self.bypassesNoTradeState = bypassesNoTradeState
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var panelBoundaryHeld: Bool {
        productTypes.isEmpty == false
            && Set(productTypes).isSubset(of: Set(ProductType.allCases))
            && productTypes.count == Set(productTypes).count
            && strategies.isEmpty == false
            && Set(strategies).isSubset(of: Set(ReleaseV020DashboardStrategyPanel.allCases))
            && strategies.count == Set(strategies).count
            && commandGatewayRoute.hasPrefix("command-gateway/release-v0.2.0/")
            && defaultMode == .noTrade
            && visibleModes == ReleaseV020DashboardCommandMode.allCases
            && commandEntryVisible
            && commandEntryEnabled == false
            && productionCommandEnabled == false
            && routesThroughCommandGateway
            && riskEngineGateRequired
            && executionEngineGateRequired
            && omsGateRequired
            && eventStoreGateRequired
            && killSwitchGateRequired
            && noTradeStateRequired
            && disabledReason.contains("CommandGateway")
            && sourceEvidenceAnchor.hasPrefix("GH-594-")
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointTouched == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && bypassesCommandGateway == false
            && bypassesRiskEngine == false
            && bypassesExecutionEngine == false
            && bypassesOMS == false
            && bypassesEventStore == false
            && bypassesKillSwitch == false
            && bypassesNoTradeState == false
            && authorizesTradingExecution == false
    }

    private static func defaultProductTypes(for panel: ReleaseV020DashboardControlPanel) -> [ProductType] {
        switch panel {
        case .spot:
            return [.spot]
        case .perp:
            return [.usdsPerpetual]
        case .ema, .rsi, .risk, .oms, .portfolio:
            return ProductType.allCases
        }
    }

    private static func defaultStrategies(
        for panel: ReleaseV020DashboardControlPanel
    ) -> [ReleaseV020DashboardStrategyPanel] {
        switch panel {
        case .ema:
            return [.ema]
        case .rsi:
            return [.rsi]
        case .spot, .perp, .risk, .oms, .portfolio:
            return ReleaseV020DashboardStrategyPanel.allCases
        }
    }

    private static func normalizedProducts(_ productTypes: [ProductType]) -> [ProductType] {
        productTypes.sorted { $0.rawValue < $1.rawValue }
    }

    private static func normalizedStrategies(
        _ strategies: [ReleaseV020DashboardStrategyPanel]
    ) -> [ReleaseV020DashboardStrategyPanel] {
        strategies.sorted { $0.rawValue < $1.rawValue }
    }
}

/// ReleaseV020DashboardCommandGatewaySurfaceReadModel 汇总 GH-594 Dashboard 控制面输入。
///
/// 它只描述 Dashboard 可展示的 Spot / Perp / EMA / RSI / Risk / OMS / Portfolio
/// panel 与 CommandGateway routing gate，不包含 secret、endpoint、broker session、OMS store、
/// order payload 或 production command authorization。
/// `GH-594-DASHBOARD-COMMANDGATEWAY-SURFACE`
public struct ReleaseV020DashboardCommandGatewaySurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let panels: [ReleaseV020DashboardCommandGatewayPanelViewModel]
    public let validationAnchors: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        panels: [ReleaseV020DashboardCommandGatewayPanelViewModel] = Self.requiredPanels,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.panels = panels.sortedByReleaseV020DashboardPanelOrder()
        self.validationAnchors = validationAnchors
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var dashboardSurfaceBoundaryHeld: Bool {
        source.isReadModelOnly
            && panels.map(\.panel) == ReleaseV020DashboardControlPanel.allCases
            && panels.allSatisfy(\.panelBoundaryHeld)
            && Set(productTypesCovered) == Set(ProductType.allCases)
            && Set(strategiesCovered) == Set(ReleaseV020DashboardStrategyPanel.allCases)
            && dashboardLabels == ReleaseV020DashboardControlPanel.allCases.map(\.dashboardLabel)
            && commandsRouteThroughCommandGateway
            && productionCommandDisabledByDefault
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var dashboardLabels: [String] {
        panels.map(\.dashboardLabel)
    }

    public var productTypesCovered: [ProductType] {
        panels.flatMap(\.productTypes).uniquePreservingOrder().sorted { $0.rawValue < $1.rawValue }
    }

    public var strategiesCovered: [ReleaseV020DashboardStrategyPanel] {
        panels.flatMap(\.strategies).uniquePreservingOrder().sorted { $0.rawValue < $1.rawValue }
    }

    public var commandsRouteThroughCommandGateway: Bool {
        panels.allSatisfy(\.routesThroughCommandGateway)
            && panels.allSatisfy { $0.commandGatewayRoute.hasPrefix("command-gateway/release-v0.2.0/") }
    }

    public var productionCommandDisabledByDefault: Bool {
        panels.allSatisfy { $0.productionCommandEnabled == false && $0.defaultMode == .noTrade }
    }

    public static let requiredValidationAnchors = [
        "GH-594-DASHBOARD-COMMANDGATEWAY-SURFACE",
        "GH-594-SPOT-PERP-EMA-RSI-RISK-OMS-PORTFOLIO-PANELS",
        "GH-594-COMMANDGATEWAY-ROUTING-GATE",
        "GH-594-PRODUCTION-COMMAND-DISABLED-BY-DEFAULT",
        "GH-594-NO-RISK-EXECUTION-OMS-EVENTSTORE-BYPASS",
        "TVM-RELEASE-V020-DASHBOARD-COMMANDGATEWAY-SURFACE"
    ]

    public static let requiredPanels: [ReleaseV020DashboardCommandGatewayPanelViewModel] =
        ReleaseV020DashboardControlPanel.allCases.map { panel in
            do {
                return try ReleaseV020DashboardCommandGatewayPanelViewModel(panel: panel)
            } catch {
                preconditionFailure("Invalid release v0.2.0 dashboard panel fixture: \(error)")
            }
        }
}

/// ReleaseV020DashboardCommandGatewaySurfaceViewModel 是 GH-594 Dashboard 可渲染摘要。
///
/// ViewModel 可以展示产品、策略、risk、OMS、Portfolio panel 和 CommandGateway route；
/// 它不提供 live command、trading button、order form、secret editor 或真实 broker action。
public struct ReleaseV020DashboardCommandGatewaySurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let panelLabels: [String]
    public let productTypeLabels: [String]
    public let strategyLabels: [String]
    public let commandGatewayRoutes: [String]
    public let disabledReasons: [String]
    public let validationAnchors: [String]
    public let panelCount: Int
    public let dashboardShowsRequiredPanels: Bool
    public let commandsRouteThroughCommandGateway: Bool
    public let commandEntryDefaultNoTrade: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCommandEnabled: Bool
    public let commandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let riskEngineGateRequired: Bool
    public let executionEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let eventStoreGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let noTradeStateRequired: Bool
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let dashboardSurfaceBoundaryHeld: Bool
    public let providesCommandSurface: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesSecretEditor: Bool
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let touchesAccountEndpoint: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let bypassesCommandGateway: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: ReleaseV020DashboardCommandGatewaySurfaceReadModel) {
        let panels = readModel.panels
        self.source = readModel.source
        self.issueID = "GH-594"
        self.matrixID = "TVM-RELEASE-V020-DASHBOARD-COMMANDGATEWAY-SURFACE"
        self.panelLabels = panels.map(\.dashboardLabel)
        self.productTypeLabels = readModel.productTypesCovered.map(\.rawValue)
        self.strategyLabels = readModel.strategiesCovered.map(\.rawValue)
        self.commandGatewayRoutes = panels.map(\.commandGatewayRoute)
        self.disabledReasons = panels.map(\.disabledReason)
        self.validationAnchors = readModel.validationAnchors
        self.panelCount = panels.count
        self.dashboardShowsRequiredPanels = readModel.dashboardLabels
            == ReleaseV020DashboardControlPanel.allCases.map(\.dashboardLabel)
        self.commandsRouteThroughCommandGateway = readModel.commandsRouteThroughCommandGateway
        self.commandEntryDefaultNoTrade = panels.allSatisfy { $0.defaultMode == .noTrade }
        self.productionTradingEnabledByDefault = false
        self.productionCommandEnabled = panels.contains(where: \.productionCommandEnabled)
        self.commandSurfaceVisible = panels.allSatisfy(\.commandEntryVisible)
        self.commandSurfaceEnabled = panels.contains(where: \.commandEntryEnabled)
        self.riskEngineGateRequired = panels.allSatisfy(\.riskEngineGateRequired)
        self.executionEngineGateRequired = panels.allSatisfy(\.executionEngineGateRequired)
        self.omsGateRequired = panels.allSatisfy(\.omsGateRequired)
        self.eventStoreGateRequired = panels.allSatisfy(\.eventStoreGateRequired)
        self.killSwitchGateRequired = panels.allSatisfy(\.killSwitchGateRequired)
        self.noTradeStateRequired = panels.allSatisfy(\.noTradeStateRequired)
        self.reportSummary = [
            "Release v0.2.0 Dashboard CommandGateway surface",
            "panels=\(panels.count)",
            "CommandGateway=required",
            "production=disabled"
        ].joined(separator: "; ")
        self.dashboardPanelSummaries = panels.map {
            "\($0.dashboardLabel): \($0.defaultMode.rawValue), route=\($0.commandGatewayRoute)"
        }
        self.dashboardSurfaceBoundaryHeld = readModel.dashboardSurfaceBoundaryHeld
            && dashboardShowsRequiredPanels
            && commandsRouteThroughCommandGateway
            && commandEntryDefaultNoTrade
            && productionCommandEnabled == false
            && commandSurfaceEnabled == false
            && panels.allSatisfy(\.panelBoundaryHeld)
        self.providesCommandSurface = commandSurfaceVisible
        self.providesTradingButton = false
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesSecretEditor = false
        self.readsSecret = panels.contains(where: \.productionSecretRead)
        self.opensProductionEndpoint = panels.contains(where: \.productionEndpointTouched)
        self.connectsBroker = panels.contains(where: \.brokerGatewayTouched)
        self.touchesAccountEndpoint = panels.contains(where: \.accountEndpointRead)
        self.submitsRealOrder = panels.contains(where: \.submitsRealOrder)
        self.cancelsRealOrder = panels.contains(where: \.cancelsRealOrder)
        self.replacesRealOrder = panels.contains(where: \.replacesRealOrder)
        self.bypassesCommandGateway = panels.contains(where: \.bypassesCommandGateway)
        self.bypassesRiskEngine = panels.contains(where: \.bypassesRiskEngine)
        self.bypassesExecutionEngine = panels.contains(where: \.bypassesExecutionEngine)
        self.bypassesOMS = panels.contains(where: \.bypassesOMS)
        self.bypassesEventStore = panels.contains(where: \.bypassesEventStore)
        self.bypassesKillSwitch = panels.contains(where: \.bypassesKillSwitch)
        self.bypassesNoTradeState = panels.contains(where: \.bypassesNoTradeState)
        self.authorizesTradingExecution = panels.contains(where: \.authorizesTradingExecution)
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element: Hashable {
    func uniquePreservingOrder() -> [Element] {
        var seen = Set<Element>()
        var values: [Element] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}

private extension Array where Element == ReleaseV020DashboardCommandGatewayPanelViewModel {
    func sortedByReleaseV020DashboardPanelOrder() -> [Element] {
        sorted { lhs, rhs in
            guard let lhsIndex = ReleaseV020DashboardControlPanel.allCases.firstIndex(of: lhs.panel),
                  let rhsIndex = ReleaseV020DashboardControlPanel.allCases.firstIndex(of: rhs.panel) else {
                return lhs.panel.rawValue < rhs.panel.rawValue
            }
            return lhsIndex < rhsIndex
        }
    }
}
