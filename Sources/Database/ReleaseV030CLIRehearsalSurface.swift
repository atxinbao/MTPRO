import DomainModel
import Foundation

/// ReleaseV030CLIRehearsalStrategyKind 固定 `mtpro rehearsal-status` 可展示的策略集合。
///
/// CLI 只展示 release v0.3.0 rehearsal evidence，不导入 Trader / Portfolio runtime，
/// 不读取 secret、不连接 endpoint，也不授权任何真实交易命令。
public enum ReleaseV030CLIRehearsalStrategyKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema
    case rsi
}

/// ReleaseV030CLIRehearsalStatus 固定 CLI 输出的 rehearsal 状态。
public enum ReleaseV030CLIRehearsalStatus: String, Codable, Equatable, Sendable {
    case ready
    case blocked
}

/// ReleaseV030CLIRehearsalGate 固定 CLI 需要展示的 CommandGateway gate。
public enum ReleaseV030CLIRehearsalGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case commandGateway
    case riskEngine
    case executionEngine
    case oms
    case eventStore
    case portfolioProjection
    case killSwitch
    case noTrade
}

/// ReleaseV030CLIRehearsalGateRecord 是 CLI 输出中的单个 gate 记录。
public struct ReleaseV030CLIRehearsalGateRecord: Codable, Equatable, Sendable {
    public let gate: ReleaseV030CLIRehearsalGate
    public let status: ReleaseV030CLIRehearsalStatus
    public let commandGatewayRoute: String
    public let failureReason: String
    public let visibleOnCLI: Bool
    public let bypassesCommandGateway: Bool
    public let authorizesTradingExecution: Bool

    public init(
        gate: ReleaseV030CLIRehearsalGate,
        status: ReleaseV030CLIRehearsalStatus,
        commandGatewayRoute: String? = nil,
        failureReason: String,
        visibleOnCLI: Bool = true,
        bypassesCommandGateway: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        let resolvedRoute = commandGatewayRoute ?? "command-gateway/release-v0.3.0/rehearsal/\(gate.rawValue)"
        guard resolvedRoute.hasPrefix("command-gateway/release-v0.3.0/rehearsal/"),
              failureReason.isEmpty == false,
              visibleOnCLI else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030CLIRehearsalSurface.gate",
                expected: "CLI-visible gate routed through CommandGateway",
                actual: gate.rawValue
            )
        }
        try Self.forbid(bypassesCommandGateway, "bypassesCommandGateway")
        try Self.forbid(authorizesTradingExecution, "authorizesTradingExecution")

        self.gate = gate
        self.status = status
        self.commandGatewayRoute = resolvedRoute
        self.failureReason = failureReason
        self.visibleOnCLI = visibleOnCLI
        self.bypassesCommandGateway = bypassesCommandGateway
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var gateHeld: Bool {
        commandGatewayRoute.hasPrefix("command-gateway/release-v0.3.0/rehearsal/")
            && failureReason.isEmpty == false
            && visibleOnCLI
            && bypassesCommandGateway == false
            && authorizesTradingExecution == false
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030CLIRehearsalSurface.gate.\(field)")
        }
    }
}

/// ReleaseV030CLIRehearsalSurfaceEvidence 汇总 CLI-only rehearsal status。
///
/// 该 evidence 位于 Database target，使 `MTPROCLI` 继续只依赖 Database。Portfolio-owned
/// Dashboard evidence 仍由 `ReleaseV030RehearsalSurface` 覆盖；CLI 这里仅复用相同 anchor
/// 和 gate vocabulary，避免 executable target 直接依赖 Portfolio。
public struct ReleaseV030CLIRehearsalSurfaceEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let upstreamPortfolioProjectionAnchor: String
    public let validationAnchor: String
    public let runStatus: ReleaseV030CLIRehearsalStatus
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV030CLIRehearsalStrategyKind]
    public let gates: [ReleaseV030CLIRehearsalGateRecord]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let accountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let bypassesCommandGateway: Bool
    public let startsNextMilestone: Bool

    public init(
        issueID: Identifier = Identifier.constant("GH-666"),
        upstreamIssueID: Identifier = Identifier.constant("GH-665"),
        downstreamIssueID: Identifier = Identifier.constant("GH-667"),
        canonicalQueueRange: String = "GH-657..GH-670",
        releaseVersion: String = "v0.3.0",
        upstreamPortfolioProjectionAnchor: String = Self.requiredUpstreamPortfolioProjectionAnchor,
        validationAnchor: String = Self.requiredValidationAnchor,
        runStatus: ReleaseV030CLIRehearsalStatus = .blocked,
        productTypes: [ProductType] = Self.requiredProductTypes,
        strategies: [ReleaseV030CLIRehearsalStrategyKind] = Self.requiredStrategies,
        gates: [ReleaseV030CLIRehearsalGateRecord],
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        accountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        bypassesCommandGateway: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        let sortedProducts = productTypes.sorted { $0.rawValue < $1.rawValue }
        let sortedStrategies = strategies.sorted { $0.rawValue < $1.rawValue }
        guard issueID.rawValue == "GH-666",
              upstreamIssueID.rawValue == "GH-665",
              downstreamIssueID.rawValue == "GH-667",
              canonicalQueueRange == "GH-657..GH-670",
              releaseVersion == "v0.3.0",
              upstreamPortfolioProjectionAnchor == Self.requiredUpstreamPortfolioProjectionAnchor,
              validationAnchor == Self.requiredValidationAnchor,
              runStatus == .blocked,
              Set(sortedProducts) == Set(Self.requiredProductTypes),
              Set(sortedStrategies) == Set(Self.requiredStrategies),
              gates.map(\.gate) == ReleaseV030CLIRehearsalGate.allCases,
              gates.allSatisfy(\.gateHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030CLIRehearsalSurface.evidence",
                expected: "GH-666 blocked CLI rehearsal status routed through CommandGateway",
                actual: "\(gates.count)"
            )
        }
        for forbidden in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("accountEndpointRead", accountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("bypassesCommandGateway", bypassesCommandGateway),
            ("startsNextMilestone", startsNextMilestone)
        ] where forbidden.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030CLIRehearsalSurface.\(forbidden.0)")
        }

        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.upstreamPortfolioProjectionAnchor = upstreamPortfolioProjectionAnchor
        self.validationAnchor = validationAnchor
        self.runStatus = runStatus
        self.productTypes = sortedProducts
        self.strategies = sortedStrategies
        self.gates = gates
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.accountEndpointRead = accountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.bypassesCommandGateway = bypassesCommandGateway
        self.startsNextMilestone = startsNextMilestone
    }

    public var failureReasons: [String] {
        gates.map(\.failureReason)
    }

    public var killSwitchStatus: ReleaseV030CLIRehearsalStatus {
        gates.first { $0.gate == .killSwitch }?.status ?? .blocked
    }

    public var noTradeStatus: ReleaseV030CLIRehearsalStatus {
        gates.first { $0.gate == .noTrade }?.status ?? .blocked
    }

    public var cliBoundaryHeld: Bool {
        issueID.rawValue == "GH-666"
            && upstreamIssueID.rawValue == "GH-665"
            && downstreamIssueID.rawValue == "GH-667"
            && upstreamPortfolioProjectionAnchor == Self.requiredUpstreamPortfolioProjectionAnchor
            && validationAnchor == Self.requiredValidationAnchor
            && runStatus == .blocked
            && gates.allSatisfy(\.gateHeld)
            && productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && accountEndpointRead == false
            && brokerGatewayTouched == false
            && bypassesCommandGateway == false
            && startsNextMilestone == false
    }

    public static let requiredUpstreamPortfolioProjectionAnchor =
        "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL"
    public static let requiredValidationAnchor = "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"
    /// GH-685 固定 `mtpro rehearsal-status` 的 v0.3.x product boundary。
    ///
    /// 这里不能使用产品枚举全集，否则未来新增 product type 时 CLI evidence 会
    /// 静默扩大 release v0.3.x 范围。
    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    /// GH-685 固定 `mtpro rehearsal-status` 的 v0.3.x strategy boundary。
    public static let requiredStrategies: [ReleaseV030CLIRehearsalStrategyKind] = [.ema, .rsi]
}

/// ReleaseV030CLIRehearsalSurface 生成 `mtpro rehearsal-status` 的本地 deterministic 输出。
public enum ReleaseV030CLIRehearsalSurface {
    public static let cliCommand = "rehearsal-status"

    public static func deterministicEvidence() throws -> ReleaseV030CLIRehearsalSurfaceEvidence {
        try ReleaseV030CLIRehearsalSurfaceEvidence(gates: deterministicGates())
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments == [cliCommand] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.rehearsal.arguments",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        let evidence = try deterministicEvidence()
        let gates = evidence.gates.map { "\($0.gate.rawValue)=\($0.status.rawValue)" }.joined(separator: ",")
        let failureReasons = evidence.failureReasons.joined(separator: " | ")
        let productTypes = evidence.productTypes.map(\.rawValue).joined(separator: ",")
        let strategies = evidence.strategies.map(\.rawValue).joined(separator: ",")
        return [
            "mtpro \(cliCommand) \(evidence.runStatus.rawValue)",
            "issue=\(evidence.issueID.rawValue)",
            "upstream=\(evidence.upstreamIssueID.rawValue)",
            "commandGateway=required",
            "validationAnchor=\(evidence.validationAnchor)",
            "productTypes=\(productTypes)",
            "strategies=\(strategies)",
            "gates=\(gates)",
            "failureReasons=\(failureReasons)",
            "killSwitchStatus=\(evidence.killSwitchStatus.rawValue)",
            "noTradeStatus=\(evidence.noTradeStatus.rawValue)",
            "commandsRouteThroughCommandGateway=true",
            "productionTradingEnabledByDefault=false",
            "productionEndpointAutoConnect=false",
            "productionSecretAutoRead=false",
            "productionOrderSubmission=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=\(evidence.cliBoundaryHeld)"
        ].joined(separator: "\n")
    }

    private static func deterministicGates() throws -> [ReleaseV030CLIRehearsalGateRecord] {
        try ReleaseV030CLIRehearsalGate.allCases.map { gate in
            let status: ReleaseV030CLIRehearsalStatus = (gate == .killSwitch || gate == .noTrade) ? .blocked : .ready
            return try ReleaseV030CLIRehearsalGateRecord(
                gate: gate,
                status: status,
                failureReason: failureReason(for: gate, status: status)
            )
        }
    }

    private static func failureReason(
        for gate: ReleaseV030CLIRehearsalGate,
        status: ReleaseV030CLIRehearsalStatus
    ) -> String {
        switch (gate, status) {
        case (.killSwitch, .blocked):
            return "kill switch active; rehearsal command remains blocked"
        case (.noTrade, .blocked):
            return "global no-trade state active; production command remains disabled"
        case (.commandGateway, .ready):
            return "CommandGateway route visible; direct CLI bypass forbidden"
        case (.riskEngine, .ready):
            return "RiskEngine gate evidence visible"
        case (.executionEngine, .ready):
            return "ExecutionEngine gate evidence visible"
        case (.oms, .ready):
            return "OMS gate evidence visible"
        case (.eventStore, .ready):
            return "Event Store replay evidence visible"
        case (.portfolioProjection, .ready):
            return "Portfolio projection rehearsal evidence visible"
        case (_, .ready):
            return "\(gate.rawValue) gate evidence visible"
        case (_, .blocked):
            return "\(gate.rawValue) gate blocks unsafe command"
        }
    }
}
