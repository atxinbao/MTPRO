import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ReleaseV0140FullE2ETestnetSuiteMatrixCase 是 GH-1038 单个 product / strategy E2E case。
///
/// case 只汇总本地 testnet evidence，不保存 credential，不创建网络请求，也不表示 production
/// submit / cancel / replace 已经被授权。
public struct ReleaseV0140FullE2ETestnetSuiteMatrixCase: Codable, Equatable, Sendable {
    public let caseID: Identifier
    public let productType: ProductType
    public let strategy: OrderIntentStrategyKind
    public let targetExposure: TargetExposureIntent
    public let sourceSequence: Int
    public let signalID: Identifier
    public let pipelineReportID: Identifier
    public let completedStages: [ReleaseV0140SignalToExecutionPipelineStage]
    public let riskOutcome: ReleaseV0140PreTradeRiskOutcome
    public let reconciliationStatus: ReleaseV0140ReconciliationStatus?
    public let e2eTestnetEvidencePassed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        caseID: Identifier,
        productType: ProductType,
        strategy: OrderIntentStrategyKind,
        targetExposure: TargetExposureIntent,
        sourceSequence: Int,
        signalID: Identifier,
        pipelineReport: ReleaseV0140SignalToExecutionPipelineReport,
        e2eTestnetEvidencePassed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        guard OrderIntent.activeProductTypes.contains(productType),
              OrderIntent.activeStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.nonReleaseMatrixCase")
        }
        guard targetExposure.isPreOrderAllowed(for: productType), targetExposure.requiresOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.targetExposure",
                expected: "pre-order exposure allowed for \(productType.rawValue)",
                actual: targetExposure.rawValue
            )
        }
        guard sourceSequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.sourceSequence",
                expected: "positive sequence",
                actual: "\(sourceSequence)"
            )
        }
        guard pipelineReport.boundaryHeld,
              pipelineReport.status == .passed,
              pipelineReport.completedStages == ReleaseV0140SignalToExecutionPipelineReport.requiredPassedStages,
              pipelineReport.riskOutcome == .accepted,
              pipelineReport.reconciliationStatus == .passed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.pipelineReport",
                expected: "passed signal-to-reconciliation report",
                actual: "\(pipelineReport.status.rawValue):\(pipelineReport.riskOutcome.rawValue)"
            )
        }
        guard e2eTestnetEvidencePassed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.caseEvidence",
                expected: "passed",
                actual: "failed"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        guard caseID == Self.deterministicID(
            productType: productType,
            strategy: strategy,
            signalID: signalID,
            pipelineReportID: pipelineReport.reportID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.caseID",
                expected: Self.deterministicID(
                    productType: productType,
                    strategy: strategy,
                    signalID: signalID,
                    pipelineReportID: pipelineReport.reportID
                ).rawValue,
                actual: caseID.rawValue
            )
        }

        self.caseID = caseID
        self.productType = productType
        self.strategy = strategy
        self.targetExposure = targetExposure
        self.sourceSequence = sourceSequence
        self.signalID = signalID
        self.pipelineReportID = pipelineReport.reportID
        self.completedStages = pipelineReport.completedStages
        self.riskOutcome = pipelineReport.riskOutcome
        self.reconciliationStatus = pipelineReport.reconciliationStatus
        self.e2eTestnetEvidencePassed = e2eTestnetEvidencePassed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        OrderIntent.activeProductTypes.contains(productType)
            && OrderIntent.activeStrategies.contains(strategy)
            && targetExposure.isPreOrderAllowed(for: productType)
            && targetExposure.requiresOrderIntent
            && sourceSequence > 0
            && completedStages == ReleaseV0140SignalToExecutionPipelineReport.requiredPassedStages
            && riskOutcome == .accepted
            && reconciliationStatus == .passed
            && e2eTestnetEvidencePassed
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    public static func deterministicID(
        productType: ProductType,
        strategy: OrderIntentStrategyKind,
        signalID: Identifier,
        pipelineReportID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1038-e2e-case:\(productType.rawValue):\(strategy.rawValue):\(signalID.rawValue):\(pipelineReportID.rawValue)",
            field: "releaseV0140FullE2E.caseID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.case.\(field)")
        }
    }
}

/// ReleaseV0140FullE2ETestnetSuiteReport 汇总 GH-1038 Spot / Perp x EMA / RSI 矩阵结果。
///
/// Report 要求四个 accepted matrix case 全部通过，并额外保留 production-requested
/// fail-closed report，证明生产交易请求不会进入 adapter、OMS 或 reconciliation。
public struct ReleaseV0140FullE2ETestnetSuiteReport: Codable, Equatable, Sendable {
    public let suiteID: Identifier
    public let matrixCases: [ReleaseV0140FullE2ETestnetSuiteMatrixCase]
    public let productionGuardReportID: Identifier
    public let productTypesCovered: [ProductType]
    public let strategiesCovered: [OrderIntentStrategyKind]
    public let acceptedCaseCount: Int
    public let productionGuardFailedClosed: Bool
    public let productionGuardStoppedBeforeAdapter: Bool
    public let readOnlyDashboardInputReady: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        suiteID: Identifier,
        matrixCases: [ReleaseV0140FullE2ETestnetSuiteMatrixCase],
        productionGuardReport: ReleaseV0140SignalToExecutionPipelineReport,
        readOnlyDashboardInputReady: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard matrixCases.count == Self.requiredMatrixCaseCount else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.matrixCaseCount",
                expected: "\(Self.requiredMatrixCaseCount)",
                actual: "\(matrixCases.count)"
            )
        }
        guard Set(matrixCases.map(\.productType)) == Set(Self.requiredProductTypes),
              Set(matrixCases.map(\.strategy)) == Set(Self.requiredStrategies),
              Set(matrixCases.map(Self.comboKey)) == Set(Self.requiredComboKeys) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.coverageMatrix",
                expected: Self.requiredComboKeys.sorted().joined(separator: ","),
                actual: matrixCases.map(Self.comboKey).sorted().joined(separator: ",")
            )
        }
        guard matrixCases.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.matrixBoundary",
                expected: "all cases boundary-held",
                actual: "boundary drift"
            )
        }
        guard productionGuardReport.boundaryHeld,
              productionGuardReport.status == .failedClosed,
              productionGuardReport.riskOutcome == .blocked,
              productionGuardReport.executionMappingID == nil,
              productionGuardReport.submitPathID == nil,
              productionGuardReport.localOrderID == nil,
              productionGuardReport.reconciliationReportID == nil,
              productionGuardReport.adapterSubmitEvidenceCreated == false,
              productionGuardReport.omsEventLogCreated == false,
              productionGuardReport.reconciliationCompleted == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.productionGuard",
                expected: "failed-closed before adapter / OMS / reconciliation",
                actual: "\(productionGuardReport.status.rawValue):\(productionGuardReport.riskOutcome.rawValue)"
            )
        }
        guard readOnlyDashboardInputReady else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.dashboardInput",
                expected: "read-only dashboard input ready",
                actual: "false"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        guard suiteID == Self.deterministicID(
            caseIDs: matrixCases.map(\.caseID),
            productionGuardReportID: productionGuardReport.reportID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.suiteID",
                expected: Self.deterministicID(
                    caseIDs: matrixCases.map(\.caseID),
                    productionGuardReportID: productionGuardReport.reportID
                ).rawValue,
                actual: suiteID.rawValue
            )
        }

        self.suiteID = suiteID
        self.matrixCases = matrixCases
        self.productionGuardReportID = productionGuardReport.reportID
        self.productTypesCovered = Self.requiredProductTypes
        self.strategiesCovered = Self.requiredStrategies
        self.acceptedCaseCount = matrixCases.count
        self.productionGuardFailedClosed = true
        self.productionGuardStoppedBeforeAdapter = true
        self.readOnlyDashboardInputReady = readOnlyDashboardInputReady
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        matrixCases.count == Self.requiredMatrixCaseCount
            && Set(matrixCases.map(\.productType)) == Set(Self.requiredProductTypes)
            && Set(matrixCases.map(\.strategy)) == Set(Self.requiredStrategies)
            && Set(matrixCases.map(Self.comboKey)) == Set(Self.requiredComboKeys)
            && matrixCases.allSatisfy(\.boundaryHeld)
            && acceptedCaseCount == Self.requiredMatrixCaseCount
            && productionGuardFailedClosed
            && productionGuardStoppedBeforeAdapter
            && readOnlyDashboardInputReady
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredStrategies: [OrderIntentStrategyKind] = [.ema, .rsi]
    public static let requiredMatrixCaseCount = 4
    public static let requiredValidationAnchors = [
        "GH-1038-FULL-E2E-TESTNET-SUITE",
        "GH-1038-SPOT-PERP-EMA-RSI-MATRIX",
        "GH-1038-PRODUCTION-GUARDS",
        "TVM-RELEASE-V0140-FULL-E2E-TESTNET-SUITE"
    ]

    public static var requiredComboKeys: [String] {
        requiredProductTypes.flatMap { productType in
            requiredStrategies.map { strategy in
                "\(productType.rawValue):\(strategy.rawValue)"
            }
        }
    }

    public static func deterministicID(
        caseIDs: [Identifier],
        productionGuardReportID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1038-full-e2e-suite:\(caseIDs.map(\.rawValue).joined(separator: "|")):\(productionGuardReportID.rawValue)",
            field: "releaseV0140FullE2E.suiteID"
        )
    }

    private static func comboKey(_ matrixCase: ReleaseV0140FullE2ETestnetSuiteMatrixCase) -> String {
        "\(matrixCase.productType.rawValue):\(matrixCase.strategy.rawValue)"
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.report.\(field)")
        }
    }
}

/// ReleaseV0140FullE2ETestnetSuite 运行 GH-1038 的本地 E2E testnet 矩阵。
///
/// Suite 复用 GH-1037 pipeline，不新增真实网络连接；它只证明 release v0.14.0 的
/// Binance Spot / USDⓈ-M Perpetual 与 EMA / RSI 能形成完整本地闭环证据。
public struct ReleaseV0140FullE2ETestnetSuite: Codable, Equatable, Sendable {
    public let pipeline: ReleaseV0140SignalToExecutionPipeline
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        pipeline: ReleaseV0140SignalToExecutionPipeline? = nil,
        validationAnchors: [String] = ReleaseV0140FullE2ETestnetSuiteReport.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        let resolvedPipeline: ReleaseV0140SignalToExecutionPipeline
        if let pipeline {
            resolvedPipeline = pipeline
        } else {
            resolvedPipeline = try ReleaseV0140SignalToExecutionPipeline()
        }
        guard resolvedPipeline.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.unheldPipeline")
        }
        guard validationAnchors == ReleaseV0140FullE2ETestnetSuiteReport.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FullE2E.suite.validationAnchors",
                expected: ReleaseV0140FullE2ETestnetSuiteReport.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.pipeline = resolvedPipeline
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        pipeline.boundaryHeld
            && validationAnchors == ReleaseV0140FullE2ETestnetSuiteReport.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    public func run() throws -> ReleaseV0140FullE2ETestnetSuiteReport {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.unheldSuite")
        }

        let matrixCases = try Self.matrixDefinitions.map { definition in
            let signal = try Self.makeSignal(
                productType: definition.productType,
                strategy: definition.strategy,
                targetExposure: definition.targetExposure,
                sourceSequence: definition.sourceSequence
            )
            let riskGate: ReleaseV0140PreTradeRiskEngineGate = try .deterministicFixture()
            let report = try pipeline.run(
                signal: signal,
                referencePrice: Self.referencePrice,
                riskGate: riskGate
            )
            return try ReleaseV0140FullE2ETestnetSuiteMatrixCase(
                caseID: ReleaseV0140FullE2ETestnetSuiteMatrixCase.deterministicID(
                    productType: definition.productType,
                    strategy: definition.strategy,
                    signalID: signal.signalID,
                    pipelineReportID: report.reportID
                ),
                productType: definition.productType,
                strategy: definition.strategy,
                targetExposure: definition.targetExposure,
                sourceSequence: definition.sourceSequence,
                signalID: signal.signalID,
                pipelineReport: report
            )
        }

        let productionGuardSignal = try Self.makeSignal(
            productType: .spot,
            strategy: .ema,
            targetExposure: .targetLong,
            sourceSequence: 10_038
        )
        let productionGuardRiskGate: ReleaseV0140PreTradeRiskEngineGate = try .deterministicFixture()
        let productionGuardReport = try pipeline.run(
            signal: productionGuardSignal,
            referencePrice: Self.referencePrice,
            riskGate: productionGuardRiskGate,
            productionTradingRequested: true
        )

        return try ReleaseV0140FullE2ETestnetSuiteReport(
            suiteID: ReleaseV0140FullE2ETestnetSuiteReport.deterministicID(
                caseIDs: matrixCases.map(\.caseID),
                productionGuardReportID: productionGuardReport.reportID
            ),
            matrixCases: matrixCases,
            productionGuardReport: productionGuardReport,
            validationAnchors: validationAnchors
        )
    }

    private static let referencePrice = 1_000.0

    private static let matrixDefinitions: [(productType: ProductType, strategy: OrderIntentStrategyKind, targetExposure: TargetExposureIntent, sourceSequence: Int)] = [
        (.spot, .ema, .targetLong, 1_038),
        (.spot, .rsi, .targetLong, 1_039),
        (.usdsPerpetual, .ema, .targetLong, 1_040),
        (.usdsPerpetual, .rsi, .targetShort, 1_041)
    ]

    private static func makeSignal(
        productType: ProductType,
        strategy: OrderIntentStrategyKind,
        targetExposure: TargetExposureIntent,
        sourceSequence: Int
    ) throws -> ReleaseV0140StrategySignalEnvelope {
        let symbol = Symbol.constant("BTCUSDT")
        let productAwareIntent = try ProductAwareOrderIntent(
            intentID: Identifier.constant(
                "gh-1038-product-aware:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
                field: "releaseV0140FullE2E.productAwareIntentID"
            ),
            instrument: InstrumentIdentity.binance(productType: productType, symbol: symbol),
            targetExposure: targetExposure,
            quantity: Quantity(0.025, field: "releaseV0140FullE2E.quantity"),
            referencePrice: Price(Self.referencePrice, field: "releaseV0140FullE2E.referencePrice"),
            createdAt: Date(timeIntervalSince1970: TimeInterval(sourceSequence))
        )
        let sourceMessageID = Identifier.constant(
            "gh-1038-message:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140FullE2E.sourceMessageID"
        )
        let strategyRunID = Identifier.constant(
            "gh-1038-run:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140FullE2E.strategyRunID"
        )

        return try ReleaseV0140StrategySignalEnvelope(
            signalID: ReleaseV0140StrategySignalEnvelope.deterministicID(
                productAwareIntentID: productAwareIntent.intentID,
                strategy: strategy,
                sourceMessageID: sourceMessageID,
                strategyRunID: strategyRunID,
                sourceSequence: sourceSequence
            ),
            productAwareOrderIntent: productAwareIntent,
            strategy: strategy,
            sourceMessageID: sourceMessageID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence,
            emittedAt: Date(timeIntervalSince1970: TimeInterval(sourceSequence))
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FullE2E.suite.\(field)")
        }
    }
}
