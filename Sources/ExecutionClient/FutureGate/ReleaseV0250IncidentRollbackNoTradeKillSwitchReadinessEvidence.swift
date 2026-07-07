import Foundation

public enum ReleaseV0250IncidentReadinessKind: String, Codable, Equatable, Sendable, CaseIterable {
    case rollbackReadiness = "rollback-readiness"
    case noTradeState = "no-trade-state"
    case killSwitchReadiness = "kill-switch-readiness"
    case blockedOperationalControl = "blocked-operational-control"
}

public struct ReleaseV0250IncidentProductReadinessEvidence: Codable, Equatable, Sendable {
    public let product: ReleaseV0250RiskGateProduct
    public let upstreamRiskGateRelease: String
    public let readinessKinds: [ReleaseV0250IncidentReadinessKind]
    public let rollbackEvidence: String
    public let noTradeStateEvidence: String
    public let killSwitchEvidence: String
    public let blockedOperationalControlEvidence: String
    public let operationalControlRuntimeEnabled: Bool
    public let emergencyStopCommandEnabled: Bool
    public let shutdownRuntimeEnabled: Bool
    public let restoreRuntimeEnabled: Bool
    public let brokerConnectionEnabled: Bool
    public let liveCommandUIEnabled: Bool

    public init(
        product: ReleaseV0250RiskGateProduct,
        upstreamRiskGateRelease: String,
        readinessKinds: [ReleaseV0250IncidentReadinessKind],
        rollbackEvidence: String,
        noTradeStateEvidence: String,
        killSwitchEvidence: String,
        blockedOperationalControlEvidence: String,
        operationalControlRuntimeEnabled: Bool,
        emergencyStopCommandEnabled: Bool,
        shutdownRuntimeEnabled: Bool,
        restoreRuntimeEnabled: Bool,
        brokerConnectionEnabled: Bool,
        liveCommandUIEnabled: Bool
    ) {
        self.product = product
        self.upstreamRiskGateRelease = upstreamRiskGateRelease
        self.readinessKinds = readinessKinds
        self.rollbackEvidence = rollbackEvidence
        self.noTradeStateEvidence = noTradeStateEvidence
        self.killSwitchEvidence = killSwitchEvidence
        self.blockedOperationalControlEvidence = blockedOperationalControlEvidence
        self.operationalControlRuntimeEnabled = operationalControlRuntimeEnabled
        self.emergencyStopCommandEnabled = emergencyStopCommandEnabled
        self.shutdownRuntimeEnabled = shutdownRuntimeEnabled
        self.restoreRuntimeEnabled = restoreRuntimeEnabled
        self.brokerConnectionEnabled = brokerConnectionEnabled
        self.liveCommandUIEnabled = liveCommandUIEnabled
    }

    public var evidenceHeld: Bool {
        upstreamRiskGateRelease == "v0.25.0/V0250-005"
            && Set(readinessKinds) == Set(ReleaseV0250IncidentReadinessKind.allCases)
            && rollbackEvidence.hasPrefix("readiness:")
            && noTradeStateEvidence.hasPrefix("readiness:")
            && killSwitchEvidence.hasPrefix("readiness:")
            && blockedOperationalControlEvidence.hasPrefix("blocked:")
            && operationalControlRuntimeEnabled == false
            && emergencyStopCommandEnabled == false
            && shutdownRuntimeEnabled == false
            && restoreRuntimeEnabled == false
            && brokerConnectionEnabled == false
            && liveCommandUIEnabled == false
    }
}

public struct ReleaseV0250IncidentRollbackNoTradeKillSwitchReadinessEvidence:
    Codable, Equatable, Sendable
{
    // v0.25.0 records incident-readiness vocabulary only; it does not add control runtime.
    public static let validationAnchor =
        "TVM-RELEASE-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE"
    public static let verificationAnchor =
        "GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE"
    public static let requiredAnchors = [
        "GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE",
        "TVM-RELEASE-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE",
        "V0250-006-INCIDENT-ROLLBACK-READINESS",
        "V0250-006-NO-TRADE-STATE-EVIDENCE",
        "V0250-006-KILL-SWITCH-READINESS",
        "V0250-006-BLOCKED-OPERATIONAL-CONTROL",
        "V0250-006-NO-EMERGENCY-STOP-RUNTIME",
        "V0250-006-NO-LIVE-COMMAND-UI"
    ]

    public let release: String
    public let upstreamRiskGateRelease: String
    public let productEvidence: [ReleaseV0250IncidentProductReadinessEvidence]
    public let productionTradingEnabledByDefault: Bool
    public let operationalControlRuntimeEnabled: Bool
    public let emergencyStopCommandEnabled: Bool
    public let shutdownRuntimeEnabled: Bool
    public let restoreRuntimeEnabled: Bool
    public let brokerConnectionEnabled: Bool
    public let liveCommandUIEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamRiskGateRelease: String,
        productEvidence: [ReleaseV0250IncidentProductReadinessEvidence],
        productionTradingEnabledByDefault: Bool,
        operationalControlRuntimeEnabled: Bool,
        emergencyStopCommandEnabled: Bool,
        shutdownRuntimeEnabled: Bool,
        restoreRuntimeEnabled: Bool,
        brokerConnectionEnabled: Bool,
        liveCommandUIEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamRiskGateRelease = upstreamRiskGateRelease
        self.productEvidence = productEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.operationalControlRuntimeEnabled = operationalControlRuntimeEnabled
        self.emergencyStopCommandEnabled = emergencyStopCommandEnabled
        self.shutdownRuntimeEnabled = shutdownRuntimeEnabled
        self.restoreRuntimeEnabled = restoreRuntimeEnabled
        self.brokerConnectionEnabled = brokerConnectionEnabled
        self.liveCommandUIEnabled = liveCommandUIEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamRiskGateRelease: "v0.25.0/V0250-005",
            productEvidence: [
                .init(
                    product: .spot,
                    upstreamRiskGateRelease: "v0.25.0/V0250-005",
                    readinessKinds: ReleaseV0250IncidentReadinessKind.allCases,
                    rollbackEvidence: "readiness:spot-canary-rollback-evidence-required",
                    noTradeStateEvidence: "readiness:spot-no-trade-state-evidence-required",
                    killSwitchEvidence: "readiness:spot-kill-switch-evidence-required",
                    blockedOperationalControlEvidence: "blocked:spot-operational-control-runtime-not-authorized",
                    operationalControlRuntimeEnabled: false,
                    emergencyStopCommandEnabled: false,
                    shutdownRuntimeEnabled: false,
                    restoreRuntimeEnabled: false,
                    brokerConnectionEnabled: false,
                    liveCommandUIEnabled: false
                ),
                .init(
                    product: .usdsPerpetual,
                    upstreamRiskGateRelease: "v0.25.0/V0250-005",
                    readinessKinds: ReleaseV0250IncidentReadinessKind.allCases,
                    rollbackEvidence: "readiness:futures-readonly-rollback-evidence-required",
                    noTradeStateEvidence: "readiness:futures-no-trade-state-evidence-required",
                    killSwitchEvidence: "readiness:futures-kill-switch-evidence-required",
                    blockedOperationalControlEvidence: "blocked:futures-operational-control-runtime-not-authorized",
                    operationalControlRuntimeEnabled: false,
                    emergencyStopCommandEnabled: false,
                    shutdownRuntimeEnabled: false,
                    restoreRuntimeEnabled: false,
                    brokerConnectionEnabled: false,
                    liveCommandUIEnabled: false
                )
            ],
            productionTradingEnabledByDefault: false,
            operationalControlRuntimeEnabled: false,
            emergencyStopCommandEnabled: false,
            shutdownRuntimeEnabled: false,
            restoreRuntimeEnabled: false,
            brokerConnectionEnabled: false,
            liveCommandUIEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var evidenceHeld: Bool {
        release == "v0.25.0"
            && upstreamRiskGateRelease == "v0.25.0/V0250-005"
            && Set(productEvidence.map(\.product)) == Set(ReleaseV0250RiskGateProduct.allCases)
            && productEvidence.allSatisfy(\.evidenceHeld)
            && forbiddenCapabilitiesClosed
            && boundaryHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && operationalControlRuntimeEnabled == false
            && emergencyStopCommandEnabled == false
            && shutdownRuntimeEnabled == false
            && restoreRuntimeEnabled == false
            && brokerConnectionEnabled == false
            && liveCommandUIEnabled == false
            && productionCutoverAuthorized == false
    }
}
