import Foundation

// GH-1542-DEFINE-V0330-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT
// TVM-RELEASE-V0330-OBSERVED-CONTROLLED-PRODUCTION-CANARY
// V0330-001-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT

public enum ReleaseV0330BackendClosureRequirement: String, CaseIterable, Codable, Sendable {
    case publishedV0323IntegrityRepair = "published-v0.32.3-integrity-repair"
    case explicitHumanApproval = "explicit-human-approval"
    case commitBoundApprovalPacket = "commit-bound-approval-packet"
    case strictProductAndNotionalCaps = "strict-product-and-notional-caps"
    case trustedGitHubProvenance = "trusted-github-provenance"
    case completeObservedLifecycle = "complete-observed-lifecycle"
    case immutableIndependentArtifactBundle = "immutable-independent-artifact-bundle"
    case failClosedDecisionEngine = "fail-closed-decision-engine"
}

public enum ReleaseV0330QueueEligibility: String, Codable, Sendable {
    case blockedV0323NotPublished = "blocked-v0.32.3-not-published"
    case blockedHumanApprovalMissing = "blocked-human-approval-missing"
    case approvalPacketPreparationEligible = "approval-packet-preparation-eligible"
}

public struct ReleaseV0330ObservedCanaryBackendClosureContract: Codable, Equatable, Sendable {
    public static let release = "v0.33.0"
    public static let prerequisiteRelease = "v0.32.3"
    public static let requiredProducts = ["spot", "usdsPerpetual"]
    public static let requiredActions = ["submit", "status", "cancel"]
    public static let requiredRequirements = ReleaseV0330BackendClosureRequirement.allCases
    public static let requiredAnchors = [
        "GH-1542-DEFINE-V0330-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT",
        "TVM-RELEASE-V0330-OBSERVED-CONTROLLED-PRODUCTION-CANARY",
        "V0330-001-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT",
    ]

    public let release: String
    public let prerequisiteRelease: String
    public let requiredProducts: [String]
    public let requiredActions: [String]
    public let requiredRequirements: [ReleaseV0330BackendClosureRequirement]
    public let requiresExplicitHumanApproval: Bool
    public let observedCanaryExecutionAuthorized: Bool
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool

    public init(
        release: String = Self.release,
        prerequisiteRelease: String = Self.prerequisiteRelease,
        requiredProducts: [String] = Self.requiredProducts,
        requiredActions: [String] = Self.requiredActions,
        requiredRequirements: [ReleaseV0330BackendClosureRequirement] = Self.requiredRequirements,
        requiresExplicitHumanApproval: Bool = true,
        observedCanaryExecutionAuthorized: Bool = false,
        productionCutoverAuthorized: Bool = false,
        defaultProductionTradingEnabled: Bool = false,
        okxActiveRuntimeEnabled: Bool = false,
        dashboardTradingControlsEnabled: Bool = false
    ) {
        self.release = release
        self.prerequisiteRelease = prerequisiteRelease
        self.requiredProducts = requiredProducts
        self.requiredActions = requiredActions
        self.requiredRequirements = requiredRequirements
        self.requiresExplicitHumanApproval = requiresExplicitHumanApproval
        self.observedCanaryExecutionAuthorized = observedCanaryExecutionAuthorized
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
    }

    public func queueEligibility(
        prerequisiteReleasePublished: Bool,
        explicitHumanApprovalRecorded: Bool
    ) -> ReleaseV0330QueueEligibility {
        guard prerequisiteReleasePublished else {
            return .blockedV0323NotPublished
        }
        guard explicitHumanApprovalRecorded else {
            return .blockedHumanApprovalMissing
        }
        return .approvalPacketPreparationEligible
    }

    public var boundaryHeld: Bool {
        release == Self.release
            && prerequisiteRelease == Self.prerequisiteRelease
            && requiredProducts == Self.requiredProducts
            && requiredActions == Self.requiredActions
            && Set(requiredRequirements) == Set(Self.requiredRequirements)
            && requiredRequirements.count == Self.requiredRequirements.count
            && requiresExplicitHumanApproval
            && observedCanaryExecutionAuthorized == false
            && productionCutoverAuthorized == false
            && defaultProductionTradingEnabled == false
            && okxActiveRuntimeEnabled == false
            && dashboardTradingControlsEnabled == false
    }
}
