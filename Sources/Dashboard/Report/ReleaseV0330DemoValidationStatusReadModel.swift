import ExecutionClient

// GH-1548-ADD-READ-ONLY-DEMO-VALIDATION-STATUS-SURFACE
// TVM-RELEASE-V0330-DEMO-VALIDATION-STATUS
// V0330-007-DASHBOARD-READ-MODEL-ONLY
public struct ReleaseV0330DemoValidationStatusReadModel: Equatable, Sendable {
    public let decision: ReleaseV0330DemoValidationDecision
    public let reasons: [String]
    public let backendClosureDecision: String
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool
    public let readModelOnly: Bool

    public init(report: ReleaseV0330DemoValidationDecisionReport) {
        self.decision = report.decision
        self.reasons = report.reasons
        self.backendClosureDecision = report.backendClosureDecision
        self.productionCutoverAuthorized = report.productionCutoverAuthorized
        self.defaultProductionTradingEnabled = report.defaultProductionTradingEnabled
        self.readModelOnly = true
    }
}
