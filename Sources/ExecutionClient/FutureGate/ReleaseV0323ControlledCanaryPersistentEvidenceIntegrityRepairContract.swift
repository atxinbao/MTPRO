import Foundation

// GH-1535-DEFINE-V0323-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT
// TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR
// V0323-001-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT

public enum ReleaseV0323IntegrityRequirement: String, CaseIterable, Codable, Sendable {
    case trustedGitHubProvenance = "trusted-github-provenance"
    case atomicPersistentRunLock = "atomic-persistent-run-lock"
    case independentArtifactGraph = "independent-artifact-graph"
    case realpathContainment = "realpath-containment"
    case completeNegativeMatrix = "complete-negative-matrix"
    case binanceOnlyDocumentation = "binance-only-documentation"
}

public struct ReleaseV0323ControlledCanaryPersistentEvidenceIntegrityRepairContract: Codable, Equatable, Sendable {
    public static let release = "v0.32.3"
    public static let blockedRelease = "v0.33.0"
    public static let backendClosureDecision = "blocked"
    public static let requiredRequirements = ReleaseV0323IntegrityRequirement.allCases
    public static let requiredAnchors = [
        "GH-1535-DEFINE-V0323-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT",
        "TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR",
        "V0323-001-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT",
    ]

    public let release: String
    public let blockedRelease: String
    public let requiredRequirements: [ReleaseV0323IntegrityRequirement]
    public let backendClosureDecision: String
    public let observedProductionCanaryAuthorized: Bool
    public let productionCutoverAuthorized: Bool
    public let selfReportedManifestTrusted: Bool
    public let defaultProductionTradingEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool

    public init(
        release: String = Self.release,
        blockedRelease: String = Self.blockedRelease,
        requiredRequirements: [ReleaseV0323IntegrityRequirement] = Self.requiredRequirements,
        backendClosureDecision: String = Self.backendClosureDecision,
        observedProductionCanaryAuthorized: Bool = false,
        productionCutoverAuthorized: Bool = false,
        selfReportedManifestTrusted: Bool = false,
        defaultProductionTradingEnabled: Bool = false,
        okxActiveRuntimeEnabled: Bool = false,
        dashboardTradingControlsEnabled: Bool = false
    ) {
        self.release = release
        self.blockedRelease = blockedRelease
        self.requiredRequirements = requiredRequirements
        self.backendClosureDecision = backendClosureDecision
        self.observedProductionCanaryAuthorized = observedProductionCanaryAuthorized
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.selfReportedManifestTrusted = selfReportedManifestTrusted
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
    }

    public var boundaryHeld: Bool {
        release == Self.release
            && blockedRelease == Self.blockedRelease
            && Set(requiredRequirements) == Set(Self.requiredRequirements)
            && requiredRequirements.count == Self.requiredRequirements.count
            && backendClosureDecision == Self.backendClosureDecision
            && observedProductionCanaryAuthorized == false
            && productionCutoverAuthorized == false
            && selfReportedManifestTrusted == false
            && defaultProductionTradingEnabled == false
            && okxActiveRuntimeEnabled == false
            && dashboardTradingControlsEnabled == false
    }
}
