import DomainModel
import Foundation

/// ReleaseV020VerificationGateSection 固定 GH-595 verify-fast / verify-release 的覆盖维度。
///
/// 这些 section 只是本地 deterministic release evidence 的验收分组，不代表外部 CI、
/// production runbook、broker statement、真实账户 checkpoint 或 production cutover。
public enum ReleaseV020VerificationGateSection: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case foundation
    case sampleTraces = "sample-traces"
    case fullGates = "full-gates"
    case allTraces = "all-traces"
}

/// ReleaseV020VerificationGateCoverage 是单个 verify mode 的 coverage contract。
///
/// verify-fast 必须覆盖 foundation + sample traces；verify-release 必须覆盖 foundation、sample
/// traces、full gates 和 all traces。两者都只验证本地 evidence，不读取 secret、不连接 endpoint、
/// 不触发 broker 或真实订单。
public struct ReleaseV020VerificationGateCoverage: Codable, Equatable, Sendable {
    public let mode: ReleaseV020CLIVerificationMode
    public let sections: [ReleaseV020VerificationGateSection]
    public let traceKinds: [ReleaseV020GoldenTraceKind]
    public let sourceEvidenceAnchors: [String]
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV020GoldenTraceStrategy]
    public let catalogBoundaryHeld: Bool
    public let commandGatewayRequired: Bool
    public let riskEngineGateRequired: Bool
    public let executionEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let eventStoreGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let noTradeStateRequired: Bool
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

    public init(
        mode: ReleaseV020CLIVerificationMode,
        sections: [ReleaseV020VerificationGateSection],
        traceKinds: [ReleaseV020GoldenTraceKind],
        sourceEvidenceAnchors: [String],
        productTypes: [ProductType] = ProductType.allCases,
        strategies: [ReleaseV020GoldenTraceStrategy] = ReleaseV020GoldenTraceStrategy.allCases,
        catalogBoundaryHeld: Bool = true,
        commandGatewayRequired: Bool = true,
        riskEngineGateRequired: Bool = true,
        executionEngineGateRequired: Bool = true,
        omsGateRequired: Bool = true,
        eventStoreGateRequired: Bool = true,
        killSwitchGateRequired: Bool = true,
        noTradeStateRequired: Bool = true,
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
        bypassesNoTradeState: Bool = false
    ) throws {
        let normalizedSections = sections.sortedByReleaseV020VerificationSectionOrder()
        let normalizedTraceKinds = traceKinds.sortedByReleaseV020GoldenTraceKindOrder()
        let normalizedProducts = productTypes.sorted { $0.rawValue < $1.rawValue }
        let normalizedStrategies = strategies.sorted { $0.rawValue < $1.rawValue }
        let requiredSections = ReleaseV020VerificationGates.requiredSections(for: mode)

        guard normalizedSections == requiredSections,
              normalizedTraceKinds.isEmpty == false,
              Set(normalizedTraceKinds).isSubset(of: Set(ReleaseV020GoldenTraceKind.allCases)),
              normalizedTraceKinds.count == Set(normalizedTraceKinds).count,
              sourceEvidenceAnchors.isEmpty == false,
              sourceEvidenceAnchors.allSatisfy({ $0.hasPrefix("GH-") }),
              Set(normalizedProducts) == Set(ProductType.allCases),
              Set(normalizedStrategies) == Set(ReleaseV020GoldenTraceStrategy.allCases),
              catalogBoundaryHeld,
              commandGatewayRequired,
              riskEngineGateRequired,
              executionEngineGateRequired,
              omsGateRequired,
              eventStoreGateRequired,
              killSwitchGateRequired,
              noTradeStateRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020VerificationGates.coverage",
                expected: "\(mode.rawValue) coverage sections and release gate requirements",
                actual: normalizedSections.map(\.rawValue).joined(separator: ",")
            )
        }

        if mode == .verifyRelease,
           Set(normalizedTraceKinds) != Set(ReleaseV020GoldenTraceKind.allCases) {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020VerificationGates.verifyReleaseTraceCoverage",
                expected: "all release v0.2.0 golden traces",
                actual: "\(normalizedTraceKinds.count)"
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
            ("bypassesNoTradeState", bypassesNoTradeState)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020VerificationGates.\(forbiddenFlag.0)"
            )
        }

        self.mode = mode
        self.sections = normalizedSections
        self.traceKinds = normalizedTraceKinds
        self.sourceEvidenceAnchors = sourceEvidenceAnchors.sorted()
        self.productTypes = normalizedProducts
        self.strategies = normalizedStrategies
        self.catalogBoundaryHeld = catalogBoundaryHeld
        self.commandGatewayRequired = commandGatewayRequired
        self.riskEngineGateRequired = riskEngineGateRequired
        self.executionEngineGateRequired = executionEngineGateRequired
        self.omsGateRequired = omsGateRequired
        self.eventStoreGateRequired = eventStoreGateRequired
        self.killSwitchGateRequired = killSwitchGateRequired
        self.noTradeStateRequired = noTradeStateRequired
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
    }

    public var sectionLabels: [String] {
        sections.map(\.rawValue)
    }

    public var traceKindLabels: [String] {
        traceKinds.map(\.rawValue)
    }

    public var coverageBoundaryHeld: Bool {
        sections == ReleaseV020VerificationGates.requiredSections(for: mode)
            && traceKinds.isEmpty == false
            && Set(traceKinds).isSubset(of: Set(ReleaseV020GoldenTraceKind.allCases))
            && (mode == .verifyFast || Set(traceKinds) == Set(ReleaseV020GoldenTraceKind.allCases))
            && sourceEvidenceAnchors.isEmpty == false
            && sourceEvidenceAnchors.allSatisfy { $0.hasPrefix("GH-") }
            && Set(productTypes) == Set(ProductType.allCases)
            && Set(strategies) == Set(ReleaseV020GoldenTraceStrategy.allCases)
            && catalogBoundaryHeld
            && commandGatewayRequired
            && riskEngineGateRequired
            && executionEngineGateRequired
            && omsGateRequired
            && eventStoreGateRequired
            && killSwitchGateRequired
            && noTradeStateRequired
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
    }
}

/// ReleaseV020VerificationGateEvidence 汇总 GH-595 verify-fast / verify-release gate。
public struct ReleaseV020VerificationGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let verifyFast: ReleaseV020VerificationGateCoverage
    public let verifyRelease: ReleaseV020VerificationGateCoverage
    public let validationAnchors: [String]
    public let catalogTraceCount: Int
    public let verifyFastPasses: Bool
    public let verifyReleasePasses: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointTouched: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-595-verify-fast-release-gate-evidence"),
        issueID: Identifier = Identifier.constant("GH-595"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-594")],
        verifyFast: ReleaseV020VerificationGateCoverage,
        verifyRelease: ReleaseV020VerificationGateCoverage,
        validationAnchors: [String] = ReleaseV020VerificationGates.requiredValidationAnchors,
        catalogTraceCount: Int = ReleaseV020GoldenTraceCatalog.requiredTraceCount,
        verifyFastPasses: Bool = true,
        verifyReleasePasses: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-595",
              upstreamIssueIDs.map(\.rawValue) == ["GH-594"],
              verifyFast.mode == .verifyFast,
              verifyRelease.mode == .verifyRelease,
              verifyFast.coverageBoundaryHeld,
              verifyRelease.coverageBoundaryHeld,
              validationAnchors == ReleaseV020VerificationGates.requiredValidationAnchors,
              catalogTraceCount == ReleaseV020GoldenTraceCatalog.requiredTraceCount,
              verifyFastPasses,
              verifyReleasePasses else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020VerificationGates.evidence",
                expected: "verify-fast and verify-release coverage evidence",
                actual: "\(catalogTraceCount)"
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
            ("replacesRealOrder", replacesRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020VerificationGates.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.verifyFast = verifyFast
        self.verifyRelease = verifyRelease
        self.validationAnchors = validationAnchors
        self.catalogTraceCount = catalogTraceCount
        self.verifyFastPasses = verifyFastPasses
        self.verifyReleasePasses = verifyReleasePasses
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointTouched = productionEndpointTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public var gateBoundaryHeld: Bool {
        issueID.rawValue == "GH-595"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-594"]
            && verifyFast.mode == .verifyFast
            && verifyRelease.mode == .verifyRelease
            && verifyFast.coverageBoundaryHeld
            && verifyRelease.coverageBoundaryHeld
            && validationAnchors == ReleaseV020VerificationGates.requiredValidationAnchors
            && catalogTraceCount == ReleaseV020GoldenTraceCatalog.requiredTraceCount
            && verifyFastPasses
            && verifyReleasePasses
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointTouched == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }
}

/// ReleaseV020VerificationGates 生成 GH-595 verify-fast / verify-release deterministic evidence。
public enum ReleaseV020VerificationGates {
    public static let requiredValidationAnchors = [
        "GH-595-VERIFY-FAST-FOUNDATION-SAMPLE-TRACES",
        "GH-595-VERIFY-RELEASE-FULL-GATES-ALL-TRACES",
        "GH-595-MTPRO-VERIFY-FAST-GATE-PASS",
        "GH-595-MTPRO-VERIFY-RELEASE-GATE-PASS",
        "GH-595-NO-PRODUCTION-VERIFY-SIDE-EFFECT",
        "TVM-RELEASE-V020-VERIFY-FAST-RELEASE-GATES"
    ]

    public static let sampleTraceKinds: [ReleaseV020GoldenTraceKind] = [
        .spotMarketDataCache,
        .perpetualMarketDataCache,
        .emaSpotTargetExposure,
        .emaPerpetualTargetExposure,
        .rsiSpotTargetExposure,
        .rsiPerpetualTargetExposure
    ]

    public static func requiredSections(
        for mode: ReleaseV020CLIVerificationMode
    ) -> [ReleaseV020VerificationGateSection] {
        switch mode {
        case .verifyFast:
            return [.foundation, .sampleTraces]
        case .verifyRelease:
            return [.foundation, .sampleTraces, .fullGates, .allTraces]
        }
    }

    public static func deterministicEvidence() throws -> ReleaseV020VerificationGateEvidence {
        let catalog = try ReleaseV020GoldenTraceCatalog.deterministicEvidence()
        let verifyFast = try ReleaseV020VerificationGateCoverage(
            mode: .verifyFast,
            sections: requiredSections(for: .verifyFast),
            traceKinds: sampleTraceKinds,
            sourceEvidenceAnchors: [
                "GH-565-GH-568-FOUNDATION-GUARDS",
                "GH-572-TYPED-MESSAGEBUS-ENVELOPE",
                "GH-592-SAMPLE-TRACE-CATALOG",
                "GH-594-DASHBOARD-COMMANDGATEWAY-SURFACE"
            ],
            catalogBoundaryHeld: catalog.catalogBoundaryHeld
        )
        let verifyRelease = try ReleaseV020VerificationGateCoverage(
            mode: .verifyRelease,
            sections: requiredSections(for: .verifyRelease),
            traceKinds: ReleaseV020GoldenTraceKind.allCases,
            sourceEvidenceAnchors: [
                "GH-565-GH-594-RELEASE-V020-FULL-GATE-CHAIN",
                "GH-592-ALL-15-REQUIRED-TRACES-PRESENT",
                "GH-593-MTPRO-VERIFY-RELEASE-PASS",
                "GH-594-DASHBOARD-COMMANDGATEWAY-SURFACE"
            ],
            catalogBoundaryHeld: catalog.catalogBoundaryHeld
        )
        return try ReleaseV020VerificationGateEvidence(
            verifyFast: verifyFast,
            verifyRelease: verifyRelease,
            catalogTraceCount: catalog.traceCount
        )
    }
}

private extension Array where Element == ReleaseV020VerificationGateSection {
    func sortedByReleaseV020VerificationSectionOrder() -> [ReleaseV020VerificationGateSection] {
        sorted { lhs, rhs in
            guard let lhsIndex = ReleaseV020VerificationGateSection.allCases.firstIndex(of: lhs),
                  let rhsIndex = ReleaseV020VerificationGateSection.allCases.firstIndex(of: rhs) else {
                return lhs.rawValue < rhs.rawValue
            }
            return lhsIndex < rhsIndex
        }
    }
}

private extension Array where Element == ReleaseV020GoldenTraceKind {
    func sortedByReleaseV020GoldenTraceKindOrder() -> [ReleaseV020GoldenTraceKind] {
        sorted { lhs, rhs in
            guard let lhsIndex = ReleaseV020GoldenTraceKind.allCases.firstIndex(of: lhs),
                  let rhsIndex = ReleaseV020GoldenTraceKind.allCases.firstIndex(of: rhs) else {
                return lhs.rawValue < rhs.rawValue
            }
            return lhsIndex < rhsIndex
        }
    }
}
