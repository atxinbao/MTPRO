import Foundation
import Portfolio

/// ReleaseV060DashboardRunDetailObserverViewModel 是 GH-764 Dashboard 只读 run detail read-model。
///
/// ViewModel 只消费 Portfolio-owned artifact-backed observer evidence；它不提供 trading button、
/// order form、live command surface、broker connection 或 production cutover control。
public struct ReleaseV060DashboardRunDetailObserverViewModel: Codable, Equatable, Sendable {
    public let issueID: String
    public let runID: String
    public let validationAnchors: [String]
    public let sectionLabels: [String]
    public let sectionStatuses: [String]
    public let sectionSummaries: [String]
    public let manifestArtifactPaths: [String]
    public let payloadTypes: [String]
    public let riskDecisions: [String]
    public let riskReasons: [String]
    public let omsStates: [String]
    public let cliCommands: [String]
    public let dashboardReadsSameManifestAsCLI: Bool
    public let manifestValidatedBeforeHealthyState: Bool
    public let missingOrCorruptArtifactShownAsGap: Bool
    public let readModelOnly: Bool
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

    public init(evidence: ReleaseV060RunDetailObserverEvidence) {
        self.issueID = evidence.issueID.rawValue
        self.runID = evidence.selectedRunID.rawValue
        self.validationAnchors = evidence.validationAnchors
        self.sectionLabels = evidence.sectionRecords.map(\.section.rawValue)
        self.sectionStatuses = evidence.sectionRecords.map(\.status.rawValue)
        self.sectionSummaries = evidence.sectionRecords.map(\.summary)
        self.manifestArtifactPaths = evidence.manifestArtifactPaths
        self.payloadTypes = evidence.payloadTypes.map(\.rawValue)
        self.riskDecisions = evidence.riskDecisions.map(\.rawValue)
        self.riskReasons = evidence.riskReasons
        self.omsStates = evidence.omsStates.map(\.rawValue)
        self.cliCommands = evidence.cliCommands.map(\.rawValue)
        self.dashboardReadsSameManifestAsCLI = evidence.dashboardReadsSameManifestAsCLI
        self.manifestValidatedBeforeHealthyState = evidence.manifestValidatedBeforeHealthyState
        self.missingOrCorruptArtifactShownAsGap = evidence.missingOrCorruptArtifactShownAsGap
        self.readModelOnly = true
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
            && dashboardReadsSameManifestAsCLI
            && manifestValidatedBeforeHealthyState
            && missingOrCorruptArtifactShownAsGap
            && readModelOnly
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
}
