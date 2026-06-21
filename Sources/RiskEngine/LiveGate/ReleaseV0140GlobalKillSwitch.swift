import DomainModel
import Foundation

/// ReleaseV0140GlobalKillSwitchCommandKind 表达 GH-1035 需要被全局 kill switch 覆盖的命令面。
///
/// 这些 case 只描述本地 command intent / evidence 分类，不代表已经生成 adapter request，
/// 也不授权 Binance testnet 或 production 的真实网络动作。
public enum ReleaseV0140GlobalKillSwitchCommandKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// ReleaseV0140GlobalKillSwitchDecisionOutcome 是 GH-1035 的命令门禁结果。
public enum ReleaseV0140GlobalKillSwitchDecisionOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allowed
    case blocked
}

/// ReleaseV0140GlobalKillSwitchBlockReason 记录 submit / cancel / replace 被 fail closed 的原因。
public enum ReleaseV0140GlobalKillSwitchBlockReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none
    case killSwitchActive
    case noTradeStateActive
    case missingRiskAcceptedDecision
    case missingLocalOMSOrderIdentity
    case productionTradingRequested
}

/// ReleaseV0140GlobalKillSwitchPolicy 固定 v0.14.0 全局 shutdown gate。
///
/// Policy 默认保持 kill switch active，用于证明 submit / cancel / replace 在 gate active 时
/// 全部阻断。测试可显式创建 inactive policy 验证允许路径，但该允许路径仍只表示本地 evidence
/// 可继续传递，不表示生产交易或真实 broker action 已获授权。
public struct ReleaseV0140GlobalKillSwitchPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let releaseVenueID: Identifier
    public let coveredCommands: Set<ReleaseV0140GlobalKillSwitchCommandKind>
    public let killSwitchActive: Bool
    public let noTradeStateActive: Bool
    public let auditEvidenceRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        policyID: Identifier = Identifier.constant(
            "gh-1035-v0140-global-kill-switch-policy",
            field: "releaseV0140GlobalKillSwitch.policyID"
        ),
        releaseVenueID: Identifier = OrderIntent.activeVenueID,
        coveredCommands: Set<ReleaseV0140GlobalKillSwitchCommandKind> = Set(ReleaseV0140GlobalKillSwitchCommandKind.allCases),
        killSwitchActive: Bool = true,
        noTradeStateActive: Bool = false,
        auditEvidenceRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        guard releaseVenueID == OrderIntent.activeVenueID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.nonBinanceVenue")
        }
        guard coveredCommands == Set(ReleaseV0140GlobalKillSwitchCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.coveredCommands",
                expected: ReleaseV0140GlobalKillSwitchCommandKind.allCases.map(\.rawValue).sorted().joined(separator: ","),
                actual: coveredCommands.map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard auditEvidenceRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.auditEvidenceRequired",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.policyID = policyID
        self.releaseVenueID = releaseVenueID
        self.coveredCommands = coveredCommands
        self.killSwitchActive = killSwitchActive
        self.noTradeStateActive = noTradeStateActive
        self.auditEvidenceRequired = auditEvidenceRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        releaseVenueID == OrderIntent.activeVenueID
            && coveredCommands == Set(ReleaseV0140GlobalKillSwitchCommandKind.allCases)
            && auditEvidenceRequired
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    public static func deterministicFixture(
        killSwitchActive: Bool = true,
        noTradeStateActive: Bool = false
    ) throws -> ReleaseV0140GlobalKillSwitchPolicy {
        try ReleaseV0140GlobalKillSwitchPolicy(
            killSwitchActive: killSwitchActive,
            noTradeStateActive: noTradeStateActive
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.policy.\(field)")
        }
    }
}

/// ReleaseV0140GlobalKillSwitchDecision 是 GH-1035 的本地 command shutdown evidence。
///
/// blocked decision 必须把 request mapping 与 adapter action 同时关掉，并且必须输出
/// audit evidence。allowed decision 只表示 gate inactive 且前置 evidence 齐备，可由后续
/// testnet-only path 继续评估；它不执行网络动作。
public struct ReleaseV0140GlobalKillSwitchDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let policyID: Identifier
    public let command: ReleaseV0140GlobalKillSwitchCommandKind
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int
    public let localOrderID: Identifier?
    public let inputLifecycleState: OrderLifecycleState
    public let outcome: ReleaseV0140GlobalKillSwitchDecisionOutcome
    public let blockReasons: [ReleaseV0140GlobalKillSwitchBlockReason]
    public let requestMappingAllowed: Bool
    public let adapterActionAllowed: Bool
    public let auditEvidenceEmitted: Bool
    public let nextLifecycleState: OrderLifecycleState
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        decisionID: Identifier,
        policyID: Identifier,
        command: ReleaseV0140GlobalKillSwitchCommandKind,
        intentID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int,
        localOrderID: Identifier?,
        inputLifecycleState: OrderLifecycleState,
        outcome: ReleaseV0140GlobalKillSwitchDecisionOutcome,
        blockReasons: [ReleaseV0140GlobalKillSwitchBlockReason],
        requestMappingAllowed: Bool,
        adapterActionAllowed: Bool,
        auditEvidenceEmitted: Bool = true,
        nextLifecycleState: OrderLifecycleState,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = ReleaseV0140GlobalKillSwitch.requiredValidationAnchors
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.sourceSequence",
                expected: "positive source sequence",
                actual: "\(sourceSequence)"
            )
        }
        guard auditEvidenceEmitted else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.auditEvidenceEmitted",
                expected: "true",
                actual: "false"
            )
        }
        guard validationAnchors == ReleaseV0140GlobalKillSwitch.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.validationAnchors",
                expected: ReleaseV0140GlobalKillSwitch.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        switch outcome {
        case .allowed:
            guard blockReasons == [.none],
                  requestMappingAllowed,
                  adapterActionAllowed,
                  nextLifecycleState == inputLifecycleState else {
                let actualBlockReasons = blockReasons.map(\.rawValue).joined(separator: ",")
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140GlobalKillSwitch.allowedDecision",
                    expected: "no block reason and mapping/action allowed",
                    actual: actualBlockReasons
                )
            }
        case .blocked:
            guard blockReasons.isEmpty == false,
                  blockReasons != [.none],
                  requestMappingAllowed == false,
                  adapterActionAllowed == false,
                  nextLifecycleState == .failedClosed else {
                let actualBlockReasons = blockReasons.map(\.rawValue).joined(separator: ",")
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140GlobalKillSwitch.blockedDecision",
                    expected: "explicit block reason and no mapping/action",
                    actual: actualBlockReasons
                )
            }
        }

        if command == .submit {
            guard localOrderID == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140GlobalKillSwitch.submit.localOrderID",
                    expected: "nil before submit",
                    actual: localOrderID?.rawValue ?? "nil"
                )
            }
        } else {
            guard localOrderID != nil || blockReasons.contains(.missingLocalOMSOrderIdentity) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140GlobalKillSwitch.cancelReplace.localOrderID",
                    expected: "existing local OMS order identity or explicit missing-identity block",
                    actual: "nil"
                )
            }
            guard ReleaseV0140GlobalKillSwitch.allowedCancelReplaceStates.contains(inputLifecycleState)
                    || outcome == .blocked else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140GlobalKillSwitch.cancelReplace.lifecycleState",
                    expected: ReleaseV0140GlobalKillSwitch.allowedCancelReplaceStates.map(\.rawValue).sorted().joined(separator: ","),
                    actual: inputLifecycleState.rawValue
                )
            }
        }

        guard decisionID == Self.deterministicID(
            policyID: policyID,
            command: command,
            intentID: intentID,
            sourceSequence: sourceSequence,
            outcome: outcome
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.decisionID",
                expected: Self.deterministicID(
                    policyID: policyID,
                    command: command,
                    intentID: intentID,
                    sourceSequence: sourceSequence,
                    outcome: outcome
                ).rawValue,
                actual: decisionID.rawValue
            )
        }

        self.decisionID = decisionID
        self.policyID = policyID
        self.command = command
        self.intentID = intentID
        self.strategyRunID = strategyRunID
        self.sourceSequence = sourceSequence
        self.localOrderID = localOrderID
        self.inputLifecycleState = inputLifecycleState
        self.outcome = outcome
        self.blockReasons = blockReasons
        self.requestMappingAllowed = requestMappingAllowed
        self.adapterActionAllowed = adapterActionAllowed
        self.auditEvidenceEmitted = auditEvidenceEmitted
        self.nextLifecycleState = nextLifecycleState
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        auditEvidenceEmitted
            && validationAnchors == ReleaseV0140GlobalKillSwitch.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && (outcome == .allowed ? blockReasons == [.none] : blockReasons != [.none])
            && (outcome == .blocked ? requestMappingAllowed == false && adapterActionAllowed == false : true)
    }

    public static func deterministicID(
        policyID: Identifier,
        command: ReleaseV0140GlobalKillSwitchCommandKind,
        intentID: Identifier,
        sourceSequence: Int,
        outcome: ReleaseV0140GlobalKillSwitchDecisionOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1035-global-kill-switch-decision",
                policyID.rawValue,
                command.rawValue,
                intentID.rawValue,
                "\(sourceSequence)",
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0140GlobalKillSwitch.decisionID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.decision.\(field)")
        }
    }
}

/// ReleaseV0140GlobalKillSwitchEvidence 汇总 GH-1035 的 submit / cancel / replace 阻断证据。
public struct ReleaseV0140GlobalKillSwitchEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let policyID: Identifier
    public let decisions: [ReleaseV0140GlobalKillSwitchDecision]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        evidenceID: Identifier,
        policyID: Identifier,
        decisions: [ReleaseV0140GlobalKillSwitchDecision],
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = ReleaseV0140GlobalKillSwitch.requiredValidationAnchors
    ) throws {
        guard decisions.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.decisions",
                expected: "non-empty decision evidence",
                actual: "empty"
            )
        }
        guard decisions.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.unheldDecision")
        }
        guard decisions.allSatisfy({ $0.policyID == policyID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.policyID",
                expected: policyID.rawValue,
                actual: decisions.map(\.policyID.rawValue).joined(separator: ",")
            )
        }
        guard Set(decisions.map(\.command)) == Set(ReleaseV0140GlobalKillSwitchCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.coveredCommands",
                expected: ReleaseV0140GlobalKillSwitchCommandKind.allCases.map(\.rawValue).sorted().joined(separator: ","),
                actual: decisions.map(\.command.rawValue).sorted().joined(separator: ",")
            )
        }
        guard decisions.filter({ $0.outcome == .blocked }).allSatisfy({
            $0.requestMappingAllowed == false && $0.adapterActionAllowed == false && $0.auditEvidenceEmitted
        }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.blockedCommandBypass")
        }
        guard validationAnchors == ReleaseV0140GlobalKillSwitch.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.evidence.validationAnchors",
                expected: ReleaseV0140GlobalKillSwitch.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        guard evidenceID == Self.deterministicID(policyID: policyID, decisions: decisions) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.evidenceID",
                expected: Self.deterministicID(policyID: policyID, decisions: decisions).rawValue,
                actual: evidenceID.rawValue
            )
        }

        self.evidenceID = evidenceID
        self.policyID = policyID
        self.decisions = decisions
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        decisions.allSatisfy(\.boundaryHeld)
            && Set(decisions.map(\.command)) == Set(ReleaseV0140GlobalKillSwitchCommandKind.allCases)
            && decisions.filter { $0.outcome == .blocked }.allSatisfy {
                $0.requestMappingAllowed == false && $0.adapterActionAllowed == false && $0.auditEvidenceEmitted
            }
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && validationAnchors == ReleaseV0140GlobalKillSwitch.requiredValidationAnchors
    }

    public static func deterministicID(
        policyID: Identifier,
        decisions: [ReleaseV0140GlobalKillSwitchDecision]
    ) -> Identifier {
        let decisionPart = decisions.map(\.decisionID.rawValue).joined(separator: ":")
        return Identifier.constant(
            "gh-1035-global-kill-switch-evidence:\(policyID.rawValue):\(decisionPart)",
            field: "releaseV0140GlobalKillSwitch.evidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.evidence.\(field)")
        }
    }
}

/// ReleaseV0140GlobalKillSwitch 是 GH-1035 的全局 submit / cancel / replace shutdown gate。
public struct ReleaseV0140GlobalKillSwitch: Codable, Equatable, Sendable {
    public let policy: ReleaseV0140GlobalKillSwitchPolicy

    public init(policy: ReleaseV0140GlobalKillSwitchPolicy) throws {
        guard policy.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140GlobalKillSwitch.unheldPolicy")
        }
        self.policy = policy
    }

    public static func deterministicFixture(
        killSwitchActive: Bool = true,
        noTradeStateActive: Bool = false
    ) throws -> ReleaseV0140GlobalKillSwitch {
        try ReleaseV0140GlobalKillSwitch(
            policy: .deterministicFixture(
                killSwitchActive: killSwitchActive,
                noTradeStateActive: noTradeStateActive
            )
        )
    }

    public var boundaryHeld: Bool {
        policy.boundaryHeld
    }

    public func evaluateSubmit(
        riskDecision: ReleaseV0140PreTradeRiskDecision,
        productionTradingRequested: Bool = false
    ) throws -> ReleaseV0140GlobalKillSwitchDecision {
        let reasons = blockReasons(
            command: .submit,
            riskDecisionAccepted: riskDecision.outcome == .accepted && riskDecision.adapterSubmitEligible,
            localOrderID: nil,
            productionTradingRequested: productionTradingRequested
        )
        return try makeDecision(
            command: .submit,
            intentID: riskDecision.intentID,
            strategyRunID: riskDecision.strategyRunID,
            sourceSequence: riskDecision.sourceSequence,
            localOrderID: nil,
            inputLifecycleState: .riskAccepted,
            blockReasons: reasons
        )
    }

    public func evaluateCancelOrReplace(
        command: ReleaseV0140GlobalKillSwitchCommandKind,
        intentID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int,
        localOrderID: Identifier?,
        currentLifecycleState: OrderLifecycleState,
        productionTradingRequested: Bool = false
    ) throws -> ReleaseV0140GlobalKillSwitchDecision {
        guard command == .cancel || command == .replace else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140GlobalKillSwitch.cancelReplace.command",
                expected: "cancel or replace",
                actual: command.rawValue
            )
        }
        let reasons = blockReasons(
            command: command,
            riskDecisionAccepted: true,
            localOrderID: localOrderID,
            productionTradingRequested: productionTradingRequested
        )
        return try makeDecision(
            command: command,
            intentID: intentID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence,
            localOrderID: localOrderID,
            inputLifecycleState: currentLifecycleState,
            blockReasons: reasons
        )
    }

    public func deterministicEvidence(
        riskDecision: ReleaseV0140PreTradeRiskDecision,
        localOrderID: Identifier
    ) throws -> ReleaseV0140GlobalKillSwitchEvidence {
        let submit = try evaluateSubmit(riskDecision: riskDecision)
        let cancel = try evaluateCancelOrReplace(
            command: .cancel,
            intentID: riskDecision.intentID,
            strategyRunID: riskDecision.strategyRunID,
            sourceSequence: riskDecision.sourceSequence + 1,
            localOrderID: localOrderID,
            currentLifecycleState: .accepted
        )
        let replace = try evaluateCancelOrReplace(
            command: .replace,
            intentID: riskDecision.intentID,
            strategyRunID: riskDecision.strategyRunID,
            sourceSequence: riskDecision.sourceSequence + 2,
            localOrderID: localOrderID,
            currentLifecycleState: .accepted
        )
        let decisions = [submit, cancel, replace]
        return try ReleaseV0140GlobalKillSwitchEvidence(
            evidenceID: ReleaseV0140GlobalKillSwitchEvidence.deterministicID(
                policyID: policy.policyID,
                decisions: decisions
            ),
            policyID: policy.policyID,
            decisions: decisions
        )
    }

    public static let allowedCancelReplaceStates: Set<OrderLifecycleState> = [
        .accepted,
        .partiallyFilled,
        .replaced
    ]

    public static let requiredValidationAnchors: [String] = [
        "GH-1035-GLOBAL-KILL-SWITCH",
        "GH-1035-SUBMIT-CANCEL-REPLACE-BLOCKED",
        "GH-1035-AUDIT-EVIDENCE",
        "TVM-RELEASE-V0140-GLOBAL-KILL-SWITCH"
    ]

    private func blockReasons(
        command: ReleaseV0140GlobalKillSwitchCommandKind,
        riskDecisionAccepted: Bool,
        localOrderID: Identifier?,
        productionTradingRequested: Bool
    ) -> [ReleaseV0140GlobalKillSwitchBlockReason] {
        var reasons: [ReleaseV0140GlobalKillSwitchBlockReason] = []
        if policy.killSwitchActive {
            reasons.append(.killSwitchActive)
        }
        if policy.noTradeStateActive {
            reasons.append(.noTradeStateActive)
        }
        if command == .submit, riskDecisionAccepted == false {
            reasons.append(.missingRiskAcceptedDecision)
        }
        if command != .submit, localOrderID == nil {
            reasons.append(.missingLocalOMSOrderIdentity)
        }
        if productionTradingRequested {
            reasons.append(.productionTradingRequested)
        }
        return reasons.isEmpty ? [.none] : reasons
    }

    private func makeDecision(
        command: ReleaseV0140GlobalKillSwitchCommandKind,
        intentID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int,
        localOrderID: Identifier?,
        inputLifecycleState: OrderLifecycleState,
        blockReasons: [ReleaseV0140GlobalKillSwitchBlockReason]
    ) throws -> ReleaseV0140GlobalKillSwitchDecision {
        let blocked = blockReasons != [.none]
        let outcome: ReleaseV0140GlobalKillSwitchDecisionOutcome = blocked ? .blocked : .allowed
        let decisionID = ReleaseV0140GlobalKillSwitchDecision.deterministicID(
            policyID: policy.policyID,
            command: command,
            intentID: intentID,
            sourceSequence: sourceSequence,
            outcome: outcome
        )
        return try ReleaseV0140GlobalKillSwitchDecision(
            decisionID: decisionID,
            policyID: policy.policyID,
            command: command,
            intentID: intentID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence,
            localOrderID: localOrderID,
            inputLifecycleState: inputLifecycleState,
            outcome: outcome,
            blockReasons: blockReasons,
            requestMappingAllowed: blocked == false,
            adapterActionAllowed: blocked == false,
            nextLifecycleState: blocked ? .failedClosed : inputLifecycleState
        )
    }
}
