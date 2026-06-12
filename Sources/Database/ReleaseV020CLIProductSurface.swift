import DomainModel
import Foundation

/// ReleaseV020CLIProductSurfaceCommand 固定 GH-593 允许暴露的 mtpro CLI 子命令。
///
/// 这些命令只产出本地 deterministic evidence，用于验证 Spot / Perp / strategy / risk /
/// execution / verify 产品表面已接入 CommandGateway gate。它们不读取 secret、不连接
/// endpoint、不调用 broker，也不提交、取消或替换真实订单。
public enum ReleaseV020CLIProductSurfaceCommand: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spot
    case perp
    case strategy
    case risk
    case execution
    case verifyFast = "verify-fast"
    case verifyRelease = "verify-release"
}

/// ReleaseV020CLIVerificationMode 表示 mtpro CLI 的两个验收入口。
public enum ReleaseV020CLIVerificationMode: String, Codable, Equatable, Hashable, Sendable {
    case verifyFast = "verify-fast"
    case verifyRelease = "verify-release"
}

/// ReleaseV020CLICommandRecord 是 GH-593 每个 CLI surface command 的 gate 记录。
///
/// 每条记录必须声明它经过 CommandGateway gate，并保持 RiskEngine、ExecutionEngine、
/// OMS、Event Store、kill switch 和 no-trade gate 不可绕过。`perp` 只是 USD-M
/// Perpetual 的 CLI 缩写，不引入第三 product type。
public struct ReleaseV020CLICommandRecord: Codable, Equatable, Sendable {
    public let command: ReleaseV020CLIProductSurfaceCommand
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV020GoldenTraceStrategy]
    public let sourceEvidenceAnchor: String
    public let routesThroughCommandGateway: Bool
    public let usesGoldenTraceCatalog: Bool
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
        command: ReleaseV020CLIProductSurfaceCommand,
        productTypes: [ProductType],
        strategies: [ReleaseV020GoldenTraceStrategy],
        sourceEvidenceAnchor: String,
        routesThroughCommandGateway: Bool = true,
        usesGoldenTraceCatalog: Bool = true,
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
        let normalizedProducts = productTypes.sorted { $0.rawValue < $1.rawValue }
        let normalizedStrategies = strategies.sorted { $0.rawValue < $1.rawValue }
        guard normalizedProducts.isEmpty == false,
              Set(normalizedProducts).isSubset(of: Set(ProductType.allCases)),
              normalizedProducts.count == Set(normalizedProducts).count,
              normalizedStrategies.count == Set(normalizedStrategies).count,
              Set(normalizedStrategies).isSubset(of: Set(ReleaseV020GoldenTraceStrategy.allCases)),
              sourceEvidenceAnchor.isEmpty == false,
              routesThroughCommandGateway,
              usesGoldenTraceCatalog else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020CLIProductSurface.commandRecord",
                expected: "CommandGateway-routed deterministic CLI evidence",
                actual: command.rawValue
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
                "releaseV020CLIProductSurface.\(forbiddenFlag.0)"
            )
        }

        self.command = command
        self.productTypes = normalizedProducts
        self.strategies = normalizedStrategies
        self.sourceEvidenceAnchor = sourceEvidenceAnchor
        self.routesThroughCommandGateway = routesThroughCommandGateway
        self.usesGoldenTraceCatalog = usesGoldenTraceCatalog
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

    public var commandBoundaryHeld: Bool {
        productTypes.isEmpty == false
            && Set(productTypes).isSubset(of: Set(ProductType.allCases))
            && productTypes.count == Set(productTypes).count
            && strategies.count == Set(strategies).count
            && Set(strategies).isSubset(of: Set(ReleaseV020GoldenTraceStrategy.allCases))
            && sourceEvidenceAnchor.isEmpty == false
            && routesThroughCommandGateway
            && usesGoldenTraceCatalog
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

/// ReleaseV020CLIProductSurfaceEvidence 汇总 GH-593 的 CLI product surface gate。
public struct ReleaseV020CLIProductSurfaceEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let cliProductName: String
    public let executableTargetName: String
    public let commands: [ReleaseV020CLICommandRecord]
    public let validationAnchors: [String]
    public let verifyFastPasses: Bool
    public let verifyReleasePasses: Bool
    public let commandGatewayRequired: Bool
    public let cliVenue: Identifier
    public let cliProductTypes: [ProductType]
    public let cliStrategies: [ReleaseV020GoldenTraceStrategy]
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
        evidenceID: Identifier = Identifier.constant("gh-593-cli-product-surface-evidence"),
        issueID: Identifier = Identifier.constant("GH-593"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-592")],
        cliProductName: String = "mtpro",
        executableTargetName: String = "MTPROCLI",
        commands: [ReleaseV020CLICommandRecord],
        validationAnchors: [String] = ReleaseV020CLIProductSurface.requiredValidationAnchors,
        verifyFastPasses: Bool = true,
        verifyReleasePasses: Bool = true,
        commandGatewayRequired: Bool = true,
        cliVenue: Identifier = Identifier.constant("binance"),
        cliProductTypes: [ProductType] = ProductType.allCases,
        cliStrategies: [ReleaseV020GoldenTraceStrategy] = ReleaseV020GoldenTraceStrategy.allCases,
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
        let sortedCommands = commands.sortedByReleaseV020CLICommandOrder()
        guard issueID.rawValue == "GH-593",
              upstreamIssueIDs.map(\.rawValue) == ["GH-592"],
              cliProductName == "mtpro",
              executableTargetName == "MTPROCLI",
              sortedCommands.map(\.command) == ReleaseV020CLIProductSurface.requiredCommandSequence,
              sortedCommands.allSatisfy(\.commandBoundaryHeld),
              validationAnchors == ReleaseV020CLIProductSurface.requiredValidationAnchors,
              cliVenue.rawValue == "binance",
              Set(cliProductTypes) == Set(ProductType.allCases),
              Set(cliStrategies) == Set(ReleaseV020GoldenTraceStrategy.allCases),
              verifyFastPasses,
              verifyReleasePasses,
              commandGatewayRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020CLIProductSurface.evidence",
                expected: "mtpro CLI surface routed through CommandGateway gate",
                actual: "\(commands.count)"
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
                "releaseV020CLIProductSurface.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.cliProductName = cliProductName
        self.executableTargetName = executableTargetName
        self.commands = sortedCommands
        self.validationAnchors = validationAnchors
        self.verifyFastPasses = verifyFastPasses
        self.verifyReleasePasses = verifyReleasePasses
        self.commandGatewayRequired = commandGatewayRequired
        self.cliVenue = cliVenue
        self.cliProductTypes = cliProductTypes.sorted { $0.rawValue < $1.rawValue }
        self.cliStrategies = cliStrategies.sorted { $0.rawValue < $1.rawValue }
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

    public var commandNames: [String] {
        commands.map(\.command.rawValue)
    }

    public var surfaceBoundaryHeld: Bool {
        issueID.rawValue == "GH-593"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-592"]
            && cliProductName == "mtpro"
            && executableTargetName == "MTPROCLI"
            && commands.map(\.command) == ReleaseV020CLIProductSurface.requiredCommandSequence
            && commands.allSatisfy(\.commandBoundaryHeld)
            && validationAnchors == ReleaseV020CLIProductSurface.requiredValidationAnchors
            && verifyFastPasses
            && verifyReleasePasses
            && commandGatewayRequired
            && cliVenue.rawValue == "binance"
            && Set(cliProductTypes) == Set(ProductType.allCases)
            && Set(cliStrategies) == Set(ReleaseV020GoldenTraceStrategy.allCases)
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

/// ReleaseV020CLIVerificationResult 是 mtpro verify-fast / verify-release 的稳定输出模型。
public struct ReleaseV020CLIVerificationResult: Codable, Equatable, Sendable {
    public let mode: ReleaseV020CLIVerificationMode
    public let status: String
    public let evidence: ReleaseV020CLIProductSurfaceEvidence
    public let verificationGates: ReleaseV020VerificationGateEvidence

    public var passed: Bool {
        status == "pass"
            && evidence.surfaceBoundaryHeld
            && verificationGates.gateBoundaryHeld
            && (
                (mode == .verifyFast && verificationGates.verifyFastPasses)
                    || (mode == .verifyRelease && verificationGates.verifyReleasePasses)
            )
    }
}

/// ReleaseV020CLIProductSurface 生成 GH-593 deterministic CLI surface evidence。
public enum ReleaseV020CLIProductSurface {
    public static let requiredCommandSequence: [ReleaseV020CLIProductSurfaceCommand] = [
        .spot,
        .perp,
        .strategy,
        .risk,
        .execution,
        .verifyFast,
        .verifyRelease
    ]

    public static let requiredValidationAnchors = [
        "GH-593-CLI-PRODUCT-SURFACE",
        "GH-593-MTPRO-VERIFY-FAST-PASS",
        "GH-593-MTPRO-VERIFY-RELEASE-PASS",
        "GH-593-COMMANDGATEWAY-ROUTING-GATE",
        "GH-593-NO-PRODUCTION-CLI-SIDE-EFFECT",
        "TVM-RELEASE-V020-CLI-PRODUCT-SURFACE"
    ]

    public static func deterministicEvidence() throws -> ReleaseV020CLIProductSurfaceEvidence {
        _ = try ReleaseV020GoldenTraceCatalog.deterministicEvidence()
        return try ReleaseV020CLIProductSurfaceEvidence(commands: deterministicCommands())
    }

    public static func verify(
        arguments: [String],
        evidence: ReleaseV020CLIProductSurfaceEvidence? = nil
    ) throws -> ReleaseV020CLIVerificationResult {
        let resolvedEvidence = try evidence ?? deterministicEvidence()
        guard arguments.count == 1 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.arguments",
                expected: "verify-fast or verify-release",
                actual: arguments.joined(separator: " ")
            )
        }
        guard let mode = ReleaseV020CLIVerificationMode(rawValue: arguments[0]) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.command",
                expected: "verify-fast or verify-release",
                actual: arguments[0]
            )
        }

        switch mode {
        case .verifyFast where resolvedEvidence.verifyFastPasses:
            let verificationGates = try ReleaseV020VerificationGates.deterministicEvidence()
            guard verificationGates.verifyFastPasses else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "mtpro.verify-fast.gate",
                    expected: "foundation + sample traces coverage",
                    actual: "fail"
                )
            }
            return ReleaseV020CLIVerificationResult(
                mode: mode,
                status: "pass",
                evidence: resolvedEvidence,
                verificationGates: verificationGates
            )
        case .verifyRelease where resolvedEvidence.verifyReleasePasses:
            let verificationGates = try ReleaseV020VerificationGates.deterministicEvidence()
            guard verificationGates.verifyReleasePasses else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "mtpro.verify-release.gate",
                    expected: "full gates + all traces coverage",
                    actual: "fail"
                )
            }
            return ReleaseV020CLIVerificationResult(
                mode: mode,
                status: "pass",
                evidence: resolvedEvidence,
                verificationGates: verificationGates
            )
        default:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mtpro.\(mode.rawValue)",
                expected: "pass",
                actual: "fail"
            )
        }
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        let result = try verify(arguments: arguments)
        let upstreamIssues = result.evidence.upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
        let commands = result.evidence.commandNames.joined(separator: ",")
        let cliProductTypes = result.evidence.cliProductTypes.map(\.rawValue).joined(separator: ",")
        let cliStrategies = result.evidence.cliStrategies.map(\.rawValue).joined(separator: ",")
        let coverage = result.mode == .verifyFast
            ? result.verificationGates.verifyFast
            : result.verificationGates.verifyRelease
        let verifyCoverage = coverage.sectionLabels.joined(separator: ",")
        let verifyTraceKinds = coverage.traceKindLabels.joined(separator: ",")
        return [
            "mtpro \(result.mode.rawValue) \(result.status)",
            "issue=\(result.evidence.issueID.rawValue)",
            "verificationIssue=\(result.verificationGates.issueID.rawValue)",
            "upstream=\(upstreamIssues)",
            "cliProduct=\(result.evidence.cliProductName)",
            "executableTarget=\(result.evidence.executableTargetName)",
            "commandGateway=required",
            "commands=\(commands)",
            "verifyCoverage=\(verifyCoverage)",
            "verifyTraceCount=\(coverage.traceKinds.count)",
            "verifyCatalogTraceCount=\(result.verificationGates.catalogTraceCount)",
            "verifyTraceKinds=\(verifyTraceKinds)",
            "verifyGateBoundaryHeld=\(result.verificationGates.gateBoundaryHeld)",
            "cliVenue=\(result.evidence.cliVenue.rawValue)",
            "cliProductTypes=\(cliProductTypes)",
            "cliStrategies=\(cliStrategies)",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointTouched=false",
            "brokerGatewayTouched=false",
            "accountEndpointRead=false",
            "realOrderSubmitCancelReplace=false",
            "boundaryHeld=\(result.evidence.surfaceBoundaryHeld)"
        ].joined(separator: "\n")
    }

    private static func deterministicCommands() throws -> [ReleaseV020CLICommandRecord] {
        try [
            makeCommand(
                command: .spot,
                productTypes: [.spot],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-573-GH-579-GH-581-GH-587-SPOT-CLI-SURFACE"
            ),
            makeCommand(
                command: .perp,
                productTypes: [.usdsPerpetual],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-574-GH-575-GH-580-GH-582-GH-588-PERP-CLI-SURFACE"
            ),
            makeCommand(
                command: .strategy,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-569-GH-570-GH-571-GH-576-GH-577-STRATEGY-CLI-SURFACE"
            ),
            makeCommand(
                command: .risk,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-578-GH-579-GH-580-RISK-CLI-SURFACE"
            ),
            makeCommand(
                command: .execution,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-581-GH-582-GH-583-GH-584-GH-585-GH-586-EXECUTION-CLI-SURFACE"
            ),
            makeCommand(
                command: .verifyFast,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-593-MTPRO-VERIFY-FAST-PASS"
            ),
            makeCommand(
                command: .verifyRelease,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-593-MTPRO-VERIFY-RELEASE-PASS"
            )
        ]
    }

    private static func makeCommand(
        command: ReleaseV020CLIProductSurfaceCommand,
        productTypes: [ProductType],
        strategies: [ReleaseV020GoldenTraceStrategy],
        sourceEvidenceAnchor: String
    ) throws -> ReleaseV020CLICommandRecord {
        try ReleaseV020CLICommandRecord(
            command: command,
            productTypes: productTypes,
            strategies: strategies,
            sourceEvidenceAnchor: sourceEvidenceAnchor
        )
    }
}

private extension Array where Element == ReleaseV020CLICommandRecord {
    func sortedByReleaseV020CLICommandOrder() -> [ReleaseV020CLICommandRecord] {
        sorted { lhs, rhs in
            guard let lhsIndex = ReleaseV020CLIProductSurface.requiredCommandSequence.firstIndex(of: lhs.command),
                  let rhsIndex = ReleaseV020CLIProductSurface.requiredCommandSequence.firstIndex(of: rhs.command) else {
                return lhs.command.rawValue < rhs.command.rawValue
            }
            return lhsIndex < rhsIndex
        }
    }
}
