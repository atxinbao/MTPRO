import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV010DryRunTestnetValidationStage 固定 GH-537 release validation suite 的阶段。
///
/// Stage 只描述本地 deterministic dry-run / Binance testnet evidence 检查顺序；它不启动真实网络、
/// 不读取 credential value、不连接 production broker，也不提交真实订单。
public enum ReleaseV010DryRunTestnetValidationStage:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case dryRunEndToEnd = "dry-run end-to-end"
    case testnetSubmitCancelReplace = "testnet submit/cancel/replace"
    case executionReportBrokerFill = "execution report/broker fill"
    case reconciliationPortfolioUpdate = "reconciliation/portfolio update"
    case killSwitchNoTradeRollback = "kill switch/no-trade/rollback"
}

/// ReleaseV010DryRunTestnetValidationStep 是 GH-537 单个 validation step 的审计摘要。
///
/// Step 必须只引用 release v0.1.0 上游 deterministic evidence。失败只产生 validation failure，
/// 不能被映射成 production order、broker fallback、repair command 或 automatic rollback。
public struct ReleaseV010DryRunTestnetValidationStep: Codable, Equatable, Sendable {
    public let stage: ReleaseV010DryRunTestnetValidationStage
    public let sourceIssueIDs: [String]
    public let evidenceIDs: [String]
    public let expectedRecordCount: Int
    public let actualRecordCount: Int
    public let repeatable: Bool
    public let validationPassed: Bool
    public let failureTriggersProductionOrder: Bool
    public let readsProductionSecret: Bool
    public let connectsProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let authorizesTradingExecution: Bool

    public init(
        stage: ReleaseV010DryRunTestnetValidationStage,
        sourceIssueIDs: [String],
        evidenceIDs: [String],
        expectedRecordCount: Int,
        actualRecordCount: Int,
        repeatable: Bool = true,
        validationPassed: Bool = true,
        failureTriggersProductionOrder: Bool = false,
        readsProductionSecret: Bool = false,
        connectsProductionEndpoint: Bool = false,
        connectsBroker: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        guard sourceIssueIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIssueIDs",
                expected: "non-empty GH-537 source issues",
                actual: "empty"
            )
        }
        guard evidenceIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidenceIDs",
                expected: "non-empty GH-537 evidence IDs",
                actual: "empty"
            )
        }
        guard expectedRecordCount == actualRecordCount, actualRecordCount > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordCount",
                expected: "\(expectedRecordCount)",
                actual: "\(actualRecordCount)"
            )
        }
        for requiredFlag in [
            ("repeatable", repeatable),
            ("validationPassed", validationPassed)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("failureTriggersProductionOrder", failureTriggersProductionOrder),
            ("readsProductionSecret", readsProductionSecret),
            ("connectsProductionEndpoint", connectsProductionEndpoint),
            ("connectsBroker", connectsBroker),
            ("authorizesTradingExecution", authorizesTradingExecution)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Validation.\(forbiddenFlag.0)")
        }

        self.stage = stage
        self.sourceIssueIDs = sourceIssueIDs
        self.evidenceIDs = evidenceIDs
        self.expectedRecordCount = expectedRecordCount
        self.actualRecordCount = actualRecordCount
        self.repeatable = repeatable
        self.validationPassed = validationPassed
        self.failureTriggersProductionOrder = failureTriggersProductionOrder
        self.readsProductionSecret = readsProductionSecret
        self.connectsProductionEndpoint = connectsProductionEndpoint
        self.connectsBroker = connectsBroker
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var stepBoundaryHeld: Bool {
        sourceIssueIDs.isEmpty == false
            && evidenceIDs.isEmpty == false
            && expectedRecordCount == actualRecordCount
            && actualRecordCount > 0
            && repeatable
            && validationPassed
            && [
                failureTriggersProductionOrder,
                readsProductionSecret,
                connectsProductionEndpoint,
                connectsBroker,
                authorizesTradingExecution
            ].allSatisfy { $0 == false }
    }
}

/// ReleaseV010DryRunTestnetValidationEvidence 是 GH-537 的最终 suite evidence。
/// `GH-537-BINANCE-DRYRUN-TESTNET-VALIDATION-SUITE`
/// `TVM-RELEASE-V010-BINANCE-DRYRUN-TESTNET-VALIDATION`
public struct ReleaseV010DryRunTestnetValidationEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let validationCommand: String
    public let steps: [ReleaseV010DryRunTestnetValidationStep]
    public let commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence
    public let parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence
    public let reconciliationEvidence: ReleaseV010PortfolioReconciliationUpdateEvidence
    public let validationAnchors: [String]
    public let dryRunEndToEndRepeatable: Bool
    public let testnetSubmitCancelReplaceCovered: Bool
    public let executionReportFillReconciliationCovered: Bool
    public let killSwitchNoTradeRollbackRequired: Bool
    public let failureTriggersProductionOrder: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool
    public let authorizesTradingExecution: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-537"
            && upstreamIssueIDs.map(\.rawValue) == Self.requiredUpstreamIssueIDs.map(\.rawValue)
            && validationCommand == Self.requiredValidationCommand
            && steps.map(\.stage) == ReleaseV010DryRunTestnetValidationStage.allCases
            && steps.allSatisfy(\.stepBoundaryHeld)
            && commandEvidence.evidenceBoundaryHeld
            && parserEvidence.evidenceBoundaryHeld
            && reconciliationEvidence.evidenceBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && dryRunEndToEndRepeatable
            && testnetSubmitCancelReplaceCovered
            && executionReportFillReconciliationCovered
            && killSwitchNoTradeRollbackRequired
            && [
                failureTriggersProductionOrder,
                productionTradingEnabledByDefault,
                productionSecretReadEnabledByDefault,
                productionEndpointConnectionEnabledByDefault,
                brokerGatewayTouched,
                nonBinanceVenueEnabled,
                nonEMAStrategyEnabled,
                authorizesTradingExecution
            ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-537-release-v010-dryrun-testnet-validation-evidence"),
        issueID: Identifier = Identifier.constant("GH-537"),
        upstreamIssueIDs: [Identifier] = Self.requiredUpstreamIssueIDs,
        validationCommand: String = Self.requiredValidationCommand,
        steps: [ReleaseV010DryRunTestnetValidationStep],
        commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence,
        parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence,
        reconciliationEvidence: ReleaseV010PortfolioReconciliationUpdateEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        dryRunEndToEndRepeatable: Bool = true,
        testnetSubmitCancelReplaceCovered: Bool = true,
        executionReportFillReconciliationCovered: Bool = true,
        killSwitchNoTradeRollbackRequired: Bool = true,
        failureTriggersProductionOrder: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionEndpointConnectionEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-537" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-537",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == Self.requiredUpstreamIssueIDs.map(\.rawValue) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: Self.requiredUpstreamIssueIDs.map(\.rawValue).joined(separator: ","),
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationCommand == Self.requiredValidationCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationCommand",
                expected: Self.requiredValidationCommand,
                actual: validationCommand
            )
        }
        guard steps.map(\.stage) == ReleaseV010DryRunTestnetValidationStage.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "steps",
                expected: ReleaseV010DryRunTestnetValidationStage.allCases.map(\.rawValue).joined(separator: ","),
                actual: steps.map { $0.stage.rawValue }.joined(separator: ",")
            )
        }
        guard steps.allSatisfy(\.stepBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "steps",
                expected: "all GH-537 validation steps held",
                actual: "mismatch"
            )
        }
        guard commandEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence",
                expected: "GH-531 command evidence held",
                actual: "mismatch"
            )
        }
        guard parserEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-532 parser evidence held",
                actual: "mismatch"
            )
        }
        guard reconciliationEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reconciliationEvidence",
                expected: "GH-533 reconciliation evidence held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("dryRunEndToEndRepeatable", dryRunEndToEndRepeatable),
            ("testnetSubmitCancelReplaceCovered", testnetSubmitCancelReplaceCovered),
            ("executionReportFillReconciliationCovered", executionReportFillReconciliationCovered),
            ("killSwitchNoTradeRollbackRequired", killSwitchNoTradeRollbackRequired)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("failureTriggersProductionOrder", failureTriggersProductionOrder),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("productionEndpointConnectionEnabledByDefault", productionEndpointConnectionEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("nonEMAStrategyEnabled", nonEMAStrategyEnabled),
            ("authorizesTradingExecution", authorizesTradingExecution)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Validation.\(forbiddenFlag.0)")
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.validationCommand = validationCommand
        self.steps = steps
        self.commandEvidence = commandEvidence
        self.parserEvidence = parserEvidence
        self.reconciliationEvidence = reconciliationEvidence
        self.validationAnchors = validationAnchors
        self.dryRunEndToEndRepeatable = dryRunEndToEndRepeatable
        self.testnetSubmitCancelReplaceCovered = testnetSubmitCancelReplaceCovered
        self.executionReportFillReconciliationCovered = executionReportFillReconciliationCovered
        self.killSwitchNoTradeRollbackRequired = killSwitchNoTradeRollbackRequired
        self.failureTriggersProductionOrder = failureTriggersProductionOrder
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public static let requiredUpstreamIssueIDs = [
        Identifier.constant("GH-531"),
        Identifier.constant("GH-532"),
        Identifier.constant("GH-533"),
        Identifier.constant("GH-536")
    ]

    public static let requiredValidationCommand = "bash checks/release-v0.1.0-dryrun-testnet.sh"

    public static let requiredValidationAnchors = [
        "GH-537-BINANCE-DRYRUN-TESTNET-VALIDATION-SUITE",
        "GH-537-DRYRUN-END-TO-END",
        "GH-537-TESTNET-SUBMIT-CANCEL-REPLACE",
        "GH-537-EXECUTION-REPORT-FILL-RECONCILIATION-CHECKS",
        "GH-537-NO-PRODUCTION-ORDER-ON-FAILURE",
        "TVM-RELEASE-V010-BINANCE-DRYRUN-TESTNET-VALIDATION"
    ]
}

/// ReleaseV010DryRunTestnetValidationSuite 组合 GH-531 / GH-532 / GH-533 / GH-536 evidence。
///
/// Suite 是 release validation 的本地 deterministic builder。它不发网络请求，不读取真实凭证，
/// 不调用 production endpoint，不连接 broker，不写 production OMS，也不产生真实 submit / cancel / replace。
public struct ReleaseV010DryRunTestnetValidationSuite: Codable, Equatable, Sendable {
    public let suiteID: Identifier
    public let commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence
    public let parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence
    public let reconciliationEvidence: ReleaseV010PortfolioReconciliationUpdateEvidence
    public let validationAnchors: [String]

    public init(
        suiteID: Identifier = Identifier.constant("gh-537-release-v010-dryrun-testnet-validation-suite"),
        commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence? = nil,
        parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence? = nil,
        reconciliationEvidence: ReleaseV010PortfolioReconciliationUpdateEvidence? = nil,
        validationAnchors: [String] = ReleaseV010DryRunTestnetValidationEvidence.requiredValidationAnchors
    ) throws {
        let resolvedCommandEvidence = try commandEvidence
            ?? ReleaseV010BinanceExecutionClientTestnetAdapter.deterministicFixture()
                .deterministicCommandEvidence()
        let resolvedParserEvidence = try parserEvidence
            ?? ReleaseV010BinanceExecutionReportParser(
                commandEvidence: resolvedCommandEvidence
            ).deterministicParserEvidence()
        let resolvedReconciliationEvidence = try reconciliationEvidence
            ?? ReleaseV010PortfolioReconciliationUpdatePath(
                parserEvidence: resolvedParserEvidence
            ).deterministicEvidence()

        guard resolvedCommandEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence",
                expected: "GH-531 command evidence held",
                actual: "mismatch"
            )
        }
        guard resolvedParserEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-532 parser evidence held",
                actual: "mismatch"
            )
        }
        guard resolvedReconciliationEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reconciliationEvidence",
                expected: "GH-533 reconciliation evidence held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV010DryRunTestnetValidationEvidence.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010DryRunTestnetValidationEvidence.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.suiteID = suiteID
        self.commandEvidence = resolvedCommandEvidence
        self.parserEvidence = resolvedParserEvidence
        self.reconciliationEvidence = resolvedReconciliationEvidence
        self.validationAnchors = validationAnchors
    }

    public var suiteBoundaryHeld: Bool {
        commandEvidence.evidenceBoundaryHeld
            && parserEvidence.evidenceBoundaryHeld
            && reconciliationEvidence.evidenceBoundaryHeld
            && validationAnchors == ReleaseV010DryRunTestnetValidationEvidence.requiredValidationAnchors
    }

    public func deterministicValidationEvidence() throws -> ReleaseV010DryRunTestnetValidationEvidence {
        try ReleaseV010DryRunTestnetValidationEvidence(
            steps: [
                dryRunStep(),
                testnetCommandStep(),
                executionReportStep(),
                reconciliationStep(),
                killSwitchNoTradeStep()
            ],
            commandEvidence: commandEvidence,
            parserEvidence: parserEvidence,
            reconciliationEvidence: reconciliationEvidence,
            validationAnchors: validationAnchors
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010DryRunTestnetValidationSuite {
        try ReleaseV010DryRunTestnetValidationSuite()
    }

    private func dryRunStep() throws -> ReleaseV010DryRunTestnetValidationStep {
        try ReleaseV010DryRunTestnetValidationStep(
            stage: .dryRunEndToEnd,
            sourceIssueIDs: ["GH-531", "GH-532", "GH-533", "GH-536"],
            evidenceIDs: [
                commandEvidence.evidenceID.rawValue,
                parserEvidence.evidenceID.rawValue,
                reconciliationEvidence.evidenceID.rawValue,
                "gh-536-release-v010-kill-switch-no-trade-rollback-surface"
            ],
            expectedRecordCount: 14,
            actualRecordCount: commandEvidence.requests.count
                + commandEvidence.acknowledgements.count
                + parserEvidence.parsedEvents.count
                + reconciliationEvidence.records.count
        )
    }

    private func testnetCommandStep() throws -> ReleaseV010DryRunTestnetValidationStep {
        try ReleaseV010DryRunTestnetValidationStep(
            stage: .testnetSubmitCancelReplace,
            sourceIssueIDs: ["GH-531"],
            evidenceIDs: commandEvidence.requests.map(\.requestID.rawValue)
                + commandEvidence.acknowledgements.map(\.ackID.rawValue),
            expectedRecordCount: 6,
            actualRecordCount: commandEvidence.requests.count + commandEvidence.acknowledgements.count
        )
    }

    private func executionReportStep() throws -> ReleaseV010DryRunTestnetValidationStep {
        try ReleaseV010DryRunTestnetValidationStep(
            stage: .executionReportBrokerFill,
            sourceIssueIDs: ["GH-532"],
            evidenceIDs: parserEvidence.parsedEvents.map(\.eventID.rawValue)
                + parserEvidence.invalidReports.map(\.evidenceID.rawValue),
            expectedRecordCount: 6,
            actualRecordCount: parserEvidence.parsedEvents.count + parserEvidence.invalidReports.count
        )
    }

    private func reconciliationStep() throws -> ReleaseV010DryRunTestnetValidationStep {
        try ReleaseV010DryRunTestnetValidationStep(
            stage: .reconciliationPortfolioUpdate,
            sourceIssueIDs: ["GH-533"],
            evidenceIDs: reconciliationEvidence.records.map(\.recordID.rawValue),
            expectedRecordCount: 4,
            actualRecordCount: reconciliationEvidence.records.count
        )
    }

    private func killSwitchNoTradeStep() throws -> ReleaseV010DryRunTestnetValidationStep {
        try ReleaseV010DryRunTestnetValidationStep(
            stage: .killSwitchNoTradeRollback,
            sourceIssueIDs: ["GH-536"],
            evidenceIDs: [
                "GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS",
                "GH-536-SUBMIT-CANCEL-REPLACE-BLOCKED",
                "GH-536-ROLLBACK-OPERATOR-EVIDENCE"
            ],
            expectedRecordCount: 3,
            actualRecordCount: 3
        )
    }
}
