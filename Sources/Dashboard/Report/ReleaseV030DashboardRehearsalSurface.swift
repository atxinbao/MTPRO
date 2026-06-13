import Core
import Foundation

/// ReleaseV030DashboardRehearsalSurfaceViewModel 是 GH-666 的 Dashboard 只读 rehearsal surface。
///
/// ViewModel 只展示 run status、gate evidence、failure reason、kill switch 和 no-trade 状态；
/// 它不创建 SwiftUI trading button，不暴露 order form，不调用 CommandGateway 或 broker runtime。
public struct ReleaseV030DashboardRehearsalSurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let runStatusLabel: String
    public let productTypeLabels: [String]
    public let strategyLabels: [String]
    public let gateLabels: [String]
    public let gateStatuses: [String]
    public let failureReasons: [String]
    public let killSwitchStatusLabel: String
    public let noTradeStatusLabel: String
    public let commandGatewayRoutes: [String]
    public let dashboardStatusVisible: Bool
    public let failureReasonsVisible: Bool
    public let killSwitchStatusVisible: Bool
    public let noTradeStatusVisible: Bool
    public let commandsRouteThroughCommandGateway: Bool
    public let commandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let providesTradingButton: Bool
    public let exposesOrderForm: Bool
    public let authorizesTradingExecution: Bool
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let touchesAccountEndpoint: Bool
    public let connectsBroker: Bool
    public let submitsRealOrder: Bool
    public let bypassesCommandGateway: Bool
    public let dashboardSurfaceBoundaryHeld: Bool

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        evidence: ReleaseV030RehearsalSurfaceEvidence
    ) {
        self.source = source
        self.issueID = evidence.issueID.rawValue
        self.matrixID = "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"
        self.runStatusLabel = evidence.runStatus.rawValue
        self.productTypeLabels = evidence.productTypes.map(\.rawValue)
        self.strategyLabels = evidence.strategies.map(\.rawValue)
        self.gateLabels = evidence.gates.map(\.gate.rawValue)
        self.gateStatuses = evidence.gates.map(\.status.rawValue)
        self.failureReasons = evidence.failureReasons
        self.killSwitchStatusLabel = evidence.killSwitchStatus.rawValue
        self.noTradeStatusLabel = evidence.noTradeStatus.rawValue
        self.commandGatewayRoutes = evidence.gates.map(\.commandGatewayRoute)
        self.dashboardStatusVisible = evidence.dashboardStatusVisible
        self.failureReasonsVisible = evidence.failureReasonsVisible
        self.killSwitchStatusVisible = evidence.killSwitchStatusVisible
        self.noTradeStatusVisible = evidence.noTradeStatusVisible
        self.commandsRouteThroughCommandGateway = evidence.commandsRouteThroughCommandGateway
        self.commandSurfaceVisible = true
        self.commandSurfaceEnabled = false
        self.providesTradingButton = false
        self.exposesOrderForm = false
        self.authorizesTradingExecution = false
        self.readsSecret = false
        self.opensProductionEndpoint = false
        self.touchesAccountEndpoint = false
        self.connectsBroker = false
        self.submitsRealOrder = false
        self.bypassesCommandGateway = evidence.dashboardBypassesCommandGateway
        self.dashboardSurfaceBoundaryHeld = source.isReadModelOnly
            && evidence.evidenceHeld
            && evidence.boundaryHeld
            && dashboardStatusVisible
            && failureReasonsVisible
            && killSwitchStatusVisible
            && noTradeStatusVisible
            && commandsRouteThroughCommandGateway
            && commandSurfaceEnabled == false
            && providesTradingButton == false
            && exposesOrderForm == false
            && authorizesTradingExecution == false
            && readsSecret == false
            && opensProductionEndpoint == false
            && touchesAccountEndpoint == false
            && connectsBroker == false
            && submitsRealOrder == false
            && bypassesCommandGateway == false
    }

    public static func deterministic() throws -> ReleaseV030DashboardRehearsalSurfaceViewModel {
        try ReleaseV030DashboardRehearsalSurfaceViewModel(
            evidence: ReleaseV030RehearsalSurface.deterministicEvidence()
        )
    }
}
