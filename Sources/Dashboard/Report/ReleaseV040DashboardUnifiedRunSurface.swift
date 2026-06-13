import Foundation
import Portfolio

/// ReleaseV040DashboardUnifiedRunSurfaceViewModel 是 GH-705 的 Dashboard 只读 unified run surface。
///
/// ViewModel 只消费 Portfolio-owned unified run evidence，不暴露 trading button、order form
/// 或 production command surface。
public struct ReleaseV040DashboardUnifiedRunSurfaceViewModel: Codable, Equatable, Sendable {
    public let issueID: String
    public let runID: String
    public let validationAnchor: String
    public let productTypeLabels: [String]
    public let strategyLabels: [String]
    public let gateLabels: [String]
    public let gateStatuses: [String]
    public let explanations: [String]
    public let adapterEvidenceVisible: Bool
    public let portfolioProjectionVisible: Bool
    public let blockedStatesExplained: Bool
    public let rejectedStatesExplained: Bool
    public let consumesProjectionByRunID: Bool
    public let readModelOnly: Bool
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
    public let startsNextMilestone: Bool
    public let dashboardSurfaceBoundaryHeld: Bool

    public init(evidence: ReleaseV040UnifiedRunSurfaceEvidence) {
        self.issueID = evidence.issueID.rawValue
        self.runID = evidence.runID.rawValue
        self.validationAnchor = evidence.validationAnchor
        self.productTypeLabels = evidence.productTypes.map(\.rawValue)
        self.strategyLabels = evidence.strategies.map(\.rawValue)
        self.gateLabels = evidence.gates.map(\.gate.rawValue)
        self.gateStatuses = evidence.gates.map(\.status.rawValue)
        self.explanations = evidence.failureReasons
        self.adapterEvidenceVisible = evidence.adapterEvidenceVisible
        self.portfolioProjectionVisible = evidence.portfolioProjectionVisible
        self.blockedStatesExplained = evidence.blockedStatesExplained
        self.rejectedStatesExplained = evidence.rejectedStatesExplained
        self.consumesProjectionByRunID = evidence.dashboardConsumesProjectionByRunID
        self.readModelOnly = true
        self.commandSurfaceVisible = false
        self.commandSurfaceEnabled = false
        self.providesTradingButton = false
        self.exposesOrderForm = false
        self.authorizesTradingExecution = false
        self.readsSecret = false
        self.opensProductionEndpoint = false
        self.touchesAccountEndpoint = false
        self.connectsBroker = false
        self.submitsRealOrder = false
        self.startsNextMilestone = false
        self.dashboardSurfaceBoundaryHeld = evidence.evidenceHeld
            && evidence.boundaryHeld
            && adapterEvidenceVisible
            && portfolioProjectionVisible
            && blockedStatesExplained
            && rejectedStatesExplained
            && consumesProjectionByRunID
            && readModelOnly
            && commandSurfaceVisible == false
            && commandSurfaceEnabled == false
            && providesTradingButton == false
            && exposesOrderForm == false
            && authorizesTradingExecution == false
            && readsSecret == false
            && opensProductionEndpoint == false
            && touchesAccountEndpoint == false
            && connectsBroker == false
            && submitsRealOrder == false
            && startsNextMilestone == false
    }

    public static func deterministic() throws -> ReleaseV040DashboardUnifiedRunSurfaceViewModel {
        try ReleaseV040DashboardUnifiedRunSurfaceViewModel(
            evidence: ReleaseV040UnifiedRunSurface.deterministicEvidence()
        )
    }
}
