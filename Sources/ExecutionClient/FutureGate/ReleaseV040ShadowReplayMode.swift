import DomainModel
import Foundation

/// ReleaseV040ShadowReplayInputKind 固定 GH-706 shadow replay 可以读取的输入类别。
///
/// 输入只代表 historical / deterministic replay source，不是 live market stream、
/// signed endpoint、broker payload 或 production account state。
public enum ReleaseV040ShadowReplayInputKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case historicalMarketEvent = "historical market event"
    case historicalRunEvent = "historical run event"
}

/// ReleaseV040ShadowReplayForbiddenCapability 枚举 GH-706 必须保持关闭的能力。
public enum ReleaseV040ShadowReplayForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case networkCall = "network call"
    case brokerConnection = "broker connection"
    case testnetConnection = "testnet connection"
    case productionEndpointConnection = "production endpoint connection"
    case productionSecretRead = "production secret read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverApproval = "production cutover approval"
    case treatsShadowAsProductionApproval = "shadow success treated as production approval"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV040ShadowReplayInputEvent 是 GH-706 replay-only 输入。
public struct ReleaseV040ShadowReplayInputEvent: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let kind: ReleaseV040ShadowReplayInputKind
    public let productType: ProductType
    public let strategy: ReleaseV040RehearsalStrategyKind
    public let sourceSequence: Int
    public let payloadType: String
    public let observedAt: Date
    public let deterministicReplayInput: Bool
    public let historicalSourceReferenced: Bool
    public let networkCallPerformed: Bool
    public let brokerConnectionOpened: Bool
    public let productionOrderSubmitted: Bool

    public var inputHeld: Bool {
        runContext.mode == .shadow
            && runContext.boundaryHeld
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(productType)
            && ReleaseV040RehearsalRunContext.requiredStrategies.contains(strategy)
            && sourceSequence > 0
            && payloadType.isEmpty == false
            && deterministicReplayInput
            && historicalSourceReferenced
            && networkCallPerformed == false
            && brokerConnectionOpened == false
            && productionOrderSubmitted == false
    }

    public init(
        inputID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        kind: ReleaseV040ShadowReplayInputKind,
        productType: ProductType,
        strategy: ReleaseV040RehearsalStrategyKind,
        sourceSequence: Int,
        payloadType: String,
        observedAt: Date,
        deterministicReplayInput: Bool = true,
        historicalSourceReferenced: Bool = true,
        networkCallPerformed: Bool = false,
        brokerConnectionOpened: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        guard runContext.mode == .shadow else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.input.mode",
                expected: ReleaseV040RehearsalRunMode.shadow.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.input.productType",
                expected: ReleaseV040RehearsalRunContext.requiredProductTypes.map(\.rawValue).joined(separator: ","),
                actual: productType.rawValue
            )
        }
        guard ReleaseV040RehearsalRunContext.requiredStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.input.strategy",
                expected: ReleaseV040RehearsalRunContext.requiredStrategies.map(\.rawValue).joined(separator: ","),
                actual: strategy.rawValue
            )
        }
        guard sourceSequence > 0, payloadType.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.input.source",
                expected: "positive sequence and payload type",
                actual: "\(sourceSequence):\(payloadType)"
            )
        }
        guard deterministicReplayInput, historicalSourceReferenced else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.input.replaySource",
                expected: "deterministic historical replay input",
                actual: "\(deterministicReplayInput):\(historicalSourceReferenced)"
            )
        }
        try Self.forbid(networkCallPerformed, "networkCallPerformed")
        try Self.forbid(brokerConnectionOpened, "brokerConnectionOpened")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")

        self.inputID = inputID
        self.runContext = runContext
        self.kind = kind
        self.productType = productType
        self.strategy = strategy
        self.sourceSequence = sourceSequence
        self.payloadType = payloadType
        self.observedAt = observedAt
        self.deterministicReplayInput = deterministicReplayInput
        self.historicalSourceReferenced = historicalSourceReferenced
        self.networkCallPerformed = networkCallPerformed
        self.brokerConnectionOpened = brokerConnectionOpened
        self.productionOrderSubmitted = productionOrderSubmitted
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040ShadowReplay.input.\(field)")
        }
    }
}

/// ReleaseV040ShadowReplayStepEvidence 是 shadow mode 对 dry-run step shape 的 replay 证据。
public struct ReleaseV040ShadowReplayStepEvidence: Codable, Equatable, Sendable {
    public let step: ReleaseV040RuntimeKernelDryRunStep
    public let sequence: Int
    public let inputEventIDs: [Identifier]
    public let envelopes: [ReleaseV040UnifiedEvidenceEnvelope]

    public var runID: Identifier? { envelopes.first?.runID }

    public var stepHeld: Bool {
        sequence > 0
            && inputEventIDs.isEmpty == false
            && envelopes.map(\.module) == step.evidenceModules
            && envelopes.allSatisfy(\.boundaryHeld)
            && envelopes.allSatisfy { $0.mode == .shadow }
            && envelopes.allSatisfy { $0.runID == runID }
    }

    public init(
        step: ReleaseV040RuntimeKernelDryRunStep,
        sequence: Int,
        inputEventIDs: [Identifier],
        envelopes: [ReleaseV040UnifiedEvidenceEnvelope]
    ) throws {
        guard sequence > 0, inputEventIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.step",
                expected: "positive sequence and replay input references",
                actual: "\(sequence):\(inputEventIDs.count)"
            )
        }
        guard envelopes.map(\.module) == step.evidenceModules else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.step.modules",
                expected: step.evidenceModules.map(\.rawValue).joined(separator: ","),
                actual: envelopes.map(\.module.rawValue).joined(separator: ",")
            )
        }
        guard let runID = envelopes.first?.runID,
              envelopes.allSatisfy({ $0.runID == runID && $0.mode == .shadow }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.step.runID",
                expected: "single shadow runID",
                actual: "split"
            )
        }

        self.step = step
        self.sequence = sequence
        self.inputEventIDs = inputEventIDs
        self.envelopes = envelopes
    }
}

/// ReleaseV040ShadowReplayModeEvidence 汇总 GH-706 shadow replay mode。
public struct ReleaseV040ShadowReplayModeEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let releaseVersion: String
    public let runContext: ReleaseV040RehearsalRunContext
    public let inputEvents: [ReleaseV040ShadowReplayInputEvent]
    public let stepEvidence: [ReleaseV040ShadowReplayStepEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let sameRunIDChainShapeAsDryRun: Bool
    public let shadowReplayOnly: Bool
    public let networkCallsPerformed: Bool
    public let brokerConnectionOpened: Bool
    public let testnetConnected: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let shadowSuccessTreatedAsProductionApproval: Bool
    public let startsNextMilestone: Bool

    public var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        stepEvidence.flatMap(\.envelopes)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-706"
            && upstreamIssueID.rawValue == "GH-703"
            && downstreamIssueID.rawValue == "GH-707"
            && releaseVersion == "v0.4.0"
            && runContext.mode == .shadow
            && runContext.boundaryHeld
            && inputEvents.count == 4
            && Set(inputEvents.map(\.kind)) == Set(ReleaseV040ShadowReplayInputKind.allCases)
            && Set(inputEvents.map(\.productType)) == Set(ReleaseV040RehearsalRunContext.requiredProductTypes)
            && Set(inputEvents.map(\.strategy)) == Set(ReleaseV040RehearsalRunContext.requiredStrategies)
            && inputEvents.allSatisfy(\.inputHeld)
            && inputEvents.allSatisfy { $0.runContext.runID == runContext.runID }
            && stepEvidence.map(\.step) == ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder
            && stepEvidence.allSatisfy(\.stepHeld)
            && envelopes.map(\.module) == ReleaseV040UnifiedEvidenceModule.allCases
            && envelopes.allSatisfy { $0.runID == runContext.runID && $0.mode == .shadow }
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && sameRunIDChainShapeAsDryRun
            && shadowReplayOnly
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        networkCallsPerformed == false
            && brokerConnectionOpened == false
            && testnetConnected == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && shadowSuccessTreatedAsProductionApproval == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-706-v040-shadow-replay-mode"),
        issueID: Identifier = Identifier.constant("GH-706"),
        upstreamIssueID: Identifier = Identifier.constant("GH-703"),
        downstreamIssueID: Identifier = Identifier.constant("GH-707"),
        releaseVersion: String = "v0.4.0",
        runContext: ReleaseV040RehearsalRunContext,
        inputEvents: [ReleaseV040ShadowReplayInputEvent],
        stepEvidence: [ReleaseV040ShadowReplayStepEvidence],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        sameRunIDChainShapeAsDryRun: Bool = true,
        shadowReplayOnly: Bool = true,
        networkCallsPerformed: Bool = false,
        brokerConnectionOpened: Bool = false,
        testnetConnected: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        shadowSuccessTreatedAsProductionApproval: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validate(
            runContext: runContext,
            inputEvents: inputEvents,
            stepEvidence: stepEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            sameRunIDChainShapeAsDryRun: sameRunIDChainShapeAsDryRun,
            shadowReplayOnly: shadowReplayOnly,
            networkCallsPerformed: networkCallsPerformed,
            brokerConnectionOpened: brokerConnectionOpened,
            testnetConnected: testnetConnected,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretRead: productionSecretRead,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            shadowSuccessTreatedAsProductionApproval: shadowSuccessTreatedAsProductionApproval,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.runContext = runContext
        self.inputEvents = inputEvents
        self.stepEvidence = stepEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.sameRunIDChainShapeAsDryRun = sameRunIDChainShapeAsDryRun
        self.shadowReplayOnly = shadowReplayOnly
        self.networkCallsPerformed = networkCallsPerformed
        self.brokerConnectionOpened = brokerConnectionOpened
        self.testnetConnected = testnetConnected
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.shadowSuccessTreatedAsProductionApproval = shadowSuccessTreatedAsProductionApproval
        self.startsNextMilestone = startsNextMilestone

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.evidenceHeld",
                expected: "held GH-706 shadow replay evidence",
                actual: "false"
            )
        }
    }

    public static let validationAnchor = "TVM-RELEASE-V040-SHADOW-REPLAY-MODE"
    public static let requiredValidationAnchors = [
        "V040-13-SHADOW-REPLAY-MODE",
        "V040-13-HISTORICAL-DETERMINISTIC-INPUT",
        "V040-13-SAME-RUNID-EVIDENCE-CHAIN-SHAPE",
        "V040-13-NO-NETWORK-BROKER-CALLS",
        "V040-13-SHADOW-IS-NOT-PRODUCTION-APPROVAL",
        validationAnchor
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls",
        "bash checks/verify-v0.3.1.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV040ShadowReplayMode 生成 GH-706 deterministic shadow replay evidence。
public enum ReleaseV040ShadowReplayMode {
    public static func deterministicEvidence() throws -> ReleaseV040ShadowReplayModeEvidence {
        let runContext = try deterministicRunContext()
        let inputEvents = try deterministicInputEvents(runContext: runContext)
        return try ReleaseV040ShadowReplayModeEvidence(
            runContext: runContext,
            inputEvents: inputEvents,
            stepEvidence: deterministicStepEvidence(runContext: runContext, inputEvents: inputEvents)
        )
    }

    public static func brokerConnectionRejected() throws -> Bool {
        let evidence = try deterministicEvidence()
        do {
            _ = try ReleaseV040ShadowReplayModeEvidence(
                runContext: evidence.runContext,
                inputEvents: evidence.inputEvents,
                stepEvidence: evidence.stepEvidence,
                brokerConnectionOpened: true
            )
            return false
        } catch CoreError.liveTradingBoundaryForbiddenCapability("releaseV040ShadowReplay.brokerConnectionOpened") {
            return true
        }
    }

    public static func deterministicInputEvents(
        runContext: ReleaseV040RehearsalRunContext
    ) throws -> [ReleaseV040ShadowReplayInputEvent] {
        let specs: [(ReleaseV040ShadowReplayInputKind, ProductType, ReleaseV040RehearsalStrategyKind, String)] = [
            (.historicalMarketEvent, .spot, .ema, "shadow.spot.ema.market-event"),
            (.historicalMarketEvent, .usdsPerpetual, .rsi, "shadow.usds-perpetual.rsi.market-event"),
            (.historicalRunEvent, .spot, .rsi, "shadow.spot.rsi.run-event"),
            (.historicalRunEvent, .usdsPerpetual, .ema, "shadow.usds-perpetual.ema.run-event")
        ]
        return try specs.enumerated().map { index, spec in
            let sequence = index + 1
            return try ReleaseV040ShadowReplayInputEvent(
                inputID: Identifier.constant("gh-706-v040-shadow-input-\(sequence)"),
                runContext: runContext,
                kind: spec.0,
                productType: spec.1,
                strategy: spec.2,
                sourceSequence: sequence,
                payloadType: spec.3,
                observedAt: Date(timeIntervalSince1970: 1_706_004_000 + TimeInterval(sequence))
            )
        }
    }

    public static func deterministicStepEvidence(
        runContext: ReleaseV040RehearsalRunContext,
        inputEvents: [ReleaseV040ShadowReplayInputEvent]
    ) throws -> [ReleaseV040ShadowReplayStepEvidence] {
        let inputEventIDs = inputEvents.map(\.inputID)
        var upstreamEvidenceID: Identifier?
        var envelopeSequence = 1
        var steps: [ReleaseV040ShadowReplayStepEvidence] = []

        for (stepIndex, step) in ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder.enumerated() {
            var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] = []
            for module in step.evidenceModules {
                let component = module.rawValue.normalizedShadowReplayComponent
                let evidenceID = Identifier.constant("gh-706-v040-\(component)-shadow-evidence")
                let envelope = try ReleaseV040UnifiedEvidenceEnvelope(
                    envelopeID: Identifier.constant("gh-706-v040-\(component)-shadow-envelope"),
                    runContext: runContext,
                    module: module,
                    sourceIssueID: Identifier.constant("GH-706"),
                    evidenceID: evidenceID,
                    upstreamEvidenceID: upstreamEvidenceID,
                    validationAnchor: ReleaseV040ShadowReplayModeEvidence.validationAnchor,
                    sequence: envelopeSequence
                )
                envelopes.append(envelope)
                upstreamEvidenceID = evidenceID
                envelopeSequence += 1
            }
            steps.append(
                try ReleaseV040ShadowReplayStepEvidence(
                    step: step,
                    sequence: stepIndex + 1,
                    inputEventIDs: inputEventIDs,
                    envelopes: envelopes
                )
            )
        }

        return steps
    }

    private static func deterministicRunContext() throws -> ReleaseV040RehearsalRunContext {
        try ReleaseV040RehearsalRunContext(
            runID: Identifier.constant("gh-706-v040-shadow-replay-run"),
            mode: .shadow,
            correlationID: Identifier.constant("gh-706-v040-shadow-correlation"),
            causationID: Identifier.constant("gh-703-v040-eventstore-run")
        )
    }
}

private extension ReleaseV040ShadowReplayModeEvidence {
    static func validate(
        runContext: ReleaseV040RehearsalRunContext,
        inputEvents: [ReleaseV040ShadowReplayInputEvent],
        stepEvidence: [ReleaseV040ShadowReplayStepEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String],
        sameRunIDChainShapeAsDryRun: Bool,
        shadowReplayOnly: Bool,
        networkCallsPerformed: Bool,
        brokerConnectionOpened: Bool,
        testnetConnected: Bool,
        productionEndpointConnected: Bool,
        productionSecretRead: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        shadowSuccessTreatedAsProductionApproval: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard runContext.mode == .shadow else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.mode",
                expected: ReleaseV040RehearsalRunMode.shadow.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard inputEvents.isEmpty == false,
              inputEvents.allSatisfy({ $0.inputHeld && $0.runContext.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.inputEvents",
                expected: "held replay-only input events for one runID",
                actual: "\(inputEvents.count)"
            )
        }
        guard stepEvidence.map(\.step) == ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder,
              stepEvidence.allSatisfy(\.stepHeld),
              stepEvidence.flatMap(\.envelopes).allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.stepEvidence",
                expected: "same dry-run step shape with one shadow runID",
                actual: stepEvidence.map(\.step.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == requiredValidationAnchors,
              requiredValidationCommands == Self.requiredValidationCommands,
              sameRunIDChainShapeAsDryRun,
              shadowReplayOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040ShadowReplay.contract",
                expected: "required anchors, commands, same runID shape, shadow replay only",
                actual: "\(validationAnchors.count):\(sameRunIDChainShapeAsDryRun):\(shadowReplayOnly)"
            )
        }
        let forbiddenFlags = [
            ("networkCallsPerformed", networkCallsPerformed),
            ("brokerConnectionOpened", brokerConnectionOpened),
            ("testnetConnected", testnetConnected),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretRead", productionSecretRead),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("shadowSuccessTreatedAsProductionApproval", shadowSuccessTreatedAsProductionApproval),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040ShadowReplay.\(field)")
        }
    }
}

private extension String {
    var normalizedShadowReplayComponent: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
}
