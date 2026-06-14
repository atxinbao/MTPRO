import Foundation
import Portfolio

/// ReleaseV050DashboardRunObserverSurfaceViewModel 是 GH-737 的 Dashboard 只读 run observer。
///
/// ViewModel 只消费 Portfolio-owned observer evidence；它不提供 trading button、order form、
/// live command surface、broker connection 或 production cutover control。
public struct ReleaseV050DashboardRunObserverSurfaceViewModel: Codable, Equatable, Sendable {
    public let issueID: String
    public let runID: String
    public let validationAnchors: [String]
    public let sectionLabels: [String]
    public let sectionStatuses: [String]
    public let sectionSummaries: [String]
    public let sourcePayloadTypes: [String]
    public let cliCommands: [String]
    public let riskDecisions: [String]
    public let riskReasons: [String]
    public let omsStates: [String]
    public let executionDryRunCommands: [String]
    public let projectionIDs: [String]
    public let dashboardReadsByRunID: Bool
    public let consumesRunJournal: Bool
    public let consumesPortfolioProjection: Bool
    public let displaysBlockedRejectedReasons: Bool
    public let displaysBoundaryEvidence: Bool
    public let readModelOnly: Bool
    public let defaultDemoSnapshotUsedForV050Path: Bool
    public let commandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let providesTradingButton: Bool
    public let exposesOrderForm: Bool
    public let brokerExecutionWriteEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let dashboardSurfaceBoundaryHeld: Bool

    public init(evidence: ReleaseV050RunObserverSurfaceEvidence) {
        self.issueID = evidence.issueID.rawValue
        self.runID = evidence.runID.rawValue
        self.validationAnchors = evidence.validationAnchors
        self.sectionLabels = evidence.dashboardSections.map(\.section.rawValue)
        self.sectionStatuses = evidence.dashboardSections.map(\.status.rawValue)
        self.sectionSummaries = evidence.dashboardSections.map(\.summary)
        self.sourcePayloadTypes = evidence.sourcePayloadTypes.map(\.rawValue)
        self.cliCommands = evidence.cliCommands.map(\.rawValue)
        self.riskDecisions = evidence.riskDecisions.map(\.rawValue)
        self.riskReasons = evidence.riskReasons
        self.omsStates = evidence.omsStates.map(\.rawValue)
        self.executionDryRunCommands = evidence.executionDryRunCommands.map(\.rawValue)
        self.projectionIDs = evidence.portfolioProjectionState.productProjections.map(\.projectionID.rawValue)
        self.dashboardReadsByRunID = evidence.dashboardReadsByRunID
        self.consumesRunJournal = evidence.consumesRunJournal
        self.consumesPortfolioProjection = evidence.consumesPortfolioProjection
        self.displaysBlockedRejectedReasons = evidence.displaysBlockedRejectedReasons
        self.displaysBoundaryEvidence = evidence.displaysBoundaryEvidence
        self.readModelOnly = true
        self.defaultDemoSnapshotUsedForV050Path = evidence.defaultDemoSnapshotUsedForV050Path
        self.commandSurfaceVisible = false
        self.commandSurfaceEnabled = false
        self.providesTradingButton = false
        self.exposesOrderForm = false
        self.brokerExecutionWriteEnabled = evidence.brokerExecutionWriteEnabled
        self.productionTradingEnabledByDefault = evidence.productionTradingEnabledByDefault
        self.productionEndpointConnected = evidence.productionEndpointConnected
        self.productionSecretAutoReadEnabled = evidence.productionSecretAutoReadEnabled
        self.productionOrderSubmitted = evidence.productionOrderSubmitted
        self.productionCutoverAuthorized = evidence.productionCutoverAuthorized
        self.dashboardSurfaceBoundaryHeld = evidence.evidenceHeld
            && evidence.observerBoundaryHeld
            && evidence.forbiddenBoundaryHeld
            && dashboardReadsByRunID
            && consumesRunJournal
            && consumesPortfolioProjection
            && displaysBlockedRejectedReasons
            && displaysBoundaryEvidence
            && readModelOnly
            && defaultDemoSnapshotUsedForV050Path == false
            && commandSurfaceVisible == false
            && commandSurfaceEnabled == false
            && providesTradingButton == false
            && exposesOrderForm == false
            && brokerExecutionWriteEnabled == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func deterministic() async throws -> ReleaseV050DashboardRunObserverSurfaceViewModel {
        let evidence = try await ReleaseV050RunObserverSurface.deterministicEvidence()
        return ReleaseV050DashboardRunObserverSurfaceViewModel(evidence: evidence)
    }
}
