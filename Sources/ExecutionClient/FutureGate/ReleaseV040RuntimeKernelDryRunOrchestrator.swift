import DomainModel
import Foundation

/// ReleaseV040RuntimeKernelDryRunStep 固定 GH-696 dry-run RuntimeKernel 的本地编排顺序。
///
/// 每个 step 只声明本地 evidence 应该如何排队；它不会打开 testnet、production endpoint、
/// broker session、secret provider 或真实 submit / cancel / replace 路径。
public enum ReleaseV040RuntimeKernelDryRunStep: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngine = "DataEngine"
    case messageBus = "MessageBus"
    case traderStrategies = "Trader / EMA / RSI"
    case riskEngine = "RiskEngine"
    case executionEngineOMS = "ExecutionEngine / OMS"
    case executionClientDryRunBoundary = "ExecutionClient dry-run boundary"
    case eventStore = "Event Store"
    case portfolioProjection = "Portfolio projection"
    case dashboardCLIProjection = "Dashboard / CLI projection"

    public var evidenceModules: [ReleaseV040UnifiedEvidenceModule] {
        switch self {
        case .dataEngine:
            [.dataEngine]
        case .messageBus:
            [.messageBus]
        case .traderStrategies:
            [.trader]
        case .riskEngine:
            [.riskEngine]
        case .executionEngineOMS:
            [.executionEngine, .oms]
        case .executionClientDryRunBoundary:
            [.executionClient]
        case .eventStore:
            [.eventStore]
        case .portfolioProjection:
            [.portfolio]
        case .dashboardCLIProjection:
            [.dashboard, .cli]
        }
    }
}

/// ReleaseV040RuntimeKernelDryRunStepEvidence 是单个 RuntimeKernel step 产生的本地 envelope 集合。
///
/// Step evidence 必须复用 GH-695 的 shared run context / envelope，且模块覆盖必须与 step
/// 声明完全一致；MessageBus、ExecutionEngine / OMS 和 Dashboard / CLI 这类组合 step 不得拆出独立 runID。
public struct ReleaseV040RuntimeKernelDryRunStepEvidence: Codable, Equatable, Sendable {
    public let step: ReleaseV040RuntimeKernelDryRunStep
    public let sequence: Int
    public let envelopes: [ReleaseV040UnifiedEvidenceEnvelope]

    public var runID: Identifier? { envelopes.first?.runID }

    public var boundaryHeld: Bool {
        sequence > 0
            && envelopes.isEmpty == false
            && envelopes.map(\.module) == step.evidenceModules
            && envelopes.allSatisfy(\.boundaryHeld)
            && envelopes.allSatisfy { $0.runID == runID }
    }

    public init(
        step: ReleaseV040RuntimeKernelDryRunStep,
        sequence: Int,
        envelopes: [ReleaseV040UnifiedEvidenceEnvelope]
    ) throws {
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "step.sequence",
                expected: "positive",
                actual: "\(sequence)"
            )
        }
        guard envelopes.map(\.module) == step.evidenceModules else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "step.evidenceModules",
                expected: step.evidenceModules.map(\.rawValue).joined(separator: ","),
                actual: envelopes.map(\.module.rawValue).joined(separator: ",")
            )
        }
        guard let firstRunID = envelopes.first?.runID, envelopes.allSatisfy({ $0.runID == firstRunID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "step.runID",
                expected: "single runID",
                actual: "split"
            )
        }

        self.step = step
        self.sequence = sequence
        self.envelopes = envelopes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            step: try container.decode(ReleaseV040RuntimeKernelDryRunStep.self, forKey: .step),
            sequence: try container.decode(Int.self, forKey: .sequence),
            envelopes: try container.decode([ReleaseV040UnifiedEvidenceEnvelope].self, forKey: .envelopes)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case step
        case sequence
        case envelopes
    }
}

/// ReleaseV040RuntimeKernelDryRunResult 是一次本地 dry-run 编排的结果外壳。
public struct ReleaseV040RuntimeKernelDryRunResult: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let stepEvidence: [ReleaseV040RuntimeKernelDryRunStepEvidence]
    public let validationAnchor: String

    public var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        stepEvidence.flatMap(\.envelopes)
    }

    public var boundaryHeld: Bool {
        validationAnchor == ReleaseV040RuntimeKernelDryRunOrchestrator.validationAnchor
            && stepEvidence.map(\.step) == ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder
            && stepEvidence.allSatisfy(\.boundaryHeld)
            && envelopes.allSatisfy { $0.runID == runID }
    }

    public init(
        runID: Identifier,
        stepEvidence: [ReleaseV040RuntimeKernelDryRunStepEvidence],
        validationAnchor: String = ReleaseV040RuntimeKernelDryRunOrchestrator.validationAnchor
    ) throws {
        guard validationAnchor == ReleaseV040RuntimeKernelDryRunOrchestrator.validationAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchor",
                expected: ReleaseV040RuntimeKernelDryRunOrchestrator.validationAnchor,
                actual: validationAnchor
            )
        }
        guard stepEvidence.map(\.step) == ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "stepOrder",
                expected: ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder.map(\.rawValue).joined(separator: ","),
                actual: stepEvidence.map(\.step.rawValue).joined(separator: ",")
            )
        }
        let envelopes = stepEvidence.flatMap(\.envelopes)
        guard envelopes.isEmpty == false, envelopes.allSatisfy({ $0.runID == runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "result.runID",
                expected: runID.rawValue,
                actual: "split or empty"
            )
        }

        self.runID = runID
        self.stepEvidence = stepEvidence
        self.validationAnchor = validationAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            runID: try container.decode(Identifier.self, forKey: .runID),
            stepEvidence: try container.decode([ReleaseV040RuntimeKernelDryRunStepEvidence].self, forKey: .stepEvidence),
            validationAnchor: try container.decode(String.self, forKey: .validationAnchor)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case runID
        case stepEvidence
        case validationAnchor
    }
}

/// ReleaseV040RuntimeKernelDryRunOrchestrator 是 GH-696 的 local-only RuntimeKernel 合同。
///
/// 该类型只驱动 deterministic evidence：它复用 GH-695 run context / envelope，按固定 step order
/// 生成本地结果。所有网络、secret、testnet 默认开启、production endpoint、broker、真实订单和
/// production cutover flags 都必须保持 false。
public struct ReleaseV040RuntimeKernelDryRunOrchestrator: Codable, Equatable, Sendable {
    public let orchestratorID: Identifier
    public let issueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let stepEvidence: [ReleaseV040RuntimeKernelDryRunStepEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let localDryRunOnly: Bool
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let testnetEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var steps: [ReleaseV040RuntimeKernelDryRunStep] {
        stepEvidence.map(\.step)
    }

    public var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        stepEvidence.flatMap(\.envelopes)
    }

    public var dryRunBoundaryHeld: Bool {
        issueID.rawValue == "GH-696"
            && runContext.mode == .dryRun
            && runContext.boundaryHeld
            && steps == Self.requiredStepOrder
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && stepEvidence.allSatisfy(\.boundaryHeld)
            && envelopes.allSatisfy { $0.runID == runContext.runID }
            && localDryRunOnly
            && forbiddenRuntimeHeld
    }

    public var forbiddenRuntimeHeld: Bool {
        networkCallsPerformed == false
            && secretReadsPerformed == false
            && testnetEnabledByDefault == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        orchestratorID: Identifier = Identifier.constant("gh-696-v040-runtime-kernel-dry-run-orchestrator"),
        issueID: Identifier = Identifier.constant("GH-696"),
        runContext: ReleaseV040RehearsalRunContext,
        stepEvidence: [ReleaseV040RuntimeKernelDryRunStepEvidence],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        localDryRunOnly: Bool = true,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        testnetEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-696" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-696",
                actual: issueID.rawValue
            )
        }
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard stepEvidence.map(\.step) == Self.requiredStepOrder else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "stepOrder",
                expected: Self.requiredStepOrder.map(\.rawValue).joined(separator: ","),
                actual: stepEvidence.map(\.step.rawValue).joined(separator: ",")
            )
        }
        guard stepEvidence.flatMap(\.envelopes).allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        guard localDryRunOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("localDryRunOnly=false")
        }
        try Self.validateForbiddenFlags(
            networkCallsPerformed: networkCallsPerformed,
            secretReadsPerformed: secretReadsPerformed,
            testnetEnabledByDefault: testnetEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.orchestratorID = orchestratorID
        self.issueID = issueID
        self.runContext = runContext
        self.stepEvidence = stepEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.localDryRunOnly = localDryRunOnly
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.testnetEnabledByDefault = testnetEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(
        orchestratorID: Identifier = Identifier.constant("gh-696-v040-runtime-kernel-dry-run-orchestrator"),
        issueID: Identifier = Identifier.constant("GH-696"),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        localDryRunOnly: Bool = true,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        testnetEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let runContext = try ReleaseV040RehearsalRunContext(
            runID: Identifier.constant("gh-696-v040-runtime-kernel-dry-run")
        )
        try self.init(
            orchestratorID: orchestratorID,
            issueID: issueID,
            runContext: runContext,
            stepEvidence: Self.deterministicStepEvidence(runContext: runContext),
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            localDryRunOnly: localDryRunOnly,
            networkCallsPerformed: networkCallsPerformed,
            secretReadsPerformed: secretReadsPerformed,
            testnetEnabledByDefault: testnetEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            orchestratorID: try container.decode(Identifier.self, forKey: .orchestratorID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            stepEvidence: try container.decode([ReleaseV040RuntimeKernelDryRunStepEvidence].self, forKey: .stepEvidence),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            localDryRunOnly: try container.decode(Bool.self, forKey: .localDryRunOnly),
            networkCallsPerformed: try container.decode(Bool.self, forKey: .networkCallsPerformed),
            secretReadsPerformed: try container.decode(Bool.self, forKey: .secretReadsPerformed),
            testnetEnabledByDefault: try container.decode(Bool.self, forKey: .testnetEnabledByDefault),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionBrokerConnected: try container.decode(Bool.self, forKey: .productionBrokerConnected),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        )
    }

    public func driveLocalDryRun() throws -> ReleaseV040RuntimeKernelDryRunResult {
        try ReleaseV040RuntimeKernelDryRunResult(
            runID: runContext.runID,
            stepEvidence: stepEvidence
        )
    }

    public static func deterministicFixture() throws -> ReleaseV040RuntimeKernelDryRunOrchestrator {
        let runContext = try ReleaseV040RehearsalRunContext(
            runID: Identifier.constant("gh-696-v040-runtime-kernel-dry-run")
        )
        return try ReleaseV040RuntimeKernelDryRunOrchestrator(
            runContext: runContext,
            stepEvidence: deterministicStepEvidence(runContext: runContext)
        )
    }

    public static func deterministicStepEvidence(
        runContext: ReleaseV040RehearsalRunContext
    ) throws -> [ReleaseV040RuntimeKernelDryRunStepEvidence] {
        var upstreamEvidenceID: Identifier?
        var envelopeSequence = 1
        var stepEvidence: [ReleaseV040RuntimeKernelDryRunStepEvidence] = []

        for (stepIndex, step) in requiredStepOrder.enumerated() {
            var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] = []
            for module in step.evidenceModules {
                let evidenceID = Identifier.constant(
                    "gh-696-v040-\(module.rawValue.normalizedRuntimeEvidenceComponent)-evidence"
                )
                let envelope = try ReleaseV040UnifiedEvidenceEnvelope(
                    envelopeID: Identifier.constant(
                        "gh-696-v040-\(module.rawValue.normalizedRuntimeEvidenceComponent)-envelope"
                    ),
                    runContext: runContext,
                    module: module,
                    sourceIssueID: Identifier.constant("GH-696"),
                    evidenceID: evidenceID,
                    upstreamEvidenceID: upstreamEvidenceID,
                    validationAnchor: validationAnchor,
                    sequence: envelopeSequence
                )
                envelopes.append(envelope)
                upstreamEvidenceID = evidenceID
                envelopeSequence += 1
            }
            stepEvidence.append(
                try ReleaseV040RuntimeKernelDryRunStepEvidence(
                    step: step,
                    sequence: stepIndex + 1,
                    envelopes: envelopes
                )
            )
        }

        return stepEvidence
    }

    public static let validationAnchor = "TVM-RELEASE-V040-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR"

    public static let requiredStepOrder: [ReleaseV040RuntimeKernelDryRunStep] = [
        .dataEngine,
        .messageBus,
        .traderStrategies,
        .riskEngine,
        .executionEngineOMS,
        .executionClientDryRunBoundary,
        .eventStore,
        .portfolioProjection,
        .dashboardCLIProjection
    ]

    public static let requiredValidationAnchors = [
        "V040-03-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR",
        "V040-03-ONE-RUNID-STEP-ORDER",
        "V040-03-LOCAL-ONLY-DRY-RUN",
        "V040-03-FORBIDDEN-NETWORK-SECRET-PRODUCTION",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH696RuntimeKernelDryRunOrchestratorDrivesLocalRunWithoutNetworkOrSecrets",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private enum CodingKeys: String, CodingKey {
        case orchestratorID
        case issueID
        case runContext
        case stepEvidence
        case validationAnchors
        case requiredValidationCommands
        case localDryRunOnly
        case networkCallsPerformed
        case secretReadsPerformed
        case testnetEnabledByDefault
        case productionEndpointConnected
        case productionBrokerConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }
}

private extension ReleaseV040RuntimeKernelDryRunOrchestrator {
    static func validateForbiddenFlags(
        networkCallsPerformed: Bool,
        secretReadsPerformed: Bool,
        testnetEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("networkCallsPerformed", networkCallsPerformed),
            ("secretReadsPerformed", secretReadsPerformed),
            ("testnetEnabledByDefault", testnetEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}

private extension String {
    var normalizedRuntimeEvidenceComponent: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
}
