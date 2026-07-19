import Foundation

// GH-1577-CONSOLIDATE-DEMO-EVIDENCE-OWNERSHIP
// TVM-RELEASE-V0330-DEMO-ARTIFACT-VALIDATOR
// V0330-MAINTENANCE-ONE-AUTHORITATIVE-VALIDATION-PATH

public struct ReleaseV0330DemoValidationStatusSnapshot: Codable, Equatable, Sendable {
    public let decision: ReleaseV0330DemoValidationDecision
    public let reasons: [String]
    public let bundleSHA256: String?
    public let backendClosureDecision: String
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool
    public let readModelOnly: Bool

    public init(report: ReleaseV0330DemoValidationDecisionReport) {
        decision = report.decision
        reasons = report.reasons
        bundleSHA256 = report.bundleSHA256
        backendClosureDecision = report.backendClosureDecision
        productionCutoverAuthorized = report.productionCutoverAuthorized
        defaultProductionTradingEnabled = report.defaultProductionTradingEnabled
        readModelOnly = true
    }

    public var boundaryHeld: Bool {
        readModelOnly
            && productionCutoverAuthorized == false
            && defaultProductionTradingEnabled == false
            && (
                decision == .accepted
                    ? (
                        backendClosureDecision
                            == ReleaseV0330DemoValidationDecisionReport
                            .acceptedDemoNetworkParityBackendClosure
                            && reasons.isEmpty
                    )
                    : (
                        backendClosureDecision
                            == ReleaseV0330DemoValidationDecisionReport.blockedBackendClosure
                            && reasons.isEmpty == false
                    )
            )
    }
}

public enum ReleaseV0330DemoValidationArtifactValidator {
    public static let validationAnchor = "TVM-RELEASE-V0330-DEMO-ARTIFACT-VALIDATOR"

    /// 读取范围固定为 artifact 所在目录，并复用 v0.32.3 的 realpath containment。
    /// 缺失、损坏、symlink 或 schema/boundary 漂移都返回 blocked snapshot。
    public static func validate(bundleURL: URL) -> ReleaseV0330DemoValidationStatusSnapshot {
        let report: ReleaseV0330DemoValidationDecisionReport
        do {
            let standardized = bundleURL.standardizedFileURL
            let root = standardized.deletingLastPathComponent()
            let containment = try ReleaseV0323EvidenceRootContainment(evidenceRoot: root)
            let data = try containment.readArtifact(
                relativePath: standardized.lastPathComponent
            )
            let bundle = try JSONDecoder().decode(
                ReleaseV0330DemoValidationEvidenceBundle.self,
                from: data
            )
            report = ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle)
        } catch let error as ReleaseV0323EvidenceRootContainmentError {
            report = blocked(reason: containmentReason(error))
        } catch is DecodingError {
            report = blocked(reason: "corrupt-demo-validation-bundle")
        } catch {
            report = blocked(reason: "missing-demo-validation-bundle")
        }
        return ReleaseV0330DemoValidationStatusSnapshot(report: report)
    }

    private static func containmentReason(
        _ error: ReleaseV0323EvidenceRootContainmentError
    ) -> String {
        switch error {
        case .missingArtifact:
            "missing-demo-validation-bundle"
        default:
            "unsafe-demo-validation-artifact-path"
        }
    }

    private static func blocked(reason: String) -> ReleaseV0330DemoValidationDecisionReport {
        ReleaseV0330DemoValidationDecisionReport(
            decision: .blocked,
            reasons: [reason],
            bundleSHA256: nil,
            backendClosureDecision:
                ReleaseV0330DemoValidationDecisionReport.blockedBackendClosure,
            productionCutoverAuthorized: false,
            defaultProductionTradingEnabled: false
        )
    }
}
